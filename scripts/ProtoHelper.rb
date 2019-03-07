#!/usr/bin/env ruby
# -w
# encoding: utf-8

=begin
功能：1.将gitlab上的proto文件下载到本地 download()  //弃用，改为由git控制下载更新
	 2.编译proto文件为objective-c文件 compile()
	 3.配置objective-c文件到工程	
	 4.提取头文件 到 额外的 

API文档：https://www.rubydoc.info/gems/xcodeproj/Xcodeproj	
=end

require 'open-uri'
require "net/https"
require 'find'
require "fileutils"
require 'xcodeproj'
require 'tmpdir'
 require 'set'

$FrameworkHeader = "ServerObjects.h"
$FrameworkHeaderDesc=<<END_OF_STRING
//
//  ServerObjects.h
//  ServerObjects
//
//  Created by  dingxiuwei on 2018/5/7.
//  Copyright © 2018年  dingxiuwei. All rights reserved.
//


//! Project version number for ServerObjects.
FOUNDATION_EXPORT double ServerObjectsVersionNumber;

//! Project version string for ServerObjects.
FOUNDATION_EXPORT const unsigned char ServerObjectsVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <ServerObjects/PublicHeader.h>

#import <Foundation/Foundation.h>

#import "PBIdPropertyFix.h"
END_OF_STRING


class ProtoHelper 

	def initialize(protocTool, source_proto_path, compiledPath,projectPath, projectName, gitHost='192.168.0.101', gitPort='443', gitToken='fY_9JmHyAnPmu9uAuCuy')
		@projectPath = projectPath
		@projectName = projectName
		@gitHost = gitHost
		@gitPort = gitPort
		@gitToken = gitToken
		@protoFiles = Array.new
		@headerFiles = Array.new
		@mFiles = Array.new
		@protocTool = protocTool
		@compiledPath = compiledPath
		@source_proto_path = source_proto_path

		FileUtils.rm_rf(@compiledPath)
		FileUtils.mkpath @compiledPath
		# puts 'initialize'
	end

	def download()
		tmpName = "bb1.gz"
		http = Net::HTTP.new(@gitHost, @gitPort)
		http.use_ssl = true
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		http.start {
			headers = {
				'PRIVATE-TOKEN' => @gitToken
			}
		path = '/api/v4/projects/94/repository/archive'
		http.request_get(path, headers) { |res|
				# res.each { |e| puts e.to_s + ':'+res[e.to_s] }
				File.open(tmpName, "w+") { |io| io.write res.body  }
				puts "download over"
				unGzip tmpName
		}
		}
	end

	def compile()
		buildTmp =  File.join(Dir.tmpdir, "protohhelprbtmp")
		Dir.mkdir(buildTmp) unless Dir.exist?(buildTmp)
		buildTmp2 =  File.join(Dir.tmpdir, "protohhelprbtmp2")
		Dir.mkdir(buildTmp2) unless Dir.exist?(buildTmp2)

		FileUtils.cp(@protoFiles,buildTmp2)
		
		protoFilesTmp = []
		Dir.glob(buildTmp2+"/*") { |file|  
			if file.end_with?('.proto')
				protoFilesTmp.push(file)
			end
		}

    	cmd_comps = []
		cmd_comps.push(@protocTool)
		cmd_comps.push('--proto_path=' + buildTmp2)
	    cmd_comps.push('--objc_out=' + buildTmp)
	    
	    cmd_comps << protoFilesTmp

	    cmd = cmd_comps.join(' ')
	    # puts "cmd:" + cmd.to_s
	    system cmd

	    Find.find(buildTmp) do |file|
			# if File::file?(file) && File.basename(file) =~ /.[m|h]$/i
			dst = File::join(@compiledPath, File.basename(file))
			if File::file?(file)
				# puts  dst
				if file.end_with?('.h')
					@headerFiles.push(dst)
				end
				if file.end_with?('.m')
					@mFiles.push(dst)
				end
				FileUtils.cp(file, dst)
			end
		end	

		FileUtils.rm_rf(buildTmp)
		FileUtils.rm_rf(buildTmp2)
	end

	def configProject()
		projectPath = File::join(@projectPath, @projectName + ".xcodeproj")
	    # puts File.exist?(projectPath)
		project = Xcodeproj::Project.open(projectPath)
		# project.targets.each do |t|
		# puts t
		# end

		target = project.targets.first
		# puts target

		# 找到要插入的group (参数中true表示如果找不到group，就创建一个group)
		group = project.main_group.find_subpath(File.join(@projectName,'proto'),true)

		# 清理以前的数据
		group.clear
		target.source_build_phase.clear
		target.headers_build_phase.files_references.each do |ref|
			if ref == nil || !(@@excludeHeaders.include?(ref.display_name))
				target.headers_build_phase.remove_file_reference(ref)
			end
		end
		
		# 设置新数据
		group.set_source_tree('SOURCE_ROOT')
		group.set_path(@compiledPath)
		@headerFiles.each do |f|
			file_ref = group.new_reference(f)
			target.add_file_references([file_ref]) do |build_file|
		        build_file.settings = { 'ATTRIBUTES' => ['Project'] }
		    end
		end

		@mFiles.each do |f|
			file_ref = group.new_reference(f)
			target.add_file_references([file_ref], '-fno-objc-arc')
		end

		group.sort()
		project.save
	end

	def unGzip(src,dst=@compiledPath)
 		FileUtils.mkdir_p(dst) unless File.exist?(dst)
 		result = system 'tar -zxf bb1.gz -C ' + dst
 		# puts result
	end

	def findProtos(src = @source_proto_path)
		# puts src
		@protoFiles.clear
		# Find.find(src) do |file| # 遍历目录下的所有文件
		Dir.foreach(src) do |file| # 只遍历当前目录 
			file = File.join(src,file) # 全路径
			# puts  file
			if File::file?(file) && File.basename(file) =~ /.proto$/i 
				@protoFiles.push(file)
			end
		end	
	end

	def buildFramewokHeadFile
		path = File.join(@compiledPath,$FrameworkHeader)
		# FileUtils.mkdir_p(path) unless File.exist?(path)
		File.open(path, "w+") do |header|
			header.puts $FrameworkHeaderDesc
			@headerFiles.each do |fileName|
				h = '#import "'+ File::basename(fileName) +'"'
				header.puts h
			end
			@headerFiles.push(header)
		end
	end

	def removeBuildPhaseFilesRecursively(aTarget, aGroup)
  		aGroup.files.each do |file|
      		if file.real_path.to_s.end_with?(".m", ".mm", ".cpp") then
          		aTarget.source_build_phase.remove_file_reference(file)
      		elsif file.real_path.to_s.end_with?(".plist") then
         		 aTarget.resources_build_phase.remove_file_reference(file)
      		end
      	end
  	end

  	def copyHeader(dir)
  		# puts dir 
  		FileUtils.mkpath(dir) 
  		@headerFiles.each { |f|
  			FileUtils.cp(f, dir)
  		  }

  		path = File.join(@projectPath,"ServerObjects","PBIdPropertyFix.h")
  		# puts path
  		FileUtils.cp(path, dir)
  	end
	# 调用
  	def ProtoHelper.Run(source_dir='../src/proto/src/main/proto/',
  						protoc_path = '../tools/protoc',
  		 				projectPath = '../src/LoochaCampusMain/LoochaCampusMain/OC/Dependencies/ServerObjects/'
  		 				)
		source_dir = File::expand_path(source_dir)
		protoc_path = File::expand_path(protoc_path)
		projectPath = File::expand_path(projectPath)
		compiled_OC_filePath = File.join(projectPath, '/ServerObjects/proto/')
		projectName = 'ServerObjects'
		@@excludeHeaders = Set.new([$FrameworkHeader,'PBIdPropertyFix.h'])
		help = ProtoHelper.new(protocTool=protoc_path, 
							   source_proto_path=source_dir, 
							   compiledPath=compiled_OC_filePath, 
							   projectPath=projectPath, 
							   projectName = projectName)
		# help.download()
		# help.unGzip('bb1.gz')
		help.findProtos()
		help.compile()
		help.buildFramewokHeadFile()
		help.configProject()
		help.copyHeader(File.join(source_dir,"../../../../","ProtoHeader","ServerObjects"))
  	end

end



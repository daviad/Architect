#!/usr/bin/env ruby
require './ProtoHelper.rb'
# clone or pull proto
if Dir.exist?(File::expand_path('../src/proto/'))
	# cmd_pull = <<-END_OF_STRING
	# cd ../src/proto/
	# git pull 
	# cd -
	# END_OF_STRING
	# system(cmd_pull)
	puts("protoc 已经clone 并配置好了，直接 update 库 就可以了")
	puts("proto 目录：")
	puts(File::expand_path('../src/proto/'))
	puts("如果 proto 目录不是 clone 目录,或者发生莫名错误。 删除此目录，从新运行此脚本即可")
	exit(0)
else
	cmd_clone = <<-END_OF_STRING
	git clone https://192.168.0.101/common/proto.git  ../src/proto/
	END_OF_STRING
	system(cmd_clone)
end

puts "create scripts"
# proto post-merge
source_dir = File::expand_path('../src/proto/src/main/proto/')
protoc_path = File::expand_path('../tools/protoc')
projectPath = File::expand_path('../src/LoochaCampusMain/LoochaCampusMain/OC/Dependencies/ServerObjects/')

args = "(source_dir=" + "'" + source_dir + "'" + "," +
  	   "protoc_path = " + "'" + protoc_path + "'" + "," +
  	   "projectPath = " + "'" + projectPath + "'" +")"
post  = "../src/proto/.git/hooks/post-merge"
File.open(post, "w") { |file| 
	includeFile = File.join(File::expand_path('./'),"ProtoHelper.rb").to_s
	file.puts "#!/usr/bin/env sh"
	file.puts "/usr/bin/env ruby <<-EORUBY"
	file.puts "#!/usr/bin/env ruby"
	file.puts "require " +  "'" + includeFile +"'"
	file.puts "ProtoHelper.Run" + args
	file.puts "EORUBY"
	}
FileUtils.chmod(0777, post)

# # main project post-merge
# post  = "../../.git/hooks/post-merge"
# File.open(post, "w") { |file| 
# 	file.puts "#!/usr/bin/env bash"
# 	file.puts "cd " + File::expand_path('../../Main/src/proto')
# 	file.puts "git pull"
# 	file.puts "cd -"
# 	}
# FileUtils.chmod(0777, post)

puts "config project"
# config project
ProtoHelper.Run()

puts("done!!!")

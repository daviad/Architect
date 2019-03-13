#!/usr/bin/python
# -*- coding: UTF-8 -*- 

import sys
import os

if len(sys.argv) < 2:
    print 'Useage: path/gen_module Test'
    exit(0)

ProjectName = 'Architect'
ModuleName = sys.argv[1]
ModuleName = ModuleName.capitalize()

if os.path.exists(ModuleName):
    print ModuleName + ' exists'
    exit(0)

output_dir = ModuleName + '/'
os.mkdir(output_dir)

UserName = os.popen('whoami').read().strip('\r\n')
Today = os.popen('date +%Y-%m-%d').read().strip('\r\n')
Year = os.popen('date +%Y').read().strip('\r\n')

def do_replace(tmp_path, target_path):
    f = open(tmp_path, 'r')
    content = f.read()
    f.close()
    content = content.replace('{ProjectName}', ProjectName)
    content = content.replace('{ModuleName}', ModuleName)
    content = content.replace('{UserName}', UserName)
    content = content.replace('{Today}', Today)
    content = content.replace('{Year}', Year)
    f = open(target_path, 'w')
    f.write(content)
    f.close()
do_replace('template/Module.swift', output_dir + ModuleName + 'Module.swift')

fo = open(output_dir + ModuleName + ".md", "w")
fo.write("# 该模块的相关说明\n")
fo.close()

os.mkdir(output_dir + 'Models')
os.mkdir(output_dir + 'Views')
os.mkdir(output_dir + 'Controllers')
os.mkdir(output_dir + 'ViewModels')
os.mkdir(output_dir + 'DAO')

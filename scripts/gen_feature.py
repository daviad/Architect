#!/usr/bin/python

import sys
import os

if len(sys.argv) < 2:
    print 'Useage: path/gen_feature Test'
    exit(0)

ProjectName = 'loocha'
FeatureName = sys.argv[1]
ClassName = FeatureName.capitalize() + 'Feature'

if os.path.exists(ClassName):
    print ClassName + ' exists'
    exit(0)

output_dir = ClassName + '/'
os.mkdir(output_dir)

UserName = os.popen('whoami').read().strip('\r\n')
Today = os.popen('date +%y-%m-%d').read().strip('\r\n')

def do_replace(tmp_path, target_path):
    f = open(tmp_path, 'r')
    content = f.read()
    f.close()
    content = content.replace('{ProjectName}', ProjectName)
    content = content.replace('{FeatureName}', FeatureName)
    content = content.replace('{ClassName}', ClassName)
    content = content.replace('{UserName}', UserName)
    content = content.replace('{Today}', Today)
    f = open(target_path, 'w')
    f.write(content)

do_replace('template/__Feature__.h', output_dir + ClassName + '.h')
do_replace('template/__Feature__.m', output_dir + ClassName + '.m')

os.mkdir(output_dir + 'Model')
os.mkdir(output_dir + 'View')
os.mkdir(output_dir + 'Controller')
os.mkdir(output_dir + 'ViewModel')

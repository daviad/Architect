#!/usr/bin/python

import sys
import re
import time
import subprocess
import shutil
import os

# usage: ./sprop_processor.py aaa ./a.properties ./out.zip

password = sys.argv[1]
src_path = sys.argv[2]
dst_path = sys.argv[3]
src_name = os.path.basename(src_path)

session_home = '/tmp/%f/' % time.time()
os.mkdir(session_home)

tmpfile_path = session_home + src_name
tmpfile_zip_path = tmpfile_path + '.zip'

fin = open(src_path)
fout = open(tmpfile_path, 'w')
lines = fin.readlines()
fin.close()

commentPattern = re.compile(r'^\s*#.*')
for line in lines:
	if not commentPattern.match(line):
		line = line.strip()
		sepIndex = line.find('=')
		if sepIndex < 0:
			continue
		key = line[0:sepIndex].strip()
		value = line[sepIndex + 1:].strip()
		line = key + '=' + value
		fout.write(line + '\n')
fout.close()

cwd = os.getcwd()
os.chdir(session_home)
command = ['zip']
command += ['-e', '-P' + password]
command += [src_name + '.zip', src_name]

print command

status = subprocess.call(command)

os.chdir(cwd)

if status != 0:
	print 'failed to compress file ' + tmpfile_path + ' to ' + dst_path
else:
	shutil.move(tmpfile_zip_path, dst_path)
#!/usr/bin/python

import sys
import os
import shutil

src_dir = sys.argv[1]
dst_dir = sys.argv[2]

def diff_cp_file(src_file, dst_file):
	mtime = os.stat(src_file).st_mtime
	if not os.path.exists(dst_file) or mtime != os.stat(dst_file).st_mtime:
		shutil.copyfile(src_file, dst_file)
		atime = os.stat(src_file).st_atime
		os.utime(dst_file, (atime, mtime))
	else:
		print "ignoring file (equal) : ", src_file

def diff_cp_folder(src_folder, dst_folder):
	print "copy ", src_folder, " to ", dst_folder

	if not os.path.exists(dst_folder):
		os.mkdir(dst_folder)

	items = os.listdir(src_folder)
	for i in items:
	    s_path = src_folder + '/' + i
	    d_path = dst_folder + '/' + i

	    if os.path.isdir(s_path):
	    	diff_cp_folder(s_path, d_path)
	    elif os.path.isfile(s_path):
	    	diff_cp_file(s_path, d_path)
	    else:
	    	print "unknown type file : ", s_path

diff_cp_folder(src_dir, dst_dir)

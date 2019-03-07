#!/usr/bin/python

import os
import sys
import shutil

def get_archs(file_path):
	info = os.popen("lipo -info " + file_path).read()
	return info[info.rfind(":") + 1 : -1].split()

def ar_each(file_path):
	file_name = os.path.basename(file_path)
	origin_cwd = os.getcwd()
	out_folder = origin_cwd + "/" + file_name + ".out"
	if os.path.exists(out_folder):
		shutil.rmtree(out_folder)
	os.mkdir(out_folder)

	archs = get_archs(file_path)

	if len(archs) == 1:
		arch = archs[0]
		arch_folder = out_folder + "/" + arch
		os.mkdir(arch_folder)
		os.chdir(arch_folder)
		os.system("ar -x " + file_path)
		os.chdir(origin_cwd)
	else:
		for i in range(0, len(archs)):
			arch = archs[i]
			arch_file = out_folder + "/" + file_name + "." + arch
			thin_arch_file = arch_file + ".thin"
			os.system("lipo -extract %s -output %s %s" % (arch, arch_file, file_path))
			os.system("lipo %s -thin %s -output %s" % (arch_file, arch, thin_arch_file))
			arch_folder = out_folder + "/" + arch
			os.mkdir(arch_folder)
			os.chdir(arch_folder)
			os.system("ar -x " + thin_arch_file)
			os.chdir(origin_cwd)

for i in range(1, len(sys.argv)):
	file_path = sys.argv[i]
	if not file_path.startswith("/"):
		file_path = os.getcwd() + "/" + file_path
	ar_each(file_path)


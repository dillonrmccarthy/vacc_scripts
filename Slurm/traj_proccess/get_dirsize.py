#!/usr/bin/python3
# Returns the size of any directory as defined by 'dir'

import os

def getdirsize(dir):
	size = subprocess.check_output(['du','-sh', cwd]).split()[0].decode('utf-8')
	return size

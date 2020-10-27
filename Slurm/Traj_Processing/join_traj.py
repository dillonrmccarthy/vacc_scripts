import os
from os import listdir, getcwd
import subprocess
import sys

class Dirinfo:
    def __init__(self,incms):
        incms = [incms]
        #incms = [f for f in listdir(getcwd()) if f[-7:] == '-in.cms']
        cont_folders = [ff for ff in listdir(getcwd()) if '_cont_' in ff]
        cont_vals = sorted([int((element.split("_")[-1])) for element in cont_folders])
        sorted_cf = [(incms[0][:-7]+'_cont_'+str(val)) for val in cont_vals]
        self._clickmes = [("./"+incms[0][:-7]+'_trj/clickme.dtr')]
        for path in sorted_cf:
            self._clickmes.append("./"+path+"/"+path+"_trj/clickme.dtr")
        self._dirpath = os.getcwd()+'/'

    def write_tcl_clickmes(self): #clickmes is a pre-processed tcl list which has the correct elements
        tcl_tmp = ['{']
        mid_tmp = ' '.join(map(str,self._clickmes))
        tcl_tmp.append(mid_tmp)
        tcl_tmp.append('}')
        tcl_list = ''.join(map(str,tcl_tmp))
        return tcl_list


test = Dirinfo('test-in.cms')
test2 = test.write_tcl_clickmes()
print(test2)

test._clickmes = 4

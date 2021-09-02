#!/usr/bin/env python
"""
Module Docstring
"""

import os, sys
from subprocess import Popen, PIPE

__author__ = "David Villasmil"
__version__ = "0.1.0"
__license__ = "MIT"

def exec_command(command):
    ## run it ##
    # p = subprocess.Popen(command, shell=True, stderr=subprocess.PIPE)
    # res = ''

    # ## But do not wait till netstat finish, start displaying output immediately ##
    # while True:
    #     out = p.stderr.read(1)
    #     if out == '' and p.poll() != None:
    #        break
    #     if out != '':
    #         print('char: {}'.format(out))
    #         #sys.stdout.write(out)
    #         #sys.stdout.flush()
    # print('resul: {}'.format(p.returncode))
    # return res
    process = Popen(command, stdout=PIPE, shell=True)
    print("Process: {}".format(process.pid))
    while True:
        line = process.stdout.readline().rstrip()
        print("line: {}".format(line))
        if not line:
            break
        yield line
    

def init():
    for line in exec_command('terraform init 2>&1'):
        print('RES: {}'.format(res))

def main():
    """ Main entry point of the app """
    init()


if __name__ == "__main__":
    """ This is executed when run from the command line """
    main()
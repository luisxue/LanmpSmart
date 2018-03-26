#!/usr/bin/python
# Author:  Luisxue <luisxue@gmail.com>
# BLOG:  https://luisxue.xcodn.com
#
# Notes: TreesShell for CentOS/RadHat 6+ Debian 7+ and Ubuntu 12+
#
# Project home page:
#       http://trees.org.cn
#       https://github.com/luisxue/TreesShell

import socket,sys
sk = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sk.settimeout(1)
try:
  sk.connect((sys.argv[1],int(sys.argv[2])))
  print 'ok'
except Exception:
  print 'no'
sk.close()

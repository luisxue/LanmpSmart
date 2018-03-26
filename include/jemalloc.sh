#!/bin/bash
# Author:  Luisxue <luisxue@gmail.com>
# BLOG:  https://luisxue.xcodn.com
#
# Notes: TreesShell for CentOS/RadHat 6+ Debian 7+ and Ubuntu 12+
#
# Project home page:
#       http://trees.org.cn
#       https://github.com/luisxue/TreesShell

Install_Jemalloc() {
  if [ ! -e "/usr/local/lib/libjemalloc.so" ]; then
    pushd ${oneinstack_dir}/src > /dev/null
    tar xjf jemalloc-$jemalloc_ver.tar.bz2
    pushd jemalloc-$jemalloc_ver
    LDFLAGS="${LDFLAGS} -lrt" ./configure
    make -j ${THREAD} && make install
    unset LDFLAGS
    popd
    if [ -f "/usr/local/lib/libjemalloc.so" ]; then
      if [ "${OS_BIT}" == '64' -a "$OS" == 'CentOS' ]; then
        ln -s /usr/local/lib/libjemalloc.so.2 /usr/lib64/libjemalloc.so.1
      else
        ln -s /usr/local/lib/libjemalloc.so.2 /usr/lib/libjemalloc.so.1
      fi
      echo '/usr/local/lib' > /etc/ld.so.conf.d/local.conf
      ldconfig
      echo "${CSUCCESS}jemalloc module installed successfully! ${CEND}"
      rm -rf jemalloc-${jemalloc_ver}
    else
      echo "${CFAILURE}jemalloc install failed, Please contact the author! ${CEND}"
      kill -9 $$
    fi
    popd
  fi
}

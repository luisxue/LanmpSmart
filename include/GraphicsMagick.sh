#!/bin/bash
# Author:  Luisxue <luisxue@gmail.com>
# BLOG:  https://luisxue.xcodn.com
#
# Notes: TreesShell for CentOS/RadHat 6+ Debian 7+ and Ubuntu 12+
#
# Project home page:
#       http://trees.org.cn
#       https://github.com/luisxue/TreesShell

Install_GraphicsMagick() {
  pushd ${oneinstack_dir}/src > /dev/null
  tar xzf GraphicsMagick-${graphicsmagick_ver}.tar.gz
  pushd GraphicsMagick-${graphicsmagick_ver}
  ./configure --prefix=/usr/local/graphicsmagick --enable-shared --enable-static
  make -j ${THREAD} && make install
  popd
  rm -rf GraphicsMagick-${graphicsmagick_ver}
  popd
}

Install_php-gmagick() {
  pushd ${oneinstack_dir}/src > /dev/null
  if [ -e "${php_install_dir}/bin/phpize" ]; then
    phpExtensionDir=`${php_install_dir}/bin/php-config --extension-dir`
    if [ "`${php_install_dir}/bin/php -r 'echo PHP_VERSION;' | awk -F. '{print $1}'`" == '7' ]; then
      tar xzf gmagick-${gmagick_for_php7_ver}.tgz 
      pushd gmagick-${gmagick_for_php7_ver} 
    else
      tar xzf gmagick-${gmagick_ver}.tgz
      pushd gmagick-${gmagick_ver}
    fi
    export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
    ${php_install_dir}/bin/phpize
    ./configure --with-php-config=${php_install_dir}/bin/php-config --with-gmagick=/usr/local/graphicsmagick
    make -j ${THREAD} && make install
    popd
    if [ -f "${phpExtensionDir}/gmagick.so" ]; then
      echo 'extension=gmagick.so' > ${php_install_dir}/etc/php.d/03-gmagick.ini
      echo "${CSUCCESS}PHP gmagick module installed successfully! ${CEND}"
      rm -rf gmagick-${gmagick_for_php7_ver} gmagick-${gmagick_ver}
    else
      echo "${CFAILURE}PHP gmagick module install failed, Please contact the author! ${CEND}"
    fi
  fi
  popd
}

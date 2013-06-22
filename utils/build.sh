NW_VERSION=v0.6.0
if [ $# == 0 ]; then
  echo 'usage: build.sh version'
  exit 1
fi
pushd `dirname $0`
cd ..
mkdir -p dist && \
cd dist || \
exit 1
for platform in osx-ia32 win-ia32 linux-ia32 linux-x64
do
  if [ -f shadowsocks-gui-$1-$platform.7z ]; then
    continue
  fi
  if [ ! -f node-webkit-$NW_VERSION-$platform.zip ] ; then
    if [ ! -f node-webkit-$NW_VERSION-$platform.tar.gz ] ; then
      axel https://s3.amazonaws.com/node-webkit/$NW_VERSION/node-webkit-$NW_VERSION-$platform.zip || \
      wget https://s3.amazonaws.com/node-webkit/$NW_VERSION/node-webkit-$NW_VERSION-$platform.zip || \
      axel https://s3.amazonaws.com/node-webkit/$NW_VERSION/node-webkit-$NW_VERSION-$platform.tar.gz || \
      wget https://s3.amazonaws.com/node-webkit/$NW_VERSION/node-webkit-$NW_VERSION-$platform.tar.gz || \
      exit 1
    fi
  fi
  mkdir shadowsocks-gui-$1-$platform && \
  pushd shadowsocks-gui-$1-$platform && \
  unzip ../node-webkit-$NW_VERSION-$platform.zip || \
  tar xf ../node-webkit-$NW_VERSION-$platform.tar.gz || \
  exit 1
  if [ -d node-webkit-$NW_VERSION-$platform ]; then
    mv node-webkit-$NW_VERSION-$platform/* ./ && \
    rm -r node-webkit-$NW_VERSION-$platform || \
    exit 1
  fi
  cp ../../*.js . && \
  cp ../../*.css . && \
  cp ../../*.json . && \
  cp ../../*.htm* . && \
  cp ../../*.png . && \
  cp -r ../../shadowsocks-nodejs . && \
  rm -r shadowsocks-nodejs/.git* && \
  popd && \
  tar zcf shadowsocks-gui-$1-$platform.tar.gz shadowsocks-gui-$1-$platform && \
  7z a -t7z shadowsocks-gui-$1-$platform.7z shadowsocks-gui-$1-$platform && \
  rm -r shadowsocks-gui-$1-$platform && \
  rsync --progress -e ssh shadowsocks-gui-$1-$platform.tar.gz frs.sourceforge.net:/home/frs/project/shadowsocksgui/dist/shadowsocks-gui-$1-$platform.tar.gz && \
  rsync --progress -e ssh shadowsocks-gui-$1-$platform.7z frs.sourceforge.net:/home/frs/project/shadowsocksgui/dist/shadowsocks-gui-$1-$platform.7z || \
  exit 1
done
popd

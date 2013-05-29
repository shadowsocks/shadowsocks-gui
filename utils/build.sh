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
  if [ -f shadowsocks-gui-$1-$platform.tar.gz ]; then
    continue
  fi
  if [ ! -f node-webkit-v0.5.1-$platform.zip ] ; then
    if [ ! -f node-webkit-v0.5.1-$platform.tar.gz ] ; then
      axel https://s3.amazonaws.com/node-webkit/v0.5.1/node-webkit-v0.5.1-$platform.zip || \
      wget https://s3.amazonaws.com/node-webkit/v0.5.1/node-webkit-v0.5.1-$platform.zip || \
      axel https://s3.amazonaws.com/node-webkit/v0.5.1/node-webkit-v0.5.1-$platform.tar.gz || \
      wget https://s3.amazonaws.com/node-webkit/v0.5.1/node-webkit-v0.5.1-$platform.tar.gz || \
      exit 1
    fi
  fi
  mkdir shadowsocks-gui-$1-$platform && \
  pushd shadowsocks-gui-$1-$platform && \
  unzip ../node-webkit-v0.5.1-$platform.zip || \
  tar xf ../node-webkit-v0.5.1-$platform.tar.gz || \
  exit 1
  if [ -d node-webkit-v0.5.1-$platform ]; then
    mv node-webkit-v0.5.1-$platform/* ./ && \
    rm -r node-webkit-v0.5.1-$platform || \
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
  rm -r shadowsocks-gui-$1-$platform && \
  rsync --progress -e ssh shadowsocks-gui-$1-$platform.tar.gz frs.sourceforge.net:/home/frs/project/shadowsocksgui/dist/shadowsocks-gui-$1-$platform.tar.gz || \
  exit 1
done
popd

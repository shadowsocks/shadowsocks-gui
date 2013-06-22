NW_VERSION=v0.6.0
if [ $# == 0 ]; then
  echo 'usage: build.sh version'
  exit 1
fi
pushd `dirname $0`
cd ..
mkdir -p dist && \
cd dist && \
mkdir app && \
pushd app && \
cp ../../*.js . && \
cp ../../*.css . && \
cp ../../*.json . && \
cp ../../*.htm* . && \
cp ../../*.png . && \
cp -r ../../shadowsocks-nodejs . && \
rm -r shadowsocks-nodejs/.git* && \
zip -r ../app.nw *
popd && \
rm -rf app || \
exit 1
for platform in osx-ia32 win-ia32
do
  if [ -f shadowsocks-gui-$1-$platform.7z ]; then
    continue
  fi
  if [ ! -f node-webkit-$NW_VERSION-$platform.zip ] ; then
    if [ ! -f node-webkit-$NW_VERSION-$platform.tar.gz ] ; then
      axel https://s3.amazonaws.com/node-webkit/$NW_VERSION/node-webkit-$NW_VERSION-$platform.zip || \
      curl https://s3.amazonaws.com/node-webkit/$NW_VERSION/node-webkit-$NW_VERSION-$platform.zip > node-webkit-$NW_VERSION-$platform.zip || \
      axel https://s3.amazonaws.com/node-webkit/$NW_VERSION/node-webkit-$NW_VERSION-$platform.tar.gz || \
      curl https://s3.amazonaws.com/node-webkit/$NW_VERSION/node-webkit-$NW_VERSION-$platform.tar.gz > node-webkit-$NW_VERSION-$platform.tar.gz || \
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
  if [ $platform == win-ia32 ]; then
      cat nw.exe ../app.nw > shadowsocks.exe
      rm nw.exe
  fi
  if [ $platform == osx-ia32 ]; then
      cp ../app.nw node-webkit.app/Contents/Resources/
      cp ../../utils/Info.plist node-webkit.app/Contents/
      cp ../../utils/*.icns node-webkit.app/Contents/Resources/
      /usr/libexec/PlistBuddy -c "Set CFBundleVersion $1" Info.plist 
      /usr/libexec/PlistBuddy -c "Set CFBundleShortVersionString $1" Info.plist 
      mv node-webkit.app shadowsocks.app
  fi
  popd
  # tar zcf shadowsocks-gui-$1-$platform.tar.gz shadowsocks-gui-$1-$platform && \
  # rm -r shadowsocks-gui-$1-$platform && \
  # rsync --progress -e ssh shadowsocks-gui-$1-$platform.tar.gz frs.sourceforge.net:/home/frs/project/shadowsocksgui/dist/shadowsocks-gui-$1-$platform.tar.gz || \
  # exit 1
done
popd

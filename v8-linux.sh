VERSION="8.1.307.31"

echo "Installing system dependencies"

apt-get install -y \
    pkg-config \
    git \
    subversion \
    curl \
    wget \
    build-essential \
    python \
    xz-utils \
    zip

git config --global user.name "V8 Linux Builder"
git config --global user.email "v8.linux.builder@localhost"
git config --global core.autocrlf false
git config --global core.filemode false
git config --global color.ui true


cd ~
echo "=====[ Getting Depot Tools ]====="	
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
export PATH=${`pwd`}/depot_tools:$PATH
gclient

mkdir v8
cd v8

echo "=====[ Fetching V8 ]====="	
fetch v8
echo "target_os = ['linux']" >> .gclient

cd /opt/v8/v8
echo "Installing V8 dependencies" # Linux only step
./build/install-build-deps.sh --no-syms --no-nacl --no-prompt
gclient sync

git checkout $VERSION
gclient sync


echo "=====[ Building V8 ]====="
python ./tools/dev/v8gen.py x64.release -vv -- '
target_os = "linux"
is_component_build = true
v8_enable_i18n_support = false
symbol_level = 1
'

ninja -C out.gn/x64.release -t clean
ninja -C out.gn/x64.release v8
cd ..

zip v8-linux.zip -r v8/out.gn/x64.release -i '*.so'
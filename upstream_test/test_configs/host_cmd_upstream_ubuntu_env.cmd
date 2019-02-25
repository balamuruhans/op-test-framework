# Install the required dependency packages

apt install -y bison flex openssl-dev pixman-dev libtool rpcgen  libnl3-dev libxml2-dev mingw64-portablexdr libtirpc-dev yajl-dev device-mapper-dev libpciaccess-dev audit-libs-dev augeas avahi-dev bash-completion cyrus-sasl-dev dbus-dev fuse-dev glusterfs-api-dev glusterfs-dev gnutls-dev libacl-dev libattr-dev libblkid-dev libcap-ng-dev libcurl-dev libpcap-dev librados2-dev librbd1-dev libssh-dev libssh2-dev libtasn1-dev libwsman-dev ncurses-dev netcf-dev numactl-dev parted-dev readline-dev sanlock-dev scrub systemtap-sdt-dev wireshark-dev jansson-dev libiscsi-dev python python-dev openvswitch
apt install -y qemu-kvm libvirt virtinst gcc git pip

# install required python packages for Avocado and Avocado-VT
pip install pip --upgrade
pip install setuptools --upgrade
pip install netifaces --upgrade
pip install aexpect --upgrade
pip install netaddr --upgrade

# create workspace for the test to run
mkdir -p /home/bala && cd /home/bala
rm -f ~/.config/avocado/avocado.conf
echo "[datadir.paths]" >> ~/.config/avocado/avocado.conf
echo "base_dir = /home/test/bala/avocado" >> ~/.config/avocado/avocado.conf
echo "test_dir = /home/test/bala/avocado/tests" >> ~/.config/avocado/avocado.conf
echo "data_dir = /home/test/bala/avocado/data" >> ~/.config/avocado/avocado.conf
echo "logs_dir = /home/test/bala/avocado/results" >> ~/.config/avocado/avocado.conf
echo "[sysinfo.collect]" >> ~/.config/avocado/avocado.conf
echo "enabled = True" >> ~/.config/avocado/avocado.conf
echo "profiler = True" >> ~/.config/avocado/avocado.conf
echo "per_test = True" >> ~/.config/avocado/avocado.conf
source ~/.config/avocado/avocado.conf

# clone/install  Avocado and Avocado-VT
git clone https://github.com/avocado-framework/avocado.git
cd avocado
make requirements
python setup.py install
cd ..
git clone https://github.com/avocado-framework/avocado-vt.git
cd avocado-vt
make requirements
python setup.py install
cd ..

# Bootstrap the framework and download the required guest image
avocado vt-bootstrap --vt-type libvirt --vt-guest-os "JeOS.27.ppc64le" --yes-to-all
avocado vt-bootstrap --vt-type qemu --yes-to-all --vt-no-downloads

# build upstream Qemu
wget https://raw.githubusercontent.com/balamuruhans/op-test-framework/upstream_test/upstream_test/build_configs/qemu_build.cfg -O ./qemu_build.cfg
avocado run --vt-config ./qemu_build.cfg --vt-extra-params qemu_binary=/usr/bin/qemu-system-ppc64

# build upstream Libvirt
wget https://raw.githubusercontent.com/balamuruhans/op-test-framework/upstream_test/upstream_test/build_configs/libvirt_build.cfg -O ./libvirt_build.cfg
avocado run --vt-config ./libvirt_build.cfg --vt-extra-params qemu_binary=/usr/bin/qemu-system-ppc64

# build upstream Linux for Guest
rm -rf linux
git clone https://github.com/torvalds/linux.git
cd linux
make ppc64le_guest_defconfig
make -j $(cat /proc/cpuinfo | grep -c "cpu")
cd ..

# Set selinux to permit Libvirt and Qemu to run from new upstream build
setenforce 0

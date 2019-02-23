# Install the required dependency packages

yum install -y bison flex openssl-devel pixman-devel libtool rpcgen  libnl3-devel libxml2-devel mingw64-portablexdr libtirpc-devel yajl-devel device-mapper-devel libpciaccess-devel rpm-build audit-libs-devel augeas avahi-devel bash-completion cyrus-sasl-devel dbus-devel fuse-devel glusterfs-api-devel glusterfs-devel gnutls-devel libacl-devel libattr-devel libblkid-devel libcap-ng-devel libcurl-devel libpcap-devel librados2-devel librbd1-devel libssh-devel libssh2-devel libtasn1-devel libwsman-devel ncurses-devel netcf-devel numactl-devel parted-devel readline-devel sanlock-devel scrub systemtap-sdt-devel wireshark-devel jansson-devel libiscsi-devel python python-devel openvswitch
yum install -y qemu-system-ppc libvirt virt-install gcc redhat-rpm-config python2 python2-devel python2-pip
yum install -y "@Development Tools"

# softlink python2 and pip2 to python and pip
ln -s /usr/bin/python2 /usr/bin/python
ln -s /usr/bin/pip2 /usr/bin/pip

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

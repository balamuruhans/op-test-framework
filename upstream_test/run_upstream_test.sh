# !/usr/bin/sh

mkdir -p /var/tmp/upstream_test
cd /var/tmp/upstream_test
git clone https://github.com/open-power/op-test-framework.git
cd ./op-test-framework

rm -f machine_host.conf

# install upstream kernel in the host
wget "https://raw.githubusercontent.com/balamuruhans/op-test-framework/upstream_test/upstream_test/machine_configs/$1" -O machine_host.conf
./op-test -c machine_host.conf --run testcases.InstallUpstreamKernel.InstallUpstreamKernel

# install required packages, build libirt, qemu in host, build kernel for guest
wget "https://raw.githubusercontent.com/balamuruhans/op-test-framework/upstream_test/upstream_test/test_configs/host_cmd_upstream_env.cmd" -O env.cmd
./op-test -c machine_test.conf --run testcases.RunHostTest.RunHostTest --host-cmd-file env.cmd

# run localhost migration test with upstream libvirt qemu and kernel
wget "https://raw.githubusercontent.com/balamuruhans/op-test-framework/upstream_test/upstream_test/test_configs/host_cmd_upstream_localhost_migration.cmd" -O migration.cmd
./op-test -c machine_test.conf --run testcases.RunHostTest.RunHostTest --host-cmd-file migration.cmd

wget "https://raw.githubusercontent.com/balamuruhans/op-test-framework/upstream_test/upstream_test/test_configs/host_cmd_upstream_lifecycle.cmd" -O lifecycle.cmd
./op-test -c machine_test.conf --run testcases.RunHostTest.RunHostTest --host-cmd-file lifecycle.cmd

wget "https://raw.githubusercontent.com/balamuruhans/op-test-framework/upstream_test/upstream_test/test_configs/host_cmd_upstream_lifecycle.cmd" -O lifecycle.cmd
./op-test -c machine_test.conf --run testcases.RunHostTest.RunHostTest --host-cmd-file lifecycle.cmd

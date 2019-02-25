# !/usr/bin/sh

rm -f $1.conf

# install required packages, build libirt, qemu in host, build kernel for guest
# wget "https://raw.githubusercontent.com/balamuruhans/op-test-framework/upstream_test/upstream_test/test_configs/host_cmd_upstream_env.cmd" -O env.cmd
if $2 == "Ubuntu"; then
    /tmp/upstream/op-test-framework/op-test -c /tmp/upstream/op-test-framework/upstream_test/machine_configs/$1.conf --run testcases.RunHostTest.RunHostTest --host-cmd-file /tmp/upstream/op-test-framework/upstream_test/test_configs/host_cmd_upstream_ubuntu_env.cmd;
else
    /tmp/upstream/op-test-framework/op-test -c /tmp/upstream/op-test-framework/upstream_test/machine_configs/$1.conf --run testcases.RunHostTest.RunHostTest --host-cmd-file /tmp/upstream/op-test-framework/upstream_test/test_configs/host_cmd_upstream_env.cmd;
fi


# install upstream kernel in the host
# wget "https://raw.githubusercontent.com/balamuruhans/op-test-framework/upstream_test/upstream_test/machine_configs/$1.conf" -O machine_host.conf
/tmp/upstream/op-test-framework/op-test -c /tmp/upstream/op-test-framework/upstream_test/machine_configs/$1.conf --run testcases.InstallUpstreamKernel.InstallUpstreamKernel

# run localhost migration test with upstream libvirt qemu and kernel
#wget "https://raw.githubusercontent.com/balamuruhans/op-test-framework/upstream_test/upstream_test/test_configs/host_cmd_upstream_localhost_migration.cmd" -O migration.cmd
/tmp/upstream/op-test-framework/op-test -c /tmp/upstream/op-test-framework/upstream_test/machine_configs/$1.conf --run testcases.RunHostTest.RunHostTest --host-cmd-file /tmp/upstream/op-test-framework/upstream_test/test_configs/host_cmd_upstream_localhost_migration.cmd

#wget "https://raw.githubusercontent.com/balamuruhans/op-test-framework/upstream_test/upstream_test/test_configs/host_cmd_upstream_lifecycle.cmd" -O lifecycle.cmd
/tmp/upstream/op-test-framework/op-test -c /tmp/upstream/op-test-framework/upstream_test/machine_configs/$1.conf --run testcases.RunHostTest.RunHostTest --host-cmd-file /tmp/upstream/op-test-framework/upstream_test/test_configs/host_cmd_upstream_lifecycle.cmd

#wget "https://raw.githubusercontent.com/balamuruhans/op-test-framework/upstream_test/upstream_test/test_configs/host_cmd_upstream_lifecycle.cmd" -O lifecycle.cmd
/tmp/upstream/op-test-framework/op-test -c /tmp/upstream/op-test-framework/upstream_test/machine_configs/$1.conf --run testcases.RunHostTest.RunHostTest --host-cmd-file /tmp/upstream/op-test-framework/upstream_test/test_configs/host_cmd_upstream_lifecycle.cmd

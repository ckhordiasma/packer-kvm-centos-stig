source "qemu" "example" {
  iso_url          = "https://mirrors.ocf.berkeley.edu/centos-stream/9-stream/BaseOS/x86_64/iso/CentOS-Stream-9-20220216.1-x86_64-dvd1.iso"
  iso_checksum     = "609512d104e3fd8926a3d7faf78c1217b120ee4b93a49ce30ff2e0114b73fae5"
  output_directory = "output_centos"
  vm_name          = "centos_vm_test"

  disk_size = "30000M"
  memory    = 4096
  cpus = 2
  qemuargs = [["-cpu","host"]]
  ssh_username = "centos"
  ssh_password = "123Cen70$cen123"

  # if running qemu on a headless server, qemu will fail unless this is specified. 
  headless = "true"

  # this is helpful for being able to VNC into the packer'd VM if on headless server
  vnc_bind_address = "0.0.0.0"


  format      = "qcow2"
  accelerator = "kvm"


  ssh_timeout            = "30m"
  ssh_handshake_attempts = "20"

  net_device       = "virtio-net"
  disk_interface   = "virtio"
  boot_wait        = "3s"
  shutdown_command = "echo '123Cen70$cen123' | sudo -S shutdown -P now"

  # Boot:
  #  0. gets into text mode interface
  #  1. normal boot options
  #  2. autoinstall options
  #  3. initiates boot sequence
  boot_command = [
    "<tab>",
    "  ",
    "inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg",
    "<wait5><enter>"
  ]


  # instead of specifying an http_directory, files are created on the fly using the http_content block.
  http_content = {
    "/ks.cfg" = <<EOF
# Generated by Anaconda 34.25.0.26
# Generated by pykickstart v3.32
#version=RHEL9
# Use graphical install
graphical
network --bootproto=dhcp

repo --name="AppStream" --baseurl=file:///run/install/sources/mount-0000-cdrom/AppStream
reboot --eject
%addon com_redhat_kdump --disable

%end

%addon com_redhat_oscap
    content-type = scap-security-guide
    datastream-id = scap_org.open-scap_datastream_from_xccdf_ssg-rhel9-xccdf-1.2.xml
    xccdf-id = scap_org.open-scap_cref_ssg-rhel9-xccdf-1.2.xml
    profile = xccdf_org.ssgproject.content_profile_stig
%end

# Keyboard layouts
keyboard --xlayouts='us'
# System language
lang en_US.UTF-8

# Use CDROM installation media
cdrom

%packages
@^server-product-environment
aide
audit
fapolicyd
firewalld
opensc
openscap
openscap-scanner
openssh-server
openssl-pkcs11
policycoreutils
rng-tools
rsyslog
rsyslog-gnutls
scap-security-guide
tmux
usbguard
-iprutils
-krb5-workstation
-rsh-server
-sendmail
-telnet-server
-tftp-server
-tuned
-vsftpd
-xorg-x11-server-Xorg
-xorg-x11-server-Xwayland
-xorg-x11-server-common
-xorg-x11-server-utils

%end

# Run the Setup Agent on first boot
firstboot --enable

# Generated using Blivet version 3.4.0
ignoredisk --only-use=vda
# Partition clearing information
clearpart --none --initlabel
# Disk partitioning information
part /boot --fstype="xfs" --ondisk=vda --size=1024
part /var --fstype="xfs" --ondisk=vda --size=1024
part /boot/efi --fstype="efi" --ondisk=vda --size=550 --fsoptions="umask=0077,shortname=winnt"
part /var/tmp --fstype="xfs" --ondisk=vda --size=1024
part /var/log --fstype="xfs" --ondisk=vda --size=2048
part /tmp --fstype="xfs" --ondisk=vda --size=1024
part swap --fstype="swap" --ondisk=vda --size=4096
part / --fstype="xfs" --ondisk=vda --size=10240
part /var/log/audit --fstype="xfs" --ondisk=vda --size=100
part /home --fstype="xfs" --ondisk=vda --size=5120

# System timezone
timezone America/New_York --utc

# Root password
rootpw --iscrypted $6$2bio5bLKoI85RWbx$SFLMpa4nc6hUP7H/krVrWoohgthCoG.jJK9wE1kZPQ5K0pm024xYvdUizPGicWEisNC4Gm5H9sUCK/x6/JDOO.
user --groups=wheel --name=centos --password=$6$2bio5bLKoI85RWbx$SFLMpa4nc6hUP7H/krVrWoohgthCoG.jJK9wE1kZPQ5K0pm024xYvdUizPGicWEisNC4Gm5H9sUCK/x6/JDOO. --iscrypted --gecos="CentOS User"

%post
# immediately change password to get around STIG insta-password-expire thing
usermod -p '$6$gRTs8o2AhcL73ZnJ$VPJB17l1r4eJZMHC45pZT8X/WHC0.iV2La0Qj7Fapu16nIiiLhtEqLyT4eN9MdHjjPVOrEeP28bMMyaw/B1wz0' centos
%end

EOF

  }
}

build {
  sources = ["source.qemu.example"]
}

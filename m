Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58334 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752317AbdF3NYC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 30 Jun 2017 09:24:02 -0400
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Abbas Naderi <abiusx@google.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@redhat.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH v3 00/14] NFS: add AF_VSOCK support
Date: Fri, 30 Jun 2017 14:23:38 +0100
Message-Id: <20170630132352.32133-1-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v3:
 * Now with nfsd support so the full stack can be tested

This patch series enables AF_VSOCK address family support in the NFS client and
nfsd.  You can also get the code here:
https://github.com/stefanha/linux/tree/vsock-nfsd

Please also see the nfs-utils patch series I have just sent to
linux-nfs@vger.kernel.org for the necessary patches.  You can get the code
here:
https://github.com/stefanha/nfs-utils/tree/vsock-nfsd

The AF_VSOCK address family provides socket communication between virtual
machines and hypervisors.  VMware VMCI and virtio (for KVM) transports are
available in Linux, see net/vmw_vsock/.

The goal of this work is sharing files between virtual machines and
hypervisors.  AF_VSOCK is well-suited to this because it requires no
configuration inside the virtual machine, making it simple to manage and
reliable.

Why NFS over AF_VSOCK?
----------------------
It is unusual to add a new NFS transport, only TCP, RDMA, and UDP are currently
supported.  Here is the rationale for adding AF_VSOCK.

Sharing files with a virtual machine can be configured manually:
1. Add a dedicated network card to the virtual machine.  It will be used for
   NFS traffic.
2. Configure a local subnet and assign IP addresses to the virtual machine and
   hypervisor
3. Configure an NFS export on the hypervisor and start the NFS server
4. Mount the export inside the virtual machine

Automating these steps poses a problem: modifying network configuration inside
the virtual machine is invasive.  It's hard to add a network interface to an
arbitrary running system in an automated fashion, considering the diversity in
network management tools, firewall rules, IP address usage, etc.

Furthermore, the user may disrupt file sharing by accident when they add
firewall rules, restart networking, etc because the NFS network interface is
prone to interference alongside the network interfaces managed by the user.

AF_VSOCK is a zero-configuration network transport that avoids these problems.
Adding it to a virtual machine is non-invasive.  It also avoids accidental
misconfiguration by the user.  This is why "guest agents" and other services in
various hypervisors (KVM, Xen, VMware, VirtualBox) do not use regular network
interfaces.

Instead of implementing a paravirtualized filesystem it makes more sense to use
NFS, which is mature and well-understood.  This is why this patch series adds
AF_VSOCK support to NFS.

The approach in this series
---------------------------
AF_VSOCK stream sockets can be used for NFSv4.1 much in the same way as TCP.
RFC 1831 record fragments divide messages since SOCK_STREAM semantics are
present.  The backchannel shares the connection just like the default TCP
configuration.

Addresses are <Context ID, Port Number> pairs.  These patches use "vsock:<cid>"
string representation to distinguish AF_VSOCK addresses from IPv4 and IPv6
numeric addresses.

The following nfsd /proc changes are needed:

 * /proc/net/rpc/auth.unix.ip - new 'vsock:CID' syntax
 * /proc/fs/nfsd/portlist - new 'vsock' transport and
                            accept AF_VSOCK socket fds

Quickstart
----------
1. Build these patches or clone from git:
   https://github.com/stefanha/linux/tree/vsock-nfsd

   Config options:
   CONFIG_VSOCKETS=m
   CONFIG_VIRTIO_VSOCKETS=m
   CONFIG_VIRTIO_VSOCKETS_COMMON=m
   CONFIG_SUNRPC_XPRT_VSOCK=y
   CONFIG_VHOST_VSOCK=m

   Install this kernel on the host and inside the guest.

2. Build nfs-utils from git:
   https://github.com/stefanha/nfs-utils/tree/vsock-nfsd

   Install nfs-utils on the host and inside the guest.

3. Define a vsock export on the host:

   (host)# cat /etc/exports
   /export	vsock:*(rw,no_root_squash,insecure,subtree_check)

4. Ensure the host has AF_VSOCK set up

   (host)# modprobe vhost_vsock

5. Start nfsd

   (host)# systemctl start var-lib-nfs-rpc_pipefs.mount
   (host)# systemctl start proc-fs-nfsd.mount
   (host)# systemctl start rpcbind.socket rpcbind.service
   (host)# rpc.mountd
   (host)# exportfs -r
   (host)# rpc.nfsd -N3 -V4.1 --vsock 2049

6. Launch the guest

   (host)# qemu-system-x86_64 -M accel=kvm -m 1G \
             -device vhost-vsock-pci,id=vhost-vsock-pci0,guest-cid=3 \
             ...

   (Check whether your qemu-system-x86_64 binary supports vsock using
   "qemu-system-x86_64 -device \? 2>&1 | grep vsock".  If not, build
   QEMU from git://git.qemu-project.org/qemu.git master.)

7. Mount the export from the guest

   The following example mounts /export from the hypervisor (CID 2)
   inside the virtual machine (CID 3):

   (guest)# mount.nfs 2:/export /mnt -o clientaddr=3,proto=vsock

Status
------
Tested with basic NFSv4.1 file I/O.  Advanced NFS features may require
additional changes.

Please let me know your comments or questions.

Thanks,
Stefan

Stefan Hajnoczi (14):
  SUNRPC: add AF_VSOCK support to addr.[ch]
  SUNRPC: rename "TCP" record parser to "stream" parser
  SUNRPC: abstract tcp_read_sock() in record fragment parser
  SUNRPC: extract xs_stream_reset_state()
  VSOCK: add tcp_read_sock()-like vsock_read_sock() function
  SUNRPC: add AF_VSOCK support to xprtsock.c
  SUNRPC: drop unnecessary svc_bc_tcp_create() helper
  SUNRPC: add AF_VSOCK support to svc_xprt.c
  SUNRPC: add AF_VSOCK backchannel support
  NFS: add AF_VSOCK support to NFS client
  nfsd: support vsock xprt creation
  SUNRPC: add AF_VSOCK lock class
  SUNRPC: vsock svcsock support
  SUNRPC: add AF_VSOCK support to auth.unix.ip

 include/linux/sunrpc/addr.h             |  44 ++
 include/linux/sunrpc/svc_xprt.h         |  12 +
 include/linux/sunrpc/xprt.h             |   1 +
 include/linux/sunrpc/xprtsock.h         |  36 +-
 include/linux/virtio_vsock.h            |   4 +
 include/net/af_vsock.h                  |   5 +
 include/trace/events/sunrpc.h           |  26 +-
 drivers/vhost/vsock.c                   |   1 +
 fs/nfs/client.c                         |   2 +
 fs/nfs/super.c                          |  11 +-
 fs/nfsd/nfsctl.c                        |  23 +-
 net/sunrpc/addr.c                       |  57 +++
 net/sunrpc/svc_xprt.c                   |  18 +
 net/sunrpc/svcauth_unix.c               | 146 +++++--
 net/sunrpc/svcsock.c                    | 271 ++++++++++--
 net/sunrpc/xprtsock.c                   | 701 +++++++++++++++++++++++++-------
 net/vmw_vsock/af_vsock.c                |  16 +
 net/vmw_vsock/virtio_transport.c        |   1 +
 net/vmw_vsock/virtio_transport_common.c |  66 +++
 net/vmw_vsock/vmci_transport.c          |   8 +
 net/sunrpc/Kconfig                      |  10 +
 21 files changed, 1206 insertions(+), 253 deletions(-)

-- 
2.9.4


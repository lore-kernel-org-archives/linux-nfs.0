Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40348 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751672AbbFDQp4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Jun 2015 12:45:56 -0400
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        asias.hejun@gmail.com, netdev@vger.kernel.org,
        Daniel Berrange <berrange@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        Stefan Hajnoczi <stefanha@redhat.com>
Subject: [RFC 00/10] NFS: add AF_VSOCK support to NFS client
Date: Thu,  4 Jun 2015 17:45:43 +0100
Message-Id: <1433436353-6761-1-git-send-email-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch series enables AF_VSOCK address family support in the NFS client.
Please use the https://github.com/stefanha/linux.git vsock-nfs branch, which
contains the dependencies for this series.

The AF_VSOCK address family provides dgram and stream socket communication
between virtual machines and hypervisors.  A VMware VMCI transport is currently
available in-tree (see net/vmw_vsock) and I have posted virtio-vsock patches
for use with QEMU/KVM: http://thread.gmane.org/gmane.linux.network/365205

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
arbitrary running system in an automated fashion, considering the network
management tools, firewall rules, IP address usage, etc.

Furthermore, the user may disrupt file sharing by accident when they add
firewall rules, restart networking, etc because the NFS network interface is
visible alongside the network interfaces managed by the user.

AF_VSOCK is a zero-configuration network transport that avoids these problems.
Adding it to a virtual machine is non-invasive.  It also avoids accidental
misconfiguration by the user.  This is why "guest agents" and other services in
various hypervisors (KVM, Xen, VMware, VirtualBox) do not use regular network
interfaces.

This is why AF_VSOCK is appropriate for providing shared files as a hypervisor
service.

The approach in this series
---------------------------
AF_VSOCK stream sockets can be used for NFSv4.1 much in the same way as TCP.
RFC 1831 record fragments divide messages since SOCK_STREAM semantics are
present.  The backchannel shares the connection just like the default TCP
configuration.

Addresses are <Context ID, Port Number> pairs.  These patches use "vsock:<cid>"
string representation to distinguish AF_VSOCK addresses from IPv4 and IPv6
numeric addresses.

The patches cover the following areas:

Patch 1 - support struct sockaddr_vm in sunrpc addr.h

Patch 2-4 - make sunrpc TCP record fragment parser reusable for any stream
            socket

Patch 5 - add tcp_read_sock()-like interface to AF_VSOCK sockets

Patch 6 - extend sunrpc xprtsock.c for AF_VSOCK RPC clients

Patch 7-9 - AF_VSOCK backchannel support

Patch 10 - add AF_VSOCK support to NFS client

The following example mounts /export from the hypervisor (CID 2) inside the
virtual machine (CID 3):

  # /sbin/mount.nfs 2:/export /mnt -o clientaddr=3,proto=vsock

Status
------
I am looking for feedback on this approach.  There are TODOs remaining in the code.

Hopefully the way I add AF_VSOCK support to sunrpc is reasonable and something
that can be standardized (a netid assigned and the uaddr string format decided).

See below for the nfs-utils patch.  It can be made nice once glibc
getnameinfo()/getaddrinfo() support AF_VSOCK.

The vsock_read_sock() implementation is dumb.  Less of a NFS/SUNRPC issue and
more of a vsock issue, but perhaps virtio_transport.c should use skbs for its
receive queue instead of a custom packet struct.  That would eliminate memory
allocation and copying in vsock_read_sock().

The next step is tackling NFS server.  In the meantime, I have tested the
patches using the nc-vsock netcat-like utility that is available in my Linux
kernel repo below.

Repositories
------------
 * Linux kernel: https://github.com/stefanha/linux.git vsock-nfs
 * QEMU virtio-vsock device: https://github.com/stefanha/qemu.git vsock
 * nfs-utils vsock: https://github.com/stefanha/nfs-utils.git vsock

Stefan Hajnoczi (10):
  SUNRPC: add AF_VSOCK support to addr.h
  SUNRPC: rename "TCP" record parser to "stream" parser
  SUNRPC: abstract tcp_read_sock() in record fragment parser
  SUNRPC: extract xs_stream_reset_state()
  VSOCK: add tcp_read_sock()-like vsock_read_sock() function
  SUNRPC: add AF_VSOCK support to xprtsock.c
  SUNRPC: restrict backchannel svc IPPROTO_TCP check to IP
  SUNRPC: add vsock-bc backchannel
  SUNRPC: add AF_VSOCK support to svc_xprt.c
  NFS: add AF_VSOCK support to NFS client

 drivers/vhost/vsock.c                   |   1 +
 fs/nfs/callback.c                       |   7 +-
 fs/nfs/client.c                         |  16 +
 fs/nfs/super.c                          |  10 +
 include/linux/sunrpc/addr.h             |   6 +
 include/linux/sunrpc/svc_xprt.h         |  12 +
 include/linux/sunrpc/xprt.h             |   1 +
 include/linux/sunrpc/xprtsock.h         |  37 +-
 include/linux/virtio_vsock.h            |   4 +
 include/net/af_vsock.h                  |   5 +
 include/trace/events/sunrpc.h           |  30 +-
 net/sunrpc/addr.c                       |  57 +++
 net/sunrpc/svc.c                        |  13 +-
 net/sunrpc/svc_xprt.c                   |  13 +
 net/sunrpc/svcsock.c                    |  48 ++-
 net/sunrpc/xprtsock.c                   | 693 +++++++++++++++++++++++++-------
 net/vmw_vsock/af_vsock.c                |  15 +
 net/vmw_vsock/virtio_transport.c        |   1 +
 net/vmw_vsock/virtio_transport_common.c |  55 +++
 net/vmw_vsock/vmci_transport.c          |   8 +
 20 files changed, 825 insertions(+), 207 deletions(-)

-- 
2.4.2


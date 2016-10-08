Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34914 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933053AbcJHAmT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Oct 2016 20:42:19 -0400
Received: by mail-pf0-f193.google.com with SMTP id t25so3586761pfg.2
        for <linux-nfs@vger.kernel.org>; Fri, 07 Oct 2016 17:42:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1475834514-4058-1-git-send-email-stefanha@redhat.com>
References: <1475834514-4058-1-git-send-email-stefanha@redhat.com>
From: Cedric Blancher <cedric.blancher@gmail.com>
Date: Sat, 8 Oct 2016 02:42:17 +0200
Message-ID: <CALXu0UdS_m6ag7VDdbc-aJWH+fK=42GM0FEWH1Ht9M-9xy9Xjw@mail.gmail.com>
Subject: Re: [PATCH v2 00/10] NFS: add AF_VSOCK support to NFS client
To: Stefan Hajnoczi <stefanha@redhat.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

So basically you're creating a new (Red Hat) Linux-only wormhole which
bypasses all network security between VM host and guest and needs
extra work&thought&tool support (wireshark, valgrind, ...) to handle,
trace, debug, monitor and secure?

Ced

On 7 October 2016 at 12:01, Stefan Hajnoczi <stefanha@redhat.com> wrote:
> This patch series enables AF_VSOCK address family support in the NFS client.
> You can also get the commits from the vsock-nfs branch at
> https://github.com/stefanha/linux.git.
>
> The AF_VSOCK address family provides dgram and stream socket communication
> between virtual machines and hypervisors.  VMware VMCI and virtio (for KVM)
> transports are available, see net/vmw_vsock.
>
> The goal of this work is sharing files between virtual machines and
> hypervisors.  AF_VSOCK is well-suited to this because it requires no
> configuration inside the virtual machine, making it simple to manage and
> reliable.
>
> Why NFS over AF_VSOCK?
> ----------------------
> It is unusual to add a new NFS transport, only TCP, RDMA, and UDP are currently
> supported.  Here is the rationale for adding AF_VSOCK.
>
> Sharing files with a virtual machine can be configured manually:
> 1. Add a dedicated network card to the virtual machine.  It will be used for
>    NFS traffic.
> 2. Configure a local subnet and assign IP addresses to the virtual machine and
>    hypervisor
> 3. Configure an NFS export on the hypervisor and start the NFS server
> 4. Mount the export inside the virtual machine
>
> Automating these steps poses a problem: modifying network configuration inside
> the virtual machine is invasive.  It's hard to add a network interface to an
> arbitrary running system in an automated fashion, considering the network
> management tools, firewall rules, IP address usage, etc.
>
> Furthermore, the user may disrupt file sharing by accident when they add
> firewall rules, restart networking, etc because the NFS network interface is
> visible alongside the network interfaces managed by the user.
>
> AF_VSOCK is a zero-configuration network transport that avoids these problems.
> Adding it to a virtual machine is non-invasive.  It also avoids accidental
> misconfiguration by the user.  This is why "guest agents" and other services in
> various hypervisors (KVM, Xen, VMware, VirtualBox) do not use regular network
> interfaces.
>
> This is why AF_VSOCK is appropriate for providing shared files as a hypervisor
> service.
>
> The approach in this series
> ---------------------------
> AF_VSOCK stream sockets can be used for NFSv4.1 much in the same way as TCP.
> RFC 1831 record fragments divide messages since SOCK_STREAM semantics are
> present.  The backchannel shares the connection just like the default TCP
> configuration.
>
> Addresses are <Context ID, Port Number> pairs.  These patches use "vsock:<cid>"
> string representation to distinguish AF_VSOCK addresses from IPv4 and IPv6
> numeric addresses.
>
> The following example mounts /export from the hypervisor (CID 2) inside the
> virtual machine (CID 3):
>
>   # /sbin/mount.nfs 2:/export /mnt -o clientaddr=3,proto=vsock
>
> Please see the nfs-utils patch series I have just sent to
> linux-nfs@vger.kernel.org for the necessary patches.
>
> Status
> ------
> The virtio-vsock transport was merged in Linux 4.8 and the vhost-vsock-pci
> device is available in QEMU git master.  This means the underlying AF_VSOCK
> transport for KVM is now available upstream.
>
> I have begun work on nfsd support in the kernel and nfs-utils.  This is not
> complete yet and will be sent as separate patch series.
>
> Stefan Hajnoczi (10):
>   SUNRPC: add AF_VSOCK support to addr.[ch]
>   SUNRPC: rename "TCP" record parser to "stream" parser
>   SUNRPC: abstract tcp_read_sock() in record fragment parser
>   SUNRPC: extract xs_stream_reset_state()
>   VSOCK: add tcp_read_sock()-like vsock_read_sock() function
>   SUNRPC: add AF_VSOCK support to xprtsock.c
>   SUNRPC: drop unnecessary svc_bc_tcp_create() helper
>   SUNRPC: add AF_VSOCK support to svc_xprt.c
>   SUNRPC: add AF_VSOCK backchannel support
>   NFS: add AF_VSOCK support to NFS client
>
>  drivers/vhost/vsock.c                   |   1 +
>  fs/nfs/client.c                         |   2 +
>  fs/nfs/super.c                          |  11 +-
>  include/linux/sunrpc/addr.h             |  44 ++
>  include/linux/sunrpc/svc_xprt.h         |  12 +
>  include/linux/sunrpc/xprt.h             |   1 +
>  include/linux/sunrpc/xprtsock.h         |  36 +-
>  include/linux/virtio_vsock.h            |   4 +
>  include/net/af_vsock.h                  |   5 +
>  include/trace/events/sunrpc.h           |  28 +-
>  net/sunrpc/Kconfig                      |  10 +
>  net/sunrpc/addr.c                       |  57 +++
>  net/sunrpc/svc_xprt.c                   |  18 +
>  net/sunrpc/svcsock.c                    |  48 ++-
>  net/sunrpc/xprtsock.c                   | 703 +++++++++++++++++++++++++-------
>  net/vmw_vsock/af_vsock.c                |  16 +
>  net/vmw_vsock/virtio_transport.c        |   1 +
>  net/vmw_vsock/virtio_transport_common.c |  66 +++
>  net/vmw_vsock/vmci_transport.c          |   8 +
>  19 files changed, 880 insertions(+), 191 deletions(-)
>
> --
> 2.7.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Cedric Blancher <cedric.blancher@gmail.com>
[https://plus.google.com/u/0/+CedricBlancher/]
Institute Pasteur

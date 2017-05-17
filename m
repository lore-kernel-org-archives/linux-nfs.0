Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f172.google.com ([209.85.216.172]:34733 "EHLO
        mail-qt0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754472AbdEQQve (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 17 May 2017 12:51:34 -0400
Received: by mail-qt0-f172.google.com with SMTP id c13so14421318qtc.1
        for <linux-nfs@vger.kernel.org>; Wed, 17 May 2017 09:51:34 -0700 (PDT)
Message-ID: <1495039891.2930.8.camel@redhat.com>
Subject: Re: [PATCH 0/4] nfs-utils mount: add AF_VSOCK support
From: Jeff Layton <jlayton@redhat.com>
To: Stefan Hajnoczi <stefanha@redhat.com>, linux-nfs@vger.kernel.org
Date: Wed, 17 May 2017 12:51:31 -0400
In-Reply-To: <1475834503-3984-1-git-send-email-stefanha@redhat.com>
References: <1475834503-3984-1-git-send-email-stefanha@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2016-10-07 at 11:01 +0100, Stefan Hajnoczi wrote:
> The AF_VSOCK address family allows virtual machines to communicate with the
> hypervisor using a zero-configuration transport.  Both KVM and VMware
> hypervisors support AF_VSOCK and it was introduced in Linux 3.9.
> 
> This patch series adds AF_VSOCK support to mount.nfs(8) and works together with
> the kernel NFS client patches that I am also posting to
> linux-nfs@vger.kernel.org.
> 
> NFS over AF_VSOCK is useful for file system sharing between a virtual machine
> and the host.  Due to the zero-configuration nature of AF_VSOCK this is more
> transparent to the user and more robust than asking the user to set up NFS over
> TCP/IP.
> 
> A file system from the host (hypervisor) can be mounted inside a virtual
> machine over AF_VSOCK like this:
> 
>   (guest)# mount.nfs 2:/export /mnt -v -o clientaddr=3,proto=vsock
> 
> The VM's cid (address) is 3 and the hypervisor is 2.
> 

Sorry for the long delay, and I may just not have been keeping up. I'd
like to start taking a look at these patches, but I'm having a hard time
finding much information about how one would use AF_VSOCK in practice.
I'd like to understand the general idea a little more before I go
reviewing code...

If 2 is always the HV's address, then is that documented somewhere?

How are guest addresses determined? Can different guests talk to each
other over vsock?

Are there plans to eventually add some sort of name resolution? (It
might be interesting to put together a NSS module that keeps a list of
running guest hostnames and their vsock addresses).


> For testing it's easiest to tunnel AF_VSOCK to the AF_INET nfsd on the host.
> The following utility can do this:
> https://github.com/stefanha/linux/blob/vsock-extras/nc-vsock.c
> 
>   (host)# nc-vsock -l 2049 -t 127.0.0.1 2049
> 
> I will post nfsd patches for both the kernel and nfs-utils once they are
> complete.
> 
> Alternatively you can use nfs-ganesha's AF_VSOCK support to run a native
> AF_VSOCK server.
> 
> Note that this patch series relies on the AF_VSOCK getaddrinfo(3) support I
> recently posted to glibc:
> https://patchwork.ozlabs.org/patch/676589/
> 
> Stefan Hajnoczi (4):
>   mount: don't use IPPROTO_UDP for address resolution
>   mount: present AF_VSOCK addresses
>   mount: accept AF_VSOCK in nfs_verify_family()
>   getport: recognize "vsock" netid
> 
>  support/nfs/getport.c | 16 ++++++++++++----
>  utils/mount/network.c | 10 +++++++++-
>  utils/mount/stropts.c |  4 +---
>  3 files changed, 22 insertions(+), 8 deletions(-)
> 

-- 
Jeff Layton <jlayton@redhat.com>

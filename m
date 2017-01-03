Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47290 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1759621AbdACQh7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 3 Jan 2017 11:37:59 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id D70F231B337
        for <linux-nfs@vger.kernel.org>; Tue,  3 Jan 2017 16:37:59 +0000 (UTC)
Subject: Re: [PATCH 0/4] nfs-utils mount: add AF_VSOCK support
To: Stefan Hajnoczi <stefanha@redhat.com>, linux-nfs@vger.kernel.org
References: <1475834503-3984-1-git-send-email-stefanha@redhat.com>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <5e994b44-8b88-62f8-3c09-6d8cb459e303@RedHat.com>
Date: Tue, 3 Jan 2017 11:37:58 -0500
MIME-Version: 1.0
In-Reply-To: <1475834503-3984-1-git-send-email-stefanha@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/07/2016 06:01 AM, Stefan Hajnoczi wrote:
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
My apologies... I did lose track of these... 

Where the kernel patches for the AF_VSOCK support 
accepted??

steved.
 

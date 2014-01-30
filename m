Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f182.google.com ([209.85.213.182]:38702 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753224AbaA3ORD convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jan 2014 09:17:03 -0500
Received: by mail-ig0-f182.google.com with SMTP id uy17so7152926igb.3
        for <linux-nfs@vger.kernel.org>; Thu, 30 Jan 2014 06:17:02 -0800 (PST)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: NFS client broken in Linus' tip
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <20140130140834.GW15937@n2100.arm.linux.org.uk>
Date: Thu, 30 Jan 2014 09:17:00 -0500
Cc: linuxnfs <linux-nfs@vger.kernel.org>, Christoph Hellwig <hch@lst.de>,
        Viro Alexander <viro@zeniv.linux.org.uk>,
        linux-arm-kernel@lists.infradead.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Message-Id: <960A8F94-BDD4-4ED0-95EC-0D71D4AC27E7@primarydata.com>
References: <20140130140834.GW15937@n2100.arm.linux.org.uk>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 30, 2014, at 9:08, Russell King - ARM Linux <linux@arm.linux.org.uk> wrote:

> I just booted Linus' tip (plus a few other patches to imx-drm and imx
> code), and stumbled into this interesting scenario:
> 
> # touch test
> touch: cannot touch `test': Operation not supported
> 
> I also tried mkdir and mknod, all result in the same error.  Hard and
> symlinks links are creatable.
> 
> However, I can chmod existing files and rename them.  Files can also be
> deleted, and the combination of this has left me without a /etc/mtab !
> 
> The machine is a iMX6 based ARM, running root-nfs, which was mounted via
> ubuntu's initramfs (so not using the kernel's built-in root-nfs.)
> 
> /proc/mounts for the root mount gives:
> 192.168.1.123:/var/boot/ci / nfs rw,relatime,vers=3,rsize=65536,wsize=65536,namlen=255,hard,nolock,proto=tcp,port=2049,timeo=7,retrans=10,sec=sys,local_lock=all,addr=192.168.1.123 0 0
> 
> CONFIG_NFS_FS=y
> CONFIG_NFS_V2=y
> CONFIG_NFS_V3=y
> CONFIG_NFS_V3_ACL=y
> CONFIG_NFS_V4=y
> # CONFIG_NFS_SWAP is not set
> # CONFIG_NFS_V4_1 is not set
> CONFIG_ROOT_NFS=y
> # CONFIG_NFS_USE_LEGACY_DNS is not set
> CONFIG_NFS_USE_KERNEL_DNS=y
> # CONFIG_NFSD is not set
> CONFIG_LOCKD=y
> CONFIG_LOCKD_V4=y
> CONFIG_NFS_ACL_SUPPORT=y
> CONFIG_NFS_COMMON=y
> CONFIG_SUNRPC=y
> CONFIG_SUNRPC_GSS=y
> 
> tcpdumping, I see:
> 
> 13:59:51.713523 IP 192.168.1.252.1341245608 > 192.168.1.123.2049: 132 lookup fh Unknown/010007011040840000000000CC238FC8FBA0475D9D9F8356B4C44166CDC38700 "test"
> 13:59:51.714345 IP 192.168.1.123.2049 > 192.168.1.252.1341245608: reply ok 120 lookup ERROR: No such file or directory
> 13:59:51.751303 IP 192.168.1.252.797 > 192.168.1.123.nfs: . ack 3381 win 2625 <nop,nop,timestamp 474136 3431312924>
> 
> which is the only NFS packet(s) I see which mention "test".
> 
> and stracing touch:
> 
> open("test", O_WRONLY|O_CREAT|O_NOCTTY|O_NONBLOCK|O_LARGEFILE, 0666) = -1 EOPNOTSUPP (Operation not supported)
> utimensat(AT_FDCWD, "test", NULL, 0)    = -1 ENOENT (No such file or directory)
> write(2, "touch: ", 7touch: )                  = 7
> write(2, "cannot touch `test'", 19cannot touch `test')     = 19
> write(2, ": Operation not supported", 25: Operation not supported) = 25
> write(2, "\n", 1
> )                       = 1
> 
> I think it's down to this:
> 
> commit 013cdf1088d7235da9477a2375654921d9b9ba9f
> Author: Christoph Hellwig <hch@infradead.org>
> Date:   Fri Dec 20 05:16:53 2013 -0800
> 
>    nfs: use generic posix ACL infrastructure for v3 Posix ACLs
> 
>    This causes a small behaviour change in that we don't bother to set
>    ACLs on file creation if the mode bit can express the access permissions
>    fully, and thus behaving identical to local filesystems.
> 
>    Signed-off-by: Christoph Hellwig <hch@lst.de>
>    Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
> 
> which adds:
> 
> +       status = posix_acl_create(dir, &sattr->ia_mode, &default_acl, &acl);
> +       if (status)
> +               goto out;

Right, this should clearly not cause nfs4_proc_create to fail if it returns EOPNOTSUPP.

> into nfs3_proc_create(), but this ends up calling down into nfs3_get_acl(),
> which does this:
> 
>        if (!nfs_server_capable(inode, NFS_CAP_ACLS))
>                return ERR_PTR(-EOPNOTSUPP);

Just for completeness sake: is the server you were running against supposed to support POSIX acls?

--
Trond Myklebust
Linux NFS client maintainer


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:51651 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757653Ab0GTUiX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Jul 2010 16:38:23 -0400
Date: Tue, 20 Jul 2010 16:37:42 -0400
To: Rick Harris <rickfharris@yahoo.com.au>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Memory leaks in rpc.mountd
Message-ID: <20100720203741.GB11367@fieldses.org>
References: <op.vfl3hdllxjjcjd@ricks-laptop.localnet>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <op.vfl3hdllxjjcjd@ricks-laptop.localnet>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, Jul 10, 2010 at 02:43:51PM +0930, Rick Harris wrote:
> Hi all,
> 
> I'm currently experiencing some large memory leaks on an NFS server
> when copying files to it from an NFS client.
> This happens for both NFSv3 and NFSv4, am currently using an NFSv4 setup.
> Installed software and kernel versions below...
> 
> 
> SERVER:
> Kernel 2.6.32.9
> CONFIG_NFS_FS=y
> # CONFIG_NFS_V3 is not set
> CONFIG_NFS_V4=y
> # CONFIG_NFS_V4_1 is not set
> # CONFIG_ROOT_NFS is not set
> CONFIG_NFSD=y
> CONFIG_NFSD_V3=y
> # CONFIG_NFSD_V3_ACL is not set
> CONFIG_NFSD_V4=y
> CONFIG_NFS_COMMON=y
> 
> libtirpc-0.2.0
> rpcbind-0.2.0
> nfs-utils-1.2.2
> 
> 
> CLIENT:
> Kernel 2.6.34
> CONFIG_NFS_FS=y
> # CONFIG_NFS_V3 is not set
> CONFIG_NFS_V4=y
> # CONFIG_NFS_V4_1 is not set
> CONFIG_NFSD=y
> CONFIG_NFSD_V3=y
> # CONFIG_NFSD_V3_ACL is not set
> CONFIG_NFSD_V4=y
> CONFIG_NFS_COMMON=y
> 
> libtirpc-0.2.0
> rpcbind-0.2.0
> nfs-utils-1.2.2
> 
> 
> Output of kmemleak report...
> 
> unreferenced object 0xf4b2ec60 (size 32):

If I understand right, it's saying that it only found the one
unreferenced object?  svc_export_parse should be called relatively
rarely, so it's unlikely to explain your symptoms anyway.

>   comm "rpc.mountd", pid 1814, jiffies 4294759177
>   hex dump (first 32 bytes):
>     ab 82 c0 3b c4 54 4f e9 a5 c9 ee db 43 71 fc 38  ...;.TO.....Cq.8
>     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
>   backtrace:
>     [<c12e7d79>] kmemleak_alloc+0x59/0xc0
>     [<c106ac5a>] __kmalloc+0xfa/0x110
>     [<c105787f>] kmemdup+0x1f/0x70
>     [<c113dfb1>] svc_export_parse+0x621/0x770
>     [<c12db79d>] cache_do_downcall+0x2d/0x40
>     [<c12dc2f1>] cache_write+0x91/0xe0
>     [<c12dc392>] cache_write_procfs+0x22/0x30
>     [<c10a6e34>] proc_reg_write+0x44/0x60
>     [<c106fbcc>] vfs_write+0x9c/0x160
>     [<c106fd4d>] sys_write+0x3d/0x70
>     [<c1002c48>] sysenter_do_call+0x12/0x26
>     [<ffffffff>] 0xffffffff
> 
> 
> The test case is copying a 1.5GB file from the nfs client to the server.
> It literally takes only a minute for the server's 1.2GB of memory to
> be almost totally exhausted down to around 5MB.

How are you measuring the amount of free memory?

> The copying process hangs, then resumes many times along the way
> until it does successfully finish around 4 minutes later.
> The consumed memory is then not freed and the server's memory
> remains depleted to almost nothing.

What kind of drive are you exporting, over what network?

--b.

> The memory is never completely exhausted so it never starts to swap ?
> 
> Reading from server works fine with no memory loss, albeit a much
> slower transfer rate.
> 
> This started happening after a kernel upgrade on the server from
> 2.6.20.7 to 2.6.29.5, but is still occurring with the latest
> kernels.
> Hope the above info helps, I'm willing to try any patches that may
> get thrown my way.
> 
> 
> Cheers,
> Rick
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

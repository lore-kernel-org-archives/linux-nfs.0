Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ipmail04.adl6.internode.on.net ([150.101.137.141]:7109 "EHLO
	ipmail04.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750791Ab0GJFS4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 10 Jul 2010 01:18:56 -0400
Received: from ricks-laptop.localnet (Ricks-LAPTOP.localnet [192.168.0.14])
	by mightylegends.org (Postfix) with ESMTPA id 74211733CB4
	for <linux-nfs@vger.kernel.org>; Sat, 10 Jul 2010 14:43:51 +0930 (CST)
Content-Type: text/plain; charset=us-ascii; format=flowed; delsp=yes
To: linux-nfs@vger.kernel.org
Date: Sat, 10 Jul 2010 14:43:51 +0930
Subject: Memory leaks in rpc.mountd
From: "Rick Harris" <rickfharris@yahoo.com.au>
Message-ID: <op.vfl3hdllxjjcjd@ricks-laptop.localnet>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi all,

I'm currently experiencing some large memory leaks on an NFS server when  
copying files to it from an NFS client.
This happens for both NFSv3 and NFSv4, am currently using an NFSv4 setup.
Installed software and kernel versions below...


SERVER:
Kernel 2.6.32.9
CONFIG_NFS_FS=y
# CONFIG_NFS_V3 is not set
CONFIG_NFS_V4=y
# CONFIG_NFS_V4_1 is not set
# CONFIG_ROOT_NFS is not set
CONFIG_NFSD=y
CONFIG_NFSD_V3=y
# CONFIG_NFSD_V3_ACL is not set
CONFIG_NFSD_V4=y
CONFIG_NFS_COMMON=y

libtirpc-0.2.0
rpcbind-0.2.0
nfs-utils-1.2.2


CLIENT:
Kernel 2.6.34
CONFIG_NFS_FS=y
# CONFIG_NFS_V3 is not set
CONFIG_NFS_V4=y
# CONFIG_NFS_V4_1 is not set
CONFIG_NFSD=y
CONFIG_NFSD_V3=y
# CONFIG_NFSD_V3_ACL is not set
CONFIG_NFSD_V4=y
CONFIG_NFS_COMMON=y

libtirpc-0.2.0
rpcbind-0.2.0
nfs-utils-1.2.2


Output of kmemleak report...

unreferenced object 0xf4b2ec60 (size 32):
   comm "rpc.mountd", pid 1814, jiffies 4294759177
   hex dump (first 32 bytes):
     ab 82 c0 3b c4 54 4f e9 a5 c9 ee db 43 71 fc 38  ...;.TO.....Cq.8
     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
   backtrace:
     [<c12e7d79>] kmemleak_alloc+0x59/0xc0
     [<c106ac5a>] __kmalloc+0xfa/0x110
     [<c105787f>] kmemdup+0x1f/0x70
     [<c113dfb1>] svc_export_parse+0x621/0x770
     [<c12db79d>] cache_do_downcall+0x2d/0x40
     [<c12dc2f1>] cache_write+0x91/0xe0
     [<c12dc392>] cache_write_procfs+0x22/0x30
     [<c10a6e34>] proc_reg_write+0x44/0x60
     [<c106fbcc>] vfs_write+0x9c/0x160
     [<c106fd4d>] sys_write+0x3d/0x70
     [<c1002c48>] sysenter_do_call+0x12/0x26
     [<ffffffff>] 0xffffffff


The test case is copying a 1.5GB file from the nfs client to the server.
It literally takes only a minute for the server's 1.2GB of memory to be  
almost totally exhausted down to around 5MB.
The copying process hangs, then resumes many times along the way until it  
does successfully finish around 4 minutes later.
The consumed memory is then not freed and the server's memory remains  
depleted to almost nothing.
The memory is never completely exhausted so it never starts to swap ?

Reading from server works fine with no memory loss, albeit a much slower  
transfer rate.

This started happening after a kernel upgrade on the server from 2.6.20.7  
to 2.6.29.5, but is still occurring with the latest kernels.
Hope the above info helps, I'm willing to try any patches that may get  
thrown my way.


Cheers,
Rick

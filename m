Return-Path: linux-nfs-owner@vger.kernel.org
Received: from dsl-67-204-24-19.acanac.net ([67.204.24.19]:44134 "EHLO
	mail.ellipticsemi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751238Ab1LISX4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Dec 2011 13:23:56 -0500
Date: Fri, 9 Dec 2011 12:59:25 -0500
From: Nick Bowler <nbowler@elliptictech.com>
To: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: NFS kmemleak reports.
Message-ID: <20111209175925.GA14635@elliptictech.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi folks,

Lately, I've been seeing dozens of kmemleak reports pointing at NFS.
They all appear to be referring to the same "name" value which gets
stored in dentry->d_fsdata by nfs_get_root.  But at a first glance
the code seems to be taking some care to free these properly (although
it's quite tricky for me to follow), so I'm not sure what's up.  These
are NFSv3 client mounts.

This is with Linus' master as of a couple days ago, but I've also seen
this on some older kernels (on different networks).  The machine in
question is using autofs (which may explain the fairly large number of
kmemleak reports, due to semi-frequent mounting/unmounting).

They all look essentially the same: one is quoted below.

  unreferenced object 0xf18fb820 (size 32):
    comm "mount.nfs", pid 5688, jiffies 15473748 (age 73861.344s)
    hex dump (first 32 bytes):
      65 6c 70 66 73 31 3a 2f 65 78 70 6f 72 74 2f 74  elpfs1:/export/t
      6f 6f 6c 73 2f 65 6c 70 73 6f 66 74 00 00 00 00  ools/elpsoft....
    backtrace:
      [<c125d7f6>] kmemleak_alloc+0x21/0x3f
      [<c10a95c2>] __kmalloc_track_caller+0x128/0x14a
      [<c1093db6>] kstrdup+0x29/0x39
      [<f85a7543>] nfs_get_root+0x29/0x11e [nfs]
      [<f85ac6ee>] nfs_fs_mount+0x6d6/0x75b [nfs]
      [<c10ae861>] mount_fs+0xe/0x95
      [<c10bf2cd>] vfs_kern_mount+0x4a/0x78
      [<c10bff7c>] do_kern_mount+0x2f/0xad
      [<c10c129e>] do_mount+0x581/0x5cf
      [<c10c1521>] sys_mount+0x61/0x94
      [<c12718d0>] sysenter_do_call+0x12/0x36
      [<ffffffff>] 0xffffffff

Let me know if you need any more info,
-- 
Nick Bowler, Elliptic Technologies (http://www.elliptictech.com/)

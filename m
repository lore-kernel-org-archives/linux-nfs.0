Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from frankvm.xs4all.nl ([83.163.148.79]:56588 "EHLO
	janus.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759256Ab1FWNw5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Jun 2011 09:52:57 -0400
Date: Thu, 23 Jun 2011 15:39:45 +0200
From: Frank van Maarseveen <frankvm@frankvm.com>
To: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: mount.nfs->nfs_idmap_new(): page allocation failure. order:4,
 mode:0xc0d0
Message-ID: <20110623133945.GA18017@janus>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The automounter for /net triggered this:

kernel: mount.nfs: page allocation failure. order:4, mode:0xc0d0
kernel: Pid: 27787, comm: mount.nfs Not tainted 2.6.39.1-x257lm #1
kernel: Call Trace:
kernel: [<ffffffff810ea32f>] __alloc_pages_nodemask+0x73f/0x800
kernel: [<ffffffff810ea492>] __get_free_pages+0x12/0x50
kernel: [<ffffffff81231122>] nfs_idmap_new+0x32/0x100
kernel: [<ffffffff81200918>] nfs4_init_client+0x88/0x1c0
kernel: [<ffffffff81200e2b>] nfs_get_client+0x23b/0x320
kernel: [<ffffffff819121c1>] ? __mutex_lock_slowpath+0x2a1/0x350
kernel: [<ffffffff81200f76>] nfs4_set_client+0x66/0xf0
kernel: [<ffffffff81911d49>] ? mutex_unlock+0x9/0x10
kernel: [<ffffffff812010c7>] nfs4_init_server+0xc7/0x2b0
kernel: [<ffffffff81201d8b>] nfs4_create_server+0x3b/0xe0
kernel: [<ffffffff8120d04b>] nfs4_remote_mount+0x5b/0x1c0
kernel: [<ffffffff8111f234>] mount_fs+0x14/0xd0
kernel: [<ffffffff8113ae95>] vfs_kern_mount+0x65/0xc0
kernel: [<ffffffff8120d41a>] nfs_do_root_mount+0x7a/0xa0
kernel: [<ffffffff8120d7ee>] nfs4_try_mount+0x4e/0xd0
kernel: [<ffffffff8120ea4f>] nfs_fs_mount+0x1af/0x410
kernel: [<ffffffff8111f234>] mount_fs+0x14/0xd0
kernel: [<ffffffff8113ae95>] vfs_kern_mount+0x65/0xc0
kernel: [<ffffffff8113be5e>] do_kern_mount+0x4e/0x100
kernel: [<ffffffff8113d570>] do_mount+0x1f0/0x240
kernel: [<ffffffff81163ae7>] compat_sys_mount+0xc7/0x230
kernel: [<ffffffff8103d01d>] ? math_state_restore+0x3d/0x60
kernel: [<ffffffff819156dc>] sysenter_dispatch+0x7/0x32

Page allocation order 4 is quite a lot.


-- 
Frank

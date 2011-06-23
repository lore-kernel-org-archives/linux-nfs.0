Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:9617 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755367Ab1FWOBG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Jun 2011 10:01:06 -0400
Subject: Re: mount.nfs->nfs_idmap_new(): page allocation failure. order:4,
 mode:0xc0d0
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Frank van Maarseveen <frankvm@frankvm.com>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Date: Thu, 23 Jun 2011 10:00:40 -0400
In-Reply-To: <20110623133945.GA18017@janus>
References: <20110623133945.GA18017@janus>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1308837640.6797.2.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-06-23 at 15:39 +0200, Frank van Maarseveen wrote: 
> The automounter for /net triggered this:
> 
> kernel: mount.nfs: page allocation failure. order:4, mode:0xc0d0
> kernel: Pid: 27787, comm: mount.nfs Not tainted 2.6.39.1-x257lm #1
> kernel: Call Trace:
> kernel: [<ffffffff810ea32f>] __alloc_pages_nodemask+0x73f/0x800
> kernel: [<ffffffff810ea492>] __get_free_pages+0x12/0x50
> kernel: [<ffffffff81231122>] nfs_idmap_new+0x32/0x100
> kernel: [<ffffffff81200918>] nfs4_init_client+0x88/0x1c0
> kernel: [<ffffffff81200e2b>] nfs_get_client+0x23b/0x320
> kernel: [<ffffffff819121c1>] ? __mutex_lock_slowpath+0x2a1/0x350
> kernel: [<ffffffff81200f76>] nfs4_set_client+0x66/0xf0
> kernel: [<ffffffff81911d49>] ? mutex_unlock+0x9/0x10
> kernel: [<ffffffff812010c7>] nfs4_init_server+0xc7/0x2b0
> kernel: [<ffffffff81201d8b>] nfs4_create_server+0x3b/0xe0
> kernel: [<ffffffff8120d04b>] nfs4_remote_mount+0x5b/0x1c0
> kernel: [<ffffffff8111f234>] mount_fs+0x14/0xd0
> kernel: [<ffffffff8113ae95>] vfs_kern_mount+0x65/0xc0
> kernel: [<ffffffff8120d41a>] nfs_do_root_mount+0x7a/0xa0
> kernel: [<ffffffff8120d7ee>] nfs4_try_mount+0x4e/0xd0
> kernel: [<ffffffff8120ea4f>] nfs_fs_mount+0x1af/0x410
> kernel: [<ffffffff8111f234>] mount_fs+0x14/0xd0
> kernel: [<ffffffff8113ae95>] vfs_kern_mount+0x65/0xc0
> kernel: [<ffffffff8113be5e>] do_kern_mount+0x4e/0x100
> kernel: [<ffffffff8113d570>] do_mount+0x1f0/0x240
> kernel: [<ffffffff81163ae7>] compat_sys_mount+0xc7/0x230
> kernel: [<ffffffff8103d01d>] ? math_state_restore+0x3d/0x60
> kernel: [<ffffffff819156dc>] sysenter_dispatch+0x7/0x32
> 
> Page allocation order 4 is quite a lot.

..and is one of the reasons why we added a new idmapper. Please see
CONFIG_NFS_USE_NEW_IDMAPPER.

Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com


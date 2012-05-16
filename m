Return-Path: linux-nfs-owner@vger.kernel.org
Received: from plane.gmane.org ([80.91.229.3]:53513 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757473Ab2EPVeg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 May 2012 17:34:36 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1SUlrf-0002dE-4V
	for linux-nfs@vger.kernel.org; Wed, 16 May 2012 23:34:35 +0200
Received: from NORTHWEST-R.edge3.Denver1.Level3.net ([4.28.99.98])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 16 May 2012 23:34:35 +0200
Received: from orion by NORTHWEST-R.edge3.Denver1.Level3.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 16 May 2012 23:34:35 +0200
To: linux-nfs@vger.kernel.org
From: Orion Poplawski <orion@cora.nwra.com>
Subject: Re: Cannot unmount nfs4 sec=krb5 mount if network is down
Date: Wed, 16 May 2012 21:34:27 +0000 (UTC)
Message-ID: <loom.20120516T233017-710@post.gmane.org>
References: <loom.20120510T222025-23@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Orion Poplawski <orion@...> writes:
> 
> See https://bugzilla.redhat.com/show_bug.cgi?id=820707
>
> If the network is disconnected it is impossible to unmount, even if no
> processes are accessing the mount.  umount -f and umount -l both hang on
> readlink("/home/orion"). 

umount needs to canonicalize the path so it does a readlink on the path given to
it.  This hangs.  Here's the kernel trace.

[94630.673017] umount.nfs      D 0000009c     0 14999  14882 0x00000080
[94630.673017]  c30f5c38 00000086 00000001 0000009c ed110004 1b928142 0000560e
00000000
[94630.673017]  c0c4b180 ed37c000 c0c4b180 f5007180 f6b37110 c32ef110 c30f5c28
f7fd6243
[94630.673017]  c2f9c580 c30f5c20 f7fd9ff2 f82520c0 00000246 c30f5c0c c0927c33
c30f5c30
[94630.673017] Call Trace:
[94630.673017]  [<f7fd6243>] ? xs_sendpages+0x63/0x1f0 [sunrpc]
[94630.673017]  [<f7fd9ff2>] ? __rpc_sleep_on_priority+0x122/0x210 [sunrpc]
[94630.673017]  [<c0927c33>] ? _raw_spin_unlock_bh+0x13/0x20
[94630.673017]  [<c0927c33>] ? _raw_spin_unlock_bh+0x13/0x20
[94630.673017]  [<c0926ed5>] schedule+0x35/0x50
[94630.673017]  [<f7fd96fd>] rpc_wait_bit_killable+0x2d/0x70 [sunrpc]
[94630.673017]  [<c09259a1>] __wait_on_bit+0x51/0x70
[94630.673017]  [<f7fd96d0>] ? __rpc_wait_for_completion_task+0x30/0x30 [sunrpc]
[94630.673017]  [<f7fd96d0>] ? __rpc_wait_for_completion_task+0x30/0x30 [sunrpc]
[94630.673017]  [<c0925a21>] out_of_line_wait_on_bit+0x61/0x70
[94630.673017]  [<c0455480>] ? autoremove_wake_function+0x50/0x50
[94630.673017]  [<f7fda2e7>] __rpc_execute+0x187/0x2a0 [sunrpc]
[94630.673017]  [<c0455423>] ? wake_up_bit+0x23/0x30
[94630.673017]  [<f7fda548>] rpc_execute+0x38/0x40 [sunrpc]
[94630.673017]  [<f7fd30a9>] rpc_run_task+0x59/0x70 [sunrpc]
[94630.673017]  [<f7fd31bc>] rpc_call_sync+0x3c/0x60 [sunrpc]
[94630.673017]  [<f84aff63>] _nfs4_call_sync+0x23/0x30 [nfs]
[94630.673017]  [<f84afc3e>] _nfs4_proc_getattr+0x8e/0xa0 [nfs]
[94630.673017]  [<f84b385b>] nfs4_proc_getattr+0x3b/0x60 [nfs]
[94630.673017]  [<f849d311>] __nfs_revalidate_inode+0x81/0x210 [nfs]
[94630.673017]  [<f849d5df>] nfs_revalidate_inode+0x2f/0x50 [nfs]
[94630.673017]  [<f8496b3f>] nfs_check_verifier+0x4f/0x80 [nfs]
[94630.673017]  [<f8498ca2>] nfs_lookup_revalidate+0x232/0x450 [nfs]
[94630.673017]  [<c05ead5e>] ? autofs4_d_manage+0x8e/0xf0
[94630.673017]  [<f8499811>] nfs_open_revalidate+0x41/0x220 [nfs]
[94630.673017]  [<c053e79b>] ? follow_managed+0x19b/0x1f0
[94630.673017]  [<c053ff00>] ? unlazy_walk+0xd0/0x180
[94630.673017]  [<c0540153>] ? do_lookup+0x1a3/0x350
[94630.673017]  [<c053f748>] complete_walk+0x88/0xc0
[94630.673017]  [<c0540cc3>] path_lookupat+0x63/0x620
[94630.673017]  [<c0523b89>] ? kmem_cache_alloc+0x29/0x120
[94630.673017]  [<c065a998>] ? strncpy_from_user+0x38/0x70
[94630.673017]  [<c05412aa>] do_path_lookup+0x2a/0xb0
[94630.673017]  [<c0542466>] user_path_at_empty+0x46/0x80
[94630.673017]  [<c092b557>] ? do_page_fault+0x1b7/0x450
[94630.673017]  [<c050c074>] ? remove_vma+0x44/0x60
[94630.673017]  [<c054e233>] ? mntput_no_expire+0x23/0x100
[94630.673017]  [<c0539313>] sys_readlinkat+0x43/0xb0
[94630.673017]  [<c05393ac>] sys_readlink+0x2c/0x30
[94630.673017]  [<c0927ed4>] syscall_call+0x7/0xb

This appears to wait forever.  This pretty much makes it impossible to use krb5
nfs4 with laptops where the network can disappear.


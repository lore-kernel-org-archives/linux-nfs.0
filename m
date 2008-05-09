From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: referrals
Date: Thu, 8 May 2008 21:19:18 -0400
Message-ID: <20080509011918.GK12690@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, Manoj Naik <manoj@almaden.ibm.com>
To: Trond Myklebust <trond@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:35424 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756914AbYEIBTV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 May 2008 21:19:21 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

An attempt to follow an nfsv4 referral is leading to a hang.  I'm doing
an "ls" on the absent directory.  A network trace shows the server
returning with a sane-looking response to the getattr of fs_locations.
I've appended the part of the sysrq-t trace for "ls".  Any ideas?

--b.

May  8 19:33:02 piglet2 kernel: ls            D 00000046     0  3023   3006
May  8 19:33:02 piglet2 kernel:        ce527870 00000046 cf9181f0 00000046 00000000 00000000 cf9181f0 cf918450
May  8 19:33:02 piglet2 kernel:        cf918450 ce527850 c013976d c1201b88 00000246 ce527860 cf14a4c0 ce5278a8
May  8 19:33:02 piglet2 kernel:        c1201b88 ce527878 ce5278a0 00000000 ce5278a8 ce527878 c053b497 ce527894
May  8 19:33:02 piglet2 kernel: Call Trace:
May  8 19:33:02 piglet2 kernel:  [<c013976d>] ? trace_hardirqs_on+0x9d/0x110
May  8 19:33:02 piglet2 kernel:  [<c053b497>] rpc_wait_bit_killable+0x17/0x30
May  8 19:33:02 piglet2 kernel:  [<c058a045>] __wait_on_bit+0x55/0x80
May  8 19:33:02 piglet2 kernel:  [<c053b480>] ? rpc_wait_bit_killable+0x0/0x30
May  8 19:33:02 piglet2 kernel:  [<c053b480>] ? rpc_wait_bit_killable+0x0/0x30
May  8 19:33:02 piglet2 kernel:  [<c058a0b8>] out_of_line_wait_on_bit+0x48/0x50
May  8 19:33:02 piglet2 kernel:  [<c012f5b0>] ? wake_bit_function+0x0/0x50
May  8 19:33:02 piglet2 kernel:  [<c053be87>] __rpc_execute+0xa7/0x240
May  8 19:33:02 piglet2 kernel:  [<c053c047>] rpc_execute+0x17/0x20
May  8 19:33:02 piglet2 kernel:  [<c0534a25>] rpc_run_task+0x25/0x60
May  8 19:33:02 piglet2 kernel:  [<c0534b01>] rpc_call_sync+0x41/0x60
May  8 19:33:02 piglet2 kernel:  [<c0534b63>] rpc_ping+0x43/0x60
May  8 19:33:02 piglet2 kernel:  [<c053662c>] rpc_create+0x46c/0x510
May  8 19:33:02 piglet2 kernel:  [<c0139da2>] ? __lock_acquire+0x4b2/0xc30
May  8 19:33:02 piglet2 kernel:  [<c053cb61>] ? rpcauth_lookup_credcache+0xe1/0x220
May  8 19:33:02 piglet2 kernel:  [<c021ee18>] nfs_create_rpc_client+0xa8/0xe0
May  8 19:33:02 piglet2 kernel:  [<c058bbd7>] ? _spin_unlock+0x27/0x40
May  8 19:33:02 piglet2 kernel:  [<c021f547>] nfs4_set_client+0x67/0x170
May  8 19:33:02 piglet2 kernel:  [<c021fd6b>] nfs4_create_referral_server+0x7b/0x230
May  8 19:33:02 piglet2 kernel:  [<c0139da2>] ? __lock_acquire+0x4b2/0xc30
May  8 19:33:02 piglet2 last message repeated 2 times
May  8 19:33:02 piglet2 kernel:  [<c0165430>] ? poison_obj+0x20/0x40
May  8 19:33:02 piglet2 kernel:  [<c0228f91>] nfs4_referral_get_sb+0x31/0x190
May  8 19:33:02 piglet2 kernel:  [<c013976d>] ? trace_hardirqs_on+0x9d/0x110
May  8 19:33:02 piglet2 kernel:  [<c0165882>] ? check_poison_obj+0x22/0x1b0
May  8 19:33:02 piglet2 kernel:  [<c0165430>] ? poison_obj+0x20/0x40
May  8 19:33:02 piglet2 kernel:  [<c0165131>] ? dbg_redzone1+0x11/0x20
May  8 19:33:02 piglet2 kernel:  [<c0181375>] ? alloc_vfsmnt+0xd5/0x110
May  8 19:33:02 piglet2 kernel:  [<c0165a81>] ? cache_alloc_debugcheck_after+0x71/0x1a0
May  8 19:33:02 piglet2 kernel:  [<c01671b0>] ? __kmalloc+0x100/0x140
May  8 19:33:02 piglet2 kernel:  [<c016716e>] ? __kmalloc+0xbe/0x140
May  8 19:33:02 piglet2 kernel:  [<c0181375>] ? alloc_vfsmnt+0xd5/0x110
May  8 19:33:02 piglet2 kernel:  [<c0181375>] ? alloc_vfsmnt+0xd5/0x110
May  8 19:33:02 piglet2 kernel:  [<c016bc33>] vfs_kern_mount+0x53/0x120
May  8 19:33:02 piglet2 kernel:  [<c02464fd>] nfs_do_refmount+0x65d/0x680
May  8 19:33:02 piglet2 kernel:  [<c02317b2>] nfs_follow_mountpoint+0x232/0x410
May  8 19:33:02 piglet2 kernel:  [<c058bbd7>] ? _spin_unlock+0x27/0x40
May  8 19:33:02 piglet2 kernel:  [<c018017d>] ? mnt_drop_write+0x5d/0x120
May  8 19:33:02 piglet2 kernel:  [<c0174bb4>] do_follow_link+0x104/0x300
May  8 19:33:02 piglet2 kernel:  [<c017294c>] ? do_lookup+0x5c/0x170
May  8 19:33:02 piglet2 kernel:  [<c0172fd5>] __link_path_walk+0x575/0x7e0
May  8 19:33:02 piglet2 kernel:  [<c0173286>] path_walk+0x46/0xb0
May  8 19:33:02 piglet2 kernel:  [<c01734b8>] do_path_lookup+0x68/0x160
May  8 19:33:02 piglet2 kernel:  [<c017183d>] ? getname+0x9d/0xb0
May  8 19:33:02 piglet2 kernel:  [<c0173ec0>] __user_walk_fd+0x30/0x50
May  8 19:33:02 piglet2 kernel:  [<c016d8e9>] vfs_stat_fd+0x19/0x40
May  8 19:33:02 piglet2 kernel:  [<c0157eac>] ? handle_mm_fault+0xfc/0x5a0
May  8 19:33:02 piglet2 kernel:  [<c016d9e1>] vfs_stat+0x11/0x20
May  8 19:33:02 piglet2 kernel:  [<c016da04>] sys_stat64+0x14/0x30
May  8 19:33:02 piglet2 kernel:  [<c0132886>] ? up_read+0x16/0x30
May  8 19:33:02 piglet2 kernel:  [<c0103123>] ? restore_nocheck+0x12/0x15
May  8 19:33:02 piglet2 kernel:  [<c058d4c0>] ? do_page_fault+0x0/0x6c0
May  8 19:33:02 piglet2 kernel:  [<c013976d>] ? trace_hardirqs_on+0x9d/0x110
May  8 19:33:02 piglet2 kernel:  [<c0103123>] ? restore_nocheck+0x12/0x15
May  8 19:33:02 piglet2 kernel:  [<c01030c2>] syscall_call+0x7/0xb

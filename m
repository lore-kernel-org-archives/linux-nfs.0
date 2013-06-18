Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f171.google.com ([209.85.217.171]:53700 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754001Ab3FRKjc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Jun 2013 06:39:32 -0400
Date: Tue, 18 Jun 2013 14:37:18 +0400
From: Andrew Vagin <avagin@gmail.com>
To: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: BUG: path_init is called, when current->fs is already NULL
Message-ID: <20130618103718.GA6053@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I got this panic only once and I can't reproduce it again.
Looks like we try to access current->fs, when it is already released.

Here is a call trace how we get this situation.
do_exit(code):
	exit_fs(tsk); // current->fs = NULL
	exit_task_namespaces(tsk);
	...
		path_init
			set_root_rcu
				read_seqcount_begin(current->fs->sec)

[ 1428.648178] BUG: unable to handle kernel NULL pointer dereference at 0000000000000040
[ 1428.649022] IP: [<ffffffff81199cee>] path_init+0x3be/0x4c0
[ 1428.649022] PGD 0
[ 1428.649022] Oops: 0000 [#1] SMP
[ 1428.649022] Modules linked in: nfsv3 nfs_acl nfs lockd sunrpc fscache ip6table_filter ip6_tables iptable_filter ip_tables microcode pcspkr virtio_net virtio_balloon i2c_piix4 i2c_core floppy
[ 1428.649022] CPU: 0 PID: 342 Comm: bash Not tainted 3.10.0-rc5+ #42
[ 1428.649022] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[ 1428.649022] task: ffff8800372c8000 ti: ffff8800795ee000 task.ti: ffff8800795ee000
[ 1428.649022] RIP: 0010:[<ffffffff81199cee>]  [<ffffffff81199cee>] path_init+0x3be/0x4c0
[ 1428.649022] RSP: 0018:ffff8800795ef628  EFLAGS: 00010246
[ 1428.649022] RAX: 0000000000000000 RBX: ffff8800795ef7a8 RCX: 0000000e5c088000
[ 1428.649022] RDX: 0000000000000000 RSI: 0000000000000002 RDI: 0000000000000246
[ 1428.649022] RBP: ffff8800795ef688 R08: 0000000000000002 R09: 0000000000000000
[ 1428.649022] R10: 0000000000000001 R11: 0000000000000015 R12: ffff8800726d801a
[ 1428.649022] R13: 0000000000000041 R14: ffff8800795ef7a8 R15: 7fffffffffffffff
[ 1428.649022] FS:  00007f5cd7ed2740(0000) GS:ffff88007fc00000(0000) knlGS:0000000000000000
[ 1428.649022] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 1428.649022] CR2: 0000000000000040 CR3: 000000007a45b000 CR4: 00000000000006f0
[ 1428.649022] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 1428.649022] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 1428.649022] Stack:
[ 1428.649022]  ffffffff81199b91 ffff8800761088d0 ffff8800795ef738 0000000000000046
[ 1428.649022]  0000000000000001 0000000000000000 ffff88007d001b00 ffff8800795ef7a8
[ 1428.649022]  ffff8800726d801a 0000000000000041 ffff8800795ef7a8 7fffffffffffffff
[ 1428.649022] Call Trace:
[ 1428.649022]  [<ffffffff81199b91>] ? path_init+0x261/0x4c0
[ 1428.649022]  [<ffffffff81199e23>] path_lookupat+0x33/0x730
[ 1428.649022]  [<ffffffff8119a554>] filename_lookup+0x34/0xc0
[ 1428.649022]  [<ffffffff8119a692>] do_path_lookup+0x32/0x40
[ 1428.649022]  [<ffffffff8119a91a>] kern_path+0x2a/0x50
[ 1428.649022]  [<ffffffff8151b23c>] ? __kmalloc_reserve.isra.53+0x3c/0xa0
[ 1428.649022]  [<ffffffff8151cc2b>] ? __alloc_skb+0x9b/0x2a0
[ 1428.649022]  [<ffffffff815cc80c>] ? unix_create1+0x18c/0x1c0
[ 1428.649022]  [<ffffffff815cdea6>] unix_find_other+0x36/0x210
[ 1428.649022]  [<ffffffff81516cc4>] ? sock_wmalloc+0x34/0x90
[ 1428.649022]  [<ffffffff815cf4ab>] unix_stream_connect+0xeb/0x460
[ 1428.649022]  [<ffffffff8105632d>] ? local_bh_enable_ip+0x8d/0x100
[ 1428.649022]  [<ffffffff8150fa90>] kernel_connect+0x10/0x20
[ 1428.649022]  [<ffffffffa0086f3c>] xs_local_setup_socket+0x13c/0x320 [sunrpc]
[ 1428.649022]  [<ffffffffa008728f>] xs_local_connect+0x1f/0x70 [sunrpc]
[ 1428.649022]  [<ffffffffa008255d>] xprt_connect+0x11d/0x1a0 [sunrpc]
[ 1428.649022]  [<ffffffffa007dd60>] ? call_bind_status+0x290/0x290 [sunrpc]
[ 1428.649022]  [<ffffffffa007dd60>] ? call_bind_status+0x290/0x290 [sunrpc]
[ 1428.649022]  [<ffffffffa007ddb6>] call_connect+0x56/0xa0 [sunrpc]
[ 1428.649022]  [<ffffffffa00884b4>] __rpc_execute+0x84/0x390 [sunrpc]
[ 1428.649022]  [<ffffffff81075dbe>] ? wake_up_bit+0x2e/0x40
[ 1428.649022]  [<ffffffffa0089629>] rpc_execute+0x59/0xa0 [sunrpc]
[ 1428.649022]  [<ffffffffa00804b0>] rpc_run_task+0x70/0x90 [sunrpc]
[ 1428.649022]  [<ffffffffa00805d3>] rpc_call_sync+0x43/0xa0 [sunrpc]
[ 1428.649022]  [<ffffffffa0092cd0>] rpcb_register_call+0x20/0x60 [sunrpc]
[ 1428.649022]  [<ffffffffa0093b2e>] rpcb_v4_register+0x1ae/0x220 [sunrpc]
[ 1428.649022]  [<ffffffffa0093985>] ? rpcb_v4_register+0x5/0x220 [sunrpc]
[ 1428.649022]  [<ffffffffa008bc9b>] svc_unregister.isra.7+0x8b/0x160 [sunrpc]
[ 1428.649022]  [<ffffffffa008bd86>] svc_rpcb_cleanup+0x16/0x30 [sunrpc]
[ 1428.649022]  [<ffffffffa008bb14>] svc_shutdown_net+0x34/0x40 [sunrpc]
[ 1428.649022]  [<ffffffffa00d8088>] lockd_down_net+0xd8/0x120 [lockd]
[ 1428.649022]  [<ffffffffa00d7fb5>] ? lockd_down_net+0x5/0x120 [lockd]
[ 1428.649022]  [<ffffffffa00d8105>] lockd_down+0x35/0xf0 [lockd]
[ 1428.649022]  [<ffffffffa00d4022>] nlmclnt_done+0x22/0x30 [lockd]
[ 1428.649022]  [<ffffffffa00f4347>] nfs_destroy_server+0x17/0x20 [nfs]
[ 1428.649022]  [<ffffffffa00f528e>] nfs_free_server+0x10e/0x1d0 [nfs]
[ 1428.649022]  [<ffffffffa00f51b0>] ? nfs_free_server+0x30/0x1d0 [nfs]
[ 1428.649022]  [<ffffffffa00fe5f4>] nfs_kill_super+0x34/0x40 [nfs]
[ 1428.649022]  [<ffffffff8118fb3d>] deactivate_locked_super+0x4d/0x80
[ 1428.649022]  [<ffffffff8119076e>] deactivate_super+0x4e/0x70
[ 1428.649022]  [<ffffffff811ac397>] mntput_no_expire+0xd7/0x130
[ 1428.649022]  [<ffffffff811ac416>] mntput+0x26/0x40
[ 1428.649022]  [<ffffffff811ac593>] namespace_unlock+0x103/0x120
[ 1428.649022]  [<ffffffff811aed3f>] put_mnt_ns+0x4f/0x70
[ 1428.649022]  [<ffffffff8107a2af>] free_nsproxy+0x1f/0x90
[ 1428.649022]  [<ffffffff8107a540>] switch_task_namespaces+0x50/0x60
[ 1428.649022]  [<ffffffff8107a560>] exit_task_namespaces+0x10/0x20
[ 1428.649022]  [<ffffffff81053901>] do_exit+0x2a1/0xa30
[ 1428.649022]  [<ffffffff8163fe30>] ? _raw_write_unlock_irq+0x30/0x40
[ 1428.649022]  [<ffffffff816409d8>] ? retint_swapgs+0x13/0x1b
[ 1428.649022]  [<ffffffff81054129>] do_group_exit+0x49/0xc0
[ 1428.649022]  [<ffffffff810541b7>] SyS_exit_group+0x17/0x20
[ 1428.649022]  [<ffffffff81649199>] system_call_fastpath+0x16/0x1b
[ 1428.649022] Code: e8 a8 e6 ff ff 45 85 f6 0f 84 e4 fd ff ff 4c 89 ef e8 17 53 ff ff e9 d7 fd ff ff 65 48 8b 04 25 00 ba 00 00 48 8b 80 38 05 00 00 <8b> 70 40 40 f6 c6 01 0f 85 ed 00 00 00 48 8b 50 50 48 89 53 20
[ 1428.649022] RIP  [<ffffffff81199cee>] path_init+0x3be/0x4c0
[ 1428.649022]  RSP <ffff8800795ef628>
[ 1428.649022] CR2: 0000000000000040
[ 1428.811055] ---[ end trace 1f093fcc32fb286b ]---


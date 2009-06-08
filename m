From: Wu Fengguang <fengguang.wu@intel.com>
Subject: sk_lock: inconsistent {RECLAIM_FS-ON-W} -> {IN-RECLAIM_FS-W} usage
Date: Mon, 8 Jun 2009 10:37:57 +0800
Message-ID: <20090608023757.GA6244@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:53582 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751565AbZFHCh4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 7 Jun 2009 22:37:56 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

This lockdep warning appears when doing stress memory tests over NFS.

page reclaim => nfs_writepage => tcp_sendmsg => lock sk_lock

tcp_close => lock sk_lock => tcp_send_fin => alloc_skb_fclone => page reclaim

Any ideas?

Thanks,
Fengguang
---

[ 1630.751276] NFS: Server wrote zero bytes, expected 4096.
[ 1637.984875]
[ 1637.984878] =================================
[ 1637.987429] [ INFO: inconsistent lock state ]
[ 1637.987429] 2.6.30-rc8-mm1 #299
[ 1637.987429] ---------------------------------
[ 1637.987429] inconsistent {RECLAIM_FS-ON-W} -> {IN-RECLAIM_FS-W} usage.
[ 1637.987429] kswapd0/387 [HC0[0]:SC0[1]:HE1:SE0] takes:
[ 1637.987429]  (sk_lock-AF_INET-RPC){+.+.?.}, at: [<ffffffff81458972>] tcp_sendmsg+0x22/0xbc0
[ 1637.987429] {RECLAIM_FS-ON-W} state was registered at:
[ 1637.987429]   [<ffffffff81079b18>] mark_held_locks+0x68/0x90
[ 1637.987429]   [<ffffffff81079c35>] lockdep_trace_alloc+0xf5/0x100
[ 1637.987429]   [<ffffffff810c7f55>] __alloc_pages_nodemask+0x95/0x6c0
[ 1637.987429]   [<ffffffff810f71f9>] __slab_alloc_page+0xb9/0x3b0
[ 1637.987429]   [<ffffffff810f8596>] kmem_cache_alloc_node+0x166/0x200
[ 1637.987429]   [<ffffffff81423cba>] __alloc_skb+0x4a/0x160
[ 1637.987429]   [<ffffffff81466da6>] tcp_send_fin+0x86/0x1a0
[ 1637.987429]   [<ffffffff814573c0>] tcp_close+0x3f0/0x4b0
[ 1637.987429]   [<ffffffff81478dd2>] inet_release+0x42/0x70
[ 1637.987429]   [<ffffffff8141b2d4>] sock_release+0x24/0x90
[ 1637.987429]   [<ffffffff814d8fd8>] xs_reset_transport+0xb8/0xd0
[ 1637.987429]   [<ffffffff814d900d>] xs_close+0x1d/0x60
[ 1637.987429]   [<ffffffff814d9082>] xs_destroy+0x32/0xa0
[ 1637.987429]   [<ffffffff814d69be>] xprt_destroy+0x6e/0x90
[ 1637.987429]   [<ffffffff8126ed77>] kref_put+0x37/0x70
[ 1637.987429]   [<ffffffff814d6940>] xprt_put+0x10/0x20
[ 1637.987429]   [<ffffffff814d5e2b>] rpc_free_client+0x8b/0x100
[ 1637.987429]   [<ffffffff8126ed77>] kref_put+0x37/0x70
[ 1637.987429]   [<ffffffff814d5ee1>] rpc_free_auth+0x41/0x70
[ 1637.987429]   [<ffffffff8126ed77>] kref_put+0x37/0x70
[ 1637.987429]   [<ffffffff814d5d5e>] rpc_release_client+0x2e/0x70
[ 1637.987429]   [<ffffffff814d5f5c>] rpc_shutdown_client+0x4c/0xf0
[ 1637.987429]   [<ffffffff814e52b1>] rpcb_getport_sync+0xa1/0xf0
[ 1637.987429]   [<ffffffff81814f5f>] nfs_root_data+0x3a9/0x40a
[ 1637.987429]   [<ffffffff817f63ae>] mount_root+0x1f/0x141
[ 1637.987429]   [<ffffffff817f65c8>] prepare_namespace+0xf8/0x190
[ 1637.987429]   [<ffffffff817f5728>] kernel_init+0x1b5/0x1d2
[ 1637.987429]   [<ffffffff8100d0ca>] child_rip+0xa/0x20
[ 1637.987429]   [<ffffffffffffffff>] 0xffffffffffffffff
[ 1637.987429] irq event stamp: 285158
[ 1637.987429] hardirqs last  enabled at (285157): [<ffffffff81544cff>] _spin_unlock_irqrestore+0x3f/0x70
[ 1637.987429] hardirqs last disabled at (285156): [<ffffffff8154506d>] _spin_lock_irqsave+0x2d/0x90
[ 1637.987429] softirqs last  enabled at (285152): [<ffffffff814d7f8f>] xprt_transmit+0x1bf/0x2d0
[ 1637.987429] softirqs last disabled at (285158): [<ffffffff81544f67>] _spin_lock_bh+0x17/0x70
[ 1637.987429]
[ 1637.987429] other info that might help us debug this:
[ 1637.987429] no locks held by kswapd0/387.
[ 1637.987429]
[ 1637.987429] stack backtrace:
[ 1637.987429] Pid: 387, comm: kswapd0 Not tainted 2.6.30-rc8-mm1 #299
[ 1637.987429] Call Trace:
[ 1637.987429]  [<ffffffff810793bc>] print_usage_bug+0x18c/0x1f0
[ 1638.251441]  [<ffffffff810798bf>] mark_lock+0x49f/0x690
[ 1638.259418]  [<ffffffff8107a310>] ? check_usage_forwards+0x0/0xc0
[ 1638.267420]  [<ffffffff8107b039>] __lock_acquire+0x289/0x1b40
[ 1638.267420]  [<ffffffff810127f0>] ? native_sched_clock+0x20/0x80
[ 1638.277673]  [<ffffffff8107c9d1>] lock_acquire+0xe1/0x120
[ 1638.277673]  [<ffffffff81458972>] ? tcp_sendmsg+0x22/0xbc0
[ 1638.287418]  [<ffffffff8141d9b5>] lock_sock_nested+0x105/0x120
[ 1638.287418]  [<ffffffff81458972>] ? tcp_sendmsg+0x22/0xbc0
[ 1638.287418]  [<ffffffff810127f0>] ? native_sched_clock+0x20/0x80
[ 1638.287418]  [<ffffffff81458972>] tcp_sendmsg+0x22/0xbc0
[ 1638.287418]  [<ffffffff81077944>] ? find_usage_forwards+0x94/0xd0
[ 1638.287418]  [<ffffffff81077944>] ? find_usage_forwards+0x94/0xd0
[ 1638.287418]  [<ffffffff8141ad2f>] sock_sendmsg+0xdf/0x110
[ 1638.287418]  [<ffffffff81077944>] ? find_usage_forwards+0x94/0xd0
[ 1638.287418]  [<ffffffff81066ae0>] ? autoremove_wake_function+0x0/0x40
[ 1638.287418]  [<ffffffff8107a36e>] ? check_usage_forwards+0x5e/0xc0
[ 1638.287418]  [<ffffffff8107966e>] ? mark_lock+0x24e/0x690
[ 1638.287418]  [<ffffffff8141b0b4>] kernel_sendmsg+0x34/0x50
[ 1638.287418]  [<ffffffff814d9234>] xs_send_kvec+0x94/0xa0
[ 1638.287418]  [<ffffffff81079e55>] ? trace_hardirqs_on_caller+0x155/0x1a0
[ 1638.287418]  [<ffffffff814d92bd>] xs_sendpages+0x7d/0x220
[ 1638.287418]  [<ffffffff814d95b9>] xs_tcp_send_request+0x59/0x190
[ 1638.287418]  [<ffffffff814d7e4e>] xprt_transmit+0x7e/0x2d0
[ 1638.287418]  [<ffffffff814d4eb8>] call_transmit+0x1c8/0x2a0
[ 1638.287418]  [<ffffffff814dccb2>] __rpc_execute+0xb2/0x2b0
[ 1638.287418]  [<ffffffff814dced8>] rpc_execute+0x28/0x30
[ 1638.403414]  [<ffffffff814d5b5b>] rpc_run_task+0x3b/0x80
[ 1638.403414]  [<ffffffff811c7b6d>] nfs_write_rpcsetup+0x1ad/0x250
[ 1638.403414]  [<ffffffff811c9b69>] nfs_flush_one+0xb9/0x100
[ 1638.419417]  [<ffffffff811c3f82>] nfs_pageio_doio+0x32/0x70
[ 1638.419417]  [<ffffffff811c3fc9>] nfs_pageio_complete+0x9/0x10
[ 1638.427413]  [<ffffffff811c7ee5>] nfs_writepage_locked+0x85/0xc0
[ 1638.435414]  [<ffffffff811c9ab0>] ? nfs_flush_one+0x0/0x100
[ 1638.435414]  [<ffffffff81079e55>] ? trace_hardirqs_on_caller+0x155/0x1a0
[ 1638.435414]  [<ffffffff811c8509>] nfs_writepage+0x19/0x40
[ 1638.435414]  [<ffffffff810ce005>] shrink_page_list+0x675/0x810
[ 1638.435414]  [<ffffffff810127f0>] ? native_sched_clock+0x20/0x80
[ 1638.435414]  [<ffffffff810ce761>] shrink_list+0x301/0x650
[ 1638.435414]  [<ffffffff810ced23>] shrink_zone+0x273/0x370
[ 1638.435414]  [<ffffffff810cf9f9>] kswapd+0x729/0x7a0
[ 1638.435414]  [<ffffffff810cca80>] ? isolate_pages_global+0x0/0x250
[ 1638.435414]  [<ffffffff81066ae0>] ? autoremove_wake_function+0x0/0x40
[ 1638.435414]  [<ffffffff810cf2d0>] ? kswapd+0x0/0x7a0
[ 1638.435414]  [<ffffffff810666de>] kthread+0x9e/0xb0
[ 1638.435414]  [<ffffffff8100d0ca>] child_rip+0xa/0x20
[ 1638.435414]  [<ffffffff8100ca90>] ? restore_args+0x0/0x30
[ 1638.435414]  [<ffffffff81066640>] ? kthread+0x0/0xb0
[ 1638.435414]  [<ffffffff8100d0c0>] ? child_rip+0x0/0x20

From: David Howells <dhowells@redhat.com>
Subject: nfs_access_cache_shrinker() is missing an unlock
Date: Wed, 26 May 2010 13:22:54 +0100
Message-ID: <2068.1274876574@redhat.com>
Cc: dhowells@redhat.com, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45806 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753578Ab0EZMXj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 May 2010 08:23:39 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi Trond,

nfs_access_cache_shrinker() incurs the attached lockdep warning and then locks
up.

Specifically, the problem appears to be the:

		spin_lock(&inode->i_lock);

in the loop, for which there's not an unlock.  Nor is there an unlock in
nfs_access_free_list() or nfs_access_free_entry.

Is the spin_unlock() supposed to occur at the end of the loop, just before the
closing brace?  Or did you mean to defer the unlock to nfs_access_free_entry()?

David
---
=============================================
[ INFO: possible recursive locking detected ]
2.6.34-cachefs #100
---------------------------------------------
kswapd0/328 is trying to acquire lock:
 (&sb->s_type->i_lock_key#13){+.+.-.}, at: [<ffffffffa0092717>] nfs_access_cache_shrinker+0x6e/0x1c3 [nfs]

but task is already holding lock:
 (&sb->s_type->i_lock_key#13){+.+.-.}, at: [<ffffffffa0092717>] nfs_access_cache_shrinker+0x6e/0x1c3 [nfs]

other info that might help us debug this:
3 locks held by kswapd0/328:
 #0:  (shrinker_rwsem){++++..}, at: [<ffffffff81092b48>] shrink_slab+0x38/0x157
 #1:  (nfs_access_lru_lock){+.+.-.}, at: [<ffffffffa00926ef>] nfs_access_cache_shrinker+0x46/0x1c3 [nfs]
 #2:  (&sb->s_type->i_lock_key#13){+.+.-.}, at: [<ffffffffa0092717>] nfs_access_cache_shrinker+0x6e/0x1c3 [nfs]

stack backtrace:
Pid: 328, comm: kswapd0 Not tainted 2.6.34-cachefs #100
Call Trace:
 [<ffffffff81054e80>] validate_chain+0x584/0xd23
 [<ffffffff8108c95b>] ? free_pages+0x32/0x34
 [<ffffffff81055ea8>] __lock_acquire+0x889/0x8fa
 [<ffffffff81055ea8>] ? __lock_acquire+0x889/0x8fa
 [<ffffffff81055f70>] lock_acquire+0x57/0x6d
 [<ffffffffa0092717>] ? nfs_access_cache_shrinker+0x6e/0x1c3 [nfs]
 [<ffffffff813e2350>] _raw_spin_lock+0x2c/0x3b
 [<ffffffffa0092717>] ? nfs_access_cache_shrinker+0x6e/0x1c3 [nfs]
 [<ffffffffa0092717>] nfs_access_cache_shrinker+0x6e/0x1c3 [nfs]
 [<ffffffff81092be3>] shrink_slab+0xd3/0x157
 [<ffffffff81092fd2>] balance_pgdat+0x36b/0x5d1
 [<ffffffff810933ed>] kswapd+0x1b5/0x1cb
 [<ffffffff81045fcd>] ? autoremove_wake_function+0x0/0x34
 [<ffffffff81093238>] ? kswapd+0x0/0x1cb
 [<ffffffff81045be7>] kthread+0x7a/0x82
 [<ffffffff81002cd4>] kernel_thread_helper+0x4/0x10
 [<ffffffff813e2c3c>] ? restore_args+0x0/0x30
 [<ffffffff81045b6d>] ? kthread+0x0/0x82
 [<ffffffff81002cd0>] ? kernel_thread_helper+0x0/0x10
BUG: soft lockup - CPU#1 stuck for 61s! [exe:6253]
Modules linked in: cachefiles nfs fscache auth_rpcgss nfs_acl lockd sunrpc
irq event stamp: 300
hardirqs last  enabled at (299): [<ffffffff813e295e>] _raw_spin_unlock_irqrestore+0x3a/0x41
hardirqs last disabled at (300): [<ffffffff813e23c0>] _raw_spin_lock_irq+0x12/0x41
softirqs last  enabled at (296): [<ffffffffa0007ab3>] __rpc_execute+0xb4/0x236 [sunrpc]
softirqs last disabled at (294): [<ffffffff813e2517>] _raw_spin_lock_bh+0x11/0x40
CPU 1 
Modules linked in: cachefiles nfs fscache auth_rpcgss nfs_acl lockd sunrpc

Pid: 6253, comm: exe Not tainted 2.6.34-cachefs #100 DG965RY/        
RIP: 0010:[<ffffffff811f566a>]  [<ffffffff811f566a>] delay_tsc+0x14/0x5a
RSP: 0018:ffff880000dbfab0  EFLAGS: 00000202
RAX: 00000000bc560d39 RBX: ffff880000dbfab0 RCX: 0000000000009b00
RDX: 00000000000001c0 RSI: 0000000000000001 RDI: 0000000000000001
RBP: ffffffff8100288e R08: 0000000000000002 R09: 0000000000000000
R10: ffffffffa00926ef R11: 0000000000000000 R12: 0000000000000000
R13: 00000000000001c0 R14: ffff880000dbe000 R15: ffffffff8162a4d0
FS:  00007f8ac983c700(0000) GS:ffff880002100000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00007f8ac9358b30 CR3: 000000002d4c7000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process exe (pid: 6253, threadinfo ffff880000dbe000, task ffff88001c2ef050)
Stack:
 ffff880000dbfac0 ffffffff811f55a5 ffff880000dbfb10 ffffffff811f9a7a
<0> ffff880000dbfb10 0000000000000001 0000000000000000 ffffffffa00bfe90
<0> 0000000000000000 0000000000000000 0000000000000000 ffff880000dbfb50
Call Trace:
 [<ffffffff811f55a5>] ? __delay+0xa/0xc
 [<ffffffff811f9a7a>] ? do_raw_spin_lock+0xd2/0x13c
 [<ffffffff813e2358>] ? _raw_spin_lock+0x34/0x3b
 [<ffffffffa00926ef>] ? nfs_access_cache_shrinker+0x46/0x1c3 [nfs]
 [<ffffffffa00926ef>] ? nfs_access_cache_shrinker+0x46/0x1c3 [nfs]
 [<ffffffff81092b76>] ? shrink_slab+0x66/0x157
 [<ffffffff81093611>] ? do_try_to_free_pages+0x20e/0x337
 [<ffffffff81093847>] ? try_to_free_pages+0x62/0x64
 [<ffffffff8108d4f2>] ? __alloc_pages_nodemask+0x415/0x63f
 [<ffffffff8108d72e>] ? __get_free_pages+0x12/0x4f
 [<ffffffff8102f169>] ? copy_process+0xd4/0x1125
 [<ffffffff810492c4>] ? up_read+0x1e/0x36
 [<ffffffff8103031f>] ? do_fork+0x165/0x303
 [<ffffffff813e21ee>] ? lockdep_sys_exit_thunk+0x35/0x67
 [<ffffffff810098a5>] ? sys_clone+0x23/0x25
 [<ffffffff81002213>] ? stub_clone+0x13/0x20
 [<ffffffff81001eab>] ? system_call_fastpath+0x16/0x1b
Code: 81 48 6b 94 0a 98 00 00 00 3e f7 e2 48 8d 7a 01 e8 47 ff ff ff c9 c3 55 48 89 e5 65 8b 34 25 68 d3 00 00 0f 1f 00 0f ae e8 0f 31 <89> c1 0f 1f 00 0f ae e8 0f 31 89 c0 48 89 c2 48 29 ca 48 39 fa 
Call Trace:
 [<ffffffff811f55a5>] ? __delay+0xa/0xc
 [<ffffffff811f9a7a>] ? do_raw_spin_lock+0xd2/0x13c
 [<ffffffff813e2358>] ? _raw_spin_lock+0x34/0x3b
 [<ffffffffa00926ef>] ? nfs_access_cache_shrinker+0x46/0x1c3 [nfs]
 [<ffffffffa00926ef>] ? nfs_access_cache_shrinker+0x46/0x1c3 [nfs]
 [<ffffffff81092b76>] ? shrink_slab+0x66/0x157
 [<ffffffff81093611>] ? do_try_to_free_pages+0x20e/0x337
 [<ffffffff81093847>] ? try_to_free_pages+0x62/0x64
 [<ffffffff8108d4f2>] ? __alloc_pages_nodemask+0x415/0x63f
 [<ffffffff8108d72e>] ? __get_free_pages+0x12/0x4f
 [<ffffffff8102f169>] ? copy_process+0xd4/0x1125
 [<ffffffff810492c4>] ? up_read+0x1e/0x36
 [<ffffffff8103031f>] ? do_fork+0x165/0x303
 [<ffffffff813e21ee>] ? lockdep_sys_exit_thunk+0x35/0x67
 [<ffffffff810098a5>] ? sys_clone+0x23/0x25
 [<ffffffff81002213>] ? stub_clone+0x13/0x20
 [<ffffffff81001eab>] ? system_call_fastpath+0x16/0x1b

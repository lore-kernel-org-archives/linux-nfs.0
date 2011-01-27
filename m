Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:20683 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751967Ab1A0UAa convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Jan 2011 15:00:30 -0500
Subject: Re: 2.6.38-rc2 NFS client lockdep splat
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
In-Reply-To: <E4B1CD0A-A45D-4D16-904A-13FCADB20721@oracle.com>
References: <E4B1CD0A-A45D-4D16-904A-13FCADB20721@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 27 Jan 2011 15:00:26 -0500
Message-ID: <1296158426.2965.62.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-01-27 at 14:45 -0500, Chuck Lever wrote: 
> Jan 27 14:33:04 matisse kernel:
> Jan 27 14:33:04 matisse kernel: =================================
> Jan 27 14:33:04 matisse kernel: [ INFO: inconsistent lock state ]
> Jan 27 14:33:04 matisse kernel: 2.6.38-rc2-00025-gce531fd #10
> Jan 27 14:33:04 matisse kernel: ---------------------------------
> Jan 27 14:33:04 matisse kernel: inconsistent {SOFTIRQ-ON-W} -> {IN-SOFTIRQ-W} usage.
> Jan 27 14:33:04 matisse kernel: swapper/0 [HC0[0]:SC1[1]:HE1:SE0] takes:
> Jan 27 14:33:04 matisse kernel: (rpc_credcache_lock){+.?...}, at: [<ffffffff8122318d>] _atomic_dec_and_lock+0x2d/0x4c
> Jan 27 14:33:04 matisse kernel: {SOFTIRQ-ON-W} state was registered at:
> Jan 27 14:33:04 matisse kernel:  [<ffffffff8107d4d9>] __lock_acquire+0x341/0xd0b
> Jan 27 14:33:04 matisse kernel:  [<ffffffff8107df86>] lock_acquire+0xe3/0x110
> Jan 27 14:33:04 matisse kernel:  [<ffffffff8147860f>] _raw_spin_lock+0x31/0x40
> Jan 27 14:33:04 matisse kernel:  [<ffffffff8122318d>] _atomic_dec_and_lock+0x2d/0x4c
> Jan 27 14:33:04 matisse kernel:  [<ffffffffa029ac37>] put_rpccred+0x41/0x130 [sunrpc]
> Jan 27 14:33:04 matisse kernel:  [<ffffffffa0295186>] xprt_release+0xde/0x182 [sunrpc]
> Jan 27 14:33:04 matisse kernel:  [<ffffffffa02994f6>] rpc_put_task+0x2b/0xad [sunrpc]Jan 27 14:33:04 matisse kernel:  [<ffffffffa0293e17>] rpc_call_sync+0x5c/0x65 [sunrpc]
> Jan 27 14:33:04 matisse kernel:  [<ffffffffa02a22a1>] rpcb_register_call+0x20/0x55 [sunrpc]Jan 27 14:33:04 matisse kernel:  [<ffffffffa02a2389>] rpcb_v4_register+0xb3/0x170 [sunrpc]
> Jan 27 14:33:04 matisse kernel:  [<ffffffffa029c9bd>] svc_unregister+0x5b/0xef [sunrpc]Jan 27 14:33:04 matisse kernel:  [<ffffffffa029cec3>] __svc_create+0x1eb/0x1fb [sunrpc]
> Jan 27 14:33:04 matisse kernel:  [<ffffffffa029d120>] svc_create+0x16/0x18 [sunrpc]Jan 27 14:33:04 matisse kernel:  [<ffffffffa03574fb>] nfs_callback_up+0x92/0x1ed [nfs]
> Jan 27 14:33:04 matisse kernel:  [<ffffffffa032c7ff>] nfs4_set_client+0x1a2/0x271 [nfs]
> Jan 27 14:33:04 matisse kernel:  [<ffffffffa032ce67>] nfs4_create_server+0xf7/0x20d [nfs]
> Jan 27 14:33:04 matisse kernel:  [<ffffffffa0335beb>] nfs4_remote_mount+0x7d/0x1e6 [nfs]
> Jan 27 14:33:04 matisse kernel:  [<ffffffff8111f7e9>] vfs_kern_mount+0xbd/0x1d9
> Jan 27 14:33:04 matisse kernel:  [<ffffffffa0335fc0>] nfs_do_root_mount+0x7b/0x9a [nfs]
> Jan 27 14:33:04 matisse kernel:  [<ffffffffa03363b2>] nfs4_try_mount+0x5b/0xb4 [nfs]
> Jan 27 14:33:04 matisse kernel:  [<ffffffffa033762d>] nfs_get_sb+0x4c5/0x730 [nfs]
> Jan 27 14:33:04 matisse kernel:  [<ffffffff8111f81b>] vfs_kern_mount+0xef/0x1d9
> Jan 27 14:33:04 matisse kernel:  [<ffffffff8111f96d>] do_kern_mount+0x4d/0xdd
> Jan 27 14:33:04 matisse kernel:  [<ffffffff811374a1>] do_mount+0x72f/0x797
> Jan 27 14:33:04 matisse kernel:  [<ffffffff81137591>] sys_mount+0x88/0xc2
> Jan 27 14:33:04 matisse kernel:  [<ffffffff8100abc2>] system_call_fastpath+0x16/0x1bJan 27 14:33:04 matisse kernel: irq event stamp: 2544680
> Jan 27 14:33:04 matisse kernel: hardirqs last  enabled at (2544680): [<ffffffff81110169>] kmem_cache_free+0xb0/0xfc
> Jan 27 14:33:04 matisse kernel: hardirqs last disabled at (2544679): [<ffffffff811100fa>] kmem_cache_free+0x41/0xfc
> Jan 27 14:33:04 matisse kernel: softirqs last  enabled at (2544654): [<ffffffff81056166>] _local_bh_enable+0x13/0x15
> Jan 27 14:33:04 matisse kernel: softirqs last disabled at (2544655): [<ffffffff8100bb5c>] call_softirq+0x1c/0x30
> Jan 27 14:33:04 matisse kernel:
> Jan 27 14:33:04 matisse kernel: other info that might help us debug this:
> Jan 27 14:33:04 matisse kernel: no locks held by swapper/0.
> Jan 27 14:33:04 matisse kernel:
> Jan 27 14:33:04 matisse kernel: stack backtrace:
> Jan 27 14:33:04 matisse kernel: Pid: 0, comm: swapper Not tainted 2.6.38-rc2-00025-gce531fd #10
> Jan 27 14:33:04 matisse kernel: Call Trace:
> Jan 27 14:33:04 matisse kernel: <IRQ>  [<ffffffff8107bfc4>] ? valid_state+0x17f/0x192
> Jan 27 14:33:04 matisse kernel: [<ffffffff81016716>] ? save_stack_trace+0x2d/0x4a
> Jan 27 14:33:04 matisse kernel: [<ffffffff8107c8b1>] ? check_usage_forwards+0x0/0x87
> Jan 27 14:33:04 matisse kernel: [<ffffffff8107c0f1>] ? mark_lock+0x11a/0x235
> Jan 27 14:33:04 matisse kernel: [<ffffffff8107d465>] ? __lock_acquire+0x2cd/0xd0b
> Jan 27 14:33:04 matisse kernel: [<ffffffff8110daae>] ? add_partial+0x20/0x58
> Jan 27 14:33:04 matisse kernel: [<ffffffff8107df86>] ? lock_acquire+0xe3/0x110
> Jan 27 14:33:04 matisse kernel: [<ffffffff8122318d>] ? _atomic_dec_and_lock+0x2d/0x4c
> Jan 27 14:33:04 matisse kernel: [<ffffffff8110f3fe>] ? free_debug_processing+0x16a/0x193
> Jan 27 14:33:04 matisse kernel: [<ffffffff8147860f>] ? _raw_spin_lock+0x31/0x40
> Jan 27 14:33:04 matisse kernel: [<ffffffff8122318d>] ? _atomic_dec_and_lock+0x2d/0x4c
> Jan 27 14:33:04 matisse kernel: [<ffffffff8122318d>] ? _atomic_dec_and_lock+0x2d/0x4c
> Jan 27 14:33:04 matisse kernel: [<ffffffffa029ac37>] ? put_rpccred+0x41/0x130 [sunrpc]
> Jan 27 14:33:04 matisse kernel: [<ffffffffa0355a3f>] ? nfs_free_delegation_callback+0x23/0x30 [nfs]
> Jan 27 14:33:04 matisse kernel: [<ffffffff810abbf8>] ? __rcu_process_callbacks+0x1b1/0x2ef
> Jan 27 14:33:04 matisse kernel: [<ffffffff810abd61>] ? rcu_process_callbacks+0x2b/0xb3
> Jan 27 14:33:04 matisse kernel: [<ffffffff81056062>] ? __do_softirq+0xe2/0x1d3
> Jan 27 14:33:04 matisse kernel: [<ffffffff810785f6>] ? tick_program_event+0x1f/0x21
> Jan 27 14:33:04 matisse kernel: [<ffffffff8100bb5c>] ? call_softirq+0x1c/0x30
> Jan 27 14:33:04 matisse kernel: [<ffffffff8100d1b3>] ? do_softirq+0x4b/0xa3
> Jan 27 14:33:04 matisse kernel: [<ffffffff81055dbc>] ? irq_exit+0x4a/0x8c
> Jan 27 14:33:04 matisse kernel: [<ffffffff8147f9a1>] ? smp_apic_timer_interrupt+0x8d/0x9b
> Jan 27 14:33:04 matisse kernel: [<ffffffff8100b613>] ? apic_timer_interrupt+0x13/0x20
> Jan 27 14:33:04 matisse kernel: <EOI>  [<ffffffff8102c6c1>] ? native_safe_halt+0xb/0xd
> Jan 27 14:33:04 matisse kernel: [<ffffffff8107c50f>] ? trace_hardirqs_on+0xd/0xf
> Jan 27 14:33:04 matisse kernel: [<ffffffff81012708>] ? default_idle+0x55/0x94
> Jan 27 14:33:04 matisse kernel: [<ffffffff81009e50>] ? cpu_idle+0xb7/0xed
> Jan 27 14:33:04 matisse kernel: [<ffffffff8145f723>] ? rest_init+0xb7/0xbe
> Jan 27 14:33:04 matisse kernel: [<ffffffff8145f66c>] ? rest_init+0x0/0xbe
> Jan 27 14:33:04 matisse kernel: [<ffffffff81b67df6>] ? start_kernel+0x41b/0x426
> Jan 27 14:33:04 matisse kernel: [<ffffffff81b672cd>] ? x86_64_start_reservations+0xb8/0xbc
> Jan 27 14:33:04 matisse kernel: [<ffffffff81b673d7>] ? x86_64_start_kernel+0x106/0x115

The following patch ought to fix it.

Cheers
  Trond

8<--------------------------------------------------------------------------------------- 

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from scorn.kernelslacker.org ([45.56.101.199]:34500 "EHLO
        scorn.kernelslacker.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751766AbdJYCXG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Oct 2017 22:23:06 -0400
Date: Tue, 24 Oct 2017 22:23:03 -0400
From: Dave Jones <davej@codemonkey.org.uk>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org,
        Linux Kernel <linux-kernel@vger.kernel.org>
Subject: [4.14rc6] suspicious nfs rcu dereference
Message-ID: <20171025022303.qfyafixsfacvfruh@codemonkey.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

WARNING: suspicious RCU usage
4.14.0-rc6-think+ #2 Not tainted
-----------------------------
net/sunrpc/clnt.c:1206 suspicious rcu_dereference_check() usage!

other info that might help us debug this:


rcu_scheduler_active = 2, debug_locks = 1
2 locks held by kworker/2:0/9104:
 #0: 
 (
"rpciod"
){+.+.}
, at: [<ffffffff8110102e>] process_one_work+0x66e/0xea0
 #1: 
 (
(&task->u.tk_work)
){+.+.}
, at: [<ffffffff8110102e>] process_one_work+0x66e/0xea0

stack backtrace:
CPU: 2 PID: 9104 Comm: kworker/2:0 Not tainted 4.14.0-rc6-think+ #2 
Workqueue: rpciod rpc_async_schedule [sunrpc]
Call Trace:
 dump_stack+0xbc/0x145
 ? dma_virt_map_sg+0xfb/0xfb
 ? lockdep_rcu_suspicious+0xda/0x100
 rpc_peeraddr2str+0x11a/0x130 [sunrpc]
 ? call_start+0x1e0/0x1e0 [sunrpc]
 perf_trace_nfs4_clientid_event+0xde/0x420 [nfsv4]
 ? do_raw_spin_unlock+0x147/0x220
 ? save_trace+0x1c0/0x1c0
 ? perf_trace_nfs4_open_event+0x5f0/0x5f0 [nfsv4]
 ? nfs41_sequence_process+0xba/0x5a0 [nfsv4]
 ? _raw_spin_unlock+0x24/0x30
 ? nfs41_sequence_free_slot.isra.47+0x143/0x230 [nfsv4]
 ? __lock_is_held+0x51/0xd0
 nfs41_sequence_call_done+0x29a/0x430 [nfsv4]
 ? perf_trace_nfs4_open_event+0x5f0/0x5f0 [nfsv4]
 ? nfs4_proc_unlink_done+0xb0/0xb0 [nfsv4]
 ? __internal_add_timer+0x11b/0x170
 ? call_connect_status+0x490/0x490 [sunrpc]
 ? __lock_is_held+0x51/0xd0
 ? call_decode+0x33f/0xdd0 [sunrpc]
 ? nfs4_proc_unlink_done+0xb0/0xb0 [nfsv4]
 ? rpc_make_runnable+0x180/0x180 [sunrpc]
 rpc_exit_task+0x61/0x100 [sunrpc]
 ? rpc_make_runnable+0x180/0x180 [sunrpc]
 __rpc_execute+0x1c8/0x9e0 [sunrpc]
 ? rpc_wake_up_queued_task+0x40/0x40 [sunrpc]
 ? lock_downgrade+0x310/0x310
 ? match_held_lock+0xa6/0x410
 ? sched_clock_cpu+0x14/0xf0
 ? sched_clock_cpu+0x14/0xf0
 ? save_trace+0x1c0/0x1c0
 ? lock_acquire+0x12e/0x350
 ? lock_acquire+0x12e/0x350
 ? process_one_work+0x66e/0xea0
 ? lock_release+0x890/0x890
 ? do_raw_spin_trylock+0x100/0x100
 ? __lock_is_held+0x51/0xd0
 process_one_work+0x766/0xea0
 ? pwq_dec_nr_in_flight+0x1e0/0x1e0
 ? preempt_notifier_dec+0x20/0x20
 ? __schedule+0x5cc/0x1310
 ? __sched_text_start+0x8/0x8
 ? match_held_lock+0x93/0x410
 ? save_trace+0x1c0/0x1c0
 ? native_sched_clock+0xf9/0x1a0
 ? cyc2ns_read_end+0x10/0x10
 ? cyc2ns_read_end+0x10/0x10
 ? find_held_lock+0x74/0xd0
 ? lock_contended+0x790/0x790
 ? lock_release+0x890/0x890
 ? do_raw_spin_unlock+0x147/0x220
 ? do_raw_spin_trylock+0x100/0x100
 ? retint_kernel+0x10/0x10
 ? do_raw_spin_trylock+0xb3/0x100
 ? do_raw_spin_lock+0x110/0x110
 ? mark_held_locks+0x1b/0xa0
 worker_thread+0x1cf/0xcf0
 ? do_raw_spin_unlock+0x147/0x220
 ? do_raw_spin_trylock+0x100/0x100
 ? process_one_work+0xea0/0xea0
 ? get_vtime_delta+0x13/0x80
 ? mark_held_locks+0x1b/0xa0
 ? trace_hardirqs_on_caller+0x17a/0x250
 ? _raw_spin_unlock_irq+0x29/0x40
 ? finish_task_switch+0x183/0x470
 ? finish_task_switch+0x101/0x470
 ? preempt_notifier_dec+0x20/0x20
 ? __schedule+0x5cc/0x1310
 ? try_to_wake_up+0xe7/0xbb0
 ? save_stack+0x32/0xb0
 ? kasan_kmalloc+0xa0/0xd0
 ? native_sched_clock+0xf9/0x1a0
 ? ret_from_fork+0x27/0x40
 ? sched_clock_cpu+0x14/0xf0
 ? sched_clock_cpu+0x14/0xf0
 ? lock_downgrade+0x310/0x310
 ? __schedule+0x1310/0x1310
 ? do_raw_spin_unlock+0x147/0x220
 ? do_raw_spin_trylock+0x100/0x100
 ? do_raw_spin_lock+0x110/0x110
 ? __init_waitqueue_head+0xbe/0xf0
 ? mark_held_locks+0x1b/0xa0
 ? _raw_spin_unlock_irqrestore+0x32/0x50
 ? process_one_work+0xea0/0xea0
 kthread+0x1c9/0x1f0
 ? kthread_create_on_node+0xc0/0xc0
 ret_from_fork+0x27/0x40

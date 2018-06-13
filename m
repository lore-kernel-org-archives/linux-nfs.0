Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:3694 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754535AbeFMWLr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 13 Jun 2018 18:11:47 -0400
Date: Wed, 13 Jun 2018 16:11:43 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
To: linux-nfs@vger.kernel.org,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Chuck Lever <chuck.lever@oracle.com>
Subject: NFS client deadlock in linux/master
Message-ID: <20180613221143.GA9316@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I was doing a little testing with the current linux/master (be779f03d563) in
my VM which uses NFS, and happened to hit the following BUG:

BUG: sleeping function called from invalid context at mm/slab.h:421
in_atomic(): 0, irqs_disabled(): 0, pid: 875, name: NFSv4 callback
1 lock held by NFSv4 callback/875:
 #0: 00000000c4c0a136 (rcu_read_lock){....}, at: nfs_delegation_find_inode+0x5/0x1d0
Preemption disabled at:
[<ffffffff8110aa14>] get_lock_stats+0x14/0x50
CPU: 9 PID: 875 Comm: NFSv4 callback Not tainted 4.17.0-11782-gbe779f03d563 #1
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.11.1-0-g0551a4be2c-prebuilt.qemu-project.org 04/01/2014
Call Trace:
 dump_stack+0x8e/0xd5
 ___might_sleep+0x185/0x260
 ? __kthread_create_on_node+0x80/0x1c0
 __might_sleep+0x4a/0x80
 kmem_cache_alloc_trace+0x1dd/0x2d0
 ? nfs4_do_reclaim+0x790/0x790
 __kthread_create_on_node+0x80/0x1c0
 kthread_create_on_node+0x46/0x70
 nfs4_schedule_state_manager+0x117/0x1b0
 nfs_async_inode_return_delegation+0x144/0x220
 nfs4_callback_recall+0x66/0x4a0
 ? decode_fh+0x5b/0xf0
 nfs4_callback_compound+0x2da/0x5e0
 svc_process_common+0x6fb/0x830
 bc_svc_process+0x1ef/0x320
 nfs41_callback_svc+0x12e/0x1b0
 ? finish_wait+0x90/0x90
 kthread+0x12f/0x150
 ? nfs_map_gid_to_group+0x200/0x200
 ? kthread_create_worker_on_cpu+0x70/0x70
 ret_from_fork+0x3a/0x50
WARNING: CPU: 9 PID: 875 at kernel/rcu/tree_plugin.h:330 rcu_note_context_switch+0x72/0x6b0
Modules linked in: nd_pmem dax_pmem device_dax nd_btt nfit libnvdimm
CPU: 9 PID: 875 Comm: NFSv4 callback Tainted: G        W         4.17.0-11782-gbe779f03d563 #1
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.11.1-0-g0551a4be2c-prebuilt.qemu-project.org 04/01/2014
RIP: 0010:rcu_note_context_switch+0x72/0x6b0
Code: 00 85 ff 74 0e 8b b3 fc 08 00 00 85 f6 0f 84 45 02 00 00 45 84 e4 8b 83 68 03 00 00 0f 85 1c 01 00 00 85 c0 0f 8e 1c 01 00 00 <0f> 0b 80 bb 6c 03 00 00 00 0f 84 54 02 00 00 e8 da 90 ff ff e8 15
RSP: 0018:ffffc90000f3b8f8 EFLAGS: 00010002
RAX: 0000000000000001 RBX: ffff88010b835280 RCX: 0000000000000000
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000001
RBP: ffffc90000f3b938 R08: 0000000000000001 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
R13: ffff88010b835280 R14: ffff88010b835910 R15: ffffc90000f3bb50
FS:  0000000000000000(0000) GS:ffff880115600000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f0abf6be800 CR3: 00000000bb48e000 CR4: 00000000000006e0
Call Trace:
 ? wait_for_completion_killable+0x106/0x1f0
 __schedule+0xc1/0xad0
 ? wait_for_completion_killable+0x106/0x1f0
 schedule+0x36/0x90
 schedule_timeout+0x251/0x5c0
 ? _raw_spin_unlock_irq+0x2c/0x60
 ? wait_for_completion_killable+0x106/0x1f0
 ? trace_hardirqs_on_caller+0xf4/0x190
 ? wait_for_completion_killable+0x106/0x1f0
 wait_for_completion_killable+0x12e/0x1f0
 ? wake_up_q+0x80/0x80
 __kthread_create_on_node+0xf9/0x1c0
 ? complete+0x1d/0x60
 kthread_create_on_node+0x46/0x70
 nfs4_schedule_state_manager+0x117/0x1b0
 nfs_async_inode_return_delegation+0x144/0x220
 nfs4_callback_recall+0x66/0x4a0
 ? decode_fh+0x5b/0xf0
 nfs4_callback_compound+0x2da/0x5e0
 svc_process_common+0x6fb/0x830
 bc_svc_process+0x1ef/0x320
 nfs41_callback_svc+0x12e/0x1b0
 ? finish_wait+0x90/0x90
 kthread+0x12f/0x150
 ? nfs_map_gid_to_group+0x200/0x200
 ? kthread_create_worker_on_cpu+0x70/0x70
 ret_from_fork+0x3a/0x50
irq event stamp: 236
hardirqs last  enabled at (235): [<ffffffff81c8804c>] _raw_spin_unlock_irq+0x2c/0x60
hardirqs last disabled at (236): [<ffffffff81c7eccc>] __schedule+0xac/0xad0
softirqs last  enabled at (230): [<ffffffff820003bf>] __do_softirq+0x3bf/0x520
softirqs last disabled at (223): [<ffffffff810ac27c>] irq_exit+0xec/0x100
---[ end trace 638e000b2028c1a4 ]---
XFS (pmem0p1): Mounting V5 Filesystem
XFS (pmem0p1): Ending clean mount
XFS (pmem0p2): DAX enabled. Warning: EXPERIMENTAL, use at your own risk
XFS (pmem0p2): Mounting V5 Filesystem
XFS (pmem0p2): Ending clean mount
INFO: rcu_preempt detected stalls on CPUs/tasks:
	Tasks blocked on level-0 rcu_node (CPUs 0-11): P875
	(detected by 9, t=65006 jiffies, g=3820, c=3819, q=39853)
NFSv4 callback  S    0   875      2 0x80000000
Call Trace:
 __schedule+0x2c5/0xad0
 ? nfs41_callback_svc+0x156/0x1b0
 schedule+0x36/0x90
 nfs41_callback_svc+0x19b/0x1b0
 ? finish_wait+0x90/0x90
 kthread+0x12f/0x150
 ? nfs_map_gid_to_group+0x200/0x200
 ? kthread_create_worker_on_cpu+0x70/0x70
 ret_from_fork+0x3a/0x50
NFSv4 callback  S    0   875      2 0x80000000
Call Trace:
 __schedule+0x2c5/0xad0
 ? nfs41_callback_svc+0x156/0x1b0
 schedule+0x36/0x90
 nfs41_callback_svc+0x19b/0x1b0
 ? finish_wait+0x90/0x90
 kthread+0x12f/0x150
 ? nfs_map_gid_to_group+0x200/0x200
 ? kthread_create_worker_on_cpu+0x70/0x70
 ret_from_fork+0x3a/0x50

After this the system deadlocked, with the following stuck task popping up in
response to a 'w' thrown at /proc/sysrq-trigger:

[  178.751722] sysrq: SysRq : Show Blocked State
[  178.753489]   task                        PC stack   pid father
[  178.754920] umount          D    0  3326   3322 0x00000000
[  178.756542] Call Trace:
[  178.757183]  __schedule+0x2c5/0xad0
[  178.758088]  ? wait_for_completion+0x109/0x1a0
[  178.759293]  schedule+0x36/0x90
[  178.760104]  schedule_timeout+0x251/0x5c0
[  178.761219]  ? wait_for_completion+0x129/0x1a0
[  178.762414]  ? trace_hardirqs_on_caller+0xf4/0x190
[  178.763506]  ? wait_for_completion+0x109/0x1a0
[  178.763970]  wait_for_completion+0x131/0x1a0
[  178.764581]  ? wake_up_q+0x80/0x80
[  178.765052]  __wait_rcu_gp+0x144/0x180
[  178.765570]  synchronize_rcu.part.59+0x41/0x60
[  178.766137]  ? kfree_call_rcu+0x30/0x30
[  178.766609]  ? __bpf_trace_rcu_utilization+0x10/0x10
[  178.767277]  ? wait_for_completion+0x47/0x1a0
[  178.767831]  synchronize_rcu+0x2c/0xa0
[  178.768311]  namespace_unlock+0x6a/0x80
[  178.768899]  ksys_umount+0x2b7/0x4c0
[  178.769406]  __x64_sys_umount+0x16/0x20
[  178.769871]  do_syscall_64+0x65/0x220
[  178.770350]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
[  178.770958] RIP: 0033:0x7feb4488e1a7
[  178.771411] Code: Bad RIP value.
[  178.771810] RSP: 002b:00007ffe17c31818 EFLAGS: 00000246 ORIG_RAX: 00000000000000a6
[  178.772918] RAX: ffffffffffffffda RBX: 00005623cbd632d0 RCX: 00007feb4488e1a7
[  178.773992] RDX: 0000000000000001 RSI: 0000000000000000 RDI: 00005623cbd6b5c0
[  178.775042] RBP: 00005623cbd6b5c0 R08: 0000000000000000 R09: 00005623cbd63010
[  178.776109] R10: 0000000000000000 R11: 0000000000000246 R12: 00007feb45622184
[  178.777184] R13: 0000000000000000 R14: 00005623cbd634b0 R15: 0000000000000000

I've tried to reproduce this but so far have been unable to do so reliably,
but I was hoping that maybe the stack traces in the BUG message would be
enough to be helpful.

- Ross

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from icebox.esperi.org.uk ([81.187.191.129]:56046 "EHLO
	mail.esperi.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753284Ab3HDQZE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 4 Aug 2013 12:25:04 -0400
From: Nix <nix@esperi.org.uk>
To: NFS list <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: [3.10.4] NFS locking panic, plus persisting NFS shutdown panic from 3.9.*
Date: Sun, 04 Aug 2013 16:40:58 +0100
Message-ID: <8761vlv4z9.fsf@spindle.srvr.nix>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I just got this panic on 3.10.4, in the middle of a large parallel
compilation (of Chromium, as it happens) over NFSv3:

[16364.527516] BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
[16364.527571] IP: [<ffffffff81245157>] nlmclnt_setlockargs+0x55/0xcf
[16364.527611] PGD 0 
[16364.527626] Oops: 0000 [#1] PREEMPT SMP 
[16364.527656] Modules linked in: [last unloaded: microcode] 
[16364.527690] CPU: 0 PID: 17034 Comm: flock Not tainted 3.10.4-05315-gf4ce424-dirty #1
[16364.527730] Hardware name: System manufacturer System Product Name/P8H61-MX USB3, BIOS 0506 08/10/2012
[16364.527775] task: ffff88041a97ad60 ti: ffff8803501d4000 task.ti: ffff8803501d4000
[16364.527813] RIP: 0010:[<ffffffff81245157>] [<ffffffff81245157>] nlmclnt_setlockargs+0x55/0xcf
[16364.527860] RSP: 0018:ffff8803501d5c58  EFLAGS: 00010282
[16364.527889] RAX: ffff88041a97ad60 RBX: ffff8803e49c8800 RCX: 0000000000000000
[16364.527926] RDX: 0000000000000000 RSI: 000000000000004a RDI: ffff8803e49c8b54
[16364.527962] RBP: ffff8803501d5c68 R08: 0000000000015720 R09: 0000000000000000
[16364.527998] R10: 00007ffffffff000 R11: ffff8803501d5d58 R12: ffff8803501d5d58
[16364.528034] R13: ffff88041bd2bc00 R14: 0000000000000000 R15: ffff8803fc9e2900
[16364.528070] FS:  0000000000000000(0000) GS:ffff88042fa00000(0000) knlGS:0000000000000000
[16364.528111] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[16364.528142] CR2: 0000000000000008 CR3: 0000000001c0b000 CR4: 00000000001407f0
[16364.528177] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[16364.528214] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[16364.528303] Stack:
[16364.528316]  ffff8803501d5d58 ffff8803e49c8800 ffff8803501d5cd8 ffffffff81245418 
[16364.528369]  0000000000000000 ffff8803516f0bc0 ffff8803d7b7b6c0 ffffffff81215c81 
[16364.528418]  ffff880300000007 ffff88041bd2bdc8 ffff8801aabe9650 ffff8803fc9e2900 
[16364.528467] Call Trace:
[16364.528485]  [<ffffffff81245418>] nlmclnt_proc+0x148/0x5fb
[16364.528516]  [<ffffffff81215c81>] ? nfs_put_lock_context+0x69/0x6e
[16364.528550]  [<ffffffff812209a2>] nfs3_proc_lock+0x21/0x23
[16364.528581]  [<ffffffff812149dd>] do_unlk+0x96/0xb2
[16364.528608]  [<ffffffff81214b41>] nfs_flock+0x5a/0x71
[16364.528637]  [<ffffffff8119a747>] locks_remove_flock+0x9e/0x113
[16364.528668]  [<ffffffff8115cc68>] __fput+0xb6/0x1e6
[16364.528695]  [<ffffffff8115cda6>] ____fput+0xe/0x10
[16364.528724]  [<ffffffff810998da>] task_work_run+0x7e/0x98
[16364.528754]  [<ffffffff81082bc5>] do_exit+0x3cc/0x8fa
[16364.528782]  [<ffffffff81083501>] ? SyS_wait4+0xa5/0xc2
[16364.528811]  [<ffffffff8108328d>] do_group_exit+0x6f/0xa2
[16364.528843]  [<ffffffff810832d7>] SyS_exit_group+0x17/0x17
[16364.528876]  [<ffffffff81613e92>] system_call_fastpath+0x16/0x1b
[16364.528907] Code: 00 00 65 48 8b 04 25 c0 b8 00 00 48 8b 72 20 48 81 ee c0 01 00 00 f3 a4 48 8d bb 54 03 00 00 be 4a 00 00 00 48 8b 90 68 05 00 00 <48> 8b 52 08 48 89 bb d0 00 00 00 48 83 c2 45 48 89 53 38 48 8b 
[16364.529176] RIP [<ffffffff81245157>] nlmclnt_setlockargs+0x55/0xcf
[16364.529264]  RSP <ffff8803501d5c58>
[16364.529283] CR2: 0000000000000008
[16364.539039] ---[ end trace 5a73fddf23441377 ]---

This is the same machine on which this panic has been occurring on
shutdown since 3.9.x: Al Viro has previously pointed out the problem and
nothing has happened:

[50618.993226] BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
[50618.993904] IP: [<ffffffff81165e76>] path_init+0x11c/0x36f
[50618.994609] PGD 0 
[50618.995329] Oops: 0000 [#1] PREEMPT SMP 
[50618.996027] Modules linked in: [last unloaded: microcode] 
[50618.996758] CPU: 3 PID: 1262 Comm: pulseaudio Not tainted 3.10.4-05315-gf4ce424-dirty #1
[50618.997506] Hardware name: System manufacturer System Product Name/P8H61-MX USB3, BIOS 0506 08/10/2012
[50618.998268] task: ffff88041bf1ad60 ti: ffff88041b19e000 task.ti: ffff88041b19e000
[50618.999017] RIP: 0010:[<ffffffff81165e76>] [<ffffffff81165e76>] path_init+0x11c/0x36f
[50618.999804] RSP: 0018:ffff88041b19f508  EFLAGS: 00010246
[50619.000592] RAX: 0000000000000000 RBX: ffff88041b19f658 RCX: 000000000000005c
[50619.001398] RDX: 0000000000005c5c RSI: ffff880419b3781a RDI: ffffffff81c34a10
[50619.002198] RBP: ffff88041b19f558 R08: ffff88041b19f588 R09: ffff88041b19f7c4
[50619.002999] R10: 00000000ffffff9c R11: ffff88041b19f658 R12: 0000000000000041
[50619.003816] R13: 0000000000000040 R14: ffff880419b3781a R15: ffff88041b19f7c4
[50619.004638] FS:  00007fca19bc2740(0000) GS:ffff88042fac0000(0000) knlGS:0000000000000000
[50619.005465] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[50619.006284] CR2: 0000000000000008 CR3: 0000000001c0b000 CR4: 00000000001407e0
[50619.007092] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[50619.007922] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[50619.008750] Stack: [50619.009576]  ffff88041b19f518 00000000ffbfaa5e 0000000000000000 ffffffff8151e735 
[50619.010437]  ffffc900080ae000 ffff88041b19f658 0000000000000041 ffff880419b3781a 
[50619.011292]  ffff88041b19f628 ffff88041b19f7c4 ffff88041b19f5e8 ffffffff811660fc 
[50619.012119] Call Trace:
[50619.012947]  [<ffffffff8151e735>] ? skb_checksum+0x4f/0x25b
[50619.013782]  [<ffffffff811660fc>] path_lookupat+0x33/0x6c5
[50619.014618]  [<ffffffff8152c623>] ? dev_hard_start_xmit+0x2e5/0x50b
[50619.015457]  [<ffffffff811667b4>] filename_lookup.isra.27+0x26/0x5c
[50619.016298]  [<ffffffff8116687e>] do_path_lookup+0x33/0x35
[50619.017123]  [<ffffffff81166aac>] kern_path+0x2a/0x4d
[50619.017973]  [<ffffffff815203d8>] ? __alloc_skb+0x75/0x186
[50619.018832]  [<ffffffff81520324>] ? __kmalloc_reserve.isra.42+0x2d/0x6c
[50619.019702]  [<ffffffff815871a3>] unix_find_other+0x38/0x1b9
[50619.020568]  [<ffffffff81589043>] unix_stream_connect+0x102/0x3ed
[50619.021429]  [<ffffffff81518cbc>] ? __sock_create+0x168/0x1c0
[50619.022301]  [<ffffffff815de7e3>] ? call_refreshresult+0x91/0x91
[50619.023170]  [<ffffffff81516531>] kernel_connect+0x10/0x12
[50619.024047]  [<ffffffff815e1d36>] xs_local_setup_socket+0x122/0x191
[50619.024945]  [<ffffffff815e2f50>] xs_local_connect+0x2c/0x48
[50619.025849]  [<ffffffff815e01f6>] xprt_connect+0x112/0x11b
[50619.026756]  [<ffffffff815de81c>] call_connect+0x39/0x3b
[50619.027662]  [<ffffffff815e4e68>] __rpc_execute+0xe8/0x2ca
[50619.028567]  [<ffffffff815e5109>] rpc_execute+0x76/0x9d
[50619.029473]  [<ffffffff815debd1>] rpc_run_task+0x78/0x80
[50619.030376]  [<ffffffff815ded0f>] rpc_call_sync+0x88/0x9e
[50619.031270]  [<ffffffff815ebd2f>] rpcb_register_call+0x1f/0x2e
[50619.032143]  [<ffffffff815ec216>] rpcb_v4_register+0xb2/0x13c
[50619.033031]  [<ffffffff8108addb>] ? call_timer_fn+0x15e/0x15e
[50619.033918]  [<ffffffff815e7816>] svc_unregister.isra.11+0x5a/0xcb
[50619.034804]  [<ffffffff815e789b>] svc_rpcb_cleanup+0x14/0x21
[50619.035706]  [<ffffffff815e70ef>] svc_shutdown_net+0x2b/0x30
[50619.036586]  [<ffffffff812471c5>] lockd_down_net+0x7f/0xa3
[50619.037465]  [<ffffffff81247413>] lockd_down+0x30/0xb2
[50619.038346]  [<ffffffff8124439f>] nlmclnt_done+0x1f/0x23
[50619.039227]  [<ffffffff8120fd72>] ? nfs_start_lockd+0xc8/0xc8
[50619.040086]  [<ffffffff8120fd89>] nfs_destroy_server+0x17/0x19
[50619.040962]  [<ffffffff8121024b>] nfs_free_server+0xeb/0x15c
[50619.041947]  [<ffffffff812172c3>] nfs_kill_super+0x1f/0x23
[50619.042824]  [<ffffffff8115da33>] deactivate_locked_super+0x26/0x52
[50619.043696]  [<ffffffff8115e73d>] deactivate_super+0x42/0x47
[50619.044562]  [<ffffffff8117453e>] mntput_no_expire+0x135/0x13e
[50619.045424]  [<ffffffff81174574>] mntput+0x2d/0x2f
[50619.046287]  [<ffffffff8115cd78>] __fput+0x1c6/0x1e6
[50619.047111]  [<ffffffff8115cda6>] ____fput+0xe/0x10
[50619.047943]  [<ffffffff810998da>] task_work_run+0x7e/0x98
[50619.048764]  [<ffffffff81082bc5>] do_exit+0x3cc/0x8fa
[50619.049580]  [<ffffffff81174449>] ? mntput_no_expire+0x40/0x13e
[50619.050399]  [<ffffffff8108ca8b>] ? __dequeue_signal+0x1a/0x118
[50619.051215]  [<ffffffff8108328d>] do_group_exit+0x6f/0xa2
[50619.052000]  [<ffffffff8108f0e7>] get_signal_to_deliver+0x4f2/0x530
[50619.052797]  [<ffffffff81036a39>] do_signal+0x4d/0x4a4
[50619.053577]  [<ffffffff810f2810>] ? call_rcu+0x17/0x19
[50619.054344]  [<ffffffff81036ebc>] do_notify_resume+0x2c/0x6b
[50619.055084]  [<ffffffff81614098>] int_signal+0x12/0x17
[50619.055852] Code: c7 c7 10 4a c3 81 e8 79 c4 f3 ff e8 99 3a f3 ff 48 83 7b 20 00 0f 85 8d 00 00 00 65 48 8b 04 25 c0 b8 00 00 48 8b 80 58 05 00 00 <8b> 50 08 f6 c2 01 74 04 f3 90 eb f4 48 8b 48 18 48 89 4b 20 48 
[50619.057735] RIP [<ffffffff81165e76>] path_init+0x11c/0x36f
[50619.058586]  RSP <ffff88041b19f508>
[50619.059429] CR2: 0000000000000008

.config available on request, but it seems like I've been posting it to
l-k with various crashes too often and I don't want to be accused of
spamming!

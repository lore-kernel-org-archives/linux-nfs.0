Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fisica.ufpr.br ([200.17.209.129]:32500 "EHLO fisica.ufpr.br"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751056AbaJ1TMb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Oct 2014 15:12:31 -0400
Date: Tue, 28 Oct 2014 17:12:29 -0200
From: Carlos Carvalho <carlos@fisica.ufpr.br>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: massive memory leak in 3.1[3-5] with nfs4+kerberos
Message-ID: <20141028191229.GA30677@fisica.ufpr.br>
References: <20141011033627.GA6850@fisica.ufpr.br>
 <20141013135840.GA32584@fieldses.org>
 <20141013235026.GA10153@fisica.ufpr.br>
 <20141014204245.GB15960@fieldses.org>
 <20141028141428.GA17735@fisica.ufpr.br>
 <20141028142449.GC32743@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141028142449.GC32743@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields (bfields@fieldses.org) wrote on Tue, Oct 28, 2014 at 12:24:50PM BRST:
> On Tue, Oct 28, 2014 at 12:14:28PM -0200, Carlos Carvalho wrote:
> > J. Bruce Fields (bfields@fieldses.org) wrote on Tue, Oct 14, 2014 at 05:42:45PM BRT:
> > > On Mon, Oct 13, 2014 at 08:50:27PM -0300, Carlos Carvalho wrote:
> > > > J. Bruce Fields (bfields@fieldses.org) wrote on Mon, Oct 13, 2014 at 10:58:40AM BRT:
> > > > Note the big xprt_alloc. slabinfo is found in the kernel tree at tools/vm.
> > > > Another way to see it:
> > > > 
> > > > urquell# sort -n /sys/kernel/slab/kmalloc-2048/alloc_calls | tail -n 2
> > > >    1519 nfsd4_create_session+0x24a/0x810 age=189221/25894524/71426273 pid=5372-5436 cpus=0-11,13-16,19-20 nodes=0-1
> > > > 3380755 xprt_alloc+0x1e/0x190 age=5/27767270/71441075 pid=6-32599 cpus=0-31 nodes=0-1
> > > 
> > > Agreed that the xprt_alloc is suspicious, though I don't really
> > > understand these statistics.
> > > 
> > > Since you have 4.1 clients, maybe this would be explained by a leak in
> > > the backchannel code.
> > 
> > We've set clients to use 4.0 and it only made the problem worse; the growth in
> > unreclaimable memory was faster.
> > 
> > > It could certainly still be worth testing 3.17 if possible.
> > 
> > We tested it and it SEEMS the problem doesn't appear in 3.17.1; the SUnreclaim
> > value oscillates up and down as usual, instead of increasing monotonically.
> > However it didn't last long enough for us to get conclusive numbers because
> > after about 5-6h the machine fills the screen with "NMI watchdog CPU #... is
> > locked for more than 22s".
> 
> Are the backtraces with those messages?

First one, nfsd:

Oct 22 18:37:12 urquell kernel: NMI watchdog: BUG: soft lockup - CPU#23 stuck for 23s! [nfsd:12603]
Oct 22 18:37:12 urquell kernel: Modules linked in:
Oct 22 18:37:12 urquell kernel: CPU: 23 PID: 12603 Comm: nfsd Not tainted 3.17.1-urquell-slabdebug #2
Oct 22 18:37:12 urquell kernel: Hardware name: SGI.COM SGI MIS Server/S2600JF, BIOS SE5C600.86B.01.03.0002.062020121504 06/20/2012
Oct 22 18:37:12 urquell kernel: task: ffff880fbb321000 ti: ffff880fbaf58000 task.ti: ffff880fbaf58000
Oct 22 18:37:12 urquell kernel: RIP: 0010:[<ffffffff82511685>]  [<ffffffff82511685>] _raw_spin_unlock_irqrestore+0x5/0x10
Oct 22 18:37:12 urquell kernel: RSP: 0018:ffff880fbaf5bde0  EFLAGS: 00000296
Oct 22 18:37:12 urquell kernel: RAX: ffffffff82841930 RBX: ffffffff820963db RCX: 0000000000000000
Oct 22 18:37:12 urquell kernel: RDX: ffffffff82841948 RSI: 0000000000000296 RDI: ffffffff82841940
Oct 22 18:37:12 urquell kernel: RBP: ffff880fd1ac52d0 R08: 0000000000000000 R09: 0000000000000000
Oct 22 18:37:12 urquell kernel: R10: ffff880fd1ac5b28 R11: ffff880fff804780 R12: 00000000ffffffff
Oct 22 18:37:12 urquell kernel: R13: 0000000000000000 R14: 0000000000000000 R15: 0000000000000000
Oct 22 18:37:12 urquell kernel: FS:  0000000000000000(0000) GS:ffff880fffde0000(0000) knlGS:0000000000000000
Oct 22 18:37:12 urquell kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
Oct 22 18:37:12 urquell kernel: CR2: 00007f22e0b01400 CR3: 000000000280e000 CR4: 00000000000407e0
Oct 22 18:37:12 urquell kernel: Stack:
Oct 22 18:37:12 urquell kernel: ffffffff821dd282 ffff880fbaf5bde8 ffff880fbaf5bde8 ffff881ff785c6d8
Oct 22 18:37:12 urquell kernel: ffff880fd1ac52d0 ffff881ff785c6d8 0000000000000020 ffffffff8285dac0
Oct 22 18:37:12 urquell kernel: ffffffff821e3550 ffff880fbaf5be28 ffff880fbaf5be28 ffff881ff785c6d8
Oct 22 18:37:12 urquell kernel: Call Trace:
Oct 22 18:37:12 urquell kernel: [<ffffffff821dd282>] ? __destroy_client+0xd2/0x130
Oct 22 18:37:12 urquell kernel: [<ffffffff821e3550>] ? nfs4_state_shutdown_net+0x150/0x1e0
Oct 22 18:37:12 urquell kernel: [<ffffffff821c1152>] ? nfsd_shutdown_net+0x32/0x60
Oct 22 18:37:12 urquell kernel: [<ffffffff821c11da>] ? nfsd_last_thread+0x5a/0x90
Oct 22 18:37:12 urquell kernel: [<ffffffff821c163b>] ? nfsd_destroy+0x4b/0x70
Oct 22 18:37:12 urquell kernel: [<ffffffff821c17a4>] ? nfsd+0x144/0x170
Oct 22 18:37:12 urquell kernel: [<ffffffff821c1660>] ? nfsd_destroy+0x70/0x70
Oct 22 18:37:12 urquell kernel: [<ffffffff8207f38c>] ? kthread+0xbc/0xe0
Oct 22 18:37:12 urquell kernel: [<ffffffff8207f2d0>] ? __kthread_parkme+0x70/0x70
Oct 22 18:37:12 urquell kernel: [<ffffffff82511dac>] ? ret_from_fork+0x7c/0xb0
Oct 22 18:37:12 urquell kernel: [<ffffffff8207f2d0>] ? __kthread_parkme+0x70/0x70

Next one, shortly after, another task and core:

Oct 22 18:37:40 urquell kernel: NMI watchdog: BUG: soft lockup - CPU#9 stuck for 23s! [migration/9:54]
Oct 22 18:37:40 urquell kernel: Modules linked in:
Oct 22 18:37:40 urquell kernel: CPU: 9 PID: 54 Comm: migration/9 Tainted: G             L 3.17.1-urquell-slabdebug #2
Oct 22 18:37:40 urquell kernel: Hardware name: SGI.COM SGI MIS Server/S2600JF, BIOS SE5C600.86B.01.03.0002.062020121504 06/20/2012
Oct 22 18:37:40 urquell kernel: task: ffff881ff932a000 ti: ffff881ff888c000 task.ti: ffff881ff888c000
Oct 22 18:37:40 urquell kernel: RIP: 0010:[<ffffffff820c51ec>]  [<ffffffff820c51ec>] multi_cpu_stop+0x4c/0xb0
Oct 22 18:37:40 urquell kernel: RSP: 0000:ffff881ff888fd98  EFLAGS: 00000293
Oct 22 18:37:40 urquell kernel: RAX: 0000000000000000 RBX: ffff881ff932a000 RCX: ffff88203fc2d5a8
Oct 22 18:37:40 urquell kernel: RDX: 0000000000000001 RSI: 0000000000000246 RDI: ffff881ff412bbb0
Oct 22 18:37:40 urquell kernel: RBP: ffff881ff412bbb0 R08: ffff881ff888c000 R09: 0000000000000001
Oct 22 18:37:40 urquell kernel: R10: 0000000000000000 R11: 0000000000000000 R12: ffff881ff6e18d68
Oct 22 18:37:40 urquell kernel: R13: 0000000000000046 R14: ffffffff8209197b R15: ffff88203fc31200
Oct 22 18:37:40 urquell kernel: FS:  0000000000000000(0000) GS:ffff88203fc20000(0000) knlGS:0000000000000000
Oct 22 18:37:40 urquell kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
Oct 22 18:37:40 urquell kernel: CR2: 00007fd3488e5640 CR3: 000000000280e000 CR4: 00000000000407e0
Oct 22 18:37:40 urquell kernel: Stack:
Oct 22 18:37:40 urquell kernel: 0000000000000000 ffff88203fc2d5a0 ffff881ff412bbd8 ffff88203fc2d5a8
Oct 22 18:37:40 urquell kernel: ffff881ff412bbb0 ffffffff820c4e50 ffff880fffc11200 ffffffff82084351
Oct 22 18:37:40 urquell kernel: 0000000000000001 ffff881ff92b8000 0000000000000000 0000000000000000
Oct 22 18:37:40 urquell kernel: Call Trace:
Oct 22 18:37:40 urquell kernel: [<ffffffff820c4e50>] ? cpu_stopper_thread+0x70/0x120
Oct 22 18:37:40 urquell kernel: [<ffffffff82084351>] ? ttwu_do_wakeup+0x11/0x80
Oct 22 18:37:40 urquell kernel: [<ffffffff8208254c>] ? smpboot_thread_fn+0xfc/0x190
Oct 22 18:37:40 urquell kernel: [<ffffffff82082450>] ? SyS_setgroups+0x130/0x130
Oct 22 18:37:40 urquell kernel: [<ffffffff8207f38c>] ? kthread+0xbc/0xe0
Oct 22 18:37:40 urquell kernel: [<ffffffff8207f2d0>] ? __kthread_parkme+0x70/0x70
Oct 22 18:37:40 urquell kernel: [<ffffffff82511dac>] ? ret_from_fork+0x7c/0xb0
Oct 22 18:37:40 urquell kernel: [<ffffffff8207f2d0>] ? __kthread_parkme+0x70/0x70

These alternate in a series:

Oct 22 18:37:40 urquell kernel: NMI watchdog: BUG: soft lockup - CPU#23 stuck for 22s! [nfsd:12603]
[REMOVED]
Oct 22 18:37:40 urquell kernel: [<ffffffff821e3550>] ? nfs4_state_shutdown_net+0x150/0x1e0
Oct 22 18:37:40 urquell kernel: [<ffffffff821c1152>] ? nfsd_shutdown_net+0x32/0x60
Oct 22 18:37:40 urquell kernel: [<ffffffff821c11da>] ? nfsd_last_thread+0x5a/0x90
Oct 22 18:37:40 urquell kernel: [<ffffffff821c163b>] ? nfsd_destroy+0x4b/0x70
Oct 22 18:37:40 urquell kernel: [<ffffffff821c17a4>] ? nfsd+0x144/0x170
Oct 22 18:37:40 urquell kernel: [<ffffffff821c1660>] ? nfsd_destroy+0x70/0x70
Oct 22 18:37:40 urquell kernel: [<ffffffff8207f38c>] ? kthread+0xbc/0xe0
Oct 22 18:37:40 urquell kernel: [<ffffffff8207f2d0>] ? __kthread_parkme+0x70/0x70
Oct 22 18:37:40 urquell kernel: [<ffffffff82511dac>] ? ret_from_fork+0x7c/0xb0
Oct 22 18:37:40 urquell kernel: [<ffffffff8207f2d0>] ? __kthread_parkme+0x70/0x70

Oct 22 18:38:08 urquell kernel: NMI watchdog: BUG: soft lockup - CPU#9 stuck for 23s! [migration/9:54]
[REMOVED]
Oct 22 18:38:08 urquell kernel: [<ffffffff820c4e50>] ? cpu_stopper_thread+0x70/0x120
Oct 22 18:38:08 urquell kernel: [<ffffffff82084351>] ? ttwu_do_wakeup+0x11/0x80
Oct 22 18:38:08 urquell kernel: [<ffffffff8208254c>] ? smpboot_thread_fn+0xfc/0x190
Oct 22 18:38:08 urquell kernel: [<ffffffff82082450>] ? SyS_setgroups+0x130/0x130
Oct 22 18:38:08 urquell kernel: [<ffffffff8207f38c>] ? kthread+0xbc/0xe0
Oct 22 18:38:08 urquell kernel: [<ffffffff8207f2d0>] ? __kthread_parkme+0x70/0x70
Oct 22 18:38:08 urquell kernel: [<ffffffff82511dac>] ? ret_from_fork+0x7c/0xb0
Oct 22 18:38:08 urquell kernel: [<ffffffff8207f2d0>] ? __kthread_parkme+0x70/0x70

Etc. There's some variation in the call thread:

Oct 22 18:38:44 urquell kernel: NMI watchdog: BUG: soft lockup - CPU#23 stuck for 23s! [nfsd:12603]
[REMOVED]
Oct 22 18:38:44 urquell kernel: [<ffffffff82096093>] ? __wake_up+0x43/0x70
Oct 22 18:38:44 urquell kernel: [<ffffffff821dcf49>] ? nfs4_put_stid+0x29/0x100
Oct 22 18:38:44 urquell kernel: [<ffffffff821dd282>] ? __destroy_client+0xd2/0x130
Oct 22 18:38:44 urquell kernel: [<ffffffff821e3550>] ? nfs4_state_shutdown_net+0x150/0x1e0
Oct 22 18:38:44 urquell kernel: [<ffffffff821c1152>] ? nfsd_shutdown_net+0x32/0x60
Oct 22 18:38:44 urquell kernel: [<ffffffff821c11da>] ? nfsd_last_thread+0x5a/0x90
Oct 22 18:38:44 urquell kernel: [<ffffffff821c163b>] ? nfsd_destroy+0x4b/0x70
Oct 22 18:38:44 urquell kernel: [<ffffffff821c17a4>] ? nfsd+0x144/0x170
Oct 22 18:38:44 urquell kernel: [<ffffffff821c1660>] ? nfsd_destroy+0x70/0x70
Oct 22 18:38:44 urquell kernel: [<ffffffff8207f38c>] ? kthread+0xbc/0xe0
Oct 22 18:38:44 urquell kernel: [<ffffffff8207f2d0>] ? __kthread_parkme+0x70/0x70
Oct 22 18:38:44 urquell kernel: [<ffffffff82511dac>] ? ret_from_fork+0x7c/0xb0
Oct 22 18:38:44 urquell kernel: [<ffffffff8207f2d0>] ? __kthread_parkme+0x70/0x70


Then reboot. Next NMI appeared next day:

Oct 23 11:43:24 urquell kernel: NMI watchdog: BUG: soft lockup - CPU#5 stuck for 22s! [kworker/u64:3:6414]
Oct 23 11:43:24 urquell kernel: Modules linked in:
Oct 23 11:43:24 urquell kernel: CPU: 5 PID: 6414 Comm: kworker/u64:3 Not tainted 3.17.1-urquell-slabdebug #2
Oct 23 11:43:24 urquell kernel: Hardware name: SGI.COM SGI MIS Server/S2600JF, BIOS SE5C600.86B.01.03.0002.062020121504 06/20/2012
Oct 23 11:43:24 urquell kernel: Workqueue: nfsd4 laundromat_main
Oct 23 11:43:24 urquell kernel: task: ffff881ff0d49800 ti: ffff8813f5a04000 task.ti: ffff8813f5a04000
Oct 23 11:43:24 urquell kernel: RIP: 0010:[<ffffffff85245cc8>]  [<ffffffff85245cc8>] _atomic_dec_and_lock+0x18/0x60
Oct 23 11:43:24 urquell kernel: RSP: 0018:ffff8813f5a07d08  EFLAGS: 00000246
Oct 23 11:43:24 urquell kernel: RAX: 0000000000000000 RBX: ffffffff85096290 RCX: 00000000ffffffff
Oct 23 11:43:24 urquell kernel: RDX: 0000000000000000 RSI: ffffffff850963db RDI: ffff8813f5a07cf8
Oct 23 11:43:24 urquell kernel: RBP: ffffffff85096093 R08: 0000000000000000 R09: 0000000000000001
Oct 23 11:43:24 urquell kernel: R10: 0000000000000001 R11: 0140000000000000 R12: 0000000000000000
Oct 23 11:43:24 urquell kernel: R13: ffff880ff5c752d0 R14: ffffffff851bdaa0 R15: 0000000000000206
Oct 23 11:43:24 urquell kernel: FS:  0000000000000000(0000) GS:ffff880fffca0000(0000) knlGS:0000000000000000
Oct 23 11:43:24 urquell kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
Oct 23 11:43:24 urquell kernel: CR2: ffffffffff600400 CR3: 000000000580e000 CR4: 00000000000407e0
Oct 23 11:43:24 urquell kernel: Stack:
Oct 23 11:43:24 urquell kernel: ffff881fee03dba0 ffffffff85096093 ffff8813f5a07cf8 ffffffff851dcf49
Oct 23 11:43:24 urquell kernel: ffff881fee039950 ffff881fee0398d8 ffff8813f5a07d48 ffffffff851dd282
Oct 23 11:43:24 urquell kernel: ffff8813f5a07d48 ffff8813f5a07d48 ffff8813f5a07db8 ffff881ff7fbbd98
Oct 23 11:43:24 urquell kernel: Call Trace:
Oct 23 11:43:24 urquell kernel: [<ffffffff85096093>] ? __wake_up+0x43/0x70
Oct 23 11:43:24 urquell kernel: [<ffffffff851dcf49>] ? nfs4_put_stid+0x29/0x100
Oct 23 11:43:24 urquell kernel: [<ffffffff851dd282>] ? __destroy_client+0xd2/0x130
Oct 23 11:43:24 urquell kernel: [<ffffffff851dd449>] ? laundromat_main+0x149/0x3f0
Oct 23 11:43:24 urquell kernel: [<ffffffff8507a6a4>] ? process_one_work+0x134/0x340
Oct 23 11:43:24 urquell kernel: [<ffffffff8507adb4>] ? worker_thread+0x114/0x460
Oct 23 11:43:24 urquell kernel: [<ffffffff85095b5c>] ? __wake_up_common+0x4c/0x80
Oct 23 11:43:24 urquell kernel: [<ffffffff8507aca0>] ? init_pwq+0x160/0x160
Oct 23 11:43:24 urquell kernel: [<ffffffff8507f38c>] ? kthread+0xbc/0xe0
Oct 23 11:43:24 urquell kernel: [<ffffffff8507f2d0>] ? __kthread_parkme+0x70/0x70
Oct 23 11:43:24 urquell kernel: [<ffffffff85511dac>] ? ret_from_fork+0x7c/0xb0
Oct 23 11:43:24 urquell kernel: [<ffffffff8507f2d0>] ? __kthread_parkme+0x70/0x70

Oct 23 11:43:52 urquell kernel: NMI watchdog: BUG: soft lockup - CPU#5 stuck for 22s! [kworker/u64:3:6414]
Oct 23 11:43:52 urquell kernel: Modules linked in:
Oct 23 11:43:52 urquell kernel: CPU: 5 PID: 6414 Comm: kworker/u64:3 Tainted: G             L 3.17.1-urquell-slabdebug #2
Oct 23 11:43:52 urquell kernel: Hardware name: SGI.COM SGI MIS Server/S2600JF, BIOS SE5C600.86B.01.03.0002.062020121504 06/20/2012
Oct 23 11:43:52 urquell kernel: Workqueue: nfsd4 laundromat_main
Oct 23 11:43:52 urquell kernel: task: ffff881ff0d49800 ti: ffff8813f5a04000 task.ti: ffff8813f5a04000
Oct 23 11:43:52 urquell kernel: RIP: 0010:[<ffffffff85511685>]  [<ffffffff85511685>] _raw_spin_unlock_irqrestore+0x5/0x10
Oct 23 11:43:52 urquell kernel: RSP: 0018:ffff8813f5a07d40  EFLAGS: 00000296
Oct 23 11:43:52 urquell kernel: RAX: ffffffff85841930 RBX: ffffffff850963db RCX: 0000000000000000
Oct 23 11:43:52 urquell kernel: RDX: ffffffff85841948 RSI: 0000000000000296 RDI: ffffffff85841940
Oct 23 11:43:52 urquell kernel: RBP: ffff881fee0398d8 R08: 0000000000000000 R09: 0000000000000001
Oct 23 11:43:52 urquell kernel: R10: 0000000000000001 R11: 0140000000000000 R12: ffff8813f5a07d48
Oct 23 11:43:52 urquell kernel: R13: ffff8813f5a07d48 R14: 0000000000000000 R15: 0000000000000001
Oct 23 11:43:52 urquell kernel: FS:  0000000000000000(0000) GS:ffff880fffca0000(0000) knlGS:0000000000000000
Oct 23 11:43:52 urquell kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
Oct 23 11:43:52 urquell kernel: CR2: ffffffffff600400 CR3: 000000000580e000 CR4: 00000000000407e0
Oct 23 11:43:52 urquell kernel: Stack:
Oct 23 11:43:52 urquell kernel: ffffffff851dd282 ffff8813f5a07d48 ffff8813f5a07d48 ffff8813f5a07db8
Oct 23 11:43:52 urquell kernel: ffff881ff7fbbd98 ffff8813f5a07db8 ffff881ff7fbbeb0 000000005449058d
Oct 23 11:43:52 urquell kernel: ffffffff851dd449 0000000000000000 0000000000000000 0000000000000000
Oct 23 11:43:52 urquell kernel: Call Trace:
Oct 23 11:43:52 urquell kernel: [<ffffffff851dd282>] ? __destroy_client+0xd2/0x130
Oct 23 11:43:52 urquell kernel: [<ffffffff851dd449>] ? laundromat_main+0x149/0x3f0
Oct 23 11:43:52 urquell kernel: [<ffffffff8507a6a4>] ? process_one_work+0x134/0x340
Oct 23 11:43:52 urquell kernel: [<ffffffff8507adb4>] ? worker_thread+0x114/0x460
Oct 23 11:43:52 urquell kernel: [<ffffffff85095b5c>] ? __wake_up_common+0x4c/0x80
Oct 23 11:43:52 urquell kernel: [<ffffffff8507aca0>] ? init_pwq+0x160/0x160
Oct 23 11:43:52 urquell kernel: [<ffffffff8507f38c>] ? kthread+0xbc/0xe0
Oct 23 11:43:52 urquell kernel: [<ffffffff8507f2d0>] ? __kthread_parkme+0x70/0x70
Oct 23 11:43:52 urquell kernel: [<ffffffff85511dac>] ? ret_from_fork+0x7c/0xb0
Oct 23 11:43:52 urquell kernel: [<ffffffff8507f2d0>] ? __kthread_parkme+0x70/0x70

And it repeats, always kworker at the same core.

We then reverted to 3.14.21, since an uptime of ~5h (under load) is not viable
in this mission critical server.


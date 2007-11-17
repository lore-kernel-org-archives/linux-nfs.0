From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [NFS] [BUG] 2.6.24-rc2-mm1 - kernel bug on nfs v4
Date: Sat, 17 Nov 2007 10:05:07 -0800
Message-ID: <20071117100507.912c5e5c.akpm__45061.5955669948$1195332536$gmane$org@linux-foundation.org>
References: <473DA608.1020804@linux.vnet.ibm.com>
	<64bb37e0711170953p67d1be49lf4eaa190d662e2b4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	LKML <linux-kernel@vger.kernel.org>,
	Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>,
	linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org, nfs@lists.sourceforge.net,
	Christoph Lameter <clameter@sgi.com>,
	Andy Whitcroft <apw-26w3C0LaAnFg9hUCZPvPmw@public.gmane.org>,
	Jan Blunck <jblunck@suse.de>,
	Balbir Singh <balbir@linux.vnet.ibm.com>
To: "Torsten Kaiser" <just.for.lkml@googlemail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ItS2y-0002mB-T9
	for nfs@lists.sourceforge.net; Sat, 17 Nov 2007 10:05:36 -0800
Received: from smtp2.linux-foundation.org ([207.189.120.14])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1ItS34-00070x-E7
	for nfs@lists.sourceforge.net; Sat, 17 Nov 2007 10:05:42 -0800
In-Reply-To: <64bb37e0711170953p67d1be49lf4eaa190d662e2b4-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Sat, 17 Nov 2007 18:53:45 +0100 "Torsten Kaiser" <just.for.lkml@googlemail.com> wrote:

> On Nov 16, 2007 3:15 PM, Kamalesh Babulal <kamalesh@linux.vnet.ibm.com> wrote:
> > Hi Andrew,
> >
> > The kernel enters the xmon state while running the file system
> > stress on nfs v4 mounted partition.
> [snip]
> > 0:mon> t
> > [c0000000dbd4fb50] c000000000069768 .__wake_up+0x54/0x88
> > [c0000000dbd4fc00] d00000000086b890 .nfs_sb_deactive+0x44/0x58 [nfs]
> > [c0000000dbd4fc80] d000000000872658 .nfs_free_unlinkdata+0x2c/0x74 [nfs]
> > [c0000000dbd4fd10] d000000000598510 .rpc_release_calldata+0x50/0x74 [sunrpc]
> > [c0000000dbd4fda0] c00000000008d960 .run_workqueue+0x10c/0x1f4
> > [c0000000dbd4fe50] c00000000008ec70 .worker_thread+0x118/0x138
> > [c0000000dbd4ff00] c0000000000939f4 .kthread+0x78/0xc4
> > [c0000000dbd4ff90] c00000000002b060 .kernel_thread+0x4c/0x68
> 
> Definitely not a ppc problem.
> Got nearly the same backtrace on 64bit x86:
> [  966.712167] BUG: soft lockup - CPU#3 stuck for 11s! [rpciod/3:605]
> [  966.718522] CPU 3:
> [  966.720589] Modules linked in: radeon drm nfsd exportfs ipv6
> w83792d tuner tea5767 tda8290 tuner_xc2028 tda9887 tuner_simple mt20xx
> tea5761 tvaudio msp3400 bttv ir_common compat_ioctl32 videobuf_dma_sg
> videobuf_core btcx_risc tveeprom videodev usbhid v4l2_common
> v4l1_compat hid sg i2c_nforce2 pata_amd
> [  966.748306] Pid: 605, comm: rpciod/3 Not tainted 2.6.24-rc2-mm1 #4
> [  966.754653] RIP: 0010:[<ffffffff805b0542>]  [<ffffffff805b0542>]
> _spin_lock_irqsave+0x12/0x30
> [  966.763424] RSP: 0018:ffff81007ef33e28  EFLAGS: 00000286
> [  966.768879] RAX: 0000000000000286 RBX: ffff81007ef33e60 RCX: 0000000000000000
> [  966.776204] RDX: 0000000000000001 RSI: 0000000000000003 RDI: ffff81011e107960
> [  966.783511] RBP: ffff81011cc6c588 R08: ffff8100db918130 R09: ffff81011cc6c540
> [  966.790837] R10: 0000000000000000 R11: ffffffff80266390 R12: ffff8100d2d693a8
> [  966.798170] R13: ffff81011cc6c588 R14: ffff8100d2d693a8 R15: ffffffff80302726
> [  966.805505] FS:  00007f9e739d96f0(0000) GS:ffff81011ff12700(0000)
> knlGS:0000000000000000
> [  966.813805] CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
> [  966.819703] CR2: 0000000001b691d0 CR3: 0000000069861000 CR4: 00000000000006e0
> [  966.827039] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [  966.834362] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [  966.841687]
> [  966.841687] Call Trace:
> [  966.845728]  [<ffffffff8022cf4d>] __wake_up+0x2d/0x70
> [  966.850900]  [<ffffffff802f5e6e>] nfs_free_unlinkdata+0x1e/0x50
> [  966.857004]  [<ffffffff80593f66>] rpc_release_calldata+0x26/0x50
> [  966.863161]  [<ffffffff80594930>] rpc_async_schedule+0x0/0x10
> [  966.869078]  [<ffffffff80245cec>] run_workqueue+0xcc/0x170
> [  966.874705]  [<ffffffff802467a0>] worker_thread+0x0/0xb0
> [  966.880163]  [<ffffffff802467a0>] worker_thread+0x0/0xb0
> [  966.885610]  [<ffffffff8024680d>] worker_thread+0x6d/0xb0
> [  966.891148]  [<ffffffff8024a140>] autoremove_wake_function+0x0/0x30
> [  966.897606]  [<ffffffff802467a0>] worker_thread+0x0/0xb0
> [  966.903045]  [<ffffffff802467a0>] worker_thread+0x0/0xb0
> [  966.908485]  [<ffffffff80249d5b>] kthread+0x4b/0x80
> [  966.913484]  [<ffffffff8020ca28>] child_rip+0xa/0x12
> [  966.918579]  [<ffffffff80249d10>] kthread+0x0/0x80
> [  966.923498]  [<ffffffff8020ca1e>] child_rip+0x0/0x12
> [  966.928584]

I don't know what'a causing that.  I spose I should set up nfs4.

> Sadly lockdep does not work for me, as it gets turned off early:
> [   39.851594] ---------------------------------
> [   39.855963] inconsistent {softirq-on-W} -> {in-softirq-W} usage.
> [   39.861981] swapper/0 [HC0[0]:SC1[1]:HE0:SE0] takes:
> [   39.866963]  (&n->list_lock){-+..}, at: [<ffffffff802935c1>]
> add_partial+0x31/0xa0
> [   39.874712] {softirq-on-W} state was registered at:
> [   39.879788]   [<ffffffff80259fb8>] __lock_acquire+0x3e8/0x1140
> [   39.885763]   [<ffffffff80259838>] debug_check_no_locks_freed+0x188/0x1a0
> [   39.892682]   [<ffffffff8025ad65>] lock_acquire+0x55/0x70
> [   39.898840]   [<ffffffff802935c1>] add_partial+0x31/0xa0
> [   39.904288]   [<ffffffff805c76de>] _spin_lock+0x1e/0x30
> [   39.909650]   [<ffffffff802935c1>] add_partial+0x31/0xa0
> [   39.915097]   [<ffffffff80296f9c>] kmem_cache_open+0x1cc/0x330
> [   39.921066]   [<ffffffff805c7984>] _spin_unlock_irq+0x24/0x30
> [   39.926946]   [<ffffffff802974f4>] create_kmalloc_cache+0x64/0xf0
> [   39.933172]   [<ffffffff80295640>] init_alloc_cpu_cpu+0x70/0x90
> [   39.939226]   [<ffffffff8080ada5>] kmem_cache_init+0x65/0x1d0
> [   39.945289]   [<ffffffff807f1b4e>] start_kernel+0x23e/0x350
> [   39.950996]   [<ffffffff807f112d>] _sinittext+0x12d/0x140
> [   39.956529]   [<ffffffffffffffff>] 0xffffffffffffffff
> [   39.961720] irq event stamp: 1207
> [   39.965048] hardirqs last  enabled at (1206): [<ffffffff80259838>]
> debug_check_no_locks_freed+0x188/0x1a0
> [   39.974701] hardirqs last disabled at (1207): [<ffffffff802952eb>]
> __slab_free+0x3b/0x190
> [   39.982968] softirqs last  enabled at (570): [<ffffffff8020cf0c>]
> call_softirq+0x1c/0x30
> [   39.991148] softirqs last disabled at (1197): [<ffffffff8020cf0c>]
> call_softirq+0x1c/0x30
> [   39.999415]
> [   39.999416] other info that might help us debug this:
> [   40.005990] no locks held by swapper/0.
> [   40.010018]
> [   40.010018] stack backtrace:
> [   40.014429]
> [   40.014429] Call Trace:
> [   40.018407]  <IRQ>  [<ffffffff8025847c>] print_usage_bug+0x18c/0x1a0
> [   40.024817]  [<ffffffff802593ec>] mark_lock+0x64c/0x660
> [   40.030057]  [<ffffffff80259f6e>] __lock_acquire+0x39e/0x1140
> [   40.035818]  [<ffffffff80257717>] save_trace+0x37/0xa0
> [   40.040972]  [<ffffffff802492cd>] __rcu_process_callbacks+0x8d/0x250
> [   40.047335]  [<ffffffff8025ad65>] lock_acquire+0x55/0x70
> [   40.052663]  [<ffffffff802935c1>] add_partial+0x31/0xa0
> [   40.057905]  [<ffffffff802595d3>] trace_hardirqs_on+0x83/0x160
> [   40.063750]  [<ffffffff805c76de>] _spin_lock+0x1e/0x30
> [   40.068905]  [<ffffffff802935c1>] add_partial+0x31/0xa0
> [   40.074311]  [<ffffffff802953b0>] __slab_free+0x100/0x190
> [   40.079724]  [<ffffffff802492cd>] __rcu_process_callbacks+0x8d/0x250
> [   40.086088]  [<ffffffff8023b79c>] tasklet_action+0x2c/0xc0
> [   40.091588]  [<ffffffff802494b3>] rcu_process_callbacks+0x23/0x50
> [   40.097694]  [<ffffffff8023b7ba>] tasklet_action+0x4a/0xc0
> [   40.103194]  [<ffffffff8023b67a>] __do_softirq+0x7a/0x100
> [   40.108607]  [<ffffffff8020cf0c>] call_softirq+0x1c/0x30
> [   40.113935]  [<ffffffff8020f125>] do_softirq+0x55/0xb0
> [   40.119089]  [<ffffffff8023b5f7>] irq_exit+0x97/0xa0
> [   40.124073]  [<ffffffff8021bf2c>] smp_apic_timer_interrupt+0x7c/0xc0
> [   40.130434]  [<ffffffff8020ac70>] default_idle+0x0/0x60
> [   40.135840]  [<ffffffff8020ac70>] default_idle+0x0/0x60
> [   40.141080]  [<ffffffff8020c9bb>] apic_timer_interrupt+0x6b/0x70
> [   40.147100]  <EOI>  [<ffffffff8020aca7>] default_idle+0x37/0x60
> [   40.153066]  [<ffffffff8020aca5>] default_idle+0x35/0x60
> [   40.158393]  [<ffffffff8020ad2f>] cpu_idle+0x5f/0x90
> [   40.163374]
> [   40.164888] INFO: lockdep is turned off.
> 
> Don't know who to bug about that.
> 

That's slub.  It appears that list_lock is being taken from process context
in one place and from softirq in another.



-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs


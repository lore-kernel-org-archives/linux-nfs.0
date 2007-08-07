From: Marc Dietrich <Marc.Dietrich@ap.physik.uni-giessen.de>
Subject: Re: [NFS] 2.6.23-rc1-mm2
Date: Tue, 7 Aug 2007 14:09:30 +0200
Message-ID: <200708071409.39012.marc.dietrich@ap.physik.uni-giessen.de>
References: <20070731230932.a9459617.akpm@linux-foundation.org> <200708061305.37208.marc.dietrich@ap.physik.uni-giessen.de> <1186417445.6616.23.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Oleg Nesterov <oleg@tv-sign.ru>,
	Andrew Morton <akpm@linux-foundation.org>,
	Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762220AbXHGMK1@vger.kernel.org>
In-Reply-To: <1186417445.6616.23.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Am Monday 06 August 2007 18:24 schrieb Trond Myklebust:
> On Mon, 2007-08-06 at 13:05 +0200, Marc Dietrich wrote:
> > Hi,
> >
> > > (...)
> >
> > just booting into X is enough.
> >
> > I applied the patch, but now I get:
> >
> > =================================
> > [ INFO: inconsistent lock state ]
> > 2.6.23-rc1-mm2 #4
> > ---------------------------------
> > inconsistent {softirq-on-W} -> {in-softirq-W} usage.
> > swapper/0 [HC0[0]:SC1[1]:HE1:SE0] takes:
> >  (rpc_credcache_lock){-+..}, at: [<c01dc487>]
> > _atomic_dec_and_lock+0x17/0x60 {softirq-on-W} state was registered at:
> >   [<c013e870>] __lock_acquire+0x650/0x1030
> >   [<c013f2b1>] lock_acquire+0x61/0x80
> >   [<c02db9ac>] _spin_lock+0x2c/0x40
> >   [<c01dc487>] _atomic_dec_and_lock+0x17/0x60
> >   [<dced55fd>] put_rpccred+0x5d/0x100 [sunrpc]
> >   [<dced56c1>] rpcauth_unbindcred+0x21/0x60 [sunrpc]
> >   [<dced3fd4>] a0 [sunrpc]
> >   [<dcecefe0>] rpc_call_sync+0x30/0x40 [sunrpc]
> >   [<dcedc73b>] rpcb_register+0xdb/0x180 [sunrpc]
> >   [<dced65b3>] svc_register+0x93/0x160 [sunrpc]
> >   [<dced6ebe>] __svc_create+0x1ee/0x220 [sunrpc]
> >   [<dced7053>] svc_create+0x13/0x20 [sunrpc]
> >   [<dcf6d722>] nfs_callback_up+0x82/0x120 [nfs]
> >   [<dcf48f36>] nfs_get_client+0x176/0x390 [nfs]
> >   [<dcf49181>] nfs4_set_client+0x31/0x190 [nfs]
> >   [<dcf49983>] nfs4_create_server+0x63/0x3b0 [nfs]
> >   [<dcf52426>] nfs4_get_sb+0x346/0x5b0 [nfs]
> >   [<c017b444>] vfs_kern_mount+0x94/0x110
> >   [<c0190a62>] do_mount+0x1f2/0x7d0
> >   [<c01910a6>] sys_mount+0x66/0xa0
> >   [<c0104046>] syscall_call+0x7/0xb
> >   [<ffffffff>] 0xffffffff
> > irq event stamp: 5277830
> > hardirqs last  enabled at (5277830): [<c017530a>]
> > kmem_cache_free+0x8a/0xc0 hardirqs last disabled at (5277829):
> > [<c01752d2>] kmem_cache_free+0x52/0xc0 softirqs last  enabled at
> > (5277798): [<c0124173>] __do_softirq+0xa3/0xc0 softirqs last disabled at
> > (5277817): [<c01241d7>] do_softirq+0x47/0x50
> >
> > other info that might help us debug this:
> > no locks held by swapper/0.
> >
> > stack backtrace:
> >  [<c0104fda>] show_trace_log_lvl+0x1a/0x30
> >  [<c0105c02>] show_trace+0x12/0x20
> >  [<c0105d15>] dump_stack+0x15/0x20
> >  [<c013ccc3>] print_usage_bug+0x153/0x160
> >  [<c013d8b9>] mark_lock+0x449/0x620
> >  [<c013e824>] __lock_acquire+0x604/0x1030
> >  [<c013f2b1>] lock_acquire+0x61/0x80
> >  [<c02db9ac>] _spin_lock+0x2c/0x40
> >  [<c01dc487>] _atomic_dec_and_lock+0x17/0x60
> >  [<dced55fd>] put_rpccred+0x5d/0x100 [sunrpc]
> >  [<dcf6bf83>] nfs_free_delegation_callback+0x13/0x20 [nfs]
> >  [<c012f9ea>] __rcu_process_callbacks+0x6a/0x1c0
> >  [<c012fb52>] rcu_process_callbacks+0x12/0x30
> >  [<c0124218>] tasklet_action+0x38/0x80
> >  [<c0124125>] __do_softirq+0x55/0xc0
> >  [<c01241d7>] do_softirq+0x47/0x50
> >  [<c0124605>] irq_exit+0x35/0x40
> >  [<c0112463>] smp_apic_timer_interrupt+0x43/0x80
> >  [<c0104a77>] apic_timer_interrupt+0x33/0x38
> >  [<c02690df>] cpuidle_idle_call+0x6f/0x90
> >  [<c01023c3>] cpu_idle+0x43/0x70
> >  [<c02d8c27>] rest_init+0x47/0x50
> >  [<c03bcb6a>] start_kernel+0x22a/0x2b0
> >  [<00000000>] 0x0
> >  =======================
>
> That is a different matter. I assume this patch should suffice to fix
> the above problem.
>
> Trond

yes - it does.

thanks.

Marc


-- 
	"Our cause has a sacred nature."
		 Lord Arthur Ponsonby, "Falsehood in Wartime: Propaganda Lies of the First 
World War", 1928

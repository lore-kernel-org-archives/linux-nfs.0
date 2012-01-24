Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:41259 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752878Ab2AXMg5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Jan 2012 07:36:57 -0500
Date: Tue, 24 Jan 2012 07:36:26 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Stanislaw Gruszka <sgruszka@redhat.com>,
        Stephen Boyd <sboyd@codeaurora.org>, <linux-kernel@vger.kernel.org>,
        <bfields@redhat.com>, <linux-nfs@vger.kernel.org>,
        Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>
Subject: Re: WARNING: at lib/debugobjects.c:262
 debug_print_object+0x8c/0xb0()
Message-ID: <20120124073626.552bc31c@tlielax.poochiereds.net>
In-Reply-To: <4F1E7F3F.3060703@panasas.com>
References: <20120120135646.2fc4fa61@tlielax.poochiereds.net>
	<4F1BCCD6.4020603@codeaurora.org>
	<20120123102311.4378b8c1@tlielax.poochiereds.net>
	<20120124074516.GC2420@redhat.com>
	<4F1E7F3F.3060703@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 24 Jan 2012 11:51:59 +0200
Boaz Harrosh <bharrosh@panasas.com> wrote:

> On 01/24/2012 09:45 AM, Stanislaw Gruszka wrote:
> > On Mon, Jan 23, 2012 at 10:23:11AM -0500, Jeff Layton wrote:
> >> On Sun, 22 Jan 2012 00:46:14 -0800
> >> Stephen Boyd <sboyd@codeaurora.org> wrote:
> >>
> >>> On 1/20/2012 10:56 AM, Jeff Layton wrote:
> >>>> What I'm finding though is that if I stop and start nfsd multiple
> >>>> times, then I eventually get a warning like this on start:
> >>>>
> >>>> [ 5157.128514] WARNING: at lib/debugobjects.c:262 debug_print_object+0x8c/0xb0()
> >>>> [ 5157.128742] Hardware name: Bochs
> >>>> [ 5157.128742] ODEBUG: activate not available (active state 0) object type: timer_list hint: stub_timer+0x0/0x20
> >>>> [ 5157.128742] Modules linked in: nfsd(O) nfs_acl auth_rpcgss lockd sunrpc floppy virtio_net i2c_piix4 i2c_core virtio_balloon joydev pcspkr virtio_blk [last unloaded: nfsd]
> >>>> [ 5157.128742] Pid: 1312, comm: rpc.nfsd Tainted: G        W  O 3.3.0-rc1+ #1
> >>>> [ 5157.128742] Call Trace:
> >>>> [ 5157.128742]  [<ffffffff8106135f>] warn_slowpath_common+0x7f/0xc0
> >>>> [ 5157.128742]  [<ffffffff81061456>] warn_slowpath_fmt+0x46/0x50
> >>>> [ 5157.128742]  [<ffffffff8132ba2c>] debug_print_object+0x8c/0xb0
> >>>> [ 5157.128742]  [<ffffffff81070db0>] ? timer_debug_hint+0x10/0x10
> >>>> [ 5157.128742]  [<ffffffff8132c02b>] debug_object_activate+0xfb/0x190
> >>>> [ 5157.128742]  [<ffffffff81072728>] ? lock_timer_base.isra.24+0x38/0x70
> >>>> [ 5157.128742]  [<ffffffff81074676>] mod_timer+0xf6/0x450
> >>>> [ 5157.128742]  [<ffffffff810749e8>] add_timer+0x18/0x20
> >>>> [ 5157.128742]  [<ffffffff8108168e>] queue_delayed_work_on+0xbe/0x140
> >>>> [ 5157.128742]  [<ffffffff81084441>] queue_delayed_work+0x21/0x40
> >>>> [ 5157.128742]  [<ffffffffa006e568>] rpc_queue_upcall+0xe8/0x100 [sunrpc]
> >>>> [ 5157.128742]  [<ffffffffa012a121>] __cld_pipe_upcall+0x61/0xc0 [nfsd]
> >>>> [ 5157.128742]  [<ffffffffa012ad98>] nfsd4_cld_init+0x48/0x140 [nfsd]
> >>>> [ 5157.128742]  [<ffffffffa012b22a>] nfsd4_client_tracking_init+0x2a/0xc0 [nfsd]
> >>>> [ 5157.128742]  [<ffffffff8169797e>] ? mutex_unlock+0xe/0x10
> >>>> [ 5157.128742]  [<ffffffffa01266fa>] nfs4_state_start+0x1a/0x100 [nfsd]
> >>>> [ 5157.128742]  [<ffffffffa01028c5>] nfsd_svc+0x135/0x200 [nfsd]
> >>>> [ 5157.128742]  [<ffffffffa0103df0>] ? write_maxblksize+0x130/0x130 [nfsd]
> >>>> [ 5157.128742]  [<ffffffffa0103e6d>] write_threads+0x7d/0xd0 [nfsd]
> >>>> [ 5157.128742]  [<ffffffff811dd16a>] ? simple_transaction_get+0xca/0xe0
> >>>> [ 5157.128742]  [<ffffffffa0102ee7>] nfsctl_transaction_write+0x57/0x90 [nfsd]
> >>>> [ 5157.128742]  [<ffffffff811b4c9f>] vfs_write+0xaf/0x190
> >>>> [ 5157.128742]  [<ffffffff811b4fdd>] sys_write+0x4d/0x90
> >>>> [ 5157.128742]  [<ffffffff816a3469>] system_call_fastpath+0x16/0x1b
> >>>
> >>> This one is telling you that the timer you're about to run hasn't been 
> >>> registered with debug_objects. Most likely the work item hasn't been 
> >>> initialized properly and so it hasn't had INIT_DELAYED_WORK() called on it.
> >>>
> >>>>
> >>>> ...or this on stop:
> >>>>
> >>>> [ 5200.804410] WARNING: at lib/debugobjects.c:262 debug_print_object+0x8c/0xb0()
> >>>> [ 5200.808205] Hardware name: Bochs
> >>>> [ 5200.810121] ODEBUG: assert_init not available (active state 0) object type: timer_list hint: stub_timer+0x0/0x20
> >>>> [ 5200.812734] Modules linked in: nfsd(O) nfs_acl auth_rpcgss lockd sunrpc floppy virtio_net i2c_piix4 i2c_core virtio_balloon joydev pcspkr virtio_blk [last unloaded: nfsd]
> >>>> [ 5200.821596] Pid: 1394, comm: nfsd Tainted: G        W  O 3.3.0-rc1+ #1
> >>>> [ 5200.822409] Call Trace:
> >>>> [ 5200.822726]  [<ffffffff8106135f>] warn_slowpath_common+0x7f/0xc0
> >>>> [ 5200.823509]  [<ffffffff81061456>] warn_slowpath_fmt+0x46/0x50
> >>>> [ 5200.824243]  [<ffffffff8132ba2c>] debug_print_object+0x8c/0xb0
> >>>> [ 5200.824935]  [<ffffffff81070db0>] ? timer_debug_hint+0x10/0x10
> >>>> [ 5200.825665]  [<ffffffff8132c543>] debug_object_assert_init+0xe3/0x120
> >>>> [ 5200.826474]  [<ffffffff810737b4>] del_timer+0x24/0x1b0
> >>>> [ 5200.827129]  [<ffffffff81085314>] __cancel_work_timer+0x34/0x140
> >>>> [ 5200.827829]  [<ffffffff81085432>] cancel_delayed_work_sync+0x12/0x20
> >>>> [ 5200.832905]  [<ffffffffa006e430>] rpc_unlink+0x1e0/0x230 [sunrpc]
> >>>> [ 5200.833716]  [<ffffffffa012a195>] nfsd4_remove_cld_pipe+0x15/0x40 [nfsd]
> >>>> [ 5200.834558]  [<ffffffffa012b2e0>] nfsd4_client_tracking_exit+0x20/0x30 [nfsd]
> >>>> [ 5200.835434]  [<ffffffffa0126984>] nfs4_state_shutdown+0x1a4/0x1c0 [nfsd]
> >>>> [ 5200.836271]  [<ffffffffa010219a>] nfsd_last_thread+0x2a/0x60 [nfsd]
> >>>> [ 5200.837045]  [<ffffffffa005f66c>] svc_destroy+0x5c/0x140 [sunrpc]
> >>>> [ 5200.837778]  [<ffffffffa005f9f6>] svc_exit_thread+0xa6/0xb0 [sunrpc]
> >>>> [ 5200.838545]  [<ffffffffa0102123>] nfsd+0x123/0x170 [nfsd]
> >>>> [ 5200.839221]  [<ffffffffa0102000>] ? 0xffffffffa0101fff
> >>>> [ 5200.839820]  [<ffffffff8108a747>] kthread+0xb7/0xc0
> >>>> [ 5200.840431]  [<ffffffff816a48b4>] kernel_thread_helper+0x4/0x10
> >>>> [ 5200.850883]  [<ffffffff8169acf4>] ? retint_restore_args+0x13/0x13
> >>>> [ 5200.851654]  [<ffffffff8108a690>] ? kthread_worker_fn+0x1a0/0x1a0
> >>>> [ 5200.852418]  [<ffffffff816a48b0>] ? gs_change+0x13/0x13
> >>>
> >>> This is similar. Now you're deleting a timer that debug_objects doesn't 
> >>> know about.
> >>>
> >>>>
> >>>> The problem is that even after staring at this code for a while, I'm
> >>>> still clueless as to what this is telling me. It doesn't happen every
> >>>> time either, so maybe there's a race of some sort involved.
> >>>>
> >>>> It's possible that my patch is broken and doing something wrong, but
> >>>> I'm starting not to think so. I'm not really using timers directly --
> >>>> I'm using rpc_pipefs, which queues a delayed job to a workqueue, and
> >>>> that is manipulating the timer. The delayed_work (and hence the timer)
> >>>> are part of an rpc_inode.
> >>>>
> >>>> Can anyone shed a little light on what this is complaining about?
> >>>>
> >>>
> >>> Do you have workqueue debugging enabled too (DEBUG_OBJECTS_WORK)? I 
> >>> would hope that work item debugging would say the same things and then 
> >>> we would know that the work item itself wasn't initialized properly.
> >>
> >> (adding linux-nfs to cc list...)
> >>
> >> Ok, I think I sort of see what's happening, but I'm not sure if it's a
> >> bug in the debug objects code or something else. To answer the question
> >> that I didn't before, the kernels I've been testing have this set:
> >>
> >>     CONFIG_DEBUG_OBJECTS_WORK=y
> >>
> >> ...so workqueue debugging is on but I haven't seen any messages that
> >> come from it AFAICT. The rpc_inode objects have their delayed_work
> >> fields initialized via a slab "constructor". Here's the rpc_inode_cache
> >> creation call:
> >>
> >>         rpc_inode_cachep = kmem_cache_create("rpc_inode_cache",
> >>                                 sizeof(struct rpc_inode),
> >>                                 0, (SLAB_HWCACHE_ALIGN|SLAB_RECLAIM_ACCOUNT|
> >>                                                 SLAB_MEM_SPREAD),
> >>                                 init_once);
> >>
> >> ...and the init_once() routine does this:
> >>
> >>         INIT_DELAYED_WORK(&rpci->queue_timeout,
> >>                             rpc_timeout_upcall_queue);
> >>
> >> On the first use of an rpc_inode object, everything works fine. I think
> >> the problem comes in when rpc_inode objects get recycled without the
> >> INIT_DELAYED_WORK() getting called on it again.
> >>
> >> Before the object is freed it gets cancel_delayed_work_sync() called on
> >> it, but that's apparently not enough to convince the debugobjects code
> >> that it's already correctly initialized. As a Q&D check, the following
> >> patch seems to stop the warnings. Is there some better way to do this
> >> that doesn't require the reinitialization of the delayed work on each
> >> inode allocation?
> > 
> > If this is debug objects false positive, it should be rather fixed in
> > debug object code itself, not workaround in nfs code, but I do not have
> > any idea how to do this.
> > 
> > Stanislaw
> >  
> 
> I don't think so. Look at what INIT_DELAYED_WORK does.
>    INIT_WORK - Set some start values, register with the objects-debugger if on.
>    init_timer - 
> 
> I'd imagine that cancel_delayed_work_sync() would: 1st cancel some of those
> registrations, specifically with the objects-debugger. 2nd will leave some
> state undefined as left from the last round.
> 
> I think this patch is cardinal and you might have found a potential bug.
> 
> Also the cost of INIT_DELAYED_WORK is marginal compare to the extra safety.
> 
> Recomended-by: Boaz Harrosh <bharrosh@panasas.com>
> 

No, I don't think the state would be undefined after
cancel_delayed_work_sync. In principle you could requeue that work
again if you like without needing to reinitialize it.

I think this is a problem in the debugobjects code. It doesn't have
any way to know that when the object is recycled out of the slab that
the work is already initialized.

Certainly it's simple enough to reinitialize the work every time we
allocate an inode here, but I don't think this is really a rpc_pipefs
bug per-se. I can send a patch that works around this problem, but
if there are plans to fix this in the debugobjects code, I won't
bother...

-- 
Jeff Layton <jlayton@redhat.com>

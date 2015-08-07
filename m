Return-Path: <jlayton@poochiereds.net>
Date: Fri, 7 Aug 2015 09:22:29 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: nfs4_put_lock_state() wants some nfs4_state on cleanup
Message-ID: <20150807092229.0579a9cc@tlielax.poochiereds.net>
In-Reply-To: <alpine.OSX.2.19.9992.1508070736450.36471@planck.local>
References: <1437579281-26810-1-git-send-email-bcodding@redhat.com>
	<20150722123442.78ed7f67@tlielax.poochiereds.net>
	<alpine.OSX.2.19.9992.1508070736450.36471@planck.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 7 Aug 2015 07:49:58 -0400 (EDT)
Benjamin Coddington <bcodding@redhat.com> wrote:

> On Wed, 22 Jul 2015, Jeff Layton wrote:
> 
> > On Wed, 22 Jul 2015 11:34:41 -0400
> > Benjamin Coddington <bcodding@redhat.com> wrote:
> >
> > > Our QE folks are noticing the old leftover locks WARN popping up in RHEL7
> > > (it's since been removed).  While investigating upstream, I found I could
> > > make this happen by locking, then closing and signaling a process in a loop:
> > >
> > >  #0 [ffff88007a4874a0] __schedule at ffffffff81736d8a
> > >  #1 [ffff88007a4874f0] schedule at ffffffff81737407
> > >  #2 [ffff88007a487510] do_exit at ffffffff8109e18f
> > >  #3 [ffff88007a487590] oops_end at ffffffff8101822e
> > >  #4 [ffff88007a4875c0] no_context at ffffffff81063b55
> > >  #5 [ffff88007a487630] __bad_area_nosemaphore at ffffffff81063e1b
> > >  #6 [ffff88007a487680] bad_area_nosemaphore at ffffffff81063fa3
> > >  #7 [ffff88007a487690] __do_page_fault at ffffffff81064251
> > >  #8 [ffff88007a4876f0] trace_do_page_fault at ffffffff81064677
> > >  #9 [ffff88007a487730] do_async_page_fault at ffffffff8105ed0e
> > > #10 [ffff88007a487750] async_page_fault at ffffffff8173d078
> > >     [exception RIP: nfs4_put_lock_state+82]
> > >     RIP: ffffffffa02dd5b2  RSP: ffff88007a487808  RFLAGS: 00010207
> > >     RAX: 0000003fffffffff  RBX: ffff8800351d2000  RCX: 0000000000000024
> > >     RDX: 0000000000000000  RSI: 0000000000000000  RDI: 0000000000000009
> > >     RBP: ffff88007a487818   R8: 0000000000000000   R9: 0000000000000000
> > >     R10: 000000000000028b  R11: 0000000000aaaaaa  R12: ffff88003675e240
> > >     R13: ffff88003504d5b0  R14: ffff88007a487b30  R15: ffff880035097c40
> > >     ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0018
> > > #11 [ffff88007a487800] nfs4_put_lock_state at ffffffffa02dd59b [nfsv4]
> > > #12 [ffff88007a487820] nfs4_fl_release_lock at ffffffffa02dd605 [nfsv4]
> > > #13 [ffff88007a487830] locks_release_private at ffffffff81258548
> > > #14 [ffff88007a487850] locks_free_lock at ffffffff81258dbb
> > > #15 [ffff88007a487870] locks_dispose_list at ffffffff81258f68
> > > #16 [ffff88007a4878a0] __posix_lock_file at ffffffff81259ab6
> > > #17 [ffff88007a487930] posix_lock_inode_wait at ffffffff8125a02a
> > > #18 [ffff88007a4879b0] do_vfs_lock at ffffffffa02c4687 [nfsv4]
> > > #19 [ffff88007a4879c0] nfs4_proc_lock at ffffffffa02cc1a1 [nfsv4]
> > > #20 [ffff88007a487a70] do_unlk at ffffffffa0273d9e [nfs]
> > > #21 [ffff88007a487ac0] nfs_lock at ffffffffa0273fa9 [nfs]
> > > #22 [ffff88007a487b10] vfs_lock_file at ffffffff8125a76e
> > > #23 [ffff88007a487b20] locks_remove_posix at ffffffff8125a819
> > > #24 [ffff88007a487c10] locks_remove_posix at ffffffff8125a878
> > > #25 [ffff88007a487c20] filp_close at ffffffff812092a2
> > > #26 [ffff88007a487c50] put_files_struct at ffffffff812290c5
> > > #27 [ffff88007a487ca0] exit_files at ffffffff812291c1
> > > #28 [ffff88007a487cc0] do_exit at ffffffff8109dc5f
> > > #29 [ffff88007a487d40] do_group_exit at ffffffff8109e3b5
> > > #30 [ffff88007a487d70] get_signal at ffffffff810a9504
> > > #31 [ffff88007a487e00] do_signal at ffffffff81014447
> > > #32 [ffff88007a487f30] do_notify_resume at ffffffff81014b0e
> > > #33 [ffff88007a487f50] int_signal at ffffffff8173b2fc
> > >
> > > The nfs4_lock_state->ls_state pointer is pointing to free memory.
> > >
> > > I think what's happening here is that a signal is bumping us out of
> > > do_unlk() waiting on the io_counter while we try to release locks on
> > > __fput().  Since the lock is never released, it sticks around on the inode
> > > until another lock replaces it, and when it is freed it wants some bits from
> > > nfs4_state, but the nfs4_state was already cleaned up.
> > >
> > > Probably we need to do a better job not bailing out of do_unlk on file
> > > close, but while I work on that, something like the following keeps the
> > > nfs4_state around for proper cleanup of the nfs4_lock_state:
> > >
> > > Is this sane?
> > >
> > > Ben
> > >
> > > 8<--------------------------------------------------------------------
> > > From cab3dd59aa1a04f3be28811dfb515afc4a9080a7 Mon Sep 17 00:00:00 2001
> > > Message-Id: <cab3dd59aa1a04f3be28811dfb515afc4a9080a7.1437578183.git.bcodding@redhat.com>
> > > From: Benjamin Coddington <bcodding@redhat.com>
> > > Date: Wed, 22 Jul 2015 11:02:26 -0400
> > > Subject: [PATCH] NFS: keep nfs4_state for nfs4_lock_state cleanup
> > >
> > > If we fail to release a lock due to an error or signal on file close, we
> > > might later free the lock if another lock replaces it.  Hold a reference to
> > > the nfs4_state to ensure it is not released before freeing the
> > > nfs4_lock_state.
> > > ---
> > >  fs/nfs/nfs4state.c |    2 ++
> > >  1 files changed, 2 insertions(+), 0 deletions(-)
> > >
> > > diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> > > index 605840d..f93b410 100644
> > > --- a/fs/nfs/nfs4state.c
> > > +++ b/fs/nfs/nfs4state.c
> > > @@ -827,6 +827,7 @@ static struct nfs4_lock_state *nfs4_alloc_lock_state(struct nfs4_state *state, f
> > >  		return NULL;
> > >  	nfs4_init_seqid_counter(&lsp->ls_seqid);
> > >  	atomic_set(&lsp->ls_count, 1);
> > > +	atomic_inc(&state->count);
> > >  	lsp->ls_state = state;
> > >  	lsp->ls_owner = fl_owner;
> > >  	lsp->ls_seqid.owner_id = ida_simple_get(&server->lockowner_id, 0, 0, GFP_NOFS);
> > > @@ -903,6 +904,7 @@ void nfs4_put_lock_state(struct nfs4_lock_state *lsp)
> > >  		clp->cl_mvops->free_lock_state(server, lsp);
> > >  	} else
> > >  		nfs4_free_lock_state(server, lsp);
> > > +	nfs4_put_open_state(state);
> > >  }
> > >
> > >  static void nfs4_fl_copy_lock(struct file_lock *dst, struct file_lock *src)
> >
> > Looks relatively harmless at first glance, and since lock states are
> > somewhat dependent on an open state then having them hold a reference
> > like this makes a lot of sense as well.
> >
> > The existing behavior is probably fine when FL_CLOSE isn't set, but
> > when it is we need a stronger guarantee that the lock will be cleaned
> > up properly.
> >
> > I think the best fix when FL_CLOSE is set would be to change the code
> > so that it's not waiting synchronously on the iocounter to go to zero
> > before submitting the rpc_task. Instead, we should have the LOCKU
> > rpc_task wait on an rpc_wait_queue for the counter to go to zero.
> >
> > We might be able to get away with making all LOCKU rpcs do this, but I
> > think when you catch a signal in the middle of a fcntl() syscall,
> > you'll probably want to cancel the RPC as well if it hasn't been
> > successfully transmitted yet.
> 
> It seems like using a separate rpc_wait_queue to make sure the unlock is
> completed when the wait is interrupted would work for nfsv4, but for nlm
> locks it looks like a lot of plumbing.  You'd have to decide to pass along
> the rpc_wait_queue or a callback way before you get anywhere near setting up
> a task, or give nlm the smarts to check the io_counters.  Maybe I am being
> dense and there's a simpler way.
> 
> I think it makes sense to instead add the unlock request to the io_counter,
> and have nfsiod do the unlock when the counter reaches zero.  Somebody yell
> at me if that's a really bad idea.
> 

Ok, so you're going to add a list (or something) to nfs_io_counter. If
the wait is interrupted, you'll add the unlock request to the list.
When the io_count goes to 0, you'll submit all of the lock requests on
the list to nfsiod?

I don't know...it seems like your plan would add some new special-case
machinery to handle this case when we already have the necessary
infrastructure to do it with rpc_wait_queues.

My thinking was to just create a global rpc_wait_queue for this. Any
rpc_task that needs to wait on an io_count to drop would wait on this
queue, and when any NFS io_count drops to 0, you wake up all the
waiters.  If the rpc_task is scheduled and finds that the io_count for
the inode is not 0, it goes back to sleep on the wait queue.

The symbol for the queue could be exported so that both NLM and
NFS could access it -- maybe it could live in fs/nfs_common?

For NLM then you'd just need to add a rpc_call_prepare operation for
nlmclnt_unlock_ops that does this check and puts the task to sleep on
this wait queue if the io_count is still high.

The one case that does not cover though is the "is_local" case in
do_unlk. You probably would still need to do a synchronous wait there,
or come up with some other mechanism to handle it. Queueing the unlock
to a workqueue may make sense there.

In any case, it's ultimately up to Trond/Anna since they'd be the ones
merging this. If they think your proposal is a better way to go, then
I'm fine with that.

-- 
Jeff Layton <jlayton@poochiereds.net>

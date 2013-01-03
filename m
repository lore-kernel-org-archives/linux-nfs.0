Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52466 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753197Ab3ACXIO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Jan 2013 18:08:14 -0500
Date: Thu, 3 Jan 2013 18:08:11 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Tejun Heo <tj@kernel.org>
Cc: "Adamson, Dros" <Weston.Adamson@netapp.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Dave Jones <davej@redhat.com>,
        Linux Kernel <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: nfsd oops on Linus' current tree.
Message-ID: <20130103230811.GC3238@fieldses.org>
References: <20121221153348.GA32151@redhat.com>
 <20121221180824.GA27729@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA91197273D@SACEXCMBX04-PRD.hq.netapp.com>
 <20121221230849.GB29739@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA911972C73@SACEXCMBX04-PRD.hq.netapp.com>
 <20121221232609.GC29739@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA911972CA1@SACEXCMBX04-PRD.hq.netapp.com>
 <20121221234530.GA30048@fieldses.org>
 <0EC8763B847DB24D9ADF5EBD9CD7B4191259E4A2@SACEXCMBX02-PRD.hq.netapp.com>
 <20130103220309.GA2753@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130103220309.GA2753@mtj.dyndns.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 03, 2013 at 05:03:09PM -0500, Tejun Heo wrote:
> Hello, guys.
> 
> On Thu, Jan 03, 2013 at 04:28:37PM +0000, Adamson, Dros wrote:
> > The deadlock we were seeing was:
> > 
> > - task A gets queued on rpciod workqueue and assigned kworker-0:0
> > - task B gets queued on rpciod workqueue and assigned the same kworker (kworker-0:0)
> > - task A gets run, calls rpc_shutdown_client(), which will loop forever waiting for task B to run rpc_async_release()
> > - task B will never run rpc_async_release() - it can't run until kworker-0:0 is free, which won't happen until task A (rpc_shutdown_client) is done
> > 
> > The same deadlock happened when we tried queuing the tasks on a
> > different workqueues -- queue_work() assigns the task to a kworker
> > thread and it's luck of the draw if it's the same kworker as task A.
> > We tried the different workqueue options, but nothing changed this
> > behavior.
> 
> Work items don't get assigned to workers on queueing.  Idle workers
> pick up work items.

Oh, so that's why the case where we can't create a new worker is the
only case we should need the rescuers for.  Got it.  I think.

--b.

> A work item is directly assigned to a specific
> worker iff the worker is already executing that specific work item or
> the new work item is "linked" to the one it's currently executing.
> Currently, the only case where a linked work item is used is when
> flushing which is guaranteed to not introduce dependency the other way
> around.
> 
> So, your diagnosis looks wrong to me.  If such problem existed, we
> would be seeing deadlocks all over the place.
> 
> > Once a work struct is queued, there is no way to back out of the
> > deadlock.  From kernel/workqueue.c:insert_wq_barrier comment:
> 
> Yes, there are.  cancel_work[_sync]() do exactly that.
> 
> >  * Currently, a queued barrier can't be canceled.  This is because
> >  * try_to_grab_pending() can't determine whether the work to be
> >  * grabbed is at the head of the queue and thus can't clear LINKED
> >  * flag of the previous work while there must be a valid next work
> >  * after a work with LINKED flag set.
> > 
> > So once a work struct is queued and there is an ordering dependency
> > (i.e. task A is before task B), there is no way to back task B out -
> > so we can't just call cancel_work() or something on task B in
> > rpc_shutdown_client.
> 
> A *barrier* can't be canceled.  A barrier is used only to flush work
> items.  The above comment means that we currently don't (or can't)
> support canceling flush_work().  It has *nothing* to do with canceling
> regular work items.  You can cancel work items fine.
> 
> > The root of our issue is that rpc_shutdown_client is never safe to
> > call from a workqueue context - it loops until there are no more
> > tasks, marking tasks as killed and waiting for them to be cleaned up
> > in each task's own workqueue context. Any tasks that have already
> > been assigned to the same kworker thread will never have a chance to
> > run this cleanup stage.
> >
> > When fixing this deadlock, Trond and I discussed changing how
> > rpc_shutdown_client works (making it workqueue safe), but Trond felt
> > that it'd be better to just not call it from a workqueue context and
> > print a warning if it is.
> >
> > IIRC we tried using different workqueues with WQ_MEM_RECLAIM (with
> > no success), but I'd argue that even if that did work it would still
> > be very easy to call rpc_shutdown_client from the wrong context and
> > MUCH harder to detect it.  It's also unclear to me if setting rpciod
> > workqueue to WQ_MEM_RECLAIM would limit it to one kworker, etc...
> 
> It looks like you guys ended up in a weird place misled by wrong
> analysis.  Unless you require more than one concurrent execution on
> the same workqueue, WQ_MEM_RECLAIM guarantees forward progress.  It
> won't deadlock because "a different work item is queued to the same
> worker".  The whole thing is designed *exactly* to avoid problems like
> that.  So, I'd strongly recommend looking again at why the deadlocks
> are occurring.
> 
> Thanks.
> 
> -- 
> tejun
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

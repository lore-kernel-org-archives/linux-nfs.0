Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41918 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753708Ab3ACUwY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Jan 2013 15:52:24 -0500
Date: Thu, 3 Jan 2013 15:52:21 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Adamson, Dros" <Weston.Adamson@netapp.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Dave Jones <davej@redhat.com>,
        Linux Kernel <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Tejun Heo <tj@kernel.org>
Subject: Re: nfsd oops on Linus' current tree.
Message-ID: <20130103205221.GB2533@fieldses.org>
References: <20121221180824.GA27729@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA91197273D@SACEXCMBX04-PRD.hq.netapp.com>
 <20121221230849.GB29739@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA911972C73@SACEXCMBX04-PRD.hq.netapp.com>
 <20121221232609.GC29739@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA911972CA1@SACEXCMBX04-PRD.hq.netapp.com>
 <20121221234530.GA30048@fieldses.org>
 <0EC8763B847DB24D9ADF5EBD9CD7B4191259E4A2@SACEXCMBX02-PRD.hq.netapp.com>
 <20130103201120.GA2096@fieldses.org>
 <0EC8763B847DB24D9ADF5EBD9CD7B4191259F54D@SACEXCMBX02-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <0EC8763B847DB24D9ADF5EBD9CD7B4191259F54D@SACEXCMBX02-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 03, 2013 at 08:27:20PM +0000, Adamson, Dros wrote:
> 
> On Jan 3, 2013, at 3:11 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> > On Thu, Jan 03, 2013 at 04:28:37PM +0000, Adamson, Dros wrote:
> >> Hey, sorry for the late response, I've been on vacation.
> >> 
> >> On Dec 21, 2012, at 6:45 PM, J. Bruce Fields <bfields@fieldses.org>
> >> wrote:
> >> 
> >>> On Fri, Dec 21, 2012 at 11:36:51PM +0000, Myklebust, Trond wrote:
> >>>> Please reread what I said. There was no obvious circular
> >>>> dependency, because nfsiod and rpciod are separate workqueues, both
> >>>> created with WQ_MEM_RECLAIM.
> >>> 
> >>> Oh, sorry, I read "rpciod" as "nfsiod"!
> >>> 
> >>>> Dros' experience shows, however that a call to rpc_shutdown_client
> >>>> in an nfsiod work item will deadlock with rpciod if the RPC task's
> >>>> work item has been assigned to the same CPU as the one running the
> >>>> rpc_shutdown_client work item.
> >>>> 
> >>>> I can't tell right now if that is intentional (in which case the
> >>>> WARN_ON in the rpc code is correct), or if it is a bug in the
> >>>> workqueue code. For now, we're assuming the former.
> >>> 
> >>> Well, Documentation/workqueue.txt says:
> >>> 
> >>> 	"Each wq with WQ_MEM_RECLAIM set has an execution context
> >>> 	reserved for it.  If there is dependency among multiple work
> >>> 	items used during memory reclaim, they should be queued to
> >>> 	separate wq each with WQ_MEM_RECLAIM."
> >> 
> >> The deadlock we were seeing was:
> >> 
> >> - task A gets queued on rpciod workqueue and assigned kworker-0:0 -
> >> task B gets queued on rpciod workqueue and assigned the same kworker
> >> (kworker-0:0) - task A gets run, calls rpc_shutdown_client(), which
> >> will loop forever waiting for task B to run rpc_async_release() - task
> >> B will never run rpc_async_release() - it can't run until kworker-0:0
> >> is free, which won't happen until task A (rpc_shutdown_client) is done
> >> 
> >> The same deadlock happened when we tried queuing the tasks on a
> >> different workqueues -- queue_work() assigns the task to a kworker
> >> thread and it's luck of the draw if it's the same kworker as task A.
> >> We tried the different workqueue options, but nothing changed this
> >> behavior.
> >> 
> >> Once a work struct is queued, there is no way to back out of the
> >> deadlock.  From kernel/workqueue.c:insert_wq_barrier comment:
> >> 
> >> * Currently, a queued barrier can't be canceled.  This is because *
> >> try_to_grab_pending() can't determine whether the work to be *
> >> grabbed is at the head of the queue and thus can't clear LINKED *
> >> flag of the previous work while there must be a valid next work *
> >> after a work with LINKED flag set.
> >> 
> >> So once a work struct is queued and there is an ordering dependency
> >> (i.e. task A is before task B), there is no way to back task B out -
> >> so we can't just call cancel_work() or something on task B in
> >> rpc_shutdown_client.
> >> 
> >> The root of our issue is that rpc_shutdown_client is never safe to
> >> call from a workqueue context - it loops until there are no more
> >> tasks, marking tasks as killed and waiting for them to be cleaned up
> >> in each task's own workqueue context. Any tasks that have already been
> >> assigned to the same kworker thread will never have a chance to run
> >> this cleanup stage.
> >> 
> >> When fixing this deadlock, Trond and I discussed changing how
> >> rpc_shutdown_client works (making it workqueue safe), but Trond felt
> >> that it'd be better to just not call it from a workqueue context and
> >> print a warning if it is.
> >> 
> >> IIRC we tried using different workqueues with WQ_MEM_RECLAIM (with no
> >> success), but I'd argue that even if that did work it would still be
> >> very easy to call rpc_shutdown_client from the wrong context and MUCH
> >> harder to detect it.  It's also unclear to me if setting rpciod
> >> workqueue to WQ_MEM_RECLAIM would limit it to one kworker, etc...
> > 
> > Both rpciod and nfsiod already set WQ_MEM_RECLAIM.
> 
> Heh, oh yeah :)
> 
> > 
> > But, right, looking at kernel/workqueue.c, it seems that the dedicated
> > "rescuer" threads are invoked only in the case when work is stalled
> > because a new worker thread isn't allocated quickly enough.
> > 
> > So, what to do that's simplest enough that it would work for
> > post-rc2/stable?  I was happy having just a simple dedicated
> > thread--these are only started when nfsd is, so there's no real thread
> > proliferation problem.
> 
> That should work fine.

No, I meant I was happy having my workqueue handled by a single
dedicated thread, which I don't see a trivial way to do any more.

> The client went this way and spawns a new kthread before calling rpc_shutdown_client() from a workqueue context.  This should happen very infrequently.

I don't think I can do that, as I was really counting on being able to
wait for the client to shut down.  I'll think about it.

--b.

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:17870 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753001Ab1BOXrK convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Feb 2011 18:47:10 -0500
Subject: Re: [PATCH] nfs: don't queue synchronous NFSv4 close rpc_release
 to nfsiod
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20110215113053.345e3abc@tlielax.poochiereds.net>
References: <1297781939-1400-1-git-send-email-jlayton@redhat.com>
	 <1297783898.10103.22.camel@heimdal.trondhjem.org>
	 <20110215113053.345e3abc@tlielax.poochiereds.net>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 15 Feb 2011 18:47:04 -0500
Message-ID: <1297813624.10103.34.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2011-02-15 at 11:30 -0500, Jeff Layton wrote: 
> On Tue, 15 Feb 2011 10:31:38 -0500
> Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> 
> > On Tue, 2011-02-15 at 09:58 -0500, Jeff Layton wrote: 
> > > I recently had some of our QA people report some connectathon test
> > > failures in RHEL5 (2.6.18-based kernel). For some odd reason (maybe
> > > scheduling differences that make the race more likely?) the problem
> > > occurs more frequently on s390.
> > > 
> > > The problem generally manifests itself on NFSv4 as a race where an rmdir
> > > fails because a silly-renamed file in the directory wasn't deleted in
> > > time. Looking at traces, what you usually see is the failing rmdir
> > > attempt that fails with the sillydelete of the file that prevented it
> > > very soon afterward.
> > > 
> > > Silly deletes are handled via dentry_iput and in the case of a close on
> > > NFSv4, the last dentry reference is often held by the CLOSE RPC task.
> > > nfs4_do_close does the close as an async RPC task that it conditionally
> > > waits on depending on whether the close is synchronous or not.
> > > 
> > > It also sets the workqueue for the task to nfsiod_workqueue. When
> > > tk_workqueue is set, the rpc_release operation is queued to that
> > > workqueue. rpc_release is where the dentry reference held by the task is
> > > put. The caller has no way to wait for that to complete, so the close(2)
> > > syscall can easily return before the rpc_release call is ever done. In
> > > some cases, that rpc_release is delayed for a long enough to prevent a
> > > subsequent rmdir of the containing directory.
> > > 
> > > I believe this is a bug, or at least not ideal behavior. We should try
> > > not to have the close(2) call return in this situation until the
> > > sillydelete is done.
> > > 
> > > I've been able to reproduce this more reliably by adding a 100ms sleep
> > > at the top of nfs4_free_closedata. I've not seen it "in the wild" on
> > > mainline kernels, but it seems quite possible when a machine is heavily
> > > loaded.
<snip> 
> > There is no guarantee that rpc_wait_for_completion_task() will wait
> > until rpciod had called rpc_put_task(), in which case the above change
> > ends up with a dput() on the rpciod workqueue, and potential deadlocks.
> > 
> > Let's rather look at making rpc_put_task a little bit more safe, by
> > ensuring that rpciod always calls queue_work(), and by allowing other
> > callers to switch it off.
> > 
> 
> Ok, I see the potential deadlock. To make sure I understand correctly,
> is this what you'd like to see?
> 
> 1) If tk_workqueue is set, then queue rpc_release to that.
> 
> 2) If it's not, queue it to rpciod.
> 
> 3) add a flag to rpc_put_task (or a variant of that function) that
> calls rpc_release synchronously, and have nfs4_do_close use that
> variant when it puts the task.
> 
> ...does that sound correct? If so, then I'm not sure that it'll 100%
> close the race. It's still possible that the rpc_put_task call in
> rpc_release_task would be the last one. If so and we queue it to the
> workqueue, then we're back in the same situation.

Agreed. The problem is lack of atomicity between rpc_complete_task() and
rpc_put_task(). How about something like the following?

Cheers
  Trond
8<----------------------------------------------------------------------------------------- 

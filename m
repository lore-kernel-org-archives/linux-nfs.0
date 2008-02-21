From: Neil Brown <neilb@suse.de>
Subject: Re: Strange lockup during unmount in 2.6.22 - maybe rpciod
	deadlock?
Date: Thu, 21 Feb 2008 15:58:34 +1100
Message-ID: <18365.1274.387629.944796@notabene.brown>
References: <18310.37731.29874.582772@notabene.brown>
	<1200004896.13775.27.camel@heimdal.trondhjem.org>
	<18362.27251.619125.502340@notabene.brown>
	<1203449166.8156.85.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.suse.de ([195.135.220.2]:55945 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755446AbYBUE6a (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Feb 2008 23:58:30 -0500
In-Reply-To: message from Trond Myklebust on Tuesday February 19
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tuesday February 19, trond.myklebust@fys.uio.no wrote:
> 
> On Tue, 2008-02-19 at 16:34 +1100, Neil Brown wrote:
> > On Thursday January 10, trond.myklebust@fys.uio.no wrote:
> > > 
> > > On Fri, 2008-01-11 at 08:51 +1100, Neil Brown wrote:
> > > > 
> > > > I have a report of an unusual NFS deadlock in OpenSuSE 10.3, which is
> > > > based on 2.6.22.
> > > > 
> > > > People who like bugzilla can find a little more detail at:
> > > >     https://bugzilla.novell.com/show_bug.cgi?id=352878
> > > > 
> > > > We start with a "soft,intr" mount over a VPN on an unreliable network.
> > > > 
> > > > I assume an unmount happened (by autofs) while there was some
> > > > outstanding requests  - at least one was a COMMIT but I'm guessing
> > > > there were others.
> > > > 
> > > > When the last commit completed (probably timed-out) it put the open
> > > > context, dropped the last reference on the vfsmnt and so called
> > > > nfs_free_server and thence rpc_shutdown_client.
> > > > All this is happened in rpciod/0.
> > > > 
> > > > rpc_shutdown_client calls rpc_killall_tasks and waits for them all to
> > > > complete.  This deadlocks.
> > > > 
> > > > I'm wondering if some other request (read-ahead?) might need service
> > > > from rpciod/0 before it can complete.  This would mean that it cannot
> > > > complete until rpciod/0 is free, and rpciod/0 won't be free until it
> > > > completes.
> > > > 
> > > > Is this a credible scenario?
> > > 
> > > Yes, but I have a scenario that I think trumps it:
> > > 
> > >       * the call that puts the open context is being made in
> > >         nfs_commit_done (or possibly nfs_writeback_done), causing it to
> > >         wait until the rpc_killall_tasks completes.
> > >       * The problem is that rpc_killall_tasks won't complete until the
> > >         rpc_task that is stuck in nfs_commit_done/nfs_writeback_done
> > >         exits.
> > > 
> > > Urgh...
> > > 
> > > I'm surprised that we can get into this state, though. How is
> > > sys_umount() able to exit with either readaheads or writebacks still
> > > pending? Is this perhaps occurring on a lazy umount?
> > 
> > (finally getting back to this).
> > 
> > Yes, lazy umount is definitely implicated.  OpenSUSE sends 'autofs' a
> > SIGUSR1 when suspending, and autofs may use "umount -l" if it received
> > SIGUSR1.
> > 
> > I dug further and realised that if there is still a COMMIT in flight,
> > then there should still be an open file descriptor on the filesystem,
> > so when the COMMIT finishes, it won't be the last thing that is
> > holding the filesystem active, so this dead lock shouldn't happen...
> > 
> > Then I found this, which post-dates OpenSUSE-10.3.
> > 
> > ----------------------------
> > commit a49c3c7736a2e77931dabc5bc4a83fb4b2da013e
> > Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> > Date:   Thu Oct 18 18:03:27 2007 -0400
> > 
> >     NFSv4: Ensure that we wait for the CLOSE request to complete
> >     
> >     Otherwise, we do end up breaking close-to-open semantics. We also end up
> >     breaking some of the silly-rename tests in Connectathon on some setups.
> >     
> >     Please refer to the bug-report at
> >         http://bugzilla.linux-nfs.org/show_bug.cgi?id=150
> > ----------------------------
> > 
> > Which seems to suggest that a file descriptor could have been
> > completely closed before the final COMMIT returned, so that final
> > commit would be all that was holding the filesystem active.
> > 
> > So it could be that this bug has since been fixed.
> > 
> > Do you remember this patch well enough to be able to say if the bug it
> > fixes could have allowed a COMMIT to be outstanding when the last
> > nfs_file_release completed?
> > 
> > 
> > In my investigations, it seemed that (in -mm where I was looking)
> > nfs_wb_all can still complete before the last COMMIT returns, but only
> > if the process received a signal (the new TASK_KILLABLE seems to allow
> > this).  That seems to suggest that the bug could be there again.  If
> > you "umount -l", then kill the last process with a file open, there
> > could still be an in-fight COMMIT that is holding the filesystem
> > active. When it competes, you could get a deadlock.
> > 
> > It also seems to me that  "rpc_shutdown_client" doesn't really need
> > to loop.  The only reason I can see for calling rpc_killall_tasks
> > multiple times is in case a task schedules a sub-task before it
> > noticed that it has been killed.
> > 
> > That possibility can be avoided by flagging the client as 'dying' and
> > auto-killing any task that gets added to a dying client.
> > 
> > Once the multiple calls to rpc_killall_tasks aren't needed, there is
> > no need to wait until cl_tasks is empty as the kref counting will make
> > sure that the client gets cleaned up at the right time.
> > 
> > So maybe the following patch would still be useful to make sure that
> > rpc_shutdown_client never deadlocks??
> > 
> > Thanks,
> > NeilBrown
> > 
> > 
> > Signed-off-by: Neil Brown <neilb@suse.de>
> > 
> > ### Diffstat output
> >  ./include/linux/sunrpc/clnt.h |    2 ++
> >  ./net/sunrpc/clnt.c           |   10 +++++-----
> >  ./net/sunrpc/sched.c          |    4 ++++
> >  3 files changed, 11 insertions(+), 5 deletions(-)
> > 
> > diff .prev/include/linux/sunrpc/clnt.h ./include/linux/sunrpc/clnt.h
> > --- .prev/include/linux/sunrpc/clnt.h	2008-02-19 15:28:06.000000000 +1100
> > +++ ./include/linux/sunrpc/clnt.h	2008-02-19 15:51:40.000000000 +1100
> > @@ -42,6 +42,8 @@ struct rpc_clnt {
> >  
> >  	unsigned int		cl_softrtry : 1,/* soft timeouts */
> >  				cl_discrtry : 1,/* disconnect before retry */
> > +				cl_dying : 1,   /* shutting down, allow
> > +						 * no more tasks */
> >  				cl_autobind : 1;/* use getport() */
> >  
> >  	struct rpc_rtt *	cl_rtt;		/* RTO estimator data */
> > 
> > diff .prev/net/sunrpc/clnt.c ./net/sunrpc/clnt.c
> > --- .prev/net/sunrpc/clnt.c	2008-02-19 15:29:58.000000000 +1100
> > +++ ./net/sunrpc/clnt.c	2008-02-19 15:49:43.000000000 +1100
> > @@ -386,11 +386,11 @@ void rpc_shutdown_client(struct rpc_clnt
> >  	dprintk("RPC:       shutting down %s client for %s\n",
> >  			clnt->cl_protname, clnt->cl_server);
> >  
> > -	while (!list_empty(&clnt->cl_tasks)) {
> > -		rpc_killall_tasks(clnt);
> > -		wait_event_timeout(destroy_wait,
> > -			list_empty(&clnt->cl_tasks), 1*HZ);
> > -	}
> > +	spin_lock(&clnt->cl_lock);
> > +	clnt->cl_dying = 1;
> > +	spin_unlock(&clnt->cl_lock);
> > +
> > +	rpc_killall_tasks(clnt);
> >  
> >  	rpc_release_client(clnt);
> >  }
> > 
> > diff .prev/net/sunrpc/sched.c ./net/sunrpc/sched.c
> > --- .prev/net/sunrpc/sched.c	2008-02-19 15:25:45.000000000 +1100
> > +++ ./net/sunrpc/sched.c	2008-02-19 15:37:11.000000000 +1100
> > @@ -278,6 +278,10 @@ static void rpc_set_active(struct rpc_ta
> >  	if (clnt != NULL) {
> >  		spin_lock(&clnt->cl_lock);
> >  		list_add_tail(&task->tk_task, &clnt->cl_tasks);
> > +		if (clnt->cl_dying) {
> > +			task->tk_flags |= RPC_TASK_KILLED;
> > +			rpc_exit(task, -EIO);
> > +		}
> >  		spin_unlock(&clnt->cl_lock);
> >  	}
> >  }
> 
> Hmm... I'm not sure that I see how this will fix the deadlock.

The task that I saw deadlocked was waiting in rpc_shutdown_client.  I
removed the wait from rpc_shutdown_client, so presumably the task
cannot deadlock anymore.

> 
> The main problem here is that we can call nfs_inode_remove_request(),
> for instance, from within the rpciod callback nfs_writeback_done_full().
> This again may end up calling put_nfs_open_context(), which again calls
> mntput().
> 
> The deadlock then occurs because we still have the active rpc_task in
> nfs_writeback_done_full() calling mntput, and hence triggering the call
> to rpc_shutdown_client(), which cannot complete until said active
> rpc_task itself completes...

My question is:  *why* cannot rpc_shutdown_client complete until all
active rpc_tasks complete?  The use of reference counting ensure that
once they do all complete, the client will be finally released and any
relevant modules will also be released.

Is there really any need to wait for completion?

> 
> One solution may be to move the call to put_nfs_open_context() into the
> ->rpc_release() callback, since that is called after the task has been
> removed from the client task list, and so it is invisible to
> rpc_killall_tasks() and rpc_shutdown_client().
> The next problem then becomes SteveD's wait_event() in nfs_put_super(),
> which waits for all sillyrenames to complete. If rpciod is doing the
> waiting, then it can't service the asynchronous sillyrename tasks, and
> so it deadlocks again. In that case, it may indeed be that your fix
> above will help. I need to think a bit about that, since there are
> legitimate RPC calls that can be sent even after the call to
> rpc_killall_tasks (mainly the RPCSEC_GSS context teardown calls).


The current rpc_shutdown_client will kill such a task if it takes
longer than 1 second, won't it?

Maybe this is all the more reason to simply cut the client loose and
let it sort itself out with the help of rpciod and clean up when it
has finished.
> 
> Cheers
>   Trond

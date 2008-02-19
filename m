From: Neil Brown <neilb@suse.de>
Subject: Re: Strange lockup during unmount in 2.6.22 - maybe rpciod
	deadlock?
Date: Tue, 19 Feb 2008 16:34:43 +1100
Message-ID: <18362.27251.619125.502340@notabene.brown>
References: <18310.37731.29874.582772@notabene.brown>
	<1200004896.13775.27.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:40987 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751331AbYBSFek (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Feb 2008 00:34:40 -0500
In-Reply-To: message from Trond Myklebust on Thursday January 10
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thursday January 10, trond.myklebust@fys.uio.no wrote:
> 
> On Fri, 2008-01-11 at 08:51 +1100, Neil Brown wrote:
> > 
> > I have a report of an unusual NFS deadlock in OpenSuSE 10.3, which is
> > based on 2.6.22.
> > 
> > People who like bugzilla can find a little more detail at:
> >     https://bugzilla.novell.com/show_bug.cgi?id=352878
> > 
> > We start with a "soft,intr" mount over a VPN on an unreliable network.
> > 
> > I assume an unmount happened (by autofs) while there was some
> > outstanding requests  - at least one was a COMMIT but I'm guessing
> > there were others.
> > 
> > When the last commit completed (probably timed-out) it put the open
> > context, dropped the last reference on the vfsmnt and so called
> > nfs_free_server and thence rpc_shutdown_client.
> > All this is happened in rpciod/0.
> > 
> > rpc_shutdown_client calls rpc_killall_tasks and waits for them all to
> > complete.  This deadlocks.
> > 
> > I'm wondering if some other request (read-ahead?) might need service
> > from rpciod/0 before it can complete.  This would mean that it cannot
> > complete until rpciod/0 is free, and rpciod/0 won't be free until it
> > completes.
> > 
> > Is this a credible scenario?
> 
> Yes, but I have a scenario that I think trumps it:
> 
>       * the call that puts the open context is being made in
>         nfs_commit_done (or possibly nfs_writeback_done), causing it to
>         wait until the rpc_killall_tasks completes.
>       * The problem is that rpc_killall_tasks won't complete until the
>         rpc_task that is stuck in nfs_commit_done/nfs_writeback_done
>         exits.
> 
> Urgh...
> 
> I'm surprised that we can get into this state, though. How is
> sys_umount() able to exit with either readaheads or writebacks still
> pending? Is this perhaps occurring on a lazy umount?

(finally getting back to this).

Yes, lazy umount is definitely implicated.  OpenSUSE sends 'autofs' a
SIGUSR1 when suspending, and autofs may use "umount -l" if it received
SIGUSR1.

I dug further and realised that if there is still a COMMIT in flight,
then there should still be an open file descriptor on the filesystem,
so when the COMMIT finishes, it won't be the last thing that is
holding the filesystem active, so this dead lock shouldn't happen...

Then I found this, which post-dates OpenSUSE-10.3.

----------------------------
commit a49c3c7736a2e77931dabc5bc4a83fb4b2da013e
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Oct 18 18:03:27 2007 -0400

    NFSv4: Ensure that we wait for the CLOSE request to complete
    
    Otherwise, we do end up breaking close-to-open semantics. We also end up
    breaking some of the silly-rename tests in Connectathon on some setups.
    
    Please refer to the bug-report at
        http://bugzilla.linux-nfs.org/show_bug.cgi?id=150
----------------------------

Which seems to suggest that a file descriptor could have been
completely closed before the final COMMIT returned, so that final
commit would be all that was holding the filesystem active.

So it could be that this bug has since been fixed.

Do you remember this patch well enough to be able to say if the bug it
fixes could have allowed a COMMIT to be outstanding when the last
nfs_file_release completed?


In my investigations, it seemed that (in -mm where I was looking)
nfs_wb_all can still complete before the last COMMIT returns, but only
if the process received a signal (the new TASK_KILLABLE seems to allow
this).  That seems to suggest that the bug could be there again.  If
you "umount -l", then kill the last process with a file open, there
could still be an in-fight COMMIT that is holding the filesystem
active. When it competes, you could get a deadlock.

It also seems to me that  "rpc_shutdown_client" doesn't really need
to loop.  The only reason I can see for calling rpc_killall_tasks
multiple times is in case a task schedules a sub-task before it
noticed that it has been killed.

That possibility can be avoided by flagging the client as 'dying' and
auto-killing any task that gets added to a dying client.

Once the multiple calls to rpc_killall_tasks aren't needed, there is
no need to wait until cl_tasks is empty as the kref counting will make
sure that the client gets cleaned up at the right time.

So maybe the following patch would still be useful to make sure that
rpc_shutdown_client never deadlocks??

Thanks,
NeilBrown


Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./include/linux/sunrpc/clnt.h |    2 ++
 ./net/sunrpc/clnt.c           |   10 +++++-----
 ./net/sunrpc/sched.c          |    4 ++++
 3 files changed, 11 insertions(+), 5 deletions(-)

diff .prev/include/linux/sunrpc/clnt.h ./include/linux/sunrpc/clnt.h
--- .prev/include/linux/sunrpc/clnt.h	2008-02-19 15:28:06.000000000 +1100
+++ ./include/linux/sunrpc/clnt.h	2008-02-19 15:51:40.000000000 +1100
@@ -42,6 +42,8 @@ struct rpc_clnt {
 
 	unsigned int		cl_softrtry : 1,/* soft timeouts */
 				cl_discrtry : 1,/* disconnect before retry */
+				cl_dying : 1,   /* shutting down, allow
+						 * no more tasks */
 				cl_autobind : 1;/* use getport() */
 
 	struct rpc_rtt *	cl_rtt;		/* RTO estimator data */

diff .prev/net/sunrpc/clnt.c ./net/sunrpc/clnt.c
--- .prev/net/sunrpc/clnt.c	2008-02-19 15:29:58.000000000 +1100
+++ ./net/sunrpc/clnt.c	2008-02-19 15:49:43.000000000 +1100
@@ -386,11 +386,11 @@ void rpc_shutdown_client(struct rpc_clnt
 	dprintk("RPC:       shutting down %s client for %s\n",
 			clnt->cl_protname, clnt->cl_server);
 
-	while (!list_empty(&clnt->cl_tasks)) {
-		rpc_killall_tasks(clnt);
-		wait_event_timeout(destroy_wait,
-			list_empty(&clnt->cl_tasks), 1*HZ);
-	}
+	spin_lock(&clnt->cl_lock);
+	clnt->cl_dying = 1;
+	spin_unlock(&clnt->cl_lock);
+
+	rpc_killall_tasks(clnt);
 
 	rpc_release_client(clnt);
 }

diff .prev/net/sunrpc/sched.c ./net/sunrpc/sched.c
--- .prev/net/sunrpc/sched.c	2008-02-19 15:25:45.000000000 +1100
+++ ./net/sunrpc/sched.c	2008-02-19 15:37:11.000000000 +1100
@@ -278,6 +278,10 @@ static void rpc_set_active(struct rpc_ta
 	if (clnt != NULL) {
 		spin_lock(&clnt->cl_lock);
 		list_add_tail(&task->tk_task, &clnt->cl_tasks);
+		if (clnt->cl_dying) {
+			task->tk_flags |= RPC_TASK_KILLED;
+			rpc_exit(task, -EIO);
+		}
 		spin_unlock(&clnt->cl_lock);
 	}
 }

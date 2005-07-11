From: Olaf Kirch <okir@suse.de>
Subject: [PATCH]: Fix EJUKEBOX handling
Date: Mon, 11 Jul 2005 11:34:44 +0200
Message-ID: <20050711093444.GA29922@suse.de>
References: <1109028596/rjf@maui.cs.washington.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="r5Pyd7+fXNt84Ff3"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Drugd-0000Db-97
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 02:34:51 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.44)
	id 1Drugb-00065k-W5
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 02:34:51 -0700
To: "Richard J.Farnsworth" <rjf@maui.cs.washington.edu>
In-Reply-To: <1109028596/rjf@maui.cs.washington.edu>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


--r5Pyd7+fXNt84Ff3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi all,

this problem still seems to be present in 2.6.12, or am I
missing something?

The patch I've been using is attached below.

Olaf

On Thu, Feb 24, 2005 at 05:08:35AM +0000, Richard J.Farnsworth wrote:
> There seems to be a bug in the 2.6.11-rc code related to the handling
> of nfsd's EJUNKBOX error return.  The code for __rpc_execute in
> net/sunrpc/sched.c looks like:
> 
> =============================
> 
> static int __rpc_execute(struct rpc_task *task)
> {
> 	int		status = 0;
> 
> 	dprintk("RPC: %4d rpc_execute flgs %x\n",
> 				task->tk_pid, task->tk_flags);
> 
> 	BUG_ON(RPC_IS_QUEUED(task));
> 
>  restarted:
> 	while (1) {
> 		/*
> 		 * Garbage collection of pending timers...
> 		 */
> 		rpc_delete_timer(task);
> 
>  .....
> 
> 	if (task->tk_exit) {
> 		lock_kernel();
> >>>>		task->tk_exit(task);
> 		unlock_kernel();
> 		/* If tk_action is non-null, the user wants us to restart */
> 		if (task->tk_action) {
> 			if (!RPC_ASSASSINATED(task)) {
> 				/* Release RPC slot and buffer memory */
> 				if (task->tk_rqstp)
> 					xprt_release(task);
> 				rpc_free(task);
> 				goto restarted;
> 			}
> 			printk(KERN_ERR "RPC: dead task tries to walk away.\n");
> 		}
> 	}
> 
> =============================
> 
> If the tk_exit procedure (e.g., nfs_read_done) called at ">>>>" above
> detects EJUKEBOX as the result of the call, it will attempt to do
> an rpc_restart and rpc_delay on the task.  The rpc_delay will set a timer.
> However, when the main loop is re-entered via the "goto restarted",
> the first thing that happens is that all timers for the task are removed.
> This results in the RPC task hanging in an uninterruptible wait.
> 
> Am I missing something here or is this really a problem?
> 
> 
> 
> 
> 
> -------------------------------------------------------
> SF email is sponsored by - The IT Product Guide
> Read honest & candid reviews on hundreds of IT Products from real users.
> Discover which products truly live up to the hype. Start reading now.
> http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

--r5Pyd7+fXNt84Ff3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=sunrpc-restart-delay-fix

From: Olaf Kirch <okir@suse.de>
Subject: NFS: prevent hangs when NFS server returns EJUKEBOX

When an NFS server returns EJUKEBOX, we restart the RPC task, setting
a delay of a few seconds so that the call is retried a little later.
Unfortunately, we will kill the timer immediately afterwards when we
re-enter the main loop in __rpc_execute.

The fix below will kill the timer only when the task is actually
running.

Signed-off-by: okir@suse.de

Index: linux-2.6.10/net/sunrpc/sched.c
===================================================================
--- linux-2.6.10.orig/net/sunrpc/sched.c
+++ linux-2.6.10/net/sunrpc/sched.c
@@ -569,7 +569,8 @@ static int __rpc_execute(struct rpc_task
 		/*
 		 * Garbage collection of pending timers...
 		 */
-		rpc_delete_timer(task);
+		if (RPC_IS_RUNNING(task))
+			rpc_delete_timer(task);
 
 		/*
 		 * Execute any pending callback.

--r5Pyd7+fXNt84Ff3--


-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Bug in nfs client handling of EJUKEBOX
Date: Thu, 24 Feb 2005 12:02:53 -0800
Message-ID: <1109275373.11433.59.camel@lade.trondhjem.org>
References: <1109101592/oystr@hugh.cs.washington.edu>
	 <20050224115531.GF11336@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-/2Id9e6Tz24KW011j57k"
Cc: Jan Sanislo <oystr@cs.washington.edu>, nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D4PCW-0005eZ-H3
	for nfs@lists.sourceforge.net; Thu, 24 Feb 2005 12:03:08 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D4PCV-0000yF-PO
	for nfs@lists.sourceforge.net; Thu, 24 Feb 2005 12:03:08 -0800
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20050224115531.GF11336@suse.de>
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


--=-/2Id9e6Tz24KW011j57k
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

to den 24.02.2005 Klokka 12:55 (+0100) skreiv Olaf Kirch:

> I think this is a genuine problem. Previously, we would clear the timers
> only when the task was running, i.e. inside the if (RPC_RUNNING(task))
> branch. Proposed patch attached.

I'm thinking it might make sense to move that code into rpc_delete_timer
itself, and perhaps change the condition to "!RPC_IS_QUEUED(task)", so
that we test if the task is queued on a waitqueue, rather than if it is
still running.

How about the following?

Cheers,
  Trond
-- 
Trond Myklebust <trond.myklebust@fys.uio.no>

--=-/2Id9e6Tz24KW011j57k
Content-Disposition: inline; filename=linux-2.6.11-02-fix_rpc_delete.dif
Content-Type: text/plain; name=linux-2.6.11-02-fix_rpc_delete.dif; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

RPC: Don't kill timers when calling rpc_restart_call() after rpc_delay()

  Currently, if we restart an RPC call after having set an RPC delay (for
  instance in the case where an NFS EJUKEBOX error has occurred) the call
  to rpc_delete_timer() at the top of the rpc_execute() loop will
  kill off our timer.

  This patch causes rpc_delete_timer() to detect if the rpc_task is still
  queued on a wait queue, and refuse to delete the timer if this is the case.

  Problem diagnosed by Jan Sanislo and Olaf Kirch.
  Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 sched.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletion(-)

Index: linux-2.6.11-rc4/net/sunrpc/sched.c
===================================================================
--- linux-2.6.11-rc4.orig/net/sunrpc/sched.c
+++ linux-2.6.11-rc4/net/sunrpc/sched.c
@@ -132,9 +132,11 @@ __rpc_add_timer(struct rpc_task *task, r
  * Delete any timer for the current task. Because we use del_timer_sync(),
  * this function should never be called while holding queue->lock.
  */
-static inline void
+static void
 rpc_delete_timer(struct rpc_task *task)
 {
+	if (RPC_IS_QUEUED(task))
+		return;
 	if (test_and_clear_bit(RPC_TASK_HAS_TIMER, &task->tk_runstate)) {
 		del_singleshot_timer_sync(&task->tk_timer);
 		dprintk("RPC: %4d deleting timer\n", task->tk_pid);

--=-/2Id9e6Tz24KW011j57k--



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

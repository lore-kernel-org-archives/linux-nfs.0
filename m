From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] prevent sunrpc deadlock with debug on
Date: Wed, 29 Dec 2004 00:43:16 +0100
Message-ID: <1104277396.3976.10.camel@lade.trondhjem.org>
References: <20041216165714.GB2077@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-salaSYwwggT/pCxle8K5"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CjR0h-0006Ey-F7
	for nfs@lists.sourceforge.net; Tue, 28 Dec 2004 15:44:15 -0800
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CjR0g-0002Gf-55
	for nfs@lists.sourceforge.net; Tue, 28 Dec 2004 15:44:15 -0800
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20041216165714.GB2077@suse.de>
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


--=-salaSYwwggT/pCxle8K5
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

to den 16.12.2004 Klokka 17:57 (+0100) skreiv Olaf Kirch:
> Here's a patch we added to our kernel a while ago, but which
> I forgot to submit... here it is.

Olaf,

 The fix here is blatantly wrong, since you are releasing the lock and
then referencing rpc_wake_up_task() on the pointer it was protecting.
That is far worse than the "problem" it is trying to fix (which is after
all debugging code).

I think I've found the real bug that Shirly was seeing. Can you ask her
to test if this change fixes the actual problem?

Cheers,
  Trond

-- 
Trond Myklebust <trond.myklebust@fys.uio.no>

--=-salaSYwwggT/pCxle8K5
Content-Disposition: inline; filename=linux-2.6.10-03-fix_rpc_show_task.dif
Content-Type: text/plain; name=linux-2.6.10-03-fix_rpc_show_task.dif; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

RPC: rpc_tasks on the "all_tasks" list must be initialized first.

   Shirly Ma reported seeing problems with rpc_killall_tasks() causing
   the task->tk_magic debugging test to trigger.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 sched.c |   22 +++++++++++++---------
 1 files changed, 13 insertions(+), 9 deletions(-)

Index: linux-2.6.10/net/sunrpc/sched.c
===================================================================
--- linux-2.6.10.orig/net/sunrpc/sched.c	2004-12-26 01:34:01.000000000 +0100
+++ linux-2.6.10/net/sunrpc/sched.c	2004-12-29 00:41:16.223908500 +0100
@@ -25,6 +25,7 @@
 
 #ifdef RPC_DEBUG
 #define RPCDBG_FACILITY		RPCDBG_SCHED
+#define RPC_TASK_MAGIC_ID	0xf00baa
 static int			rpc_task_id;
 #endif
 
@@ -352,7 +353,7 @@ static void __rpc_do_wake_up_task(struct
 	dprintk("RPC: %4d __rpc_wake_up_task (now %ld)\n", task->tk_pid, jiffies);
 
 #ifdef RPC_DEBUG
-	if (task->tk_magic != 0xf00baa) {
+	if (unlikely(task->tk_magic != RPC_TASK_MAGIC_ID)) {
 		printk(KERN_ERR "RPC: attempt to wake up non-existing task!\n");
 		rpc_debug = ~0;
 		rpc_show_tasks();
@@ -766,11 +767,6 @@ void rpc_init_task(struct rpc_task *task
 	if (!RPC_IS_ASYNC(task))
 		init_waitqueue_head(&task->u.tk_wait.waitq);
 
-	/* Add to global list of all tasks */
-	spin_lock(&rpc_sched_lock);
-	list_add(&task->tk_task, &all_tasks);
-	spin_unlock(&rpc_sched_lock);
-
 	if (clnt) {
 		atomic_inc(&clnt->cl_users);
 		if (clnt->cl_softrtry)
@@ -780,9 +776,14 @@ void rpc_init_task(struct rpc_task *task
 	}
 
 #ifdef RPC_DEBUG
-	task->tk_magic = 0xf00baa;
+	task->tk_magic = RPC_TASK_MAGIC_ID;
 	task->tk_pid = rpc_task_id++;
 #endif
+	/* Add to global list of all tasks */
+	spin_lock(&rpc_sched_lock);
+	list_add_tail(&task->tk_task, &all_tasks);
+	spin_unlock(&rpc_sched_lock);
+
 	dprintk("RPC: %4d new task procpid %d\n", task->tk_pid,
 				current->pid);
 }
@@ -840,7 +841,7 @@ void rpc_release_task(struct rpc_task *t
 	dprintk("RPC: %4d release task\n", task->tk_pid);
 
 #ifdef RPC_DEBUG
-	if (task->tk_magic != 0xf00baa) {
+	if (unlikely(task->tk_magic != RPC_TASK_MAGIC_ID)) {
 		printk(KERN_ERR "RPC: attempt to release a non-existing task!\n");
 		rpc_debug = ~0;
 		rpc_show_tasks();
@@ -956,12 +957,15 @@ void rpc_killall_tasks(struct rpc_clnt *
 	 * Spin lock all_tasks to prevent changes...
 	 */
 	spin_lock(&rpc_sched_lock);
-	alltask_for_each(rovr, le, &all_tasks)
+	alltask_for_each(rovr, le, &all_tasks) {
+		if (! RPC_IS_ACTIVATED(rovr))
+			continue;
 		if (!clnt || rovr->tk_client == clnt) {
 			rovr->tk_flags |= RPC_TASK_KILLED;
 			rpc_exit(rovr, -EIO);
 			rpc_wake_up_task(rovr);
 		}
+	}
 	spin_unlock(&rpc_sched_lock);
 }
 

--=-salaSYwwggT/pCxle8K5--



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

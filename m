From: olof@austin.ibm.com
Subject: [PATCH] Race between rpciod() and rpciod_down() when shutting down
Date: Thu, 15 May 2003 18:01:23 -0500 (CDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.A41.4.44.0305151745370.28612-100000@forte.austin.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: trond.myklebust@fys.uio.no
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from e32.co.us.ibm.com ([32.97.110.130])
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19GRjM-0004ha-00
	for <nfs@lists.sourceforge.net>; Thu, 15 May 2003 16:01:45 -0700
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Below patch removes a timing window during which rpciod_down() will pass
the while(rpciod_pid) test, but go to sleep after rpciod() has woken up
sleepers on the rpciod_killer queue.

Unfortunately, there's no wait_for_completion_interruptible(). Instead of
rolling my own in the NFS code, I'll work on getting one added to the
kernel.  The uninterruptible sleep is a temporary solution until then, and
I'll make sure to follow up here if/when the function is added to
kernel/sched.c.

Patch is against 2.4.20. Same problem exists in 2.5, I can supply
a separate patch for that if needed.


Thanks,

Olof


--- linux-2.4.20/net/sunrpc/sched.c.orig	2002-11-28 17:53:16.000000000 -0600
+++ linux-2.4.20/net/sunrpc/sched.c	2003-05-15 17:43:45.000000000 -0500
@@ -19,6 +19,7 @@
 #include <linux/smp.h>
 #include <linux/smp_lock.h>
 #include <linux/spinlock.h>
+#include <linux/completion.h>

 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/xprt.h>
@@ -63,7 +64,7 @@ static LIST_HEAD(all_tasks);
  * rpciod-related stuff
  */
 static DECLARE_WAIT_QUEUE_HEAD(rpciod_idle);
-static DECLARE_WAIT_QUEUE_HEAD(rpciod_killer);
+static DECLARE_COMPLETION(rpciod_done);
 static DECLARE_MUTEX(rpciod_sema);
 static unsigned int		rpciod_users;
 static pid_t			rpciod_pid;
@@ -979,7 +980,7 @@ rpciod_task_pending(void)
 static int
 rpciod(void *ptr)
 {
-	wait_queue_head_t *assassin = (wait_queue_head_t*) ptr;
+	struct completion *done = ptr;
 	int		rounds = 0;

 	MOD_INC_USE_COUNT;
@@ -1027,7 +1028,7 @@ rpciod(void *ptr)
 	}

 	rpciod_pid = 0;
-	wake_up(assassin);
+	complete(done);

 	dprintk("RPC: rpciod exiting\n");
 	MOD_DEC_USE_COUNT;
@@ -1076,7 +1077,7 @@ rpciod_up(void)
 	/*
 	 * Create the rpciod thread and wait for it to start.
 	 */
-	error = kernel_thread(rpciod, &rpciod_killer, 0);
+	error = kernel_thread(rpciod, &rpciod_done, 0);
 	if (error < 0) {
 		printk(KERN_WARNING "rpciod_up: create thread failed, error=%d\n", error);
 		rpciod_users--;
@@ -1119,14 +1120,23 @@ rpciod_down(void)
 	/*
 	 * Display a message if we're going to wait longer.
 	 */
-	while (rpciod_pid) {
+	if (rpciod_pid)
 		dprintk("rpciod_down: waiting for pid %d to exit\n", rpciod_pid);
-		if (signalled()) {
-			dprintk("rpciod_down: caught signal\n");
-			break;
-		}
-		interruptible_sleep_on(&rpciod_killer);
-	}
+/*
+	XXX Unfortunately, there's no wait_for_completion_interruptible()
+	(yet), so we need to bite the bullet and sleep uninterruptible.
+	Once we have the infrastructure for it, we can switch over.
+	-OlofJ
+
+	if (wait_for_completion_interruptible(&rpciod_done))
+		dprintk("rpciod_down: caught signal\n");
+*/
+	/* Even if rpciod_pid is 0, we still need to call wait_for_completion().
+	 * Otherwise the "done" count of the completion structure will be off
+	 * by one since complete() increases it.
+	 */
+	wait_for_completion(&rpciod_done);
+
 	spin_lock_irqsave(&current->sigmask_lock, flags);
 	recalc_sigpending(current);
 	spin_unlock_irqrestore(&current->sigmask_lock, flags);




---
Olof Johansson                                          Office: 4E002/905
pSeries Linux Development                               IBM Systems Group
Email: olof@austin.ibm.com                            Phone: 512-838-9858
All opinions are my own and not those of IBM




-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

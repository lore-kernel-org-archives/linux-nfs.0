From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH][RFC] use completions instead of sleep_on for rpciod
Date: Sat, 7 Feb 2004 15:44:05 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040207144405.GA19416__19412.0656852194$1076193253@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ApVgs-0003Vu-LP
	for nfs@lists.sourceforge.net; Sat, 07 Feb 2004 08:52:22 -0800
Received: from electric-eye.fr.zoreil.com ([213.41.134.224] helo=fr.zoreil.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1ApVgr-0001gR-OK
	for nfs@lists.sourceforge.net; Sat, 07 Feb 2004 08:52:22 -0800
Received: from electric-eye.fr.zoreil.com (localhost.localdomain [127.0.0.1])
	by fr.zoreil.com (8.12.8/8.12.1) with ESMTP id i17Golgf010037
	for <nfs@lists.sourceforge.net>; Sat, 7 Feb 2004 17:50:47 +0100
Received: (from romieu@localhost)
	by electric-eye.fr.zoreil.com (8.12.8/8.12.1) id i17GokkP010036
	for nfs@lists.sourceforge.net; Sat, 7 Feb 2004 17:50:46 +0100
Resent-Message-Id: <200402071650.i17GokkP010036@electric-eye.fr.zoreil.com>
To: netdev@oss.sgi.com
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

[let's hope some sunrpc folks are on this list, too, the nfs list
 mentioned in MAINTAINERS refuses postings from non-subsribers..]

The rpciod shutdown code gives ugly sleep_on without BKL warnings in
-mm.  And it looks indeed somewhat racy.

The easy fix would be to simply use a completion as in the patch below,
but that removes all the signal fuzzing semantics the current code has.
I don't really understand why we want to cancel the operation by
signals, but I think it'd be better to leave that to people familar with
the code anyway..


--- 1.27/net/sunrpc/sched.c	Fri Jun 20 22:16:26 2003
+++ edited/net/sunrpc/sched.c	Wed Feb  4 06:29:02 2004
@@ -71,7 +71,7 @@
  * rpciod-related stuff
  */
 static DECLARE_WAIT_QUEUE_HEAD(rpciod_idle);
-static DECLARE_WAIT_QUEUE_HEAD(rpciod_killer);
+static DECLARE_COMPLETION(rpciod_killer);
 static DECLARE_MUTEX(rpciod_sema);
 static unsigned int		rpciod_users;
 static pid_t			rpciod_pid;
@@ -950,7 +950,6 @@
 static int
 rpciod(void *ptr)
 {
-	wait_queue_head_t *assassin = (wait_queue_head_t*) ptr;
 	int		rounds = 0;
 
 	lock_kernel();
@@ -992,11 +991,11 @@
 		rpciod_killall();
 	}
 
-	rpciod_pid = 0;
-	wake_up(assassin);
-
 	dprintk("RPC: rpciod exiting\n");
 	unlock_kernel();
+
+	rpciod_pid = 0;
+	complete_and_exit(&rpciod_killer, 0);
 	return 0;
 }
 
@@ -1041,7 +1040,7 @@
 	/*
 	 * Create the rpciod thread and wait for it to start.
 	 */
-	error = kernel_thread(rpciod, &rpciod_killer, 0);
+	error = kernel_thread(rpciod, NULL, 0);
 	if (error < 0) {
 		printk(KERN_WARNING "rpciod_up: create thread failed, error=%d\n", error);
 		rpciod_users--;
@@ -1057,8 +1056,6 @@
 void
 rpciod_down(void)
 {
-	unsigned long flags;
-
 	down(&rpciod_sema);
 	dprintk("rpciod_down pid %d sema %d\n", rpciod_pid, rpciod_users);
 	if (rpciod_users) {
@@ -1073,27 +1070,8 @@
 	}
 
 	kill_proc(rpciod_pid, SIGKILL, 1);
-	/*
-	 * Usually rpciod will exit very quickly, so we
-	 * wait briefly before checking the process id.
-	 */
-	clear_thread_flag(TIF_SIGPENDING);
-	yield();
-	/*
-	 * Display a message if we're going to wait longer.
-	 */
-	while (rpciod_pid) {
-		dprintk("rpciod_down: waiting for pid %d to exit\n", rpciod_pid);
-		if (signalled()) {
-			dprintk("rpciod_down: caught signal\n");
-			break;
-		}
-		interruptible_sleep_on(&rpciod_killer);
-	}
-	spin_lock_irqsave(&current->sighand->siglock, flags);
-	recalc_sigpending();
-	spin_unlock_irqrestore(&current->sighand->siglock, flags);
-out:
+	wait_for_completion(&rpciod_killer);
+ out:
 	up(&rpciod_sema);
 }
 


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

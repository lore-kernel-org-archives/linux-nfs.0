From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH][RFC] use completions instead of sleep_on for rpciod
Date: Sat, 7 Feb 2004 15:44:05 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040207144405.GA19416__36631.2978709631$1076193325@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ApYWG-0005yn-AF
	for nfs@lists.sourceforge.net; Sat, 07 Feb 2004 11:53:36 -0800
Received: from relay.uni-heidelberg.de ([129.206.100.212])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1ApYWF-0006Y1-Mg
	for nfs@lists.sourceforge.net; Sat, 07 Feb 2004 11:53:35 -0800
Received: from mail.iwr.uni-heidelberg.de (mail.iwr.uni-heidelberg.de [129.206.104.30])
	by relay.uni-heidelberg.de (8.12.10/8.12.10) with ESMTP id i17JrViv027813
	for <nfs@lists.sourceforge.net>; Sat, 7 Feb 2004 20:53:32 +0100 (MET)
Received: from kenzo.iwr.uni-heidelberg.de (IDENT:cwiXnx2ElZ9itX9Tm1UK2kth0QNE7j8x@kenzo.iwr.uni-heidelberg.de [129.206.120.29])
	by mail.iwr.uni-heidelberg.de (8.12.10/8.12.9) with ESMTP id i17JrUxf016631
	for <nfs@lists.sourceforge.net>; Sat, 7 Feb 2004 20:53:30 +0100 (MET)
Received: from kenzo.iwr.uni-heidelberg.de (localhost.localdomain [127.0.0.1])
	by kenzo.iwr.uni-heidelberg.de (8.12.8/8.12.8) with ESMTP id i17JrUkw001908
	for <nfs@lists.sourceforge.net>; Sat, 7 Feb 2004 20:53:30 +0100
Received: from localhost (bogdan@localhost)
	by kenzo.iwr.uni-heidelberg.de (8.12.8/8.12.8/Submit) with ESMTP id i17JrUpr001904
	for <nfs@lists.sourceforge.net>; Sat, 7 Feb 2004 20:53:30 +0100
To: netdev@oss.sgi.com
ReSent-Message-ID: <Pine.LNX.4.44.0402072053200.1398@kenzo.iwr.uni-heidelberg.de>
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

From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH][RFC] NLM: make sure that only one lockd is running at
 a time
Date: Thu, 4 Oct 2007 15:59:32 -0400
Message-ID: <20071004155932.cfd772d7.jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IdWr8-0006dw-Rr
	for nfs@lists.sourceforge.net; Thu, 04 Oct 2007 12:59:38 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IdWrD-00076o-OV
	for nfs@lists.sourceforge.net; Thu, 04 Oct 2007 12:59:40 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.8/8.13.1) with ESMTP id l94JxXWk004691
	for <nfs@lists.sourceforge.net>; Thu, 4 Oct 2007 15:59:33 -0400
Received: from pobox.corp.redhat.com (pobox.corp.redhat.com [10.11.255.20])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l94JxXfv029670
	for <nfs@lists.sourceforge.net>; Thu, 4 Oct 2007 15:59:33 -0400
Received: from tleilax.poochiereds.net (vpn-15-74.rdu.redhat.com [10.11.15.74])
	by pobox.corp.redhat.com (8.13.1/8.13.1) with SMTP id l94JxWL4031592
	for <nfs@lists.sourceforge.net>; Thu, 4 Oct 2007 15:59:32 -0400
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

I've been looking at a rather nasty oops in NLM code, and while it's
hard to conclusively prove it, my current thinking is that there were 2
competing lockd daemons running at the same time -- one in the process
of coming down and one up and working. The current code allows this,
but the data that's touched by lockd doesn't seem to be adequately
protected against this possibility.

The only protection for some of the data there appears to be the BKL,
and there are functions that definitely sleep. Since it doesn't appear
to be safe to have more than one lockd running at a time, we should
probably prevent that from happening. It also seems like the current
scheme of waiting for a bit and then forgetting about the existing
lockd thread could be papering over bugs that cause lockd to take a
long time coming down.

The following patch should prevent the kernel from spawning more than
1 lockd at a time, and causes the last caller of lockd_down to block
until lockd actually comes down.

This patch isn't well tested, so this is really more an RFC and a
starting point for discussion. The current code allows multiple lockd's
to run, but that doesn't seem to be  safe. Do we really need to allow
that to occur, or should it be prevented? Is it acceptable to allow
callers of lockd_down() to block this way?

Thoughts?

Signed-off-by: Jeff Layton <jlayton@redhat.com>

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 82e2192..96a580f 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -151,7 +151,7 @@ lockd(struct svc_rqst *rqstp)
 	 * NFS mount or NFS daemon has gone away, and we've been sent a
 	 * signal, or else another process has taken over our job.
 	 */
-	while ((nlmsvc_users || !signalled()) && nlmsvc_pid == current->pid) {
+	while (nlmsvc_users) {
 		long timeout = MAX_SCHEDULE_TIMEOUT;
 		char buf[RPC_MAX_ADDRBUFLEN];
 
@@ -200,15 +200,9 @@ lockd(struct svc_rqst *rqstp)
 	 * Check whether there's a new lockd process before
 	 * shutting down the hosts and clearing the slot.
 	 */
-	if (!nlmsvc_pid || current->pid == nlmsvc_pid) {
-		if (nlmsvc_ops)
-			nlmsvc_invalidate_all();
-		nlm_shutdown_hosts();
-		nlmsvc_pid = 0;
-		nlmsvc_serv = NULL;
-	} else
-		printk(KERN_DEBUG
-			"lockd: new process, skipping host shutdown\n");
+	if (nlmsvc_ops)
+		nlmsvc_invalidate_all();
+	nlm_shutdown_hosts();
 	wake_up(&lockd_exit);
 
 	/* Exit the RPC thread */
@@ -346,16 +340,14 @@ lockd_down(void)
 
 	kill_proc(nlmsvc_pid, SIGKILL, 1);
 	/*
-	 * Wait for the lockd process to exit, but since we're holding
-	 * the lockd semaphore, we can't wait around forever ...
+	 * Wait indefinitely for the lockd process to exit. Allowing a new
+	 * lockd to start before the old one has come down is dangerous and
+	 * may be papering over lockd bugs.
 	 */
 	clear_thread_flag(TIF_SIGPENDING);
-	interruptible_sleep_on_timeout(&lockd_exit, HZ);
-	if (nlmsvc_pid) {
-		printk(KERN_WARNING 
-			"lockd_down: lockd failed to exit, clearing pid\n");
-		nlmsvc_pid = 0;
-	}
+	sleep_on(&lockd_exit);
+	nlmsvc_pid = 0;
+	nlmsvc_serv = NULL;
 	spin_lock_irq(&current->sighand->siglock);
 	recalc_sigpending();
 	spin_unlock_irq(&current->sighand->siglock);

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

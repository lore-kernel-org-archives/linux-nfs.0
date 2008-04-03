From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 6/8] NLM/lockd: Fix a race when cancelling a blocking lock
Date: Thu, 03 Apr 2008 18:39:22 -0400
Message-ID: <20080403223922.12713.81442.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080403223921.12713.71396.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13124 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752084AbYDCW6D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Apr 2008 18:58:03 -0400
In-Reply-To: <20080403223921.12713.71396.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We shouldn't remove the lock from the list of blocked locks until the
CANCEL call has completed since we may be racing with a GRANTED callback.

Also ensure that we send an UNLOCK if the CANCEL request failed. Normally
that should only happen if the process gets hit with a fatal signal.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/lockd/clntproc.c |   43 ++++++++++++++++++++++++++++++++++---------
 1 files changed, 34 insertions(+), 9 deletions(-)

diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index ea1a694..37d1aa2 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -510,6 +510,7 @@ nlmclnt_lock(struct nlm_rqst *req, struct file_lock *fl)
 	struct nlm_res	*resp = &req->a_res;
 	struct nlm_wait *block = NULL;
 	unsigned char fl_flags = fl->fl_flags;
+	unsigned char fl_type;
 	int status = -ENOLCK;
 
 	if (nsm_monitor(host) < 0) {
@@ -525,13 +526,16 @@ nlmclnt_lock(struct nlm_rqst *req, struct file_lock *fl)
 
 	block = nlmclnt_prepare_block(host, fl);
 again:
+	/*
+	 * Initialise resp->status to a valid non-zero value,
+	 * since 0 == nlm_lck_granted
+	 */
+	resp->status = nlm_lck_blocked;
 	for(;;) {
 		/* Reboot protection */
 		fl->fl_u.nfs_fl.state = host->h_state;
 		status = nlmclnt_call(req, NLMPROC_LOCK);
 		if (status < 0)
-			goto out_unblock;
-		if (!req->a_args.block)
 			break;
 		/* Did a reclaimer thread notify us of a server reboot? */
 		if (resp->status ==  nlm_lck_denied_grace_period)
@@ -540,15 +544,22 @@ again:
 			break;
 		/* Wait on an NLM blocking lock */
 		status = nlmclnt_block(block, req, NLMCLNT_POLL_TIMEOUT);
-		/* if we were interrupted. Send a CANCEL request to the server
-		 * and exit
-		 */
 		if (status < 0)
-			goto out_unblock;
+			break;
 		if (resp->status != nlm_lck_blocked)
 			break;
 	}
 
+	/* if we were interrupted while blocking, then cancel the lock request
+	 * and exit
+	 */
+	if (resp->status == nlm_lck_blocked) {
+		if (!req->a_args.block)
+			goto out_unlock;
+		if (nlmclnt_cancel(host, req->a_args.block, fl) == 0)
+			goto out_unblock;
+	}
+
 	if (resp->status == nlm_granted) {
 		down_read(&host->h_rwsem);
 		/* Check whether or not the server has rebooted */
@@ -562,16 +573,30 @@ again:
 			printk(KERN_WARNING "%s: VFS is out of sync with lock manager!\n", __FUNCTION__);
 		up_read(&host->h_rwsem);
 		fl->fl_flags = fl_flags;
+		status = 0;
 	}
+	if (status < 0)
+		goto out_unlock;
 	status = nlm_stat_to_errno(resp->status);
 out_unblock:
 	nlmclnt_finish_block(block);
-	/* Cancel the blocked request if it is still pending */
-	if (resp->status == nlm_lck_blocked)
-		nlmclnt_cancel(host, req->a_args.block, fl);
 out:
 	nlm_release_call(req);
 	return status;
+out_unlock:
+	/* Fatal error: ensure that we remove the lock altogether */
+	dprintk("lockd: lock attempt ended in fatal error.\n"
+		"       Attempting to unlock.\n");
+	nlmclnt_finish_block(block);
+	fl_type = fl->fl_type;
+	fl->fl_type = F_UNLCK;
+	down_read(&host->h_rwsem);
+	do_vfs_lock(fl);
+	up_read(&host->h_rwsem);
+	fl->fl_type = fl_type;
+	fl->fl_flags = fl_flags;
+	nlmclnt_async_call(req, NLMPROC_UNLOCK, &nlmclnt_unlock_ops);
+	return status;
 }
 
 /*


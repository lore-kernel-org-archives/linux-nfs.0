From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 4/8] NLM: Remove the signal masking in
	nlmclnt_proc/nlmclnt_cancel
Date: Thu, 03 Apr 2008 18:39:22 -0400
Message-ID: <20080403223922.12713.2035.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080403223921.12713.71396.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:8113 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751923AbYDCW6A (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Apr 2008 18:58:00 -0400
In-Reply-To: <20080403223921.12713.71396.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The signal masks have been rendered obsolete by the preceding patch.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/lockd/clntproc.c |   42 +-----------------------------------------
 1 files changed, 1 insertions(+), 41 deletions(-)

diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index a34b709..5f13e03 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -155,8 +155,6 @@ static void nlmclnt_release_lockargs(struct nlm_rqst *req)
 int nlmclnt_proc(struct nlm_host *host, int cmd, struct file_lock *fl)
 {
 	struct nlm_rqst		*call;
-	sigset_t		oldset;
-	unsigned long		flags;
 	int			status;
 
 	nlm_get_host(host);
@@ -168,22 +166,6 @@ int nlmclnt_proc(struct nlm_host *host, int cmd, struct file_lock *fl)
 	/* Set up the argument struct */
 	nlmclnt_setlockargs(call, fl);
 
-	/* Keep the old signal mask */
-	spin_lock_irqsave(&current->sighand->siglock, flags);
-	oldset = current->blocked;
-
-	/* If we're cleaning up locks because the process is exiting,
-	 * perform the RPC call asynchronously. */
-	if ((IS_SETLK(cmd) || IS_SETLKW(cmd))
-	    && fl->fl_type == F_UNLCK
-	    && (current->flags & PF_EXITING)) {
-		sigfillset(&current->blocked);	/* Mask all signals */
-		recalc_sigpending();
-
-		call->a_flags = RPC_TASK_ASYNC;
-	}
-	spin_unlock_irqrestore(&current->sighand->siglock, flags);
-
 	if (IS_SETLK(cmd) || IS_SETLKW(cmd)) {
 		if (fl->fl_type != F_UNLCK) {
 			call->a_args.block = IS_SETLKW(cmd) ? 1 : 0;
@@ -198,11 +180,6 @@ int nlmclnt_proc(struct nlm_host *host, int cmd, struct file_lock *fl)
 	fl->fl_ops->fl_release_private(fl);
 	fl->fl_ops = NULL;
 
-	spin_lock_irqsave(&current->sighand->siglock, flags);
-	current->blocked = oldset;
-	recalc_sigpending();
-	spin_unlock_irqrestore(&current->sighand->siglock, flags);
-
 	dprintk("lockd: clnt proc returns %d\n", status);
 	return status;
 }
@@ -722,16 +699,6 @@ static const struct rpc_call_ops nlmclnt_unlock_ops = {
 static int nlmclnt_cancel(struct nlm_host *host, int block, struct file_lock *fl)
 {
 	struct nlm_rqst	*req;
-	unsigned long	flags;
-	sigset_t	oldset;
-	int		status;
-
-	/* Block all signals while setting up call */
-	spin_lock_irqsave(&current->sighand->siglock, flags);
-	oldset = current->blocked;
-	sigfillset(&current->blocked);
-	recalc_sigpending();
-	spin_unlock_irqrestore(&current->sighand->siglock, flags);
 
 	req = nlm_alloc_call(nlm_get_host(host));
 	if (!req)
@@ -741,14 +708,7 @@ static int nlmclnt_cancel(struct nlm_host *host, int block, struct file_lock *fl
 	nlmclnt_setlockargs(req, fl);
 	req->a_args.block = block;
 
-	status = nlmclnt_async_call(req, NLMPROC_CANCEL, &nlmclnt_cancel_ops);
-
-	spin_lock_irqsave(&current->sighand->siglock, flags);
-	current->blocked = oldset;
-	recalc_sigpending();
-	spin_unlock_irqrestore(&current->sighand->siglock, flags);
-
-	return status;
+	return nlmclnt_async_call(req, NLMPROC_CANCEL, &nlmclnt_cancel_ops);
 }
 
 static void nlmclnt_cancel_callback(struct rpc_task *task, void *data)


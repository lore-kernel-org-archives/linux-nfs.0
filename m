From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH 0/2] asynchronous unlock on exit
Date: Fri, 28 Mar 2008 17:37:56 -0400
Message-ID: <47ED6534.9080604@redhat.com>
References: <20080328201229.18158.52437.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010806040004010101050106"
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:41784 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756729AbYC1ViQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 28 Mar 2008 17:38:16 -0400
In-Reply-To: <20080328201229.18158.52437.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010806040004010101050106
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Trond Myklebust wrote:
> Hi Peter,
>
> The following patchsets takes up the theme from the NLM patch that you
> sent me a couple of weeks ago, and re-implements your fix in terms
> that are closer to the existing NFSv4 implementation (which you
> said was fine).

Hi, Trond.

Thanx for doing this!  I started recoding and got some stuff
working, but then got distracted by higher priority issues.

I wasn't pleased with the look and feel of the stuff that I
had developed, so I was waiting to finish it up.

Your patch is a bit more extensive than mine, which is good.

However, I think that nlmclnt_unlock() needs to wait until
the RPC is completed.  The original problem was test12() in
the Connectathon testsuite, which would occasionally fail.
It would fail because the parent would kill the child process
(actually the child of the child) and immediately attempt to
grab the lock.  This would fail because the child hadn't
completed releasing the lock yet.  There were some timing
dependencies in test12() itself, which I eliminated, but then
discovered that this wouldn't solve the entire problem.  (I
can send you the new version of test12(), if you wish.)

I think that it was this need to wait in nlmclnt_unlock()
which made the patch less pleasing than I wanted.  I have
attached the current version that I had worked on, just
for grins.

    Thanx...

       ps

--------------010806040004010101050106
Content-Type: text/plain;
 name="nlmclnt_unlock.devel"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nlmclnt_unlock.devel"

--- linux-2.6.24.i686/fs/lockd/clntproc.c.org
+++ linux-2.6.24.i686/fs/lockd/clntproc.c
@@ -155,8 +155,6 @@ static void nlmclnt_release_lockargs(str
 int nlmclnt_proc(struct nlm_host *host, int cmd, struct file_lock *fl)
 {
 	struct nlm_rqst		*call;
-	sigset_t		oldset;
-	unsigned long		flags;
 	int			status;
 
 	nlm_get_host(host);
@@ -168,22 +166,6 @@ int nlmclnt_proc(struct nlm_host *host, 
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
@@ -192,17 +174,14 @@ int nlmclnt_proc(struct nlm_host *host, 
 			status = nlmclnt_unlock(call, fl);
 	} else if (IS_GETLK(cmd))
 		status = nlmclnt_test(call, fl);
-	else
+	else {
+		nlm_release_call(call);
 		status = -EINVAL;
+	}
 
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
@@ -596,9 +575,34 @@ nlmclnt_reclaim(struct nlm_host *host, s
 static int
 nlmclnt_unlock(struct nlm_rqst *req, struct file_lock *fl)
 {
-	struct nlm_host	*host = req->a_host;
-	struct nlm_res	*resp = &req->a_res;
+	struct nlm_host *host = req->a_host;
+	sigset_t oldset;
+	unsigned long flags;
 	int status = 0;
+	struct rpc_message msg = {
+		.rpc_argp = &req->a_args,
+		.rpc_resp = &req->a_res,
+	};
+	struct rpc_clnt *clnt;
+	struct rpc_task	*task;
+	struct rpc_task_setup task_setup_data = {
+		.rpc_message = &msg,
+		.callback_ops = &nlmclnt_unlock_ops,
+		.callback_data = req,
+		.flags = RPC_TASK_ASYNC,
+	};
+
+	/* Keep the old signal mask */
+	spin_lock_irqsave(&current->sighand->siglock, flags);
+	oldset = current->blocked;
+
+	/* If we're cleaning up locks because the process is exiting,
+	 * perform the RPC call asynchronously. */
+	if (current->flags & PF_EXITING) {
+		sigfillset(&current->blocked);	/* Mask all signals */
+		recalc_sigpending();
+	}
+	spin_unlock_irqrestore(&current->sighand->siglock, flags);
 
 	/*
 	 * Note: the server is supposed to either grant us the unlock
@@ -609,27 +613,38 @@ nlmclnt_unlock(struct nlm_rqst *req, str
 	down_read(&host->h_rwsem);
 	if (do_vfs_lock(fl) == -ENOENT) {
 		up_read(&host->h_rwsem);
-		goto out;
+		goto err;
 	}
 	up_read(&host->h_rwsem);
 
-	if (req->a_flags & RPC_TASK_ASYNC)
-		return nlm_async_call(req, NLMPROC_UNLOCK, &nlmclnt_unlock_ops);
+	/* If we have no RPC client yet, create one. */
+	clnt = nlm_bind_host(host);
+	if (clnt == NULL)
+		goto err;
 
-	status = nlmclnt_call(req, NLMPROC_UNLOCK);
-	if (status < 0)
-		goto out;
+	msg.rpc_proc = &clnt->cl_procinfo[NLMPROC_UNLOCK];
+
+	task_setup_data.rpc_client = clnt;
 
-	if (resp->status == nlm_granted)
+	task = rpc_run_task(&task_setup_data);
+	status = PTR_ERR(task);
+	if (IS_ERR(task))
 		goto out;
 
-	if (resp->status != nlm_lck_denied_nolocks)
-		printk("lockd: unexpected unlock status: %d\n", resp->status);
-	/* What to do now? I'm out of my depth... */
-	status = -ENOLCK;
+	status = rpc_wait_for_completion_task(task);
+	rpc_put_task(task);
+
 out:
-	nlm_release_call(req);
+	spin_lock_irqsave(&current->sighand->siglock, flags);
+	current->blocked = oldset;
+	recalc_sigpending();
+	spin_unlock_irqrestore(&current->sighand->siglock, flags);
+
 	return status;
+
+err:
+	nlm_release_call(req);
+	goto out;
 }
 
 static void nlmclnt_unlock_callback(struct rpc_task *task, void *data)

--------------010806040004010101050106--

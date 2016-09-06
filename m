Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52764 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933737AbcIFPMp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Sep 2016 11:12:45 -0400
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 7/9] nfs: add code to allow client to wait on lock callbacks
Date: Tue,  6 Sep 2016 11:12:38 -0400
Message-Id: <1473174760-29859-8-git-send-email-jlayton@redhat.com>
In-Reply-To: <1473174760-29859-1-git-send-email-jlayton@redhat.com>
References: <1473174760-29859-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a waitqueue head to the client structure. Have clients set a wait
on that queue prior to requesting a lock from the server. If the lock
is blocked, then we can use that to wait for wakeups.

Note that we do need to do this "manually" since we need to set the
wait on the waitqueue prior to requesting the lock, but requesting a
lock can involve activities that can block.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/callback_proc.c    |  1 +
 fs/nfs/nfs4client.c       |  1 +
 fs/nfs/nfs4proc.c         | 67 ++++++++++++++++++++++++++++++++++++++++++++---
 include/linux/nfs_fs_sb.h |  1 +
 4 files changed, 67 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index a211af339f32..4ba6a8763f91 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -645,6 +645,7 @@ __be32 nfs4_callback_notify_lock(struct cb_notify_lock_args *args, void *dummy,
 	fc_tbl = &cps->clp->cl_session->fc_slot_table;
 
 	status = htonl(NFS4_OK);
+	__wake_up(&cps->clp->cl_lock_waitq, TASK_NORMAL, 0, &args->cbnl_owner);
 	return status;
 }
 #endif /* CONFIG_NFS_V4_1 */
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index cd3b7cfdde16..89b7a794ff10 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -199,6 +199,7 @@ struct nfs_client *nfs4_alloc_client(const struct nfs_client_initdata *cl_init)
 	clp->cl_minorversion = cl_init->minorversion;
 	clp->cl_mvops = nfs_v4_minor_ops[cl_init->minorversion];
 	clp->cl_mig_gen = 1;
+	init_waitqueue_head(&clp->cl_lock_waitq);
 	return clp;
 
 error:
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5573f19539a6..3a6669063c44 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5531,13 +5531,54 @@ int nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, const nfs4
 #define NFS4_LOCK_MINTIMEOUT (1 * HZ)
 #define NFS4_LOCK_MAXTIMEOUT (30 * HZ)
 
+struct nfs4_lock_waiter {
+	struct task_struct	*task;
+	struct nfs_lowner	*owner;
+	bool			notified;
+};
+
+static int
+nfs4_wake_lock_waiter(wait_queue_t *wait, unsigned int mode, int flags, void *key)
+{
+	int ret;
+	struct nfs4_lock_waiter	*waiter	= wait->private;
+	struct nfs_lowner	*lowner = key, *wowner = waiter->owner;
+
+	/* Don't wake anybody if the string looked bogus */
+	if (!lowner->id && !lowner->s_dev)
+		return 0;
+
+	/* Only wake if the callback was for the same owner */
+	if (lowner->clientid != wowner->clientid ||
+	    lowner->id != wowner->id		 ||
+	    lowner->s_dev != wowner->s_dev)
+		return 0;
+
+	waiter->notified = true;
+
+	/* override "private" so we can use default_wake_function */
+	wait->private = waiter->task;
+	ret = autoremove_wake_function(wait, mode, flags, key);
+	wait->private = waiter;
+	return ret;
+}
+
 /* 
  * sleep, with exponential backoff, and retry the LOCK operation. 
  */
 static unsigned long
-nfs4_set_lock_task_retry(unsigned long timeout)
+nfs4_wait_for_lock_retry(unsigned long timeout, wait_queue_head_t *q,
+			 struct nfs4_lock_waiter *waiter)
 {
+	unsigned long flags;
+
+	spin_lock_irqsave(&q->lock, flags);
+	if (waiter->notified) {
+		spin_unlock_irqrestore(&q->lock, flags);
+		return timeout;
+	}
 	set_current_state(TASK_INTERRUPTIBLE);
+	spin_unlock_irqrestore(&q->lock, flags);
 	freezable_schedule_timeout_unsafe(timeout);
 	timeout <<= 1;
 	if (timeout > NFS4_LOCK_MAXTIMEOUT)
@@ -6232,10 +6273,30 @@ nfs4_proc_lock(struct file *filp, int cmd, struct file_lock *request)
 		return status;
 
 	do {
+		struct nfs4_lock_state *lsp = request->fl_u.nfs4_fl.owner;
+		struct nfs_server *server = NFS_SERVER(lsp->ls_state->inode);
+		struct nfs_client *clp = server->nfs_client;
+		struct nfs_lowner owner = { .clientid = clp->cl_clientid,
+					    .id = lsp->ls_seqid.owner_id,
+					    .s_dev = server->s_dev };
+		struct nfs4_lock_waiter waiter = { .task  = current,
+						   .owner = &owner,
+						   .notified = false };
+		wait_queue_t wait;
+
+		init_wait(&wait);
+		wait.private = &waiter;
+		wait.func = nfs4_wake_lock_waiter;
+
+		add_wait_queue(&clp->cl_lock_waitq, &wait);
 		status = nfs4_proc_setlk(state, cmd, request);
-		if ((status != -EAGAIN) || IS_SETLK(cmd))
+		if ((status != -EAGAIN) || IS_SETLK(cmd)) {
+			finish_wait(&clp->cl_lock_waitq, &wait);
 			break;
-		timeout = nfs4_set_lock_task_retry(timeout);
+		}
+		timeout = nfs4_wait_for_lock_retry(timeout,
+					&clp->cl_lock_waitq, &waiter);
+		finish_wait(&clp->cl_lock_waitq, &wait);
 		status = -ERESTARTSYS;
 		if (signalled())
 			break;
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 14a762d2734d..fb2319a0ce65 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -103,6 +103,7 @@ struct nfs_client {
 #define NFS_SP4_MACH_CRED_WRITE    5	/* WRITE */
 #define NFS_SP4_MACH_CRED_COMMIT   6	/* COMMIT */
 #define NFS_SP4_MACH_CRED_PNFS_CLEANUP  7 /* LAYOUTRETURN */
+	wait_queue_head_t	cl_lock_waitq;
 #endif /* CONFIG_NFS_V4 */
 
 	/* Our own IP address, as a null-terminated string.
-- 
2.7.4


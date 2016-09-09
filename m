Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44712 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754231AbcIISsW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 9 Sep 2016 14:48:22 -0400
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@primarydata.com, Anna.Schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 10/10] nfs: ensure that the filehandle in CB_NOTIFY_LOCK request matches the inode
Date: Fri,  9 Sep 2016 14:48:20 -0400
Message-Id: <1473446900-1897-1-git-send-email-jlayton@redhat.com>
In-Reply-To: <1473446870-1831-1-git-send-email-jlayton@redhat.com>
References: <1473446870-1831-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/callback_proc.c |  3 +--
 fs/nfs/nfs4proc.c      | 10 +++++++++-
 2 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 590ed26232cc..478636b59d32 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -642,8 +642,7 @@ __be32 nfs4_callback_notify_lock(struct cb_notify_lock_args *args, void *dummy,
 
 	/* Don't wake anybody if the string looked bogus */
 	if (lowner->id || lowner->s_dev)
-		__wake_up(&cps->clp->cl_lock_waitq, TASK_NORMAL, 0,
-			  &args->cbnl_owner);
+		__wake_up(&cps->clp->cl_lock_waitq, TASK_NORMAL, 0, args);
 
 	return htonl(NFS4_OK);
 }
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 2271c44aff32..71325fc8c650 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6189,6 +6189,7 @@ nfs4_retry_setlk_simple(struct nfs4_state *state, int cmd,
 #ifdef CONFIG_NFS_V4_1
 struct nfs4_lock_waiter {
 	struct task_struct	*task;
+	struct inode		*inode;
 	struct nfs_lowner	*owner;
 	bool			notified;
 };
@@ -6197,8 +6198,10 @@ static int
 nfs4_wake_lock_waiter(wait_queue_t *wait, unsigned int mode, int flags, void *key)
 {
 	int ret;
+	struct cb_notify_lock_args *cbnl = key;
 	struct nfs4_lock_waiter	*waiter	= wait->private;
-	struct nfs_lowner	*lowner = key, *wowner = waiter->owner;
+	struct nfs_lowner	*lowner = &cbnl->cbnl_owner,
+				*wowner = waiter->owner;
 
 	/* Only wake if the callback was for the same owner */
 	if (lowner->clientid != wowner->clientid ||
@@ -6206,6 +6209,10 @@ nfs4_wake_lock_waiter(wait_queue_t *wait, unsigned int mode, int flags, void *ke
 	    lowner->s_dev != wowner->s_dev)
 		return 0;
 
+	/* Make sure it's for the right inode */
+	if (nfs_compare_fh(NFS_FH(waiter->inode), &cbnl->cbnl_fh))
+		return 0;
+
 	waiter->notified = true;
 
 	/* override "private" so we can use default_wake_function */
@@ -6228,6 +6235,7 @@ nfs4_retry_setlk(struct nfs4_state *state, int cmd, struct file_lock *request)
 				    .id = lsp->ls_seqid.owner_id,
 				    .s_dev = server->s_dev };
 	struct nfs4_lock_waiter waiter = { .task  = current,
+					   .inode = state->inode,
 					   .owner = &owner,
 					   .notified = false };
 	wait_queue_t wait;
-- 
2.7.4


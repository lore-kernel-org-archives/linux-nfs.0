Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:42302 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751515AbeCRMhI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 18 Mar 2018 08:37:08 -0400
From: Jeff Layton <jlayton@kernel.org>
To: trondmy@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 3/3] nfs4: wake any lock waiters on successful RECLAIM_COMPLETE
Date: Sun, 18 Mar 2018 08:37:03 -0400
Message-Id: <20180318123703.11256-4-jlayton@kernel.org>
In-Reply-To: <20180318123703.11256-1-jlayton@kernel.org>
References: <20180318123703.11256-1-jlayton@kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jeff Layton <jlayton@redhat.com>

If we have a RECLAIM_COMPLETE with a populated cl_lock_waitq, then
that implies that a reconnect has occurred. Since we can't expect a
CB_NOTIFY_LOCK callback at that point, just wake up the entire queue
so that all the tasks can re-poll for their locks.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/nfs4proc.c | 26 ++++++++++++++++----------
 1 file changed, 16 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 669ba9211177..ec68edce6cc3 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6621,20 +6621,24 @@ static int
 nfs4_wake_lock_waiter(wait_queue_entry_t *wait, unsigned int mode, int flags, void *key)
 {
 	int ret;
-	struct cb_notify_lock_args *cbnl = key;
 	struct nfs4_lock_waiter	*waiter	= wait->private;
-	struct nfs_lowner	*lowner = &cbnl->cbnl_owner,
-				*wowner = waiter->owner;
 
-	/* Only wake if the callback was for the same owner. */
-	if (lowner->id != wowner->id || lowner->s_dev != wowner->s_dev)
-		return 0;
+	/* NULL key means to wake up everyone */
+	if (key) {
+		struct cb_notify_lock_args	*cbnl = key;
+		struct nfs_lowner		*lowner = &cbnl->cbnl_owner,
+						*wowner = waiter->owner;
 
-	/* Make sure it's for the right inode */
-	if (nfs_compare_fh(NFS_FH(waiter->inode), &cbnl->cbnl_fh))
-		return 0;
+		/* Only wake if the callback was for the same owner. */
+		if (lowner->id != wowner->id || lowner->s_dev != wowner->s_dev)
+			return 0;
 
-	waiter->notified = true;
+		/* Make sure it's for the right inode */
+		if (nfs_compare_fh(NFS_FH(waiter->inode), &cbnl->cbnl_fh))
+			return 0;
+
+		waiter->notified = true;
+	}
 
 	/* override "private" so we can use default_wake_function */
 	wait->private = waiter->task;
@@ -8413,6 +8417,8 @@ static int nfs41_reclaim_complete_handle_errors(struct rpc_task *task, struct nf
 {
 	switch(task->tk_status) {
 	case 0:
+		wake_up_all(&clp->cl_lock_waitq);
+		/* Fallthrough */
 	case -NFS4ERR_COMPLETE_ALREADY:
 	case -NFS4ERR_WRONG_CRED: /* What to do here? */
 		break;
-- 
2.14.3


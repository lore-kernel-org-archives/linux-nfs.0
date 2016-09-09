Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60584 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754231AbcIISr4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 9 Sep 2016 14:47:56 -0400
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@primarydata.com, Anna.Schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 08/10] nfs: move nfs4 lock retry attempt loop to a separate function
Date: Fri,  9 Sep 2016 14:47:49 -0400
Message-Id: <1473446870-1831-9-git-send-email-jlayton@redhat.com>
In-Reply-To: <1473446870-1831-1-git-send-email-jlayton@redhat.com>
References: <1473446870-1831-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This also consolidates the waiting logic into a single function,
instead of having it spread across two like it is now.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/nfs4proc.c | 51 ++++++++++++++++++++++++---------------------------
 1 file changed, 24 insertions(+), 27 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index a50ba7975449..66fa2af03b33 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5530,22 +5530,6 @@ int nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, const nfs4
 	return err;
 }
 
-#define NFS4_LOCK_MINTIMEOUT (1 * HZ)
-#define NFS4_LOCK_MAXTIMEOUT (30 * HZ)
-
-/* 
- * sleep, with exponential backoff, and retry the LOCK operation. 
- */
-static unsigned long
-nfs4_set_lock_task_retry(unsigned long timeout)
-{
-	freezable_schedule_timeout_interruptible(timeout);
-	timeout <<= 1;
-	if (timeout > NFS4_LOCK_MAXTIMEOUT)
-		return NFS4_LOCK_MAXTIMEOUT;
-	return timeout;
-}
-
 static int _nfs4_proc_getlk(struct nfs4_state *state, int cmd, struct file_lock *request)
 {
 	struct inode *inode = state->inode;
@@ -6178,12 +6162,34 @@ static int nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock *
 	return err;
 }
 
+#define NFS4_LOCK_MINTIMEOUT (1 * HZ)
+#define NFS4_LOCK_MAXTIMEOUT (30 * HZ)
+
+static int
+nfs4_retry_setlk(struct nfs4_state *state, int cmd, struct file_lock *request)
+{
+	int status;
+	unsigned long timeout = NFS4_LOCK_MINTIMEOUT;
+
+	do {
+		status = nfs4_proc_setlk(state, cmd, request);
+		if ((status != -EAGAIN) || IS_SETLK(cmd))
+			break;
+		freezable_schedule_timeout_interruptible(timeout);
+		timeout *= 2;
+		timeout = min_t(unsigned long, NFS4_LOCK_MAXTIMEOUT, timeout);
+		status = -ERESTARTSYS;
+		if (signalled())
+			break;
+	} while(status < 0);
+	return status;
+}
+
 static int
 nfs4_proc_lock(struct file *filp, int cmd, struct file_lock *request)
 {
 	struct nfs_open_context *ctx;
 	struct nfs4_state *state;
-	unsigned long timeout = NFS4_LOCK_MINTIMEOUT;
 	int status;
 
 	/* verify open state */
@@ -6232,16 +6238,7 @@ nfs4_proc_lock(struct file *filp, int cmd, struct file_lock *request)
 	if (status != 0)
 		return status;
 
-	do {
-		status = nfs4_proc_setlk(state, cmd, request);
-		if ((status != -EAGAIN) || IS_SETLK(cmd))
-			break;
-		timeout = nfs4_set_lock_task_retry(timeout);
-		status = -ERESTARTSYS;
-		if (signalled())
-			break;
-	} while(status < 0);
-	return status;
+	return nfs4_retry_setlk(state, cmd, request);
 }
 
 int nfs4_lock_delegation_recall(struct file_lock *fl, struct nfs4_state *state, const nfs4_stateid *stateid)
-- 
2.7.4


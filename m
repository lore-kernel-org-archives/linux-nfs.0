Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f173.google.com ([209.85.160.173]:36122 "EHLO
	mail-yk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755298AbbITUpO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 20 Sep 2015 16:45:14 -0400
Received: by ykdt18 with SMTP id t18so87232064ykd.3
        for <linux-nfs@vger.kernel.org>; Sun, 20 Sep 2015 13:45:13 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/5] NFSv4: Refactor NFSv4 error handling
Date: Sun, 20 Sep 2015 16:45:07 -0400
Message-Id: <1442781911-76248-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Prepare for unification of the synchronous and asynchronous error
handling.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4_fs.h  |  6 ++++--
 fs/nfs/nfs4proc.c | 38 +++++++++++++++++++++++++++++++-------
 2 files changed, 35 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 50cfc4ca7a02..4afdee420d25 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -183,10 +183,12 @@ struct nfs4_state {
 
 
 struct nfs4_exception {
-	long timeout;
-	int retry;
 	struct nfs4_state *state;
 	struct inode *inode;
+	long timeout;
+	unsigned char delay : 1,
+		      recovering : 1,
+		      retry : 1;
 };
 
 struct nfs4_state_recovery_ops {
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ef6b46e08ac6..a77736bc9d7b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -344,13 +344,15 @@ static int nfs4_delay(struct rpc_clnt *clnt, long *timeout)
 /* This is the error handling routine for processes that are allowed
  * to sleep.
  */
-int nfs4_handle_exception(struct nfs_server *server, int errorcode, struct nfs4_exception *exception)
+int nfs4_do_handle_exception(struct nfs_server *server, int errorcode, struct nfs4_exception *exception)
 {
 	struct nfs_client *clp = server->nfs_client;
 	struct nfs4_state *state = exception->state;
 	struct inode *inode = exception->inode;
 	int ret = errorcode;
 
+	exception->delay = 0;
+	exception->recovering = 0;
 	exception->retry = 0;
 	switch(errorcode) {
 		case 0:
@@ -411,9 +413,9 @@ int nfs4_handle_exception(struct nfs_server *server, int errorcode, struct nfs4_
 			}
 		case -NFS4ERR_GRACE:
 		case -NFS4ERR_DELAY:
-			ret = nfs4_delay(server->client, &exception->timeout);
-			if (ret != 0)
-				break;
+			exception->delay = 1;
+			return 0;
+
 		case -NFS4ERR_RETRY_UNCACHED_REP:
 		case -NFS4ERR_OLD_STATEID:
 			exception->retry = 1;
@@ -434,9 +436,31 @@ int nfs4_handle_exception(struct nfs_server *server, int errorcode, struct nfs4_
 	/* We failed to handle the error */
 	return nfs4_map_errors(ret);
 wait_on_recovery:
-	ret = nfs4_wait_clnt_recover(clp);
-	if (test_bit(NFS_MIG_FAILED, &server->mig_status))
-		return -EIO;
+	exception->recovering = 1;
+	return 0;
+}
+
+/* This is the error handling routine for processes that are allowed
+ * to sleep.
+ */
+int nfs4_handle_exception(struct nfs_server *server, int errorcode, struct nfs4_exception *exception)
+{
+	struct nfs_client *clp = server->nfs_client;
+	int ret;
+
+	ret = nfs4_do_handle_exception(server, errorcode, exception);
+	if (exception->delay) {
+		ret = nfs4_delay(server->client, &exception->timeout);
+		goto out_retry;
+	}
+	if (exception->recovering) {
+		ret = nfs4_wait_clnt_recover(clp);
+		if (test_bit(NFS_MIG_FAILED, &server->mig_status))
+			return -EIO;
+		goto out_retry;
+	}
+	return ret;
+out_retry:
 	if (ret == 0)
 		exception->retry = 1;
 	return ret;
-- 
2.4.3


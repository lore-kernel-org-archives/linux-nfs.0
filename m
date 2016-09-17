Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:34301 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753327AbcIQFNr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 17 Sep 2016 01:13:47 -0400
Received: by mail-io0-f194.google.com with SMTP id y139so2395462ioy.1
        for <linux-nfs@vger.kernel.org>; Fri, 16 Sep 2016 22:13:47 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v5 12/25] NFSv4.1: FREE_STATEID can be asynchronous
Date: Sat, 17 Sep 2016 01:13:20 -0400
Message-Id: <1474089213-104014-13-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1474089213-104014-12-git-send-email-trond.myklebust@primarydata.com>
References: <1474089213-104014-1-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-2-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-3-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-4-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-5-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-6-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-7-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-8-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-9-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-10-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-11-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-12-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Nothing should need to be serialised with FREE_STATEID on the client,
so let's make the RPC call always asynchronous. Also constify the
stateid argument.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 31 ++++++++++++-------------------
 1 file changed, 12 insertions(+), 19 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 33ca6d768bd2..a53caeb73f75 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -99,8 +99,8 @@ static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 #ifdef CONFIG_NFS_V4_1
 static int nfs41_test_stateid(struct nfs_server *, nfs4_stateid *,
 		struct rpc_cred *);
-static int nfs41_free_stateid(struct nfs_server *, nfs4_stateid *,
-		struct rpc_cred *);
+static int nfs41_free_stateid(struct nfs_server *, const nfs4_stateid *,
+		struct rpc_cred *, bool);
 #endif
 
 #ifdef CONFIG_NFS_V4_SECURITY_LABEL
@@ -2443,7 +2443,7 @@ static int nfs41_test_and_free_expired_stateid(struct nfs_server *server,
 	}
 out_free:
 	/* Ack the revoked state to the server */
-	nfs41_free_stateid(server, stateid, cred);
+	nfs41_free_stateid(server, stateid, cred, true);
 	return -NFS4ERR_EXPIRED;
 }
 
@@ -8722,7 +8722,7 @@ static const struct rpc_call_ops nfs41_free_stateid_ops = {
 };
 
 static struct rpc_task *_nfs41_free_stateid(struct nfs_server *server,
-		nfs4_stateid *stateid,
+		const nfs4_stateid *stateid,
 		struct rpc_cred *cred,
 		bool privileged)
 {
@@ -8765,38 +8765,31 @@ static struct rpc_task *_nfs41_free_stateid(struct nfs_server *server,
  * @server: server / transport on which to perform the operation
  * @stateid: state ID to release
  * @cred: credential
+ * @is_recovery: set to true if this call needs to be privileged
  *
- * Returns NFS_OK if the server freed "stateid".  Otherwise a
- * negative NFS4ERR value is returned.
+ * Note: this function is always asynchronous.
  */
 static int nfs41_free_stateid(struct nfs_server *server,
-		nfs4_stateid *stateid,
-		struct rpc_cred *cred)
+		const nfs4_stateid *stateid,
+		struct rpc_cred *cred,
+		bool is_recovery)
 {
 	struct rpc_task *task;
-	int ret;
 
-	task = _nfs41_free_stateid(server, stateid, cred, true);
+	task = _nfs41_free_stateid(server, stateid, cred, is_recovery);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
-	ret = rpc_wait_for_completion_task(task);
-	if (!ret)
-		ret = task->tk_status;
 	rpc_put_task(task);
-	return ret;
+	return 0;
 }
 
 static void
 nfs41_free_lock_state(struct nfs_server *server, struct nfs4_lock_state *lsp)
 {
-	struct rpc_task *task;
 	struct rpc_cred *cred = lsp->ls_state->owner->so_cred;
 
-	task = _nfs41_free_stateid(server, &lsp->ls_stateid, cred, false);
+	nfs41_free_stateid(server, &lsp->ls_stateid, cred, false);
 	nfs4_free_lock_state(server, lsp);
-	if (IS_ERR(task))
-		return;
-	rpc_put_task(task);
 }
 
 static bool nfs41_match_stateid(const nfs4_stateid *s1,
-- 
2.7.4


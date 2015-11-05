Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:60822 "HELO
	discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S932414AbbKEAp0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Nov 2015 19:45:26 -0500
From: Andrew Elble <aweits@rit.edu>
To: linux-nfs@vger.kernel.org, trond.myklebust@primarydata.com
Cc: Andrew Elble <aweits@rit.edu>
Subject: [PATCH RFC v3] nfs: nfs_do_return_delegation() needs to send FREE_STATEID
Date: Wed,  4 Nov 2015 19:43:48 -0500
Message-Id: <1446684228-37765-1-git-send-email-aweits@rit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In the NFS4.1 case, revoked delegations need to be processed via
FREE_STATEID, not simply forgotten.

Fixes: 869f9dfa4d6d ("NFSv4: Fix races between nfs_remove_bad_delegation() and delegation return")
Signed-off-by: Andrew Elble <aweits@rit.edu>
---
 fs/nfs/delegation.c |  6 ++++++
 fs/nfs/nfs4_fs.h    |  2 ++
 fs/nfs/nfs4proc.c   | 18 ++++++++++--------
 3 files changed, 18 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 5166adcfc0fb..dc971adb7af9 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -205,6 +205,12 @@ static int nfs_do_return_delegation(struct inode *inode, struct nfs_delegation *
 				delegation->cred,
 				&delegation->stateid,
 				issync);
+#if defined(CONFIG_NFS_V4_1)
+	else if (NFS_SERVER(inode)->nfs_client->cl_minorversion)
+		res = nfs41_free_stateid(NFS_SERVER(inode),
+					&delegation->stateid,
+					delegation->cred, issync);
+#endif /* CONFIG_NFS_V4_1 */
 	nfs_free_delegation(delegation);
 	return res;
 }
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 4afdee420d25..862fe4e44634 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -261,6 +261,8 @@ extern int nfs4_set_rw_stateid(nfs4_stateid *stateid,
 		fmode_t fmode);
 
 #if defined(CONFIG_NFS_V4_1)
+int nfs41_free_stateid(struct nfs_server *, nfs4_stateid *,
+		struct rpc_cred *, int issync);
 static inline struct nfs4_session *nfs4_get_session(const struct nfs_server *server)
 {
 	return server->nfs_client->cl_session;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7ed8f2cd97f8..77811c727703 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -88,8 +88,6 @@ static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 #ifdef CONFIG_NFS_V4_1
 static int nfs41_test_stateid(struct nfs_server *, nfs4_stateid *,
 		struct rpc_cred *);
-static int nfs41_free_stateid(struct nfs_server *, nfs4_stateid *,
-		struct rpc_cred *);
 #endif
 
 #ifdef CONFIG_NFS_V4_SECURITY_LABEL
@@ -2347,7 +2345,7 @@ static void nfs41_check_delegation_stateid(struct nfs4_state *state)
 		/* Free the stateid unless the server explicitly
 		 * informs us the stateid is unrecognized. */
 		if (status != -NFS4ERR_BAD_STATEID)
-			nfs41_free_stateid(server, &stateid, cred);
+			nfs41_free_stateid(server, &stateid, cred, 1);
 		nfs_finish_clear_delegation_stateid(state);
 	}
 
@@ -2381,7 +2379,7 @@ static int nfs41_check_open_stateid(struct nfs4_state *state)
 		/* Free the stateid unless the server explicitly
 		 * informs us the stateid is unrecognized. */
 		if (status != -NFS4ERR_BAD_STATEID)
-			nfs41_free_stateid(server, stateid, cred);
+			nfs41_free_stateid(server, stateid, cred, 1);
 
 		clear_bit(NFS_O_RDONLY_STATE, &state->flags);
 		clear_bit(NFS_O_WRONLY_STATE, &state->flags);
@@ -6033,7 +6031,7 @@ static int nfs41_check_expired_locks(struct nfs4_state *state)
 				if (status != -NFS4ERR_BAD_STATEID)
 					nfs41_free_stateid(server,
 							&lsp->ls_stateid,
-							cred);
+							cred, 1);
 				clear_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags);
 				ret = status;
 			}
@@ -8553,19 +8551,23 @@ static struct rpc_task *_nfs41_free_stateid(struct nfs_server *server,
  * Returns NFS_OK if the server freed "stateid".  Otherwise a
  * negative NFS4ERR value is returned.
  */
-static int nfs41_free_stateid(struct nfs_server *server,
+int nfs41_free_stateid(struct nfs_server *server,
 		nfs4_stateid *stateid,
-		struct rpc_cred *cred)
+		struct rpc_cred *cred,
+		int issync)
 {
 	struct rpc_task *task;
-	int ret;
+	int ret = 0;
 
 	task = _nfs41_free_stateid(server, stateid, cred, true);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
+	if (!issync)
+		goto out;
 	ret = rpc_wait_for_completion_task(task);
 	if (!ret)
 		ret = task->tk_status;
+out:
 	rpc_put_task(task);
 	return ret;
 }
-- 
2.4.6


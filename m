Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:35270 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756184AbcIQFNr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 17 Sep 2016 01:13:47 -0400
Received: by mail-io0-f196.google.com with SMTP id q92so2389733ioi.2
        for <linux-nfs@vger.kernel.org>; Fri, 16 Sep 2016 22:13:46 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v5 11/25] NFSv4.1: Ensure we always run TEST/FREE_STATEID on locks
Date: Sat, 17 Sep 2016 01:13:19 -0400
Message-Id: <1474089213-104014-12-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1474089213-104014-11-git-send-email-trond.myklebust@primarydata.com>
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
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Right now, we're only running TEST/FREE_STATEID on the locks if
the open stateid recovery succeeds. The protocol requires us to
always do so.
The fix would be to move the call to TEST/FREE_STATEID and do it
before we attempt open recovery.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 92 +++++++++++++++++++++++++++++++------------------------
 1 file changed, 52 insertions(+), 40 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 3c1b8cb7dd95..33ca6d768bd2 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2486,6 +2486,45 @@ static void nfs41_check_delegation_stateid(struct nfs4_state *state)
 }
 
 /**
+ * nfs41_check_expired_locks - possibly free a lock stateid
+ *
+ * @state: NFSv4 state for an inode
+ *
+ * Returns NFS_OK if recovery for this stateid is now finished.
+ * Otherwise a negative NFS4ERR value is returned.
+ */
+static int nfs41_check_expired_locks(struct nfs4_state *state)
+{
+	int status, ret = NFS_OK;
+	struct nfs4_lock_state *lsp;
+	struct nfs_server *server = NFS_SERVER(state->inode);
+
+	if (!test_bit(LK_STATE_IN_USE, &state->flags))
+		goto out;
+	list_for_each_entry(lsp, &state->lock_states, ls_locks) {
+		if (test_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags)) {
+			struct rpc_cred *cred = lsp->ls_state->owner->so_cred;
+
+			status = nfs41_test_and_free_expired_stateid(server,
+					&lsp->ls_stateid,
+					cred);
+			trace_nfs4_test_lock_stateid(state, lsp, status);
+			if (status == -NFS4ERR_EXPIRED ||
+			    status == -NFS4ERR_BAD_STATEID) {
+				clear_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags);
+				if (!recover_lost_locks)
+					set_bit(NFS_LOCK_LOST, &lsp->ls_flags);
+			} else if (status != NFS_OK) {
+				ret = status;
+				break;
+			}
+		}
+	};
+out:
+	return ret;
+}
+
+/**
  * nfs41_check_open_stateid - possibly free an open stateid
  *
  * @state: NFSv4 state for an inode
@@ -2522,6 +2561,9 @@ static int nfs41_open_expired(struct nfs4_state_owner *sp, struct nfs4_state *st
 	int status;
 
 	nfs41_check_delegation_stateid(state);
+	status = nfs41_check_expired_locks(state);
+	if (status != NFS_OK)
+		return status;
 	status = nfs41_check_open_stateid(state);
 	if (status != NFS_OK)
 		status = nfs4_open_expired(sp, state);
@@ -6125,49 +6167,19 @@ out:
 }
 
 #if defined(CONFIG_NFS_V4_1)
-/**
- * nfs41_check_expired_locks - possibly free a lock stateid
- *
- * @state: NFSv4 state for an inode
- *
- * Returns NFS_OK if recovery for this stateid is now finished.
- * Otherwise a negative NFS4ERR value is returned.
- */
-static int nfs41_check_expired_locks(struct nfs4_state *state)
-{
-	int status, ret = NFS_OK;
-	struct nfs4_lock_state *lsp;
-	struct nfs_server *server = NFS_SERVER(state->inode);
-
-	list_for_each_entry(lsp, &state->lock_states, ls_locks) {
-		if (test_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags)) {
-			struct rpc_cred *cred = lsp->ls_state->owner->so_cred;
-
-			status = nfs41_test_and_free_expired_stateid(server,
-					&lsp->ls_stateid,
-					cred);
-			trace_nfs4_test_lock_stateid(state, lsp, status);
-			if (status == -NFS4ERR_EXPIRED ||
-			    status == -NFS4ERR_BAD_STATEID)
-				clear_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags);
-			else if (status != NFS_OK) {
-				ret = status;
-				break;
-			}
-		}
-	};
-
-	return ret;
-}
-
 static int nfs41_lock_expired(struct nfs4_state *state, struct file_lock *request)
 {
-	int status = NFS_OK;
+	struct nfs4_lock_state *lsp;
+	int status;
 
-	if (test_bit(LK_STATE_IN_USE, &state->flags))
-		status = nfs41_check_expired_locks(state);
-	if (status != NFS_OK)
-		status = nfs4_lock_expired(state, request);
+	status = nfs4_set_lock_state(state, request);
+	if (status != 0)
+		return status;
+	lsp = request->fl_u.nfs4_fl.owner;
+	if (test_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags) ||
+	    test_bit(NFS_LOCK_LOST, &lsp->ls_flags))
+		return 0;
+	status = nfs4_lock_expired(state, request);
 	return status;
 }
 #endif
-- 
2.7.4


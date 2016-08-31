Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:35611 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757562AbcHaCMP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Aug 2016 22:12:15 -0400
Received: by mail-it0-f68.google.com with SMTP id f128so4119699ith.2
        for <linux-nfs@vger.kernel.org>; Tue, 30 Aug 2016 19:12:15 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 3/7] NFSv4.1: Add a helper function to deal with expired stateids
Date: Tue, 30 Aug 2016 22:11:40 -0400
Message-Id: <1472609504-69094-4-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1472609504-69094-3-git-send-email-trond.myklebust@primarydata.com>
References: <1472609504-69094-1-git-send-email-trond.myklebust@primarydata.com>
 <1472609504-69094-2-git-send-email-trond.myklebust@primarydata.com>
 <1472609504-69094-3-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In NFSv4.1 and newer, if the server decides to revoke some or all of
the protocol state, the client is required to iterate through all the
stateids that it holds and call TEST_STATEID to determine which stateids
still correspond to valid state, and then call FREE_STATEID on the
others.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 45 ++++++++++++++++++++++++---------------------
 1 file changed, 24 insertions(+), 21 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 2d2c1a46c3b9..13640bb3dcfb 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2405,6 +2405,26 @@ static int nfs40_open_expired(struct nfs4_state_owner *sp, struct nfs4_state *st
 }
 
 #if defined(CONFIG_NFS_V4_1)
+static int nfs41_test_and_free_expired_stateid(struct nfs_server *server,
+		nfs4_stateid *stateid,
+		struct rpc_cred *cred)
+{
+	int status;
+
+	status = nfs41_test_stateid(server, stateid, cred);
+
+	switch (status) {
+	case -NFS4ERR_EXPIRED:
+	case -NFS4ERR_ADMIN_REVOKED:
+	case -NFS4ERR_DELEG_REVOKED:
+		/* Ack the revoked state to the server */
+		nfs41_free_stateid(server, stateid, cred);
+	case -NFS4ERR_BAD_STATEID:
+		return status;
+	}
+	return NFS_OK;
+}
+
 static void nfs41_check_delegation_stateid(struct nfs4_state *state)
 {
 	struct nfs_server *server = NFS_SERVER(state->inode);
@@ -2429,16 +2449,10 @@ static void nfs41_check_delegation_stateid(struct nfs4_state *state)
 	nfs4_stateid_copy(&stateid, &delegation->stateid);
 	cred = get_rpccred(delegation->cred);
 	rcu_read_unlock();
-	status = nfs41_test_stateid(server, &stateid, cred);
+	status = nfs41_test_and_free_expired_stateid(server, &stateid, cred);
 	trace_nfs4_test_delegation_stateid(state, NULL, status);
-
-	if (status != NFS_OK) {
-		/* Free the stateid unless the server explicitly
-		 * informs us the stateid is unrecognized. */
-		if (status != -NFS4ERR_BAD_STATEID)
-			nfs41_free_stateid(server, &stateid, cred);
+	if (status != NFS_OK)
 		nfs_finish_clear_delegation_stateid(state);
-	}
 
 	put_rpccred(cred);
 }
@@ -2464,14 +2478,9 @@ static int nfs41_check_open_stateid(struct nfs4_state *state)
 	    (test_bit(NFS_O_RDWR_STATE, &state->flags) == 0))
 		return -NFS4ERR_BAD_STATEID;
 
-	status = nfs41_test_stateid(server, stateid, cred);
+	status = nfs41_test_and_free_expired_stateid(server, stateid, cred);
 	trace_nfs4_test_open_stateid(state, NULL, status);
 	if (status != NFS_OK) {
-		/* Free the stateid unless the server explicitly
-		 * informs us the stateid is unrecognized. */
-		if (status != -NFS4ERR_BAD_STATEID)
-			nfs41_free_stateid(server, stateid, cred);
-
 		clear_bit(NFS_O_RDONLY_STATE, &state->flags);
 		clear_bit(NFS_O_WRONLY_STATE, &state->flags);
 		clear_bit(NFS_O_RDWR_STATE, &state->flags);
@@ -6106,17 +6115,11 @@ static int nfs41_check_expired_locks(struct nfs4_state *state)
 		if (test_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags)) {
 			struct rpc_cred *cred = lsp->ls_state->owner->so_cred;
 
-			status = nfs41_test_stateid(server,
+			status = nfs41_test_and_free_expired_stateid(server,
 					&lsp->ls_stateid,
 					cred);
 			trace_nfs4_test_lock_stateid(state, lsp, status);
 			if (status != NFS_OK) {
-				/* Free the stateid unless the server
-				 * informs us the stateid is unrecognized. */
-				if (status != -NFS4ERR_BAD_STATEID)
-					nfs41_free_stateid(server,
-							&lsp->ls_stateid,
-							cred);
 				clear_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags);
 				ret = status;
 			}
-- 
2.7.4


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:36180 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755489Ab3ETRRy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 May 2013 13:17:54 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/6] NFSv4.1: Ensure that test_stateid and free_stateid use correct credentials
Date: Mon, 20 May 2013 13:17:05 -0400
Message-Id: <1369070227-40671-4-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1369070227-40671-3-git-send-email-Trond.Myklebust@netapp.com>
References: <1369070227-40671-1-git-send-email-Trond.Myklebust@netapp.com>
 <1369070227-40671-2-git-send-email-Trond.Myklebust@netapp.com>
 <1369070227-40671-3-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c | 65 ++++++++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 50 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9d90f57..4f42f49 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -83,8 +83,10 @@ static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 			    struct nfs_fattr *fattr, struct iattr *sattr,
 			    struct nfs4_state *state);
 #ifdef CONFIG_NFS_V4_1
-static int nfs41_test_stateid(struct nfs_server *, nfs4_stateid *);
-static int nfs41_free_stateid(struct nfs_server *, nfs4_stateid *);
+static int nfs41_test_stateid(struct nfs_server *, nfs4_stateid *,
+		struct rpc_cred *);
+static int nfs41_free_stateid(struct nfs_server *, nfs4_stateid *,
+		struct rpc_cred *);
 #endif
 /* Prevent leaks of NFSv4 errors into userland */
 static int nfs4_map_errors(int err)
@@ -1855,18 +1857,30 @@ static void nfs41_clear_delegation_stateid(struct nfs4_state *state)
 {
 	struct nfs_server *server = NFS_SERVER(state->inode);
 	nfs4_stateid *stateid = &state->stateid;
-	int status;
+	struct nfs_delegation *delegation;
+	struct rpc_cred *cred = NULL;
+	int status = -NFS4ERR_BAD_STATEID;
 
 	/* If a state reset has been done, test_stateid is unneeded */
 	if (test_bit(NFS_DELEGATED_STATE, &state->flags) == 0)
 		return;
 
-	status = nfs41_test_stateid(server, stateid);
+	/* Get the delegation credential for use by test/free_stateid */
+	rcu_read_lock();
+	delegation = rcu_dereference(NFS_I(state->inode)->delegation);
+	if (delegation != NULL &&
+	    nfs4_stateid_match(&delegation->stateid, stateid)) {
+		cred = get_rpccred(delegation->cred);
+		rcu_read_unlock();
+		status = nfs41_test_stateid(server, stateid, cred);
+	} else
+		rcu_read_unlock();
+
 	if (status != NFS_OK) {
 		/* Free the stateid unless the server explicitly
 		 * informs us the stateid is unrecognized. */
 		if (status != -NFS4ERR_BAD_STATEID)
-			nfs41_free_stateid(server, stateid);
+			nfs41_free_stateid(server, stateid, cred);
 		nfs_remove_bad_delegation(state->inode);
 
 		write_seqlock(&state->seqlock);
@@ -1874,6 +1888,9 @@ static void nfs41_clear_delegation_stateid(struct nfs4_state *state)
 		write_sequnlock(&state->seqlock);
 		clear_bit(NFS_DELEGATED_STATE, &state->flags);
 	}
+
+	if (cred != NULL)
+		put_rpccred(cred);
 }
 
 /**
@@ -1888,6 +1905,7 @@ static int nfs41_check_open_stateid(struct nfs4_state *state)
 {
 	struct nfs_server *server = NFS_SERVER(state->inode);
 	nfs4_stateid *stateid = &state->open_stateid;
+	struct rpc_cred *cred = state->owner->so_cred;
 	int status;
 
 	/* If a state reset has been done, test_stateid is unneeded */
@@ -1896,12 +1914,12 @@ static int nfs41_check_open_stateid(struct nfs4_state *state)
 	    (test_bit(NFS_O_RDWR_STATE, &state->flags) == 0))
 		return -NFS4ERR_BAD_STATEID;
 
-	status = nfs41_test_stateid(server, stateid);
+	status = nfs41_test_stateid(server, stateid, cred);
 	if (status != NFS_OK) {
 		/* Free the stateid unless the server explicitly
 		 * informs us the stateid is unrecognized. */
 		if (status != -NFS4ERR_BAD_STATEID)
-			nfs41_free_stateid(server, stateid);
+			nfs41_free_stateid(server, stateid, cred);
 
 		clear_bit(NFS_O_RDONLY_STATE, &state->flags);
 		clear_bit(NFS_O_WRONLY_STATE, &state->flags);
@@ -5056,13 +5074,18 @@ static int nfs41_check_expired_locks(struct nfs4_state *state)
 
 	list_for_each_entry(lsp, &state->lock_states, ls_locks) {
 		if (test_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags)) {
-			status = nfs41_test_stateid(server, &lsp->ls_stateid);
+			struct rpc_cred *cred = lsp->ls_state->owner->so_cred;
+
+			status = nfs41_test_stateid(server,
+					&lsp->ls_stateid,
+					cred);
 			if (status != NFS_OK) {
 				/* Free the stateid unless the server
 				 * informs us the stateid is unrecognized. */
 				if (status != -NFS4ERR_BAD_STATEID)
 					nfs41_free_stateid(server,
-							&lsp->ls_stateid);
+							&lsp->ls_stateid,
+							cred);
 				clear_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags);
 				ret = status;
 			}
@@ -6737,7 +6760,9 @@ out:
 	return err;
 }
 
-static int _nfs41_test_stateid(struct nfs_server *server, nfs4_stateid *stateid)
+static int _nfs41_test_stateid(struct nfs_server *server,
+		nfs4_stateid *stateid,
+		struct rpc_cred *cred)
 {
 	int status;
 	struct nfs41_test_stateid_args args = {
@@ -6748,6 +6773,7 @@ static int _nfs41_test_stateid(struct nfs_server *server, nfs4_stateid *stateid)
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_TEST_STATEID],
 		.rpc_argp = &args,
 		.rpc_resp = &res,
+		.rpc_cred = cred,
 	};
 
 	dprintk("NFS call  test_stateid %p\n", stateid);
@@ -6768,17 +6794,20 @@ static int _nfs41_test_stateid(struct nfs_server *server, nfs4_stateid *stateid)
  *
  * @server: server / transport on which to perform the operation
  * @stateid: state ID to test
+ * @cred: credential
  *
  * Returns NFS_OK if the server recognizes that "stateid" is valid.
  * Otherwise a negative NFS4ERR value is returned if the operation
  * failed or the state ID is not currently valid.
  */
-static int nfs41_test_stateid(struct nfs_server *server, nfs4_stateid *stateid)
+static int nfs41_test_stateid(struct nfs_server *server,
+		nfs4_stateid *stateid,
+		struct rpc_cred *cred)
 {
 	struct nfs4_exception exception = { };
 	int err;
 	do {
-		err = _nfs41_test_stateid(server, stateid);
+		err = _nfs41_test_stateid(server, stateid, cred);
 		if (err != -NFS4ERR_DELAY)
 			break;
 		nfs4_handle_exception(server, err, &exception);
@@ -6827,10 +6856,12 @@ const struct rpc_call_ops nfs41_free_stateid_ops = {
 
 static struct rpc_task *_nfs41_free_stateid(struct nfs_server *server,
 		nfs4_stateid *stateid,
+		struct rpc_cred *cred,
 		bool privileged)
 {
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_FREE_STATEID],
+		.rpc_cred = cred,
 	};
 	struct rpc_task_setup task_setup = {
 		.rpc_client = server->client,
@@ -6863,16 +6894,19 @@ static struct rpc_task *_nfs41_free_stateid(struct nfs_server *server,
  *
  * @server: server / transport on which to perform the operation
  * @stateid: state ID to release
+ * @cred: credential
  *
  * Returns NFS_OK if the server freed "stateid".  Otherwise a
  * negative NFS4ERR value is returned.
  */
-static int nfs41_free_stateid(struct nfs_server *server, nfs4_stateid *stateid)
+static int nfs41_free_stateid(struct nfs_server *server,
+		nfs4_stateid *stateid,
+		struct rpc_cred *cred)
 {
 	struct rpc_task *task;
 	int ret;
 
-	task = _nfs41_free_stateid(server, stateid, true);
+	task = _nfs41_free_stateid(server, stateid, cred, true);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
 	ret = rpc_wait_for_completion_task(task);
@@ -6885,8 +6919,9 @@ static int nfs41_free_stateid(struct nfs_server *server, nfs4_stateid *stateid)
 static int nfs41_free_lock_state(struct nfs_server *server, struct nfs4_lock_state *lsp)
 {
 	struct rpc_task *task;
+	struct rpc_cred *cred = lsp->ls_state->owner->so_cred;
 
-	task = _nfs41_free_stateid(server, &lsp->ls_stateid, false);
+	task = _nfs41_free_stateid(server, &lsp->ls_stateid, cred, false);
 	nfs4_free_lock_state(server, lsp);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
-- 
1.8.1.4


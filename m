Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:10796 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934204Ab3ECU1q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 May 2013 16:27:46 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] NFSv4.1: Ensure that we free the lock stateid on the server
Date: Fri,  3 May 2013 16:27:41 -0400
Message-Id: <1367612861-37915-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1367612861-37915-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1367612861-37915-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This ensures that the server doesn't need to keep huge numbers of
lock stateids waiting around for the final CLOSE.
See section 8.2.4 in RFC5661.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4_fs.h   |  3 ++-
 fs/nfs/nfs4proc.c  | 17 +++++++++++++++--
 fs/nfs/nfs4state.c | 11 +++++++----
 3 files changed, 24 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index f617bdc..a1e52d5 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -48,6 +48,8 @@ struct nfs4_minor_version_ops {
 			const nfs4_stateid *);
 	int	(*find_root_sec)(struct nfs_server *, struct nfs_fh *,
 			struct nfs_fsinfo *);
+	int	(*free_lock_state)(struct nfs_server *,
+			struct nfs4_lock_state *);
 	const struct nfs4_state_recovery_ops *reboot_recovery_ops;
 	const struct nfs4_state_recovery_ops *nograce_recovery_ops;
 	const struct nfs4_state_maintenance_ops *state_renewal_ops;
@@ -235,7 +237,6 @@ extern int nfs4_proc_fs_locations(struct rpc_clnt *, struct inode *, const struc
 extern struct rpc_clnt *nfs4_proc_lookup_mountpoint(struct inode *, struct qstr *,
 			    struct nfs_fh *, struct nfs_fattr *);
 extern int nfs4_proc_secinfo(struct inode *, const struct qstr *, struct nfs4_secinfo_flavors *);
-extern int nfs4_release_lockowner(struct nfs4_lock_state *);
 extern const struct xattr_handler *nfs4_xattr_handlers[];
 extern int nfs4_set_rw_stateid(nfs4_stateid *stateid,
 		const struct nfs_open_context *ctx,
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 95f73ca..236972d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5238,9 +5238,8 @@ static const struct rpc_call_ops nfs4_release_lockowner_ops = {
 	.rpc_release = nfs4_release_lockowner_release,
 };
 
-int nfs4_release_lockowner(struct nfs4_lock_state *lsp)
+static int nfs4_release_lockowner(struct nfs_server *server, struct nfs4_lock_state *lsp)
 {
-	struct nfs_server *server = lsp->ls_state->owner->so_server;
 	struct nfs_release_lockowner_data *data;
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_RELEASE_LOCKOWNER],
@@ -6879,6 +6878,18 @@ static int nfs41_free_stateid(struct nfs_server *server, nfs4_stateid *stateid)
 	return ret;
 }
 
+static int nfs41_free_lock_state(struct nfs_server *server, struct nfs4_lock_state *lsp)
+{
+	struct rpc_task *task;
+
+	task = _nfs41_free_stateid(server, &lsp->ls_stateid, false);
+	nfs4_free_lock_state(server, lsp);
+	if (IS_ERR(task))
+		return PTR_ERR(task);
+	rpc_put_task(task);
+	return 0;
+}
+
 static bool nfs41_match_stateid(const nfs4_stateid *s1,
 		const nfs4_stateid *s2)
 {
@@ -6975,6 +6986,7 @@ static const struct nfs4_minor_version_ops nfs_v4_0_minor_ops = {
 	.call_sync = _nfs4_call_sync,
 	.match_stateid = nfs4_match_stateid,
 	.find_root_sec = nfs4_find_root_sec,
+	.free_lock_state = nfs4_release_lockowner,
 	.reboot_recovery_ops = &nfs40_reboot_recovery_ops,
 	.nograce_recovery_ops = &nfs40_nograce_recovery_ops,
 	.state_renewal_ops = &nfs40_state_renewal_ops,
@@ -6992,6 +7004,7 @@ static const struct nfs4_minor_version_ops nfs_v4_1_minor_ops = {
 	.call_sync = nfs4_call_sync_sequence,
 	.match_stateid = nfs41_match_stateid,
 	.find_root_sec = nfs41_find_root_sec,
+	.free_lock_state = nfs41_free_lock_state,
 	.reboot_recovery_ops = &nfs41_reboot_recovery_ops,
 	.nograce_recovery_ops = &nfs41_nograce_recovery_ops,
 	.state_renewal_ops = &nfs41_state_renewal_ops,
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index a31e0ab..ff8c038 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -921,6 +921,7 @@ static struct nfs4_lock_state *nfs4_get_lock_state(struct nfs4_state *state, fl_
  */
 void nfs4_put_lock_state(struct nfs4_lock_state *lsp)
 {
+	struct nfs_server *server;
 	struct nfs4_state *state;
 
 	if (lsp == NULL)
@@ -932,11 +933,13 @@ void nfs4_put_lock_state(struct nfs4_lock_state *lsp)
 	if (list_empty(&state->lock_states))
 		clear_bit(LK_STATE_IN_USE, &state->flags);
 	spin_unlock(&state->state_lock);
+	server = state->owner->so_server;
 	if (test_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags)) {
-		if (nfs4_release_lockowner(lsp) == 0)
-			return;
-	}
-	nfs4_free_lock_state(lsp->ls_state->owner->so_server, lsp);
+		struct nfs_client *clp = server->nfs_client;
+
+		clp->cl_mvops->free_lock_state(server, lsp);
+	} else
+		nfs4_free_lock_state(server, lsp);
 }
 
 static void nfs4_fl_copy_lock(struct file_lock *dst, struct file_lock *src)
-- 
1.8.1.4


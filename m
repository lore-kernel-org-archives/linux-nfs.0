From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 10/15] NFSv41: Convert the various reboot recovery ops etc to minor version ops
Date: Mon, 14 Jun 2010 17:51:34 -0400
Message-ID: <1276552299-6625-10-git-send-email-Trond.Myklebust@netapp.com>
References: <1276552299-6625-1-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-2-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-3-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-4-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-5-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-6-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-7-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-8-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-9-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:34599 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756627Ab0FNVvq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Jun 2010 17:51:46 -0400
In-Reply-To: <1276552299-6625-9-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4_fs.h    |    6 +++---
 fs/nfs/nfs4proc.c   |   31 ++++++-------------------------
 fs/nfs/nfs4renewd.c |    4 ++--
 fs/nfs/nfs4state.c  |   15 +++++++--------
 4 files changed, 18 insertions(+), 38 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 5b01705..1ff0ea2 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -60,6 +60,9 @@ struct nfs4_minor_version_ops {
 			struct nfs4_sequence_args *args,
 			struct nfs4_sequence_res *res,
 			int cache_reply);
+	const struct nfs4_state_recovery_ops *reboot_recovery_ops;
+	const struct nfs4_state_recovery_ops *nograce_recovery_ops;
+	const struct nfs4_state_maintenance_ops *state_renewal_ops;
 };
 
 /*
@@ -233,8 +236,6 @@ extern int nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *fh
 extern int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 		struct nfs4_fs_locations *fs_locations, struct page *page);
 
-extern struct nfs4_state_recovery_ops *nfs4_reboot_recovery_ops[];
-extern struct nfs4_state_recovery_ops *nfs4_nograce_recovery_ops[];
 #if defined(CONFIG_NFS_V4_1)
 static inline struct nfs4_session *nfs4_get_session(const struct nfs_server *server)
 {
@@ -271,7 +272,6 @@ static inline int nfs4_init_session(struct nfs_server *server)
 #endif /* CONFIG_NFS_V4_1 */
 
 extern const struct nfs4_minor_version_ops *nfs_v4_minor_ops[];
-extern struct nfs4_state_maintenance_ops *nfs4_state_renewal_ops[];
 
 extern const u32 nfs4_fattr_bitmap[2];
 extern const u32 nfs4_statfs_bitmap[2];
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8530782..e4ec092 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5355,40 +5355,21 @@ struct nfs4_state_maintenance_ops nfs41_state_renewal_ops = {
 static const struct nfs4_minor_version_ops nfs_v4_0_minor_ops = {
 	.minor_version = 0,
 	.call_sync = _nfs4_call_sync,
+	.reboot_recovery_ops = &nfs40_reboot_recovery_ops,
+	.nograce_recovery_ops = &nfs40_nograce_recovery_ops,
+	.state_renewal_ops = &nfs40_state_renewal_ops,
 };
 
 #if defined(CONFIG_NFS_V4_1)
 static const struct nfs4_minor_version_ops nfs_v4_1_minor_ops = {
 	.minor_version = 1,
 	.call_sync = _nfs4_call_sync_session,
+	.reboot_recovery_ops = &nfs41_reboot_recovery_ops,
+	.nograce_recovery_ops = &nfs41_nograce_recovery_ops,
+	.state_renewal_ops = &nfs41_state_renewal_ops,
 };
 #endif
 
-/*
- * Per minor version reboot and network partition recovery ops
- */
-
-struct nfs4_state_recovery_ops *nfs4_reboot_recovery_ops[] = {
-	&nfs40_reboot_recovery_ops,
-#if defined(CONFIG_NFS_V4_1)
-	&nfs41_reboot_recovery_ops,
-#endif
-};
-
-struct nfs4_state_recovery_ops *nfs4_nograce_recovery_ops[] = {
-	&nfs40_nograce_recovery_ops,
-#if defined(CONFIG_NFS_V4_1)
-	&nfs41_nograce_recovery_ops,
-#endif
-};
-
-struct nfs4_state_maintenance_ops *nfs4_state_renewal_ops[] = {
-	&nfs40_state_renewal_ops,
-#if defined(CONFIG_NFS_V4_1)
-	&nfs41_state_renewal_ops,
-#endif
-};
-
 const struct nfs4_minor_version_ops *nfs_v4_minor_ops[] = {
 	[0] = &nfs_v4_0_minor_ops,
 #if defined(CONFIG_NFS_V4_1)
diff --git a/fs/nfs/nfs4renewd.c b/fs/nfs/nfs4renewd.c
index d87f103..72b6c58 100644
--- a/fs/nfs/nfs4renewd.c
+++ b/fs/nfs/nfs4renewd.c
@@ -54,14 +54,14 @@
 void
 nfs4_renew_state(struct work_struct *work)
 {
-	struct nfs4_state_maintenance_ops *ops;
+	const struct nfs4_state_maintenance_ops *ops;
 	struct nfs_client *clp =
 		container_of(work, struct nfs_client, cl_renewd.work);
 	struct rpc_cred *cred;
 	long lease;
 	unsigned long last, now;
 
-	ops = nfs4_state_renewal_ops[clp->cl_minorversion];
+	ops = clp->cl_mvops->state_renewal_ops;
 	dprintk("%s: start\n", __func__);
 	/* Are there any active superblocks? */
 	if (list_empty(&clp->cl_superblocks))
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 4538c56..c3c6b8a 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1122,8 +1122,7 @@ static void nfs4_state_end_reclaim_reboot(struct nfs_client *clp)
 	if (!test_and_clear_bit(NFS4CLNT_RECLAIM_REBOOT, &clp->cl_state))
 		return;
 
-	nfs4_reclaim_complete(clp,
-		nfs4_reboot_recovery_ops[clp->cl_minorversion]);
+	nfs4_reclaim_complete(clp, clp->cl_mvops->reboot_recovery_ops);
 
 	for (pos = rb_first(&clp->cl_state_owners); pos != NULL; pos = rb_next(pos)) {
 		sp = rb_entry(pos, struct nfs4_state_owner, so_client_node);
@@ -1213,8 +1212,8 @@ restart:
 static int nfs4_check_lease(struct nfs_client *clp)
 {
 	struct rpc_cred *cred;
-	struct nfs4_state_maintenance_ops *ops =
-		nfs4_state_renewal_ops[clp->cl_minorversion];
+	const struct nfs4_state_maintenance_ops *ops =
+		clp->cl_mvops->state_renewal_ops;
 	int status = -NFS4ERR_EXPIRED;
 
 	/* Is the client already known to have an expired lease? */
@@ -1237,8 +1236,8 @@ out:
 static int nfs4_reclaim_lease(struct nfs_client *clp)
 {
 	struct rpc_cred *cred;
-	struct nfs4_state_recovery_ops *ops =
-		nfs4_reboot_recovery_ops[clp->cl_minorversion];
+	const struct nfs4_state_recovery_ops *ops =
+		clp->cl_mvops->reboot_recovery_ops;
 	int status = -ENOENT;
 
 	cred = ops->get_clid_cred(clp);
@@ -1446,7 +1445,7 @@ static void nfs4_state_manager(struct nfs_client *clp)
 		/* First recover reboot state... */
 		if (test_bit(NFS4CLNT_RECLAIM_REBOOT, &clp->cl_state)) {
 			status = nfs4_do_reclaim(clp,
-				nfs4_reboot_recovery_ops[clp->cl_minorversion]);
+				clp->cl_mvops->reboot_recovery_ops);
 			if (test_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state) ||
 			    test_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state))
 				continue;
@@ -1460,7 +1459,7 @@ static void nfs4_state_manager(struct nfs_client *clp)
 		/* Now recover expired state... */
 		if (test_and_clear_bit(NFS4CLNT_RECLAIM_NOGRACE, &clp->cl_state)) {
 			status = nfs4_do_reclaim(clp,
-				nfs4_nograce_recovery_ops[clp->cl_minorversion]);
+				clp->cl_mvops->nograce_recovery_ops);
 			if (test_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state) ||
 			    test_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state) ||
 			    test_bit(NFS4CLNT_RECLAIM_REBOOT, &clp->cl_state))
-- 
1.7.0.1


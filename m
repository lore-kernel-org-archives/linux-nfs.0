From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 11/15] NFSv41: Fix nfs_async_inode_return_delegation() ugliness
Date: Mon, 14 Jun 2010 17:51:35 -0400
Message-ID: <1276552299-6625-11-git-send-email-Trond.Myklebust@netapp.com>
References: <1276552299-6625-1-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-2-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-3-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-4-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-5-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-6-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-7-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-8-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-9-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-10-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:53421 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756883Ab0FNVvq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Jun 2010 17:51:46 -0400
In-Reply-To: <1276552299-6625-10-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/callback_proc.c |   13 +------------
 fs/nfs/delegation.c    |    6 ++----
 fs/nfs/delegation.h    |    4 +---
 fs/nfs/nfs4_fs.h       |    2 ++
 fs/nfs/nfs4proc.c      |    2 ++
 5 files changed, 8 insertions(+), 19 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index a08770a..7445dd0 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -62,16 +62,6 @@ out:
 	return res->status;
 }
 
-static int (*nfs_validate_delegation_stateid(struct nfs_client *clp))(struct nfs_delegation *, const nfs4_stateid *)
-{
-#if defined(CONFIG_NFS_V4_1)
-	if (clp->cl_minorversion > 0)
-		return nfs41_validate_delegation_stateid;
-#endif
-	return nfs4_validate_delegation_stateid;
-}
-
-
 __be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy)
 {
 	struct nfs_client *clp;
@@ -92,8 +82,7 @@ __be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy)
 		inode = nfs_delegation_find_inode(clp, &args->fh);
 		if (inode != NULL) {
 			/* Set up a helper thread to actually return the delegation */
-			switch (nfs_async_inode_return_delegation(inode, &args->stateid,
-								  nfs_validate_delegation_stateid(clp))) {
+			switch (nfs_async_inode_return_delegation(inode, &args->stateid)) {
 				case 0:
 					res = 0;
 					break;
diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 3016345..f34f4ac 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -471,9 +471,7 @@ void nfs_expire_unreferenced_delegations(struct nfs_client *clp)
 /*
  * Asynchronous delegation recall!
  */
-int nfs_async_inode_return_delegation(struct inode *inode, const nfs4_stateid *stateid,
-				      int (*validate_stateid)(struct nfs_delegation *delegation,
-							      const nfs4_stateid *stateid))
+int nfs_async_inode_return_delegation(struct inode *inode, const nfs4_stateid *stateid)
 {
 	struct nfs_client *clp = NFS_SERVER(inode)->nfs_client;
 	struct nfs_delegation *delegation;
@@ -481,7 +479,7 @@ int nfs_async_inode_return_delegation(struct inode *inode, const nfs4_stateid *s
 	rcu_read_lock();
 	delegation = rcu_dereference(NFS_I(inode)->delegation);
 
-	if (!validate_stateid(delegation, stateid)) {
+	if (!clp->cl_mvops->validate_stateid(delegation, stateid)) {
 		rcu_read_unlock();
 		return -ENOENT;
 	}
diff --git a/fs/nfs/delegation.h b/fs/nfs/delegation.h
index 69e7b81..2026304 100644
--- a/fs/nfs/delegation.h
+++ b/fs/nfs/delegation.h
@@ -34,9 +34,7 @@ enum {
 int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct nfs_openres *res);
 void nfs_inode_reclaim_delegation(struct inode *inode, struct rpc_cred *cred, struct nfs_openres *res);
 int nfs_inode_return_delegation(struct inode *inode);
-int nfs_async_inode_return_delegation(struct inode *inode, const nfs4_stateid *stateid,
-				      int (*validate_stateid)(struct nfs_delegation *delegation,
-							      const nfs4_stateid *stateid));
+int nfs_async_inode_return_delegation(struct inode *inode, const nfs4_stateid *stateid);
 void nfs_inode_return_delegation_noreclaim(struct inode *inode);
 
 struct inode *nfs_delegation_find_inode(struct nfs_client *clp, const struct nfs_fh *fhandle);
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 1ff0ea2..04eff16 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -60,6 +60,8 @@ struct nfs4_minor_version_ops {
 			struct nfs4_sequence_args *args,
 			struct nfs4_sequence_res *res,
 			int cache_reply);
+	int	(*validate_stateid)(struct nfs_delegation *,
+			const nfs4_stateid *);
 	const struct nfs4_state_recovery_ops *reboot_recovery_ops;
 	const struct nfs4_state_recovery_ops *nograce_recovery_ops;
 	const struct nfs4_state_maintenance_ops *state_renewal_ops;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e4ec092..ef613ea 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5355,6 +5355,7 @@ struct nfs4_state_maintenance_ops nfs41_state_renewal_ops = {
 static const struct nfs4_minor_version_ops nfs_v4_0_minor_ops = {
 	.minor_version = 0,
 	.call_sync = _nfs4_call_sync,
+	.validate_stateid = nfs4_validate_delegation_stateid,
 	.reboot_recovery_ops = &nfs40_reboot_recovery_ops,
 	.nograce_recovery_ops = &nfs40_nograce_recovery_ops,
 	.state_renewal_ops = &nfs40_state_renewal_ops,
@@ -5364,6 +5365,7 @@ static const struct nfs4_minor_version_ops nfs_v4_0_minor_ops = {
 static const struct nfs4_minor_version_ops nfs_v4_1_minor_ops = {
 	.minor_version = 1,
 	.call_sync = _nfs4_call_sync_session,
+	.validate_stateid = nfs41_validate_delegation_stateid,
 	.reboot_recovery_ops = &nfs41_reboot_recovery_ops,
 	.nograce_recovery_ops = &nfs41_nograce_recovery_ops,
 	.state_renewal_ops = &nfs41_state_renewal_ops,
-- 
1.7.0.1


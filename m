From: Alexandros Batsakis <batsakis@netapp.com>
Subject: [PATCH 3/10] nfs41: v2 fix cb_recall bug
Date: Mon, 23 Nov 2009 18:49:35 -0800
Message-ID: <1259030975-6773-2-git-send-email-batsakis@netapp.com>
References: <1259030975-6773-1-git-send-email-batsakis@netapp.com>
Cc: Alexandros Batsakis <batsakis@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:28225 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757648AbZKXCya (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Nov 2009 21:54:30 -0500
In-Reply-To: <1259030975-6773-1-git-send-email-batsakis@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

in NFSv4.1 the seqid part of a stateid in CB_RECALL must be 0

Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
---
 fs/nfs/callback.h      |    6 ++++--
 fs/nfs/callback_proc.c |   37 +++++++++++++++++++++++++++++++++++--
 fs/nfs/delegation.c    |    9 ++++++---
 fs/nfs/delegation.h    |    4 +++-
 4 files changed, 48 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index 07baa82..a390fca 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -105,7 +105,8 @@ struct cb_sequenceres {
 
 extern unsigned nfs4_callback_sequence(struct cb_sequenceargs *args,
 				       struct cb_sequenceres *res);
-
+extern int nfs41_validate_delegation_stateid(struct nfs_delegation *delegation,
+					     const nfs4_stateid *stateid);
 #endif /* CONFIG_NFS_V4_1 */
 
 extern __be32 nfs4_callback_getattr(struct cb_getattrargs *args, struct cb_getattrres *res);
@@ -114,8 +115,9 @@ extern __be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy);
 #ifdef CONFIG_NFS_V4
 extern int nfs_callback_up(u32 minorversion, struct rpc_xprt *xprt);
 extern void nfs_callback_down(int minorversion);
+extern int nfs4_validate_delegation_stateid(struct nfs_delegation *delegation,
+					    const nfs4_stateid *stateid);
 #endif /* CONFIG_NFS_V4 */
-
 /*
  * nfs41: Callbacks are expected to not cause substantial latency,
  * so we limit their concurrency to 1 by setting up the maximum number
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index b7da1f5..b56fffa 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -61,6 +61,16 @@ out:
 	return res->status;
 }
 
+static int (*nfs_validate_delegation_stateid(struct nfs_client *clp))(struct nfs_delegation *, const nfs4_stateid *)
+{
+#if defined(CONFIG_NFS_V4_1)
+	if (clp->cl_minorversion > 0)
+		return nfs41_validate_delegation_stateid;
+#endif
+	return nfs4_validate_delegation_stateid;
+}
+
+
 __be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy)
 {
 	struct nfs_client *clp;
@@ -81,7 +91,8 @@ __be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy)
 		inode = nfs_delegation_find_inode(clp, &args->fh);
 		if (inode != NULL) {
 			/* Set up a helper thread to actually return the delegation */
-			switch(nfs_async_inode_return_delegation(inode, &args->stateid)) {
+			switch (nfs_async_inode_return_delegation(inode, &args->stateid,
+								  nfs_validate_delegation_stateid(clp))) {
 				case 0:
 					res = 0;
 					break;
@@ -102,8 +113,31 @@ out:
 	return res;
 }
 
+int nfs4_validate_delegation_stateid(struct nfs_delegation *delegation, const nfs4_stateid *stateid)
+{
+	if (delegation == NULL || memcmp(delegation->stateid.data, stateid->data,
+					 sizeof(delegation->stateid.data)) != 0)
+		return 0;
+	return 1;
+}
+
 #if defined(CONFIG_NFS_V4_1)
 
+int nfs41_validate_delegation_stateid(struct nfs_delegation *delegation, const nfs4_stateid *stateid)
+{
+	if (delegation == NULL)
+		return 0;
+
+	/* seqid is 4-bytes long */
+	if (((u32 *) &stateid->data)[0] != 0)
+		return 0;
+	if (memcmp(&delegation->stateid.data[4], &stateid->data[4],
+		   sizeof(stateid->data)-4))
+		return 0;
+
+	return 1;
+}
+
 /*
  * Validate the sequenceID sent by the server.
  * Return success if the sequenceID is one more than what we last saw on
@@ -226,5 +260,4 @@ out:
 	res->csr_status = status;
 	return res->csr_status;
 }
-
 #endif /* CONFIG_NFS_V4_1 */
diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 6dd48a4..af1e6de 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -428,18 +428,21 @@ void nfs_expire_unreferenced_delegations(struct nfs_client *clp)
 /*
  * Asynchronous delegation recall!
  */
-int nfs_async_inode_return_delegation(struct inode *inode, const nfs4_stateid *stateid)
+int nfs_async_inode_return_delegation(struct inode *inode, const nfs4_stateid *stateid,
+				      int (*validate_stateid)(struct nfs_delegation *delegation,
+							      const nfs4_stateid *stateid))
 {
 	struct nfs_client *clp = NFS_SERVER(inode)->nfs_client;
 	struct nfs_delegation *delegation;
 
 	rcu_read_lock();
 	delegation = rcu_dereference(NFS_I(inode)->delegation);
-	if (delegation == NULL || memcmp(delegation->stateid.data, stateid->data,
-				sizeof(delegation->stateid.data)) != 0) {
+
+	if (!validate_stateid(delegation, stateid)) {
 		rcu_read_unlock();
 		return -ENOENT;
 	}
+
 	nfs_mark_return_delegation(clp, delegation);
 	rcu_read_unlock();
 	nfs_delegation_run_state_manager(clp);
diff --git a/fs/nfs/delegation.h b/fs/nfs/delegation.h
index 09f3837..da53869 100644
--- a/fs/nfs/delegation.h
+++ b/fs/nfs/delegation.h
@@ -34,7 +34,9 @@ enum {
 int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct nfs_openres *res);
 void nfs_inode_reclaim_delegation(struct inode *inode, struct rpc_cred *cred, struct nfs_openres *res);
 int nfs_inode_return_delegation(struct inode *inode);
-int nfs_async_inode_return_delegation(struct inode *inode, const nfs4_stateid *stateid);
+int nfs_async_inode_return_delegation(struct inode *inode, const nfs4_stateid *stateid,
+				      int (*validate_stateid)(struct nfs_delegation *delegation,
+							      const nfs4_stateid *stateid));
 void nfs_inode_return_delegation_noreclaim(struct inode *inode);
 
 struct inode *nfs_delegation_find_inode(struct nfs_client *clp, const struct nfs_fh *fhandle);
-- 
1.6.2.5


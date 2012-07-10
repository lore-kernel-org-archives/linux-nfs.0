Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:20538 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756153Ab2GJQQ2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jul 2012 12:16:28 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 12/12] NFS: Split out NFS v4 client functions
Date: Tue, 10 Jul 2012 12:16:17 -0400
Message-Id: <1341936977-21186-13-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1341936977-21186-1-git-send-email-bjschuma@netapp.com>
References: <1341936977-21186-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

These functions are only needed by NFS v4, so they can be moved into a
v4 specific file.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/client.c     | 93 -----------------------------------------------------
 fs/nfs/nfs4client.c | 91 +++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 91 insertions(+), 93 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 0d50629..65afa38 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -56,30 +56,6 @@
 #define NFSDBG_FACILITY		NFSDBG_CLIENT
 
 static DECLARE_WAIT_QUEUE_HEAD(nfs_client_active_wq);
-#ifdef CONFIG_NFS_V4
-
-/*
- * Get a unique NFSv4.0 callback identifier which will be used
- * by the V4.0 callback service to lookup the nfs_client struct
- */
-static int nfs_get_cb_ident_idr(struct nfs_client *clp, int minorversion)
-{
-	int ret = 0;
-	struct nfs_net *nn = net_generic(clp->cl_net, nfs_net_id);
-
-	if (clp->rpc_ops->version != 4 || minorversion != 0)
-		return ret;
-retry:
-	if (!idr_pre_get(&nn->cb_ident_idr, GFP_KERNEL))
-		return -ENOMEM;
-	spin_lock(&nn->nfs_client_lock);
-	ret = idr_get_new(&nn->cb_ident_idr, clp, &clp->cl_cb_ident);
-	spin_unlock(&nn->nfs_client_lock);
-	if (ret == -EAGAIN)
-		goto retry;
-	return ret;
-}
-#endif /* CONFIG_NFS_V4 */
 
 /*
  * RPC cruft for NFS
@@ -175,75 +151,6 @@ error_0:
 }
 
 #ifdef CONFIG_NFS_V4
-#ifdef CONFIG_NFS_V4_1
-static void nfs4_shutdown_session(struct nfs_client *clp)
-{
-	if (nfs4_has_session(clp)) {
-		nfs4_destroy_session(clp->cl_session);
-		nfs4_destroy_clientid(clp);
-	}
-
-}
-#else /* CONFIG_NFS_V4_1 */
-static void nfs4_shutdown_session(struct nfs_client *clp)
-{
-}
-#endif /* CONFIG_NFS_V4_1 */
-
-struct nfs_client *nfs4_alloc_client(const struct nfs_client_initdata *cl_init)
-{
-	int err;
-	struct nfs_client *clp = nfs_alloc_client(cl_init);
-	if (IS_ERR(clp))
-		return clp;
-
-	err = nfs_get_cb_ident_idr(clp, cl_init->minorversion);
-	if (err)
-		goto error;
-
-	spin_lock_init(&clp->cl_lock);
-	INIT_DELAYED_WORK(&clp->cl_renewd, nfs4_renew_state);
-	rpc_init_wait_queue(&clp->cl_rpcwaitq, "NFS client");
-	clp->cl_state = 1 << NFS4CLNT_LEASE_EXPIRED;
-	clp->cl_minorversion = cl_init->minorversion;
-	clp->cl_mvops = nfs_v4_minor_ops[cl_init->minorversion];
-	return clp;
-
-error:
-	kfree(clp);
-	return ERR_PTR(err);
-}
-
-/*
- * Destroy the NFS4 callback service
- */
-static void nfs4_destroy_callback(struct nfs_client *clp)
-{
-	if (__test_and_clear_bit(NFS_CS_CALLBACK, &clp->cl_res_state))
-		nfs_callback_down(clp->cl_mvops->minor_version);
-}
-
-static void nfs4_shutdown_client(struct nfs_client *clp)
-{
-	if (__test_and_clear_bit(NFS_CS_RENEWD, &clp->cl_res_state))
-		nfs4_kill_renewd(clp);
-	nfs4_shutdown_session(clp);
-	nfs4_destroy_callback(clp);
-	if (__test_and_clear_bit(NFS_CS_IDMAP, &clp->cl_res_state))
-		nfs_idmap_delete(clp);
-
-	rpc_destroy_wait_queue(&clp->cl_rpcwaitq);
-	kfree(clp->cl_serverowner);
-	kfree(clp->cl_serverscope);
-	kfree(clp->cl_implid);
-}
-
-void nfs4_free_client(struct nfs_client *clp)
-{
-	nfs4_shutdown_client(clp);
-	nfs_free_client(clp);
-}
-
 /* idr_remove_all is not needed as all id's are removed by nfs_put_client */
 void nfs_cleanup_cb_ident_idr(struct net *net)
 {
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index a71d95e..1c3f13c 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -23,6 +23,97 @@
 static bool nfs4_disable_idmapping = true;
 
 /*
+ * Get a unique NFSv4.0 callback identifier which will be used
+ * by the V4.0 callback service to lookup the nfs_client struct
+ */
+static int nfs_get_cb_ident_idr(struct nfs_client *clp, int minorversion)
+{
+	int ret = 0;
+	struct nfs_net *nn = net_generic(clp->cl_net, nfs_net_id);
+
+	if (clp->rpc_ops->version != 4 || minorversion != 0)
+		return ret;
+retry:
+	if (!idr_pre_get(&nn->cb_ident_idr, GFP_KERNEL))
+		return -ENOMEM;
+	spin_lock(&nn->nfs_client_lock);
+	ret = idr_get_new(&nn->cb_ident_idr, clp, &clp->cl_cb_ident);
+	spin_unlock(&nn->nfs_client_lock);
+	if (ret == -EAGAIN)
+		goto retry;
+	return ret;
+}
+
+#ifdef CONFIG_NFS_V4_1
+static void nfs4_shutdown_session(struct nfs_client *clp)
+{
+	if (nfs4_has_session(clp)) {
+		nfs4_destroy_session(clp->cl_session);
+		nfs4_destroy_clientid(clp);
+	}
+
+}
+#else /* CONFIG_NFS_V4_1 */
+static void nfs4_shutdown_session(struct nfs_client *clp)
+{
+}
+#endif /* CONFIG_NFS_V4_1 */
+
+struct nfs_client *nfs4_alloc_client(const struct nfs_client_initdata *cl_init)
+{
+	int err;
+	struct nfs_client *clp = nfs_alloc_client(cl_init);
+	if (IS_ERR(clp))
+		return clp;
+
+	err = nfs_get_cb_ident_idr(clp, cl_init->minorversion);
+	if (err)
+		goto error;
+
+	spin_lock_init(&clp->cl_lock);
+	INIT_DELAYED_WORK(&clp->cl_renewd, nfs4_renew_state);
+	rpc_init_wait_queue(&clp->cl_rpcwaitq, "NFS client");
+	clp->cl_state = 1 << NFS4CLNT_LEASE_EXPIRED;
+	clp->cl_minorversion = cl_init->minorversion;
+	clp->cl_mvops = nfs_v4_minor_ops[cl_init->minorversion];
+	return clp;
+
+error:
+	kfree(clp);
+	return ERR_PTR(err);
+}
+
+/*
+ * Destroy the NFS4 callback service
+ */
+static void nfs4_destroy_callback(struct nfs_client *clp)
+{
+	if (__test_and_clear_bit(NFS_CS_CALLBACK, &clp->cl_res_state))
+		nfs_callback_down(clp->cl_mvops->minor_version);
+}
+
+static void nfs4_shutdown_client(struct nfs_client *clp)
+{
+	if (__test_and_clear_bit(NFS_CS_RENEWD, &clp->cl_res_state))
+		nfs4_kill_renewd(clp);
+	nfs4_shutdown_session(clp);
+	nfs4_destroy_callback(clp);
+	if (__test_and_clear_bit(NFS_CS_IDMAP, &clp->cl_res_state))
+		nfs_idmap_delete(clp);
+
+	rpc_destroy_wait_queue(&clp->cl_rpcwaitq);
+	kfree(clp->cl_serverowner);
+	kfree(clp->cl_serverscope);
+	kfree(clp->cl_implid);
+}
+
+void nfs4_free_client(struct nfs_client *clp)
+{
+	nfs4_shutdown_client(clp);
+	nfs_free_client(clp);
+}
+
+/*
  * Initialize the NFS4 callback service
  */
 static int nfs4_init_callback(struct nfs_client *clp)
-- 
1.7.11.1


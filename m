Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:28703 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753862Ab0A0Cne (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Jan 2010 21:43:34 -0500
From: Alexandros Batsakis <batsakis@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: trond@netapp.com, Alexandros Batsakis <batsakis@netapp.com>
Subject: [PATCH 1/4] nfs: kill renewd before clearing the client session
Date: Tue, 26 Jan 2010 18:43:52 -0800
Message-Id: <1264560235-2478-1-git-send-email-batsakis@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
---
 fs/nfs/client.c |   47 +++++++++++++++++++++++------------------------
 1 files changed, 23 insertions(+), 24 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index d0b060a..07e4b56 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -164,30 +164,6 @@ error_0:
 	return ERR_PTR(err);
 }
 
-static void nfs4_shutdown_client(struct nfs_client *clp)
-{
-#ifdef CONFIG_NFS_V4
-	if (__test_and_clear_bit(NFS_CS_RENEWD, &clp->cl_res_state))
-		nfs4_kill_renewd(clp);
-	BUG_ON(!RB_EMPTY_ROOT(&clp->cl_state_owners));
-	if (__test_and_clear_bit(NFS_CS_IDMAP, &clp->cl_res_state))
-		nfs_idmap_delete(clp);
-
-	rpc_destroy_wait_queue(&clp->cl_rpcwaitq);
-#endif
-}
-
-/*
- * Destroy the NFS4 callback service
- */
-static void nfs4_destroy_callback(struct nfs_client *clp)
-{
-#ifdef CONFIG_NFS_V4
-	if (__test_and_clear_bit(NFS_CS_CALLBACK, &clp->cl_res_state))
-		nfs_callback_down(clp->cl_minorversion);
-#endif /* CONFIG_NFS_V4 */
-}
-
 /*
  * Clears/puts all minor version specific parts from an nfs_client struct
  * reverting it to minorversion 0.
@@ -202,9 +178,31 @@ static void nfs4_clear_client_minor_version(struct nfs_client *clp)
 
 	clp->cl_call_sync = _nfs4_call_sync;
 #endif /* CONFIG_NFS_V4_1 */
+}
+
+/*
+ * Destroy the NFS4 callback service
+ */
+static void nfs4_destroy_callback(struct nfs_client *clp)
+{
+#ifdef CONFIG_NFS_V4
+	if (__test_and_clear_bit(NFS_CS_CALLBACK, &clp->cl_res_state))
+		nfs_callback_down(clp->cl_minorversion);
+#endif /* CONFIG_NFS_V4 */
+}
 
+static void nfs4_shutdown_client(struct nfs_client *clp)
+{
+#ifdef CONFIG_NFS_V4
+	if (__test_and_clear_bit(NFS_CS_RENEWD, &clp->cl_res_state))
+		nfs4_kill_renewd(clp);
+	nfs4_clear_client_minor_version(clp);
 	nfs4_destroy_callback(clp);
+	if (__test_and_clear_bit(NFS_CS_IDMAP, &clp->cl_res_state))
+		nfs_idmap_delete(clp);
+
+	rpc_destroy_wait_queue(&clp->cl_rpcwaitq);
+#endif
 }
 
 /*
-- 
1.6.2.5


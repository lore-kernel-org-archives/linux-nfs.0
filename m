From: Alexandros Batsakis <batsakis@netapp.com>
Subject: [PATCH 1/6] nfs: kill renewd before clearing client minor version
Date: Tue,  2 Feb 2010 16:06:11 -0800
Message-ID: <1265155576-7618-2-git-send-email-batsakis@netapp.com>
References: <1265155576-7618-1-git-send-email-batsakis@netapp.com>
Cc: trond@netapp.com, Alexandros Batsakis <batsakis@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:10918 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933298Ab0BDUdL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Feb 2010 15:33:11 -0500
In-Reply-To: <1265155576-7618-1-git-send-email-batsakis@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
---
 fs/nfs/client.c |   45 ++++++++++++++++++++++-----------------------
 1 files changed, 22 insertions(+), 23 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index d0b060a..f712e52 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -164,17 +164,20 @@ error_0:
 	return ERR_PTR(err);
 }
 
-static void nfs4_shutdown_client(struct nfs_client *clp)
+/*
+ * Clears/puts all minor version specific parts from an nfs_client struct
+ * reverting it to minorversion 0.
+ */
+static void nfs4_clear_client_minor_version(struct nfs_client *clp)
 {
-#ifdef CONFIG_NFS_V4
-	if (__test_and_clear_bit(NFS_CS_RENEWD, &clp->cl_res_state))
-		nfs4_kill_renewd(clp);
-	BUG_ON(!RB_EMPTY_ROOT(&clp->cl_state_owners));
-	if (__test_and_clear_bit(NFS_CS_IDMAP, &clp->cl_res_state))
-		nfs_idmap_delete(clp);
+#ifdef CONFIG_NFS_V4_1
+	if (nfs4_has_session(clp)) {
+		nfs4_destroy_session(clp->cl_session);
+		clp->cl_session = NULL;
+	}
 
-	rpc_destroy_wait_queue(&clp->cl_rpcwaitq);
-#endif
+	clp->cl_call_sync = _nfs4_call_sync;
+#endif /* CONFIG_NFS_V4_1 */
 }
 
 /*
@@ -188,22 +191,18 @@ static void nfs4_destroy_callback(struct nfs_client *clp)
 #endif /* CONFIG_NFS_V4 */
 }
 
-/*
- * Clears/puts all minor version specific parts from an nfs_client struct
- * reverting it to minorversion 0.
- */
-static void nfs4_clear_client_minor_version(struct nfs_client *clp)
+static void nfs4_shutdown_client(struct nfs_client *clp)
 {
-#ifdef CONFIG_NFS_V4_1
-	if (nfs4_has_session(clp)) {
-		nfs4_destroy_session(clp->cl_session);
-		clp->cl_session = NULL;
-	}
-
-	clp->cl_call_sync = _nfs4_call_sync;
-#endif /* CONFIG_NFS_V4_1 */
-
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


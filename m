Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:61755 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756250AbcBXR44 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Feb 2016 12:56:56 -0500
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 5/8] NFS detect session trunking
Date: Wed, 24 Feb 2016 12:56:24 -0500
Message-ID: <1456336587-17374-6-git-send-email-andros@netapp.com>
In-Reply-To: <1456336587-17374-1-git-send-email-andros@netapp.com>
References: <1456336587-17374-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/internal.h   |  2 ++
 fs/nfs/nfs4client.c | 52 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 54 insertions(+)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 0296476..e11056c 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -549,6 +549,8 @@ extern int nfs40_walk_client_list(struct nfs_client *clp,
 extern int nfs41_walk_client_list(struct nfs_client *clp,
 				struct nfs_client **result,
 				struct rpc_cred *cred);
+extern int nfs4_detect_session_trunking(struct nfs_client *clp,
+				struct nfs41_exchange_id_res *res);
 
 static inline struct inode *nfs_igrab_and_active(struct inode *inode)
 {
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 5a14fda..1606a14 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -596,6 +596,58 @@ out_major_mismatch:
 }
 
 /**
+ * nfs4_detect_session_trunking - Checks for ssession trunking called
+ * after a successuful EXCHANGE_ID testing a multi-addr connection to be
+ * potentially added as a session trunk
+ *
+ * @clp:    original mount nfs_client
+ * @res:    result structure from an exchange_id using the original mount
+ *          nfs_client with a new multi_addr transport
+ *
+ * Returns zero on success, otherwise -EINVAL
+ *
+ * Note: since the exchange_id for the new multi_addr transport uses the
+ * same nfs_client from the original mount, the cl_owner_id is reused,
+ * so eir_clientowner is the same.
+ */
+int nfs4_detect_session_trunking(struct nfs_client *clp,
+				 struct nfs41_exchange_id_res *res)
+{
+	struct nfs41_server_scope *s1 = clp->cl_serverscope;
+	struct nfs41_server_scope *s2 = res->server_scope;
+	int status = -EINVAL; /* if session trunk checks fail */
+
+	/* Check eir_clientid */
+	if (!nfs4_match_clientids(clp->cl_clientid, res->clientid))
+		return status;
+
+	/* Check eir_server_owner so_major_id */
+	if (!nfs4_check_serverowner_major_id(clp->cl_serverowner,
+					     res->server_owner))
+		return status;
+
+	/* Check eir_server_owner so_minor_id */
+	if (clp->cl_serverowner->minor_id != res->server_owner->minor_id)
+		goto out_minor_mismatch;
+
+	/* Check eir_server_scope */
+	if (s1->server_scope_sz != s2->server_scope_sz)
+		goto out_scope_mismatch;
+	if (memcmp(s1->server_scope, s2->server_scope,
+		   s1->server_scope_sz) != 0)
+		goto out_scope_mismatch;
+
+	return 0;
+
+out_minor_mismatch:
+	dprintk("NFS: --> %s server owner minor IDs do not match\n", __func__);
+	return status;
+out_scope_mismatch:
+	dprintk("NFS: --> %s server scopes do not match\n", __func__);
+	return status;
+}
+
+/**
  * nfs41_walk_client_list - Find nfs_client that matches a client/server owner
  *
  * @new: nfs_client with client ID to test
-- 
1.8.3.1


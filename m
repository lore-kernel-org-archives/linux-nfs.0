Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:13162 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753339AbcD0Pgk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Apr 2016 11:36:40 -0400
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <steved@redhat.com>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 3 5/9] NFS detect session trunking
Date: Wed, 27 Apr 2016 11:36:06 -0400
Message-ID: <1461771370-16375-6-git-send-email-andros@netapp.com>
In-Reply-To: <1461771370-16375-1-git-send-email-andros@netapp.com>
References: <1461771370-16375-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/internal.h   |  2 ++
 fs/nfs/nfs4client.c | 83 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 84 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 606b153..14d957c 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -545,6 +545,8 @@ extern int nfs40_walk_client_list(struct nfs_client *clp,
 extern int nfs41_walk_client_list(struct nfs_client *clp,
 				struct nfs_client **result,
 				struct rpc_cred *cred);
+extern int nfs4_detect_session_trunking(struct nfs_client *clp,
+				struct nfs41_exchange_id_res *res);
 
 static inline struct inode *nfs_igrab_and_active(struct inode *inode)
 {
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 5a14fda..2121c1f 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -586,7 +586,7 @@ nfs4_check_serverowner_major_id(struct nfs41_server_owner *o1,
 	if (memcmp(o1->major_id, o2->major_id, o1->major_id_sz) != 0)
 		goto out_major_mismatch;
 
-	dprintk("NFS: --> %s server owners match\n", __func__);
+	dprintk("NFS: --> %s server owner major IDs match\n", __func__);
 	return true;
 
 out_major_mismatch:
@@ -595,6 +595,87 @@ out_major_mismatch:
 	return false;
 }
 
+/*
+ * Returns true if server minor ids match
+ */
+static bool
+nfs4_check_serverowner_minor_id(struct nfs41_server_owner *o1,
+				struct nfs41_server_owner *o2)
+{
+	/* Check eir_server_owner so_minor_id */
+	if (o1->minor_id != o2->minor_id)
+		goto out_minor_mismatch;
+
+	dprintk("NFS: --> %s server owner minor IDs s match\n", __func__);
+	return true;
+
+out_minor_mismatch:
+	dprintk("NFS: --> %s server owner minor IDs do not match\n", __func__);
+	return false;
+}
+
+/*
+ * Returns true if the server scopes match
+ */
+static bool
+nfs4_check_server_scope(struct nfs41_server_scope *s1,
+			struct nfs41_server_scope *s2)
+{
+	if (s1->server_scope_sz != s2->server_scope_sz)
+		goto out_scope_mismatch;
+	if (memcmp(s1->server_scope, s2->server_scope,
+		   s1->server_scope_sz) != 0)
+		goto out_scope_mismatch;
+
+	dprintk("NFS: --> %s server scopes match\n", __func__);
+	return true;
+
+out_scope_mismatch:
+	dprintk("NFS: --> %s server scopes do not match\n",
+		__func__);
+	return false;
+}
+
+/**
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
+
+	/* Check eir_clientid */
+	if (!nfs4_match_clientids(clp->cl_clientid, res->clientid))
+		return -EINVAL;
+
+	/* Check eir_server_owner so_major_id */
+	if (!nfs4_check_serverowner_major_id(clp->cl_serverowner,
+					     res->server_owner))
+		return -EINVAL;
+
+	/* Check eir_server_owner so_minor_id */
+	if (!nfs4_check_serverowner_minor_id(clp->cl_serverowner,
+					     res->server_owner))
+		return -EINVAL;
+
+	/* Check eir_server_scope */
+	if (!nfs4_check_server_scope(clp->cl_serverscope, res->server_scope))
+		return -EINVAL;
+
+	return 0;
+}
+
 /**
  * nfs41_walk_client_list - Find nfs_client that matches a client/server owner
  *
-- 
1.8.3.1


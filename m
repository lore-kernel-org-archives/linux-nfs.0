Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:19787 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757928AbcG0SpH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Jul 2016 14:45:07 -0400
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <anna.schumaker@netapp.com>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 7 4/8] NFS detect session trunking
Date: Wed, 27 Jul 2016 14:43:16 -0400
Message-ID: <1469645000-19791-5-git-send-email-andros@netapp.com>
In-Reply-To: <1469645000-19791-1-git-send-email-andros@netapp.com>
References: <1469645000-19791-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4_fs.h    |  2 ++
 fs/nfs/nfs4client.c | 93 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 95 insertions(+)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 4be567a..eb315e1 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -277,6 +277,8 @@ extern int nfs4_proc_get_lease_time(struct nfs_client *clp,
 		struct nfs_fsinfo *fsinfo);
 extern int nfs4_proc_layoutcommit(struct nfs4_layoutcommit_data *data,
 				  bool sync);
+extern int nfs4_detect_session_trunking(struct nfs_client *clp,
+		struct nfs41_exchange_id_res *res, struct rpc_xprt *xprt);
 
 static inline bool
 is_ds_only_client(struct nfs_client *clp)
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index f356d50..37a9416 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -595,6 +595,99 @@ out_major_mismatch:
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
+				 struct nfs41_exchange_id_res *res,
+				 struct rpc_xprt *xprt)
+{
+	int status = -EINVAL;
+	/* Check eir_clientid */
+	if (!nfs4_match_clientids(clp->cl_clientid, res->clientid))
+		goto out;
+
+	/* Check eir_server_owner so_major_id */
+	if (!nfs4_check_serverowner_major_id(clp->cl_serverowner,
+					     res->server_owner))
+		goto out;
+
+	/* Check eir_server_owner so_minor_id */
+	if (!nfs4_check_serverowner_minor_id(clp->cl_serverowner,
+					     res->server_owner))
+		goto out;
+
+	/* Check eir_server_scope */
+	if (!nfs4_check_server_scope(clp->cl_serverscope, res->server_scope))
+		goto out;
+
+	status = 0;
+out:
+	if (status)
+		pr_info("NFS:  %s: Session trunking failed for %s status %d\n",
+			clp->cl_hostname,
+			xprt->address_strings[RPC_DISPLAY_ADDR], status);
+	else
+		pr_info("NFS:  %s: Session trunking succeeded for %s\n",
+			clp->cl_hostname,
+			xprt->address_strings[RPC_DISPLAY_ADDR]);
+
+	return status;
+}
+
 /**
  * nfs41_walk_client_list - Find nfs_client that matches a client/server owner
  *
-- 
1.8.3.1


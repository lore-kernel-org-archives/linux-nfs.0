From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 2/3] SQUASHME: nfs41: move nfs4_session_set_rwsize into CONFIG_NFS_V4
Date: Mon,  6 Apr 2009 10:49:58 +0300
Message-ID: <1239004198-8708-1-git-send-email-bhalevy@panasas.com>
References: <49D9B2B9.5010401@panasas.com>
Cc: Andy Adamson <andros@netapp.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	linux-next@vger.kernel.org, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:3347 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751625AbZDFHuO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Apr 2009 03:50:14 -0400
In-Reply-To: <49D9B2B9.5010401@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

fix compiler warning:
fs/nfs/client.c:554: warning: 'nfs4_session_set_rwsize' defined but not used

Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/client.c |   30 +++++++++++++++---------------
 1 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index eb341d3..9999f13 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -551,21 +551,6 @@ int nfs4_check_client_ready(struct nfs_client *clp)
 }
 
 /*
- * Session has been established, and the client marked ready.
- * Set the mount rsize and wsize with negotiated fore channel
- * attributes which will be bound checked in nfs_server_set_fsinfo.
- */
-static void nfs4_session_set_rwsize(struct nfs_server *server)
-{
-#ifdef CONFIG_NFS_V4_1
-	if (!nfs4_has_session(server->nfs_client))
-		return;
-	server->rsize = server->nfs_client->cl_session->fc_attrs.max_resp_sz;
-	server->wsize = server->nfs_client->cl_session->fc_attrs.max_rqst_sz;
-#endif /* CONFIG_NFS_V4_1 */
-}
-
-/*
  * Initialise the timeout values for a connection
  */
 static void nfs_init_timeout_values(struct rpc_timeout *to, int proto,
@@ -1246,6 +1231,21 @@ static void nfs4_init_session(struct nfs_client *clp,
 }
 
 /*
+ * Session has been established, and the client marked ready.
+ * Set the mount rsize and wsize with negotiated fore channel
+ * attributes which will be bound checked in nfs_server_set_fsinfo.
+ */
+static void nfs4_session_set_rwsize(struct nfs_server *server)
+{
+#ifdef CONFIG_NFS_V4_1
+	if (!nfs4_has_session(server->nfs_client))
+		return;
+	server->rsize = server->nfs_client->cl_session->fc_attrs.max_resp_sz;
+	server->wsize = server->nfs_client->cl_session->fc_attrs.max_rqst_sz;
+#endif /* CONFIG_NFS_V4_1 */
+}
+
+/*
  * Create a version 4 volume record
  */
 static int nfs4_init_server(struct nfs_server *server,
-- 
1.6.2.1


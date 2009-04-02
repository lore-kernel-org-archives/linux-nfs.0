From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 48/67] nfs41: use session attributes for rsize and wsize
Date: Thu,  2 Apr 2009 16:57:33 +0300
Message-ID: <1238680653-14903-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:22043 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752337AbZDBN6b (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:58:31 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Set the mount points rsize and wsize to the negotiated session fore channel
maximum response and requeset size. These values will be bound checked in
nfs_server_set_fsinfo.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/client.c |   17 +++++++++++++++++
 1 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 562f658..fda2c53 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -527,6 +527,21 @@ static void nfs_mark_client_ready(struct nfs_client *clp, int state)
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
  * Initialise the timeout values for a connection
  */
 static void nfs_init_timeout_values(struct rpc_timeout *to, int proto,
@@ -1296,6 +1311,8 @@ struct nfs_server *nfs4_create_server(const struct nfs_parsed_mount_data *data,
 		(unsigned long long) server->fsid.minor);
 	dprintk("Mount FH: %d\n", mntfh->size);
 
+	nfs4_session_set_rwsize(server);
+
 	error = nfs_probe_fsinfo(server, mntfh, &fattr);
 	if (error < 0)
 		goto error;
-- 
1.6.2.1


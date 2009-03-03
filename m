From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 04/46] nfs41: nfs_client.cl_minorversion
Date: Wed,  4 Mar 2009 01:52:21 +0200
Message-ID: <1236124341-3091-1-git-send-email-bhalevy@panasas.com>
References: <49ADBD04.2090002@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:17377
	"EHLO natasha.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753290AbZCCXwb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2009 18:52:31 -0500
In-Reply-To: <49ADBD04.2090002@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This field is set to the nfsv4 minor version for this mount.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>

Note: This patch sets the referral to the same minorversion as the
current mount. Revisit in future patch.

Signed-off-by: Andy Adamson <andros@netapp.com>
[removed cl_minorversion assignment in nfs_set_client]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/client.c           |    9 ++++++---
 include/linux/nfs_fs_sb.h |    3 ++-
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 9b728f3..2555e48 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1036,7 +1036,8 @@ static int nfs4_set_client(struct nfs_server *server,
 		const size_t addrlen,
 		const char *ip_addr,
 		rpc_authflavor_t authflavour,
-		int proto, const struct rpc_timeout *timeparms)
+		int proto, const struct rpc_timeout *timeparms,
+		u32 minorversion)
 {
 	struct nfs_client_initdata cl_init = {
 		.hostname = hostname,
@@ -1098,7 +1099,8 @@ static int nfs4_init_server(struct nfs_server *server,
 			data->client_address,
 			data->auth_flavors[0],
 			data->nfs_server.protocol,
-			&timeparms);
+			&timeparms,
+			data->minorversion);
 	if (error < 0)
 		goto error;
 
@@ -1216,7 +1218,8 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 				parent_client->cl_ipaddr,
 				data->authflavor,
 				parent_server->client->cl_xprt->prot,
-				parent_server->client->cl_timeout);
+				parent_server->client->cl_timeout,
+				parent_client->cl_minorversion);
 	if (error < 0)
 		goto error;
 
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 9bb81ae..63f8b00 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -63,7 +63,8 @@ struct nfs_client {
 	 */
 	char			cl_ipaddr[48];
 	unsigned char		cl_id_uniquifier;
-#endif
+	u32			cl_minorversion;
+#endif /* CONFIG_NFS_V4 */
 };
 
 /*
-- 
1.6.1.3


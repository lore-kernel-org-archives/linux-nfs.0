From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 05/67] nfs41: nfs_client.cl_minorversion
Date: Thu,  2 Apr 2009 16:51:07 +0300
Message-ID: <1238680267-13557-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:28008 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754573AbZDBNvQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:51:16 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
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
index 0f962db..25ea8e4 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1101,7 +1101,8 @@ static int nfs4_set_client(struct nfs_server *server,
 		const size_t addrlen,
 		const char *ip_addr,
 		rpc_authflavor_t authflavour,
-		int proto, const struct rpc_timeout *timeparms)
+		int proto, const struct rpc_timeout *timeparms,
+		u32 minorversion)
 {
 	struct nfs_client_initdata cl_init = {
 		.hostname = hostname,
@@ -1164,7 +1165,8 @@ static int nfs4_init_server(struct nfs_server *server,
 			data->client_address,
 			data->auth_flavors[0],
 			data->nfs_server.protocol,
-			&timeparms);
+			&timeparms,
+			data->minorversion);
 	if (error < 0)
 		goto error;
 
@@ -1282,7 +1284,8 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 				parent_client->cl_ipaddr,
 				data->authflavor,
 				parent_server->client->cl_xprt->prot,
-				parent_server->client->cl_timeout);
+				parent_server->client->cl_timeout,
+				parent_client->cl_minorversion);
 	if (error < 0)
 		goto error;
 
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 6ad7594..477de6c 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -63,7 +63,8 @@ struct nfs_client {
 	 */
 	char			cl_ipaddr[48];
 	unsigned char		cl_id_uniquifier;
-#endif
+	u32			cl_minorversion;
+#endif /* CONFIG_NFS_V4 */
 
 #ifdef CONFIG_NFS_FSCACHE
 	struct fscache_cookie	*fscache;	/* client index cache cookie */
-- 
1.6.2.1


From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 04/24] NFS: Reduce the stack footprint of nfs_create_server
Date: Fri, 16 Apr 2010 16:31:02 -0400
Message-ID: <1271449882-8580-5-git-send-email-Trond.Myklebust@netapp.com>
References: <1271449882-8580-1-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-2-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-3-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-4-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:8551 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932442Ab0DPUb0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Apr 2010 16:31:26 -0400
Received: from localhost.localdomain (marilynd-lxp.hq.netapp.com [10.58.50.136] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o3GKVMkx026251
	for <linux-nfs@vger.kernel.org>; Fri, 16 Apr 2010 13:31:25 -0700 (PDT)
In-Reply-To: <1271449882-8580-4-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/client.c |   50 +++++++++++++++++++++++++++++++++++++++-----------
 1 files changed, 39 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 48fc680..dc242fa 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1045,13 +1045,18 @@ struct nfs_server *nfs_create_server(const struct nfs_parsed_mount_data *data,
 				     struct nfs_fh *mntfh)
 {
 	struct nfs_server *server;
-	struct nfs_fattr fattr;
+	struct nfs_fattr *fattr;
 	int error;
 
 	server = nfs_alloc_server();
 	if (!server)
 		return ERR_PTR(-ENOMEM);
 
+	error = -ENOMEM;
+	fattr = nfs_alloc_fattr();
+	if (fattr == NULL)
+		goto error;
+
 	/* Get a client representation */
 	error = nfs_init_server(server, data);
 	if (error < 0)
@@ -1062,7 +1067,7 @@ struct nfs_server *nfs_create_server(const struct nfs_parsed_mount_data *data,
 	BUG_ON(!server->nfs_client->rpc_ops->file_inode_ops);
 
 	/* Probe the root fh to retrieve its FSID */
-	error = nfs_probe_fsinfo(server, mntfh, &fattr);
+	error = nfs_probe_fsinfo(server, mntfh, fattr);
 	if (error < 0)
 		goto error;
 	if (server->nfs_client->rpc_ops->version == 3) {
@@ -1075,14 +1080,14 @@ struct nfs_server *nfs_create_server(const struct nfs_parsed_mount_data *data,
 			server->namelen = NFS2_MAXNAMLEN;
 	}
 
-	if (!(fattr.valid & NFS_ATTR_FATTR)) {
-		error = server->nfs_client->rpc_ops->getattr(server, mntfh, &fattr);
+	if (!(fattr->valid & NFS_ATTR_FATTR)) {
+		error = server->nfs_client->rpc_ops->getattr(server, mntfh, fattr);
 		if (error < 0) {
 			dprintk("nfs_create_server: getattr error = %d\n", -error);
 			goto error;
 		}
 	}
-	memcpy(&server->fsid, &fattr.fsid, sizeof(server->fsid));
+	memcpy(&server->fsid, &fattr->fsid, sizeof(server->fsid));
 
 	dprintk("Server FSID: %llx:%llx\n",
 		(unsigned long long) server->fsid.major,
@@ -1094,9 +1099,11 @@ struct nfs_server *nfs_create_server(const struct nfs_parsed_mount_data *data,
 	spin_unlock(&nfs_client_lock);
 
 	server->mount_time = jiffies;
+	nfs_free_fattr(fattr);
 	return server;
 
 error:
+	nfs_free_fattr(fattr);
 	nfs_free_server(server);
 	return ERR_PTR(error);
 }
@@ -1338,7 +1345,7 @@ error:
 struct nfs_server *nfs4_create_server(const struct nfs_parsed_mount_data *data,
 				      struct nfs_fh *mntfh)
 {
-	struct nfs_fattr fattr;
+	struct nfs_fattr *fattr;
 	struct nfs_server *server;
 	int error;
 
@@ -1348,6 +1355,11 @@ struct nfs_server *nfs4_create_server(const struct nfs_parsed_mount_data *data,
 	if (!server)
 		return ERR_PTR(-ENOMEM);
 
+	error = -ENOMEM;
+	fattr = nfs_alloc_fattr();
+	if (fattr == NULL)
+		goto error;
+
 	/* set up the general RPC client */
 	error = nfs4_init_server(server, data);
 	if (error < 0)
@@ -1373,7 +1385,7 @@ struct nfs_server *nfs4_create_server(const struct nfs_parsed_mount_data *data,
 
 	nfs4_session_set_rwsize(server);
 
-	error = nfs_probe_fsinfo(server, mntfh, &fattr);
+	error = nfs_probe_fsinfo(server, mntfh, fattr);
 	if (error < 0)
 		goto error;
 
@@ -1387,9 +1399,11 @@ struct nfs_server *nfs4_create_server(const struct nfs_parsed_mount_data *data,
 
 	server->mount_time = jiffies;
 	dprintk("<-- nfs4_create_server() = %p\n", server);
+	nfs_free_fattr(fattr);
 	return server;
 
 error:
+	nfs_free_fattr(fattr);
 	nfs_free_server(server);
 	dprintk("<-- nfs4_create_server() = error %d\n", error);
 	return ERR_PTR(error);
@@ -1403,7 +1417,7 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 {
 	struct nfs_client *parent_client;
 	struct nfs_server *server, *parent_server;
-	struct nfs_fattr fattr;
+	struct nfs_fattr *fattr;
 	int error;
 
 	dprintk("--> nfs4_create_referral_server()\n");
@@ -1412,6 +1426,11 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 	if (!server)
 		return ERR_PTR(-ENOMEM);
 
+	error = -ENOMEM;
+	fattr = nfs_alloc_fattr();
+	if (fattr == NULL)
+		goto error;
+
 	parent_server = NFS_SB(data->sb);
 	parent_client = parent_server->nfs_client;
 
@@ -1446,7 +1465,7 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 		goto error;
 
 	/* probe the filesystem info for this server filesystem */
-	error = nfs_probe_fsinfo(server, mntfh, &fattr);
+	error = nfs_probe_fsinfo(server, mntfh, fattr);
 	if (error < 0)
 		goto error;
 
@@ -1464,10 +1483,12 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 
 	server->mount_time = jiffies;
 
+	nfs_free_fattr(fattr);
 	dprintk("<-- nfs_create_referral_server() = %p\n", server);
 	return server;
 
 error:
+	nfs_free_fattr(fattr);
 	nfs_free_server(server);
 	dprintk("<-- nfs4_create_referral_server() = error %d\n", error);
 	return ERR_PTR(error);
@@ -1483,7 +1504,7 @@ struct nfs_server *nfs_clone_server(struct nfs_server *source,
 				    struct nfs_fattr *fattr)
 {
 	struct nfs_server *server;
-	struct nfs_fattr fattr_fsinfo;
+	struct nfs_fattr *fattr_fsinfo;
 	int error;
 
 	dprintk("--> nfs_clone_server(,%llx:%llx,)\n",
@@ -1494,6 +1515,11 @@ struct nfs_server *nfs_clone_server(struct nfs_server *source,
 	if (!server)
 		return ERR_PTR(-ENOMEM);
 
+	error = -ENOMEM;
+	fattr_fsinfo = nfs_alloc_fattr();
+	if (fattr_fsinfo == NULL)
+		goto out_free_server;
+
 	/* Copy data from the source */
 	server->nfs_client = source->nfs_client;
 	atomic_inc(&server->nfs_client->cl_count);
@@ -1510,7 +1536,7 @@ struct nfs_server *nfs_clone_server(struct nfs_server *source,
 		nfs_init_server_aclclient(server);
 
 	/* probe the filesystem info for this server filesystem */
-	error = nfs_probe_fsinfo(server, fh, &fattr_fsinfo);
+	error = nfs_probe_fsinfo(server, fh, fattr_fsinfo);
 	if (error < 0)
 		goto out_free_server;
 
@@ -1532,10 +1558,12 @@ struct nfs_server *nfs_clone_server(struct nfs_server *source,
 
 	server->mount_time = jiffies;
 
+	nfs_free_fattr(fattr_fsinfo);
 	dprintk("<-- nfs_clone_server() = %p\n", server);
 	return server;
 
 out_free_server:
+	nfs_free_fattr(fattr_fsinfo);
 	nfs_free_server(server);
 	dprintk("<-- nfs_clone_server() = error %d\n", error);
 	return ERR_PTR(error);
-- 
1.6.6.1


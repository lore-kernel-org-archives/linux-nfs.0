Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:43242 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753017Ab2DWUxn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Apr 2012 16:53:43 -0400
Received: by mail-iy0-f174.google.com with SMTP id i9so2498807iad.19
        for <linux-nfs@vger.kernel.org>; Mon, 23 Apr 2012 13:53:43 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/20] NFS: Use proper naming conventions for the
 nfs_client.net field
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 23 Apr 2012 16:53:41 -0400
Message-ID: <20120423205341.11446.47234.stgit@degas.1015granger.net>
In-Reply-To: <20120423205312.11446.67081.stgit@degas.1015granger.net>
References: <20120423205312.11446.67081.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up:  When naming fields and data types, follow established
conventions to facilitate accurate grep/cscope searches.

Introduced by commit e50a7a1a "NFS: make NFS client allocated per
network namespace context," Tue Jan 10, 2012.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/blocklayout/blocklayoutdev.c |    2 +-
 fs/nfs/client.c                     |   22 +++++++++++-----------
 fs/nfs/idmap.c                      |    4 ++--
 fs/nfs/nfs4filelayoutdev.c          |    2 +-
 include/linux/nfs_fs_sb.h           |    2 +-
 5 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayoutdev.c b/fs/nfs/blocklayout/blocklayoutdev.c
index 45aabbf..9d3b642 100644
--- a/fs/nfs/blocklayout/blocklayoutdev.c
+++ b/fs/nfs/blocklayout/blocklayoutdev.c
@@ -123,7 +123,7 @@ nfs4_blk_decode_device(struct nfs_server *server,
 	uint8_t *dataptr;
 	DECLARE_WAITQUEUE(wq, current);
 	int offset, len, i, rc;
-	struct net *net = server->nfs_client->net;
+	struct net *net = server->nfs_client->cl_net;
 	struct nfs_net *nn = net_generic(net, nfs_net_id);
 	struct bl_dev_msg *reply = &nn->bl_mount_reply;
 
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 654150a..c0232aa 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -65,7 +65,7 @@ static DECLARE_WAIT_QUEUE_HEAD(nfs_client_active_wq);
 static int nfs_get_cb_ident_idr(struct nfs_client *clp, int minorversion)
 {
 	int ret = 0;
-	struct nfs_net *nn = net_generic(clp->net, nfs_net_id);
+	struct nfs_net *nn = net_generic(clp->cl_net, nfs_net_id);
 
 	if (clp->rpc_ops->version != 4 || minorversion != 0)
 		return ret;
@@ -172,7 +172,7 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 	clp->cl_rpcclient = ERR_PTR(-EINVAL);
 
 	clp->cl_proto = cl_init->proto;
-	clp->net = get_net(cl_init->net);
+	clp->cl_net = get_net(cl_init->net);
 
 #ifdef CONFIG_NFS_V4
 	err = nfs_get_cb_ident_idr(clp, cl_init->minorversion);
@@ -250,7 +250,7 @@ void nfs_cleanup_cb_ident_idr(struct net *net)
 /* nfs_client_lock held */
 static void nfs_cb_idr_remove_locked(struct nfs_client *clp)
 {
-	struct nfs_net *nn = net_generic(clp->net, nfs_net_id);
+	struct nfs_net *nn = net_generic(clp->cl_net, nfs_net_id);
 
 	if (clp->cl_cb_ident)
 		idr_remove(&nn->cb_ident_idr, clp->cl_cb_ident);
@@ -303,7 +303,7 @@ static void nfs_free_client(struct nfs_client *clp)
 	if (clp->cl_machine_cred != NULL)
 		put_rpccred(clp->cl_machine_cred);
 
-	put_net(clp->net);
+	put_net(clp->cl_net);
 	kfree(clp->cl_hostname);
 	kfree(clp);
 
@@ -321,7 +321,7 @@ void nfs_put_client(struct nfs_client *clp)
 		return;
 
 	dprintk("--> nfs_put_client({%d})\n", atomic_read(&clp->cl_count));
-	nn = net_generic(clp->net, nfs_net_id);
+	nn = net_generic(clp->cl_net, nfs_net_id);
 
 	if (atomic_dec_and_lock(&clp->cl_count, &nn->nfs_client_lock)) {
 		list_del(&clp->cl_share_link);
@@ -659,7 +659,7 @@ static int nfs_create_rpc_client(struct nfs_client *clp,
 {
 	struct rpc_clnt		*clnt = NULL;
 	struct rpc_create_args args = {
-		.net		= clp->net,
+		.net		= clp->cl_net,
 		.protocol	= clp->cl_proto,
 		.address	= (struct sockaddr *)&clp->cl_addr,
 		.addrsize	= clp->cl_addrlen,
@@ -713,7 +713,7 @@ static int nfs_start_lockd(struct nfs_server *server)
 		.nfs_version	= clp->rpc_ops->version,
 		.noresvport	= server->flags & NFS_MOUNT_NORESVPORT ?
 					1 : 0,
-		.net		= clp->net,
+		.net		= clp->cl_net,
 	};
 
 	if (nlm_init.nfs_version > 3)
@@ -1048,7 +1048,7 @@ static void nfs_server_copy_userdata(struct nfs_server *target, struct nfs_serve
 static void nfs_server_insert_lists(struct nfs_server *server)
 {
 	struct nfs_client *clp = server->nfs_client;
-	struct nfs_net *nn = net_generic(clp->net, nfs_net_id);
+	struct nfs_net *nn = net_generic(clp->cl_net, nfs_net_id);
 
 	spin_lock(&nn->nfs_client_lock);
 	list_add_tail_rcu(&server->client_link, &clp->cl_superblocks);
@@ -1065,7 +1065,7 @@ static void nfs_server_remove_lists(struct nfs_server *server)
 
 	if (clp == NULL)
 		return;
-	nn = net_generic(clp->net, nfs_net_id);
+	nn = net_generic(clp->cl_net, nfs_net_id);
 	spin_lock(&nn->nfs_client_lock);
 	list_del_rcu(&server->client_link);
 	if (list_empty(&clp->cl_superblocks))
@@ -1474,7 +1474,7 @@ struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp,
 		.rpc_ops = &nfs_v4_clientops,
 		.proto = ds_proto,
 		.minorversion = mds_clp->cl_minorversion,
-		.net = mds_clp->net,
+		.net = mds_clp->cl_net,
 	};
 	struct rpc_timeout ds_timeout = {
 		.to_initval = 15 * HZ,
@@ -1701,7 +1701,7 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 				rpc_protocol(parent_server->client),
 				parent_server->client->cl_timeout,
 				parent_client->cl_mvops->minor_version,
-				parent_client->net);
+				parent_client->cl_net);
 	if (error < 0)
 		goto error;
 
diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index b7f348b..f349eca 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -415,7 +415,7 @@ static int __nfs_idmap_register(struct dentry *dir,
 static void nfs_idmap_unregister(struct nfs_client *clp,
 				      struct rpc_pipe *pipe)
 {
-	struct net *net = clp->net;
+	struct net *net = clp->cl_net;
 	struct super_block *pipefs_sb;
 
 	pipefs_sb = rpc_get_sb_net(net);
@@ -429,7 +429,7 @@ static int nfs_idmap_register(struct nfs_client *clp,
 				   struct idmap *idmap,
 				   struct rpc_pipe *pipe)
 {
-	struct net *net = clp->net;
+	struct net *net = clp->cl_net;
 	struct super_block *pipefs_sb;
 	int err = 0;
 
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index 9b7696b..9f7c43a 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -602,7 +602,7 @@ decode_device(struct inode *ino, struct pnfs_device *pdev, gfp_t gfp_flags)
 
 		mp_count = be32_to_cpup(p); /* multipath count */
 		for (j = 0; j < mp_count; j++) {
-			da = decode_ds_addr(NFS_SERVER(ino)->nfs_client->net,
+			da = decode_ds_addr(NFS_SERVER(ino)->nfs_client->cl_net,
 					    &stream, gfp_flags);
 			if (da)
 				list_add_tail(&da->da_node, &dsaddrs);
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 773e021..59410b3 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -88,7 +88,7 @@ struct nfs_client {
 	struct fscache_cookie	*fscache;	/* client index cache cookie */
 #endif
 
-	struct net		*net;
+	struct net		*cl_net;
 };
 
 /*


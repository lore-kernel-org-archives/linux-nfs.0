Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:59542 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751723Ab3LANUV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 1 Dec 2013 08:20:21 -0500
Message-Id: <20131201132010.351939817@bombadil.infradead.org>
Date: Sun, 01 Dec 2013 05:14:45 -0800
From: Christoph Hellwig <hch@infradead.org>
To: linux-nfs@vger.kernel.org, viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org
Subject: [PATCH 04/11] sunrpc: no need to have a lock or superblock for rpc_unlink
References: <20131201131441.790963326@bombadil.infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It translates to simple dcache operations that have their own
synchronization.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/blocklayout/blocklayout.c |   22 ++--------------------
 fs/nfsd/nfs4recover.c            |   22 ++--------------------
 2 files changed, 4 insertions(+), 40 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 17088b9..d5950aa 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -1308,13 +1308,6 @@ static struct dentry *nfs4blocklayout_register_sb(struct super_block *sb,
 	return dentry;
 }
 
-static void nfs4blocklayout_unregister_sb(struct super_block *sb,
-					  struct rpc_pipe *pipe)
-{
-	if (pipe->dentry)
-		rpc_unlink(pipe->dentry);
-}
-
 static struct dentry *nfs4blocklayout_register_net(struct net *net,
 						   struct rpc_pipe *pipe)
 {
@@ -1329,18 +1322,6 @@ static struct dentry *nfs4blocklayout_register_net(struct net *net,
 	return dentry;
 }
 
-static void nfs4blocklayout_unregister_net(struct net *net,
-					   struct rpc_pipe *pipe)
-{
-	struct super_block *pipefs_sb;
-
-	pipefs_sb = rpc_get_sb_net(net);
-	if (pipefs_sb) {
-		nfs4blocklayout_unregister_sb(pipefs_sb, pipe);
-		rpc_put_sb_net(net);
-	}
-}
-
 static int nfs4blocklayout_net_init(struct net *net)
 {
 	struct nfs_net *nn = net_generic(net, nfs_net_id);
@@ -1363,7 +1344,8 @@ static void nfs4blocklayout_net_exit(struct net *net)
 {
 	struct nfs_net *nn = net_generic(net, nfs_net_id);
 
-	nfs4blocklayout_unregister_net(net, nn->bl_device_pipe);
+	if (nn->bl_device_pipe->dentry)
+		rpc_unlink(nn->bl_device_pipe->dentry);
 	rpc_destroy_pipe_data(nn->bl_device_pipe);
 	nn->bl_device_pipe = NULL;
 }
diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index d9a03e4..f4fe7d6 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -774,13 +774,6 @@ nfsd4_cld_register_sb(struct super_block *sb, struct rpc_pipe *pipe)
 	return dentry;
 }
 
-static void
-nfsd4_cld_unregister_sb(struct rpc_pipe *pipe)
-{
-	if (pipe->dentry)
-		rpc_unlink(pipe->dentry);
-}
-
 static struct dentry *
 nfsd4_cld_register_net(struct net *net, struct rpc_pipe *pipe)
 {
@@ -795,18 +788,6 @@ nfsd4_cld_register_net(struct net *net, struct rpc_pipe *pipe)
 	return dentry;
 }
 
-static void
-nfsd4_cld_unregister_net(struct net *net, struct rpc_pipe *pipe)
-{
-	struct super_block *sb;
-
-	sb = rpc_get_sb_net(net);
-	if (sb) {
-		nfsd4_cld_unregister_sb(pipe);
-		rpc_put_sb_net(net);
-	}
-}
-
 /* Initialize rpc_pipefs pipe for communication with client tracking daemon */
 static int
 nfsd4_init_cld_pipe(struct net *net)
@@ -858,7 +839,8 @@ nfsd4_remove_cld_pipe(struct net *net)
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 	struct cld_net *cn = nn->cld_net;
 
-	nfsd4_cld_unregister_net(net, cn->cn_pipe);
+	if (cn->cn_pipe->dentry)
+		rpc_unlink(cn->cn_pipe->dentry);
 	rpc_destroy_pipe_data(cn->cn_pipe);
 	kfree(nn->cld_net);
 	nn->cld_net = NULL;
-- 
1.7.10.4



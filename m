Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:59553 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751827Ab3LANUV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 1 Dec 2013 08:20:21 -0500
Message-Id: <20131201132011.112942509@bombadil.infradead.org>
Date: Sun, 01 Dec 2013 05:14:49 -0800
From: Christoph Hellwig <hch@infradead.org>
To: linux-nfs@vger.kernel.org, viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org
Subject: [PATCH 08/11] sunrpc: rpc_get_sb_net, die, die, die
References: <20131201131441.790963326@bombadil.infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

rpc_get_sb_net can go away now that no caller is left.  Also
rpc_d_lookup_sb can be static inside rpc_pipe.c now.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/sunrpc/rpc_pipe_fs.h |    5 ----
 net/sunrpc/rpc_pipe.c              |   45 ++++++------------------------------
 2 files changed, 7 insertions(+), 43 deletions(-)

diff --git a/include/linux/sunrpc/rpc_pipe_fs.h b/include/linux/sunrpc/rpc_pipe_fs.h
index ae0a109..29c66f9 100644
--- a/include/linux/sunrpc/rpc_pipe_fs.h
+++ b/include/linux/sunrpc/rpc_pipe_fs.h
@@ -69,11 +69,6 @@ RPC_I(struct inode *inode)
 	return container_of(inode, struct rpc_inode, vfs_inode);
 }
 
-extern struct dentry *rpc_d_lookup_sb(const struct super_block *sb,
-				      const unsigned char *dir_name);
-extern struct super_block *rpc_get_sb_net(const struct net *net);
-extern void rpc_put_sb_net(const struct net *net);
-
 extern ssize_t rpc_pipe_generic_upcall(struct file *, struct rpc_pipe_msg *,
 				       char __user *, size_t);
 extern int rpc_queue_upcall(struct rpc_pipe *, struct rpc_pipe_msg *);
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 3f4905a..0485796 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -627,6 +627,13 @@ static int __rpc_rmpipe(struct inode *dir, struct dentry *dentry)
 	return __rpc_unlink(dir, dentry);
 }
 
+static struct dentry *rpc_d_lookup_sb(const struct super_block *sb,
+			       const unsigned char *dir_name)
+{
+	struct qstr dir = QSTR_INIT(dir_name, strlen(dir_name));
+	return d_hash_and_lookup(sb->s_root, &dir);
+}
+
 static struct dentry *__rpc_lookup_create_exclusive(struct dentry *parent,
 					  const char *name)
 {
@@ -1255,17 +1262,6 @@ static const struct rpc_filelist files[] = {
 	},
 };
 
-/*
- * This call can be used only in RPC pipefs mount notification hooks.
- */
-struct dentry *rpc_d_lookup_sb(const struct super_block *sb,
-			       const unsigned char *dir_name)
-{
-	struct qstr dir = QSTR_INIT(dir_name, strlen(dir_name));
-	return d_hash_and_lookup(sb->s_root, &dir);
-}
-EXPORT_SYMBOL_GPL(rpc_d_lookup_sb);
-
 int rpc_pipefs_init_net(struct net *net)
 {
 	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
@@ -1287,33 +1283,6 @@ void rpc_pipefs_exit_net(struct net *net)
 	kern_unmount(sn->pipefs_mnt);
 }
 
-/*
- * This call will be used for per network namespace operations calls.
- * Note: Function will be returned with pipefs_sb_lock taken if superblock was
- * found. This lock have to be released by rpc_put_sb_net() when all operations
- * will be completed.
- */
-struct super_block *rpc_get_sb_net(const struct net *net)
-{
-	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
-
-	mutex_lock(&sn->pipefs_sb_lock);
-	if (sn->pipefs_sb)
-		return sn->pipefs_sb;
-	mutex_unlock(&sn->pipefs_sb_lock);
-	return NULL;
-}
-EXPORT_SYMBOL_GPL(rpc_get_sb_net);
-
-void rpc_put_sb_net(const struct net *net)
-{
-	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
-
-	WARN_ON(sn->pipefs_sb == NULL);
-	mutex_unlock(&sn->pipefs_sb_lock);
-}
-EXPORT_SYMBOL_GPL(rpc_put_sb_net);
-
 static int
 rpc_fill_super(struct super_block *sb, void *data, int silent)
 {
-- 
1.7.10.4



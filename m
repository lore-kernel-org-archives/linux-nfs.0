Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:59545 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751815Ab3LANUV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 1 Dec 2013 08:20:21 -0500
Message-Id: <20131201132009.815675002@bombadil.infradead.org>
Date: Sun, 01 Dec 2013 05:14:42 -0800
From: Christoph Hellwig <hch@infradead.org>
To: linux-nfs@vger.kernel.org, viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org
Subject: [PATCH 01/11] sunrpc: allocate pipefs inodes using kmalloc
References: <20131201131441.790963326@bombadil.infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There's not a lot of them, and not needing our own slab makes
initialization ordering a whole lot simpler.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 net/sunrpc/rpc_pipe.c |   39 +++++++--------------------------------
 1 file changed, 7 insertions(+), 32 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index bf04b30..395eb5f 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -40,8 +40,6 @@
 static struct file_system_type rpc_pipe_fs_type;
 
 
-static struct kmem_cache *rpc_inode_cachep __read_mostly;
-
 #define RPC_UPCALL_TIMEOUT (30*HZ)
 
 static BLOCKING_NOTIFIER_HEAD(rpc_pipefs_notifier_list);
@@ -193,24 +191,21 @@ rpc_close_pipes(struct inode *inode)
 static struct inode *
 rpc_alloc_inode(struct super_block *sb)
 {
-	struct rpc_inode *rpci;
-	rpci = (struct rpc_inode *)kmem_cache_alloc(rpc_inode_cachep, GFP_KERNEL);
+	struct rpc_inode *rpci = kmalloc(sizeof(struct rpc_inode), GFP_KERNEL);
 	if (!rpci)
 		return NULL;
-	return &rpci->vfs_inode;
-}
 
-static void
-rpc_i_callback(struct rcu_head *head)
-{
-	struct inode *inode = container_of(head, struct inode, i_rcu);
-	kmem_cache_free(rpc_inode_cachep, RPC_I(inode));
+	inode_init_once(&rpci->vfs_inode);
+	rpci->private = NULL;
+	rpci->pipe = NULL;
+	init_waitqueue_head(&rpci->waitq);
+	return &rpci->vfs_inode;
 }
 
 static void
 rpc_destroy_inode(struct inode *inode)
 {
-	call_rcu(&inode->i_rcu, rpc_i_callback);
+	kfree_rcu(inode, i_rcu);
 }
 
 static int
@@ -1327,28 +1322,10 @@ static struct file_system_type rpc_pipe_fs_type = {
 MODULE_ALIAS_FS("rpc_pipefs");
 MODULE_ALIAS("rpc_pipefs");
 
-static void
-init_once(void *foo)
-{
-	struct rpc_inode *rpci = (struct rpc_inode *) foo;
-
-	inode_init_once(&rpci->vfs_inode);
-	rpci->private = NULL;
-	rpci->pipe = NULL;
-	init_waitqueue_head(&rpci->waitq);
-}
-
 int register_rpc_pipefs(void)
 {
 	int err;
 
-	rpc_inode_cachep = kmem_cache_create("rpc_inode_cache",
-				sizeof(struct rpc_inode),
-				0, (SLAB_HWCACHE_ALIGN|SLAB_RECLAIM_ACCOUNT|
-						SLAB_MEM_SPREAD),
-				init_once);
-	if (!rpc_inode_cachep)
-		return -ENOMEM;
 	err = rpc_clients_notifier_register();
 	if (err)
 		goto err_notifier;
@@ -1360,13 +1337,11 @@ int register_rpc_pipefs(void)
 err_register:
 	rpc_clients_notifier_unregister();
 err_notifier:
-	kmem_cache_destroy(rpc_inode_cachep);
 	return err;
 }
 
 void unregister_rpc_pipefs(void)
 {
 	rpc_clients_notifier_unregister();
-	kmem_cache_destroy(rpc_inode_cachep);
 	unregister_filesystem(&rpc_pipe_fs_type);
 }
-- 
1.7.10.4



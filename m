Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:59538 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751744Ab3LANUV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 1 Dec 2013 08:20:21 -0500
Message-Id: <20131201132010.176180916@bombadil.infradead.org>
Date: Sun, 01 Dec 2013 05:14:44 -0800
From: Christoph Hellwig <hch@infradead.org>
To: linux-nfs@vger.kernel.org, viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org
Subject: [PATCH 03/11] sunrpc: remove the rpc_clients_block notifier
References: <20131201131441.790963326@bombadil.infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that a rpc_pipefs mount is always availble there is no need for it.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/blocklayout/blocklayout.c   |   56 ++-----------------
 fs/nfs/cache_lib.c                 |    6 ++-
 fs/nfs/cache_lib.h                 |    4 --
 fs/nfs/dns_resolve.c               |   49 +----------------
 fs/nfsd/nfs4recover.c              |   55 -------------------
 fs/nfsd/nfsctl.c                   |    9 +---
 fs/nfsd/nfsd.h                     |    6 ---
 include/linux/sunrpc/rpc_pipe_fs.h |   13 -----
 net/sunrpc/clnt.c                  |  104 ------------------------------------
 net/sunrpc/rpc_pipe.c              |   48 +----------------
 net/sunrpc/sunrpc.h                |    2 -
 11 files changed, 11 insertions(+), 341 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index e242bbf..17088b9 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -1315,48 +1315,6 @@ static void nfs4blocklayout_unregister_sb(struct super_block *sb,
 		rpc_unlink(pipe->dentry);
 }
 
-static int rpc_pipefs_event(struct notifier_block *nb, unsigned long event,
-			   void *ptr)
-{
-	struct super_block *sb = ptr;
-	struct net *net = sb->s_fs_info;
-	struct nfs_net *nn = net_generic(net, nfs_net_id);
-	struct dentry *dentry;
-	int ret = 0;
-
-	if (!try_module_get(THIS_MODULE))
-		return 0;
-
-	if (nn->bl_device_pipe == NULL) {
-		module_put(THIS_MODULE);
-		return 0;
-	}
-
-	switch (event) {
-	case RPC_PIPEFS_MOUNT:
-		dentry = nfs4blocklayout_register_sb(sb, nn->bl_device_pipe);
-		if (IS_ERR(dentry)) {
-			ret = PTR_ERR(dentry);
-			break;
-		}
-		nn->bl_device_pipe->dentry = dentry;
-		break;
-	case RPC_PIPEFS_UMOUNT:
-		if (nn->bl_device_pipe->dentry)
-			nfs4blocklayout_unregister_sb(sb, nn->bl_device_pipe);
-		break;
-	default:
-		ret = -ENOTSUPP;
-		break;
-	}
-	module_put(THIS_MODULE);
-	return ret;
-}
-
-static struct notifier_block nfs4blocklayout_block = {
-	.notifier_call = rpc_pipefs_event,
-};
-
 static struct dentry *nfs4blocklayout_register_net(struct net *net,
 						   struct rpc_pipe *pipe)
 {
@@ -1424,20 +1382,13 @@ static int __init nfs4blocklayout_init(void)
 	ret = pnfs_register_layoutdriver(&blocklayout_type);
 	if (ret)
 		goto out;
-
-	ret = rpc_pipefs_notifier_register(&nfs4blocklayout_block);
-	if (ret)
-		goto out_remove;
 	ret = register_pernet_subsys(&nfs4blocklayout_net_ops);
 	if (ret)
-		goto out_notifier;
-out:
-	return ret;
-
-out_notifier:
-	rpc_pipefs_notifier_unregister(&nfs4blocklayout_block);
+		goto out_remove;
+	return 0;
 out_remove:
 	pnfs_unregister_layoutdriver(&blocklayout_type);
+out:
 	return ret;
 }
 
@@ -1446,7 +1397,6 @@ static void __exit nfs4blocklayout_exit(void)
 	dprintk("%s: NFSv4 Block Layout Driver Unregistering...\n",
 	       __func__);
 
-	rpc_pipefs_notifier_unregister(&nfs4blocklayout_block);
 	unregister_pernet_subsys(&nfs4blocklayout_net_ops);
 	pnfs_unregister_layoutdriver(&blocklayout_type);
 }
diff --git a/fs/nfs/cache_lib.c b/fs/nfs/cache_lib.c
index 5f7b053..4e9226f 100644
--- a/fs/nfs/cache_lib.c
+++ b/fs/nfs/cache_lib.c
@@ -112,7 +112,8 @@ int nfs_cache_wait_for_upcall(struct nfs_cache_defer_req *dreq)
 	return 0;
 }
 
-int nfs_cache_register_sb(struct super_block *sb, struct cache_detail *cd)
+static int nfs_cache_register_sb(struct super_block *sb,
+		struct cache_detail *cd)
 {
 	int ret;
 	struct dentry *dir;
@@ -139,7 +140,8 @@ int nfs_cache_register_net(struct net *net, struct cache_detail *cd)
 	return ret;
 }
 
-void nfs_cache_unregister_sb(struct super_block *sb, struct cache_detail *cd)
+static void nfs_cache_unregister_sb(struct super_block *sb,
+		struct cache_detail *cd)
 {
 	if (cd->u.pipefs.dir)
 		sunrpc_cache_unregister_pipefs(cd);
diff --git a/fs/nfs/cache_lib.h b/fs/nfs/cache_lib.h
index 4116d2c..27280b8 100644
--- a/fs/nfs/cache_lib.h
+++ b/fs/nfs/cache_lib.h
@@ -25,7 +25,3 @@ extern int nfs_cache_wait_for_upcall(struct nfs_cache_defer_req *dreq);
 
 extern int nfs_cache_register_net(struct net *net, struct cache_detail *cd);
 extern void nfs_cache_unregister_net(struct net *net, struct cache_detail *cd);
-extern int nfs_cache_register_sb(struct super_block *sb,
-				 struct cache_detail *cd);
-extern void nfs_cache_unregister_sb(struct super_block *sb,
-				    struct cache_detail *cd);
diff --git a/fs/nfs/dns_resolve.c b/fs/nfs/dns_resolve.c
index fc0f95e..d9e641a 100644
--- a/fs/nfs/dns_resolve.c
+++ b/fs/nfs/dns_resolve.c
@@ -409,60 +409,13 @@ static struct pernet_operations nfs4_dns_resolver_ops = {
 	.exit = nfs4_dns_net_exit,
 };
 
-static int rpc_pipefs_event(struct notifier_block *nb, unsigned long event,
-			   void *ptr)
-{
-	struct super_block *sb = ptr;
-	struct net *net = sb->s_fs_info;
-	struct nfs_net *nn = net_generic(net, nfs_net_id);
-	struct cache_detail *cd = nn->nfs_dns_resolve;
-	int ret = 0;
-
-	if (cd == NULL)
-		return 0;
-
-	if (!try_module_get(THIS_MODULE))
-		return 0;
-
-	switch (event) {
-	case RPC_PIPEFS_MOUNT:
-		ret = nfs_cache_register_sb(sb, cd);
-		break;
-	case RPC_PIPEFS_UMOUNT:
-		nfs_cache_unregister_sb(sb, cd);
-		break;
-	default:
-		ret = -ENOTSUPP;
-		break;
-	}
-	module_put(THIS_MODULE);
-	return ret;
-}
-
-static struct notifier_block nfs_dns_resolver_block = {
-	.notifier_call	= rpc_pipefs_event,
-};
-
 int nfs_dns_resolver_init(void)
 {
-	int err;
-
-	err = register_pernet_subsys(&nfs4_dns_resolver_ops);
-	if (err < 0)
-		goto out;
-	err = rpc_pipefs_notifier_register(&nfs_dns_resolver_block);
-	if (err < 0)
-		goto out1;
-	return 0;
-out1:
-	unregister_pernet_subsys(&nfs4_dns_resolver_ops);
-out:
-	return err;
+	return register_pernet_subsys(&nfs4_dns_resolver_ops);
 }
 
 void nfs_dns_resolver_destroy(void)
 {
-	rpc_pipefs_notifier_unregister(&nfs_dns_resolver_block);
 	unregister_pernet_subsys(&nfs4_dns_resolver_ops);
 }
 #endif
diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 9c271f4..d9a03e4 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -1361,58 +1361,3 @@ nfsd4_record_grace_done(struct nfsd_net *nn, time_t boot_time)
 	if (nn->client_tracking_ops)
 		nn->client_tracking_ops->grace_done(nn, boot_time);
 }
-
-static int
-rpc_pipefs_event(struct notifier_block *nb, unsigned long event, void *ptr)
-{
-	struct super_block *sb = ptr;
-	struct net *net = sb->s_fs_info;
-	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
-	struct cld_net *cn = nn->cld_net;
-	struct dentry *dentry;
-	int ret = 0;
-
-	if (!try_module_get(THIS_MODULE))
-		return 0;
-
-	if (!cn) {
-		module_put(THIS_MODULE);
-		return 0;
-	}
-
-	switch (event) {
-	case RPC_PIPEFS_MOUNT:
-		dentry = nfsd4_cld_register_sb(sb, cn->cn_pipe);
-		if (IS_ERR(dentry)) {
-			ret = PTR_ERR(dentry);
-			break;
-		}
-		cn->cn_pipe->dentry = dentry;
-		break;
-	case RPC_PIPEFS_UMOUNT:
-		if (cn->cn_pipe->dentry)
-			nfsd4_cld_unregister_sb(cn->cn_pipe);
-		break;
-	default:
-		ret = -ENOTSUPP;
-		break;
-	}
-	module_put(THIS_MODULE);
-	return ret;
-}
-
-static struct notifier_block nfsd4_cld_block = {
-	.notifier_call = rpc_pipefs_event,
-};
-
-int
-register_cld_notifier(void)
-{
-	return rpc_pipefs_notifier_register(&nfsd4_cld_block);
-}
-
-void
-unregister_cld_notifier(void)
-{
-	rpc_pipefs_notifier_unregister(&nfsd4_cld_block);
-}
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 7f55517..14da88f 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1165,12 +1165,9 @@ static int __init init_nfsd(void)
 	int retval;
 	printk(KERN_INFO "Installing knfsd (copyright (C) 1996 okir@monad.swb.de).\n");
 
-	retval = register_cld_notifier();
-	if (retval)
-		return retval;
 	retval = register_pernet_subsys(&nfsd_net_ops);
 	if (retval < 0)
-		goto out_unregister_notifier;
+		goto out;
 	retval = nfsd4_init_slabs();
 	if (retval)
 		goto out_unregister_pernet;
@@ -1203,8 +1200,7 @@ out_free_slabs:
 	nfsd4_free_slabs();
 out_unregister_pernet:
 	unregister_pernet_subsys(&nfsd_net_ops);
-out_unregister_notifier:
-	unregister_cld_notifier();
+out:
 	return retval;
 }
 
@@ -1219,7 +1215,6 @@ static void __exit exit_nfsd(void)
 	nfsd_fault_inject_cleanup();
 	unregister_filesystem(&nfsd_fs_type);
 	unregister_pernet_subsys(&nfsd_net_ops);
-	unregister_cld_notifier();
 }
 
 MODULE_AUTHOR("Olaf Kirch <okir@monad.swb.de>");
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 30f34ab..10d35f1 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -384,17 +384,11 @@ static inline u32 nfsd_suppattrs2(u32 minorversion)
 	NFSD_WRITEABLE_ATTRS_WORD2
 
 extern int nfsd4_is_junction(struct dentry *dentry);
-extern int register_cld_notifier(void);
-extern void unregister_cld_notifier(void);
 #else /* CONFIG_NFSD_V4 */
 static inline int nfsd4_is_junction(struct dentry *dentry)
 {
 	return 0;
 }
-
-#define register_cld_notifier() 0
-#define unregister_cld_notifier() do { } while(0)
-
 #endif /* CONFIG_NFSD_V4 */
 
 #endif /* LINUX_NFSD_NFSD_H */
diff --git a/include/linux/sunrpc/rpc_pipe_fs.h b/include/linux/sunrpc/rpc_pipe_fs.h
index d5807e7..b9f3805 100644
--- a/include/linux/sunrpc/rpc_pipe_fs.h
+++ b/include/linux/sunrpc/rpc_pipe_fs.h
@@ -69,19 +69,6 @@ RPC_I(struct inode *inode)
 	return container_of(inode, struct rpc_inode, vfs_inode);
 }
 
-enum {
-	SUNRPC_PIPEFS_NFS_PRIO,
-	SUNRPC_PIPEFS_RPC_PRIO,
-};
-
-extern int rpc_pipefs_notifier_register(struct notifier_block *);
-extern void rpc_pipefs_notifier_unregister(struct notifier_block *);
-
-enum {
-	RPC_PIPEFS_MOUNT,
-	RPC_PIPEFS_UMOUNT,
-};
-
 extern struct dentry *rpc_d_lookup_sb(const struct super_block *sb,
 				      const unsigned char *dir_name);
 extern struct super_block *rpc_get_sb_net(const struct net *net);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index f09b7db..ec059c2 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -160,110 +160,6 @@ rpc_setup_pipedir(struct super_block *pipefs_sb, struct rpc_clnt *clnt)
 	return 0;
 }
 
-static int rpc_clnt_skip_event(struct rpc_clnt *clnt, unsigned long event)
-{
-	if (clnt->cl_program->pipe_dir_name == NULL)
-		return 1;
-
-	switch (event) {
-	case RPC_PIPEFS_MOUNT:
-		if (clnt->cl_pipedir_objects.pdh_dentry != NULL)
-			return 1;
-		if (atomic_read(&clnt->cl_count) == 0)
-			return 1;
-		break;
-	case RPC_PIPEFS_UMOUNT:
-		if (clnt->cl_pipedir_objects.pdh_dentry == NULL)
-			return 1;
-		break;
-	}
-	return 0;
-}
-
-static int __rpc_clnt_handle_event(struct rpc_clnt *clnt, unsigned long event,
-				   struct super_block *sb)
-{
-	struct dentry *dentry;
-	int err = 0;
-
-	switch (event) {
-	case RPC_PIPEFS_MOUNT:
-		dentry = rpc_setup_pipedir_sb(sb, clnt);
-		if (!dentry)
-			return -ENOENT;
-		if (IS_ERR(dentry))
-			return PTR_ERR(dentry);
-		break;
-	case RPC_PIPEFS_UMOUNT:
-		__rpc_clnt_remove_pipedir(clnt);
-		break;
-	default:
-		printk(KERN_ERR "%s: unknown event: %ld\n", __func__, event);
-		return -ENOTSUPP;
-	}
-	return err;
-}
-
-static int __rpc_pipefs_event(struct rpc_clnt *clnt, unsigned long event,
-				struct super_block *sb)
-{
-	int error = 0;
-
-	for (;; clnt = clnt->cl_parent) {
-		if (!rpc_clnt_skip_event(clnt, event))
-			error = __rpc_clnt_handle_event(clnt, event, sb);
-		if (error || clnt == clnt->cl_parent)
-			break;
-	}
-	return error;
-}
-
-static struct rpc_clnt *rpc_get_client_for_event(struct net *net, int event)
-{
-	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
-	struct rpc_clnt *clnt;
-
-	spin_lock(&sn->rpc_client_lock);
-	list_for_each_entry(clnt, &sn->all_clients, cl_clients) {
-		if (rpc_clnt_skip_event(clnt, event))
-			continue;
-		spin_unlock(&sn->rpc_client_lock);
-		return clnt;
-	}
-	spin_unlock(&sn->rpc_client_lock);
-	return NULL;
-}
-
-static int rpc_pipefs_event(struct notifier_block *nb, unsigned long event,
-			    void *ptr)
-{
-	struct super_block *sb = ptr;
-	struct rpc_clnt *clnt;
-	int error = 0;
-
-	while ((clnt = rpc_get_client_for_event(sb->s_fs_info, event))) {
-		error = __rpc_pipefs_event(clnt, event, sb);
-		if (error)
-			break;
-	}
-	return error;
-}
-
-static struct notifier_block rpc_clients_block = {
-	.notifier_call	= rpc_pipefs_event,
-	.priority	= SUNRPC_PIPEFS_RPC_PRIO,
-};
-
-int rpc_clients_notifier_register(void)
-{
-	return rpc_pipefs_notifier_register(&rpc_clients_block);
-}
-
-void rpc_clients_notifier_unregister(void)
-{
-	return rpc_pipefs_notifier_unregister(&rpc_clients_block);
-}
-
 static struct rpc_xprt *rpc_clnt_set_transport(struct rpc_clnt *clnt,
 		struct rpc_xprt *xprt,
 		const struct rpc_timeout *timeout)
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index e654b65..73e7963 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -42,20 +42,6 @@ static struct file_system_type rpc_pipe_fs_type;
 
 #define RPC_UPCALL_TIMEOUT (30*HZ)
 
-static BLOCKING_NOTIFIER_HEAD(rpc_pipefs_notifier_list);
-
-int rpc_pipefs_notifier_register(struct notifier_block *nb)
-{
-	return blocking_notifier_chain_cond_register(&rpc_pipefs_notifier_list, nb);
-}
-EXPORT_SYMBOL_GPL(rpc_pipefs_notifier_register);
-
-void rpc_pipefs_notifier_unregister(struct notifier_block *nb)
-{
-	blocking_notifier_chain_unregister(&rpc_pipefs_notifier_list, nb);
-}
-EXPORT_SYMBOL_GPL(rpc_pipefs_notifier_unregister);
-
 static void rpc_purge_list(wait_queue_head_t *waitq, struct list_head *head,
 		void (*destroy_msg)(struct rpc_pipe_msg *), int err)
 {
@@ -1258,7 +1244,6 @@ rpc_fill_super(struct super_block *sb, void *data, int silent)
 	struct dentry *root;
 	struct net *net = data;
 	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
-	int err;
 
 	sb->s_blocksize = PAGE_CACHE_SIZE;
 	sb->s_blocksize_bits = PAGE_CACHE_SHIFT;
@@ -1277,23 +1262,9 @@ rpc_fill_super(struct super_block *sb, void *data, int silent)
 		net, NET_NAME(net));
 	mutex_lock(&sn->pipefs_sb_lock);
 	sn->pipefs_sb = sb;
-	err = blocking_notifier_call_chain(&rpc_pipefs_notifier_list,
-					   RPC_PIPEFS_MOUNT,
-					   sb);
-	if (err)
-		goto err_depopulate;
 	sb->s_fs_info = get_net(net);
 	mutex_unlock(&sn->pipefs_sb_lock);
 	return 0;
-
-err_depopulate:
-	blocking_notifier_call_chain(&rpc_pipefs_notifier_list,
-					   RPC_PIPEFS_UMOUNT,
-					   sb);
-	sn->pipefs_sb = NULL;
-	__rpc_depopulate(root, files, RPCAUTH_lockd, RPCAUTH_RootEOF);
-	mutex_unlock(&sn->pipefs_sb_lock);
-	return err;
 }
 
 static struct dentry *
@@ -1316,9 +1287,6 @@ static void rpc_kill_sb(struct super_block *sb)
 	sn->pipefs_sb = NULL;
 	dprintk("RPC:       sending pipefs UMOUNT notification for net %p%s\n",
 		net, NET_NAME(net));
-	blocking_notifier_call_chain(&rpc_pipefs_notifier_list,
-					   RPC_PIPEFS_UMOUNT,
-					   sb);
 	mutex_unlock(&sn->pipefs_sb_lock);
 	put_net(net);
 out:
@@ -1336,24 +1304,10 @@ MODULE_ALIAS("rpc_pipefs");
 
 int register_rpc_pipefs(void)
 {
-	int err;
-
-	err = rpc_clients_notifier_register();
-	if (err)
-		goto err_notifier;
-	err = register_filesystem(&rpc_pipe_fs_type);
-	if (err)
-		goto err_register;
-	return 0;
-
-err_register:
-	rpc_clients_notifier_unregister();
-err_notifier:
-	return err;
+	return register_filesystem(&rpc_pipe_fs_type);
 }
 
 void unregister_rpc_pipefs(void)
 {
-	rpc_clients_notifier_unregister();
 	unregister_filesystem(&rpc_pipe_fs_type);
 }
diff --git a/net/sunrpc/sunrpc.h b/net/sunrpc/sunrpc.h
index 14c9f6d..90c292e 100644
--- a/net/sunrpc/sunrpc.h
+++ b/net/sunrpc/sunrpc.h
@@ -47,7 +47,5 @@ int svc_send_common(struct socket *sock, struct xdr_buf *xdr,
 		    struct page *headpage, unsigned long headoffset,
 		    struct page *tailpage, unsigned long tailoffset);
 
-int rpc_clients_notifier_register(void);
-void rpc_clients_notifier_unregister(void);
 #endif /* _NET_SUNRPC_SUNRPC_H */
 
-- 
1.7.10.4



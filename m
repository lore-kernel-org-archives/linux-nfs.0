Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:59537 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751531Ab3LANUV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 1 Dec 2013 08:20:21 -0500
Message-Id: <20131201132009.999380353@bombadil.infradead.org>
Date: Sun, 01 Dec 2013 05:14:43 -0800
From: Christoph Hellwig <hch@infradead.org>
To: linux-nfs@vger.kernel.org, viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org
Subject: [PATCH 02/11] rpc_pipefs: always mount on net namespace initialization
References: <20131201131441.790963326@bombadil.infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make sure every network namespace has an rpc_pipefs mount available.
This makes creating a pipes a heck lot easier.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/sunrpc/rpc_pipe_fs.h |    1 -
 net/sunrpc/netns.h                 |    4 ++++
 net/sunrpc/rpc_pipe.c              |   14 +++++++++++++-
 net/sunrpc/sunrpc_syms.c           |    8 +++++++-
 4 files changed, 24 insertions(+), 3 deletions(-)

diff --git a/include/linux/sunrpc/rpc_pipe_fs.h b/include/linux/sunrpc/rpc_pipe_fs.h
index a353e03..d5807e7 100644
--- a/include/linux/sunrpc/rpc_pipe_fs.h
+++ b/include/linux/sunrpc/rpc_pipe_fs.h
@@ -84,7 +84,6 @@ enum {
 
 extern struct dentry *rpc_d_lookup_sb(const struct super_block *sb,
 				      const unsigned char *dir_name);
-extern void rpc_pipefs_init_net(struct net *net);
 extern struct super_block *rpc_get_sb_net(const struct net *net);
 extern void rpc_put_sb_net(const struct net *net);
 
diff --git a/net/sunrpc/netns.h b/net/sunrpc/netns.h
index 779742c..a80b069 100644
--- a/net/sunrpc/netns.h
+++ b/net/sunrpc/netns.h
@@ -13,6 +13,7 @@ struct sunrpc_net {
 	struct cache_detail *rsc_cache;
 	struct cache_detail *rsi_cache;
 
+	struct vfsmount *pipefs_mnt;
 	struct super_block *pipefs_sb;
 	struct mutex pipefs_sb_lock;
 
@@ -41,4 +42,7 @@ extern int sunrpc_net_id;
 int ip_map_cache_create(struct net *);
 void ip_map_cache_destroy(struct net *);
 
+extern int rpc_pipefs_init_net(struct net *net);
+extern void rpc_pipefs_exit_net(struct net *net);
+
 #endif
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 395eb5f..e654b65 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -1203,13 +1203,25 @@ struct dentry *rpc_d_lookup_sb(const struct super_block *sb,
 }
 EXPORT_SYMBOL_GPL(rpc_d_lookup_sb);
 
-void rpc_pipefs_init_net(struct net *net)
+int rpc_pipefs_init_net(struct net *net)
 {
 	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
 
 	mutex_init(&sn->pipefs_sb_lock);
 	sn->gssd_running = 1;
 	sn->pipe_version = -1;
+
+	sn->pipefs_mnt = kern_mount(&rpc_pipe_fs_type);
+	if (IS_ERR(sn->pipefs_mnt))
+		return PTR_ERR(sn->pipefs_mnt);
+	return 0;
+}
+
+void rpc_pipefs_exit_net(struct net *net)
+{
+	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
+
+	kern_unmount(sn->pipefs_mnt);
 }
 
 /*
diff --git a/net/sunrpc/sunrpc_syms.c b/net/sunrpc/sunrpc_syms.c
index 3d6498a..5d7e961 100644
--- a/net/sunrpc/sunrpc_syms.c
+++ b/net/sunrpc/sunrpc_syms.c
@@ -44,12 +44,17 @@ static __net_init int sunrpc_init_net(struct net *net)
 	if (err)
 		goto err_unixgid;
 
-	rpc_pipefs_init_net(net);
+	err = rpc_pipefs_init_net(net);
+	if (err)
+		goto err_gidcache;
+
 	INIT_LIST_HEAD(&sn->all_clients);
 	spin_lock_init(&sn->rpc_client_lock);
 	spin_lock_init(&sn->rpcb_clnt_lock);
 	return 0;
 
+err_gidcache:
+	unix_gid_cache_destroy(net);
 err_unixgid:
 	ip_map_cache_destroy(net);
 err_ipmap:
@@ -60,6 +65,7 @@ err_proc:
 
 static __net_exit void sunrpc_exit_net(struct net *net)
 {
+	rpc_pipefs_exit_net(net);
 	unix_gid_cache_destroy(net);
 	ip_map_cache_destroy(net);
 	rpc_proc_exit(net);
-- 
1.7.10.4



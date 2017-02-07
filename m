Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:36193 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753825AbdBGNrX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Feb 2017 08:47:23 -0500
Received: by mail-io0-f196.google.com with SMTP id q20so12821199ioi.3
        for <linux-nfs@vger.kernel.org>; Tue, 07 Feb 2017 05:47:23 -0800 (PST)
Subject: [PATCH 2/7] sunrpc/nfs: cleanup procfs/pipefs entry in cache_detail
To: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
References: <59432847-8e45-4423-c441-0c67ee645f38@gmail.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <262ccbdc-889e-3528-2c93-c42b5846efed@gmail.com>
Date: Tue, 7 Feb 2017 21:47:16 +0800
MIME-Version: 1.0
In-Reply-To: <59432847-8e45-4423-c441-0c67ee645f38@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Record flush/channel/content entries is useless, remove them.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/cache_lib.c           |  3 +--
 include/linux/sunrpc/cache.h | 15 +++-----------
 net/sunrpc/cache.c           | 49 +++++++++++++++-----------------------------
 3 files changed, 21 insertions(+), 46 deletions(-)

diff --git a/fs/nfs/cache_lib.c b/fs/nfs/cache_lib.c
index 6de1570..2ae676f 100644
--- a/fs/nfs/cache_lib.c
+++ b/fs/nfs/cache_lib.c
@@ -141,8 +141,7 @@ int nfs_cache_register_net(struct net *net, struct cache_detail *cd)
 
 void nfs_cache_unregister_sb(struct super_block *sb, struct cache_detail *cd)
 {
-	if (cd->u.pipefs.dir)
-		sunrpc_cache_unregister_pipefs(cd);
+	sunrpc_cache_unregister_pipefs(cd);
 }
 
 void nfs_cache_unregister_net(struct net *net, struct cache_detail *cd)
diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index 62a60ee..bb5c9c8 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -63,15 +63,6 @@ struct cache_head {
 
 #define	CACHE_NEW_EXPIRY 120	/* keep new things pending confirmation for 120 seconds */
 
-struct cache_detail_procfs {
-	struct proc_dir_entry	*proc_ent;
-	struct proc_dir_entry   *flush_ent, *channel_ent, *content_ent;
-};
-
-struct cache_detail_pipefs {
-	struct dentry *dir;
-};
-
 struct cache_detail {
 	struct module *		owner;
 	int			hash_size;
@@ -123,9 +114,9 @@ struct cache_detail {
 	time_t			last_warn;		/* when we last warned about no readers */
 
 	union {
-		struct cache_detail_procfs procfs;
-		struct cache_detail_pipefs pipefs;
-	} u;
+		struct proc_dir_entry	*procfs;
+		struct dentry		*pipefs;
+	};
 	struct net		*net;
 };
 
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 8147e8d..688ef8c 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -1600,21 +1600,12 @@ static const struct file_operations cache_flush_operations_procfs = {
 	.llseek		= no_llseek,
 };
 
-static void remove_cache_proc_entries(struct cache_detail *cd, struct net *net)
+static void remove_cache_proc_entries(struct cache_detail *cd)
 {
-	struct sunrpc_net *sn;
-
-	if (cd->u.procfs.proc_ent == NULL)
-		return;
-	if (cd->u.procfs.flush_ent)
-		remove_proc_entry("flush", cd->u.procfs.proc_ent);
-	if (cd->u.procfs.channel_ent)
-		remove_proc_entry("channel", cd->u.procfs.proc_ent);
-	if (cd->u.procfs.content_ent)
-		remove_proc_entry("content", cd->u.procfs.proc_ent);
-	cd->u.procfs.proc_ent = NULL;
-	sn = net_generic(net, sunrpc_net_id);
-	remove_proc_entry(cd->name, sn->proc_net_rpc);
+	if (cd->procfs) {
+		proc_remove(cd->procfs);
+		cd->procfs = NULL;
+	}
 }
 
 #ifdef CONFIG_PROC_FS
@@ -1624,38 +1615,30 @@ static int create_cache_proc_entries(struct cache_detail *cd, struct net *net)
 	struct sunrpc_net *sn;
 
 	sn = net_generic(net, sunrpc_net_id);
-	cd->u.procfs.proc_ent = proc_mkdir(cd->name, sn->proc_net_rpc);
-	if (cd->u.procfs.proc_ent == NULL)
+	cd->procfs = proc_mkdir(cd->name, sn->proc_net_rpc);
+	if (cd->procfs == NULL)
 		goto out_nomem;
-	cd->u.procfs.channel_ent = NULL;
-	cd->u.procfs.content_ent = NULL;
 
 	p = proc_create_data("flush", S_IFREG|S_IRUSR|S_IWUSR,
-			     cd->u.procfs.proc_ent,
-			     &cache_flush_operations_procfs, cd);
-	cd->u.procfs.flush_ent = p;
+			     cd->procfs, &cache_flush_operations_procfs, cd);
 	if (p == NULL)
 		goto out_nomem;
 
 	if (cd->cache_request || cd->cache_parse) {
 		p = proc_create_data("channel", S_IFREG|S_IRUSR|S_IWUSR,
-				     cd->u.procfs.proc_ent,
-				     &cache_file_operations_procfs, cd);
-		cd->u.procfs.channel_ent = p;
+				cd->procfs, &cache_file_operations_procfs, cd);
 		if (p == NULL)
 			goto out_nomem;
 	}
 	if (cd->cache_show) {
 		p = proc_create_data("content", S_IFREG|S_IRUSR,
-				cd->u.procfs.proc_ent,
-				&content_file_operations_procfs, cd);
-		cd->u.procfs.content_ent = p;
+				cd->procfs, &content_file_operations_procfs, cd);
 		if (p == NULL)
 			goto out_nomem;
 	}
 	return 0;
 out_nomem:
-	remove_cache_proc_entries(cd, net);
+	remove_cache_proc_entries(cd);
 	return -ENOMEM;
 }
 #else /* CONFIG_PROC_FS */
@@ -1684,7 +1667,7 @@ EXPORT_SYMBOL_GPL(cache_register_net);
 
 void cache_unregister_net(struct cache_detail *cd, struct net *net)
 {
-	remove_cache_proc_entries(cd, net);
+	remove_cache_proc_entries(cd);
 	sunrpc_destroy_cache_detail(cd);
 }
 EXPORT_SYMBOL_GPL(cache_unregister_net);
@@ -1843,15 +1826,17 @@ int sunrpc_cache_register_pipefs(struct dentry *parent,
 	struct dentry *dir = rpc_create_cache_dir(parent, name, umode, cd);
 	if (IS_ERR(dir))
 		return PTR_ERR(dir);
-	cd->u.pipefs.dir = dir;
+	cd->pipefs = dir;
 	return 0;
 }
 EXPORT_SYMBOL_GPL(sunrpc_cache_register_pipefs);
 
 void sunrpc_cache_unregister_pipefs(struct cache_detail *cd)
 {
-	rpc_remove_cache_dir(cd->u.pipefs.dir);
-	cd->u.pipefs.dir = NULL;
+	if (cd->pipefs) {
+		rpc_remove_cache_dir(cd->pipefs);
+		cd->pipefs = NULL;
+	}
 }
 EXPORT_SYMBOL_GPL(sunrpc_cache_unregister_pipefs);
 
-- 
2.9.3


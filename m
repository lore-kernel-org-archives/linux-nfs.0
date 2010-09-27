Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:12346 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932633Ab0I0KA1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Sep 2010 06:00:27 -0400
Message-ID: <4CA06B2F.2010104@parallels.com>
Date: Mon, 27 Sep 2010 14:00:15 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH 5/9] sunrpc: Add routines that allow registering per-net caches
References: <4CA06A63.6090507@parallels.com>
In-Reply-To: <4CA06A63.6090507@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Existing calls do the same, but for the init_net.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 include/linux/sunrpc/cache.h |    2 ++
 net/sunrpc/cache.c           |   27 +++++++++++++++++++--------
 2 files changed, 21 insertions(+), 8 deletions(-)

diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index 0349635..6950c98 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -197,7 +197,9 @@ extern void cache_purge(struct cache_detail *detail);
 #define NEVER (0x7FFFFFFF)
 extern void __init cache_initialize(void);
 extern int cache_register(struct cache_detail *cd);
+extern int cache_register_net(struct cache_detail *cd, struct net *net);
 extern void cache_unregister(struct cache_detail *cd);
+extern void cache_unregister_net(struct cache_detail *cd, struct net *net);
 
 extern int sunrpc_cache_register_pipefs(struct dentry *parent, const char *,
 					mode_t, struct cache_detail *);
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index ff733df..e84e7dd 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -34,6 +34,7 @@
 #include <linux/sunrpc/cache.h>
 #include <linux/sunrpc/stats.h>
 #include <linux/sunrpc/rpc_pipe_fs.h>
+#include <net/net_namespace.h>
 
 #define	 RPCDBG_FACILITY RPCDBG_CACHE
 
@@ -1537,7 +1538,7 @@ static const struct file_operations cache_flush_operations_procfs = {
 	.release	= release_flush_procfs,
 };
 
-static void remove_cache_proc_entries(struct cache_detail *cd)
+static void remove_cache_proc_entries(struct cache_detail *cd, struct net *net)
 {
 	if (cd->u.procfs.proc_ent == NULL)
 		return;
@@ -1552,7 +1553,7 @@ static void remove_cache_proc_entries(struct cache_detail *cd)
 }
 
 #ifdef CONFIG_PROC_FS
-static int create_cache_proc_entries(struct cache_detail *cd)
+static int create_cache_proc_entries(struct cache_detail *cd, struct net *net)
 {
 	struct proc_dir_entry *p;
 
@@ -1587,11 +1588,11 @@ static int create_cache_proc_entries(struct cache_detail *cd)
 	}
 	return 0;
 out_nomem:
-	remove_cache_proc_entries(cd);
+	remove_cache_proc_entries(cd, net);
 	return -ENOMEM;
 }
 #else /* CONFIG_PROC_FS */
-static int create_cache_proc_entries(struct cache_detail *cd)
+static int create_cache_proc_entries(struct cache_detail *cd, struct net *net)
 {
 	return 0;
 }
@@ -1602,23 +1603,33 @@ void __init cache_initialize(void)
 	INIT_DELAYED_WORK_DEFERRABLE(&cache_cleaner, do_cache_clean);
 }
 
-int cache_register(struct cache_detail *cd)
+int cache_register_net(struct cache_detail *cd, struct net *net)
 {
 	int ret;
 
 	sunrpc_init_cache_detail(cd);
-	ret = create_cache_proc_entries(cd);
+	ret = create_cache_proc_entries(cd, net);
 	if (ret)
 		sunrpc_destroy_cache_detail(cd);
 	return ret;
 }
+
+int cache_register(struct cache_detail *cd)
+{
+	return cache_register_net(cd, &init_net);
+}
 EXPORT_SYMBOL_GPL(cache_register);
 
-void cache_unregister(struct cache_detail *cd)
+void cache_unregister_net(struct cache_detail *cd, struct net *net)
 {
-	remove_cache_proc_entries(cd);
+	remove_cache_proc_entries(cd, net);
 	sunrpc_destroy_cache_detail(cd);
 }
+
+void cache_unregister(struct cache_detail *cd)
+{
+	cache_unregister_net(cd, &init_net);
+}
 EXPORT_SYMBOL_GPL(cache_unregister);
 
 static ssize_t cache_read_pipefs(struct file *filp, char __user *buf,
-- 
1.5.5.6


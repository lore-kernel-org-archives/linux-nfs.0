Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:39791 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932942Ab0I0KCK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Sep 2010 06:02:10 -0400
Message-ID: <4CA06B96.2090707@parallels.com>
Date: Mon, 27 Sep 2010 14:01:58 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH 8/9] sunrpc: Make the /proc/net/rpc appear in net namespaces
References: <4CA06A63.6090507@parallels.com>
In-Reply-To: <4CA06A63.6090507@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 include/linux/sunrpc/stats.h |   23 ++++++++++++++-------
 net/sunrpc/cache.c           |   11 +++++++--
 net/sunrpc/netns.h           |    1 +
 net/sunrpc/stats.c           |   43 ++++++++++++++++++++++++-----------------
 net/sunrpc/sunrpc_syms.c     |   16 +++++++++-----
 5 files changed, 59 insertions(+), 35 deletions(-)

diff --git a/include/linux/sunrpc/stats.h b/include/linux/sunrpc/stats.h
index 5fa0f20..680471d 100644
--- a/include/linux/sunrpc/stats.h
+++ b/include/linux/sunrpc/stats.h
@@ -38,8 +38,21 @@ struct svc_stat {
 				rpcbadclnt;
 };
 
-void			rpc_proc_init(void);
-void			rpc_proc_exit(void);
+struct net;
+#ifdef CONFIG_PROC_FS
+int			rpc_proc_init(struct net *);
+void			rpc_proc_exit(struct net *);
+#else
+static inline int rpc_proc_init(struct net *net)
+{
+	return 0;
+}
+
+static inline void rpc_proc_exit(struct net *net)
+{
+}
+#endif
+
 #ifdef MODULE
 void			rpc_modcount(struct inode *, int);
 #endif
@@ -54,9 +67,6 @@ void			svc_proc_unregister(const char *);
 
 void			svc_seq_show(struct seq_file *,
 				     const struct svc_stat *);
-
-extern struct proc_dir_entry	*proc_net_rpc;
-
 #else
 
 static inline struct proc_dir_entry *rpc_proc_register(struct rpc_stat *s) { return NULL; }
@@ -69,9 +79,6 @@ static inline void svc_proc_unregister(const char *p) {}
 
 static inline void svc_seq_show(struct seq_file *seq,
 				const struct svc_stat *st) {}
-
-#define proc_net_rpc NULL
-
 #endif
 
 #endif /* _LINUX_SUNRPC_STATS_H */
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index e84e7dd..e20968a 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -34,7 +34,7 @@
 #include <linux/sunrpc/cache.h>
 #include <linux/sunrpc/stats.h>
 #include <linux/sunrpc/rpc_pipe_fs.h>
-#include <net/net_namespace.h>
+#include "netns.h"
 
 #define	 RPCDBG_FACILITY RPCDBG_CACHE
 
@@ -1540,6 +1540,8 @@ static const struct file_operations cache_flush_operations_procfs = {
 
 static void remove_cache_proc_entries(struct cache_detail *cd, struct net *net)
 {
+	struct sunrpc_net *sn;
+
 	if (cd->u.procfs.proc_ent == NULL)
 		return;
 	if (cd->u.procfs.flush_ent)
@@ -1549,15 +1551,18 @@ static void remove_cache_proc_entries(struct cache_detail *cd, struct net *net)
 	if (cd->u.procfs.content_ent)
 		remove_proc_entry("content", cd->u.procfs.proc_ent);
 	cd->u.procfs.proc_ent = NULL;
-	remove_proc_entry(cd->name, proc_net_rpc);
+	sn = net_generic(net, sunrpc_net_id);
+	remove_proc_entry(cd->name, sn->proc_net_rpc);
 }
 
 #ifdef CONFIG_PROC_FS
 static int create_cache_proc_entries(struct cache_detail *cd, struct net *net)
 {
 	struct proc_dir_entry *p;
+	struct sunrpc_net *sn;
 
-	cd->u.procfs.proc_ent = proc_mkdir(cd->name, proc_net_rpc);
+	sn = net_generic(net, sunrpc_net_id);
+	cd->u.procfs.proc_ent = proc_mkdir(cd->name, sn->proc_net_rpc);
 	if (cd->u.procfs.proc_ent == NULL)
 		goto out_nomem;
 	cd->u.procfs.channel_ent = NULL;
diff --git a/net/sunrpc/netns.h b/net/sunrpc/netns.h
index b2d18af..e52ce89 100644
--- a/net/sunrpc/netns.h
+++ b/net/sunrpc/netns.h
@@ -5,6 +5,7 @@
 #include <net/netns/generic.h>
 
 struct sunrpc_net {
+	struct proc_dir_entry *proc_net_rpc;
 };
 
 extern int sunrpc_net_id;
diff --git a/net/sunrpc/stats.c b/net/sunrpc/stats.c
index ea1046f..f71a731 100644
--- a/net/sunrpc/stats.c
+++ b/net/sunrpc/stats.c
@@ -22,11 +22,10 @@
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/svcsock.h>
 #include <linux/sunrpc/metrics.h>
-#include <net/net_namespace.h>
 
-#define RPCDBG_FACILITY	RPCDBG_MISC
+#include "netns.h"
 
-struct proc_dir_entry	*proc_net_rpc = NULL;
+#define RPCDBG_FACILITY	RPCDBG_MISC
 
 /*
  * Get RPC client stats
@@ -218,10 +217,11 @@ EXPORT_SYMBOL_GPL(rpc_print_iostats);
 static inline struct proc_dir_entry *
 do_register(const char *name, void *data, const struct file_operations *fops)
 {
-	rpc_proc_init();
-	dprintk("RPC:       registering /proc/net/rpc/%s\n", name);
+	struct sunrpc_net *sn;
 
-	return proc_create_data(name, 0, proc_net_rpc, fops, data);
+	dprintk("RPC:       registering /proc/net/rpc/%s\n", name);
+	sn = net_generic(&init_net, sunrpc_net_id);
+	return proc_create_data(name, 0, sn->proc_net_rpc, fops, data);
 }
 
 struct proc_dir_entry *
@@ -234,7 +234,10 @@ EXPORT_SYMBOL_GPL(rpc_proc_register);
 void
 rpc_proc_unregister(const char *name)
 {
-	remove_proc_entry(name, proc_net_rpc);
+	struct sunrpc_net *sn;
+
+	sn = net_generic(&init_net, sunrpc_net_id);
+	remove_proc_entry(name, sn->proc_net_rpc);
 }
 EXPORT_SYMBOL_GPL(rpc_proc_unregister);
 
@@ -248,25 +251,29 @@ EXPORT_SYMBOL_GPL(svc_proc_register);
 void
 svc_proc_unregister(const char *name)
 {
-	remove_proc_entry(name, proc_net_rpc);
+	struct sunrpc_net *sn;
+
+	sn = net_generic(&init_net, sunrpc_net_id);
+	remove_proc_entry(name, sn->proc_net_rpc);
 }
 EXPORT_SYMBOL_GPL(svc_proc_unregister);
 
-void
-rpc_proc_init(void)
+int rpc_proc_init(struct net *net)
 {
+	struct sunrpc_net *sn;
+
 	dprintk("RPC:       registering /proc/net/rpc\n");
-	if (!proc_net_rpc)
-		proc_net_rpc = proc_mkdir("rpc", init_net.proc_net);
+	sn = net_generic(net, sunrpc_net_id);
+	sn->proc_net_rpc = proc_mkdir("rpc", net->proc_net);
+	if (sn->proc_net_rpc == NULL)
+		return -ENOMEM;
+
+	return 0;
 }
 
-void
-rpc_proc_exit(void)
+void rpc_proc_exit(struct net *net)
 {
 	dprintk("RPC:       unregistering /proc/net/rpc\n");
-	if (proc_net_rpc) {
-		proc_net_rpc = NULL;
-		remove_proc_entry("rpc", init_net.proc_net);
-	}
+	remove_proc_entry("rpc", net->proc_net);
 }
 
diff --git a/net/sunrpc/sunrpc_syms.c b/net/sunrpc/sunrpc_syms.c
index faa2322..c076af8 100644
--- a/net/sunrpc/sunrpc_syms.c
+++ b/net/sunrpc/sunrpc_syms.c
@@ -28,11 +28,21 @@ int sunrpc_net_id;
 
 static __net_init int sunrpc_init_net(struct net *net)
 {
+	int err;
+
+	err = rpc_proc_init(net);
+	if (err)
+		goto err_proc;
+
 	return 0;
+
+err_proc:
+	return err;
 }
 
 static __net_exit void sunrpc_exit_net(struct net *net)
 {
+	rpc_proc_exit(net);
 }
 
 static struct pernet_operations sunrpc_net_ops = {
@@ -67,9 +77,6 @@ init_sunrpc(void)
 #ifdef RPC_DEBUG
 	rpc_register_sysctl();
 #endif
-#ifdef CONFIG_PROC_FS
-	rpc_proc_init();
-#endif
 	cache_register(&ip_map_cache);
 	cache_register(&unix_gid_cache);
 	svc_init_xprt_sock();	/* svc sock transport */
@@ -101,9 +108,6 @@ cleanup_sunrpc(void)
 #ifdef RPC_DEBUG
 	rpc_unregister_sysctl();
 #endif
-#ifdef CONFIG_PROC_FS
-	rpc_proc_exit();
-#endif
 	rcu_barrier(); /* Wait for completion of call_rcu()'s */
 }
 MODULE_LICENSE("GPL");
-- 
1.5.5.6


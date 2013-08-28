Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:65371 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754332Ab3H1Tkh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Aug 2013 15:40:37 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
CC: <andros@netapp.com>
Subject: [PATCH v2 09/16] SUNRPC: Add a framework to clean up management of rpc_pipefs directories
Date: Wed, 28 Aug 2013 15:40:14 -0400
Message-ID: <1377718821-28159-9-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1377718821-28159-8-git-send-email-Trond.Myklebust@netapp.com>
References: <1377718821-28159-1-git-send-email-Trond.Myklebust@netapp.com>
 <1377718821-28159-2-git-send-email-Trond.Myklebust@netapp.com>
 <1377718821-28159-3-git-send-email-Trond.Myklebust@netapp.com>
 <1377718821-28159-4-git-send-email-Trond.Myklebust@netapp.com>
 <1377718821-28159-5-git-send-email-Trond.Myklebust@netapp.com>
 <1377718821-28159-6-git-send-email-Trond.Myklebust@netapp.com>
 <1377718821-28159-7-git-send-email-Trond.Myklebust@netapp.com>
 <1377718821-28159-8-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The current system requires everyone to set up notifiers, manage directory
locking, etc.
What we really want to do is have the rpc_client create its directory,
and then create all the entries.

This patch will allow the RPCSEC_GSS and NFS code to register all the
objects that they want to have appear in the directory, and then have
the sunrpc code call them back to actually create/destroy their pipefs
dentries when the rpc_client creates/destroys the parent.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 include/linux/sunrpc/clnt.h        |   2 +
 include/linux/sunrpc/rpc_pipe_fs.h |  33 ++++++++-
 net/sunrpc/clnt.c                  |   3 +-
 net/sunrpc/rpc_pipe.c              | 134 ++++++++++++++++++++++++++++++++++++-
 4 files changed, 168 insertions(+), 4 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index b93b4aa..0dccd01 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -21,6 +21,7 @@
 #include <linux/sunrpc/stats.h>
 #include <linux/sunrpc/xdr.h>
 #include <linux/sunrpc/timer.h>
+#include <linux/sunrpc/rpc_pipe_fs.h>
 #include <asm/signal.h>
 #include <linux/path.h>
 #include <net/ipv6.h>
@@ -55,6 +56,7 @@ struct rpc_clnt {
 
 	int			cl_nodelen;	/* nodename length */
 	char 			cl_nodename[UNX_MAXNODENAME];
+	struct rpc_pipe_dir_head cl_pipedir_objects;
 	struct dentry *		cl_dentry;
 	struct rpc_clnt *	cl_parent;	/* Points to parent of clones */
 	struct rpc_rtt		cl_rtt_default;
diff --git a/include/linux/sunrpc/rpc_pipe_fs.h b/include/linux/sunrpc/rpc_pipe_fs.h
index aa5b582..188e7fc 100644
--- a/include/linux/sunrpc/rpc_pipe_fs.h
+++ b/include/linux/sunrpc/rpc_pipe_fs.h
@@ -5,6 +5,26 @@
 
 #include <linux/workqueue.h>
 
+struct rpc_pipe_dir_head {
+	struct list_head pdh_entries;
+	struct dentry *pdh_dentry;
+};
+
+struct rpc_pipe_dir_object_ops;
+struct rpc_pipe_dir_object {
+	struct list_head pdo_head;
+	const struct rpc_pipe_dir_object_ops *pdo_ops;
+
+	void *pdo_data;
+};
+
+struct rpc_pipe_dir_object_ops {
+	int (*create)(struct dentry *dir,
+			struct rpc_pipe_dir_object *pdo);
+	void (*destroy)(struct dentry *dir,
+			struct rpc_pipe_dir_object *pdo);
+};
+
 struct rpc_pipe_msg {
 	struct list_head list;
 	void *data;
@@ -74,7 +94,18 @@ extern int rpc_queue_upcall(struct rpc_pipe *, struct rpc_pipe_msg *);
 
 struct rpc_clnt;
 extern struct dentry *rpc_create_client_dir(struct dentry *, const char *, struct rpc_clnt *);
-extern int rpc_remove_client_dir(struct dentry *);
+extern int rpc_remove_client_dir(struct dentry *, struct rpc_clnt *);
+
+extern void rpc_init_pipe_dir_head(struct rpc_pipe_dir_head *pdh);
+extern void rpc_init_pipe_dir_object(struct rpc_pipe_dir_object *pdo,
+		const struct rpc_pipe_dir_object_ops *pdo_ops,
+		void *pdo_data);
+extern int rpc_add_pipe_dir_object(struct net *net,
+		struct rpc_pipe_dir_head *pdh,
+		struct rpc_pipe_dir_object *pdo);
+extern void rpc_remove_pipe_dir_object(struct net *net,
+		struct rpc_pipe_dir_head *pdh,
+		struct rpc_pipe_dir_object *pdo);
 
 struct cache_detail;
 extern struct dentry *rpc_create_cache_dir(struct dentry *,
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 436adce..c736031 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -105,7 +105,7 @@ static void __rpc_clnt_remove_pipedir(struct rpc_clnt *clnt)
 	if (clnt->cl_dentry) {
 		if (clnt->cl_auth && clnt->cl_auth->au_ops->pipes_destroy)
 			clnt->cl_auth->au_ops->pipes_destroy(clnt->cl_auth);
-		rpc_remove_client_dir(clnt->cl_dentry);
+		rpc_remove_client_dir(clnt->cl_dentry, clnt);
 	}
 	clnt->cl_dentry = NULL;
 }
@@ -351,6 +351,7 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, stru
 	clnt->cl_vers     = version->number;
 	clnt->cl_stats    = program->stats;
 	clnt->cl_metrics  = rpc_alloc_iostats(clnt);
+	rpc_init_pipe_dir_head(&clnt->cl_pipedir_objects);
 	err = -ENOMEM;
 	if (clnt->cl_metrics == NULL)
 		goto out_no_stats;
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index b36bfb9..cfeba77 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -884,6 +884,124 @@ rpc_unlink(struct dentry *dentry)
 }
 EXPORT_SYMBOL_GPL(rpc_unlink);
 
+/**
+ * rpc_init_pipe_dir_head - initialise a struct rpc_pipe_dir_head
+ * @pdh: pointer to struct rpc_pipe_dir_head
+ */
+void rpc_init_pipe_dir_head(struct rpc_pipe_dir_head *pdh)
+{
+	INIT_LIST_HEAD(&pdh->pdh_entries);
+	pdh->pdh_dentry = NULL;
+}
+EXPORT_SYMBOL_GPL(rpc_init_pipe_dir_head);
+
+/**
+ * rpc_init_pipe_dir_object - initialise a struct rpc_pipe_dir_object
+ * @pdo: pointer to struct rpc_pipe_dir_object
+ * @pdo_ops: pointer to const struct rpc_pipe_dir_object_ops
+ * @pdo_data: pointer to caller-defined data
+ */
+void rpc_init_pipe_dir_object(struct rpc_pipe_dir_object *pdo,
+		const struct rpc_pipe_dir_object_ops *pdo_ops,
+		void *pdo_data)
+{
+	INIT_LIST_HEAD(&pdo->pdo_head);
+	pdo->pdo_ops = pdo_ops;
+	pdo->pdo_data = pdo_data;
+}
+EXPORT_SYMBOL_GPL(rpc_init_pipe_dir_object);
+
+static int
+rpc_add_pipe_dir_object_locked(struct net *net,
+		struct rpc_pipe_dir_head *pdh,
+		struct rpc_pipe_dir_object *pdo)
+{
+	int ret = 0;
+
+	if (pdh->pdh_dentry)
+		ret = pdo->pdo_ops->create(pdh->pdh_dentry, pdo);
+	if (ret == 0)
+		list_add_tail(&pdo->pdo_head, &pdh->pdh_entries);
+	return ret;
+}
+
+static void
+rpc_remove_pipe_dir_object_locked(struct net *net,
+		struct rpc_pipe_dir_head *pdh,
+		struct rpc_pipe_dir_object *pdo)
+{
+	if (pdh->pdh_dentry)
+		pdo->pdo_ops->destroy(pdh->pdh_dentry, pdo);
+	list_del_init(&pdo->pdo_head);
+}
+
+/**
+ * rpc_add_pipe_dir_object - associate a rpc_pipe_dir_object to a directory
+ * @net: pointer to struct net
+ * @pdh: pointer to struct rpc_pipe_dir_head
+ * @pdo: pointer to struct rpc_pipe_dir_object
+ *
+ */
+int
+rpc_add_pipe_dir_object(struct net *net,
+		struct rpc_pipe_dir_head *pdh,
+		struct rpc_pipe_dir_object *pdo)
+{
+	int ret = 0;
+
+	if (list_empty(&pdo->pdo_head)) {
+		struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
+
+		mutex_lock(&sn->pipefs_sb_lock);
+		ret = rpc_add_pipe_dir_object_locked(net, pdh, pdo);
+		mutex_unlock(&sn->pipefs_sb_lock);
+	}
+	return ret;
+}
+EXPORT_SYMBOL_GPL(rpc_add_pipe_dir_object);
+
+/**
+ * rpc_remove_pipe_dir_object - remove a rpc_pipe_dir_object from a directory
+ * @net: pointer to struct net
+ * @pdh: pointer to struct rpc_pipe_dir_head
+ * @pdo: pointer to struct rpc_pipe_dir_object
+ *
+ */
+void
+rpc_remove_pipe_dir_object(struct net *net,
+		struct rpc_pipe_dir_head *pdh,
+		struct rpc_pipe_dir_object *pdo)
+{
+	if (!list_empty(&pdo->pdo_head)) {
+		struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
+
+		mutex_lock(&sn->pipefs_sb_lock);
+		rpc_remove_pipe_dir_object_locked(net, pdh, pdo);
+		mutex_unlock(&sn->pipefs_sb_lock);
+	}
+}
+EXPORT_SYMBOL_GPL(rpc_remove_pipe_dir_object);
+
+static void
+rpc_create_pipe_dir_objects(struct rpc_pipe_dir_head *pdh)
+{
+	struct rpc_pipe_dir_object *pdo;
+	struct dentry *dir = pdh->pdh_dentry;
+
+	list_for_each_entry(pdo, &pdh->pdh_entries, pdo_head)
+		pdo->pdo_ops->create(dir, pdo);
+}
+
+static void
+rpc_destroy_pipe_dir_objects(struct rpc_pipe_dir_head *pdh)
+{
+	struct rpc_pipe_dir_object *pdo;
+	struct dentry *dir = pdh->pdh_dentry;
+
+	list_for_each_entry(pdo, &pdh->pdh_entries, pdo_head)
+		pdo->pdo_ops->destroy(dir, pdo);
+}
+
 enum {
 	RPCAUTH_info,
 	RPCAUTH_EOF
@@ -924,16 +1042,28 @@ struct dentry *rpc_create_client_dir(struct dentry *dentry,
 				   const char *name,
 				   struct rpc_clnt *rpc_client)
 {
-	return rpc_mkdir_populate(dentry, name, S_IRUGO | S_IXUGO, NULL,
+	struct dentry *ret;
+
+	ret = rpc_mkdir_populate(dentry, name, S_IRUGO | S_IXUGO, NULL,
 			rpc_clntdir_populate, rpc_client);
+	if (!IS_ERR(ret)) {
+		rpc_client->cl_pipedir_objects.pdh_dentry = ret;
+		rpc_create_pipe_dir_objects(&rpc_client->cl_pipedir_objects);
+	}
+	return ret;
 }
 
 /**
  * rpc_remove_client_dir - Remove a directory created with rpc_create_client_dir()
  * @dentry: dentry for the pipe
+ * @rpc_client: rpc_client for the pipe
  */
-int rpc_remove_client_dir(struct dentry *dentry)
+int rpc_remove_client_dir(struct dentry *dentry, struct rpc_clnt *rpc_client)
 {
+	if (rpc_client->cl_pipedir_objects.pdh_dentry) {
+		rpc_destroy_pipe_dir_objects(&rpc_client->cl_pipedir_objects);
+		rpc_client->cl_pipedir_objects.pdh_dentry = NULL;
+	}
 	return rpc_rmdir_depopulate(dentry, rpc_clntdir_depopulate);
 }
 
-- 
1.8.3.1


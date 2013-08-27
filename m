Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:54793 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753521Ab3H0U7I (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Aug 2013 16:59:08 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
CC: <andros@netapp.com>
Subject: [PATCH 14/15] SUNRPC: Add a helper to allow sharing of rpc_pipefs directory objects
Date: Tue, 27 Aug 2013 16:58:51 -0400
Message-ID: <1377637132-53318-14-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1377637132-53318-13-git-send-email-Trond.Myklebust@netapp.com>
References: <1377637132-53318-1-git-send-email-Trond.Myklebust@netapp.com>
 <1377637132-53318-2-git-send-email-Trond.Myklebust@netapp.com>
 <1377637132-53318-3-git-send-email-Trond.Myklebust@netapp.com>
 <1377637132-53318-4-git-send-email-Trond.Myklebust@netapp.com>
 <1377637132-53318-5-git-send-email-Trond.Myklebust@netapp.com>
 <1377637132-53318-6-git-send-email-Trond.Myklebust@netapp.com>
 <1377637132-53318-7-git-send-email-Trond.Myklebust@netapp.com>
 <1377637132-53318-8-git-send-email-Trond.Myklebust@netapp.com>
 <1377637132-53318-9-git-send-email-Trond.Myklebust@netapp.com>
 <1377637132-53318-10-git-send-email-Trond.Myklebust@netapp.com>
 <1377637132-53318-11-git-send-email-Trond.Myklebust@netapp.com>
 <1377637132-53318-12-git-send-email-Trond.Myklebust@netapp.com>
 <1377637132-53318-13-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add support for looking up existing objects and creating new ones if there
is no match.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 include/linux/sunrpc/rpc_pipe_fs.h |  6 ++++++
 net/sunrpc/rpc_pipe.c              | 35 +++++++++++++++++++++++++++++++++++
 2 files changed, 41 insertions(+)

diff --git a/include/linux/sunrpc/rpc_pipe_fs.h b/include/linux/sunrpc/rpc_pipe_fs.h
index b0cf181..a353e03 100644
--- a/include/linux/sunrpc/rpc_pipe_fs.h
+++ b/include/linux/sunrpc/rpc_pipe_fs.h
@@ -106,6 +106,12 @@ extern int rpc_add_pipe_dir_object(struct net *net,
 extern void rpc_remove_pipe_dir_object(struct net *net,
 		struct rpc_pipe_dir_head *pdh,
 		struct rpc_pipe_dir_object *pdo);
+extern struct rpc_pipe_dir_object *rpc_find_or_alloc_pipe_dir_object(
+		struct net *net,
+		struct rpc_pipe_dir_head *pdh,
+		int (*match)(struct rpc_pipe_dir_object *, void *),
+		struct rpc_pipe_dir_object *(*alloc)(void *),
+		void *data);
 
 struct cache_detail;
 extern struct dentry *rpc_create_cache_dir(struct dentry *,
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index a35b2f4..f94567b 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -982,6 +982,41 @@ rpc_remove_pipe_dir_object(struct net *net,
 }
 EXPORT_SYMBOL_GPL(rpc_remove_pipe_dir_object);
 
+/**
+ * rpc_find_or_alloc_pipe_dir_object
+ * @net: pointer to struct net
+ * @pdh: pointer to struct rpc_pipe_dir_head
+ * @match: match struct rpc_pipe_dir_object to data
+ * @alloc: allocate a new struct rpc_pipe_dir_object
+ * @data: user defined data for match() and alloc()
+ *
+ */
+struct rpc_pipe_dir_object *
+rpc_find_or_alloc_pipe_dir_object(struct net *net,
+		struct rpc_pipe_dir_head *pdh,
+		int (*match)(struct rpc_pipe_dir_object *, void *),
+		struct rpc_pipe_dir_object *(*alloc)(void *),
+		void *data)
+{
+	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
+	struct rpc_pipe_dir_object *pdo;
+
+	mutex_lock(&sn->pipefs_sb_lock);
+	list_for_each_entry(pdo, &pdh->pdh_entries, pdo_head) {
+		if (!match(pdo, data))
+			continue;
+		goto out;
+	}
+	pdo = alloc(data);
+	if (!pdo)
+		goto out;
+	rpc_add_pipe_dir_object_locked(net, pdh, pdo);
+out:
+	mutex_unlock(&sn->pipefs_sb_lock);
+	return pdo;
+}
+EXPORT_SYMBOL_GPL(rpc_find_or_alloc_pipe_dir_object);
+
 static void
 rpc_create_pipe_dir_objects(struct rpc_pipe_dir_head *pdh)
 {
-- 
1.8.3.1


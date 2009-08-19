From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 12/32] SUNRPC: Clean up rpc_lookup_create
Date: Wed, 19 Aug 2009 19:38:35 -0400
Message-ID: <1250725135-14632-13-git-send-email-Trond.Myklebust@netapp.com>
References: <1250725135-14632-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-2-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-3-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-4-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-5-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-6-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-7-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-8-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-9-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-10-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-11-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-12-git-send-email-Trond.Myklebust@netapp.com>
Mime-Version: 1.0
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:39738 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754031AbZHSXkx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Aug 2009 19:40:53 -0400
Received: from sacrsexc2-prd.hq.netapp.com (sacrsexc2-prd.hq.netapp.com [10.99.115.28])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n7JNePRH001724
	for <linux-nfs@vger.kernel.org>; Wed, 19 Aug 2009 16:40:42 -0700 (PDT)
In-Reply-To: <1250725135-14632-12-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/rpc_pipe.c |  100 +++++++++++++++++++++++++++++--------------------
 1 files changed, 59 insertions(+), 41 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index cf30bf5..3633851 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -624,6 +624,57 @@ static int __rpc_rmpipe(struct inode *dir, struct dentry *dentry)
 	return __rpc_unlink(dir, dentry);
 }
 
+static struct dentry *__rpc_lookup_create(struct dentry *parent,
+					  struct qstr *name)
+{
+	struct dentry *dentry;
+
+	dentry = d_lookup(parent, name);
+	if (!dentry) {
+		dentry = d_alloc(parent, name);
+		if (!dentry) {
+			dentry = ERR_PTR(-ENOMEM);
+			goto out_err;
+		}
+	}
+	if (!dentry->d_inode)
+		dentry->d_op = &rpc_dentry_operations;
+out_err:
+	return dentry;
+}
+
+static struct dentry *__rpc_lookup_create_exclusive(struct dentry *parent,
+					  struct qstr *name)
+{
+	struct dentry *dentry;
+
+	dentry = __rpc_lookup_create(parent, name);
+	if (dentry->d_inode == NULL)
+		return dentry;
+	dput(dentry);
+	return ERR_PTR(-EEXIST);
+}
+
+static struct dentry *rpc_lookup_negative(const char *path,
+					  struct nameidata *nd)
+{
+	struct inode *dir;
+	struct dentry *dentry;
+	int error;
+
+	error = rpc_lookup_parent(path, nd);
+	if (error != 0)
+		return ERR_PTR(error);
+	dir = nd->path.dentry->d_inode;
+	mutex_lock_nested(&dir->i_mutex, I_MUTEX_PARENT);
+	dentry = __rpc_lookup_create_exclusive(nd->path.dentry, &nd->last);
+	if (IS_ERR(dentry)) {
+		mutex_unlock(&dir->i_mutex);
+		rpc_release_path(nd);
+	}
+	return dentry;
+}
+
 /*
  * FIXME: This probably has races.
  */
@@ -723,44 +774,6 @@ __rpc_rmdir(struct inode *dir, struct dentry *dentry)
 	return error;
 }
 
-static struct dentry *
-rpc_lookup_create(struct dentry *parent, const char *name, int len, int exclusive)
-{
-	struct inode *dir = parent->d_inode;
-	struct dentry *dentry;
-
-	mutex_lock_nested(&dir->i_mutex, I_MUTEX_PARENT);
-	dentry = lookup_one_len(name, parent, len);
-	if (IS_ERR(dentry))
-		goto out_err;
-	if (!dentry->d_inode)
-		dentry->d_op = &rpc_dentry_operations;
-	else if (exclusive) {
-		dput(dentry);
-		dentry = ERR_PTR(-EEXIST);
-		goto out_err;
-	}
-	return dentry;
-out_err:
-	mutex_unlock(&dir->i_mutex);
-	return dentry;
-}
-
-static struct dentry *
-rpc_lookup_negative(char *path, struct nameidata *nd)
-{
-	struct dentry *dentry;
-	int error;
-
-	if ((error = rpc_lookup_parent(path, nd)) != 0)
-		return ERR_PTR(error);
-	dentry = rpc_lookup_create(nd->path.dentry, nd->last.name, nd->last.len,
-				   1);
-	if (IS_ERR(dentry))
-		rpc_release_path(nd);
-	return dentry;
-}
-
 /**
  * rpc_mkdir - Create a new directory in rpc_pipefs
  * @path: path from the rpc_pipefs root to the new directory
@@ -854,6 +867,7 @@ struct dentry *rpc_mkpipe(struct dentry *parent, const char *name,
 	struct dentry *dentry;
 	struct inode *dir = parent->d_inode;
 	umode_t umode = S_IFIFO | S_IRUSR | S_IWUSR;
+	struct qstr q;
 	int err;
 
 	if (ops->upcall == NULL)
@@ -861,10 +875,14 @@ struct dentry *rpc_mkpipe(struct dentry *parent, const char *name,
 	if (ops->downcall == NULL)
 		umode &= ~S_IWUGO;
 
-	dentry = rpc_lookup_create(parent, name, strlen(name), 0);
+	q.name = name;
+	q.len = strlen(name);
+	q.hash = full_name_hash(q.name, q.len),
+
+	mutex_lock_nested(&dir->i_mutex, I_MUTEX_PARENT);
+	dentry = __rpc_lookup_create(parent, &q);
 	if (IS_ERR(dentry))
-		return dentry;
-	dir = parent->d_inode;
+		goto out;
 	if (dentry->d_inode) {
 		struct rpc_inode *rpci = RPC_I(dentry->d_inode);
 		if (rpci->private != private ||
-- 
1.6.0.4

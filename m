From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 3/5] rpc: move in_downcall list to gss code
Date: Fri, 13 Jun 2008 18:50:40 -0400
Message-ID: <1213397442-15611-4-git-send-email-bfields@citi.umich.edu>
References: <1213397442-15611-1-git-send-email-bfields@citi.umich.edu>
 <1213397442-15611-2-git-send-email-bfields@citi.umich.edu>
 <1213397442-15611-3-git-send-email-bfields@citi.umich.edu>
Cc: aglo@citi.umich.edu, kwc@citi.umich.edu, linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:43960 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755783AbYFMWuo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jun 2008 18:50:44 -0400
In-Reply-To: <1213397442-15611-3-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This list is only used by the auth_gss code anyway.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 include/linux/sunrpc/rpc_pipe_fs.h |    1 -
 net/sunrpc/auth_gss/auth_gss.c     |   33 +++++++++++++++++++--------------
 net/sunrpc/rpc_pipe.c              |    1 -
 3 files changed, 19 insertions(+), 16 deletions(-)

diff --git a/include/linux/sunrpc/rpc_pipe_fs.h b/include/linux/sunrpc/rpc_pipe_fs.h
index 51b977a..867bea8 100644
--- a/include/linux/sunrpc/rpc_pipe_fs.h
+++ b/include/linux/sunrpc/rpc_pipe_fs.h
@@ -23,7 +23,6 @@ struct rpc_inode {
 	void *private;
 	struct list_head pipe;
 	struct list_head in_upcall;
-	struct list_head in_downcall;
 	int pipelen;
 	int nreaders;
 	int nwriters;
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 28ca1c9..5e82a69 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -83,6 +83,7 @@ struct gss_auth {
 	struct kref kref;
 	struct rpc_auth rpc_auth;
 	spinlock_t lock;
+	struct list_head in_downcall;
 	struct gss_api_mech *mech;
 	enum rpc_gss_svc service;
 	struct rpc_clnt *client;
@@ -259,10 +260,11 @@ gss_release_msg(struct gss_upcall_msg *gss_msg)
 }
 
 static struct gss_upcall_msg *
-__gss_find_upcall(struct rpc_inode *rpci, uid_t uid)
+__gss_find_upcall(struct gss_auth *gss_auth, uid_t uid)
 {
 	struct gss_upcall_msg *pos;
-	list_for_each_entry(pos, &rpci->in_downcall, list) {
+
+	list_for_each_entry(pos, &gss_auth->in_downcall, list) {
 		if (pos->uid != uid)
 			continue;
 		atomic_inc(&pos->count);
@@ -280,15 +282,13 @@ __gss_find_upcall(struct rpc_inode *rpci, uid_t uid)
 static inline struct gss_upcall_msg *
 gss_add_msg(struct gss_auth *gss_auth, struct gss_upcall_msg *gss_msg)
 {
-	struct inode *inode = gss_auth->dentry->d_inode;
-	struct rpc_inode *rpci = RPC_I(inode);
 	struct gss_upcall_msg *old;
 
 	spin_lock(&gss_auth->lock);
-	old = __gss_find_upcall(rpci, gss_msg->uid);
+	old = __gss_find_upcall(gss_auth, gss_msg->uid);
 	if (old == NULL) {
 		atomic_inc(&gss_msg->count);
-		list_add(&gss_msg->list, &rpci->in_downcall);
+		list_add(&gss_msg->list, &gss_auth->in_downcall);
 	} else
 		gss_msg = old;
 	spin_unlock(&gss_auth->lock);
@@ -484,6 +484,14 @@ gss_pipe_upcall(struct file *filp, struct rpc_pipe_msg *msg,
 	return mlen;
 }
 
+static struct gss_auth *gss_auth_from_dentry(struct dentry *dentry)
+{
+	struct inode *inode = dentry->d_inode;
+	struct rpc_clnt *clnt = RPC_I(inode)->private;
+
+	return container_of(clnt->cl_auth, struct gss_auth, rpc_auth);
+}
+
 #define MSG_BUF_MAXSIZE 1024
 
 static ssize_t
@@ -492,10 +500,7 @@ gss_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 	const void *p, *end;
 	void *buf;
 	struct gss_upcall_msg *gss_msg;
-	struct inode *inode = filp->f_path.dentry->d_inode;
-	struct rpc_clnt *clnt = RPC_I(inode)->private;
-	struct gss_auth *gss_auth = container_of(clnt->cl_auth,
-						 struct gss_auth, rpc_auth);
+	struct gss_auth *gss_auth = gss_auth_from_dentry(filp->f_path.dentry);
 	struct gss_cl_ctx *ctx;
 	uid_t uid;
 	ssize_t err = -EFBIG;
@@ -507,7 +512,6 @@ gss_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 	if (!buf)
 		goto out;
 
-	clnt = RPC_I(inode)->private;
 	err = -EFAULT;
 	if (copy_from_user(buf, src, mlen))
 		goto err;
@@ -527,7 +531,7 @@ gss_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 	err = -ENOENT;
 	/* Find a matching upcall */
 	spin_lock(&gss_auth->lock);
-	gss_msg = __gss_find_upcall(RPC_I(inode), uid);
+	gss_msg = __gss_find_upcall(gss_auth, uid);
 	if (gss_msg == NULL) {
 		spin_unlock(&gss_auth->lock);
 		goto err_put_ctx;
@@ -568,9 +572,9 @@ gss_pipe_release(struct inode *inode)
 	struct gss_upcall_msg *gss_msg;
 
 	spin_lock(&gss_auth->lock);
-	while (!list_empty(&rpci->in_downcall)) {
+	while (!list_empty(&gss_auth->in_downcall)) {
 
-		gss_msg = list_entry(rpci->in_downcall.next,
+		gss_msg = list_entry(gss_auth->in_downcall.next,
 				struct gss_upcall_msg, list);
 		gss_msg->msg.errno = -EPIPE;
 		atomic_inc(&gss_msg->count);
@@ -635,6 +639,7 @@ gss_create(struct rpc_clnt *clnt, rpc_authflavor_t flavor)
 		goto err_put_mech;
 	auth = &gss_auth->rpc_auth;
 	spin_lock_init(&gss_auth->lock);
+	INIT_LIST_HEAD(&gss_auth->in_downcall);
 	auth->au_cslack = GSS_CRED_SLACK >> 2;
 	auth->au_rslack = GSS_VERF_SLACK >> 2;
 	auth->au_ops = &authgss_ops;
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 5a9b0e7..41d968f 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -906,7 +906,6 @@ init_once(struct kmem_cache * cachep, void *foo)
 	rpci->nreaders = 0;
 	rpci->nwriters = 0;
 	INIT_LIST_HEAD(&rpci->in_upcall);
-	INIT_LIST_HEAD(&rpci->in_downcall);
 	INIT_LIST_HEAD(&rpci->pipe);
 	rpci->pipelen = 0;
 	init_waitqueue_head(&rpci->waitq);
-- 
1.5.5.rc1


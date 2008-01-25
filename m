From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 086/112] NFS: Clean up fs/nfs/idmap.c
Date: Fri, 25 Jan 2008 11:37:54 -0500
Message-ID: <20080125163754.31887.89150.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14355 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755001AbYAYQ77 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 11:59:59 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PGxsea010226
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 08:59:58 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Clean up white space damage and use standard kernel coding conventions for
return statements.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/idmap.c |   87 ++++++++++++++++++++++++++++----------------------------
 1 files changed, 44 insertions(+), 43 deletions(-)

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index d11eb05..c56fc7d 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -72,39 +72,39 @@ module_param_call(idmap_cache_timeout, param_set_idmap_timeout, param_get_int,
 		 &nfs_idmap_cache_timeout, 0644);
 
 struct idmap_hashent {
-	unsigned long ih_expires;
-	__u32 ih_id;
-	int ih_namelen;
-	char ih_name[IDMAP_NAMESZ];
+	unsigned long		ih_expires;
+	__u32			ih_id;
+	int			ih_namelen;
+	char			ih_name[IDMAP_NAMESZ];
 };
 
 struct idmap_hashtable {
-	__u8 h_type;
-	struct idmap_hashent h_entries[IDMAP_HASH_SZ];
+	__u8			h_type;
+	struct idmap_hashent	h_entries[IDMAP_HASH_SZ];
 };
 
 struct idmap {
-	struct dentry        *idmap_dentry;
-	wait_queue_head_t     idmap_wq;
-	struct idmap_msg      idmap_im;
-	struct mutex          idmap_lock;    /* Serializes upcalls */
-	struct mutex          idmap_im_lock; /* Protects the hashtable */
-	struct idmap_hashtable idmap_user_hash;
-	struct idmap_hashtable idmap_group_hash;
+	struct dentry		*idmap_dentry;
+	wait_queue_head_t	idmap_wq;
+	struct idmap_msg	idmap_im;
+	struct mutex		idmap_lock;	/* Serializes upcalls */
+	struct mutex		idmap_im_lock;	/* Protects the hashtable */
+	struct idmap_hashtable	idmap_user_hash;
+	struct idmap_hashtable	idmap_group_hash;
 };
 
-static ssize_t   idmap_pipe_upcall(struct file *, struct rpc_pipe_msg *,
-		     char __user *, size_t);
-static ssize_t   idmap_pipe_downcall(struct file *, const char __user *,
-		     size_t);
-static void      idmap_pipe_destroy_msg(struct rpc_pipe_msg *);
+static ssize_t idmap_pipe_upcall(struct file *, struct rpc_pipe_msg *,
+				 char __user *, size_t);
+static ssize_t idmap_pipe_downcall(struct file *, const char __user *,
+				   size_t);
+static void idmap_pipe_destroy_msg(struct rpc_pipe_msg *);
 
 static unsigned int fnvhash32(const void *, size_t);
 
 static struct rpc_pipe_ops idmap_upcall_ops = {
-        .upcall         = idmap_pipe_upcall,
-        .downcall       = idmap_pipe_downcall,
-        .destroy_msg    = idmap_pipe_destroy_msg,
+	.upcall		= idmap_pipe_upcall,
+	.downcall	= idmap_pipe_downcall,
+	.destroy_msg	= idmap_pipe_destroy_msg,
 };
 
 int
@@ -115,19 +115,20 @@ nfs_idmap_new(struct nfs_client *clp)
 
 	BUG_ON(clp->cl_idmap != NULL);
 
-        if ((idmap = kzalloc(sizeof(*idmap), GFP_KERNEL)) == NULL)
-                return -ENOMEM;
+	idmap = kzalloc(sizeof(*idmap), GFP_KERNEL);
+	if (idmap == NULL)
+		return -ENOMEM;
 
-        idmap->idmap_dentry = rpc_mkpipe(clp->cl_rpcclient->cl_dentry, "idmap",
-	    idmap, &idmap_upcall_ops, 0);
-        if (IS_ERR(idmap->idmap_dentry)) {
+	idmap->idmap_dentry = rpc_mkpipe(clp->cl_rpcclient->cl_dentry, "idmap",
+					 idmap, &idmap_upcall_ops, 0);
+	if (IS_ERR(idmap->idmap_dentry)) {
 		error = PTR_ERR(idmap->idmap_dentry);
 		kfree(idmap);
 		return error;
 	}
 
-        mutex_init(&idmap->idmap_lock);
-        mutex_init(&idmap->idmap_im_lock);
+	mutex_init(&idmap->idmap_lock);
+	mutex_init(&idmap->idmap_im_lock);
 	init_waitqueue_head(&idmap->idmap_wq);
 	idmap->idmap_user_hash.h_type = IDMAP_TYPE_USER;
 	idmap->idmap_group_hash.h_type = IDMAP_TYPE_GROUP;
@@ -285,7 +286,7 @@ nfs_idmap_id(struct idmap *idmap, struct idmap_hashtable *h,
 	memset(im, 0, sizeof(*im));
 	mutex_unlock(&idmap->idmap_im_lock);
 	mutex_unlock(&idmap->idmap_lock);
-	return (ret);
+	return ret;
 }
 
 /*
@@ -354,16 +355,16 @@ nfs_idmap_name(struct idmap *idmap, struct idmap_hashtable *h,
 /* RPC pipefs upcall/downcall routines */
 static ssize_t
 idmap_pipe_upcall(struct file *filp, struct rpc_pipe_msg *msg,
-    char __user *dst, size_t buflen)
+		  char __user *dst, size_t buflen)
 {
-        char *data = (char *)msg->data + msg->copied;
-        ssize_t mlen = msg->len - msg->copied;
-        ssize_t left;
+	char *data = (char *)msg->data + msg->copied;
+	ssize_t mlen = msg->len - msg->copied;
+	ssize_t left;
 
-        if (mlen > buflen)
-                mlen = buflen;
+	if (mlen > buflen)
+		mlen = buflen;
 
-        left = copy_to_user(dst, data, mlen);
+	left = copy_to_user(dst, data, mlen);
 	if (left < 0) {
 		msg->errno = left;
 		return left;
@@ -371,13 +372,13 @@ idmap_pipe_upcall(struct file *filp, struct rpc_pipe_msg *msg,
 	mlen -= left;
 	msg->copied += mlen;
 	msg->errno = 0;
-        return mlen;
+	return mlen;
 }
 
 static ssize_t
 idmap_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 {
-        struct rpc_inode *rpci = RPC_I(filp->f_path.dentry->d_inode);
+	struct rpc_inode *rpci = RPC_I(filp->f_path.dentry->d_inode);
 	struct idmap *idmap = (struct idmap *)rpci->private;
 	struct idmap_msg im_in, *im = &idmap->idmap_im;
 	struct idmap_hashtable *h;
@@ -385,11 +386,11 @@ idmap_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 	int namelen_in;
 	int ret;
 
-        if (mlen != sizeof(im_in))
-                return (-ENOSPC);
+	if (mlen != sizeof(im_in))
+		return -ENOSPC;
 
-        if (copy_from_user(&im_in, src, mlen) != 0)
-		return (-EFAULT);
+	if (copy_from_user(&im_in, src, mlen) != 0)
+		return -EFAULT;
 
 	mutex_lock(&idmap->idmap_im_lock);
 
@@ -487,7 +488,7 @@ static unsigned int fnvhash32(const void *buf, size_t buflen)
 		hash ^= (unsigned int)*p;
 	}
 
-	return (hash);
+	return hash;
 }
 
 int nfs_map_name_to_uid(struct nfs_client *clp, const char *name, size_t namelen, __u32 *uid)

From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/27] NFS: Clean up white space damage in
	fs/nfs/idmap.c
Date: Fri, 26 Oct 2007 13:31:31 -0400
Message-ID: <20071026173131.31475.8688.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IlT26-0007Dk-8A
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 10:31:43 -0700
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]
	helo=flpi185.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IlT2A-0008J3-JP
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 10:31:47 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/idmap.c |   80 ++++++++++++++++++++++++++++----------------------------
 1 files changed, 40 insertions(+), 40 deletions(-)

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index d11eb05..e687ba2 100644
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
+	struct dentry *		idmap_dentry;
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
@@ -115,19 +115,19 @@ nfs_idmap_new(struct nfs_client *clp)
 
 	BUG_ON(clp->cl_idmap != NULL);
 
-        if ((idmap = kzalloc(sizeof(*idmap), GFP_KERNEL)) == NULL)
-                return -ENOMEM;
+	if ((idmap = kzalloc(sizeof(*idmap), GFP_KERNEL)) == NULL)
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
@@ -354,16 +354,16 @@ nfs_idmap_name(struct idmap *idmap, struct idmap_hashtable *h,
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
@@ -371,13 +371,13 @@ idmap_pipe_upcall(struct file *filp, struct rpc_pipe_msg *msg,
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
@@ -385,10 +385,10 @@ idmap_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 	int namelen_in;
 	int ret;
 
-        if (mlen != sizeof(im_in))
-                return (-ENOSPC);
+	if (mlen != sizeof(im_in))
+		return (-ENOSPC);
 
-        if (copy_from_user(&im_in, src, mlen) != 0)
+	if (copy_from_user(&im_in, src, mlen) != 0)
 		return (-EFAULT);
 
 	mutex_lock(&idmap->idmap_im_lock);


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

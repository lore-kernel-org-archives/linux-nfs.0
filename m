Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:41856 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752444Ab1HPNq1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Aug 2011 09:46:27 -0400
Received: by pzk37 with SMTP id 37so4661215pzk.1
        for <linux-nfs@vger.kernel.org>; Tue, 16 Aug 2011 06:46:27 -0700 (PDT)
From: Peng Tao <bergwolf@gmail.com>
To: benny@tonian.com
Cc: linux-nfs@vger.kernel.org, Peng Tao <peng_tao@emc.com>
Subject: [PATCH RESEND 1/2] SUNRPC/NFS: make rpc pipe upcall generic
Date: Fri, 12 Aug 2011 18:02:17 -0700
Message-Id: <1313197338-4529-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The same function is used by idmap, gss and blocklayout code. Make it generic.

Signed-off-by: Peng Tao <peng_tao@emc.com>
---
 fs/nfs/blocklayout/blocklayout.c    |    2 +-
 fs/nfs/blocklayout/blocklayout.h    |    2 --
 fs/nfs/blocklayout/blocklayoutdev.c |   22 ----------------------
 fs/nfs/idmap.c                      |   25 +------------------------
 include/linux/sunrpc/rpc_pipe_fs.h  |    2 ++
 net/sunrpc/auth_gss/auth_gss.c      |   24 ++----------------------
 net/sunrpc/rpc_pipe.c               |   20 ++++++++++++++++++++
 7 files changed, 26 insertions(+), 71 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 18dcab4..6fdddde 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -960,7 +960,7 @@ static struct pnfs_layoutdriver_type blocklayout_type = {
 };
 
 static const struct rpc_pipe_ops bl_upcall_ops = {
-	.upcall		= bl_pipe_upcall,
+	.upcall		= rpc_pipe_generic_upcall,
 	.downcall	= bl_pipe_downcall,
 	.destroy_msg	= bl_pipe_destroy_msg,
 };
diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index f27d827..8900396 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -169,8 +169,6 @@ extern wait_queue_head_t bl_wq;
 #define BL_DEVICE_REQUEST_ERR          0x2 /* User level process fails */
 
 /* blocklayoutdev.c */
-ssize_t bl_pipe_upcall(struct file *, struct rpc_pipe_msg *,
-		       char __user *, size_t);
 ssize_t bl_pipe_downcall(struct file *, const char __user *, size_t);
 void bl_pipe_destroy_msg(struct rpc_pipe_msg *);
 struct block_device *nfs4_blkdev_get(dev_t dev);
diff --git a/fs/nfs/blocklayout/blocklayoutdev.c b/fs/nfs/blocklayout/blocklayoutdev.c
index a83b393..46a2ce6 100644
--- a/fs/nfs/blocklayout/blocklayoutdev.c
+++ b/fs/nfs/blocklayout/blocklayoutdev.c
@@ -79,28 +79,6 @@ int nfs4_blkdev_put(struct block_device *bdev)
 	return blkdev_put(bdev, FMODE_READ);
 }
 
-/*
- * Shouldn't there be a rpc_generic_upcall() to do this for us?
- */
-ssize_t bl_pipe_upcall(struct file *filp, struct rpc_pipe_msg *msg,
-		       char __user *dst, size_t buflen)
-{
-	char *data = (char *)msg->data + msg->copied;
-	size_t mlen = min(msg->len - msg->copied, buflen);
-	unsigned long left;
-
-	left = copy_to_user(dst, data, mlen);
-	if (left == mlen) {
-		msg->errno = -EFAULT;
-		return -EFAULT;
-	}
-
-	mlen -= left;
-	msg->copied += mlen;
-	msg->errno = 0;
-	return mlen;
-}
-
 static struct bl_dev_msg bl_mount_reply;
 
 ssize_t bl_pipe_downcall(struct file *filp, const char __user *src,
diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index f20801a..47d1c6f 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -336,8 +336,6 @@ struct idmap {
 	struct idmap_hashtable	idmap_group_hash;
 };
 
-static ssize_t idmap_pipe_upcall(struct file *, struct rpc_pipe_msg *,
-				 char __user *, size_t);
 static ssize_t idmap_pipe_downcall(struct file *, const char __user *,
 				   size_t);
 static void idmap_pipe_destroy_msg(struct rpc_pipe_msg *);
@@ -345,7 +343,7 @@ static void idmap_pipe_destroy_msg(struct rpc_pipe_msg *);
 static unsigned int fnvhash32(const void *, size_t);
 
 static const struct rpc_pipe_ops idmap_upcall_ops = {
-	.upcall		= idmap_pipe_upcall,
+	.upcall		= rpc_pipe_generic_upcall,
 	.downcall	= idmap_pipe_downcall,
 	.destroy_msg	= idmap_pipe_destroy_msg,
 };
@@ -595,27 +593,6 @@ nfs_idmap_name(struct idmap *idmap, struct idmap_hashtable *h,
 	return ret;
 }
 
-/* RPC pipefs upcall/downcall routines */
-static ssize_t
-idmap_pipe_upcall(struct file *filp, struct rpc_pipe_msg *msg,
-		  char __user *dst, size_t buflen)
-{
-	char *data = (char *)msg->data + msg->copied;
-	size_t mlen = min(msg->len, buflen);
-	unsigned long left;
-
-	left = copy_to_user(dst, data, mlen);
-	if (left == mlen) {
-		msg->errno = -EFAULT;
-		return -EFAULT;
-	}
-
-	mlen -= left;
-	msg->copied += mlen;
-	msg->errno = 0;
-	return mlen;
-}
-
 static ssize_t
 idmap_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 {
diff --git a/include/linux/sunrpc/rpc_pipe_fs.h b/include/linux/sunrpc/rpc_pipe_fs.h
index cf14db9..e4ea430 100644
--- a/include/linux/sunrpc/rpc_pipe_fs.h
+++ b/include/linux/sunrpc/rpc_pipe_fs.h
@@ -44,6 +44,8 @@ RPC_I(struct inode *inode)
 	return container_of(inode, struct rpc_inode, vfs_inode);
 }
 
+extern ssize_t rpc_pipe_generic_upcall(struct file *, struct rpc_pipe_msg *,
+				       char __user *, size_t);
 extern int rpc_queue_upcall(struct inode *, struct rpc_pipe_msg *);
 
 struct rpc_clnt;
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 364eb45..e9b7693 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -603,26 +603,6 @@ out:
 	return err;
 }
 
-static ssize_t
-gss_pipe_upcall(struct file *filp, struct rpc_pipe_msg *msg,
-		char __user *dst, size_t buflen)
-{
-	char *data = (char *)msg->data + msg->copied;
-	size_t mlen = min(msg->len, buflen);
-	unsigned long left;
-
-	left = copy_to_user(dst, data, mlen);
-	if (left == mlen) {
-		msg->errno = -EFAULT;
-		return -EFAULT;
-	}
-
-	mlen -= left;
-	msg->copied += mlen;
-	msg->errno = 0;
-	return mlen;
-}
-
 #define MSG_BUF_MAXSIZE 1024
 
 static ssize_t
@@ -1590,7 +1570,7 @@ static const struct rpc_credops gss_nullops = {
 };
 
 static const struct rpc_pipe_ops gss_upcall_ops_v0 = {
-	.upcall		= gss_pipe_upcall,
+	.upcall		= rpc_pipe_generic_upcall,
 	.downcall	= gss_pipe_downcall,
 	.destroy_msg	= gss_pipe_destroy_msg,
 	.open_pipe	= gss_pipe_open_v0,
@@ -1598,7 +1578,7 @@ static const struct rpc_pipe_ops gss_upcall_ops_v0 = {
 };
 
 static const struct rpc_pipe_ops gss_upcall_ops_v1 = {
-	.upcall		= gss_pipe_upcall,
+	.upcall		= rpc_pipe_generic_upcall,
 	.downcall	= gss_pipe_downcall,
 	.destroy_msg	= gss_pipe_destroy_msg,
 	.open_pipe	= gss_pipe_open_v1,
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index b181e34..67dbc18 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -77,6 +77,26 @@ rpc_timeout_upcall_queue(struct work_struct *work)
 	rpc_purge_list(rpci, &free_list, destroy_msg, -ETIMEDOUT);
 }
 
+ssize_t rpc_pipe_generic_upcall(struct file *filp, struct rpc_pipe_msg *msg,
+				char __user *dst, size_t buflen)
+{
+	char *data = (char *)msg->data + msg->copied;
+	size_t mlen = min(msg->len - msg->copied, buflen);
+	unsigned long left;
+
+	left = copy_to_user(dst, data, mlen);
+	if (left == mlen) {
+		msg->errno = -EFAULT;
+		return -EFAULT;
+	}
+
+	mlen -= left;
+	msg->copied += mlen;
+	msg->errno = 0;
+	return mlen;
+}
+EXPORT_SYMBOL_GPL(rpc_pipe_generic_upcall);
+
 /**
  * rpc_queue_upcall - queue an upcall message to userspace
  * @inode: inode of upcall pipe on which to queue given message
-- 
1.7.1.262.g5ef3d


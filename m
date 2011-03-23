Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:40592 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756158Ab1CWTEe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Mar 2011 15:04:34 -0400
Message-ID: <4D8A443F.4070309@netapp.com>
Date: Wed, 23 Mar 2011 15:04:31 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 3/3] NFS: Detect loops in a readdir due to bad cookies
References: <4D8A407F.40105@netapp.com>
In-Reply-To: <4D8A407F.40105@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Here is an updated patch.  In nfs_ll_seekdir() I clear dir_ctx->duped at the same time as dir_ctx->dir_cookie, rather than at the beginning of the function.  I also changed the pr_notice() message to print out the cookie that caused the problem.

-Bryan


Some filesystems (such as ext4) can return the same cookie value for
multiple files.  If we try to start a readdir with one of these cookies,
the server will return the first file found with a cookie of the same
value.  This can cause the client to enter an infinite loop.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 112494a..901e9c0 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -139,7 +139,9 @@ static struct nfs_open_dir_context *alloc_nfs_open_dir_context(struct rpc_cred *
 	struct nfs_open_dir_context *ctx;
 	ctx = kmalloc(sizeof(*ctx), GFP_KERNEL);
 	if (ctx != NULL) {
+		ctx->duped = 0;
 		ctx->dir_cookie = 0;
+		ctx->dup_cookie = 0;
 		ctx->cred = get_rpccred(cred);
 	} else
 		ctx = ERR_PTR(-ENOMEM);
@@ -321,6 +323,7 @@ int nfs_readdir_search_for_pos(struct nfs_cache_array *array, nfs_readdir_descri
 {
 	loff_t diff = desc->file->f_pos - desc->current_index;
 	unsigned int index;
+	struct nfs_open_dir_context *ctx = desc->file->private_data;
 
 	if (diff < 0)
 		goto out_eof;
@@ -333,6 +336,7 @@ int nfs_readdir_search_for_pos(struct nfs_cache_array *array, nfs_readdir_descri
 	index = (unsigned int)diff;
 	*desc->dir_cookie = array->array[index].cookie;
 	desc->cache_entry_index = index;
+	ctx->duped = 0;
 	return 0;
 out_eof:
 	desc->eof = 1;
@@ -343,11 +347,18 @@ static
 int nfs_readdir_search_for_cookie(struct nfs_cache_array *array, nfs_readdir_descriptor_t *desc)
 {
 	int i;
+	loff_t new_pos;
 	int status = -EAGAIN;
+	struct nfs_open_dir_context *ctx = desc->file->private_data;
 
 	for (i = 0; i < array->size; i++) {
 		if (array->array[i].cookie == *desc->dir_cookie) {
-			desc->file->f_pos = desc->current_index + i;
+			new_pos = desc->current_index + i;
+			if (new_pos < desc->file->f_pos) {
+				ctx->dup_cookie = *desc->dir_cookie;
+				ctx->duped = 1;
+			}
+			desc->file->f_pos = new_pos;
 			desc->cache_entry_index = i;
 			return 0;
 		}
@@ -732,6 +743,20 @@ int nfs_do_filldir(nfs_readdir_descriptor_t *desc, void *dirent,
 	int i = 0;
 	int res = 0;
 	struct nfs_cache_array *array = NULL;
+	struct nfs_open_dir_context *ctx = file->private_data;
+
+	if (ctx->duped != 0 && ctx->dup_cookie == *desc->dir_cookie) {
+		if (printk_ratelimit()) {
+			pr_notice("NFS: directory %s/%s contains a readdir loop.  "
+				"Please contact your server vendor.  "
+				"Offending cookie: %llu\n",
+				file->f_dentry->d_parent->d_name.name,
+				file->f_dentry->d_name.name,
+				*desc->dir_cookie);
+		}
+		res = -ELOOP;
+		goto out;
+	}
 
 	array = nfs_readdir_get_array(desc->page);
 	if (IS_ERR(array)) {
@@ -914,6 +939,7 @@ static loff_t nfs_llseek_dir(struct file *filp, loff_t offset, int origin)
 	if (offset != filp->f_pos) {
 		filp->f_pos = offset;
 		dir_ctx->dir_cookie = 0;
+		dir_ctx->duped = 0;
 	}
 out:
 	mutex_unlock(&inode->i_mutex);
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 4b87c00..69d6fc9 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -98,6 +98,8 @@ struct nfs_open_context {
 struct nfs_open_dir_context {
 	struct rpc_cred *cred;
 	__u64 dir_cookie;
+	__u64 dup_cookie;
+	int duped;
 };
 
 /*


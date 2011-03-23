From: Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v2 3/3] NFS: Detect loops in a readdir due to bad cookies
Date: Wed, 23 Mar 2011 14:48:31 -0400
Message-ID: <4D8A407F.40105@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:5931 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932587Ab1CWSsc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Mar 2011 14:48:32 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Some filesystems (such as ext4) can return the same cookie value for
multiple files.  If we try to start a readdir with one of these cookies,
the server will return the first file found with a cookie of the same
value.  This can cause the client to enter an infinite loop.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/dir.c           |   26 +++++++++++++++++++++++++-
 include/linux/nfs_fs.h |    2 ++
 2 files changed, 27 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 112494a..64fa9fc 100644
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
@@ -732,6 +743,18 @@ int nfs_do_filldir(nfs_readdir_descriptor_t *desc, void *dirent,
 	int i = 0;
 	int res = 0;
 	struct nfs_cache_array *array = NULL;
+	struct nfs_open_dir_context *ctx = file->private_data;
+
+	if (ctx->duped != 0 && ctx->dup_cookie == *desc->dir_cookie) {
+		if (printk_ratelimit()) {
+			pr_notice("NFS: directory %s/%s contains a readdir loop.  "
+				"Please contact your server vendor.",
+				file->f_dentry->d_parent->d_name.name,
+				file->f_dentry->d_name.name);
+		}
+		res = -ELOOP;
+		goto out;
+	}
 
 	array = nfs_readdir_get_array(desc->page);
 	if (IS_ERR(array)) {
@@ -900,6 +923,7 @@ static loff_t nfs_llseek_dir(struct file *filp, loff_t offset, int origin)
 			dentry->d_name.name,
 			offset, origin);
 
+	dir_ctx->duped = 0;
 	mutex_lock(&inode->i_mutex);
 	switch (origin) {
 		case 1:
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
-- 
1.7.4.1


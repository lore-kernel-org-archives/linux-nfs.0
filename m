Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:58313 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932138Ab0IGUDm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Sep 2010 16:03:42 -0400
Received: from [10.58.61.36] (panchal1-lxp.hq.netapp.com [10.58.61.36] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o87K3fmX027270
	for <linux-nfs@vger.kernel.org>; Tue, 7 Sep 2010 13:03:41 -0700 (PDT)
Message-ID: <4C869A9D.7020604@netapp.com>
Date: Tue, 07 Sep 2010 16:03:41 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/6] NFS: add readdir cache array
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

NFS: add readdir cache array

This patch adds the readdir cache array and functions to retreive the array
stored on a cache page, clear the array by freeing allocated memory, add an
entry to the array, and search the array for a given cookie.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index e257172..2e3f8d1 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -55,6 +55,7 @@ static int nfs_rename(struct inode *, struct dentry *,
 		      struct inode *, struct dentry *);
 static int nfs_fsync_dir(struct file *, int);
 static loff_t nfs_llseek_dir(struct file *, loff_t, int);
+static int nfs_readdir_clear_array(struct page*, gfp_t);
 
 const struct file_operations nfs_dir_operations = {
 	.llseek		= nfs_llseek_dir,
@@ -80,6 +81,10 @@ const struct inode_operations nfs_dir_inode_operations = {
 	.setattr	= nfs_setattr,
 };
 
+const struct address_space_operations nfs_dir_addr_space_ops = {
+	.releasepage = nfs_readdir_clear_array,
+};
+
 #ifdef CONFIG_NFS_V3
 const struct inode_operations nfs3_dir_inode_operations = {
 	.create		= nfs_create,
@@ -150,6 +155,21 @@ nfs_opendir(struct inode *inode, struct file *filp)
 	return res;
 }
 
+struct nfs_cache_array_entry {
+	u64 cookie;
+	u64 ino;
+	struct qstr string;
+};
+
+struct nfs_cache_array {
+	unsigned int size;
+	int eof_index;
+	u64 last_cookie;
+	struct nfs_cache_array_entry array[0];
+};
+
+#define MAX_READDIR_ARRAY ((PAGE_SIZE - sizeof(struct nfs_cache_array)) / sizeof(struct nfs_cache_array_entry))
+
 typedef __be32 * (*decode_dirent_t)(__be32 *, struct nfs_entry *, int);
 typedef struct {
 	struct file	*file;
@@ -164,8 +184,100 @@ typedef struct {
 	unsigned long	timestamp;
 	unsigned long	gencount;
 	int		timestamp_valid;
+	unsigned int	cache_entry_index;
+	unsigned int	eof;
 } nfs_readdir_descriptor_t;
 
+/*
+ * The caller is responsible for calling kunmap(page)
+ */
+static inline
+struct nfs_cache_array *nfs_readdir_get_array(struct page *page)
+{
+	if (page == NULL)
+		return ERR_PTR(-EIO);
+	return (struct nfs_cache_array *)kmap(page);
+}
+
+/*
+ * we are freeing strings created by nfs_add_to_readdir_array()
+ */
+static
+int nfs_readdir_clear_array(struct page *page, gfp_t mask)
+{
+	struct nfs_cache_array *array = nfs_readdir_get_array(page_address(page));
+	int i;
+	for (i = 0; i < array->size; i++)
+		kfree(array->array[i].string.name);
+	kunmap(page);
+	return 0;
+}
+
+/*
+ * the caller is responsible for freeing qstr.name
+ * when called by nfs_readdir_add_to_array, the strings will be freed in
+ * nfs_clear_readdir_array()
+ */
+static inline
+struct qstr nfs_readdir_make_qstr(const char *name, unsigned int len)
+{
+	struct qstr string;
+	string.len = len;
+	string.name = kmemdup(name, len, GFP_KERNEL);
+	string.hash = full_name_hash(string.name, string.len);
+	return string;
+}
+
+static
+int nfs_readdir_add_to_array(struct nfs_entry *entry, struct page *page)
+{
+	struct nfs_cache_array *array = nfs_readdir_get_array(page);
+	if (IS_ERR(array))
+		return (size_t)array;
+	if (array->size >= MAX_READDIR_ARRAY) {
+		kunmap(page);
+		return -EIO;
+	}
+
+	array->array[array->size].cookie = entry->prev_cookie;
+	array->last_cookie = entry->cookie;
+	array->array[array->size].ino = entry->ino;
+	array->array[array->size].string = nfs_readdir_make_qstr(entry->name, entry->len);
+	if (entry->eof == 1)
+		array->eof_index = array->size;
+	array->size++;
+	kunmap(page);
+	return 0;
+}
+
+static
+int nfs_readdir_search_array(nfs_readdir_descriptor_t *desc)
+{
+	struct nfs_cache_array *array;
+	int i;
+	int status = -EBADCOOKIE;
+
+	if (desc->dir_cookie == NULL)
+		return -EBADCOOKIE;
+
+	array = nfs_readdir_get_array(desc->page);
+	if (IS_ERR(array))
+		return (size_t)array;
+
+	for (i = 0; i < array->size; i++) {
+		if (i == array->eof_index)
+			desc->eof = 1;
+		if (array->array[i].cookie == *desc->dir_cookie) {
+			desc->cache_entry_index = i;
+			status = 0;
+			goto exit;
+		}
+	}
+exit:
+	kunmap(desc->page);
+	return status;
+}
+
 /* Now we cache directories properly, by stuffing the dirent
  * data directly in the page cache.
  *

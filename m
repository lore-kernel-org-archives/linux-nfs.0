Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:56731 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754059Ab0LAPgz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Dec 2010 10:36:55 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>,
        Nick Bowler <nbowler@elliptictech.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org
Subject: [PATCH v2 3/3] NFS: Fix a memory leak in nfs_readdir
Date: Wed,  1 Dec 2010 10:36:44 -0500
Message-Id: <1291217804-11257-4-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1291217804-11257-3-git-send-email-Trond.Myklebust@netapp.com>
References: <1291217804-11257-1-git-send-email-Trond.Myklebust@netapp.com>
 <1291217804-11257-2-git-send-email-Trond.Myklebust@netapp.com>
 <1291217804-11257-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <20101201150428.GA2879@elliptictech.com>
References: <20101201150428.GA2879@elliptictech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

We need to ensure that the entries in the nfs_cache_array get cleared
when the page is removed from the page cache. To do so, we use the
releasepage address_space operation (which also requires us to set
the Pg_private flag).

Change nfs_readdir_clear_array to use kmap_atomic(), so that the
function can be safely called from all direct reclaim contexts.

Finally, modify the cache_page_release helper to call
nfs_readdir_clear_array directly, when dealing with an anonymous
page from 'uncached_readdir'.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/dir.c           |   22 +++++++++++++++++-----
 fs/nfs/inode.c         |    1 +
 include/linux/nfs_fs.h |    1 +
 3 files changed, 19 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 3ec3f1c..4c6319e 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -58,6 +58,7 @@ static int nfs_rename(struct inode *, struct dentry *,
 static int nfs_fsync_dir(struct file *, int);
 static loff_t nfs_llseek_dir(struct file *, loff_t, int);
 static int nfs_readdir_clear_array(struct page*, gfp_t);
+static void nfs_readdir_invalidatepage(struct page*, unsigned long);
 
 const struct file_operations nfs_dir_operations = {
 	.llseek		= nfs_llseek_dir,
@@ -85,6 +86,7 @@ const struct inode_operations nfs_dir_inode_operations = {
 
 const struct address_space_operations nfs_dir_addr_space_ops = {
 	.releasepage = nfs_readdir_clear_array,
+	.invalidatepage = nfs_readdir_invalidatepage,
 };
 
 #ifdef CONFIG_NFS_V3
@@ -216,15 +218,22 @@ void nfs_readdir_release_array(struct page *page)
 static
 int nfs_readdir_clear_array(struct page *page, gfp_t mask)
 {
-	struct nfs_cache_array *array = nfs_readdir_get_array(page);
+	struct nfs_cache_array *array;
 	int i;
 
-	if (IS_ERR(array))
-		return PTR_ERR(array);
+	array = kmap_atomic(page, KM_USER0);
 	for (i = 0; i < array->size; i++)
 		kfree(array->array[i].string.name);
-	nfs_readdir_release_array(page);
-	return 0;
+	kunmap_atomic(array, KM_USER0);
+	ClearPageUptodate(page);
+	ClearPagePrivate(page);
+	return 1;
+}
+
+static
+void nfs_readdir_invalidatepage(struct page *page, unsigned long offset)
+{
+	nfs_readdir_clear_array(page, 0);
 }
 
 /*
@@ -624,6 +633,7 @@ int nfs_readdir_filler(nfs_readdir_descriptor_t *desc, struct page* page)
 	if (ret < 0)
 		goto error;
 	SetPageUptodate(page);
+	SetPagePrivate(page);
 
 	if (invalidate_inode_pages2_range(inode->i_mapping, page->index + 1, -1) < 0) {
 		/* Should never happen */
@@ -639,6 +649,8 @@ int nfs_readdir_filler(nfs_readdir_descriptor_t *desc, struct page* page)
 static
 void cache_page_release(nfs_readdir_descriptor_t *desc)
 {
+	if (!desc->page->mapping)
+		nfs_readdir_clear_array(desc->page, GFP_KERNEL);
 	unlock_page(desc->page);
 	page_cache_release(desc->page);
 	desc->page = NULL;
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 314f571..0018e07 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -289,6 +289,7 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr)
 		} else if (S_ISDIR(inode->i_mode)) {
 			inode->i_op = NFS_SB(sb)->nfs_client->rpc_ops->dir_inode_ops;
 			inode->i_fop = &nfs_dir_operations;
+			inode->i_data.a_ops = &nfs_dir_addr_space_ops;
 			if (nfs_server_capable(inode, NFS_CAP_READDIRPLUS))
 				set_bit(NFS_INO_ADVISE_RDPLUS, &NFS_I(inode)->flags);
 			/* Deal with crossing mountpoints */
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index c66fdb7..b5d3ab0 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -401,6 +401,7 @@ extern const struct inode_operations nfs3_file_inode_operations;
 #endif /* CONFIG_NFS_V3 */
 extern const struct file_operations nfs_file_operations;
 extern const struct address_space_operations nfs_file_aops;
+extern const struct address_space_operations nfs_dir_addr_space_ops;
 
 static inline struct nfs_open_context *nfs_file_open_context(struct file *filp)
 {
-- 
1.7.3.2


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:28482 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756887Ab0LBDIR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Dec 2010 22:08:17 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>,
        Nick Bowler <nbowler@elliptictech.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
        Hugh Dickins <hughd@google.com>, Nick Piggin <npiggin@kernel.dk>,
        Rik van Riel <riel@redhat.com>, Christoph Hellwig <hch@lst.de>,
        Al Viro <viro@zeniv.linux.org.uk>
Subject: [PATCH v3 3/3] NFS: Fix a memory leak in nfs_readdir
Date: Wed,  1 Dec 2010 22:08:05 -0500
Message-Id: <1291259285-26803-4-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1291259285-26803-3-git-send-email-Trond.Myklebust@netapp.com>
References: <1291259285-26803-1-git-send-email-Trond.Myklebust@netapp.com>
 <1291259285-26803-2-git-send-email-Trond.Myklebust@netapp.com>
 <1291259285-26803-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <AANLkTinpvMJsC2XMUyDTaAdozFBLkcdde5_V57Jx-Z4w@mail.gmail.com>
References: <AANLkTinpvMJsC2XMUyDTaAdozFBLkcdde5_V57Jx-Z4w@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

We need to ensure that the entries in the nfs_cache_array get cleared
when the page is removed from the page cache. To do so, we use the
freepage address_space operation.

Change nfs_readdir_clear_array to use kmap_atomic(), so that the
function can be safely called from all contexts.

Finally, modify the cache_page_release helper to call
nfs_readdir_clear_array directly, when dealing with an anonymous
page from 'uncached_readdir'.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/dir.c           |   18 +++++++++---------
 fs/nfs/inode.c         |    1 +
 include/linux/nfs_fs.h |    1 +
 3 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index e03537f..d529e0e 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -57,7 +57,7 @@ static int nfs_rename(struct inode *, struct dentry *,
 		      struct inode *, struct dentry *);
 static int nfs_fsync_dir(struct file *, int);
 static loff_t nfs_llseek_dir(struct file *, loff_t, int);
-static int nfs_readdir_clear_array(struct page*, gfp_t);
+static void nfs_readdir_clear_array(struct page*);
 
 const struct file_operations nfs_dir_operations = {
 	.llseek		= nfs_llseek_dir,
@@ -83,8 +83,8 @@ const struct inode_operations nfs_dir_inode_operations = {
 	.setattr	= nfs_setattr,
 };
 
-const struct address_space_operations nfs_dir_addr_space_ops = {
-	.releasepage = nfs_readdir_clear_array,
+const struct address_space_operations nfs_dir_aops = {
+	.freepage = nfs_readdir_clear_array,
 };
 
 #ifdef CONFIG_NFS_V3
@@ -214,17 +214,15 @@ void nfs_readdir_release_array(struct page *page)
  * we are freeing strings created by nfs_add_to_readdir_array()
  */
 static
-int nfs_readdir_clear_array(struct page *page, gfp_t mask)
+void nfs_readdir_clear_array(struct page *page)
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
 }
 
 /*
@@ -639,6 +637,8 @@ int nfs_readdir_filler(nfs_readdir_descriptor_t *desc, struct page* page)
 static
 void cache_page_release(nfs_readdir_descriptor_t *desc)
 {
+	if (!desc->page->mapping)
+		nfs_readdir_clear_array(desc->page);
 	page_cache_release(desc->page);
 	desc->page = NULL;
 }
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 314f571..e67e31c 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -289,6 +289,7 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr)
 		} else if (S_ISDIR(inode->i_mode)) {
 			inode->i_op = NFS_SB(sb)->nfs_client->rpc_ops->dir_inode_ops;
 			inode->i_fop = &nfs_dir_operations;
+			inode->i_data.a_ops = &nfs_dir_aops;
 			if (nfs_server_capable(inode, NFS_CAP_READDIRPLUS))
 				set_bit(NFS_INO_ADVISE_RDPLUS, &NFS_I(inode)->flags);
 			/* Deal with crossing mountpoints */
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index c66fdb7..29d504d 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -401,6 +401,7 @@ extern const struct inode_operations nfs3_file_inode_operations;
 #endif /* CONFIG_NFS_V3 */
 extern const struct file_operations nfs_file_operations;
 extern const struct address_space_operations nfs_file_aops;
+extern const struct address_space_operations nfs_dir_aops;
 
 static inline struct nfs_open_context *nfs_file_open_context(struct file *filp)
 {
-- 
1.7.3.2


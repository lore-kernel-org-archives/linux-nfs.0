From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/7] NFS: Add debugging facility for NFS aops
Date: Wed, 11 Jun 2008 17:55:50 -0400
Message-ID: <20080611215549.7068.14401.stgit@ellison.1015granger.net>
References: <20080611215018.7068.71737.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:35302 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753240AbYFKWCI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Jun 2008 18:02:08 -0400
In-Reply-To: <20080611215018.7068.71737.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Recent work in fs/nfs/file.c neglected to add appropriate trace debugging
for the NFS client's address space operations.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/file.c |   29 +++++++++++++++++++++++++++--
 1 files changed, 27 insertions(+), 2 deletions(-)


diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index ce18877..5a14f1c 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -335,6 +335,11 @@ static int nfs_write_begin(struct file *file, struct address_space *mapping,
 	struct page *page;
 	index = pos >> PAGE_CACHE_SHIFT;
 
+	dfprintk(PAGECACHE, "NFS: write_begin(%s/%s(%ld), %u@%lld)\n",
+		file->f_path.dentry->d_parent->d_name.name,
+		file->f_path.dentry->d_name.name,
+		mapping->host->i_ino, len, (long long) pos);
+
 	page = __grab_cache_page(mapping, index);
 	if (!page)
 		return -ENOMEM;
@@ -355,6 +360,11 @@ static int nfs_write_end(struct file *file, struct address_space *mapping,
 	unsigned offset = pos & (PAGE_CACHE_SIZE - 1);
 	int status;
 
+	dfprintk(PAGECACHE, "NFS: write_end(%s/%s(%ld), %u@%lld)\n",
+		file->f_path.dentry->d_parent->d_name.name,
+		file->f_path.dentry->d_name.name,
+		mapping->host->i_ino, len, (long long) pos);
+
 	lock_kernel();
 	status = nfs_updatepage(file, page, offset, copied);
 	unlock_kernel();
@@ -369,6 +379,8 @@ static int nfs_write_end(struct file *file, struct address_space *mapping,
 
 static void nfs_invalidate_page(struct page *page, unsigned long offset)
 {
+	dfprintk(PAGECACHE, "NFS: invalidate_page(%p, %lu)\n", page, offset);
+
 	if (offset != 0)
 		return;
 	/* Cancel any unstarted writes on this page */
@@ -377,13 +389,20 @@ static void nfs_invalidate_page(struct page *page, unsigned long offset)
 
 static int nfs_release_page(struct page *page, gfp_t gfp)
 {
+	dfprintk(PAGECACHE, "NFS: release_page(%p)\n", page);
+
 	/* If PagePrivate() is set, then the page is not freeable */
 	return 0;
 }
 
 static int nfs_launder_page(struct page *page)
 {
-	return nfs_wb_page(page->mapping->host, page);
+	struct inode *inode = page->mapping->host;
+
+	dfprintk(PAGECACHE, "NFS: launder_page(%ld, %llu)\n",
+		inode->i_ino, (long long)page_offset(page));
+
+	return nfs_wb_page(inode, page);
 }
 
 const struct address_space_operations nfs_file_aops = {
@@ -403,13 +422,19 @@ const struct address_space_operations nfs_file_aops = {
 static int nfs_vm_page_mkwrite(struct vm_area_struct *vma, struct page *page)
 {
 	struct file *filp = vma->vm_file;
+	struct dentry *dentry = filp->f_path.dentry;
 	unsigned pagelen;
 	int ret = -EINVAL;
 	struct address_space *mapping;
 
+	dfprintk(PAGECACHE, "NFS: vm_page_mkwrite(%s/%s(%ld), offset %lld)\n",
+		dentry->d_parent->d_name.name, dentry->d_name.name,
+		filp->f_mapping->host->i_ino,
+		(long long)page_offset(page));
+
 	lock_page(page);
 	mapping = page->mapping;
-	if (mapping != vma->vm_file->f_path.dentry->d_inode->i_mapping)
+	if (mapping != dentry->d_inode->i_mapping)
 		goto out_unlock;
 
 	ret = 0;


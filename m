From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/5] NFS: Add debugging facility for NFS aops
Date: Fri, 21 Mar 2008 19:02:31 -0400
Message-ID: <20080321230231.23627.59557.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]:12636 "EHLO
	flpi185.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764095AbYCUXCs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Mar 2008 19:02:48 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Recent work in fs/nfs/file.c neglected to add appropriate trace debugging
for the NFS client's address space operations.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/file.c |   29 ++++++++++++++++++++++++++++-
 1 files changed, 28 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index b50f86c..fb0a7cd 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -329,11 +329,17 @@ static int nfs_write_begin(struct file *file, struct address_space *mapping,
 			loff_t pos, unsigned len, unsigned flags,
 			struct page **pagep, void **fsdata)
 {
+	struct dentry *dentry = file->f_path.dentry;
+	struct inode *inode = mapping->host;
 	int ret;
 	pgoff_t index;
 	struct page *page;
 	index = pos >> PAGE_CACHE_SHIFT;
 
+	dfprintk(PAGECACHE, "NFS: write_begin(%s/%s(%ld), %u@%Ld)\n",
+		dentry->d_parent->d_name.name, dentry->d_name.name,
+		inode->i_ino, len, (long long) pos);
+
 	page = __grab_cache_page(mapping, index);
 	if (!page)
 		return -ENOMEM;
@@ -351,9 +357,15 @@ static int nfs_write_end(struct file *file, struct address_space *mapping,
 			loff_t pos, unsigned len, unsigned copied,
 			struct page *page, void *fsdata)
 {
+	struct dentry *dentry = file->f_path.dentry;
+	struct inode *inode = mapping->host;
 	unsigned offset = pos & (PAGE_CACHE_SIZE - 1);
 	int status;
 
+	dfprintk(PAGECACHE, "NFS: write_end(%s/%s(%ld), %u@%Ld)\n",
+		dentry->d_parent->d_name.name, dentry->d_name.name,
+		inode->i_ino, len, (long long) pos);
+
 	lock_kernel();
 	status = nfs_updatepage(file, page, offset, copied);
 	unlock_kernel();
@@ -368,6 +380,8 @@ static int nfs_write_end(struct file *file, struct address_space *mapping,
 
 static void nfs_invalidate_page(struct page *page, unsigned long offset)
 {
+	dfprintk(PAGECACHE, "NFS: invalidate_page(%p, %lu)\n", page, offset);
+
 	if (offset != 0)
 		return;
 	/* Cancel any unstarted writes on this page */
@@ -376,13 +390,20 @@ static void nfs_invalidate_page(struct page *page, unsigned long offset)
 
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
+	dfprintk(PAGECACHE, "NFS: launder_page(%ld, %Lu)\n",
+		inode->i_ino, (long long)page_offset(page));
+
+	return nfs_wb_page(inode, page);
 }
 
 const struct address_space_operations nfs_file_aops = {
@@ -402,10 +423,16 @@ const struct address_space_operations nfs_file_aops = {
 static int nfs_vm_page_mkwrite(struct vm_area_struct *vma, struct page *page)
 {
 	struct file *filp = vma->vm_file;
+	struct dentry *dentry = filp->f_path.dentry;
 	unsigned pagelen;
 	int ret = -EINVAL;
 	struct address_space *mapping;
 
+	dfprintk(PAGECACHE, "NFS: vm_page_mkwrite(%s/%s(%ld), offset %Ld)\n",
+		dentry->d_parent->d_name.name, dentry->d_name.name,
+		filp->f_mapping->host->i_ino,
+		(long long)page_offset(page));
+
 	lock_page(page);
 	mapping = page->mapping;
 	if (mapping != vma->vm_file->f_path.dentry->d_inode->i_mapping)


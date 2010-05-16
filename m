From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 14/22] pnfs_submit: stash and refcount lseg in write path
Date: Sat, 15 May 2010 21:23:05 -0400
Message-ID: <1273972993-15369-15-git-send-email-iisaman@netapp.com>
References: <1273972993-15369-1-git-send-email-iisaman@netapp.com>
 <1273972993-15369-2-git-send-email-iisaman@netapp.com>
 <1273972993-15369-3-git-send-email-iisaman@netapp.com>
 <1273972993-15369-4-git-send-email-iisaman@netapp.com>
 <1273972993-15369-5-git-send-email-iisaman@netapp.com>
 <1273972993-15369-6-git-send-email-iisaman@netapp.com>
 <1273972993-15369-7-git-send-email-iisaman@netapp.com>
 <1273972993-15369-8-git-send-email-iisaman@netapp.com>
 <1273972993-15369-9-git-send-email-iisaman@netapp.com>
 <1273972993-15369-10-git-send-email-iisaman@netapp.com>
 <1273972993-15369-11-git-send-email-iisaman@netapp.com>
 <1273972993-15369-12-git-send-email-iisaman@netapp.com>
 <1273972993-15369-13-git-send-email-iisaman@netapp.com>
 <1273972993-15369-14-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47588 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754780Ab0ETKam (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 May 2010 06:30:42 -0400
Received: from localhost.localdomain (vpn2ntap-176975.hq.netapp.com [10.58.56.200])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o4KAUQc4022655
	for <linux-nfs@vger.kernel.org>; Thu, 20 May 2010 03:30:41 -0700 (PDT)
In-Reply-To: <1273972993-15369-14-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Store the lseg in each nfs_page.  Note this necessitates adding checks
for compatibility with pre-existing nfs_pages lsegs.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/file.c          |   14 +++++++++-----
 fs/nfs/write.c         |   30 ++++++++++++++++++------------
 include/linux/nfs_fs.h |    8 ++++++--
 3 files changed, 33 insertions(+), 19 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 03a1b3b..1479289 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -416,7 +416,9 @@ static int nfs_write_begin(struct file *file, struct address_space *mapping,
 		file->f_path.dentry->d_name.name,
 		mapping->host->i_ino, len, (long long) pos);
 
-	pnfs_update_layout(mapping->host, NULL, NFS4_MAX_UINT64, 0, IOMODE_RW,
+	pnfs_update_layout(mapping->host,
+			   nfs_file_open_context(file),
+			   NFS4_MAX_UINT64, 0, IOMODE_RW,
 			   (struct pnfs_layout_segment **) fsdata);
 start:
 	/*
@@ -435,7 +437,7 @@ start:
 	}
 	*pagep = page;
 
-	ret = nfs_flush_incompatible(file, page);
+	ret = nfs_flush_incompatible(file, page, *fsdata);
 	if (ret) {
 		unlock_page(page);
 		page_cache_release(page);
@@ -487,7 +489,7 @@ static int nfs_write_end(struct file *file, struct address_space *mapping,
 			zero_user_segment(page, pglen, PAGE_CACHE_SIZE);
 	}
 
-	status = nfs_updatepage(file, page, offset, copied);
+	status = nfs_updatepage(file, page, offset, copied, fsdata);
 
 	unlock_page(page);
 	page_cache_release(page);
@@ -594,6 +596,8 @@ static int nfs_vm_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	/* make sure the cache has finished storing the page */
 	nfs_fscache_wait_on_page_write(NFS_I(dentry->d_inode), page);
 
+	/* XXX Do we want to call pnfs_update_layout here? */
+
 	lock_page(page);
 	mapping = page->mapping;
 	if (mapping != dentry->d_inode->i_mapping)
@@ -604,11 +608,11 @@ static int nfs_vm_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	if (pagelen == 0)
 		goto out_unlock;
 
-	ret = nfs_flush_incompatible(filp, page);
+	ret = nfs_flush_incompatible(filp, page, NULL);
 	if (ret != 0)
 		goto out_unlock;
 
-	ret = nfs_updatepage(filp, page, 0, pagelen);
+	ret = nfs_updatepage(filp, page, 0, pagelen, NULL);
 out_unlock:
 	if (!ret)
 		return VM_FAULT_LOCKED;
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 523ceb4..34a571b 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -570,7 +570,8 @@ static inline int nfs_scan_commit(struct inode *inode, struct list_head *dst, pg
 static struct nfs_page *nfs_try_to_update_request(struct inode *inode,
 		struct page *page,
 		unsigned int offset,
-		unsigned int bytes)
+		unsigned int bytes,
+		struct pnfs_layout_segment *lseg)
 {
 	struct nfs_page *req;
 	unsigned int rqend;
@@ -595,8 +596,8 @@ static struct nfs_page *nfs_try_to_update_request(struct inode *inode,
 		 * Note: nfs_flush_incompatible() will already
 		 * have flushed out requests having wrong owners.
 		 */
-		if (offset > rqend
-		    || end < req->wb_offset)
+		if (offset > rqend || end < req->wb_offset ||
+		    req->wb_lseg != lseg)
 			goto out_flushme;
 
 		if (nfs_set_page_tag_locked(req))
@@ -644,16 +645,17 @@ out_err:
  * already called nfs_flush_incompatible() if necessary.
  */
 static struct nfs_page * nfs_setup_write_request(struct nfs_open_context* ctx,
-		struct page *page, unsigned int offset, unsigned int bytes)
+		struct page *page, unsigned int offset, unsigned int bytes,
+		struct pnfs_layout_segment *lseg)
 {
 	struct inode *inode = page->mapping->host;
 	struct nfs_page	*req;
 	int error;
 
-	req = nfs_try_to_update_request(inode, page, offset, bytes);
+	req = nfs_try_to_update_request(inode, page, offset, bytes, lseg);
 	if (req != NULL)
 		goto out;
-	req = nfs_create_request(ctx, inode, page, offset, bytes, NULL);
+	req = nfs_create_request(ctx, inode, page, offset, bytes, lseg);
 	if (IS_ERR(req))
 		goto out;
 	error = nfs_inode_add_request(inode, req);
@@ -666,11 +668,12 @@ out:
 }
 
 static int nfs_writepage_setup(struct nfs_open_context *ctx, struct page *page,
-		unsigned int offset, unsigned int count)
+			       unsigned int offset, unsigned int count,
+			       struct pnfs_layout_segment *lseg)
 {
 	struct nfs_page	*req;
 
-	req = nfs_setup_write_request(ctx, page, offset, count);
+	req = nfs_setup_write_request(ctx, page, offset, count, lseg);
 	if (IS_ERR(req))
 		return PTR_ERR(req);
 	nfs_mark_request_dirty(req);
@@ -682,7 +685,8 @@ static int nfs_writepage_setup(struct nfs_open_context *ctx, struct page *page,
 	return 0;
 }
 
-int nfs_flush_incompatible(struct file *file, struct page *page)
+int nfs_flush_incompatible(struct file *file, struct page *page,
+			   struct pnfs_layout_segment *lseg)
 {
 	struct nfs_open_context *ctx = nfs_file_open_context(file);
 	struct nfs_page	*req;
@@ -699,7 +703,8 @@ int nfs_flush_incompatible(struct file *file, struct page *page)
 		req = nfs_page_find_request(page);
 		if (req == NULL)
 			return 0;
-		do_flush = req->wb_page != page || req->wb_context != ctx;
+		do_flush = req->wb_page != page || req->wb_context != ctx ||
+			req->wb_lseg != lseg;
 		nfs_release_request(req);
 		if (!do_flush)
 			return 0;
@@ -726,7 +731,8 @@ static int nfs_write_pageuptodate(struct page *page, struct inode *inode)
  * things with a page scheduled for an RPC call (e.g. invalidate it).
  */
 int nfs_updatepage(struct file *file, struct page *page,
-		unsigned int offset, unsigned int count)
+		   unsigned int offset, unsigned int count,
+		   struct pnfs_layout_segment *lseg)
 {
 	struct nfs_open_context *ctx = nfs_file_open_context(file);
 	struct inode	*inode = page->mapping->host;
@@ -751,7 +757,7 @@ int nfs_updatepage(struct file *file, struct page *page,
 		offset = 0;
 	}
 
-	status = nfs_writepage_setup(ctx, page, offset, count);
+	status = nfs_writepage_setup(ctx, page, offset, count, lseg);
 	if (status < 0)
 		nfs_set_pageerror(page);
 
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 98a8dc0..9d41821 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -503,8 +503,12 @@ extern void nfs_unblock_sillyrename(struct dentry *dentry);
 extern int  nfs_congestion_kb;
 extern int  nfs_writepage(struct page *page, struct writeback_control *wbc);
 extern int  nfs_writepages(struct address_space *, struct writeback_control *);
-extern int  nfs_flush_incompatible(struct file *file, struct page *page);
-extern int  nfs_updatepage(struct file *, struct page *, unsigned int, unsigned int);
+struct pnfs_layout_segment;
+extern int  nfs_flush_incompatible(struct file *file, struct page *page,
+				   struct pnfs_layout_segment *lseg);
+extern int  nfs_updatepage(struct file *, struct page *,
+			   unsigned int offset, unsigned int count,
+			   struct pnfs_layout_segment *lseg);
 extern int nfs_writeback_done(struct rpc_task *, struct nfs_write_data *);
 
 /*
-- 
1.6.6.1


From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 3/8] SQUASHME: pnfs_submit: Revert "pnfs: propagate fsdata into nfs_create_request"
Date: Sun,  2 May 2010 21:00:44 -0400
Message-ID: <1272848449-19170-4-git-send-email-iisaman@netapp.com>
References: <1272848449-19170-1-git-send-email-iisaman@netapp.com>
 <1272848449-19170-2-git-send-email-iisaman@netapp.com>
 <1272848449-19170-3-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:31966 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758005Ab0EEDH6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 May 2010 23:07:58 -0400
Received: from localhost.localdomain (makada1-lxp.hq.netapp.com [10.58.60.192] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o4537cgZ024006
	for <linux-nfs@vger.kernel.org>; Tue, 4 May 2010 20:07:41 -0700 (PDT)
In-Reply-To: <1272848449-19170-3-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This reverts commit 4c33e93770316cfa71e2c39965e344a0cc068c65.

fsdata is not used by the file layout
---
 fs/nfs/file.c            |    4 ++--
 fs/nfs/pagelist.c        |    2 +-
 fs/nfs/read.c            |    4 ++--
 fs/nfs/write.c           |   20 +++++++++-----------
 include/linux/nfs_fs.h   |    3 +--
 include/linux/nfs_page.h |    3 +--
 6 files changed, 16 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 4398953..38bc81f 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -487,7 +487,7 @@ static int nfs_write_end(struct file *file, struct address_space *mapping,
 			zero_user_segment(page, pglen, PAGE_CACHE_SIZE);
 	}
 
-	status = nfs_updatepage(file, page, offset, copied, fsdata);
+	status = nfs_updatepage(file, page, offset, copied);
 
 	unlock_page(page);
 	page_cache_release(page);
@@ -608,7 +608,7 @@ static int nfs_vm_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	if (ret != 0)
 		goto out_unlock;
 
-	ret = nfs_updatepage(filp, page, 0, pagelen, NULL);
+	ret = nfs_updatepage(filp, page, 0, pagelen);
 out_unlock:
 	if (!ret)
 		return VM_FAULT_LOCKED;
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 3584b6a..bfc9da7 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -56,7 +56,7 @@ nfs_page_free(struct nfs_page *p)
 struct nfs_page *
 nfs_create_request(struct nfs_open_context *ctx, struct inode *inode,
 		   struct page *page,
-		   unsigned int offset, unsigned int count, void *fsdata)
+		   unsigned int offset, unsigned int count)
 {
 	struct nfs_page		*req;
 
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index fd8bac7..d2cf82e 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -125,7 +125,7 @@ int nfs_readpage_async(struct nfs_open_context *ctx, struct inode *inode,
 	len = nfs_page_length(page);
 	if (len == 0)
 		return nfs_return_empty_page(page);
-	new = nfs_create_request(ctx, inode, page, 0, len, NULL);
+	new = nfs_create_request(ctx, inode, page, 0, len);
 	if (IS_ERR(new)) {
 		unlock_page(page);
 		return PTR_ERR(new);
@@ -606,7 +606,7 @@ readpage_async_filler(void *data, struct page *page)
 	if (len == 0)
 		return nfs_return_empty_page(page);
 
-	new = nfs_create_request(desc->ctx, inode, page, 0, len, NULL);
+	new = nfs_create_request(desc->ctx, inode, page, 0, len);
 	if (IS_ERR(new))
 		goto out_error;
 
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 38e542a..9aa9dae 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -570,8 +570,7 @@ static inline int nfs_scan_commit(struct inode *inode, struct list_head *dst, pg
 static struct nfs_page *nfs_try_to_update_request(struct inode *inode,
 		struct page *page,
 		unsigned int offset,
-		unsigned int bytes,
-		void *fsdata)
+		unsigned int bytes)
 {
 	struct nfs_page *req;
 	unsigned int rqend;
@@ -598,7 +597,7 @@ static struct nfs_page *nfs_try_to_update_request(struct inode *inode,
 		 */
 		if (offset > rqend
 		    || end < req->wb_offset
-		    || pnfs_do_flush(req, fsdata))
+		    || pnfs_do_flush(req, NULL))
 			goto out_flushme;
 
 		if (nfs_set_page_tag_locked(req))
@@ -646,17 +645,16 @@ out_err:
  * already called nfs_flush_incompatible() if necessary.
  */
 static struct nfs_page * nfs_setup_write_request(struct nfs_open_context* ctx,
-		struct page *page, unsigned int offset, unsigned int bytes,
-		void *fsdata)
+		struct page *page, unsigned int offset, unsigned int bytes)
 {
 	struct inode *inode = page->mapping->host;
 	struct nfs_page	*req;
 	int error;
 
-	req = nfs_try_to_update_request(inode, page, offset, bytes, fsdata);
+	req = nfs_try_to_update_request(inode, page, offset, bytes);
 	if (req != NULL)
 		goto out;
-	req = nfs_create_request(ctx, inode, page, offset, bytes, fsdata);
+	req = nfs_create_request(ctx, inode, page, offset, bytes);
 	if (IS_ERR(req))
 		goto out;
 	error = nfs_inode_add_request(inode, req);
@@ -669,11 +667,11 @@ out:
 }
 
 static int nfs_writepage_setup(struct nfs_open_context *ctx, struct page *page,
-		unsigned int offset, unsigned int count, void *fsdata)
+		unsigned int offset, unsigned int count)
 {
 	struct nfs_page	*req;
 
-	req = nfs_setup_write_request(ctx, page, offset, count, fsdata);
+	req = nfs_setup_write_request(ctx, page, offset, count);
 	if (IS_ERR(req))
 		return PTR_ERR(req);
 	nfs_mark_request_dirty(req);
@@ -730,7 +728,7 @@ static int nfs_write_pageuptodate(struct page *page, struct inode *inode)
  * things with a page scheduled for an RPC call (e.g. invalidate it).
  */
 int nfs_updatepage(struct file *file, struct page *page,
-		   unsigned int offset, unsigned int count, void *fsdata)
+		unsigned int offset, unsigned int count)
 {
 	struct nfs_open_context *ctx = nfs_file_open_context(file);
 	struct inode	*inode = page->mapping->host;
@@ -755,7 +753,7 @@ int nfs_updatepage(struct file *file, struct page *page,
 		offset = 0;
 	}
 
-	status = nfs_writepage_setup(ctx, page, offset, count, fsdata);
+	status = nfs_writepage_setup(ctx, page, offset, count);
 	if (status < 0)
 		nfs_set_pageerror(page);
 
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 68b3b5c..98a8dc0 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -504,8 +504,7 @@ extern int  nfs_congestion_kb;
 extern int  nfs_writepage(struct page *page, struct writeback_control *wbc);
 extern int  nfs_writepages(struct address_space *, struct writeback_control *);
 extern int  nfs_flush_incompatible(struct file *file, struct page *page);
-extern int  nfs_updatepage(struct file *, struct page *, unsigned int,
-			   unsigned int, void *);
+extern int  nfs_updatepage(struct file *, struct page *, unsigned int, unsigned int);
 extern int nfs_writeback_done(struct rpc_task *, struct nfs_write_data *);
 
 /*
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index 821f871..df93480 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -75,8 +75,7 @@ extern	struct nfs_page *nfs_create_request(struct nfs_open_context *ctx,
 					    struct inode *inode,
 					    struct page *page,
 					    unsigned int offset,
-					    unsigned int count,
-					    void *fsdata);
+					    unsigned int count);
 extern	void nfs_clear_request(struct nfs_page *req);
 extern	void nfs_release_request(struct nfs_page *req);
 
-- 
1.6.6.1


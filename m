Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52094 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754283Ab0HMVcd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 17:32:33 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 33/50] pnfs_submit: associate layout segmennt with nfs_page
Date: Fri, 13 Aug 2010 17:31:45 -0400
Message-Id: <1281735122-1496-34-git-send-email-andros@netapp.com>
In-Reply-To: <1281735122-1496-33-git-send-email-andros@netapp.com>
References: <1281735122-1496-1-git-send-email-andros@netapp.com>
 <1281735122-1496-2-git-send-email-andros@netapp.com>
 <1281735122-1496-3-git-send-email-andros@netapp.com>
 <1281735122-1496-4-git-send-email-andros@netapp.com>
 <1281735122-1496-5-git-send-email-andros@netapp.com>
 <1281735122-1496-6-git-send-email-andros@netapp.com>
 <1281735122-1496-7-git-send-email-andros@netapp.com>
 <1281735122-1496-8-git-send-email-andros@netapp.com>
 <1281735122-1496-9-git-send-email-andros@netapp.com>
 <1281735122-1496-10-git-send-email-andros@netapp.com>
 <1281735122-1496-11-git-send-email-andros@netapp.com>
 <1281735122-1496-12-git-send-email-andros@netapp.com>
 <1281735122-1496-13-git-send-email-andros@netapp.com>
 <1281735122-1496-14-git-send-email-andros@netapp.com>
 <1281735122-1496-15-git-send-email-andros@netapp.com>
 <1281735122-1496-16-git-send-email-andros@netapp.com>
 <1281735122-1496-17-git-send-email-andros@netapp.com>
 <1281735122-1496-18-git-send-email-andros@netapp.com>
 <1281735122-1496-19-git-send-email-andros@netapp.com>
 <1281735122-1496-20-git-send-email-andros@netapp.com>
 <1281735122-1496-21-git-send-email-andros@netapp.com>
 <1281735122-1496-22-git-send-email-andros@netapp.com>
 <1281735122-1496-23-git-send-email-andros@netapp.com>
 <1281735122-1496-24-git-send-email-andros@netapp.com>
 <1281735122-1496-25-git-send-email-andros@netapp.com>
 <1281735122-1496-26-git-send-email-andros@netapp.com>
 <1281735122-1496-27-git-send-email-andros@netapp.com>
 <1281735122-1496-28-git-send-email-andros@netapp.com>
 <1281735122-1496-29-git-send-email-andros@netapp.com>
 <1281735122-1496-30-git-send-email-andros@netapp.com>
 <1281735122-1496-31-git-send-email-andros@netapp.com>
 <1281735122-1496-32-git-send-email-andros@netapp.com>
 <1281735122-1496-33-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/file.c            |   32 +++++++++++++++++++++++++-------
 fs/nfs/pagelist.c        |   12 ++++++++++--
 fs/nfs/pnfs.c            |   10 ++++++++++
 fs/nfs/read.c            |    8 ++++++--
 fs/nfs/write.c           |   42 ++++++++++++++++++++++++++++++------------
 include/linux/nfs_fs.h   |    8 ++++++--
 include/linux/nfs_page.h |    3 ++-
 7 files changed, 89 insertions(+), 26 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index f036153..d0ed767 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -36,6 +36,7 @@
 #include "internal.h"
 #include "iostat.h"
 #include "fscache.h"
+#include "pnfs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_FILE
 
@@ -389,12 +390,17 @@ static int nfs_write_begin(struct file *file, struct address_space *mapping,
 	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
 	struct page *page;
 	int once_thru = 0;
+	struct pnfs_layout_segment *lseg;
 
 	dfprintk(PAGECACHE, "NFS: write_begin(%s/%s(%ld), %u@%lld)\n",
 		file->f_path.dentry->d_parent->d_name.name,
 		file->f_path.dentry->d_name.name,
 		mapping->host->i_ino, len, (long long) pos);
 
+	pnfs_update_layout(mapping->host,
+			   nfs_file_open_context(file),
+			   IOMODE_RW,
+			   &lseg);
 start:
 	/*
 	 * Prevent starvation issues if someone is doing a consistency
@@ -403,14 +409,16 @@ start:
 	ret = wait_on_bit(&NFS_I(mapping->host)->flags, NFS_INO_FLUSHING,
 			nfs_wait_bit_killable, TASK_KILLABLE);
 	if (ret)
-		return ret;
+		goto out;
 
 	page = grab_cache_page_write_begin(mapping, index, flags);
-	if (!page)
-		return -ENOMEM;
+	if (!page) {
+		ret = -ENOMEM;
+		goto out;
+	}
 	*pagep = page;
 
-	ret = nfs_flush_incompatible(file, page);
+	ret = nfs_flush_incompatible(file, page, lseg);
 	if (ret) {
 		unlock_page(page);
 		page_cache_release(page);
@@ -422,6 +430,12 @@ start:
 		if (!ret)
 			goto start;
 	}
+	*fsdata = lseg;
+ out:
+	if (ret) {
+		put_lseg(lseg);
+		*fsdata = NULL;
+	}
 	return ret;
 }
 
@@ -431,6 +445,7 @@ static int nfs_write_end(struct file *file, struct address_space *mapping,
 {
 	unsigned offset = pos & (PAGE_CACHE_SIZE - 1);
 	int status;
+	struct pnfs_layout_segment *lseg = fsdata;
 
 	dfprintk(PAGECACHE, "NFS: write_end(%s/%s(%ld), %u@%lld)\n",
 		file->f_path.dentry->d_parent->d_name.name,
@@ -457,10 +472,11 @@ static int nfs_write_end(struct file *file, struct address_space *mapping,
 			zero_user_segment(page, pglen, PAGE_CACHE_SIZE);
 	}
 
-	status = nfs_updatepage(file, page, offset, copied);
+	status = nfs_updatepage(file, page, offset, copied, lseg);
 
 	unlock_page(page);
 	page_cache_release(page);
+	put_lseg(lseg);
 
 	if (status < 0)
 		return status;
@@ -571,6 +587,8 @@ static int nfs_vm_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	/* make sure the cache has finished storing the page */
 	nfs_fscache_wait_on_page_write(NFS_I(dentry->d_inode), page);
 
+	/* XXX Do we want to call pnfs_update_layout here? */
+
 	lock_page(page);
 	mapping = page->mapping;
 	if (mapping != dentry->d_inode->i_mapping)
@@ -581,11 +599,11 @@ static int nfs_vm_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
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
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 41b3966..a014814 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -20,6 +20,7 @@
 #include <linux/nfs_mount.h>
 
 #include "internal.h"
+#include "pnfs.h"
 
 static struct kmem_cache *nfs_page_cachep;
 
@@ -56,7 +57,8 @@ nfs_page_free(struct nfs_page *p)
 struct nfs_page *
 nfs_create_request(struct nfs_open_context *ctx, struct inode *inode,
 		   struct page *page,
-		   unsigned int offset, unsigned int count)
+		   unsigned int offset, unsigned int count,
+		   struct pnfs_layout_segment *lseg)
 {
 	struct nfs_page		*req;
 
@@ -81,6 +83,9 @@ nfs_create_request(struct nfs_open_context *ctx, struct inode *inode,
 	req->wb_context = get_nfs_open_context(ctx);
 	req->wb_lock_context = nfs_get_lock_context(ctx);
 	kref_init(&req->wb_kref);
+	req->wb_lseg    = lseg;
+	if (lseg)
+		get_lseg(lseg);
 	return req;
 }
 
@@ -156,9 +161,12 @@ void nfs_clear_request(struct nfs_page *req)
 		put_nfs_open_context(ctx);
 		req->wb_context = NULL;
 	}
+	if (req->wb_lseg != NULL) {
+		put_lseg(req->wb_lseg);
+		req->wb_lseg = NULL;
+	}
 }
 
-
 /**
  * nfs_release_request - Release the count on an NFS read/write request
  * @req: request to release
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index e25e5d9..3ff193b 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1234,6 +1234,16 @@ pnfs_pageio_init_write(struct nfs_pageio_descriptor *pgio, struct inode *inode)
 	pnfs_set_pg_test(inode, pgio);
 }
 
+static void _pnfs_clear_lseg_from_pages(struct list_head *head)
+{
+	struct nfs_page *req;
+
+	list_for_each_entry(req, head, wb_list) {
+		put_lseg(req->wb_lseg);
+		req->wb_lseg = NULL;
+	}
+}
+
 /*
  * Set up the argument/result storage required for the RPC call.
  */
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 99d95ec..324b577 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -118,11 +118,14 @@ int nfs_readpage_async(struct nfs_open_context *ctx, struct inode *inode,
 	LIST_HEAD(one_request);
 	struct nfs_page	*new;
 	unsigned int len;
+	struct pnfs_layout_segment *lseg;
 
 	len = nfs_page_length(page);
 	if (len == 0)
 		return nfs_return_empty_page(page);
-	new = nfs_create_request(ctx, inode, page, 0, len);
+	pnfs_update_layout(inode, ctx, IOMODE_READ, &lseg);
+	new = nfs_create_request(ctx, inode, page, 0, len, lseg);
+	put_lseg(lseg);
 	if (IS_ERR(new)) {
 		unlock_page(page);
 		return PTR_ERR(new);
@@ -570,7 +573,8 @@ readpage_async_filler(void *data, struct page *page)
 	if (len == 0)
 		return nfs_return_empty_page(page);
 
-	new = nfs_create_request(desc->ctx, inode, page, 0, len);
+	new = nfs_create_request(desc->ctx, inode, page, 0, len,
+				 desc->pgio->pg_lseg);
 	if (IS_ERR(new))
 		goto out_error;
 
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 0667eda..a1f28c5 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -430,6 +430,17 @@ static void nfs_inode_remove_request(struct nfs_page *req)
 	nfs_clear_request(req);
 	nfs_release_request(req);
 }
+static void
+nfs_mark_request_nopnfs(struct nfs_page *req)
+{
+	struct pnfs_layout_segment *lseg = req->wb_lseg;
+
+	if (req->wb_lseg == NULL)
+		return;
+	req->wb_lseg = NULL;
+	put_lseg(lseg);
+	dprintk(" retry through MDS\n");
+}
 
 static void
 nfs_mark_request_dirty(struct nfs_page *req)
@@ -572,7 +583,8 @@ static inline int nfs_scan_commit(struct inode *inode, struct list_head *dst, pg
 static struct nfs_page *nfs_try_to_update_request(struct inode *inode,
 		struct page *page,
 		unsigned int offset,
-		unsigned int bytes)
+		unsigned int bytes,
+		struct pnfs_layout_segment *lseg)
 {
 	struct nfs_page *req;
 	unsigned int rqend;
@@ -597,8 +609,8 @@ static struct nfs_page *nfs_try_to_update_request(struct inode *inode,
 		 * Note: nfs_flush_incompatible() will already
 		 * have flushed out requests having wrong owners.
 		 */
-		if (offset > rqend
-		    || end < req->wb_offset)
+		if (offset > rqend || end < req->wb_offset ||
+		    req->wb_lseg != lseg)
 			goto out_flushme;
 
 		if (nfs_set_page_tag_locked(req))
@@ -646,16 +658,17 @@ out_err:
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
-	req = nfs_create_request(ctx, inode, page, offset, bytes);
+	req = nfs_create_request(ctx, inode, page, offset, bytes, lseg);
 	if (IS_ERR(req))
 		goto out;
 	error = nfs_inode_add_request(inode, req);
@@ -668,11 +681,12 @@ out:
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
@@ -684,7 +698,8 @@ static int nfs_writepage_setup(struct nfs_open_context *ctx, struct page *page,
 	return 0;
 }
 
-int nfs_flush_incompatible(struct file *file, struct page *page)
+int nfs_flush_incompatible(struct file *file, struct page *page,
+			   struct pnfs_layout_segment *lseg)
 {
 	struct nfs_open_context *ctx = nfs_file_open_context(file);
 	struct nfs_page	*req;
@@ -703,7 +718,8 @@ int nfs_flush_incompatible(struct file *file, struct page *page)
 			return 0;
 		do_flush = req->wb_page != page || req->wb_context != ctx ||
 			req->wb_lock_context->lockowner != current->files ||
-			req->wb_lock_context->pid != current->tgid;
+			req->wb_lock_context->pid != current->tgid ||
+			req->wb_lseg != lseg;
 		nfs_release_request(req);
 		if (!do_flush)
 			return 0;
@@ -730,7 +746,8 @@ static int nfs_write_pageuptodate(struct page *page, struct inode *inode)
  * things with a page scheduled for an RPC call (e.g. invalidate it).
  */
 int nfs_updatepage(struct file *file, struct page *page,
-		unsigned int offset, unsigned int count)
+		   unsigned int offset, unsigned int count,
+		   struct pnfs_layout_segment *lseg)
 {
 	struct nfs_open_context *ctx = nfs_file_open_context(file);
 	struct inode	*inode = page->mapping->host;
@@ -755,7 +772,7 @@ int nfs_updatepage(struct file *file, struct page *page,
 		offset = 0;
 	}
 
-	status = nfs_writepage_setup(ctx, page, offset, count);
+	status = nfs_writepage_setup(ctx, page, offset, count, lseg);
 	if (status < 0)
 		nfs_set_pageerror(page);
 
@@ -874,6 +891,7 @@ static void nfs_redirty_request(struct nfs_page *req)
 {
 	struct page *page = req->wb_page;
 
+	nfs_mark_request_nopnfs(req);
 	nfs_mark_request_dirty(req);
 	nfs_clear_page_tag_locked(req);
 	nfs_end_page_writeback(page);
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 7202c05..6f67aec 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -517,8 +517,12 @@ extern void nfs_unblock_sillyrename(struct dentry *dentry);
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
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index d7deec9..ce0a1a5 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -76,7 +76,8 @@ extern	struct nfs_page *nfs_create_request(struct nfs_open_context *ctx,
 					    struct inode *inode,
 					    struct page *page,
 					    unsigned int offset,
-					    unsigned int count);
+					    unsigned int count,
+					    struct pnfs_layout_segment *lseg);
 extern	void nfs_clear_request(struct nfs_page *req);
 extern	void nfs_release_request(struct nfs_page *req);
 
-- 
1.6.2.5


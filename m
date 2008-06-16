From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 2/2] NFS: Allow redirtying of a completed unstable write.
Date: Mon, 16 Jun 2008 15:23:48 -0400
Message-ID: <20080616192348.20513.47394.stgit@localhost.localdomain>
References: <20080616192348.20513.72423.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:4984 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752712AbYFPTej (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Jun 2008 15:34:39 -0400
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m5GJYWoF005004
	for <linux-nfs@vger.kernel.org>; Mon, 16 Jun 2008 12:34:38 -0700 (PDT)
In-Reply-To: <20080616192348.20513.72423.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, if an unstable write completes, we cannot redirty the page in
order to reflect a new change in the page data until after we've sent a
COMMIT request.

This patch allows a page rewrite to proceed without the unnecessary COMMIT
step, putting it immediately back onto the dirty page list, undoing the
VM unstable write accounting, and removing the NFS_PAGE_TAG_COMMIT tag from
the NFS radix tree.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/write.c           |   67 +++++++++++++++++++++++-----------------------
 include/linux/nfs_page.h |    9 ++++--
 2 files changed, 39 insertions(+), 37 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index a675dc9..63cfe3f 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -270,12 +270,9 @@ static int nfs_page_async_flush(struct nfs_pageio_descriptor *pgio,
 			return ret;
 		spin_lock(&inode->i_lock);
 	}
-	if (test_bit(PG_NEED_COMMIT, &req->wb_flags)) {
-		/* This request is marked for commit */
+	if (test_bit(PG_CLEAN, &req->wb_flags)) {
 		spin_unlock(&inode->i_lock);
-		nfs_clear_page_tag_locked(req);
-		nfs_pageio_complete(pgio);
-		return 0;
+		BUG();
 	}
 	if (nfs_set_page_writeback(page) != 0) {
 		spin_unlock(&inode->i_lock);
@@ -407,19 +404,6 @@ nfs_mark_request_dirty(struct nfs_page *req)
 	__set_page_dirty_nobuffers(req->wb_page);
 }
 
-/*
- * Check if a request is dirty
- */
-static inline int
-nfs_dirty_request(struct nfs_page *req)
-{
-	struct page *page = req->wb_page;
-
-	if (page == NULL || test_bit(PG_NEED_COMMIT, &req->wb_flags))
-		return 0;
-	return !PageWriteback(page);
-}
-
 #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 /*
  * Add a request to the inode's commit list.
@@ -432,7 +416,7 @@ nfs_mark_request_commit(struct nfs_page *req)
 
 	spin_lock(&inode->i_lock);
 	nfsi->ncommit++;
-	set_bit(PG_NEED_COMMIT, &(req)->wb_flags);
+	set_bit(PG_CLEAN, &(req)->wb_flags);
 	radix_tree_tag_set(&nfsi->nfs_page_tree,
 			req->wb_index,
 			NFS_PAGE_TAG_COMMIT);
@@ -442,6 +426,19 @@ nfs_mark_request_commit(struct nfs_page *req)
 	__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
 }
 
+static int
+nfs_clear_request_commit(struct nfs_page *req)
+{
+	struct page *page = req->wb_page;
+
+	if (test_and_clear_bit(PG_CLEAN, &(req)->wb_flags)) {
+		dec_zone_page_state(page, NR_UNSTABLE_NFS);
+		dec_bdi_stat(page->mapping->backing_dev_info, BDI_RECLAIMABLE);
+		return 1;
+	}
+	return 0;
+}
+
 static inline
 int nfs_write_need_commit(struct nfs_write_data *data)
 {
@@ -451,7 +448,7 @@ int nfs_write_need_commit(struct nfs_write_data *data)
 static inline
 int nfs_reschedule_unstable_write(struct nfs_page *req)
 {
-	if (test_bit(PG_NEED_COMMIT, &req->wb_flags)) {
+	if (test_and_clear_bit(PG_NEED_COMMIT, &req->wb_flags)) {
 		nfs_mark_request_commit(req);
 		return 1;
 	}
@@ -467,6 +464,12 @@ nfs_mark_request_commit(struct nfs_page *req)
 {
 }
 
+static inline int
+nfs_clear_request_commit(struct nfs_page *req)
+{
+	return 0;
+}
+
 static inline
 int nfs_write_need_commit(struct nfs_write_data *data)
 {
@@ -524,11 +527,8 @@ static void nfs_cancel_commit_list(struct list_head *head)
 
 	while(!list_empty(head)) {
 		req = nfs_list_entry(head->next);
-		dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
-		dec_bdi_stat(req->wb_page->mapping->backing_dev_info,
-				BDI_RECLAIMABLE);
 		nfs_list_remove_request(req);
-		clear_bit(PG_NEED_COMMIT, &(req)->wb_flags);
+		nfs_clear_request_commit(req);
 		nfs_inode_remove_request(req);
 		nfs_unlock_request(req);
 	}
@@ -565,7 +565,7 @@ static inline int nfs_scan_commit(struct inode *inode, struct list_head *dst, pg
 }
 #endif
 
-static int nfs_try_to_update_request(struct nfs_page *req,
+static int nfs_try_to_update_request(struct inode *inode, struct nfs_page *req,
 		unsigned int offset,
 		unsigned int end)
 {
@@ -579,7 +579,6 @@ static int nfs_try_to_update_request(struct nfs_page *req,
 	 * wait on the conflicting request.
 	 */
 	if (req->wb_page == NULL
-	    || !nfs_dirty_request(req)
 	    || offset > rqend
 	    || end < req->wb_offset)
 		return -EBUSY;
@@ -587,6 +586,10 @@ static int nfs_try_to_update_request(struct nfs_page *req,
 	if (!nfs_set_page_tag_locked(req))
 		return -EAGAIN;
 
+	if (nfs_clear_request_commit(req))
+		radix_tree_tag_clear(&NFS_I(inode)->nfs_page_tree,
+				req->wb_index, NFS_PAGE_TAG_COMMIT);
+
 	/* Okay, the request matches. Update the region */
 	if (offset < req->wb_offset) {
 		req->wb_offset = offset;
@@ -623,7 +626,7 @@ static struct nfs_page * nfs_setup_write_request(struct nfs_open_context* ctx,
 		spin_lock(&inode->i_lock);
 		req = nfs_page_find_request_locked(page);
 		if (req) {
-			error = nfs_try_to_update_request(req, offset, end);
+			error = nfs_try_to_update_request(inode, req, offset, end);
 			spin_unlock(&inode->i_lock);
 			if (error == 0)
 				break;
@@ -680,8 +683,7 @@ int nfs_flush_incompatible(struct file *file, struct page *page)
 		req = nfs_page_find_request(page);
 		if (req == NULL)
 			return 0;
-		do_flush = req->wb_page != page || req->wb_context != ctx
-			|| !nfs_dirty_request(req);
+		do_flush = req->wb_page != page || req->wb_context != ctx;
 		nfs_release_request(req);
 		if (!do_flush)
 			return 0;
@@ -1286,10 +1288,7 @@ static void nfs_commit_release(void *calldata)
 	while (!list_empty(&data->pages)) {
 		req = nfs_list_entry(data->pages.next);
 		nfs_list_remove_request(req);
-		clear_bit(PG_NEED_COMMIT, &(req)->wb_flags);
-		dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
-		dec_bdi_stat(req->wb_page->mapping->backing_dev_info,
-				BDI_RECLAIMABLE);
+		nfs_clear_request_commit(req);
 
 		dprintk("NFS:       commit (%s/%lld %d@%lld)",
 			req->wb_context->path.dentry->d_inode->i_sb->s_id,
@@ -1465,7 +1464,7 @@ int nfs_wb_page_cancel(struct inode *inode, struct page *page)
 		req = nfs_page_find_request(page);
 		if (req == NULL)
 			goto out;
-		if (test_bit(PG_NEED_COMMIT, &req->wb_flags)) {
+		if (test_bit(PG_CLEAN, &req->wb_flags)) {
 			nfs_release_request(req);
 			break;
 		}
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index a1676e1..3c60685 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -27,9 +27,12 @@
 /*
  * Valid flags for a dirty buffer
  */
-#define PG_BUSY			0
-#define PG_NEED_COMMIT		1
-#define PG_NEED_RESCHED		2
+enum {
+	PG_BUSY = 0,
+	PG_CLEAN,
+	PG_NEED_COMMIT,
+	PG_NEED_RESCHED,
+};
 
 struct nfs_inode;
 struct nfs_page {


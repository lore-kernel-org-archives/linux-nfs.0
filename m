Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:13231 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750888AbcCHV4W (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Mar 2016 16:56:22 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <linux-nfs@vger.kernel.org>, <Trond.Myklebust@primarydata.com>,
        <bfields@fieldses.org>, <hch@infradead.org>
Subject: [PATCH v3 1/3] NFS: Add nfs_commit_file()
Date: Tue, 8 Mar 2016 16:55:55 -0500
Message-ID: <1457474158-16050-2-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1457474158-16050-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1457474158-16050-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Copy will use this to set up a commit request for a generic range.  I
don't want to allocate a new pagecache entry for the file, so I needed
to change parts of the commit path to handle requests with a null
wb_page.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
Checking for wb_page everywhere feels like a hack, but I don't really see
any other way of doing this.  Suggestions welcome!
---
 fs/nfs/internal.h |  1 +
 fs/nfs/pagelist.c |  6 ++++--
 fs/nfs/write.c    | 41 +++++++++++++++++++++++++++++++++++++----
 3 files changed, 42 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 9a547aa..7a3778c 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -477,6 +477,7 @@ void nfs_mark_request_commit(struct nfs_page *req,
 			     u32 ds_commit_idx);
 int nfs_write_need_commit(struct nfs_pgio_header *);
 void nfs_writeback_update_inode(struct nfs_pgio_header *hdr);
+int nfs_commit_file(struct file *file, struct nfs_write_verifier *verf);
 int nfs_generic_commit_list(struct inode *inode, struct list_head *head,
 			    int how, struct nfs_commit_info *cinfo);
 void nfs_retry_commit(struct list_head *page_list,
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 8ce4f61..c3c3555 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -341,8 +341,10 @@ nfs_create_request(struct nfs_open_context *ctx, struct page *page,
 	 * long write-back delay. This will be adjusted in
 	 * update_nfs_request below if the region is not locked. */
 	req->wb_page    = page;
-	req->wb_index	= page_file_index(page);
-	page_cache_get(page);
+	if (page) {
+		req->wb_index = page_file_index(page);
+		page_cache_get(page);
+	}
 	req->wb_offset  = offset;
 	req->wb_pgbase	= offset;
 	req->wb_bytes   = count;
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 5754835..a82765b9 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -737,7 +737,7 @@ static void nfs_inode_remove_request(struct nfs_page *req)
 		head = req->wb_head;
 
 		spin_lock(&inode->i_lock);
-		if (likely(!PageSwapCache(head->wb_page))) {
+		if (likely(head->wb_page && !PageSwapCache(head->wb_page))) {
 			set_page_private(head->wb_page, 0);
 			ClearPagePrivate(head->wb_page);
 			smp_mb__after_atomic();
@@ -759,7 +759,8 @@ static void nfs_inode_remove_request(struct nfs_page *req)
 static void
 nfs_mark_request_dirty(struct nfs_page *req)
 {
-	__set_page_dirty_nobuffers(req->wb_page);
+	if (req->wb_page)
+		__set_page_dirty_nobuffers(req->wb_page);
 }
 
 /*
@@ -835,7 +836,8 @@ nfs_request_add_commit_list(struct nfs_page *req, struct nfs_commit_info *cinfo)
 	spin_lock(cinfo->lock);
 	nfs_request_add_commit_list_locked(req, &cinfo->mds->list, cinfo);
 	spin_unlock(cinfo->lock);
-	nfs_mark_page_unstable(req->wb_page, cinfo);
+	if (req->wb_page)
+		nfs_mark_page_unstable(req->wb_page, cinfo);
 }
 EXPORT_SYMBOL_GPL(nfs_request_add_commit_list);
 
@@ -1724,6 +1726,36 @@ nfs_commit_list(struct inode *inode, struct list_head *head, int how,
 	return -ENOMEM;
 }
 
+int nfs_commit_file(struct file *file, struct nfs_write_verifier *verf)
+{
+	struct inode *inode = file_inode(file);
+	struct nfs_open_context *open;
+	struct nfs_commit_info cinfo;
+	struct nfs_page *req;
+	int ret;
+
+	open = get_nfs_open_context(nfs_file_open_context(file));
+	req  = nfs_create_request(open, NULL, NULL, 0, i_size_read(inode));
+	if (!req) {
+		ret = -ENOMEM;
+		goto out_put;
+	}
+
+	nfs_init_cinfo_from_inode(&cinfo, inode);
+
+	memcpy(&req->wb_verf, verf, sizeof(struct nfs_write_verifier));
+	nfs_request_add_commit_list(req, &cinfo);
+	ret = nfs_commit_inode(inode, FLUSH_SYNC);
+	if (ret > 0)
+		ret = 0;
+
+	nfs_free_request(req);
+out_put:
+	put_nfs_open_context(open);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(nfs_commit_file);
+
 /*
  * COMMIT call returned
  */
@@ -1748,7 +1780,8 @@ static void nfs_commit_release_pages(struct nfs_commit_data *data)
 	while (!list_empty(&data->pages)) {
 		req = nfs_list_entry(data->pages.next);
 		nfs_list_remove_request(req);
-		nfs_clear_page_commit(req->wb_page);
+		if (req->wb_page)
+			nfs_clear_page_commit(req->wb_page);
 
 		dprintk("NFS:       commit (%s/%llu %d@%lld)",
 			req->wb_context->dentry->d_sb->s_id,
-- 
2.7.2


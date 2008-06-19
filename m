From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 1/2] NFS: Clean up nfs_update_request()
Date: Thu, 19 Jun 2008 17:22:29 -0400
Message-ID: <1213910549.7120.24.camel@localhost>
References: <20080616192348.20513.72423.stgit@localhost.localdomain>
	 <20080616192348.20513.3284.stgit@localhost.localdomain>
	 <B9BACB96-E0DB-4C6D-B55D-A50CC6F94474@oracle.com>
	 <1213739807.7288.86.camel@localhost>  <485972AE.9030405@oracle.com>
	 <1213822899.25182.21.camel@localhost>  <485986BE.1030401@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: chuck.lever@oracle.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:9400 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751754AbYFSVXI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Jun 2008 17:23:08 -0400
In-Reply-To: <485986BE.1030401@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2008-06-18 at 18:05 -0400, Chuck Lever wrote:
> What I'm trying to say is the new function with the EAGAIN return code 
> is spaghetti.  Don't get me wrong, I like Italian food.

How about this version, then?

---------------------------------------------
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Fri, 13 Jun 2008 12:12:32 -0400
NFS: Clean up nfs_update_request()

Simplify the loop in nfs_update_request by moving into a separate function
the code that attempts to update an existing cached NFS write.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/write.c |  190 +++++++++++++++++++++++++++-----------------------------
 1 files changed, 93 insertions(+), 97 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 21d8a48..48f9605 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -34,9 +34,6 @@
 /*
  * Local function declarations
  */
-static struct nfs_page * nfs_update_request(struct nfs_open_context*,
-					    struct page *,
-					    unsigned int, unsigned int);
 static void nfs_pageio_init_write(struct nfs_pageio_descriptor *desc,
 				  struct inode *inode, int ioflags);
 static void nfs_redirty_request(struct nfs_page *req);
@@ -169,30 +166,6 @@ static void nfs_mark_uptodate(struct page *page, unsigned int base, unsigned int
 	SetPageUptodate(page);
 }
 
-static int nfs_writepage_setup(struct nfs_open_context *ctx, struct page *page,
-		unsigned int offset, unsigned int count)
-{
-	struct nfs_page	*req;
-	int ret;
-
-	for (;;) {
-		req = nfs_update_request(ctx, page, offset, count);
-		if (!IS_ERR(req))
-			break;
-		ret = PTR_ERR(req);
-		if (ret != -EBUSY)
-			return ret;
-		ret = nfs_wb_page(page->mapping->host, page);
-		if (ret != 0)
-			return ret;
-	}
-	/* Update file length */
-	nfs_grow_file(page, offset, count);
-	nfs_mark_uptodate(page, req->wb_pgbase, req->wb_bytes);
-	nfs_clear_page_tag_locked(req);
-	return 0;
-}
-
 static int wb_priority(struct writeback_control *wbc)
 {
 	if (wbc->for_reclaim)
@@ -361,6 +334,10 @@ static void nfs_inode_add_request(struct inode *inode, struct nfs_page *req)
 	struct nfs_inode *nfsi = NFS_I(inode);
 	int error;
 
+	/* Lock the request! */
+	nfs_lock_request_dontget(req);
+
+	spin_lock(&inode->i_lock);
 	error = radix_tree_insert(&nfsi->nfs_page_tree, req->wb_index, req);
 	BUG_ON(error);
 	if (!nfsi->npages) {
@@ -374,6 +351,7 @@ static void nfs_inode_add_request(struct inode *inode, struct nfs_page *req)
 	kref_get(&req->wb_kref);
 	radix_tree_tag_set(&nfsi->nfs_page_tree, req->wb_index,
 				NFS_PAGE_TAG_LOCKED);
+	spin_unlock(&inode->i_lock);
 }
 
 /*
@@ -565,101 +543,119 @@ static inline int nfs_scan_commit(struct inode *inode, struct list_head *dst, pg
 #endif
 
 /*
- * Try to update any existing write request, or create one if there is none.
- * In order to match, the request's credentials must match those of
- * the calling process.
+ * Search for an existing write request, and attempt to update
+ * it to reflect a new dirty region on a given page.
  *
- * Note: Should always be called with the Page Lock held!
+ * If the attempt fails, then the existing request is flushed out
+ * to disk.
  */
-static struct nfs_page * nfs_update_request(struct nfs_open_context* ctx,
-		struct page *page, unsigned int offset, unsigned int bytes)
+static struct nfs_page *nfs_try_to_update_request(struct inode *inode,
+		struct page *page,
+		unsigned int offset,
+		unsigned int bytes)
 {
-	struct address_space *mapping = page->mapping;
-	struct inode *inode = mapping->host;
-	struct nfs_page		*req, *new = NULL;
-	pgoff_t		rqend, end;
+	struct nfs_page *req;
+	unsigned int rqend;
+	unsigned int end;
+	int error;
+
+	if (!PagePrivate(page))
+		return NULL;
 
 	end = offset + bytes;
+	spin_lock(&inode->i_lock);
 
 	for (;;) {
-		/* Loop over all inode entries and see if we find
-		 * A request for the page we wish to update
-		 */
-		spin_lock(&inode->i_lock);
 		req = nfs_page_find_request_locked(page);
-		if (req) {
-			if (!nfs_set_page_tag_locked(req)) {
-				int error;
-
-				spin_unlock(&inode->i_lock);
-				error = nfs_wait_on_request(req);
-				nfs_release_request(req);
-				if (error < 0) {
-					if (new) {
-						radix_tree_preload_end();
-						nfs_release_request(new);
-					}
-					return ERR_PTR(error);
-				}
-				continue;
-			}
-			spin_unlock(&inode->i_lock);
-			if (new) {
-				radix_tree_preload_end();
-				nfs_release_request(new);
-			}
-			break;
-		}
+		if (req == NULL)
+			goto out_unlock;
 
-		if (new) {
-			nfs_lock_request_dontget(new);
-			nfs_inode_add_request(inode, new);
-			spin_unlock(&inode->i_lock);
-			radix_tree_preload_end();
-			req = new;
-			goto out;
-		}
-		spin_unlock(&inode->i_lock);
+		rqend = req->wb_offset + req->wb_bytes;
+		/*
+		 * Tell the caller to flush out the request if
+		 * the offsets are non-contiguous.
+		 */
+		if (!nfs_dirty_request(req)
+		    || offset > rqend
+		    || end < req->wb_offset)
+			goto out_flushme;
 
-		new = nfs_create_request(ctx, inode, page, offset, bytes);
-		if (IS_ERR(new))
-			return new;
-		if (radix_tree_preload(GFP_NOFS)) {
-			nfs_release_request(new);
-			return ERR_PTR(-ENOMEM);
-		}
-	}
+		if (nfs_set_page_tag_locked(req))
+			break;
 
-	/* We have a request for our page.
-	 * If the creds don't match, or the
-	 * page addresses don't match,
-	 * tell the caller to wait on the conflicting
-	 * request.
-	 */
-	rqend = req->wb_offset + req->wb_bytes;
-	if (req->wb_context != ctx
-	    || req->wb_page != page
-	    || !nfs_dirty_request(req)
-	    || offset > rqend || end < req->wb_offset) {
-		nfs_clear_page_tag_locked(req);
-		return ERR_PTR(-EBUSY);
+		/* The request is locked, so wait and then retry */
+		spin_unlock(&inode->i_lock);
+		error = nfs_wait_on_request(req);
+		nfs_release_request(req);
+		if (error != 0)
+			goto out_err;
+		spin_lock(&inode->i_lock);
 	}
 
 	/* Okay, the request matches. Update the region */
 	if (offset < req->wb_offset) {
 		req->wb_offset = offset;
 		req->wb_pgbase = offset;
-		req->wb_bytes = max(end, rqend) - req->wb_offset;
-		goto out;
 	}
-
 	if (end > rqend)
 		req->wb_bytes = end - req->wb_offset;
+	else
+		req->wb_bytes = rqend - req->wb_offset;
+out_unlock:
+	spin_unlock(&inode->i_lock);
+	return req;
+out_flushme:
+	spin_unlock(&inode->i_lock);
+	nfs_release_request(req);
+	error = nfs_wb_page(inode, page);
+out_err:
+	return ERR_PTR(error);
+}
+
+/*
+ * Try to update an existing write request, or create one if there is none.
+ *
+ * Note: Should always be called with the Page Lock held to prevent races
+ * if we have to add a new request. Also assumes that the caller has
+ * already called nfs_flush_incompatible() if necessary.
+ */
+static struct nfs_page * nfs_setup_write_request(struct nfs_open_context* ctx,
+		struct page *page, unsigned int offset, unsigned int bytes)
+{
+	struct inode *inode = page->mapping->host;
+	struct nfs_page	*req;
 
+	req = nfs_try_to_update_request(inode, page, offset, bytes);
+	if (req != NULL)
+		goto out;
+	req = nfs_create_request(ctx, inode, page, offset, bytes);
+	if (IS_ERR(req))
+		goto out;
+	if (radix_tree_preload(GFP_NOFS)) {
+		nfs_release_request(req);
+		return ERR_PTR(-ENOMEM);
+	}
+	nfs_inode_add_request(inode, req);
+	radix_tree_preload_end();
 out:
 	return req;
 }
 
+static int nfs_writepage_setup(struct nfs_open_context *ctx, struct page *page,
+		unsigned int offset, unsigned int count)
+{
+	struct nfs_page	*req;
+
+	req = nfs_setup_write_request(ctx, page, offset, count);
+	if (IS_ERR(req))
+		return PTR_ERR(req);
+	/* Update file length */
+	nfs_grow_file(page, offset, count);
+	nfs_mark_uptodate(page, req->wb_pgbase, req->wb_bytes);
+	nfs_clear_page_tag_locked(req);
+	return 0;
+}
+
 int nfs_flush_incompatible(struct file *file, struct page *page)
 {
 	struct nfs_open_context *ctx = nfs_file_open_context(file);


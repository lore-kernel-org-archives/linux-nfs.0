From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 7/8] NFS: Fix a race when doing NFS write coalescing
Date: Wed, 11 Apr 2007 22:37:45 -0400
Message-ID: <20070412023745.15270.73696.stgit@heimdal.trondhjem.org>
References: <20070412023714.15270.33322.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HbpC2-0005m4-7x
	for nfs@lists.sourceforge.net; Wed, 11 Apr 2007 19:37:50 -0700
Received: from c-69-242-210-120.hsd1.mi.comcast.net ([69.242.210.120]
	helo=heimdal.trondhjem.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HbpC3-0002XN-5E
	for nfs@lists.sourceforge.net; Wed, 11 Apr 2007 19:37:52 -0700
In-Reply-To: <20070412023714.15270.33322.stgit@heimdal.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Currently we do write coalescing in a very inefficient manner: one pass in
generic_writepages() in order to lock the pages for writing, then one pass
in nfs_flush_mapping() and/or nfs_sync_mapping_wait() in order to gather
the locked pages for coalescing into RPC requests of size "wsize".

In fact, it turns out there is actually a deadlock possible here since we
only start I/O on the second pass. If the user signals the process while
we're in nfs_sync_mapping_wait(), for instance, then we may exit before
starting I/O on all the requests that have been queued up.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/pagelist.c         |   91 -----------------------
 fs/nfs/write.c            |  180 +++++++++++++++------------------------------
 include/linux/nfs_page.h  |    8 --
 include/linux/writeback.h |    2 +
 4 files changed, 64 insertions(+), 217 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 094537d..ce1d5a4 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -354,25 +354,6 @@ int nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
 }
 
 /**
- * nfs_pageio_add_list - Split coalesced requests out from a list.
- * @desc: destination io descriptor
- * @head: source list
- *
- * Moves a maximum of 'nmax' elements from one list to another.
- * The elements are checked to ensure that they form a contiguous set
- * of pages, and that the RPC credentials are the same.
- */
-void nfs_pageio_add_list(struct nfs_pageio_descriptor *desc,
-			 struct list_head *head)
-{
-	while (!list_empty(head)) {
-		struct nfs_page *req = nfs_list_entry(head->next);
-		if (!nfs_pageio_add_request(desc, req))
-			break;
-	}
-}
-
-/**
  * nfs_pageio_complete - Complete I/O on an nfs_pageio_descriptor
  * @desc: pointer to io descriptor
  */
@@ -383,78 +364,6 @@ void nfs_pageio_complete(struct nfs_pageio_descriptor *desc)
 
 #define NFS_SCAN_MAXENTRIES 16
 /**
- * nfs_scan_dirty - Scan the radix tree for dirty requests
- * @mapping: pointer to address space
- * @wbc: writeback_control structure
- * @dst: Destination list
- *
- * Moves elements from one of the inode request lists.
- * If the number of requests is set to 0, the entire address_space
- * starting at index idx_start, is scanned.
- * The requests are *not* checked to ensure that they form a contiguous set.
- * You must be holding the inode's req_lock when calling this function
- */
-long nfs_scan_dirty(struct address_space *mapping,
-			struct writeback_control *wbc,
-			struct list_head *dst)
-{
-	struct nfs_inode *nfsi = NFS_I(mapping->host);
-	struct nfs_page *pgvec[NFS_SCAN_MAXENTRIES];
-	struct nfs_page *req;
-	pgoff_t idx_start, idx_end;
-	long res = 0;
-	int found, i;
-
-	if (nfsi->ndirty == 0)
-		return 0;
-	if (wbc->range_cyclic) {
-		idx_start = 0;
-		idx_end = ULONG_MAX;
-	} else if (wbc->range_end == 0) {
-		idx_start = wbc->range_start >> PAGE_CACHE_SHIFT;
-		idx_end = ULONG_MAX;
-	} else {
-		idx_start = wbc->range_start >> PAGE_CACHE_SHIFT;
-		idx_end = wbc->range_end >> PAGE_CACHE_SHIFT;
-	}
-
-	for (;;) {
-		unsigned int toscan = NFS_SCAN_MAXENTRIES;
-
-		found = radix_tree_gang_lookup_tag(&nfsi->nfs_page_tree,
-				(void **)&pgvec[0], idx_start, toscan,
-				NFS_PAGE_TAG_DIRTY);
-
-		/* Did we make progress? */
-		if (found <= 0)
-			break;
-
-		for (i = 0; i < found; i++) {
-			req = pgvec[i];
-			if (!wbc->range_cyclic && req->wb_index > idx_end)
-				goto out;
-
-			/* Try to lock request and mark it for writeback */
-			if (!nfs_set_page_writeback_locked(req))
-				goto next;
-			radix_tree_tag_clear(&nfsi->nfs_page_tree,
-					req->wb_index, NFS_PAGE_TAG_DIRTY);
-			nfsi->ndirty--;
-			nfs_list_remove_request(req);
-			nfs_list_add_request(req, dst);
-			res++;
-			if (res == LONG_MAX)
-				goto out;
-next:
-			idx_start = req->wb_index + 1;
-		}
-	}
-out:
-	WARN_ON ((nfsi->ndirty == 0) != list_empty(&nfsi->dirty));
-	return res;
-}
-
-/**
  * nfs_scan_list - Scan a list for matching requests
  * @nfsi: NFS inode
  * @head: One of the NFS inode request lists
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 56dadf5..e600773 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -38,8 +38,8 @@
 static struct nfs_page * nfs_update_request(struct nfs_open_context*,
 					    struct page *,
 					    unsigned int, unsigned int);
-static void nfs_mark_request_dirty(struct nfs_page *req);
-static long nfs_flush_mapping(struct address_space *mapping, struct writeback_control *wbc, int how);
+static void nfs_pageio_init_write(struct nfs_pageio_descriptor *desc,
+				  struct inode *inode, int ioflags);
 static const struct rpc_call_ops nfs_write_partial_ops;
 static const struct rpc_call_ops nfs_write_full_ops;
 static const struct rpc_call_ops nfs_commit_ops;
@@ -202,7 +202,7 @@ static int nfs_writepage_setup(struct nfs_open_context *ctx, struct page *page,
 static int wb_priority(struct writeback_control *wbc)
 {
 	if (wbc->for_reclaim)
-		return FLUSH_HIGHPRI;
+		return FLUSH_HIGHPRI | FLUSH_STABLE;
 	if (wbc->for_kupdate)
 		return FLUSH_LOWPRI;
 	return 0;
@@ -252,10 +252,12 @@ static void nfs_end_page_writeback(struct page *page)
  * was not tagged.
  * May also return an error if the user signalled nfs_wait_on_request().
  */
-static int nfs_page_mark_flush(struct page *page)
+static int nfs_page_async_flush(struct nfs_pageio_descriptor *pgio,
+				struct page *page)
 {
 	struct nfs_page *req;
-	spinlock_t *req_lock = &NFS_I(page->mapping->host)->req_lock;
+	struct nfs_inode *nfsi = NFS_I(page->mapping->host);
+	spinlock_t *req_lock = &nfsi->req_lock;
 	int ret;
 
 	spin_lock(req_lock);
@@ -273,18 +275,23 @@ static int nfs_page_mark_flush(struct page *page)
 		 *	 request as dirty (in which case we don't care).
 		 */
 		spin_unlock(req_lock);
+		/* Prevent deadlock! */
+		nfs_pageio_complete(pgio);
 		ret = nfs_wait_on_request(req);
 		nfs_release_request(req);
 		if (ret != 0)
 			return ret;
 		spin_lock(req_lock);
 	}
+	if (nfs_set_page_writeback(page) != 0) {
+		spin_unlock(req_lock);
+		BUG();
+	}
+	radix_tree_tag_set(&nfsi->nfs_page_tree, req->wb_index,
+			NFS_PAGE_TAG_WRITEBACK);
 	spin_unlock(req_lock);
-	if (nfs_set_page_writeback(page) == 0)
-		nfs_mark_request_dirty(req);
-	ret = test_bit(PG_NEED_FLUSH, &req->wb_flags);
-	nfs_unlock_request(req);
-	return ret;
+	nfs_pageio_add_request(pgio, req);
+	return 0;
 }
 
 /*
@@ -292,6 +299,7 @@ static int nfs_page_mark_flush(struct page *page)
  */
 static int nfs_writepage_locked(struct page *page, struct writeback_control *wbc)
 {
+	struct nfs_pageio_descriptor mypgio, *pgio;
 	struct nfs_open_context *ctx;
 	struct inode *inode = page->mapping->host;
 	unsigned offset;
@@ -300,7 +308,14 @@ static int nfs_writepage_locked(struct page *page, struct writeback_control *wbc
 	nfs_inc_stats(inode, NFSIOS_VFSWRITEPAGE);
 	nfs_add_stats(inode, NFSIOS_WRITEPAGES, 1);
 
-	err = nfs_page_mark_flush(page);
+	if (wbc->for_writepages)
+		pgio = wbc->fs_private;
+	else {
+		nfs_pageio_init_write(&mypgio, inode, wb_priority(wbc));
+		pgio = &mypgio;
+	}
+
+	err = nfs_page_async_flush(pgio, page);
 	if (err <= 0)
 		goto out;
 	err = 0;
@@ -317,12 +332,12 @@ static int nfs_writepage_locked(struct page *page, struct writeback_control *wbc
 	put_nfs_open_context(ctx);
 	if (err != 0)
 		goto out;
-	err = nfs_page_mark_flush(page);
+	err = nfs_page_async_flush(pgio, page);
 	if (err > 0)
 		err = 0;
 out:
 	if (!wbc->for_writepages)
-		nfs_flush_mapping(page->mapping, wbc, FLUSH_STABLE|wb_priority(wbc));
+		nfs_pageio_complete(pgio);
 	return err;
 }
 
@@ -338,20 +353,20 @@ int nfs_writepage(struct page *page, struct writeback_control *wbc)
 int nfs_writepages(struct address_space *mapping, struct writeback_control *wbc)
 {
 	struct inode *inode = mapping->host;
+	struct nfs_pageio_descriptor pgio;
 	int err;
 
 	nfs_inc_stats(inode, NFSIOS_VFSWRITEPAGES);
 
+	nfs_pageio_init_write(&pgio, inode, wb_priority(wbc));
+	wbc->fs_private = &pgio;
 	err = generic_writepages(mapping, wbc);
+	nfs_pageio_complete(&pgio);
 	if (err)
 		return err;
-	err = nfs_flush_mapping(mapping, wbc, wb_priority(wbc));
-	if (err < 0)
-		goto out;
-	nfs_add_stats(inode, NFSIOS_WRITEPAGES, err);
-	err = 0;
-out:
-	return err;
+	if (pgio.pg_error)
+		return pgio.pg_error;
+	return 0;
 }
 
 /*
@@ -393,6 +408,8 @@ static void nfs_inode_remove_request(struct nfs_page *req)
 	set_page_private(req->wb_page, 0);
 	ClearPagePrivate(req->wb_page);
 	radix_tree_delete(&nfsi->nfs_page_tree, req->wb_index);
+	if (test_and_clear_bit(PG_NEED_FLUSH, &req->wb_flags))
+		__set_page_dirty_nobuffers(req->wb_page);
 	nfsi->npages--;
 	if (!nfsi->npages) {
 		spin_unlock(&nfsi->req_lock);
@@ -404,24 +421,6 @@ static void nfs_inode_remove_request(struct nfs_page *req)
 	nfs_release_request(req);
 }
 
-/*
- * Add a request to the inode's dirty list.
- */
-static void
-nfs_mark_request_dirty(struct nfs_page *req)
-{
-	struct inode *inode = req->wb_context->dentry->d_inode;
-	struct nfs_inode *nfsi = NFS_I(inode);
-
-	spin_lock(&nfsi->req_lock);
-	radix_tree_tag_set(&nfsi->nfs_page_tree,
-			req->wb_index, NFS_PAGE_TAG_DIRTY);
-	nfs_list_add_request(req, &nfsi->dirty);
-	nfsi->ndirty++;
-	spin_unlock(&nfsi->req_lock);
-	__mark_inode_dirty(inode, I_DIRTY_PAGES);
-}
-
 static void
 nfs_redirty_request(struct nfs_page *req)
 {
@@ -498,18 +497,6 @@ static int nfs_wait_on_requests_locked(struct inode *inode, unsigned long idx_st
 	return res;
 }
 
-static void nfs_cancel_dirty_list(struct list_head *head)
-{
-	struct nfs_page *req;
-	while(!list_empty(head)) {
-		req = nfs_list_entry(head->next);
-		nfs_list_remove_request(req);
-		nfs_end_page_writeback(req->wb_page);
-		nfs_inode_remove_request(req);
-		nfs_clear_page_writeback(req);
-	}
-}
-
 static void nfs_cancel_commit_list(struct list_head *head)
 {
 	struct nfs_page *req;
@@ -911,33 +898,15 @@ static int nfs_flush_one(struct inode *inode, struct list_head *head, size_t cou
 	return -ENOMEM;
 }
 
-static int nfs_flush_list(struct inode *inode, struct list_head *head, int npages, int how)
+static void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
+				  struct inode *inode, int ioflags)
 {
-	struct nfs_pageio_descriptor desc;
-	int wpages = NFS_SERVER(inode)->wpages;
 	int wsize = NFS_SERVER(inode)->wsize;
 
-	/* For single writes, FLUSH_STABLE is more efficient */
-	if (npages <= wpages && npages == NFS_I(inode)->npages
-			&& nfs_list_entry(head->next)->wb_bytes <= wsize)
-		how |= FLUSH_STABLE;
-
 	if (wsize < PAGE_CACHE_SIZE)
-		nfs_pageio_init(&desc, inode, nfs_flush_multi, wsize, how);
+		nfs_pageio_init(pgio, inode, nfs_flush_multi, wsize, ioflags);
 	else
-		nfs_pageio_init(&desc, inode, nfs_flush_one, wsize, how);
-	nfs_pageio_add_list(&desc, head);
-	nfs_pageio_complete(&desc);
-	if (desc.pg_error == 0)
-		return 0;
-	while (!list_empty(head)) {
-		struct nfs_page *req = nfs_list_entry(head->next);
-		nfs_list_remove_request(req);
-		nfs_end_page_writeback(req->wb_page);
-		nfs_redirty_request(req);
-		nfs_clear_page_writeback(req);
-	}
-	return desc.pg_error;
+		nfs_pageio_init(pgio, inode, nfs_flush_one, wsize, ioflags);
 }
 
 /*
@@ -1258,31 +1227,7 @@ static const struct rpc_call_ops nfs_commit_ops = {
 	.rpc_call_done = nfs_commit_done,
 	.rpc_release = nfs_commit_release,
 };
-#else
-static inline int nfs_commit_list(struct inode *inode, struct list_head *head, int how)
-{
-	return 0;
-}
-#endif
-
-static long nfs_flush_mapping(struct address_space *mapping, struct writeback_control *wbc, int how)
-{
-	struct nfs_inode *nfsi = NFS_I(mapping->host);
-	LIST_HEAD(head);
-	long res;
 
-	spin_lock(&nfsi->req_lock);
-	res = nfs_scan_dirty(mapping, wbc, &head);
-	spin_unlock(&nfsi->req_lock);
-	if (res) {
-		int error = nfs_flush_list(mapping->host, &head, res, how);
-		if (error < 0)
-			return error;
-	}
-	return res;
-}
-
-#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 int nfs_commit_inode(struct inode *inode, int how)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
@@ -1299,6 +1244,11 @@ int nfs_commit_inode(struct inode *inode, int how)
 	}
 	return res;
 }
+#else
+static inline int nfs_commit_list(struct inode *inode, struct list_head *head, int how)
+{
+	return 0;
+}
 #endif
 
 long nfs_sync_mapping_wait(struct address_space *mapping, struct writeback_control *wbc, int how)
@@ -1332,19 +1282,6 @@ long nfs_sync_mapping_wait(struct address_space *mapping, struct writeback_contr
 		ret = nfs_wait_on_requests_locked(inode, idx_start, npages);
 		if (ret != 0)
 			continue;
-		pages = nfs_scan_dirty(mapping, wbc, &head);
-		if (pages != 0) {
-			spin_unlock(&nfsi->req_lock);
-			if (how & FLUSH_INVALIDATE) {
-				nfs_cancel_dirty_list(&head);
-				ret = pages;
-			} else
-				ret = nfs_flush_list(inode, &head, pages, how);
-			spin_lock(&nfsi->req_lock);
-			continue;
-		}
-		if (wbc->pages_skipped != 0)
-			continue;
 		if (nocommit)
 			break;
 		pages = nfs_scan_commit(inode, &head, idx_start, npages);
@@ -1384,7 +1321,7 @@ int nfs_wb_all(struct inode *inode)
 	};
 	int ret;
 
-	ret = generic_writepages(mapping, &wbc);
+	ret = nfs_writepages(mapping, &wbc);
 	if (ret < 0)
 		goto out;
 	ret = nfs_sync_mapping_wait(mapping, &wbc, 0);
@@ -1407,11 +1344,9 @@ int nfs_sync_mapping_range(struct address_space *mapping, loff_t range_start, lo
 	};
 	int ret;
 
-	if (!(how & FLUSH_NOWRITEPAGE)) {
-		ret = generic_writepages(mapping, &wbc);
-		if (ret < 0)
-			goto out;
-	}
+	ret = nfs_writepages(mapping, &wbc);
+	if (ret < 0)
+		goto out;
 	ret = nfs_sync_mapping_wait(mapping, &wbc, how);
 	if (ret >= 0)
 		return 0;
@@ -1434,7 +1369,7 @@ int nfs_wb_page_priority(struct inode *inode, struct page *page, int how)
 	int ret;
 
 	BUG_ON(!PageLocked(page));
-	if (!(how & FLUSH_NOWRITEPAGE) && clear_page_dirty_for_io(page)) {
+	if (clear_page_dirty_for_io(page)) {
 		ret = nfs_writepage_locked(page, &wbc);
 		if (ret < 0)
 			goto out;
@@ -1459,15 +1394,22 @@ int nfs_wb_page(struct inode *inode, struct page* page)
 
 int nfs_set_page_dirty(struct page *page)
 {
+	spinlock_t *req_lock = &NFS_I(page->mapping->host)->req_lock;
 	struct nfs_page *req;
+	int ret;
 
-	req = nfs_page_find_request(page);
+	spin_lock(req_lock);
+	req = nfs_page_find_request_locked(page);
 	if (req != NULL) {
 		/* Mark any existing write requests for flushing */
-		set_bit(PG_NEED_FLUSH, &req->wb_flags);
+		ret = !test_and_set_bit(PG_NEED_FLUSH, &req->wb_flags);
+		spin_unlock(req_lock);
 		nfs_release_request(req);
+		return ret;
 	}
-	return __set_page_dirty_nobuffers(page);
+	ret = __set_page_dirty_nobuffers(page);
+	spin_unlock(req_lock);
+	return ret;
 }
 
 
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index ee5b09c..e49f356 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -21,8 +21,7 @@
 /*
  * Valid flags for the radix tree
  */
-#define NFS_PAGE_TAG_DIRTY	0
-#define NFS_PAGE_TAG_WRITEBACK	1
+#define NFS_PAGE_TAG_WRITEBACK	0
 
 /*
  * Valid flags for a dirty buffer
@@ -74,9 +73,6 @@ extern	void nfs_clear_request(struct nfs_page *req);
 extern	void nfs_release_request(struct nfs_page *req);
 
 
-extern	long nfs_scan_dirty(struct address_space *mapping,
-				struct writeback_control *wbc,
-				struct list_head *dst);
 extern	int nfs_scan_list(struct nfs_inode *nfsi, struct list_head *head, struct list_head *dst,
 			  unsigned long idx_start, unsigned int npages);
 extern	void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
@@ -86,8 +82,6 @@ extern	void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
 			     int how);
 extern	int nfs_pageio_add_request(struct nfs_pageio_descriptor *,
 				   struct nfs_page *);
-extern	void nfs_pageio_add_list(struct nfs_pageio_descriptor *,
-				 struct list_head *);
 extern	void nfs_pageio_complete(struct nfs_pageio_descriptor *desc);
 extern  int nfs_wait_on_request(struct nfs_page *);
 extern	void nfs_unlock_request(struct nfs_page *req);
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index 0c78f7f..daa6c12 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -59,6 +59,8 @@ struct writeback_control {
 	unsigned for_reclaim:1;		/* Invoked from the page allocator */
 	unsigned for_writepages:1;	/* This is a writepages() call */
 	unsigned range_cyclic:1;	/* range_start is cyclic */
+
+	void *fs_private;		/* For use by ->writepages() */
 };
 
 /*

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

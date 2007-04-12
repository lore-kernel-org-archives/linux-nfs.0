From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 5/8] NFS: Another cleanup of the read/write request
	coalescing code
Date: Wed, 11 Apr 2007 22:37:35 -0400
Message-ID: <20070412023735.15270.20113.stgit@heimdal.trondhjem.org>
References: <20070412023714.15270.33322.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HbpBr-0005lS-Bj
	for nfs@lists.sourceforge.net; Wed, 11 Apr 2007 19:37:40 -0700
Received: from c-69-242-210-120.hsd1.mi.comcast.net ([69.242.210.120]
	helo=heimdal.trondhjem.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HbpBt-0002V1-2e
	for nfs@lists.sourceforge.net; Wed, 11 Apr 2007 19:37:41 -0700
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

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/pagelist.c        |   71 +++++++++++++++++++++++++++++++++++++++++++---
 fs/nfs/read.c            |   62 +++++++++++++++++-----------------------
 fs/nfs/write.c           |   53 +++++++++++++---------------------
 include/linux/nfs_page.h |   14 ++++++++-
 4 files changed, 125 insertions(+), 75 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 7017eb0..5281285 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -225,14 +225,26 @@ out:
 /**
  * nfs_pageio_init - initialise a page io descriptor
  * @desc: pointer to descriptor
- * @iosize: io block size
+ * @inode: pointer to inode
+ * @doio: pointer to io function
+ * @bsize: io block size
+ * @io_flags: extra parameters for the io function
  */
-void nfs_pageio_init(struct nfs_pageio_descriptor *desc, unsigned int bsize)
+void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
+		     struct inode *inode,
+		     int (*doio)(struct inode *, struct list_head *, size_t, int),
+		     unsigned int bsize,
+		     int io_flags)
 {
 	INIT_LIST_HEAD(&desc->pg_list);
+	desc->pg_bytes_written = 0;
 	desc->pg_count = 0;
 	desc->pg_bsize = bsize;
 	desc->pg_base = 0;
+	desc->pg_inode = inode;
+	desc->pg_doio = doio;
+	desc->pg_ioflags = io_flags;
+	desc->pg_error = 0;
 }
 
 /**
@@ -265,15 +277,15 @@ static int nfs_can_coalesce_requests(struct nfs_page *prev,
 }
 
 /**
- * nfs_pageio_add_request - Attempt to coalesce a request into a page list.
+ * nfs_pageio_do_add_request - Attempt to coalesce a request into a page list.
  * @desc: destination io descriptor
  * @req: request
  *
  * Returns true if the request 'req' was successfully coalesced into the
  * existing list of pages 'desc'.
  */
-static int nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
-				  struct nfs_page *req)
+static int nfs_pageio_do_add_request(struct nfs_pageio_descriptor *desc,
+				     struct nfs_page *req)
 {
 	size_t newlen = req->wb_bytes;
 
@@ -301,6 +313,46 @@ static int nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
 	return 1;
 }
 
+/*
+ * Helper for nfs_pageio_add_request and nfs_pageio_complete
+ */
+static void nfs_pageio_doio(struct nfs_pageio_descriptor *desc)
+{
+	if (!list_empty(&desc->pg_list)) {
+		int error = desc->pg_doio(desc->pg_inode,
+					  &desc->pg_list,
+					  desc->pg_count,
+					  desc->pg_ioflags);
+		if (error < 0)
+			desc->pg_error = error;
+		else
+			desc->pg_bytes_written += desc->pg_count;
+	}
+	if (list_empty(&desc->pg_list)) {
+		desc->pg_count = 0;
+		desc->pg_base = 0;
+	}
+}
+
+/**
+ * nfs_pageio_add_request - Attempt to coalesce a request into a page list.
+ * @desc: destination io descriptor
+ * @req: request
+ *
+ * Returns true if the request 'req' was successfully coalesced into the
+ * existing list of pages 'desc'.
+ */
+static int nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
+				  struct nfs_page *req)
+{
+	while (!nfs_pageio_do_add_request(desc, req)) {
+		nfs_pageio_doio(desc);
+		if (desc->pg_error < 0)
+			return 0;
+	}
+	return 1;
+}
+
 /**
  * nfs_pageio_add_list - Split coalesced requests out from a list.
  * @desc: destination io descriptor
@@ -320,6 +372,15 @@ void nfs_pageio_add_list(struct nfs_pageio_descriptor *desc,
 	}
 }
 
+/**
+ * nfs_pageio_complete - Complete I/O on an nfs_pageio_descriptor
+ * @desc: pointer to io descriptor
+ */
+void nfs_pageio_complete(struct nfs_pageio_descriptor *desc)
+{
+	nfs_pageio_doio(desc);
+}
+
 #define NFS_SCAN_MAXENTRIES 16
 /**
  * nfs_scan_dirty - Scan the radix tree for dirty requests
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 97f0f42..0effa74 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -27,7 +27,8 @@
 
 #define NFSDBG_FACILITY		NFSDBG_PAGECACHE
 
-static int nfs_pagein_one(struct list_head *, struct inode *);
+static int nfs_pagein_multi(struct inode *, struct list_head *, size_t, int);
+static int nfs_pagein_one(struct inode *, struct list_head *, size_t, int);
 static const struct rpc_call_ops nfs_read_partial_ops;
 static const struct rpc_call_ops nfs_read_full_ops;
 
@@ -133,7 +134,10 @@ static int nfs_readpage_async(struct nfs_open_context *ctx, struct inode *inode,
 		memclear_highpage_flush(page, len, PAGE_CACHE_SIZE - len);
 
 	nfs_list_add_request(new, &one_request);
-	nfs_pagein_one(&one_request, inode);
+	if (NFS_SERVER(inode)->rsize < PAGE_CACHE_SIZE)
+		nfs_pagein_multi(inode, &one_request, len, 0);
+	else
+		nfs_pagein_one(inode, &one_request, len, 0);
 	return 0;
 }
 
@@ -230,7 +234,7 @@ static void nfs_execute_read(struct nfs_read_data *data)
  * won't see the new data until our attribute cache is updated.  This is more
  * or less conventional NFS client behavior.
  */
-static int nfs_pagein_multi(struct list_head *head, struct inode *inode)
+static int nfs_pagein_multi(struct inode *inode, struct list_head *head, size_t count, int flags)
 {
 	struct nfs_page *req = nfs_list_entry(head->next);
 	struct page *page = req->wb_page;
@@ -242,7 +246,7 @@ static int nfs_pagein_multi(struct list_head *head, struct inode *inode)
 
 	nfs_list_remove_request(req);
 
-	nbytes = req->wb_bytes;
+	nbytes = count;
 	do {
 		size_t len = min(nbytes,rsize);
 
@@ -258,23 +262,19 @@ static int nfs_pagein_multi(struct list_head *head, struct inode *inode)
 
 	ClearPageError(page);
 	offset = 0;
-	nbytes = req->wb_bytes;
+	nbytes = count;
 	do {
 		data = list_entry(list.next, struct nfs_read_data, pages);
 		list_del_init(&data->pages);
 
 		data->pagevec[0] = page;
 
-		if (nbytes > rsize) {
-			nfs_read_rpcsetup(req, data, &nfs_read_partial_ops,
-					rsize, offset);
-			offset += rsize;
-			nbytes -= rsize;
-		} else {
-			nfs_read_rpcsetup(req, data, &nfs_read_partial_ops,
-					nbytes, offset);
-			nbytes = 0;
-		}
+		if (nbytes < rsize)
+			rsize = nbytes;
+		nfs_read_rpcsetup(req, data, &nfs_read_partial_ops,
+				  rsize, offset);
+		offset += rsize;
+		nbytes -= rsize;
 		nfs_execute_read(data);
 	} while (nbytes != 0);
 
@@ -291,30 +291,24 @@ out_bad:
 	return -ENOMEM;
 }
 
-static int nfs_pagein_one(struct list_head *head, struct inode *inode)
+static int nfs_pagein_one(struct inode *inode, struct list_head *head, size_t count, int flags)
 {
 	struct nfs_page		*req;
 	struct page		**pages;
 	struct nfs_read_data	*data;
-	unsigned int		count;
-
-	if (NFS_SERVER(inode)->rsize < PAGE_CACHE_SIZE)
-		return nfs_pagein_multi(head, inode);
 
-	data = nfs_readdata_alloc(NFS_SERVER(inode)->rsize);
+	data = nfs_readdata_alloc(count);
 	if (!data)
 		goto out_bad;
 
 	INIT_LIST_HEAD(&data->pages);
 	pages = data->pagevec;
-	count = 0;
 	while (!list_empty(head)) {
 		req = nfs_list_entry(head->next);
 		nfs_list_remove_request(req);
 		nfs_list_add_request(req, &data->pages);
 		ClearPageError(req->wb_page);
 		*pages++ = req->wb_page;
-		count += req->wb_bytes;
 	}
 	req = nfs_list_entry(data->pages.next);
 
@@ -328,22 +322,20 @@ out_bad:
 }
 
 static int
-nfs_pagein_list(struct list_head *head, unsigned int rsize)
+nfs_pagein_list(struct inode *inode, struct list_head *head, unsigned int rsize)
 {
 	struct nfs_pageio_descriptor desc;
-	struct nfs_page *req;
 	unsigned int pages = 0;
 	int error = 0;
 
-	while (!list_empty(head)) {
-		nfs_pageio_init(&desc, rsize);
-		nfs_pageio_add_list(&desc, head);
-		req = nfs_list_entry(desc.pg_list.next);
-		error = nfs_pagein_one(&desc.pg_list, req->wb_context->dentry->d_inode);
-		if (error < 0)
-			break;
-		pages += (desc.pg_count + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
-	}
+	if (rsize < PAGE_CACHE_SIZE)
+		nfs_pageio_init(&desc, inode, nfs_pagein_multi, rsize, 0);
+	else
+		nfs_pageio_init(&desc, inode, nfs_pagein_one, rsize, 0);
+
+	nfs_pageio_add_list(&desc, head);
+	nfs_pageio_complete(&desc);
+	pages += (desc.pg_bytes_written + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
 
 	nfs_async_read_error(head);
 	if (error >= 0)
@@ -597,7 +589,7 @@ int nfs_readpages(struct file *filp, struct address_space *mapping,
 				filp->private_data);
 	ret = read_cache_pages(mapping, pages, readpage_async_filler, &desc);
 	if (!list_empty(&head)) {
-		int err = nfs_pagein_list(&head, server->rsize);
+		int err = nfs_pagein_list(inode, &head, server->rsize);
 		if (!ret)
 			nfs_add_stats(inode, NFSIOS_READPAGES, err);
 			ret = err;
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 402c76b..56dadf5 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -810,7 +810,7 @@ static void nfs_execute_write(struct nfs_write_data *data)
  * Generate multiple small requests to write out a single
  * contiguous dirty area on one page.
  */
-static int nfs_flush_multi(struct inode *inode, struct list_head *head, int how)
+static int nfs_flush_multi(struct inode *inode, struct list_head *head, size_t count, int how)
 {
 	struct nfs_page *req = nfs_list_entry(head->next);
 	struct page *page = req->wb_page;
@@ -822,7 +822,7 @@ static int nfs_flush_multi(struct inode *inode, struct list_head *head, int how)
 
 	nfs_list_remove_request(req);
 
-	nbytes = req->wb_bytes;
+	nbytes = count;
 	do {
 		size_t len = min(nbytes, wsize);
 
@@ -837,23 +837,19 @@ static int nfs_flush_multi(struct inode *inode, struct list_head *head, int how)
 
 	ClearPageError(page);
 	offset = 0;
-	nbytes = req->wb_bytes;
+	nbytes = count;
 	do {
 		data = list_entry(list.next, struct nfs_write_data, pages);
 		list_del_init(&data->pages);
 
 		data->pagevec[0] = page;
 
-		if (nbytes > wsize) {
-			nfs_write_rpcsetup(req, data, &nfs_write_partial_ops,
-					wsize, offset, how);
-			offset += wsize;
-			nbytes -= wsize;
-		} else {
-			nfs_write_rpcsetup(req, data, &nfs_write_partial_ops,
-					nbytes, offset, how);
-			nbytes = 0;
-		}
+		if (nbytes < wsize)
+			wsize = nbytes;
+		nfs_write_rpcsetup(req, data, &nfs_write_partial_ops,
+				   wsize, offset, how);
+		offset += wsize;
+		nbytes -= wsize;
 		nfs_execute_write(data);
 	} while (nbytes != 0);
 
@@ -879,26 +875,23 @@ out_bad:
  * This is the case if nfs_updatepage detects a conflicting request
  * that has been written but not committed.
  */
-static int nfs_flush_one(struct inode *inode, struct list_head *head, int how)
+static int nfs_flush_one(struct inode *inode, struct list_head *head, size_t count, int how)
 {
 	struct nfs_page		*req;
 	struct page		**pages;
 	struct nfs_write_data	*data;
-	unsigned int		count;
 
-	data = nfs_writedata_alloc(NFS_SERVER(inode)->wsize);
+	data = nfs_writedata_alloc(count);
 	if (!data)
 		goto out_bad;
 
 	pages = data->pagevec;
-	count = 0;
 	while (!list_empty(head)) {
 		req = nfs_list_entry(head->next);
 		nfs_list_remove_request(req);
 		nfs_list_add_request(req, &data->pages);
 		ClearPageError(req->wb_page);
 		*pages++ = req->wb_page;
-		count += req->wb_bytes;
 	}
 	req = nfs_list_entry(data->pages.next);
 
@@ -921,28 +914,22 @@ static int nfs_flush_one(struct inode *inode, struct list_head *head, int how)
 static int nfs_flush_list(struct inode *inode, struct list_head *head, int npages, int how)
 {
 	struct nfs_pageio_descriptor desc;
-	int (*flush_one)(struct inode *, struct list_head *, int);
 	int wpages = NFS_SERVER(inode)->wpages;
 	int wsize = NFS_SERVER(inode)->wsize;
-	int error;
 
-	flush_one = nfs_flush_one;
-	if (wsize < PAGE_CACHE_SIZE)
-		flush_one = nfs_flush_multi;
 	/* For single writes, FLUSH_STABLE is more efficient */
 	if (npages <= wpages && npages == NFS_I(inode)->npages
 			&& nfs_list_entry(head->next)->wb_bytes <= wsize)
 		how |= FLUSH_STABLE;
 
-	do {
-		nfs_pageio_init(&desc, wsize);
-		nfs_pageio_add_list(&desc, head);
-		error = flush_one(inode, &desc.pg_list, how);
-		if (error < 0)
-			goto out_err;
-	} while (!list_empty(head));
-	return 0;
-out_err:
+	if (wsize < PAGE_CACHE_SIZE)
+		nfs_pageio_init(&desc, inode, nfs_flush_multi, wsize, how);
+	else
+		nfs_pageio_init(&desc, inode, nfs_flush_one, wsize, how);
+	nfs_pageio_add_list(&desc, head);
+	nfs_pageio_complete(&desc);
+	if (desc.pg_error == 0)
+		return 0;
 	while (!list_empty(head)) {
 		struct nfs_page *req = nfs_list_entry(head->next);
 		nfs_list_remove_request(req);
@@ -950,7 +937,7 @@ out_err:
 		nfs_redirty_request(req);
 		nfs_clear_page_writeback(req);
 	}
-	return error;
+	return desc.pg_error;
 }
 
 /*
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index 8dd49cb..13f5ee2 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -50,9 +50,15 @@ struct nfs_page {
 
 struct nfs_pageio_descriptor {
 	struct list_head	pg_list;
+	unsigned long		pg_bytes_written;
 	size_t			pg_count;
 	size_t			pg_bsize;
 	unsigned int		pg_base;
+
+	struct inode		*pg_inode;
+	int			(*pg_doio)(struct inode *, struct list_head *, size_t, int);
+	int 			pg_ioflags;
+	int			pg_error;
 };
 
 #define NFS_WBACK_BUSY(req)	(test_bit(PG_BUSY,&(req)->wb_flags))
@@ -73,10 +79,14 @@ extern	long nfs_scan_dirty(struct address_space *mapping,
 				struct list_head *dst);
 extern	int nfs_scan_list(struct nfs_inode *nfsi, struct list_head *head, struct list_head *dst,
 			  unsigned long idx_start, unsigned int npages);
-extern  void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
-			     size_t iosize);
+extern	void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
+			     struct inode *inode,
+			     int (*doio)(struct inode *, struct list_head *, size_t, int),
+			     size_t bsize,
+			     int how);
 extern	void nfs_pageio_add_list(struct nfs_pageio_descriptor *,
 				 struct list_head *);
+extern	void nfs_pageio_complete(struct nfs_pageio_descriptor *desc);
 extern  int nfs_wait_on_request(struct nfs_page *);
 extern	void nfs_unlock_request(struct nfs_page *req);
 extern  int nfs_set_page_writeback_locked(struct nfs_page *req);

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

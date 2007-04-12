From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 4/8] NFS: Cleanup the coalescing code
Date: Wed, 11 Apr 2007 22:37:30 -0400
Message-ID: <20070412023730.15270.27421.stgit@heimdal.trondhjem.org>
References: <20070412023714.15270.33322.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HbpBm-0005lL-6W
	for nfs@lists.sourceforge.net; Wed, 11 Apr 2007 19:37:34 -0700
Received: from c-69-242-210-120.hsd1.mi.comcast.net ([69.242.210.120]
	helo=heimdal.trondhjem.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HbpBo-0002do-3G
	for nfs@lists.sourceforge.net; Wed, 11 Apr 2007 19:37:36 -0700
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

 fs/nfs/pagelist.c        |  117 +++++++++++++++++++++++++++++++++-------------
 fs/nfs/read.c            |   24 +++++----
 fs/nfs/write.c           |   11 ++--
 include/linux/nfs_page.h |   13 ++++-
 4 files changed, 114 insertions(+), 51 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index ca4b1d4..7017eb0 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -223,48 +223,101 @@ out:
 }
 
 /**
- * nfs_coalesce_requests - Split coalesced requests out from a list.
+ * nfs_pageio_init - initialise a page io descriptor
+ * @desc: pointer to descriptor
+ * @iosize: io block size
+ */
+void nfs_pageio_init(struct nfs_pageio_descriptor *desc, unsigned int bsize)
+{
+	INIT_LIST_HEAD(&desc->pg_list);
+	desc->pg_count = 0;
+	desc->pg_bsize = bsize;
+	desc->pg_base = 0;
+}
+
+/**
+ * nfs_can_coalesce_requests - test two requests for compatibility
+ * @prev: pointer to nfs_page
+ * @req: pointer to nfs_page
+ *
+ * The nfs_page structures 'prev' and 'req' are compared to ensure that the
+ * page data area they describe is contiguous, and that their RPC
+ * credentials, NFSv4 open state, and lockowners are the same.
+ *
+ * Return 'true' if this is the case, else return 'false'.
+ */
+static int nfs_can_coalesce_requests(struct nfs_page *prev,
+				     struct nfs_page *req)
+{
+	if (req->wb_context->cred != prev->wb_context->cred)
+		return 0;
+	if (req->wb_context->lockowner != prev->wb_context->lockowner)
+		return 0;
+	if (req->wb_context->state != prev->wb_context->state)
+		return 0;
+	if (req->wb_index != (prev->wb_index + 1))
+		return 0;
+	if (req->wb_pgbase != 0)
+		return 0;
+	if (prev->wb_pgbase + prev->wb_bytes != PAGE_CACHE_SIZE)
+		return 0;
+	return 1;
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
+	size_t newlen = req->wb_bytes;
+
+	if (desc->pg_count != 0) {
+		struct nfs_page *prev;
+
+		/*
+		 * FIXME: ideally we should be able to coalesce all requests
+		 * that are not block boundary aligned, but currently this
+		 * is problematic for the case of bsize < PAGE_CACHE_SIZE,
+		 * since nfs_flush_multi and nfs_pagein_multi assume you
+		 * can have only one struct nfs_page.
+		 */
+		newlen += desc->pg_count;
+		if (desc->pg_base + newlen > desc->pg_bsize)
+			return 0;
+		prev = nfs_list_entry(desc->pg_list.prev);
+		if (!nfs_can_coalesce_requests(prev, req))
+			return 0;
+	} else
+		desc->pg_base = req->wb_pgbase;
+	nfs_list_remove_request(req);
+	nfs_list_add_request(req, &desc->pg_list);
+	desc->pg_count = newlen;
+	return 1;
+}
+
+/**
+ * nfs_pageio_add_list - Split coalesced requests out from a list.
+ * @desc: destination io descriptor
  * @head: source list
- * @dst: destination list
- * @nmax: maximum number of requests to coalesce
  *
  * Moves a maximum of 'nmax' elements from one list to another.
  * The elements are checked to ensure that they form a contiguous set
  * of pages, and that the RPC credentials are the same.
  */
-int
-nfs_coalesce_requests(struct list_head *head, struct list_head *dst,
-		      unsigned int nmax)
+void nfs_pageio_add_list(struct nfs_pageio_descriptor *desc,
+			 struct list_head *head)
 {
-	struct nfs_page		*req = NULL;
-	unsigned int		npages = 0;
-
 	while (!list_empty(head)) {
-		struct nfs_page	*prev = req;
-
-		req = nfs_list_entry(head->next);
-		if (prev) {
-			if (req->wb_context->cred != prev->wb_context->cred)
-				break;
-			if (req->wb_context->lockowner != prev->wb_context->lockowner)
-				break;
-			if (req->wb_context->state != prev->wb_context->state)
-				break;
-			if (req->wb_index != (prev->wb_index + 1))
-				break;
-
-			if (req->wb_pgbase != 0)
-				break;
-		}
-		nfs_list_remove_request(req);
-		nfs_list_add_request(req, dst);
-		npages++;
-		if (req->wb_pgbase + req->wb_bytes != PAGE_CACHE_SIZE)
-			break;
-		if (npages >= nmax)
+		struct nfs_page *req = nfs_list_entry(head->next);
+		if (!nfs_pageio_add_request(desc, req))
 			break;
 	}
-	return npages;
 }
 
 #define NFS_SCAN_MAXENTRIES 16
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 6ab4d5a..97f0f42 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -328,24 +328,26 @@ out_bad:
 }
 
 static int
-nfs_pagein_list(struct list_head *head, int rpages)
+nfs_pagein_list(struct list_head *head, unsigned int rsize)
 {
-	LIST_HEAD(one_request);
-	struct nfs_page		*req;
-	int			error = 0;
-	unsigned int		pages = 0;
+	struct nfs_pageio_descriptor desc;
+	struct nfs_page *req;
+	unsigned int pages = 0;
+	int error = 0;
 
 	while (!list_empty(head)) {
-		pages += nfs_coalesce_requests(head, &one_request, rpages);
-		req = nfs_list_entry(one_request.next);
-		error = nfs_pagein_one(&one_request, req->wb_context->dentry->d_inode);
+		nfs_pageio_init(&desc, rsize);
+		nfs_pageio_add_list(&desc, head);
+		req = nfs_list_entry(desc.pg_list.next);
+		error = nfs_pagein_one(&desc.pg_list, req->wb_context->dentry->d_inode);
 		if (error < 0)
 			break;
+		pages += (desc.pg_count + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
 	}
-	if (error >= 0)
-		return pages;
 
 	nfs_async_read_error(head);
+	if (error >= 0)
+		return pages;
 	return error;
 }
 
@@ -595,7 +597,7 @@ int nfs_readpages(struct file *filp, struct address_space *mapping,
 				filp->private_data);
 	ret = read_cache_pages(mapping, pages, readpage_async_filler, &desc);
 	if (!list_empty(&head)) {
-		int err = nfs_pagein_list(&head, server->rpages);
+		int err = nfs_pagein_list(&head, server->rsize);
 		if (!ret)
 			nfs_add_stats(inode, NFSIOS_READPAGES, err);
 			ret = err;
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index bcd72f6..402c76b 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -920,9 +920,8 @@ static int nfs_flush_one(struct inode *inode, struct list_head *head, int how)
 
 static int nfs_flush_list(struct inode *inode, struct list_head *head, int npages, int how)
 {
-	LIST_HEAD(one_request);
+	struct nfs_pageio_descriptor desc;
 	int (*flush_one)(struct inode *, struct list_head *, int);
-	struct nfs_page	*req;
 	int wpages = NFS_SERVER(inode)->wpages;
 	int wsize = NFS_SERVER(inode)->wsize;
 	int error;
@@ -936,16 +935,16 @@ static int nfs_flush_list(struct inode *inode, struct list_head *head, int npage
 		how |= FLUSH_STABLE;
 
 	do {
-		nfs_coalesce_requests(head, &one_request, wpages);
-		req = nfs_list_entry(one_request.next);
-		error = flush_one(inode, &one_request, how);
+		nfs_pageio_init(&desc, wsize);
+		nfs_pageio_add_list(&desc, head);
+		error = flush_one(inode, &desc.pg_list, how);
 		if (error < 0)
 			goto out_err;
 	} while (!list_empty(head));
 	return 0;
 out_err:
 	while (!list_empty(head)) {
-		req = nfs_list_entry(head->next);
+		struct nfs_page *req = nfs_list_entry(head->next);
 		nfs_list_remove_request(req);
 		nfs_end_page_writeback(req->wb_page);
 		nfs_redirty_request(req);
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index d111be6..8dd49cb 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -48,6 +48,13 @@ struct nfs_page {
 	struct nfs_writeverf	wb_verf;	/* Commit cookie */
 };
 
+struct nfs_pageio_descriptor {
+	struct list_head	pg_list;
+	size_t			pg_count;
+	size_t			pg_bsize;
+	unsigned int		pg_base;
+};
+
 #define NFS_WBACK_BUSY(req)	(test_bit(PG_BUSY,&(req)->wb_flags))
 #define NFS_NEED_COMMIT(req)	(test_bit(PG_NEED_COMMIT,&(req)->wb_flags))
 #define NFS_NEED_RESCHED(req)	(test_bit(PG_NEED_RESCHED,&(req)->wb_flags))
@@ -66,8 +73,10 @@ extern	long nfs_scan_dirty(struct address_space *mapping,
 				struct list_head *dst);
 extern	int nfs_scan_list(struct nfs_inode *nfsi, struct list_head *head, struct list_head *dst,
 			  unsigned long idx_start, unsigned int npages);
-extern	int nfs_coalesce_requests(struct list_head *, struct list_head *,
-				  unsigned int);
+extern  void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
+			     size_t iosize);
+extern	void nfs_pageio_add_list(struct nfs_pageio_descriptor *,
+				 struct list_head *);
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

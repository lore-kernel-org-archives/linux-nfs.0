Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:55415 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754281Ab1GLTaH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Jul 2011 15:30:07 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/8] NFS: Clean up: split out the RPC transmission from nfs_pagein_multi/one
Date: Tue, 12 Jul 2011 15:29:48 -0400
Message-Id: <1310498994-12685-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1310498994-12685-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1310498994-12685-1-git-send-email-Trond.Myklebust@netapp.com>
 <1310498994-12685-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

...and do the same for nfs_flush_multi/one.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/read.c  |   92 ++++++++++++++++++++++++++++++-------------------------
 fs/nfs/write.c |   93 +++++++++++++++++++++++++++++++------------------------
 2 files changed, 102 insertions(+), 83 deletions(-)

diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 248a554..d30d6de 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -30,8 +30,6 @@
 
 #define NFSDBG_FACILITY		NFSDBG_PAGECACHE
 
-static int nfs_pagein_multi(struct nfs_pageio_descriptor *desc);
-static int nfs_pagein_one(struct nfs_pageio_descriptor *desc);
 static const struct nfs_pageio_ops nfs_pageio_read_ops;
 static const struct rpc_call_ops nfs_read_partial_ops;
 static const struct rpc_call_ops nfs_read_full_ops;
@@ -253,6 +251,27 @@ static int nfs_do_read(struct nfs_read_data *data,
 	return nfs_initiate_read(data, NFS_CLIENT(inode), call_ops);
 }
 
+static int
+nfs_do_multiple_reads(struct list_head *head,
+		const struct rpc_call_ops *call_ops,
+		struct pnfs_layout_segment *lseg)
+{
+	struct nfs_read_data *data;
+	int ret = 0;
+
+	while (!list_empty(head)) {
+		int ret2;
+
+		data = list_entry(head->next, struct nfs_read_data, list);
+		list_del_init(&data->list);
+
+		ret2 = nfs_do_read(data, call_ops, lseg);
+		if (ret == 0)
+			ret = ret2;
+	}
+	return ret;
+}
+
 static void
 nfs_async_read_error(struct list_head *head)
 {
@@ -279,7 +298,7 @@ nfs_async_read_error(struct list_head *head)
  * won't see the new data until our attribute cache is updated.  This is more
  * or less conventional NFS client behavior.
  */
-static int nfs_pagein_multi(struct nfs_pageio_descriptor *desc)
+static int nfs_pagein_multi(struct nfs_pageio_descriptor *desc, struct list_head *res)
 {
 	struct nfs_page *req = nfs_list_entry(desc->pg_list.next);
 	struct page *page = req->wb_page;
@@ -288,11 +307,10 @@ static int nfs_pagein_multi(struct nfs_pageio_descriptor *desc)
 	unsigned int offset;
 	int requests = 0;
 	int ret = 0;
-	struct pnfs_layout_segment *lseg = desc->pg_lseg;
-	LIST_HEAD(list);
 
 	nfs_list_remove_request(req);
 
+	offset = 0;
 	nbytes = desc->pg_count;
 	do {
 		size_t len = min(nbytes,rsize);
@@ -300,57 +318,33 @@ static int nfs_pagein_multi(struct nfs_pageio_descriptor *desc)
 		data = nfs_readdata_alloc(1);
 		if (!data)
 			goto out_bad;
-		list_add(&data->list, &list);
+		data->pagevec[0] = page;
+		nfs_read_rpcsetup(req, data, len, offset);
+		list_add(&data->list, res);
 		requests++;
 		nbytes -= len;
+		offset += len;
 	} while(nbytes != 0);
 	atomic_set(&req->wb_complete, requests);
-
 	ClearPageError(page);
-	offset = 0;
-	nbytes = desc->pg_count;
-	do {
-		int ret2;
-
-		data = list_entry(list.next, struct nfs_read_data, list);
-		list_del_init(&data->list);
-
-		data->pagevec[0] = page;
-
-		if (nbytes < rsize)
-			rsize = nbytes;
-		nfs_read_rpcsetup(req, data, rsize, offset);
-		ret2 = nfs_do_read(data, &nfs_read_partial_ops, lseg);
-		if (ret == 0)
-			ret = ret2;
-		offset += rsize;
-		nbytes -= rsize;
-	} while (nbytes != 0);
-	put_lseg(lseg);
-	desc->pg_lseg = NULL;
-
 	return ret;
-
 out_bad:
-	while (!list_empty(&list)) {
-		data = list_entry(list.next, struct nfs_read_data, list);
+	while (!list_empty(res)) {
+		data = list_entry(res->next, struct nfs_read_data, list);
 		list_del(&data->list);
 		nfs_readdata_free(data);
 	}
 	SetPageError(page);
 	nfs_readpage_release(req);
-	put_lseg(lseg);
-	desc->pg_lseg = NULL;
 	return -ENOMEM;
 }
 
-static int nfs_pagein_one(struct nfs_pageio_descriptor *desc)
+static int nfs_pagein_one(struct nfs_pageio_descriptor *desc, struct list_head *res)
 {
 	struct nfs_page		*req;
 	struct page		**pages;
 	struct nfs_read_data	*data;
 	struct list_head *head = &desc->pg_list;
-	struct pnfs_layout_segment *lseg = desc->pg_lseg;
 	int ret = -ENOMEM;
 
 	data = nfs_readdata_alloc(nfs_page_array_len(desc->pg_base,
@@ -371,18 +365,32 @@ static int nfs_pagein_one(struct nfs_pageio_descriptor *desc)
 	req = nfs_list_entry(data->pages.next);
 
 	nfs_read_rpcsetup(req, data, desc->pg_count, 0);
-	ret = nfs_do_read(data, &nfs_read_full_ops, lseg);
+	list_add(&data->list, res);
 out:
-	put_lseg(lseg);
-	desc->pg_lseg = NULL;
 	return ret;
 }
 
 int nfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc)
 {
-	if (desc->pg_bsize < PAGE_CACHE_SIZE)
-		return nfs_pagein_multi(desc);
-	return nfs_pagein_one(desc);
+	LIST_HEAD(head);
+	int ret;
+
+	if (desc->pg_bsize < PAGE_CACHE_SIZE) {
+		ret = nfs_pagein_multi(desc, &head);
+		if (ret == 0)
+			ret = nfs_do_multiple_reads(&head,
+					&nfs_read_partial_ops,
+					desc->pg_lseg);
+	} else {
+		ret = nfs_pagein_one(desc, &head);
+		if (ret == 0)
+			ret = nfs_do_multiple_reads(&head,
+					&nfs_read_full_ops,
+					desc->pg_lseg);
+	}
+	put_lseg(desc->pg_lseg);
+	desc->pg_lseg = NULL;
+	return ret;
 }
 EXPORT_SYMBOL_GPL(nfs_generic_pg_readpages);
 
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 0aeb09b..89cc687 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -903,6 +903,27 @@ static int nfs_do_write(struct nfs_write_data *data,
 	return nfs_initiate_write(data, NFS_CLIENT(inode), call_ops, how);
 }
 
+static int nfs_do_multiple_writes(struct list_head *head,
+		const struct rpc_call_ops *call_ops,
+		struct pnfs_layout_segment *lseg,
+		int how)
+{
+	struct nfs_write_data *data;
+	int ret = 0;
+
+	while (!list_empty(head)) {
+		int ret2;
+
+		data = list_entry(head->next, struct nfs_write_data, list);
+		list_del_init(&data->list);
+		
+		ret2 = nfs_do_write(data, call_ops, lseg, how);
+		 if (ret == 0)
+			 ret = ret2;
+	}
+	return ret;
+}
+
 /* If a nfs_flush_* function fails, it should remove reqs from @head and
  * call this on each, which will prepare them to be retried on next
  * writeback using standard nfs.
@@ -920,7 +941,7 @@ static void nfs_redirty_request(struct nfs_page *req)
  * Generate multiple small requests to write out a single
  * contiguous dirty area on one page.
  */
-static int nfs_flush_multi(struct nfs_pageio_descriptor *desc)
+static int nfs_flush_multi(struct nfs_pageio_descriptor *desc, struct list_head *res)
 {
 	struct nfs_page *req = nfs_list_entry(desc->pg_list.next);
 	struct page *page = req->wb_page;
@@ -929,8 +950,6 @@ static int nfs_flush_multi(struct nfs_pageio_descriptor *desc)
 	unsigned int offset;
 	int requests = 0;
 	int ret = 0;
-	struct pnfs_layout_segment *lseg = desc->pg_lseg;
-	LIST_HEAD(list);
 
 	nfs_list_remove_request(req);
 
@@ -940,6 +959,7 @@ static int nfs_flush_multi(struct nfs_pageio_descriptor *desc)
 		desc->pg_ioflags &= ~FLUSH_COND_STABLE;
 
 
+	offset = 0;
 	nbytes = desc->pg_count;
 	do {
 		size_t len = min(nbytes, wsize);
@@ -947,47 +967,23 @@ static int nfs_flush_multi(struct nfs_pageio_descriptor *desc)
 		data = nfs_writedata_alloc(1);
 		if (!data)
 			goto out_bad;
-		list_add(&data->list, &list);
+		data->pagevec[0] = page;
+		nfs_write_rpcsetup(req, data, wsize, offset, desc->pg_ioflags);
+		list_add(&data->list, res);
 		requests++;
 		nbytes -= len;
+		offset += len;
 	} while (nbytes != 0);
 	atomic_set(&req->wb_complete, requests);
-
-	ClearPageError(page);
-	offset = 0;
-	nbytes = desc->pg_count;
-	do {
-		int ret2;
-
-		data = list_entry(list.next, struct nfs_write_data, list);
-		list_del_init(&data->list);
-
-		data->pagevec[0] = page;
-
-		if (nbytes < wsize)
-			wsize = nbytes;
-		nfs_write_rpcsetup(req, data, wsize, offset, desc->pg_ioflags);
-		ret2 = nfs_do_write(data, &nfs_write_partial_ops, lseg,
-				desc->pg_ioflags);
-		if (ret == 0)
-			ret = ret2;
-		offset += wsize;
-		nbytes -= wsize;
-	} while (nbytes != 0);
-
-	put_lseg(lseg);
-	desc->pg_lseg = NULL;
 	return ret;
 
 out_bad:
-	while (!list_empty(&list)) {
-		data = list_entry(list.next, struct nfs_write_data, list);
+	while (!list_empty(res)) {
+		data = list_entry(res->next, struct nfs_write_data, list);
 		list_del(&data->list);
 		nfs_writedata_free(data);
 	}
 	nfs_redirty_request(req);
-	put_lseg(lseg);
-	desc->pg_lseg = NULL;
 	return -ENOMEM;
 }
 
@@ -999,13 +995,12 @@ out_bad:
  * This is the case if nfs_updatepage detects a conflicting request
  * that has been written but not committed.
  */
-static int nfs_flush_one(struct nfs_pageio_descriptor *desc)
+static int nfs_flush_one(struct nfs_pageio_descriptor *desc, struct list_head *res)
 {
 	struct nfs_page		*req;
 	struct page		**pages;
 	struct nfs_write_data	*data;
 	struct list_head *head = &desc->pg_list;
-	struct pnfs_layout_segment *lseg = desc->pg_lseg;
 	int ret;
 
 	data = nfs_writedata_alloc(nfs_page_array_len(desc->pg_base,
@@ -1035,18 +1030,34 @@ static int nfs_flush_one(struct nfs_pageio_descriptor *desc)
 
 	/* Set up the argument struct */
 	nfs_write_rpcsetup(req, data, desc->pg_count, 0, desc->pg_ioflags);
-	ret = nfs_do_write(data, &nfs_write_full_ops, lseg, desc->pg_ioflags);
+	list_add(&data->list, res);
 out:
-	put_lseg(lseg); /* Cleans any gotten in ->pg_test */
-	desc->pg_lseg = NULL;
 	return ret;
 }
 
 int nfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
 {
-	if (desc->pg_bsize < PAGE_CACHE_SIZE)
-		return nfs_flush_multi(desc);
-	return nfs_flush_one(desc);
+	LIST_HEAD(head);
+	int ret;
+
+	if (desc->pg_bsize < PAGE_CACHE_SIZE) {
+		ret = nfs_flush_multi(desc, &head);
+		if (ret == 0)
+			ret = nfs_do_multiple_writes(&head,
+					&nfs_write_partial_ops,
+					desc->pg_lseg,
+					desc->pg_ioflags);
+	} else {
+		ret = nfs_flush_one(desc, &head);
+		if (ret == 0)
+			ret = nfs_do_multiple_writes(&head,
+					&nfs_write_full_ops,
+					desc->pg_lseg,
+					desc->pg_ioflags);
+	}
+	put_lseg(desc->pg_lseg);
+	desc->pg_lseg = NULL;
+	return ret;
 }
 EXPORT_SYMBOL_GPL(nfs_generic_pg_writepages);
 
-- 
1.7.6


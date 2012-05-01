Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:10364 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752650Ab2EASkX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 May 2012 14:40:23 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH v3 2/3] NFS: Clean up nfs read and write error paths
Date: Tue,  1 May 2012 14:40:19 -0400
Message-Id: <1335897620-17569-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1335897620-17569-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1335897434.4060.17.camel@lade.trondhjem.org>
 <1335897620-17569-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Move the error handling for nfs_generic_pagein() into a single function.
Ditto for nfs_generic_flush().

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c  |    2 --
 fs/nfs/read.c  |   38 +++++++++++++++++++++-----------------
 fs/nfs/write.c |   46 +++++++++++++++++++++++-----------------------
 3 files changed, 44 insertions(+), 42 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 39cbac5..6fdeca2 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1321,7 +1321,6 @@ pnfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
 	if (ret != 0) {
 		put_lseg(desc->pg_lseg);
 		desc->pg_lseg = NULL;
-		set_bit(NFS_IOHDR_REDO, &hdr->flags);
 	} else
 		pnfs_do_multiple_writes(desc, &hdr->rpc_list, desc->pg_ioflags);
 	if (atomic_dec_and_test(&hdr->refcnt))
@@ -1476,7 +1475,6 @@ pnfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc)
 	if (ret != 0) {
 		put_lseg(desc->pg_lseg);
 		desc->pg_lseg = NULL;
-		set_bit(NFS_IOHDR_REDO, &hdr->flags);
 	} else
 		pnfs_do_multiple_reads(desc, &hdr->rpc_list);
 	if (atomic_dec_and_test(&hdr->refcnt))
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 20a0293..1961a19 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -320,6 +320,19 @@ static const struct nfs_pgio_completion_ops nfs_async_read_completion_ops = {
 	.completion = nfs_read_completion,
 };
 
+static void nfs_pagein_error(struct nfs_pageio_descriptor *desc,
+		struct nfs_pgio_header *hdr)
+{
+	set_bit(NFS_IOHDR_REDO, &hdr->flags);
+	while (!list_empty(&hdr->rpc_list)) {
+		struct nfs_read_data *data = list_first_entry(&hdr->rpc_list,
+				struct nfs_read_data, list);
+		list_del(&data->list);
+		nfs_readdata_release(data);
+	}
+	desc->pg_completion_ops->error_cleanup(&desc->pg_list);
+}
+
 /*
  * Generate multiple requests to fill a single page.
  *
@@ -342,33 +355,27 @@ static int nfs_pagein_multi(struct nfs_pageio_descriptor *desc,
 	size_t rsize = desc->pg_bsize, nbytes;
 	unsigned int offset;
 
-	nfs_list_remove_request(req);
-	nfs_list_add_request(req, &hdr->pages);
-
 	offset = 0;
 	nbytes = desc->pg_count;
 	do {
 		size_t len = min(nbytes,rsize);
 
 		data = nfs_readdata_alloc(hdr, 1);
-		if (!data)
-			goto out_bad;
+		if (!data) {
+			nfs_pagein_error(desc, hdr);
+			return -ENOMEM;
+		}
 		data->pages.pagevec[0] = page;
 		nfs_read_rpcsetup(data, len, offset);
 		list_add(&data->list, &hdr->rpc_list);
 		nbytes -= len;
 		offset += len;
 	} while (nbytes != 0);
+
+	nfs_list_remove_request(req);
+	nfs_list_add_request(req, &hdr->pages);
 	desc->pg_rpc_callops = &nfs_read_common_ops;
 	return 0;
-out_bad:
-	while (!list_empty(&hdr->rpc_list)) {
-		data = list_first_entry(&hdr->rpc_list, struct nfs_read_data, list);
-		list_del(&data->list);
-		nfs_readdata_release(data);
-	}
-	desc->pg_completion_ops->error_cleanup(&hdr->pages);
-	return -ENOMEM;
 }
 
 static int nfs_pagein_one(struct nfs_pageio_descriptor *desc,
@@ -378,12 +385,11 @@ static int nfs_pagein_one(struct nfs_pageio_descriptor *desc,
 	struct page		**pages;
 	struct nfs_read_data    *data;
 	struct list_head *head = &desc->pg_list;
-	int ret = 0;
 
 	data = nfs_readdata_alloc(hdr, nfs_page_array_len(desc->pg_base,
 							  desc->pg_count));
 	if (!data) {
-		desc->pg_completion_ops->error_cleanup(head);
+		nfs_pagein_error(desc, hdr);
 		return -ENOMEM;
 	}
 
@@ -427,8 +433,6 @@ static int nfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc)
 	if (ret == 0)
 		ret = nfs_do_multiple_reads(&hdr->rpc_list,
 					    desc->pg_rpc_callops);
-	else
-		set_bit(NFS_IOHDR_REDO, &hdr->flags);
 	if (atomic_dec_and_test(&hdr->refcnt))
 		hdr->completion_ops->completion(hdr);
 	return ret;
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 2f80aa5..d1e4f81 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1058,6 +1058,19 @@ static const struct nfs_pgio_completion_ops nfs_async_write_completion_ops = {
 	.completion = nfs_write_completion,
 };
 
+static void nfs_flush_error(struct nfs_pageio_descriptor *desc,
+		struct nfs_pgio_header *hdr)
+{
+	set_bit(NFS_IOHDR_REDO, &hdr->flags);
+	while (!list_empty(&hdr->rpc_list)) {
+		struct nfs_write_data *data = list_first_entry(&hdr->rpc_list,
+				struct nfs_write_data, list);
+		list_del(&data->list);
+		nfs_writedata_release(data);
+	}
+	desc->pg_completion_ops->error_cleanup(&desc->pg_list);
+}
+
 /*
  * Generate multiple small requests to write out a single
  * contiguous dirty area on one page.
@@ -1071,12 +1084,9 @@ static int nfs_flush_multi(struct nfs_pageio_descriptor *desc,
 	size_t wsize = desc->pg_bsize, nbytes;
 	unsigned int offset;
 	int requests = 0;
-	int ret = 0;
 	struct nfs_commit_info cinfo;
 
 	nfs_init_cinfo(&cinfo, desc->pg_inode, desc->pg_dreq);
-	nfs_list_remove_request(req);
-	nfs_list_add_request(req, &hdr->pages);
 
 	if ((desc->pg_ioflags & FLUSH_COND_STABLE) &&
 	    (desc->pg_moreio || nfs_reqs_to_commit(&cinfo) ||
@@ -1090,8 +1100,10 @@ static int nfs_flush_multi(struct nfs_pageio_descriptor *desc,
 		size_t len = min(nbytes, wsize);
 
 		data = nfs_writedata_alloc(hdr, 1);
-		if (!data)
-			goto out_bad;
+		if (!data) {
+			nfs_flush_error(desc, hdr);
+			return -ENOMEM;
+		}
 		data->pages.pagevec[0] = page;
 		nfs_write_rpcsetup(data, len, offset, desc->pg_ioflags, &cinfo);
 		list_add(&data->list, &hdr->rpc_list);
@@ -1099,17 +1111,10 @@ static int nfs_flush_multi(struct nfs_pageio_descriptor *desc,
 		nbytes -= len;
 		offset += len;
 	} while (nbytes != 0);
+	nfs_list_remove_request(req);
+	nfs_list_add_request(req, &hdr->pages);
 	desc->pg_rpc_callops = &nfs_write_common_ops;
-	return ret;
-
-out_bad:
-	while (!list_empty(&hdr->rpc_list)) {
-		data = list_first_entry(&hdr->rpc_list, struct nfs_write_data, list);
-		list_del(&data->list);
-		nfs_writedata_release(data);
-	}
-	desc->pg_completion_ops->error_cleanup(&hdr->pages);
-	return -ENOMEM;
+	return 0;
 }
 
 /*
@@ -1127,15 +1132,13 @@ static int nfs_flush_one(struct nfs_pageio_descriptor *desc,
 	struct page		**pages;
 	struct nfs_write_data	*data;
 	struct list_head *head = &desc->pg_list;
-	int ret = 0;
 	struct nfs_commit_info cinfo;
 
 	data = nfs_writedata_alloc(hdr, nfs_page_array_len(desc->pg_base,
 							   desc->pg_count));
 	if (!data) {
-		desc->pg_completion_ops->error_cleanup(head);
-		ret = -ENOMEM;
-		goto out;
+		nfs_flush_error(desc, hdr);
+		return -ENOMEM;
 	}
 
 	nfs_init_cinfo(&cinfo, desc->pg_inode, desc->pg_dreq);
@@ -1155,8 +1158,7 @@ static int nfs_flush_one(struct nfs_pageio_descriptor *desc,
 	nfs_write_rpcsetup(data, desc->pg_count, 0, desc->pg_ioflags, &cinfo);
 	list_add(&data->list, &hdr->rpc_list);
 	desc->pg_rpc_callops = &nfs_write_common_ops;
-out:
-	return ret;
+	return 0;
 }
 
 int nfs_generic_flush(struct nfs_pageio_descriptor *desc,
@@ -1186,8 +1188,6 @@ static int nfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
 		ret = nfs_do_multiple_writes(&hdr->rpc_list,
 					     desc->pg_rpc_callops,
 					     desc->pg_ioflags);
-	else
-		set_bit(NFS_IOHDR_REDO, &hdr->flags);
 	if (atomic_dec_and_test(&hdr->refcnt))
 		hdr->completion_ops->completion(hdr);
 	return ret;
-- 
1.7.7.6


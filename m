Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:15489 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932160AbaDYU40 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Apr 2014 16:56:26 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <dros@primarydata.com>, <hch@infradead.org>
Subject: [PATCH v2 12/17] NFS: Create a common pgio_error function
Date: Fri, 25 Apr 2014 16:55:55 -0400
Message-ID: <1398459360-2093-13-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1398459360-2093-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1398459360-2093-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@netapp.com>

At this point, the read and write versions of this function look
identical so both should use the same function.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/internal.h |  1 +
 fs/nfs/pageio.c   | 15 +++++++++++++++
 fs/nfs/read.c     | 25 ++++---------------------
 fs/nfs/write.c    | 25 ++++---------------------
 4 files changed, 24 insertions(+), 42 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 7bc36ee..383175e 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -401,6 +401,7 @@ extern struct nfs_rw_header *nfs_rw_header_alloc(const struct nfs_rw_ops *);
 extern void nfs_rw_header_free(struct nfs_pgio_header *);
 extern struct nfs_pgio_data *nfs_pgio_data_alloc(struct nfs_pgio_header *, unsigned int);
 extern void nfs_pgio_data_release(struct nfs_pgio_data *);
+extern int nfs_pgio_error(struct nfs_pageio_descriptor *, struct nfs_pgio_header *);
 extern void nfs_pgio_rpcsetup(struct nfs_pgio_data *, unsigned int,
 			      unsigned int, int, struct nfs_commit_info *);
 
diff --git a/fs/nfs/pageio.c b/fs/nfs/pageio.c
index 26f558e..ff8a702 100644
--- a/fs/nfs/pageio.c
+++ b/fs/nfs/pageio.c
@@ -123,6 +123,21 @@ void nfs_pgio_rpcsetup(struct nfs_pgio_data *data,
 	nfs_fattr_init(&data->fattr);
 }
 
+int nfs_pgio_error(struct nfs_pageio_descriptor *desc,
+			  struct nfs_pgio_header *hdr)
+{
+	struct nfs_pgio_data *data;
+
+	set_bit(NFS_IOHDR_REDO, &hdr->flags);
+	while (!list_empty(&hdr->rpc_list)) {
+		data = list_first_entry(&hdr->rpc_list, struct nfs_pgio_data, list);
+		list_del(&data->list);
+		nfs_pgio_data_release(data);
+	}
+	desc->pg_completion_ops->error_cleanup(&desc->pg_list);
+	return -ENOMEM;
+}
+
 static void nfs_pgio_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs_pgio_data *data = calldata;
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 2c33fc3..c623671 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -237,19 +237,6 @@ static const struct nfs_pgio_completion_ops nfs_async_read_completion_ops = {
 	.completion = nfs_read_completion,
 };
 
-static void nfs_pagein_error(struct nfs_pageio_descriptor *desc,
-		struct nfs_pgio_header *hdr)
-{
-	set_bit(NFS_IOHDR_REDO, &hdr->flags);
-	while (!list_empty(&hdr->rpc_list)) {
-		struct nfs_pgio_data *data = list_first_entry(&hdr->rpc_list,
-				struct nfs_pgio_data, list);
-		list_del(&data->list);
-		nfs_pgio_data_release(data);
-	}
-	desc->pg_completion_ops->error_cleanup(&desc->pg_list);
-}
-
 /*
  * Generate multiple requests to fill a single page.
  *
@@ -278,10 +265,8 @@ static int nfs_pagein_multi(struct nfs_pageio_descriptor *desc,
 		size_t len = min(nbytes,rsize);
 
 		data = nfs_pgio_data_alloc(hdr, 1);
-		if (!data) {
-			nfs_pagein_error(desc, hdr);
-			return -ENOMEM;
-		}
+		if (!data)
+			return nfs_pgio_error(desc, hdr);
 		data->pages.pagevec[0] = page;
 		nfs_pgio_rpcsetup(data, len, offset, 0, NULL);
 		list_add(&data->list, &hdr->rpc_list);
@@ -305,10 +290,8 @@ static int nfs_pagein_one(struct nfs_pageio_descriptor *desc,
 
 	data = nfs_pgio_data_alloc(hdr, nfs_page_array_len(desc->pg_base,
 							  desc->pg_count));
-	if (!data) {
-		nfs_pagein_error(desc, hdr);
-		return -ENOMEM;
-	}
+	if (!data)
+		return nfs_pgio_error(desc, hdr);
 
 	pages = data->pages.pagevec;
 	while (!list_empty(head)) {
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 15f2ffc..1f98f31 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1044,19 +1044,6 @@ static const struct nfs_pgio_completion_ops nfs_async_write_completion_ops = {
 	.completion = nfs_write_completion,
 };
 
-static void nfs_flush_error(struct nfs_pageio_descriptor *desc,
-		struct nfs_pgio_header *hdr)
-{
-	set_bit(NFS_IOHDR_REDO, &hdr->flags);
-	while (!list_empty(&hdr->rpc_list)) {
-		struct nfs_pgio_data *data = list_first_entry(&hdr->rpc_list,
-				struct nfs_pgio_data, list);
-		list_del(&data->list);
-		nfs_pgio_data_release(data);
-	}
-	desc->pg_completion_ops->error_cleanup(&desc->pg_list);
-}
-
 /*
  * Generate multiple small requests to write out a single
  * contiguous dirty area on one page.
@@ -1086,10 +1073,8 @@ static int nfs_flush_multi(struct nfs_pageio_descriptor *desc,
 		size_t len = min(nbytes, wsize);
 
 		data = nfs_pgio_data_alloc(hdr, 1);
-		if (!data) {
-			nfs_flush_error(desc, hdr);
-			return -ENOMEM;
-		}
+		if (!data)
+			return nfs_pgio_error(desc, hdr);
 		data->pages.pagevec[0] = page;
 		nfs_pgio_rpcsetup(data, len, offset, desc->pg_ioflags, &cinfo);
 		list_add(&data->list, &hdr->rpc_list);
@@ -1122,10 +1107,8 @@ static int nfs_flush_one(struct nfs_pageio_descriptor *desc,
 
 	data = nfs_pgio_data_alloc(hdr, nfs_page_array_len(desc->pg_base,
 							   desc->pg_count));
-	if (!data) {
-		nfs_flush_error(desc, hdr);
-		return -ENOMEM;
-	}
+	if (!data)
+		return nfs_pgio_error(desc, hdr);
 
 	nfs_init_cinfo(&cinfo, desc->pg_inode, desc->pg_dreq);
 	pages = data->pages.pagevec;
-- 
1.9.2


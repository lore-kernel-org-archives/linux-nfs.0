Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:31635 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751180AbaDQVKD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Apr 2014 17:10:03 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 06/17] NFS: Create a common pgio_alloc and pgio_release function
Date: Thu, 17 Apr 2014 17:09:30 -0400
Message-ID: <1397768981-12856-7-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1397768981-12856-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1397768981-12856-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@netapp.com>

These functions are identical for the read and write paths, so combine
them in a shared file.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/Makefile   |  2 +-
 fs/nfs/internal.h |  7 +++++--
 fs/nfs/pageio.c   | 63 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/pnfs.c     |  4 ++--
 fs/nfs/read.c     | 54 ++++-------------------------------------------
 fs/nfs/write.c    | 54 ++++-------------------------------------------
 6 files changed, 79 insertions(+), 105 deletions(-)
 create mode 100644 fs/nfs/pageio.c

diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index 03192a6..551d82a 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -7,7 +7,7 @@ obj-$(CONFIG_NFS_FS) += nfs.o
 CFLAGS_nfstrace.o += -I$(src)
 nfs-y 			:= client.o dir.o file.o getroot.o inode.o super.o \
 			   direct.o pagelist.o read.o symlink.o unlink.o \
-			   write.o namespace.o mount_clnt.o nfstrace.o
+			   write.o namespace.o mount_clnt.o nfstrace.o pageio.o
 nfs-$(CONFIG_ROOT_NFS)	+= nfsroot.o
 nfs-$(CONFIG_SYSCTL)	+= sysctl.o
 nfs-$(CONFIG_NFS_FSCACHE) += fscache.o fscache-index.o
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index b0e7a41..7f9d3c4 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -394,6 +394,11 @@ extern int nfs4_get_rootfh(struct nfs_server *server, struct nfs_fh *mntfh, bool
 #endif
 
 struct nfs_pgio_completion_ops;
+
+/* pageio.c */
+extern struct nfs_pgio_data *nfs_pgio_data_alloc(struct nfs_pgio_header *, unsigned int);
+extern void nfs_pgio_data_release(struct nfs_pgio_data *);
+
 /* read.c */
 extern struct nfs_rw_header *nfs_readhdr_alloc(void);
 extern void nfs_readhdr_free(struct nfs_pgio_header *hdr);
@@ -407,7 +412,6 @@ extern void nfs_read_prepare(struct rpc_task *task, void *calldata);
 extern int nfs_generic_pagein(struct nfs_pageio_descriptor *desc,
 			      struct nfs_pgio_header *hdr);
 extern void nfs_pageio_reset_read_mds(struct nfs_pageio_descriptor *pgio);
-extern void nfs_readdata_release(struct nfs_pgio_data *rdata);
 
 /* super.c */
 void nfs_clone_super(struct super_block *, struct nfs_mount_info *);
@@ -429,7 +433,6 @@ extern void nfs_writehdr_free(struct nfs_pgio_header *hdr);
 extern int nfs_generic_flush(struct nfs_pageio_descriptor *desc,
 			     struct nfs_pgio_header *hdr);
 extern void nfs_pageio_reset_write_mds(struct nfs_pageio_descriptor *pgio);
-extern void nfs_writedata_release(struct nfs_pgio_data *wdata);
 extern void nfs_commit_free(struct nfs_commit_data *p);
 extern int nfs_initiate_write(struct rpc_clnt *clnt,
 			      struct nfs_pgio_data *data,
diff --git a/fs/nfs/pageio.c b/fs/nfs/pageio.c
new file mode 100644
index 0000000..4b267b2
--- /dev/null
+++ b/fs/nfs/pageio.c
@@ -0,0 +1,63 @@
+/*
+ * linux/fs/nfs/pageio.c
+ *
+ * Generic pageio functions shared by read and write paths
+ *
+ * Copyright (c) 2014 Anna Schumaker <anna.schumaker@netapp.com>
+ */
+#include <linux/nfs_fs.h>
+#include <linux/nfs_xdr.h>
+
+#include "internal.h"
+
+
+static inline struct nfs_rw_header *NFS_RW_HEADER(struct nfs_pgio_header *hdr)
+{
+	return container_of(hdr, struct nfs_rw_header, header);
+}
+
+struct nfs_pgio_data *nfs_pgio_data_alloc(struct nfs_pgio_header *hdr,
+					  unsigned int pagecount)
+{
+	struct nfs_pgio_data *data, *prealloc;
+
+	prealloc = &NFS_RW_HEADER(hdr)->rpc_data;
+	if (prealloc->header == NULL)
+		data = prealloc;
+	else
+		data = kzalloc(sizeof(*data), GFP_KERNEL);
+	if (!data)
+		goto out;
+
+	if (nfs_pgarray_set(&data->pages, pagecount)) {
+		data->header = hdr;
+		atomic_inc(&hdr->refcnt);
+	} else {
+		if (data != prealloc)
+			kfree(data);
+		data = NULL;
+	}
+out:
+	return data;
+}
+
+void nfs_pgio_data_release(struct nfs_pgio_data *data)
+{
+	struct nfs_pgio_header *hdr = data->header;
+	struct nfs_rw_header *pageio_header = NFS_RW_HEADER(hdr);
+
+	put_nfs_open_context(data->args.context);
+	if (data->pages.pagevec != data->pages.page_array)
+		kfree(data->pages.pagevec);
+	if (data == &pageio_header->rpc_data) {
+		data->header = NULL;
+		data = NULL;
+	}
+	if (atomic_dec_and_test(&hdr->refcnt))
+		hdr->completion_ops->completion(hdr);
+	/* Note: we only free the rpc_task after callbacks are done.
+	 * See the comment in rpc_free_task() for why
+	 */
+	kfree(data);
+}
+EXPORT_SYMBOL_GPL(nfs_pgio_data_release);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 43cfe11..e192ba6 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1536,7 +1536,7 @@ pnfs_write_through_mds(struct nfs_pageio_descriptor *desc,
 		nfs_pageio_reset_write_mds(desc);
 		desc->pg_recoalesce = 1;
 	}
-	nfs_writedata_release(data);
+	nfs_pgio_data_release(data);
 }
 
 static enum pnfs_try_status
@@ -1691,7 +1691,7 @@ pnfs_read_through_mds(struct nfs_pageio_descriptor *desc,
 		nfs_pageio_reset_read_mds(desc);
 		desc->pg_recoalesce = 1;
 	}
-	nfs_readdata_release(data);
+	nfs_pgio_data_release(data);
 }
 
 /*
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index d29ca36..ab4c1a5 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -51,31 +51,6 @@ struct nfs_rw_header *nfs_readhdr_alloc(void)
 }
 EXPORT_SYMBOL_GPL(nfs_readhdr_alloc);
 
-static struct nfs_pgio_data *nfs_readdata_alloc(struct nfs_pgio_header *hdr,
-						unsigned int pagecount)
-{
-	struct nfs_pgio_data *data, *prealloc;
-
-	prealloc = &container_of(hdr, struct nfs_rw_header, header)->rpc_data;
-	if (prealloc->header == NULL)
-		data = prealloc;
-	else
-		data = kzalloc(sizeof(*data), GFP_KERNEL);
-	if (!data)
-		goto out;
-
-	if (nfs_pgarray_set(&data->pages, pagecount)) {
-		data->header = hdr;
-		atomic_inc(&hdr->refcnt);
-	} else {
-		if (data != prealloc)
-			kfree(data);
-		data = NULL;
-	}
-out:
-	return data;
-}
-
 void nfs_readhdr_free(struct nfs_pgio_header *hdr)
 {
 	struct nfs_rw_header *rhdr = container_of(hdr, struct nfs_rw_header, header);
@@ -84,27 +59,6 @@ void nfs_readhdr_free(struct nfs_pgio_header *hdr)
 }
 EXPORT_SYMBOL_GPL(nfs_readhdr_free);
 
-void nfs_readdata_release(struct nfs_pgio_data *rdata)
-{
-	struct nfs_pgio_header *hdr = rdata->header;
-	struct nfs_rw_header *read_header = container_of(hdr, struct nfs_rw_header, header);
-
-	put_nfs_open_context(rdata->args.context);
-	if (rdata->pages.pagevec != rdata->pages.page_array)
-		kfree(rdata->pages.pagevec);
-	if (rdata == &read_header->rpc_data) {
-		rdata->header = NULL;
-		rdata = NULL;
-	}
-	if (atomic_dec_and_test(&hdr->refcnt))
-		hdr->completion_ops->completion(hdr);
-	/* Note: we only free the rpc_task after callbacks are done.
-	 * See the comment in rpc_free_task() for why
-	 */
-	kfree(rdata);
-}
-EXPORT_SYMBOL_GPL(nfs_readdata_release);
-
 static
 int nfs_return_empty_page(struct page *page)
 {
@@ -327,7 +281,7 @@ static void nfs_pagein_error(struct nfs_pageio_descriptor *desc,
 		struct nfs_pgio_data *data = list_first_entry(&hdr->rpc_list,
 				struct nfs_pgio_data, list);
 		list_del(&data->list);
-		nfs_readdata_release(data);
+		nfs_pgio_data_release(data);
 	}
 	desc->pg_completion_ops->error_cleanup(&desc->pg_list);
 }
@@ -359,7 +313,7 @@ static int nfs_pagein_multi(struct nfs_pageio_descriptor *desc,
 	do {
 		size_t len = min(nbytes,rsize);
 
-		data = nfs_readdata_alloc(hdr, 1);
+		data = nfs_pgio_data_alloc(hdr, 1);
 		if (!data) {
 			nfs_pagein_error(desc, hdr);
 			return -ENOMEM;
@@ -385,7 +339,7 @@ static int nfs_pagein_one(struct nfs_pageio_descriptor *desc,
 	struct nfs_pgio_data	*data;
 	struct list_head *head = &desc->pg_list;
 
-	data = nfs_readdata_alloc(hdr, nfs_page_array_len(desc->pg_base,
+	data = nfs_pgio_data_alloc(hdr, nfs_page_array_len(desc->pg_base,
 							  desc->pg_count));
 	if (!data) {
 		nfs_pagein_error(desc, hdr);
@@ -515,7 +469,7 @@ static void nfs_readpage_result_common(struct rpc_task *task, void *calldata)
 
 static void nfs_readpage_release_common(void *calldata)
 {
-	nfs_readdata_release(calldata);
+	nfs_pgio_data_release(calldata);
 }
 
 void nfs_read_prepare(struct rpc_task *task, void *calldata)
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 321a791..0dc4d6a 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -87,31 +87,6 @@ struct nfs_rw_header *nfs_writehdr_alloc(void)
 }
 EXPORT_SYMBOL_GPL(nfs_writehdr_alloc);
 
-static struct nfs_pgio_data *nfs_writedata_alloc(struct nfs_pgio_header *hdr,
-						  unsigned int pagecount)
-{
-	struct nfs_pgio_data *data, *prealloc;
-
-	prealloc = &container_of(hdr, struct nfs_rw_header, header)->rpc_data;
-	if (prealloc->header == NULL)
-		data = prealloc;
-	else
-		data = kzalloc(sizeof(*data), GFP_KERNEL);
-	if (!data)
-		goto out;
-
-	if (nfs_pgarray_set(&data->pages, pagecount)) {
-		data->header = hdr;
-		atomic_inc(&hdr->refcnt);
-	} else {
-		if (data != prealloc)
-			kfree(data);
-		data = NULL;
-	}
-out:
-	return data;
-}
-
 void nfs_writehdr_free(struct nfs_pgio_header *hdr)
 {
 	struct nfs_rw_header *whdr = container_of(hdr, struct nfs_rw_header, header);
@@ -119,27 +94,6 @@ void nfs_writehdr_free(struct nfs_pgio_header *hdr)
 }
 EXPORT_SYMBOL_GPL(nfs_writehdr_free);
 
-void nfs_writedata_release(struct nfs_pgio_data *wdata)
-{
-	struct nfs_pgio_header *hdr = wdata->header;
-	struct nfs_rw_header *write_header = container_of(hdr, struct nfs_rw_header, header);
-
-	put_nfs_open_context(wdata->args.context);
-	if (wdata->pages.pagevec != wdata->pages.page_array)
-		kfree(wdata->pages.pagevec);
-	if (wdata == &write_header->rpc_data) {
-		wdata->header = NULL;
-		wdata = NULL;
-	}
-	if (atomic_dec_and_test(&hdr->refcnt))
-		hdr->completion_ops->completion(hdr);
-	/* Note: we only free the rpc_task after callbacks are done.
-	 * See the comment in rpc_free_task() for why
-	 */
-	kfree(wdata);
-}
-EXPORT_SYMBOL_GPL(nfs_writedata_release);
-
 static void nfs_context_set_write_error(struct nfs_open_context *ctx, int error)
 {
 	ctx->error = error;
@@ -1146,7 +1100,7 @@ static void nfs_flush_error(struct nfs_pageio_descriptor *desc,
 		struct nfs_pgio_data *data = list_first_entry(&hdr->rpc_list,
 				struct nfs_pgio_data, list);
 		list_del(&data->list);
-		nfs_writedata_release(data);
+		nfs_pgio_data_release(data);
 	}
 	desc->pg_completion_ops->error_cleanup(&desc->pg_list);
 }
@@ -1179,7 +1133,7 @@ static int nfs_flush_multi(struct nfs_pageio_descriptor *desc,
 	do {
 		size_t len = min(nbytes, wsize);
 
-		data = nfs_writedata_alloc(hdr, 1);
+		data = nfs_pgio_data_alloc(hdr, 1);
 		if (!data) {
 			nfs_flush_error(desc, hdr);
 			return -ENOMEM;
@@ -1214,7 +1168,7 @@ static int nfs_flush_one(struct nfs_pageio_descriptor *desc,
 	struct list_head *head = &desc->pg_list;
 	struct nfs_commit_info cinfo;
 
-	data = nfs_writedata_alloc(hdr, nfs_page_array_len(desc->pg_base,
+	data = nfs_pgio_data_alloc(hdr, nfs_page_array_len(desc->pg_base,
 							   desc->pg_count));
 	if (!data) {
 		nfs_flush_error(desc, hdr);
@@ -1348,7 +1302,7 @@ static void nfs_writeback_release_common(void *calldata)
 			set_bit(NFS_IOHDR_NEED_RESCHED, &hdr->flags);
 		spin_unlock(&hdr->lock);
 	}
-	nfs_writedata_release(data);
+	nfs_pgio_data_release(data);
 }
 
 static const struct rpc_call_ops nfs_write_common_ops = {
-- 
1.9.2


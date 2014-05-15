Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f170.google.com ([209.85.223.170]:64989 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755192AbaEOP5b (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 May 2014 11:57:31 -0400
Received: by mail-ie0-f170.google.com with SMTP id ar20so1246312iec.1
        for <linux-nfs@vger.kernel.org>; Thu, 15 May 2014 08:57:31 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH v3 14/18] nfs: remove data list from pgio header
Date: Thu, 15 May 2014 11:56:53 -0400
Message-Id: <1400169417-28245-15-git-send-email-dros@primarydata.com>
In-Reply-To: <1400169417-28245-1-git-send-email-dros@primarydata.com>
References: <1400169417-28245-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since the ability to split pages into subpage requests has been added,
nfs_pgio_header->rpc_list only ever has one pgio data.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 fs/nfs/pagelist.c       | 39 ++++++---------------------------------
 fs/nfs/pnfs.c           | 41 +++++++++++++++--------------------------
 include/linux/nfs_xdr.h |  5 +++--
 3 files changed, 24 insertions(+), 61 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 0871a95..0c4aac4 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -470,7 +470,6 @@ struct nfs_rw_header *nfs_rw_header_alloc(const struct nfs_rw_ops *ops)
 		struct nfs_pgio_header *hdr = &header->header;
 
 		INIT_LIST_HEAD(&hdr->pages);
-		INIT_LIST_HEAD(&hdr->rpc_list);
 		spin_lock_init(&hdr->lock);
 		atomic_set(&hdr->refcnt, 0);
 		hdr->rw_ops = ops;
@@ -649,27 +648,6 @@ out:
 }
 EXPORT_SYMBOL_GPL(nfs_initiate_pgio);
 
-static int nfs_do_multiple_pgios(struct list_head *head,
-				 const struct rpc_call_ops *call_ops,
-				 int how)
-{
-	struct nfs_pgio_data *data;
-	int ret = 0;
-
-	while (!list_empty(head)) {
-		int ret2;
-
-		data = list_first_entry(head, struct nfs_pgio_data, list);
-		list_del_init(&data->list);
-
-		ret2 = nfs_initiate_pgio(NFS_CLIENT(data->header->inode),
-					 data, call_ops, how, 0);
-		if (ret == 0)
-			 ret = ret2;
-	}
-	return ret;
-}
-
 /**
  * nfs_pgio_error - Clean up from a pageio error
  * @desc: IO descriptor
@@ -678,14 +656,9 @@ static int nfs_do_multiple_pgios(struct list_head *head,
 static int nfs_pgio_error(struct nfs_pageio_descriptor *desc,
 			  struct nfs_pgio_header *hdr)
 {
-	struct nfs_pgio_data *data;
-
 	set_bit(NFS_IOHDR_REDO, &hdr->flags);
-	while (!list_empty(&hdr->rpc_list)) {
-		data = list_first_entry(&hdr->rpc_list, struct nfs_pgio_data, list);
-		list_del(&data->list);
-		nfs_pgio_data_release(data);
-	}
+	nfs_pgio_data_release(hdr->data);
+	hdr->data = NULL;
 	desc->pg_completion_ops->error_cleanup(&desc->pg_list);
 	return -ENOMEM;
 }
@@ -795,7 +768,7 @@ int nfs_generic_pgio(struct nfs_pageio_descriptor *desc,
 
 	/* Set up the argument struct */
 	nfs_pgio_rpcsetup(data, desc->pg_count, 0, desc->pg_ioflags, &cinfo);
-	list_add(&data->list, &hdr->rpc_list);
+	hdr->data = data;
 	desc->pg_rpc_callops = &nfs_pgio_common_ops;
 	return 0;
 }
@@ -817,9 +790,9 @@ static int nfs_generic_pg_pgios(struct nfs_pageio_descriptor *desc)
 	atomic_inc(&hdr->refcnt);
 	ret = nfs_generic_pgio(desc, hdr);
 	if (ret == 0)
-		ret = nfs_do_multiple_pgios(&hdr->rpc_list,
-					    desc->pg_rpc_callops,
-					    desc->pg_ioflags);
+		ret = nfs_initiate_pgio(NFS_CLIENT(hdr->inode),
+					hdr->data, desc->pg_rpc_callops,
+					desc->pg_ioflags, 0);
 	if (atomic_dec_and_test(&hdr->refcnt))
 		hdr->completion_ops->completion(hdr);
 	return ret;
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 354c53c..6ef108b 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1573,23 +1573,18 @@ pnfs_try_to_write_data(struct nfs_pgio_data *wdata,
 }
 
 static void
-pnfs_do_multiple_writes(struct nfs_pageio_descriptor *desc, struct list_head *head, int how)
+pnfs_do_write(struct nfs_pageio_descriptor *desc,
+	      struct nfs_pgio_header *hdr, int how)
 {
-	struct nfs_pgio_data *data;
+	struct nfs_pgio_data *data = hdr->data;
 	const struct rpc_call_ops *call_ops = desc->pg_rpc_callops;
 	struct pnfs_layout_segment *lseg = desc->pg_lseg;
+	enum pnfs_try_status trypnfs;
 
 	desc->pg_lseg = NULL;
-	while (!list_empty(head)) {
-		enum pnfs_try_status trypnfs;
-
-		data = list_first_entry(head, struct nfs_pgio_data, list);
-		list_del_init(&data->list);
-
-		trypnfs = pnfs_try_to_write_data(data, call_ops, lseg, how);
-		if (trypnfs == PNFS_NOT_ATTEMPTED)
-			pnfs_write_through_mds(desc, data);
-	}
+	trypnfs = pnfs_try_to_write_data(data, call_ops, lseg, how);
+	if (trypnfs == PNFS_NOT_ATTEMPTED)
+		pnfs_write_through_mds(desc, data);
 	pnfs_put_lseg(lseg);
 }
 
@@ -1623,7 +1618,7 @@ pnfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
 		pnfs_put_lseg(desc->pg_lseg);
 		desc->pg_lseg = NULL;
 	} else
-		pnfs_do_multiple_writes(desc, &hdr->rpc_list, desc->pg_ioflags);
+		pnfs_do_write(desc, hdr, desc->pg_ioflags);
 	if (atomic_dec_and_test(&hdr->refcnt))
 		hdr->completion_ops->completion(hdr);
 	return ret;
@@ -1731,23 +1726,17 @@ pnfs_try_to_read_data(struct nfs_pgio_data *rdata,
 }
 
 static void
-pnfs_do_multiple_reads(struct nfs_pageio_descriptor *desc, struct list_head *head)
+pnfs_do_read(struct nfs_pageio_descriptor *desc, struct nfs_pgio_header *hdr)
 {
-	struct nfs_pgio_data *data;
+	struct nfs_pgio_data *data = hdr->data;
 	const struct rpc_call_ops *call_ops = desc->pg_rpc_callops;
 	struct pnfs_layout_segment *lseg = desc->pg_lseg;
+	enum pnfs_try_status trypnfs;
 
 	desc->pg_lseg = NULL;
-	while (!list_empty(head)) {
-		enum pnfs_try_status trypnfs;
-
-		data = list_first_entry(head, struct nfs_pgio_data, list);
-		list_del_init(&data->list);
-
-		trypnfs = pnfs_try_to_read_data(data, call_ops, lseg);
-		if (trypnfs == PNFS_NOT_ATTEMPTED)
-			pnfs_read_through_mds(desc, data);
-	}
+	trypnfs = pnfs_try_to_read_data(data, call_ops, lseg);
+	if (trypnfs == PNFS_NOT_ATTEMPTED)
+		pnfs_read_through_mds(desc, data);
 	pnfs_put_lseg(lseg);
 }
 
@@ -1782,7 +1771,7 @@ pnfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc)
 		pnfs_put_lseg(desc->pg_lseg);
 		desc->pg_lseg = NULL;
 	} else
-		pnfs_do_multiple_reads(desc, &hdr->rpc_list);
+		pnfs_do_read(desc, hdr);
 	if (atomic_dec_and_test(&hdr->refcnt))
 		hdr->completion_ops->completion(hdr);
 	return ret;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index adef7bd..ae63601 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1256,11 +1256,13 @@ enum {
 	NFS_IOHDR_NEED_RESCHED,
 };
 
+struct nfs_pgio_data;
+
 struct nfs_pgio_header {
 	struct inode		*inode;
 	struct rpc_cred		*cred;
 	struct list_head	pages;
-	struct list_head	rpc_list;
+	struct nfs_pgio_data	*data;
 	atomic_t		refcnt;
 	struct nfs_page		*req;
 	struct nfs_writeverf	verf;		/* Used for writes */
@@ -1282,7 +1284,6 @@ struct nfs_pgio_header {
 
 struct nfs_pgio_data {
 	struct nfs_pgio_header	*header;
-	struct list_head	list;
 	struct rpc_task		task;
 	struct nfs_fattr	fattr;
 	struct nfs_writeverf	verf;		/* Used for writes */
-- 
1.8.5.2 (Apple Git-48)


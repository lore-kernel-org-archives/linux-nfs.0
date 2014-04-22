Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:35941 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757973AbaDVV3R (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Apr 2014 17:29:17 -0400
Received: by mail-ie0-f174.google.com with SMTP id rp18so71952iec.5
        for <linux-nfs@vger.kernel.org>; Tue, 22 Apr 2014 14:29:17 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH 13/17] nfs: remove list of [rw]data from pgio header
Date: Tue, 22 Apr 2014 17:29:21 -0400
Message-Id: <1398202165-78897-14-git-send-email-dros@primarydata.com>
In-Reply-To: <1398202165-78897-1-git-send-email-dros@primarydata.com>
References: <1398202165-78897-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since the ability to split pages into subpage requests has been added,
nfs_pgio_header->rpc_list only ever has one wdata/rdata.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 fs/nfs/pnfs.c           | 41 +++++++++++++++--------------------------
 fs/nfs/read.c           | 35 +++++------------------------------
 fs/nfs/write.c          | 38 +++++++-------------------------------
 include/linux/nfs_xdr.h | 35 ++++++++++++++++++-----------------
 4 files changed, 45 insertions(+), 104 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 7c89385..3b3ec46 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1600,23 +1600,18 @@ pnfs_try_to_write_data(struct nfs_write_data *wdata,
 }
 
 static void
-pnfs_do_multiple_writes(struct nfs_pageio_descriptor *desc, struct list_head *head, int how)
+pnfs_do_write(struct nfs_pageio_descriptor *desc,
+	      struct nfs_pgio_header *hdr, int how)
 {
-	struct nfs_write_data *data;
+	struct nfs_write_data *data = hdr->data.write;
 	const struct rpc_call_ops *call_ops = desc->pg_rpc_callops;
 	struct pnfs_layout_segment *lseg = desc->pg_lseg;
+	enum pnfs_try_status trypnfs;
 
 	desc->pg_lseg = NULL;
-	while (!list_empty(head)) {
-		enum pnfs_try_status trypnfs;
-
-		data = list_first_entry(head, struct nfs_write_data, list);
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
 
@@ -1650,7 +1645,7 @@ pnfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
 		pnfs_put_lseg(desc->pg_lseg);
 		desc->pg_lseg = NULL;
 	} else
-		pnfs_do_multiple_writes(desc, &hdr->rpc_list, desc->pg_ioflags);
+		pnfs_do_write(desc, hdr, desc->pg_ioflags);
 	if (atomic_dec_and_test(&hdr->refcnt))
 		hdr->completion_ops->completion(hdr);
 	return ret;
@@ -1758,23 +1753,17 @@ pnfs_try_to_read_data(struct nfs_read_data *rdata,
 }
 
 static void
-pnfs_do_multiple_reads(struct nfs_pageio_descriptor *desc, struct list_head *head)
+pnfs_do_read(struct nfs_pageio_descriptor *desc, struct nfs_pgio_header *hdr)
 {
-	struct nfs_read_data *data;
+	struct nfs_read_data *data = hdr->data.read;
 	const struct rpc_call_ops *call_ops = desc->pg_rpc_callops;
 	struct pnfs_layout_segment *lseg = desc->pg_lseg;
+	enum pnfs_try_status trypnfs;
 
 	desc->pg_lseg = NULL;
-	while (!list_empty(head)) {
-		enum pnfs_try_status trypnfs;
-
-		data = list_first_entry(head, struct nfs_read_data, list);
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
 
@@ -1809,7 +1798,7 @@ pnfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc)
 		pnfs_put_lseg(desc->pg_lseg);
 		desc->pg_lseg = NULL;
 	} else
-		pnfs_do_multiple_reads(desc, &hdr->rpc_list);
+		pnfs_do_read(desc, hdr);
 	if (atomic_dec_and_test(&hdr->refcnt))
 		hdr->completion_ops->completion(hdr);
 	return ret;
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index daeff0c..c6b7dd0 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -42,7 +42,6 @@ struct nfs_read_header *nfs_readhdr_alloc(void)
 		struct nfs_pgio_header *hdr = &rhdr->header;
 
 		INIT_LIST_HEAD(&hdr->pages);
-		INIT_LIST_HEAD(&hdr->rpc_list);
 		spin_lock_init(&hdr->lock);
 		atomic_set(&hdr->refcnt, 0);
 	}
@@ -286,26 +285,6 @@ static int nfs_do_read(struct nfs_read_data *data,
 	return nfs_initiate_read(NFS_CLIENT(inode), data, call_ops, 0);
 }
 
-static int
-nfs_do_multiple_reads(struct list_head *head,
-		const struct rpc_call_ops *call_ops)
-{
-	struct nfs_read_data *data;
-	int ret = 0;
-
-	while (!list_empty(head)) {
-		int ret2;
-
-		data = list_first_entry(head, struct nfs_read_data, list);
-		list_del_init(&data->list);
-
-		ret2 = nfs_do_read(data, call_ops);
-		if (ret == 0)
-			ret = ret2;
-	}
-	return ret;
-}
-
 static void
 nfs_async_read_error(struct list_head *head)
 {
@@ -327,12 +306,8 @@ static void nfs_pagein_error(struct nfs_pageio_descriptor *desc,
 		struct nfs_pgio_header *hdr)
 {
 	set_bit(NFS_IOHDR_REDO, &hdr->flags);
-	while (!list_empty(&hdr->rpc_list)) {
-		struct nfs_read_data *data = list_first_entry(&hdr->rpc_list,
-				struct nfs_read_data, list);
-		list_del(&data->list);
-		nfs_readdata_release(data);
-	}
+	nfs_readdata_release(hdr->data.read);
+	hdr->data.read = NULL;
 	desc->pg_completion_ops->error_cleanup(&desc->pg_list);
 }
 
@@ -364,7 +339,8 @@ int nfs_generic_pagein(struct nfs_pageio_descriptor *desc,
 	}
 
 	nfs_read_rpcsetup(data, desc->pg_count, 0);
-	list_add(&data->list, &hdr->rpc_list);
+	WARN_ON_ONCE(hdr->data.read);
+	hdr->data.read = data;
 	desc->pg_rpc_callops = &nfs_read_common_ops;
 	return 0;
 }
@@ -386,8 +362,7 @@ static int nfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc)
 	atomic_inc(&hdr->refcnt);
 	ret = nfs_generic_pagein(desc, hdr);
 	if (ret == 0)
-		ret = nfs_do_multiple_reads(&hdr->rpc_list,
-					    desc->pg_rpc_callops);
+		ret = nfs_do_read(hdr->data.read, desc->pg_rpc_callops);
 	if (atomic_dec_and_test(&hdr->refcnt))
 		hdr->completion_ops->completion(hdr);
 	return ret;
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index f40db93..cd24a14 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -79,7 +79,6 @@ struct nfs_write_header *nfs_writehdr_alloc(void)
 
 		memset(p, 0, sizeof(*p));
 		INIT_LIST_HEAD(&hdr->pages);
-		INIT_LIST_HEAD(&hdr->rpc_list);
 		spin_lock_init(&hdr->lock);
 		atomic_set(&hdr->refcnt, 0);
 		hdr->verf = &p->verf;
@@ -1171,26 +1170,6 @@ static int nfs_do_write(struct nfs_write_data *data,
 	return nfs_initiate_write(NFS_CLIENT(inode), data, call_ops, how, 0);
 }
 
-static int nfs_do_multiple_writes(struct list_head *head,
-		const struct rpc_call_ops *call_ops,
-		int how)
-{
-	struct nfs_write_data *data;
-	int ret = 0;
-
-	while (!list_empty(head)) {
-		int ret2;
-
-		data = list_first_entry(head, struct nfs_write_data, list);
-		list_del_init(&data->list);
-		
-		ret2 = nfs_do_write(data, call_ops, how);
-		 if (ret == 0)
-			 ret = ret2;
-	}
-	return ret;
-}
-
 /* If a nfs_flush_* function fails, it should remove reqs from @head and
  * call this on each, which will prepare them to be retried on next
  * writeback using standard nfs.
@@ -1223,12 +1202,8 @@ static void nfs_flush_error(struct nfs_pageio_descriptor *desc,
 		struct nfs_pgio_header *hdr)
 {
 	set_bit(NFS_IOHDR_REDO, &hdr->flags);
-	while (!list_empty(&hdr->rpc_list)) {
-		struct nfs_write_data *data = list_first_entry(&hdr->rpc_list,
-				struct nfs_write_data, list);
-		list_del(&data->list);
-		nfs_writedata_release(data);
-	}
+	nfs_writedata_release(hdr->data.write);
+	hdr->data.write = NULL;
 	desc->pg_completion_ops->error_cleanup(&desc->pg_list);
 }
 
@@ -1275,7 +1250,8 @@ int nfs_generic_flush(struct nfs_pageio_descriptor *desc,
 
 	/* Set up the argument struct */
 	nfs_write_rpcsetup(data, desc->pg_count, 0, desc->pg_ioflags, &cinfo);
-	list_add(&data->list, &hdr->rpc_list);
+	WARN_ON_ONCE(hdr->data.write);
+	hdr->data.write = data;
 	desc->pg_rpc_callops = &nfs_write_common_ops;
 	return 0;
 }
@@ -1297,9 +1273,9 @@ static int nfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
 	atomic_inc(&hdr->refcnt);
 	ret = nfs_generic_flush(desc, hdr);
 	if (ret == 0)
-		ret = nfs_do_multiple_writes(&hdr->rpc_list,
-					     desc->pg_rpc_callops,
-					     desc->pg_ioflags);
+		ret = nfs_do_write(hdr->data.write,
+				   desc->pg_rpc_callops,
+				   desc->pg_ioflags);
 	if (atomic_dec_and_test(&hdr->refcnt))
 		hdr->completion_ops->completion(hdr);
 	return ret;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 6fb5b23..239274d 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1266,7 +1266,6 @@ struct nfs_page_array {
 
 struct nfs_read_data {
 	struct nfs_pgio_header	*header;
-	struct list_head	list;
 	struct rpc_task		task;
 	struct nfs_fattr	fattr;	/* fattr storage */
 	struct nfs_readargs args;
@@ -1278,6 +1277,20 @@ struct nfs_read_data {
 	struct nfs_client	*ds_clp;	/* pNFS data server */
 };
 
+struct nfs_write_data {
+	struct nfs_pgio_header	*header;
+	struct rpc_task		task;
+	struct nfs_fattr	fattr;
+	struct nfs_writeverf	verf;
+	struct nfs_writeargs	args;		/* argument struct */
+	struct nfs_writeres	res;		/* result struct */
+	unsigned long		timestamp;	/* For lease renewal */
+	int (*write_done_cb)(struct rpc_task *, struct nfs_write_data *);
+	__u64			mds_offset;	/* Filelayout dense stripe */
+	struct nfs_page_array	pages;
+	struct nfs_client	*ds_clp;	/* pNFS data server */
+};
+
 /* used as flag bits in nfs_pgio_header */
 enum {
 	NFS_IOHDR_ERROR = 0,
@@ -1291,7 +1304,10 @@ struct nfs_pgio_header {
 	struct inode		*inode;
 	struct rpc_cred		*cred;
 	struct list_head	pages;
-	struct list_head	rpc_list;
+	union {
+		struct nfs_read_data *read;
+		struct nfs_write_data *write;
+	}			data;
 	atomic_t		refcnt;
 	struct nfs_page		*req;
 	struct nfs_writeverf	*verf;
@@ -1315,21 +1331,6 @@ struct nfs_read_header {
 	struct nfs_read_data	rpc_data;
 };
 
-struct nfs_write_data {
-	struct nfs_pgio_header	*header;
-	struct list_head	list;
-	struct rpc_task		task;
-	struct nfs_fattr	fattr;
-	struct nfs_writeverf	verf;
-	struct nfs_writeargs	args;		/* argument struct */
-	struct nfs_writeres	res;		/* result struct */
-	unsigned long		timestamp;	/* For lease renewal */
-	int (*write_done_cb) (struct rpc_task *task, struct nfs_write_data *data);
-	__u64			mds_offset;	/* Filelayout dense stripe */
-	struct nfs_page_array	pages;
-	struct nfs_client	*ds_clp;	/* pNFS data server */
-};
-
 struct nfs_write_header {
 	struct nfs_pgio_header	header;
 	struct nfs_write_data	rpc_data;
-- 
1.8.5.2 (Apple Git-48)


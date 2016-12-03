Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:36769 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751294AbcLCU6I (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 3 Dec 2016 15:58:08 -0500
Received: by mail-io0-f193.google.com with SMTP id s82so14800567ioi.3
        for <linux-nfs@vger.kernel.org>; Sat, 03 Dec 2016 12:57:35 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 06/10] pNFS/flexfiles: Refactor encoding of the layoutreturn payload
Date: Sat,  3 Dec 2016 15:57:21 -0500
Message-Id: <20161203205725.12961-7-trond.myklebust@primarydata.com>
In-Reply-To: <20161203205725.12961-6-trond.myklebust@primarydata.com>
References: <20161203205725.12961-1-trond.myklebust@primarydata.com>
 <20161203205725.12961-2-trond.myklebust@primarydata.com>
 <20161203205725.12961-3-trond.myklebust@primarydata.com>
 <20161203205725.12961-4-trond.myklebust@primarydata.com>
 <20161203205725.12961-5-trond.myklebust@primarydata.com>
 <20161203205725.12961-6-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add the layout error payload to the flexfiles layoutreturn private
data, and set up the encoding mechanisms. This is a refactoring in
preparation for adding the layout iostats payload.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c    | 63 +++++++++++++++++++------
 fs/nfs/flexfilelayout/flexfilelayout.h    | 14 ++++--
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 78 +++++++++++++++++++++++++------
 3 files changed, 124 insertions(+), 31 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 540813c30b00..7f31c359a28a 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -25,6 +25,8 @@
 #define NFSDBG_FACILITY         NFSDBG_PNFS_LD
 
 #define FF_LAYOUT_POLL_RETRY_MAX     (15*HZ)
+#define FF_LAYOUTRETURN_MAXERR 20
+
 
 static struct group_info	*ff_zero_group;
 
@@ -1971,24 +1973,18 @@ ff_layout_free_deviceid_node(struct nfs4_deviceid_node *d)
 
 static int ff_layout_encode_ioerr(struct nfs4_flexfile_layout *flo,
 				  struct xdr_stream *xdr,
-				  const struct nfs4_layoutreturn_args *args)
+				  const struct nfs4_layoutreturn_args *args,
+				  const struct nfs4_flexfile_layoutreturn_args *ff_args)
 {
-	struct pnfs_layout_hdr *hdr = &flo->generic_hdr;
 	__be32 *start;
-	int count = 0, ret = 0;
 
 	start = xdr_reserve_space(xdr, 4);
 	if (unlikely(!start))
 		return -E2BIG;
 
+	*start = cpu_to_be32(ff_args->num_errors);
 	/* This assume we always return _ALL_ layouts */
-	spin_lock(&hdr->plh_inode->i_lock);
-	ret = ff_layout_encode_ds_ioerr(flo, xdr, &count, &args->range);
-	spin_unlock(&hdr->plh_inode->i_lock);
-
-	*start = cpu_to_be32(count);
-
-	return ret;
+	return ff_layout_encode_ds_ioerr(xdr, &ff_args->errors);
 }
 
 /* report nothing for now */
@@ -2017,8 +2013,10 @@ ff_layout_alloc_deviceid_node(struct nfs_server *server,
 
 static void
 ff_layout_encode_layoutreturn(struct xdr_stream *xdr,
-			      const struct nfs4_layoutreturn_args *args)
+		const void *voidargs,
+		const struct nfs4_xdr_opaque_data *ff_opaque)
 {
+	const struct nfs4_layoutreturn_args *args = voidargs;
 	struct pnfs_layout_hdr *lo = args->layout;
 	struct nfs4_flexfile_layout *flo = FF_LAYOUT_FROM_HDR(lo);
 	__be32 *start;
@@ -2027,13 +2025,52 @@ ff_layout_encode_layoutreturn(struct xdr_stream *xdr,
 	start = xdr_reserve_space(xdr, 4);
 	BUG_ON(!start);
 
-	ff_layout_encode_ioerr(flo, xdr, args);
+	ff_layout_encode_ioerr(flo, xdr, args, ff_opaque->data);
 	ff_layout_encode_iostats(flo, xdr, args);
 
 	*start = cpu_to_be32((xdr->p - start - 1) * 4);
 	dprintk("%s: Return\n", __func__);
 }
 
+static void
+ff_layout_free_layoutreturn(struct nfs4_xdr_opaque_data *args)
+{
+	struct nfs4_flexfile_layoutreturn_args *ff_args;
+
+	if (!args->data)
+		return;
+	ff_args = args->data;
+	args->data = NULL;
+
+	ff_layout_free_ds_ioerr(&ff_args->errors);
+
+	kfree(ff_args);
+}
+
+const struct nfs4_xdr_opaque_ops layoutreturn_ops = {
+	.encode = ff_layout_encode_layoutreturn,
+	.free = ff_layout_free_layoutreturn,
+};
+
+static int
+ff_layout_prepare_layoutreturn(struct nfs4_layoutreturn_args *args)
+{
+	struct nfs4_flexfile_layoutreturn_args *ff_args;
+
+	ff_args = kmalloc(sizeof(*ff_args), GFP_KERNEL);
+	if (!ff_args)
+		return -ENOMEM;
+
+	INIT_LIST_HEAD(&ff_args->errors);
+	ff_args->num_errors = ff_layout_fetch_ds_ioerr(args->layout,
+			&args->range, &ff_args->errors,
+			FF_LAYOUTRETURN_MAXERR);
+
+	args->ld_private->ops = &layoutreturn_ops;
+	args->ld_private->data = ff_args;
+	return 0;
+}
+
 static int
 ff_layout_ntop4(const struct sockaddr *sap, char *buf, const size_t buflen)
 {
@@ -2299,7 +2336,7 @@ static struct pnfs_layoutdriver_type flexfilelayout_type = {
 	.read_pagelist		= ff_layout_read_pagelist,
 	.write_pagelist		= ff_layout_write_pagelist,
 	.alloc_deviceid_node    = ff_layout_alloc_deviceid_node,
-	.encode_layoutreturn    = ff_layout_encode_layoutreturn,
+	.prepare_layoutreturn   = ff_layout_prepare_layoutreturn,
 	.sync			= pnfs_nfs_generic_sync,
 	.prepare_layoutstats	= ff_layout_prepare_layoutstats,
 	.cleanup_layoutstats	= ff_layout_cleanup_layoutstats,
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index 09f292e3a4ad..560c837995fc 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -106,6 +106,11 @@ struct nfs4_flexfile_layout {
 	ktime_t			last_report_time; /* Layoutstat report times */
 };
 
+struct nfs4_flexfile_layoutreturn_args {
+	struct list_head errors;
+	unsigned int num_errors;
+};
+
 static inline struct nfs4_flexfile_layout *
 FF_LAYOUT_FROM_HDR(struct pnfs_layout_hdr *lo)
 {
@@ -183,9 +188,12 @@ int ff_layout_track_ds_error(struct nfs4_flexfile_layout *flo,
 			     struct nfs4_ff_layout_mirror *mirror, u64 offset,
 			     u64 length, int status, enum nfs_opnum4 opnum,
 			     gfp_t gfp_flags);
-int ff_layout_encode_ds_ioerr(struct nfs4_flexfile_layout *flo,
-			      struct xdr_stream *xdr, int *count,
-			      const struct pnfs_layout_range *range);
+int ff_layout_encode_ds_ioerr(struct xdr_stream *xdr, const struct list_head *head);
+void ff_layout_free_ds_ioerr(struct list_head *head);
+unsigned int ff_layout_fetch_ds_ioerr(struct pnfs_layout_hdr *lo,
+		const struct pnfs_layout_range *range,
+		struct list_head *head,
+		unsigned int maxnum);
 struct nfs_fh *
 nfs4_ff_layout_select_ds_fh(struct pnfs_layout_segment *lseg, u32 mirror_idx);
 
diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index 75767aa38455..eb98395c3651 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -447,20 +447,26 @@ nfs4_ff_find_or_create_ds_client(struct pnfs_layout_segment *lseg, u32 ds_idx,
 	}
 }
 
+void ff_layout_free_ds_ioerr(struct list_head *head)
+{
+	struct nfs4_ff_layout_ds_err *err;
+
+	while (!list_empty(head)) {
+		err = list_first_entry(head,
+				struct nfs4_ff_layout_ds_err,
+				list);
+		list_del(&err->list);
+		kfree(err);
+	}
+}
+
 /* called with inode i_lock held */
-int ff_layout_encode_ds_ioerr(struct nfs4_flexfile_layout *flo,
-			      struct xdr_stream *xdr, int *count,
-			      const struct pnfs_layout_range *range)
+int ff_layout_encode_ds_ioerr(struct xdr_stream *xdr, const struct list_head *head)
 {
-	struct nfs4_ff_layout_ds_err *err, *n;
+	struct nfs4_ff_layout_ds_err *err;
 	__be32 *p;
 
-	list_for_each_entry_safe(err, n, &flo->error_list, list) {
-		if (!pnfs_is_range_intersecting(err->offset,
-				pnfs_end_offset(err->offset, err->length),
-				range->offset,
-				pnfs_end_offset(range->offset, range->length)))
-			continue;
+	list_for_each_entry(err, head, list) {
 		/* offset(8) + length(8) + stateid(NFS4_STATEID_SIZE)
 		 * + array length + deviceid(NFS4_DEVICEID4_SIZE)
 		 * + status(4) + opnum(4)
@@ -479,17 +485,59 @@ int ff_layout_encode_ds_ioerr(struct nfs4_flexfile_layout *flo,
 					    NFS4_DEVICEID4_SIZE);
 		*p++ = cpu_to_be32(err->status);
 		*p++ = cpu_to_be32(err->opnum);
-		*count += 1;
-		list_del(&err->list);
-		dprintk("%s: offset %llu length %llu status %d op %d count %d\n",
+		dprintk("%s: offset %llu length %llu status %d op %d\n",
 			__func__, err->offset, err->length, err->status,
-			err->opnum, *count);
-		kfree(err);
+			err->opnum);
 	}
 
 	return 0;
 }
 
+static
+unsigned int do_layout_fetch_ds_ioerr(struct pnfs_layout_hdr *lo,
+				      const struct pnfs_layout_range *range,
+				      struct list_head *head,
+				      unsigned int maxnum)
+{
+	struct nfs4_flexfile_layout *flo = FF_LAYOUT_FROM_HDR(lo);
+	struct inode *inode = lo->plh_inode;
+	struct nfs4_ff_layout_ds_err *err, *n;
+	unsigned int ret = 0;
+
+	spin_lock(&inode->i_lock);
+	list_for_each_entry_safe(err, n, &flo->error_list, list) {
+		if (!pnfs_is_range_intersecting(err->offset,
+				pnfs_end_offset(err->offset, err->length),
+				range->offset,
+				pnfs_end_offset(range->offset, range->length)))
+			continue;
+		if (!maxnum)
+			break;
+		list_move(&err->list, head);
+		maxnum--;
+		ret++;
+	}
+	spin_unlock(&inode->i_lock);
+	return ret;
+}
+
+unsigned int ff_layout_fetch_ds_ioerr(struct pnfs_layout_hdr *lo,
+				      const struct pnfs_layout_range *range,
+				      struct list_head *head,
+				      unsigned int maxnum)
+{
+	unsigned int ret;
+
+	ret = do_layout_fetch_ds_ioerr(lo, range, head, maxnum);
+	/* If we're over the max, discard all remaining entries */
+	if (ret == maxnum) {
+		LIST_HEAD(discard);
+		do_layout_fetch_ds_ioerr(lo, range, &discard, -1);
+		ff_layout_free_ds_ioerr(&discard);
+	}
+	return ret;
+}
+
 static bool ff_read_layout_has_available_ds(struct pnfs_layout_segment *lseg)
 {
 	struct nfs4_ff_layout_mirror *mirror;
-- 
2.9.3


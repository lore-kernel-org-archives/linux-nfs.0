Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:36782 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751347AbcLCU6I (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 3 Dec 2016 15:58:08 -0500
Received: by mail-io0-f196.google.com with SMTP id s82so14800684ioi.3
        for <linux-nfs@vger.kernel.org>; Sat, 03 Dec 2016 12:57:38 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 10/10] pNFS/flexfiles: Support sending layoutstats in layoutreturn
Date: Sat,  3 Dec 2016 15:57:25 -0500
Message-Id: <20161203205725.12961-11-trond.myklebust@primarydata.com>
In-Reply-To: <20161203205725.12961-10-trond.myklebust@primarydata.com>
References: <20161203205725.12961-1-trond.myklebust@primarydata.com>
 <20161203205725.12961-2-trond.myklebust@primarydata.com>
 <20161203205725.12961-3-trond.myklebust@primarydata.com>
 <20161203205725.12961-4-trond.myklebust@primarydata.com>
 <20161203205725.12961-5-trond.myklebust@primarydata.com>
 <20161203205725.12961-6-trond.myklebust@primarydata.com>
 <20161203205725.12961-7-trond.myklebust@primarydata.com>
 <20161203205725.12961-8-trond.myklebust@primarydata.com>
 <20161203205725.12961-9-trond.myklebust@primarydata.com>
 <20161203205725.12961-10-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add the ability to send an array of layoutstats entries as part of
layoutreturn.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 82 +++++++++++++++++++++++++++++++---
 fs/nfs/flexfilelayout/flexfilelayout.h |  3 ++
 2 files changed, 79 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index e5078301720a..ca1012a42e14 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -32,6 +32,12 @@ static struct group_info	*ff_zero_group;
 
 static void ff_layout_read_record_layoutstats_done(struct rpc_task *task,
 		struct nfs_pgio_header *hdr);
+static int ff_layout_mirror_prepare_stats(struct pnfs_layout_hdr *lo,
+			       struct nfs42_layoutstat_devinfo *devinfo,
+			       int dev_limit);
+static void ff_layout_encode_ff_layoutupdate(struct xdr_stream *xdr,
+			      const struct nfs42_layoutstat_devinfo *devinfo,
+			      struct nfs4_ff_layout_mirror *mirror);
 
 static struct pnfs_layout_hdr *
 ff_layout_alloc_layout_hdr(struct inode *inode, gfp_t gfp_flags)
@@ -1987,16 +1993,73 @@ static int ff_layout_encode_ioerr(struct nfs4_flexfile_layout *flo,
 	return ff_layout_encode_ds_ioerr(xdr, &ff_args->errors);
 }
 
+static void
+encode_opaque_fixed(struct xdr_stream *xdr, const void *buf, size_t len)
+{
+	__be32 *p;
+
+	p = xdr_reserve_space(xdr, len);
+	xdr_encode_opaque_fixed(p, buf, len);
+}
+
+static void
+ff_layout_encode_ff_iostat_head(struct xdr_stream *xdr,
+			    const nfs4_stateid *stateid,
+			    const struct nfs42_layoutstat_devinfo *devinfo)
+{
+	__be32 *p;
+
+	p = xdr_reserve_space(xdr, 8 + 8);
+	p = xdr_encode_hyper(p, devinfo->offset);
+	p = xdr_encode_hyper(p, devinfo->length);
+	encode_opaque_fixed(xdr, stateid->data, NFS4_STATEID_SIZE);
+	p = xdr_reserve_space(xdr, 4*8);
+	p = xdr_encode_hyper(p, devinfo->read_count);
+	p = xdr_encode_hyper(p, devinfo->read_bytes);
+	p = xdr_encode_hyper(p, devinfo->write_count);
+	p = xdr_encode_hyper(p, devinfo->write_bytes);
+	encode_opaque_fixed(xdr, devinfo->dev_id.data, NFS4_DEVICEID4_SIZE);
+}
+
+static void
+ff_layout_encode_ff_iostat(struct xdr_stream *xdr,
+			    const nfs4_stateid *stateid,
+			    const struct nfs42_layoutstat_devinfo *devinfo)
+{
+	ff_layout_encode_ff_iostat_head(xdr, stateid, devinfo);
+	ff_layout_encode_ff_layoutupdate(xdr, devinfo,
+			devinfo->ld_private.data);
+}
+
 /* report nothing for now */
-static void ff_layout_encode_iostats_array(struct nfs4_flexfile_layout *flo,
-				     struct xdr_stream *xdr,
-				     const struct nfs4_layoutreturn_args *args)
+static void ff_layout_encode_iostats_array(struct xdr_stream *xdr,
+		const struct nfs4_layoutreturn_args *args,
+		struct nfs4_flexfile_layoutreturn_args *ff_args)
 {
 	__be32 *p;
+	int i;
 
 	p = xdr_reserve_space(xdr, 4);
-	if (likely(p))
-		*p = cpu_to_be32(0);
+	*p = cpu_to_be32(ff_args->num_dev);
+	for (i = 0; i < ff_args->num_dev; i++)
+		ff_layout_encode_ff_iostat(xdr,
+				&args->layout->plh_stateid,
+				&ff_args->devinfo[i]);
+}
+
+static void
+ff_layout_free_iostats_array(struct nfs42_layoutstat_devinfo *devinfo,
+		unsigned int num_entries)
+{
+	unsigned int i;
+
+	for (i = 0; i < num_entries; i++) {
+		if (!devinfo[i].ld_private.ops)
+			continue;
+		if (!devinfo[i].ld_private.ops->free)
+			continue;
+		devinfo[i].ld_private.ops->free(&devinfo[i].ld_private);
+	}
 }
 
 static struct nfs4_deviceid_node *
@@ -2026,7 +2089,7 @@ ff_layout_encode_layoutreturn(struct xdr_stream *xdr,
 	BUG_ON(!start);
 
 	ff_layout_encode_ioerr(flo, xdr, args, ff_opaque->data);
-	ff_layout_encode_iostats_array(flo, xdr, args);
+	ff_layout_encode_iostats_array(xdr, args, ff_opaque->data);
 
 	*start = cpu_to_be32((xdr->p - start - 1) * 4);
 	dprintk("%s: Return\n", __func__);
@@ -2043,6 +2106,7 @@ ff_layout_free_layoutreturn(struct nfs4_xdr_opaque_data *args)
 	args->data = NULL;
 
 	ff_layout_free_ds_ioerr(&ff_args->errors);
+	ff_layout_free_iostats_array(ff_args->devinfo, ff_args->num_dev);
 
 	kfree(ff_args);
 }
@@ -2056,6 +2120,7 @@ static int
 ff_layout_prepare_layoutreturn(struct nfs4_layoutreturn_args *args)
 {
 	struct nfs4_flexfile_layoutreturn_args *ff_args;
+	struct nfs4_flexfile_layout *ff_layout = FF_LAYOUT_FROM_HDR(args->layout);
 
 	ff_args = kmalloc(sizeof(*ff_args), GFP_KERNEL);
 	if (!ff_args)
@@ -2066,6 +2131,11 @@ ff_layout_prepare_layoutreturn(struct nfs4_layoutreturn_args *args)
 			&args->range, &ff_args->errors,
 			FF_LAYOUTRETURN_MAXERR);
 
+	spin_lock(&args->inode->i_lock);
+	ff_args->num_dev = ff_layout_mirror_prepare_stats(&ff_layout->generic_hdr,
+			&ff_args->devinfo[0], ARRAY_SIZE(ff_args->devinfo));
+	spin_unlock(&args->inode->i_lock);
+
 	args->ld_private->ops = &layoutreturn_ops;
 	args->ld_private->data = ff_args;
 	return 0;
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index 560c837995fc..35221fe390c5 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -21,6 +21,7 @@
 
 /* LAYOUTSTATS report interval in ms */
 #define FF_LAYOUTSTATS_REPORT_INTERVAL (60000L)
+#define FF_LAYOUTSTATS_MAXDEV 4
 
 struct nfs4_ff_ds_version {
 	u32				version;
@@ -108,7 +109,9 @@ struct nfs4_flexfile_layout {
 
 struct nfs4_flexfile_layoutreturn_args {
 	struct list_head errors;
+	struct nfs42_layoutstat_devinfo devinfo[FF_LAYOUTSTATS_MAXDEV];
 	unsigned int num_errors;
+	unsigned int num_dev;
 };
 
 static inline struct nfs4_flexfile_layout *
-- 
2.9.3


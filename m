Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:34617 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751328AbcLCU6I (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 3 Dec 2016 15:58:08 -0500
Received: by mail-io0-f194.google.com with SMTP id r94so14855555ioe.1
        for <linux-nfs@vger.kernel.org>; Sat, 03 Dec 2016 12:57:37 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 09/10] pNFS/flexfiles: Minor refactoring before adding iostats to layoutreturn
Date: Sat,  3 Dec 2016 15:57:24 -0500
Message-Id: <20161203205725.12961-10-trond.myklebust@primarydata.com>
In-Reply-To: <20161203205725.12961-9-trond.myklebust@primarydata.com>
References: <20161203205725.12961-1-trond.myklebust@primarydata.com>
 <20161203205725.12961-2-trond.myklebust@primarydata.com>
 <20161203205725.12961-3-trond.myklebust@primarydata.com>
 <20161203205725.12961-4-trond.myklebust@primarydata.com>
 <20161203205725.12961-5-trond.myklebust@primarydata.com>
 <20161203205725.12961-6-trond.myklebust@primarydata.com>
 <20161203205725.12961-7-trond.myklebust@primarydata.com>
 <20161203205725.12961-8-trond.myklebust@primarydata.com>
 <20161203205725.12961-9-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 59 ++++++++++++++++++++--------------
 fs/nfs/nfs42proc.c                     |  9 ++++--
 fs/nfs/nfs42xdr.c                      |  5 +--
 fs/nfs/pnfs.h                          |  1 -
 include/linux/nfs_xdr.h                |  3 +-
 5 files changed, 44 insertions(+), 33 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index c18afd5cc0bb..e5078301720a 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1988,7 +1988,7 @@ static int ff_layout_encode_ioerr(struct nfs4_flexfile_layout *flo,
 }
 
 /* report nothing for now */
-static void ff_layout_encode_iostats(struct nfs4_flexfile_layout *flo,
+static void ff_layout_encode_iostats_array(struct nfs4_flexfile_layout *flo,
 				     struct xdr_stream *xdr,
 				     const struct nfs4_layoutreturn_args *args)
 {
@@ -2026,7 +2026,7 @@ ff_layout_encode_layoutreturn(struct xdr_stream *xdr,
 	BUG_ON(!start);
 
 	ff_layout_encode_ioerr(flo, xdr, args, ff_opaque->data);
-	ff_layout_encode_iostats(flo, xdr, args);
+	ff_layout_encode_iostats_array(flo, xdr, args);
 
 	*start = cpu_to_be32((xdr->p - start - 1) * 4);
 	dprintk("%s: Return\n", __func__);
@@ -2191,21 +2191,18 @@ ff_layout_encode_io_latency(struct xdr_stream *xdr,
 }
 
 static void
-ff_layout_encode_layoutstats(struct xdr_stream *xdr,
-			     struct nfs42_layoutstat_args *args,
-			     struct nfs42_layoutstat_devinfo *devinfo)
+ff_layout_encode_ff_layoutupdate(struct xdr_stream *xdr,
+			      const struct nfs42_layoutstat_devinfo *devinfo,
+			      struct nfs4_ff_layout_mirror *mirror)
 {
-	struct nfs4_ff_layout_mirror *mirror = devinfo->layout_private;
 	struct nfs4_pnfs_ds_addr *da;
 	struct nfs4_pnfs_ds *ds = mirror->mirror_ds->ds;
 	struct nfs_fh *fh = &mirror->fh_versions[0];
-	__be32 *p, *start;
+	__be32 *p;
 
 	da = list_first_entry(&ds->ds_addrs, struct nfs4_pnfs_ds_addr, da_node);
 	dprintk("%s: DS %s: encoding address %s\n",
 		__func__, ds->ds_remotestr, da->da_remotestr);
-	/* layoutupdate length */
-	start = xdr_reserve_space(xdr, 4);
 	/* netaddr4 */
 	ff_layout_encode_netaddr(xdr, da);
 	/* nfs_fh4 */
@@ -2222,10 +2219,36 @@ ff_layout_encode_layoutstats(struct xdr_stream *xdr,
 	/* bool */
 	p = xdr_reserve_space(xdr, 4);
 	*p = cpu_to_be32(false);
+}
+
+static void
+ff_layout_encode_layoutstats(struct xdr_stream *xdr, const void *args,
+			     const struct nfs4_xdr_opaque_data *opaque)
+{
+	struct nfs42_layoutstat_devinfo *devinfo = container_of(opaque,
+			struct nfs42_layoutstat_devinfo, ld_private);
+	__be32 *start;
+
+	/* layoutupdate length */
+	start = xdr_reserve_space(xdr, 4);
+	ff_layout_encode_ff_layoutupdate(xdr, devinfo, opaque->data);
 
 	*start = cpu_to_be32((xdr->p - start - 1) * 4);
 }
 
+static void
+ff_layout_free_layoutstats(struct nfs4_xdr_opaque_data *opaque)
+{
+	struct nfs4_ff_layout_mirror *mirror = opaque->data;
+
+	ff_layout_put_mirror(mirror);
+}
+
+static const struct nfs4_xdr_opaque_ops layoutstat_ops = {
+	.encode = ff_layout_encode_layoutstats,
+	.free	= ff_layout_free_layoutstats,
+};
+
 static int
 ff_layout_mirror_prepare_stats(struct pnfs_layout_hdr *lo,
 			       struct nfs42_layoutstat_devinfo *devinfo,
@@ -2257,8 +2280,8 @@ ff_layout_mirror_prepare_stats(struct pnfs_layout_hdr *lo,
 		devinfo->write_bytes = mirror->write_stat.io_stat.bytes_completed;
 		spin_unlock(&mirror->lock);
 		devinfo->layout_type = LAYOUT_FLEX_FILES;
-		devinfo->layoutstats_encode = ff_layout_encode_layoutstats;
-		devinfo->layout_private = mirror;
+		devinfo->ld_private.ops = &layoutstat_ops;
+		devinfo->ld_private.data = mirror;
 
 		devinfo++;
 		i++;
@@ -2291,19 +2314,6 @@ ff_layout_prepare_layoutstats(struct nfs42_layoutstat_args *args)
 	return 0;
 }
 
-static void
-ff_layout_cleanup_layoutstats(struct nfs42_layoutstat_data *data)
-{
-	struct nfs4_ff_layout_mirror *mirror;
-	int i;
-
-	for (i = 0; i < data->args.num_dev; i++) {
-		mirror = data->args.devinfo[i].layout_private;
-		data->args.devinfo[i].layout_private = NULL;
-		ff_layout_put_mirror(mirror);
-	}
-}
-
 static struct pnfs_layoutdriver_type flexfilelayout_type = {
 	.id			= LAYOUT_FLEX_FILES,
 	.name			= "LAYOUT_FLEX_FILES",
@@ -2328,7 +2338,6 @@ static struct pnfs_layoutdriver_type flexfilelayout_type = {
 	.prepare_layoutreturn   = ff_layout_prepare_layoutreturn,
 	.sync			= pnfs_nfs_generic_sync,
 	.prepare_layoutstats	= ff_layout_prepare_layoutstats,
-	.cleanup_layoutstats	= ff_layout_cleanup_layoutstats,
 };
 
 static int __init nfs4flexfilelayout_init(void)
diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index 608501971fe0..d12ff9385f49 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -397,10 +397,13 @@ static void
 nfs42_layoutstat_release(void *calldata)
 {
 	struct nfs42_layoutstat_data *data = calldata;
-	struct nfs_server *nfss = NFS_SERVER(data->args.inode);
+	struct nfs42_layoutstat_devinfo *devinfo = data->args.devinfo;
+	int i;
 
-	if (nfss->pnfs_curr_ld->cleanup_layoutstats)
-		nfss->pnfs_curr_ld->cleanup_layoutstats(data);
+	for (i = 0; i < data->args.num_dev; i++) {
+		if (devinfo[i].ld_private.ops && devinfo[i].ld_private.ops->free)
+			devinfo[i].ld_private.ops->free(&devinfo[i].ld_private);
+	}
 
 	pnfs_put_layout_hdr(NFS_I(data->args.inode)->layout);
 	smp_mb__before_atomic();
diff --git a/fs/nfs/nfs42xdr.c b/fs/nfs/nfs42xdr.c
index 8b2605882a20..6c7296454bbc 100644
--- a/fs/nfs/nfs42xdr.c
+++ b/fs/nfs/nfs42xdr.c
@@ -181,8 +181,9 @@ static void encode_layoutstats(struct xdr_stream *xdr,
 			NFS4_DEVICEID4_SIZE);
 	/* Encode layoutupdate4 */
 	*p++ = cpu_to_be32(devinfo->layout_type);
-	if (devinfo->layoutstats_encode != NULL)
-		devinfo->layoutstats_encode(xdr, args, devinfo);
+	if (devinfo->ld_private.ops)
+		devinfo->ld_private.ops->encode(xdr, args,
+				&devinfo->ld_private);
 	else
 		encode_uint32(xdr, 0);
 }
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index d1e028175cd1..63f77b49a586 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -182,7 +182,6 @@ struct pnfs_layoutdriver_type {
 				     struct xdr_stream *xdr,
 				     const struct nfs4_layoutcommit_args *args);
 	int (*prepare_layoutstats) (struct nfs42_layoutstat_args *args);
-	void (*cleanup_layoutstats) (struct nfs42_layoutstat_data *data);
 };
 
 struct pnfs_layout_hdr {
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index b64177d669fd..617cfaa20ffc 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -357,8 +357,7 @@ struct nfs42_layoutstat_devinfo {
 	__u64 write_count;
 	__u64 write_bytes;
 	__u32 layout_type;
-	layoutstats_encode_t layoutstats_encode;
-	void *layout_private;
+	struct nfs4_xdr_opaque_data ld_private;
 };
 
 struct nfs42_layoutstat_args {
-- 
2.9.3


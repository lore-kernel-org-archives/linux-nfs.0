From: andros@netapp.com
Subject: [PATCH 3/6] SQUASHME pnfs-submit: remove encode_layoutcommit
Date: Wed,  2 Jun 2010 11:54:24 -0400
Message-ID: <1275494067-4058-4-git-send-email-andros@netapp.com>
References: <1275494067-4058-1-git-send-email-andros@netapp.com>
 <1275494067-4058-2-git-send-email-andros@netapp.com>
 <1275494067-4058-3-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:38483 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758152Ab0FBRzZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Jun 2010 13:55:25 -0400
In-Reply-To: <1275494067-4058-3-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Not used by the file layout driver

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4xdr.c          |   11 ++---------
 include/linux/nfs4_pnfs.h |    3 ---
 2 files changed, 2 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index d7d41e9..72fd799 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1852,8 +1852,6 @@ encode_layoutcommit(struct xdr_stream *xdr,
 		    const struct pnfs_layoutcommit_arg *args,
 		    struct compound_hdr *hdr)
 {
-	struct layoutdriver_io_operations *ld_io_ops =
-			NFS_SERVER(args->inode)->pnfs_curr_ld->ld_io_ops;
 	__be32 *p;
 
 	dprintk("%s: %llu@%llu lbw: %llu type: %d\n", __func__,
@@ -1879,13 +1877,8 @@ encode_layoutcommit(struct xdr_stream *xdr,
 	p = reserve_space(xdr, 4);
 	*p = cpu_to_be32(args->layout_type);
 
-	if (ld_io_ops->encode_layoutcommit)
-		ld_io_ops->encode_layoutcommit(
-			&NFS_I(args->inode)->layout, xdr, args);
-	else {
-		p = reserve_space(xdr, 4);
-		xdr_encode_opaque(p, NULL, 0);
-	}
+	p = reserve_space(xdr, 4);
+	xdr_encode_opaque(p, NULL, 0);
 
 	hdr->nops++;
 	hdr->replen += decode_layoutcommit_maxsz;
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index 1b017fe..3c22168 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -146,9 +146,6 @@ struct layoutdriver_io_operations {
 	struct pnfs_layout_segment * (*alloc_lseg) (struct pnfs_layout_type *layoutid, struct nfs4_pnfs_layoutget_res *lgr);
 	void (*free_lseg) (struct pnfs_layout_segment *lseg);
 
-	void (*encode_layoutcommit) (struct pnfs_layout_type *layoutid,
-				     struct xdr_stream *xdr,
-				     const struct pnfs_layoutcommit_arg *args);
 	void (*encode_layoutreturn) (struct pnfs_layout_type *layoutid,
 				struct xdr_stream *xdr,
 				const struct nfs4_pnfs_layoutreturn_arg *args);
-- 
1.6.6


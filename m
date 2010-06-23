From: andros@netapp.com
Subject: [PATCH 04/10] SQUASHME pnfs-submit: remove encode_layoutreturn
Date: Wed, 23 Jun 2010 15:21:12 -0400
Message-ID: <1277320878-3726-5-git-send-email-andros@netapp.com>
References: <1277320878-3726-1-git-send-email-andros@netapp.com>
 <1277320878-3726-2-git-send-email-andros@netapp.com>
 <1277320878-3726-3-git-send-email-andros@netapp.com>
 <1277320878-3726-4-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:5004 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753409Ab0FWTW3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Jun 2010 15:22:29 -0400
In-Reply-To: <1277320878-3726-4-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Not used by the file layout

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4xdr.c          |   15 ++-------------
 include/linux/nfs4_pnfs.h |    4 ----
 2 files changed, 2 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index a509bc1..fb50361 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1874,24 +1874,13 @@ encode_layoutreturn(struct xdr_stream *xdr,
 	*p++ = cpu_to_be32(args->lseg.iomode);
 	*p = cpu_to_be32(args->return_type);
 	if (args->return_type == RETURN_FILE) {
-		struct layoutdriver_io_operations *ld_io_ops =
-			NFS_SERVER(args->inode)->pnfs_curr_ld->ld_io_ops;
-
 		p = reserve_space(xdr, 16 + NFS4_STATEID_SIZE);
 		p = xdr_encode_hyper(p, args->lseg.offset);
 		p = xdr_encode_hyper(p, args->lseg.length);
 		p = xdr_encode_opaque_fixed(p, &args->stateid.u.data,
 					    NFS4_STATEID_SIZE);
-
-		dprintk("%s: call %pF\n", __func__,
-			ld_io_ops->encode_layoutreturn);
-		if (ld_io_ops->encode_layoutreturn) {
-			ld_io_ops->encode_layoutreturn(
-				&NFS_I(args->inode)->layout, xdr, args);
-		} else {
-			p = reserve_space(xdr, 4);
-			*p = cpu_to_be32(0);
-		}
+		p = reserve_space(xdr, 4);
+		*p = cpu_to_be32(0);
 	}
 	hdr->nops++;
 	hdr->replen += decode_layoutreturn_maxsz;
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index d20b5de..782fdd9 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -154,10 +154,6 @@ struct layoutdriver_io_operations {
 	struct pnfs_layout_segment * (*alloc_lseg) (struct pnfs_layout_type *layoutid, struct nfs4_pnfs_layoutget_res *lgr);
 	void (*free_lseg) (struct pnfs_layout_segment *lseg);
 
-	void (*encode_layoutreturn) (struct pnfs_layout_type *layoutid,
-				struct xdr_stream *xdr,
-				const struct nfs4_pnfs_layoutreturn_arg *args);
-
 	/* Registration information for a new mounted file system
 	 */
 	int (*initialize_mountpoint) (struct nfs_client *);
-- 
1.6.6


From: andros@netapp.com
Subject: [PATCH 1/4] SQUASHME pnfs-submit get layoutget stateid from layout in xdr layer
Date: Thu, 15 Jul 2010 16:58:51 -0400
Message-ID: <1279227534-3226-2-git-send-email-andros@netapp.com>
References: <1279227534-3226-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:37399 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758683Ab0GOU6a (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Jul 2010 16:58:30 -0400
In-Reply-To: <1279227534-3226-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Set the un-initialized layout stateid from an open stateid.

This pulls the latest stateid from the layout. Fixes bug where
retry on NFS4ERR_OLD_STATEID, (and any retry) would re-use the same stateid.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4xdr.c         |    6 ++++--
 fs/nfs/pnfs.c            |   25 ++++++++++++++-----------
 fs/nfs/pnfs.h            |    1 +
 include/linux/pnfs_xdr.h |    1 -
 4 files changed, 19 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 9a52050..d542bc2 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -54,6 +54,7 @@
 #include <linux/pnfs_xdr.h>
 #include "nfs4_fs.h"
 #include "internal.h"
+#include "pnfs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_XDR
 
@@ -1797,6 +1798,7 @@ encode_layoutget(struct xdr_stream *xdr,
 		      const struct nfs4_pnfs_layoutget_arg *args,
 		      struct compound_hdr *hdr)
 {
+	nfs4_stateid stateid;
 	__be32 *p;
 
 	p = reserve_space(xdr, 44 + NFS4_STATEID_SIZE);
@@ -1807,8 +1809,8 @@ encode_layoutget(struct xdr_stream *xdr,
 	p = xdr_encode_hyper(p, args->lseg.offset);
 	p = xdr_encode_hyper(p, args->lseg.length);
 	p = xdr_encode_hyper(p, args->minlength);
-	p = xdr_encode_opaque_fixed(p, &args->stateid.u.data,
-				    NFS4_STATEID_SIZE);
+	pnfs_get_layout_stateid(&stateid, NFS_I(args->inode)->layout);
+	p = xdr_encode_opaque_fixed(p, &stateid.u.data, NFS4_STATEID_SIZE);
 	*p = cpu_to_be32(args->maxcount);
 
 	dprintk("%s: 1st type:0x%x iomode:%d off:%lu len:%lu mc:%d\n",
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index b9ada8e..9b72c00 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -465,7 +465,7 @@ pnfs_set_layout_stateid(struct pnfs_layout_type *lo,
 	write_sequnlock(&lo->seqlock);
 }
 
-static void
+void
 pnfs_get_layout_stateid(nfs4_stateid *dst, struct pnfs_layout_type *lo)
 {
 	int seq;
@@ -482,18 +482,21 @@ pnfs_get_layout_stateid(nfs4_stateid *dst, struct pnfs_layout_type *lo)
 }
 
 static void
-pnfs_layout_from_open_stateid(nfs4_stateid *dst, struct nfs4_state *state)
+pnfs_layout_from_open_stateid(struct pnfs_layout_type *lo,
+			      struct nfs4_state *state)
 {
 	int seq;
 
 	dprintk("--> %s\n", __func__);
 
-	do {
-		seq = read_seqbegin(&state->seqlock);
-		memcpy(dst->u.data, state->stateid.u.data,
-				sizeof(state->stateid.u.data));
-	} while (read_seqretry(&state->seqlock, seq));
-
+	write_seqlock(&lo->seqlock);
+	if (!memcmp(lo->stateid.u.data, &zero_stateid, NFS4_STATEID_SIZE))
+		do {
+			seq = read_seqbegin(&state->seqlock);
+			memcpy(lo->stateid.u.data, state->stateid.u.data,
+					sizeof(state->stateid.u.data));
+		} while (read_seqretry(&state->seqlock, seq));
+	write_sequnlock(&lo->seqlock);
 	dprintk("<-- %s\n", __func__);
 }
 
@@ -540,11 +543,11 @@ send_layoutget(struct inode *ino,
 					FMODE_READ: FMODE_WRITE);
 			BUG_ON(!ctx);
 		}
-		pnfs_layout_from_open_stateid(&lgp->args.stateid, ctx->state);
+		/* Set the layout stateid from the open stateid */
+		pnfs_layout_from_open_stateid(NFS_I(ino)->layout, ctx->state);
 		if (!oldctx)
 			put_nfs_open_context(ctx);
-	} else
-		pnfs_get_layout_stateid(&lgp->args.stateid, lo);
+	}
 
 	/* Retrieve layout information from server */
 	status = pnfs4_proc_layoutget(lgp);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index d5dc2e2..87b6303 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -65,6 +65,7 @@ void pnfs_set_layout_stateid(struct pnfs_layout_type *lo,
 			     const nfs4_stateid *stateid);
 void pnfs_destroy_layout(struct nfs_inode *);
 void put_layout(struct inode *inode);
+void pnfs_get_layout_stateid(nfs4_stateid *dst, struct pnfs_layout_type *lo);
 
 #define PNFS_EXISTS_LDIO_OP(srv, opname) ((srv)->pnfs_curr_ld &&	\
 				     (srv)->pnfs_curr_ld->ld_io_ops &&	\
diff --git a/include/linux/pnfs_xdr.h b/include/linux/pnfs_xdr.h
index d3d0d78..5b8f4c3 100644
--- a/include/linux/pnfs_xdr.h
+++ b/include/linux/pnfs_xdr.h
@@ -35,7 +35,6 @@ struct nfs4_pnfs_layoutget_arg {
 	struct nfs4_pnfs_layout_segment lseg;
 	__u64 minlength;
 	__u32 maxcount;
-	nfs4_stateid stateid;
 	struct inode *inode;
 	struct nfs4_sequence_args seq_args;
 };
-- 
1.6.6


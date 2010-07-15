From: andros@netapp.com
Subject: [PATCH 2/4] SQUASHME pnfs-submit get layoutreturn stateid from layout in xdr layer
Date: Thu, 15 Jul 2010 16:58:52 -0400
Message-ID: <1279227534-3226-3-git-send-email-andros@netapp.com>
References: <1279227534-3226-1-git-send-email-andros@netapp.com>
 <1279227534-3226-2-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:37399 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758683Ab0GOU6b (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Jul 2010 16:58:31 -0400
In-Reply-To: <1279227534-3226-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

So as to use the latest stateid, and to fix the bug where a replay
on NFS4ERR_OLD_STATEID (and all replays) would use the old stateid.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4xdr.c         |    4 +++-
 fs/nfs/pnfs.c            |    1 -
 include/linux/pnfs_xdr.h |    1 -
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index d542bc2..f6e1d49 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1867,6 +1867,7 @@ encode_layoutreturn(struct xdr_stream *xdr,
 		    const struct nfs4_pnfs_layoutreturn_arg *args,
 		    struct compound_hdr *hdr)
 {
+	nfs4_stateid stateid;
 	__be32 *p;
 
 	p = reserve_space(xdr, 20);
@@ -1879,7 +1880,8 @@ encode_layoutreturn(struct xdr_stream *xdr,
 		p = reserve_space(xdr, 16 + NFS4_STATEID_SIZE);
 		p = xdr_encode_hyper(p, args->lseg.offset);
 		p = xdr_encode_hyper(p, args->lseg.length);
-		p = xdr_encode_opaque_fixed(p, &args->stateid.u.data,
+		pnfs_get_layout_stateid(&stateid, NFS_I(args->inode)->layout);
+		p = xdr_encode_opaque_fixed(p, &stateid.u.data,
 					    NFS4_STATEID_SIZE);
 		p = reserve_space(xdr, 4);
 		*p = cpu_to_be32(0);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 9b72c00..ea508bf 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -683,7 +683,6 @@ return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
 	lrp->args.lseg = *range;
 	lrp->args.inode = ino;
 	lrp->lo = lo;
-	pnfs_get_layout_stateid(&lrp->args.stateid, lo);
 
 	status = pnfs4_proc_layoutreturn(lrp, wait);
 out:
diff --git a/include/linux/pnfs_xdr.h b/include/linux/pnfs_xdr.h
index 5b8f4c3..185fade 100644
--- a/include/linux/pnfs_xdr.h
+++ b/include/linux/pnfs_xdr.h
@@ -94,7 +94,6 @@ struct nfs4_pnfs_layoutreturn_arg {
 	__u32	layout_type;
 	__u32	return_type;
 	struct nfs4_pnfs_layout_segment lseg;
-	nfs4_stateid stateid;
 	struct inode *inode;
 	struct nfs4_sequence_args seq_args;
 };
-- 
1.6.6


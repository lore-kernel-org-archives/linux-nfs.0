From: andros@netapp.com
Subject: [PATCH 5/7] pnfs-post-submit: restore encode_layoutcommit
Date: Thu, 17 Jun 2010 15:34:54 -0400
Message-ID: <1276803296-9438-6-git-send-email-andros@netapp.com>
References: <1276803296-9438-1-git-send-email-andros@netapp.com>
 <1276803296-9438-2-git-send-email-andros@netapp.com>
 <1276803296-9438-3-git-send-email-andros@netapp.com>
 <1276803296-9438-4-git-send-email-andros@netapp.com>
 <1276803296-9438-5-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.212.112.111]:56797 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757354Ab0FQTfc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Jun 2010 15:35:32 -0400
In-Reply-To: <1276803296-9438-5-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4xdr.c          |   11 +++++++++--
 include/linux/nfs4_pnfs.h |    3 +++
 2 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 478b66f..45578fb 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1856,6 +1856,8 @@ encode_layoutcommit(struct xdr_stream *xdr,
 		    const struct pnfs_layoutcommit_arg *args,
 		    struct compound_hdr *hdr)
 {
+	struct layoutdriver_io_operations *ld_io_ops =
+			NFS_SERVER(args->inode)->pnfs_curr_ld->ld_io_ops;
 	__be32 *p;
 
 	dprintk("%s: %llu@%llu lbw: %llu type: %d\n", __func__,
@@ -1881,8 +1883,13 @@ encode_layoutcommit(struct xdr_stream *xdr,
 	p = reserve_space(xdr, 4);
 	*p = cpu_to_be32(args->layout_type);
 
-	p = reserve_space(xdr, 4);
-	xdr_encode_opaque(p, NULL, 0);
+	if (ld_io_ops->encode_layoutcommit) {
+		ld_io_ops->encode_layoutcommit(&NFS_I(args->inode)->layout,
+					       xdr, args);
+	} else {
+		p = reserve_space(xdr, 4);
+		xdr_encode_opaque(p, NULL, 0);
+	}
 
 	hdr->nops++;
 	hdr->replen += decode_layoutcommit_maxsz;
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index d20b5de..93fccfd 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -154,6 +154,9 @@ struct layoutdriver_io_operations {
 	struct pnfs_layout_segment * (*alloc_lseg) (struct pnfs_layout_type *layoutid, struct nfs4_pnfs_layoutget_res *lgr);
 	void (*free_lseg) (struct pnfs_layout_segment *lseg);
 
+	void (*encode_layoutcommit) (struct pnfs_layout_type *layoutid,
+				struct xdr_stream *xdr,
+				const struct pnfs_layoutcommit_arg *args);
 	void (*encode_layoutreturn) (struct pnfs_layout_type *layoutid,
 				struct xdr_stream *xdr,
 				const struct nfs4_pnfs_layoutreturn_arg *args);
-- 
1.6.6


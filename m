Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:64950 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751300Ab0LJGIl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Dec 2010 01:08:41 -0500
Received: from localhost.localdomain (kozen-lxp.hq.netapp.com [10.58.53.114] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oBA68VLf023313
	for <linux-nfs@vger.kernel.org>; Thu, 9 Dec 2010 22:08:40 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 04/22] Revert "pnfs_submit: roc add layoutcommit op to close compound"
Date: Thu,  9 Dec 2010 20:22:39 -0500
Message-Id: <1291944177-7819-5-git-send-email-iisaman@netapp.com>
In-Reply-To: <1291944177-7819-1-git-send-email-iisaman@netapp.com>
References: <1291944177-7819-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This reverts commit 361887febfa01e06c5ae7c38cc6867da3e4cf31d.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4xdr.c        |   11 ++---------
 fs/nfs/pnfs.c           |    9 +--------
 include/linux/nfs_xdr.h |    2 --
 3 files changed, 3 insertions(+), 19 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index b9fe438..dc63895 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -439,15 +439,13 @@ static int nfs4_stat_to_errno(int);
 				 encode_putfh_maxsz + \
 				 encode_close_maxsz + \
 				 encode_getattr_maxsz + \
-				 encode_layoutreturn_maxsz + \
-				 encode_layoutcommit_maxsz)
+				 encode_layoutreturn_maxsz)
 #define NFS4_dec_close_sz	(compound_decode_hdr_maxsz + \
 				 decode_sequence_maxsz + \
 				 decode_putfh_maxsz + \
 				 decode_close_maxsz + \
 				 decode_getattr_maxsz + \
-				 decode_layoutreturn_maxsz + \
-				 decode_layoutcommit_maxsz)
+				 decode_layoutreturn_maxsz)
 #define NFS4_enc_setattr_sz	(compound_encode_hdr_maxsz + \
 				 encode_sequence_maxsz + \
 				 encode_putfh_maxsz + \
@@ -2138,8 +2136,6 @@ static int nfs4_xdr_enc_close(struct rpc_rqst *req, __be32 *p, struct nfs_closea
 	encode_compound_hdr(&xdr, req, &hdr);
 	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
-	if (args->op_bitmask & NFS4_HAS_LAYOUTCOMMIT) /* layoutcommit set */
-		encode_layoutcommit(&xdr, &args->lc_args, &hdr);
 	encode_close(&xdr, args, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
 	if (args->op_bitmask & NFS4_HAS_LAYOUTRETURN) /* layoutreturn set */
@@ -5709,9 +5705,6 @@ static int nfs4_xdr_dec_close(struct rpc_rqst *rqstp, __be32 *p, struct nfs_clos
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
-	/* We pay no attention to the layoutcommit return */
-	if (res->op_bitmask & NFS4_HAS_LAYOUTCOMMIT)
-		decode_layoutcommit(&xdr);
 	status = decode_close(&xdr, res);
 	if (status != 0)
 		goto out;
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 1d3c849..4746b20 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -612,6 +612,7 @@ pnfs_return_layout_barrier(struct nfs_inode *nfsi,
  * Return on close
  *
  * No LAYOUTRETURNS can be sent when BULK RECALL flag is set.
+ * FIXME: add layoutcommit operation if layoutcommit_needed is true.
  */
 bool
 pnfs_roc(struct nfs4_closedata *data)
@@ -639,14 +640,6 @@ pnfs_roc(struct nfs4_closedata *data)
 		}
 	if (found == false)
 		goto out_nolayout;
-
-	/* Add layoutcommit operation if needed */
-	if (layoutcommit_needed(NFS_I(data->inode))) {
-		pnfs_layoutcommit_setup(data->inode, &data->arg.lc_args, false);
-		data->res.op_bitmask |= NFS4_HAS_LAYOUTCOMMIT;
-		data->arg.op_bitmask |= NFS4_HAS_LAYOUTCOMMIT;
-	}
-
 	/* Stop new and drop response to outstanding LAYOUTGETS */
 	lo->plh_block_lgets++;
 	lo->plh_outstanding++;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 5ec855b..1b7364f 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -352,7 +352,6 @@ struct nfs_open_confirmres {
 
 /* op_bitmask bits */
 #define NFS4_HAS_LAYOUTRETURN  0x01
-#define NFS4_HAS_LAYOUTCOMMIT  0x02
 
 struct nfs_closeargs {
 	struct nfs_fh *         fh;
@@ -361,7 +360,6 @@ struct nfs_closeargs {
 	fmode_t			fmode;
 	const u32 *		bitmask;
 	u32			op_bitmask; /* which optional ops to encode */
-	struct nfs4_layoutcommit_op_args lc_args; /* optional */
 	struct nfs4_layoutreturn_args	lr_args; /* optional */
 	struct nfs4_sequence_args	seq_args;
 };
-- 
1.7.2.1


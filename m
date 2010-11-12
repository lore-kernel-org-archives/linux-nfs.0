Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:65354 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756051Ab0KLIt1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Nov 2010 03:49:27 -0500
Received: from localhost.localdomain (hess01-lxp.hq.netapp.com [10.58.60.52] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oAC8n7fV025967
	for <linux-nfs@vger.kernel.org>; Fri, 12 Nov 2010 00:49:23 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 21/22] pnfs_submit: roc add layoutcommit op to close compound
Date: Fri, 12 Nov 2010 03:48:43 -0500
Message-Id: <1289551724-18575-22-git-send-email-iisaman@netapp.com>
In-Reply-To: <1289551724-18575-1-git-send-email-iisaman@netapp.com>
References: <1289551724-18575-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Place the layoutcommi operation prior to the close operation in the close
compound so that the filehandle is still valid.

If the layoutcommit fails, a retry of the close compound, which retries with
rpc_restart_call_prepare and so calls pnfs_roc again, will not include the
layoutcommit operation, as the layoutcommit_needed test will be false having
been satisfied by the failed compound.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4xdr.c        |   11 +++++++++--
 fs/nfs/pnfs.c           |    9 ++++++++-
 include/linux/nfs_xdr.h |    2 ++
 3 files changed, 19 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index f11870e..b016ec8 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -439,13 +439,15 @@ static int nfs4_stat_to_errno(int);
 				 encode_putfh_maxsz + \
 				 encode_close_maxsz + \
 				 encode_getattr_maxsz + \
-				 encode_layoutreturn_maxsz)
+				 encode_layoutreturn_maxsz + \
+				 encode_layoutcommit_maxsz)
 #define NFS4_dec_close_sz	(compound_decode_hdr_maxsz + \
 				 decode_sequence_maxsz + \
 				 decode_putfh_maxsz + \
 				 decode_close_maxsz + \
 				 decode_getattr_maxsz + \
-				 decode_layoutreturn_maxsz)
+				 decode_layoutreturn_maxsz + \
+				 decode_layoutcommit_maxsz)
 #define NFS4_enc_setattr_sz	(compound_encode_hdr_maxsz + \
 				 encode_sequence_maxsz + \
 				 encode_putfh_maxsz + \
@@ -2136,6 +2138,8 @@ static int nfs4_xdr_enc_close(struct rpc_rqst *req, __be32 *p, struct nfs_closea
 	encode_compound_hdr(&xdr, req, &hdr);
 	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
+	if (args->op_bitmask & NFS4_HAS_LAYOUTCOMMIT) /* layoutcommit set */
+		encode_layoutcommit(&xdr, &args->lc_args, &hdr);
 	encode_close(&xdr, args, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
 	if (args->op_bitmask & NFS4_HAS_LAYOUTRETURN) /* layoutreturn set */
@@ -5705,6 +5709,9 @@ static int nfs4_xdr_dec_close(struct rpc_rqst *rqstp, __be32 *p, struct nfs_clos
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
+	/* We pay no attention to the layoutcommit return */
+	if (res->op_bitmask & NFS4_HAS_LAYOUTCOMMIT)
+		decode_layoutcommit(&xdr);
 	status = decode_close(&xdr, res);
 	if (status != 0)
 		goto out;
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index f2ec773..15673d0 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -627,7 +627,6 @@ pnfs_return_layout_barrier(struct nfs_inode *nfsi,
  * Return on close
  *
  * No LAYOUTRETURNS can be sent when BULK RECALL flag is set.
- * FIXME: add layoutcommit operation if layoutcommit_needed is true.
  */
 bool
 pnfs_roc(struct nfs4_closedata *data)
@@ -655,6 +654,14 @@ pnfs_roc(struct nfs4_closedata *data)
 		}
 	if (found == false)
 		goto out_nolayout;
+
+	/* Add layoutcommit operation if needed */
+	if (layoutcommit_needed(NFS_I(data->inode))) {
+		pnfs_layoutcommit_setup(data->inode, &data->arg.lc_args, false);
+		data->res.op_bitmask |= NFS4_HAS_LAYOUTCOMMIT;
+		data->arg.op_bitmask |= NFS4_HAS_LAYOUTCOMMIT;
+	}
+
 	/* Stop new and drop response to outstanding LAYOUTGETS */
 	lo->plh_block_lgets++;
 	lo->plh_outstanding++;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 851b09f..d4c4804 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -353,6 +353,7 @@ struct nfs_open_confirmres {
 
 /* op_bitmask bits */
 #define NFS4_HAS_LAYOUTRETURN  0x01
+#define NFS4_HAS_LAYOUTCOMMIT  0x02
 
 struct nfs_closeargs {
 	struct nfs_fh *         fh;
@@ -361,6 +362,7 @@ struct nfs_closeargs {
 	fmode_t			fmode;
 	const u32 *		bitmask;
 	u32			op_bitmask; /* which optional ops to encode */
+	struct nfs4_layoutcommit_op_args lc_args; /* optional */
 	struct nfs4_layoutreturn_args	lr_args; /* optional */
 	struct nfs4_sequence_args	seq_args;
 };
-- 
1.7.2.1


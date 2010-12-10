Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:56510 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751300Ab0LJGIk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Dec 2010 01:08:40 -0500
Received: from localhost.localdomain (kozen-lxp.hq.netapp.com [10.58.53.114] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oBA68VLd023313
	for <linux-nfs@vger.kernel.org>; Thu, 9 Dec 2010 22:08:34 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 02/22] Revert "SQUASHME: pnfs-submit: encode layoutreturn on close before close"
Date: Thu,  9 Dec 2010 20:22:37 -0500
Message-Id: <1291944177-7819-3-git-send-email-iisaman@netapp.com>
In-Reply-To: <1291944177-7819-1-git-send-email-iisaman@netapp.com>
References: <1291944177-7819-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This reverts commit aafe6a6b39b0ddf87496d3912b308bf08ed6b2b9.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4xdr.c |   35 +++++++++++++++++------------------
 fs/nfs/pnfs.c    |    1 -
 2 files changed, 17 insertions(+), 19 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index f3aaa21..8dbfbb0 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -441,17 +441,17 @@ static int nfs4_stat_to_errno(int);
 #define NFS4_enc_close_sz	(compound_encode_hdr_maxsz + \
 				 encode_sequence_maxsz + \
 				 encode_putfh_maxsz + \
-				 encode_layoutcommit_maxsz + \
-				 encode_layoutreturn_maxsz + \
 				 encode_close_maxsz + \
-				 encode_getattr_maxsz)
+				 encode_getattr_maxsz + \
+				 encode_layoutreturn_maxsz + \
+				 encode_layoutcommit_maxsz)
 #define NFS4_dec_close_sz	(compound_decode_hdr_maxsz + \
 				 decode_sequence_maxsz + \
 				 decode_putfh_maxsz + \
-				 decode_layoutcommit_maxsz + \
-				 decode_layoutreturn_maxsz + \
 				 decode_close_maxsz + \
-				 decode_getattr_maxsz)
+				 decode_getattr_maxsz + \
+				 decode_layoutreturn_maxsz + \
+				 decode_layoutcommit_maxsz)
 #define NFS4_enc_setattr_sz	(compound_encode_hdr_maxsz + \
 				 encode_sequence_maxsz + \
 				 encode_putfh_maxsz + \
@@ -2160,10 +2160,10 @@ static int nfs4_xdr_enc_close(struct rpc_rqst *req, __be32 *p, struct nfs_closea
 	encode_putfh(&xdr, args->fh, &hdr);
 	if (args->op_bitmask & NFS4_HAS_LAYOUTCOMMIT) /* layoutcommit set */
 		encode_layoutcommit(&xdr, &args->lc_args, &hdr);
-	if (args->op_bitmask & NFS4_HAS_LAYOUTRETURN) /* layoutreturn set */
-		encode_layoutreturn(&xdr, &args->lr_args, &hdr);
 	encode_close(&xdr, args, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
+	if (args->op_bitmask & NFS4_HAS_LAYOUTRETURN) /* layoutreturn set */
+		encode_layoutreturn(&xdr, &args->lr_args, &hdr);
 	encode_nops(&hdr);
 	return 0;
 }
@@ -5743,16 +5743,9 @@ static int nfs4_xdr_dec_close(struct rpc_rqst *rqstp, __be32 *p, struct nfs_clos
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
-	if (res->op_bitmask & NFS4_HAS_LAYOUTCOMMIT) {
-		status = decode_layoutcommit(&xdr);
-		if (status)
-			goto out;
-	}
-	if (res->op_bitmask & NFS4_HAS_LAYOUTRETURN) {
-		status = decode_layoutreturn(&xdr, &res->lr_res);
-		if (status)
-			goto out;
-	}
+	/* We pay no attention to the layoutcommit return */
+	if (res->op_bitmask & NFS4_HAS_LAYOUTCOMMIT)
+		decode_layoutcommit(&xdr);
 	status = decode_close(&xdr, res);
 	if (status != 0)
 		goto out;
@@ -5764,6 +5757,12 @@ static int nfs4_xdr_dec_close(struct rpc_rqst *rqstp, __be32 *p, struct nfs_clos
 	 */
 	decode_getfattr(&xdr, res->fattr, res->server,
 			!RPC_IS_ASYNC(rqstp->rq_task));
+	/*
+	 * With the forgetful model, we pay no attention to the
+	 * layoutreturn status.
+	 */
+	if (res->op_bitmask & NFS4_HAS_LAYOUTRETURN)
+		decode_layoutreturn(&xdr, &res->lr_res);
 out:
 	return status;
 }
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index d3ce095..1d3c849 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -625,7 +625,6 @@ pnfs_roc(struct nfs4_closedata *data)
 	LIST_HEAD(tmp_list);
 	bool found = false;
 
-	data->arg.op_bitmask = data->res.op_bitmask = 0;
 	spin_lock(&data->inode->i_lock);
 	lo = NFS_I(data->inode)->layout;
 	if (!lo || lo->roc_iomode == 0 ||
-- 
1.7.2.1


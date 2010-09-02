Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:2363 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750802Ab0IBH7A (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Sep 2010 03:59:00 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] SQUASHME: pnfs-submit: fix getdeviceinfo decode sizing
Date: Thu,  2 Sep 2010 10:58:56 +0300
Message-Id: <1283414336-14878-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4C7F58F9.4080306@panasas.com>
References: <4C7F58F9.4080306@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

it looks like we forgot to adjust hdr->replen in
encode_getdeviceinfo (and encode_getdevicelist).

and decode_getdeviceinfo_maxsz is completely wrong!
It's in bytes, not words as it should be.
Ironically, this balanced the -8 bug above in computing replen
for xdi_inline_pages

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c |   24 ++++++++++--------------
 1 files changed, 10 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 42a91c9..c422964 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -325,10 +325,11 @@ static int nfs4_stat_to_errno(int);
 #define encode_getdeviceinfo_maxsz (op_encode_hdr_maxsz + 4 + \
 				XDR_QUADLEN(NFS4_PNFS_DEVICEID4_SIZE))
 #define decode_getdeviceinfo_maxsz (op_decode_hdr_maxsz + \
-				4 /*layout type */ + \
-				4 /* opaque devaddr4 length */ +\
-				4 /* notification bitmap length */ + \
-				4 /* notification bitmap */)
+				1 /* layout type */ + \
+				1 /* opaque devaddr4 length */ + \
+				  /* devaddr4 payload is read into page */ \
+				1 /* notification bitmap length */ + \
+				1 /* notification bitmap */)
 #define encode_layoutget_maxsz	(op_encode_hdr_maxsz + 10 + \
 				encode_stateid_maxsz)
 #define decode_layoutget_maxsz	(op_decode_hdr_maxsz + 8 + \
@@ -1888,6 +1889,7 @@ encode_getdeviceinfo(struct xdr_stream *xdr,
 	if (has_bitmap)
 		*p = cpu_to_be32(args->pdev->dev_notify_types);
 	hdr->nops++;
+	hdr->replen += decode_getdeviceinfo_maxsz;
 }
 
 static void
@@ -2850,26 +2852,20 @@ static int nfs4_xdr_enc_getdeviceinfo(struct rpc_rqst *req, uint32_t *p,
 				      struct nfs4_getdeviceinfo_args *args)
 {
 	struct xdr_stream xdr;
-	struct rpc_auth *auth = req->rq_task->tk_msg.rpc_cred->cr_auth;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
-	int replen;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
 	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_getdeviceinfo(&xdr, args, &hdr);
 
-	/* set up reply kvec. Subtract notification bitmap max size (8)
+	/* set up reply kvec. Subtract notification bitmap max size (2)
 	 * so that notification bitmap is put in xdr_buf tail */
-	replen = (RPC_REPHDRSIZE + auth->au_rslack +
-		  NFS4_dec_getdeviceinfo_sz - 8) << 2;
-	xdr_inline_pages(&req->rq_rcv_buf, replen, args->pdev->pages,
-			 args->pdev->pgbase, args->pdev->pglen);
-	dprintk("%s: inlined page args = (%u, %p, %u, %u)\n",
-		__func__, replen, args->pdev->pages,
-		args->pdev->pgbase, args->pdev->pglen);
+	xdr_inline_pages(&req->rq_rcv_buf, (hdr.replen - 2) << 2,
+			 args->pdev->pages, args->pdev->pgbase,
+			 args->pdev->pglen);
 
 	encode_nops(&hdr);
 	return 0;
-- 
1.7.2.2


From: andros@netapp.com
Subject: [PATCH 2/2] nfs41: back channel drc minimal implementation
Date: Mon, 21 Dec 2009 17:46:06 -0500
Message-ID: <1261435566-13814-3-git-send-email-andros@netapp.com>
References: <1261435566-13814-1-git-send-email-andros@netapp.com>
 <1261435566-13814-2-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:62897 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757179AbZLUWrE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Dec 2009 17:47:04 -0500
In-Reply-To: <1261435566-13814-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

For now the back channel ca_maxresponsesize_cached is 0 and there is no
backchannel DRC. Return NFS4ERR_REP_TOO_BIG_TO_CACHE when a cb_sequence
cachethis is true.  When it is false, return NFS4ERR_RETRY_UNCACHED_REP as the
next operation error.

Remember the replay error accross compound operation processing.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/callback_proc.c |   20 +++++++++++++++-----
 fs/nfs/callback_xdr.c  |   19 +++++++++++++++----
 2 files changed, 30 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 7f92b6d..c5e66fd 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -174,9 +174,15 @@ validate_seqid(struct nfs4_slot_table *tbl, struct cb_sequenceargs * args)
 
 	/* Replay */
 	if (args->csa_sequenceid == slot->seq_nr) {
-		dprintk("%s seqid %d is a replay - no DRC available\n",
+		dprintk("%s seqid %d is a replay\n",
 			__func__, args->csa_sequenceid);
-		return htonl(NFS4_OK);
+		/* Signal process_op to set this error on next op */
+		if (args->csa_cachethis == 0)
+			return htonl(NFS4ERR_RETRY_UNCACHED_REP);
+
+		/* The ca_maxresponsesize_cached is 0 with no DRC */
+		else if (args->csa_cachethis == 1)
+			return htonl(NFS4ERR_REP_TOO_BIG_TO_CACHE);
 	}
 
 	/* Wraparound */
@@ -255,9 +261,13 @@ unsigned nfs4_callback_sequence(struct cb_sequenceargs *args,
 out_putclient:
 	nfs_put_client(clp);
 out:
-	dprintk("%s: exit with status = %d\n", __func__, ntohl(status));
-	res->csr_status = status;
-	return res->csr_status;
+	if (status == htonl(NFS4ERR_RETRY_UNCACHED_REP))
+		res->csr_status = 0;
+	else
+		res->csr_status = status;
+	dprintk("%s: exit with status = %d res->csr_status %d\n", __func__,
+		ntohl(status), ntohl(res->csr_status));
+	return status;
 }
 
 unsigned nfs4_callback_recallany(struct cb_recallanyargs *args, void *dummy)
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 8e1a251..0365f79 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -602,7 +602,7 @@ preprocess_nfs4_op(unsigned int op_nr, struct callback_op **op)
 static __be32 process_op(uint32_t minorversion, int nop,
 		struct svc_rqst *rqstp,
 		struct xdr_stream *xdr_in, void *argp,
-		struct xdr_stream *xdr_out, void *resp)
+		struct xdr_stream *xdr_out, void *resp, int* drc_status)
 {
 	struct callback_op *op = &callback_ops[0];
 	unsigned int op_nr = OP_CB_ILLEGAL;
@@ -624,6 +624,11 @@ static __be32 process_op(uint32_t minorversion, int nop,
 				preprocess_nfs4_op(op_nr, &op);
 	if (status == htonl(NFS4ERR_OP_ILLEGAL))
 		op_nr = OP_CB_ILLEGAL;
+
+	if (*drc_status) {
+		status = *drc_status;
+		goto encode_hdr;
+	}
 out:
 	maxlen = xdr_out->end - xdr_out->p;
 	if (maxlen > 0 && maxlen < PAGE_SIZE) {
@@ -634,6 +639,12 @@ out:
 	} else
 		status = htonl(NFS4ERR_RESOURCE);
 
+	/* Only set by OP_CB_SEQUENCE processing */
+	if (status == htonl(NFS4ERR_RETRY_UNCACHED_REP)) {
+		*drc_status = status;
+		status = 0;
+	}
+encode_hdr:
 	res = encode_op_hdr(xdr_out, op_nr, status);
 	if (status == 0)
 		status = res;
@@ -652,7 +663,7 @@ static __be32 nfs4_callback_compound(struct svc_rqst *rqstp, void *argp, void *r
 	struct cb_compound_hdr_res hdr_res = { NULL };
 	struct xdr_stream xdr_in, xdr_out;
 	__be32 *p;
-	__be32 status;
+	__be32 status, drc_status = 0;
 	unsigned int nops = 0;
 
 	dprintk("%s: start\n", __func__);
@@ -672,8 +683,8 @@ static __be32 nfs4_callback_compound(struct svc_rqst *rqstp, void *argp, void *r
 		return rpc_system_err;
 
 	while (status == 0 && nops != hdr_arg.nops) {
-		status = process_op(hdr_arg.minorversion, nops,
-				    rqstp, &xdr_in, argp, &xdr_out, resp);
+		status = process_op(hdr_arg.minorversion, nops, rqstp,
+				    &xdr_in, argp, &xdr_out, resp, &drc_status);
 		nops++;
 	}
 
-- 
1.6.0.6


From: andros@netapp.com
Subject: [PATCH 1/7] nfs41: fix wrong error on callback header xdr overflow
Date: Thu, 14 Jan 2010 17:45:04 -0500
Message-ID: <1263509110-3097-2-git-send-email-andros@netapp.com>
References: <1263509110-3097-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:5161 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754849Ab0ANWpO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Jan 2010 17:45:14 -0500
In-Reply-To: <1263509110-3097-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Set NFS4ERR_RESOURCE as CB_COMPOUND status and do not return an op on
decode_op_hdr or encode_op_hdr buffer overflow.

NFS4ERR_RESOURCE is correct for v4.0. Will fix the return for v4.1 along with
all the other NFS4ERR_RESOURCE errors in a later patch.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/callback_xdr.c |   28 ++++++++++++++++++----------
 1 files changed, 18 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 8e1a251..6ae3278 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -28,6 +28,9 @@
 
 #define NFSDBG_FACILITY NFSDBG_CALLBACK
 
+/* Internal error code */
+#define NFS4ERR_RESOURCE_HDR	11050
+
 typedef __be32 (*callback_process_op_t)(void *, void *);
 typedef __be32 (*callback_decode_arg_t)(struct svc_rqst *, struct xdr_stream *, void *);
 typedef __be32 (*callback_encode_res_t)(struct svc_rqst *, struct xdr_stream *, void *);
@@ -173,7 +176,7 @@ static __be32 decode_op_hdr(struct xdr_stream *xdr, unsigned int *op)
 	__be32 *p;
 	p = read_buf(xdr, 4);
 	if (unlikely(p == NULL))
-		return htonl(NFS4ERR_RESOURCE);
+		return htonl(NFS4ERR_RESOURCE_HDR);
 	*op = ntohl(*p);
 	return 0;
 }
@@ -465,7 +468,7 @@ static __be32 encode_op_hdr(struct xdr_stream *xdr, uint32_t op, __be32 res)
 	
 	p = xdr_reserve_space(xdr, 8);
 	if (unlikely(p == NULL))
-		return htonl(NFS4ERR_RESOURCE);
+		return htonl(NFS4ERR_RESOURCE_HDR);
 	*p++ = htonl(op);
 	*p = res;
 	return 0;
@@ -605,17 +608,15 @@ static __be32 process_op(uint32_t minorversion, int nop,
 		struct xdr_stream *xdr_out, void *resp)
 {
 	struct callback_op *op = &callback_ops[0];
-	unsigned int op_nr = OP_CB_ILLEGAL;
+	unsigned int op_nr;
 	__be32 status;
 	long maxlen;
 	__be32 res;
 
 	dprintk("%s: start\n", __func__);
 	status = decode_op_hdr(xdr_in, &op_nr);
-	if (unlikely(status)) {
-		status = htonl(NFS4ERR_OP_ILLEGAL);
-		goto out;
-	}
+	if (unlikely(status))
+		return status;
 
 	dprintk("%s: minorversion=%d nop=%d op_nr=%u\n",
 		__func__, minorversion, nop, op_nr);
@@ -624,7 +625,7 @@ static __be32 process_op(uint32_t minorversion, int nop,
 				preprocess_nfs4_op(op_nr, &op);
 	if (status == htonl(NFS4ERR_OP_ILLEGAL))
 		op_nr = OP_CB_ILLEGAL;
-out:
+
 	maxlen = xdr_out->end - xdr_out->p;
 	if (maxlen > 0 && maxlen < PAGE_SIZE) {
 		if (likely(status == 0 && op->decode_args != NULL))
@@ -635,8 +636,8 @@ out:
 		status = htonl(NFS4ERR_RESOURCE);
 
 	res = encode_op_hdr(xdr_out, op_nr, status);
-	if (status == 0)
-		status = res;
+	if (unlikely(res))
+		return res;
 	if (op->encode_res != NULL && status == 0)
 		status = op->encode_res(rqstp, xdr_out, resp);
 	dprintk("%s: done, status = %d\n", __func__, ntohl(status));
@@ -677,6 +678,13 @@ static __be32 nfs4_callback_compound(struct svc_rqst *rqstp, void *argp, void *r
 		nops++;
 	}
 
+	/* Buffer overflow in decode_ops_hdr or encode_ops_hdr. Return
+	* resource error in cb_compound status without returning op */
+	if (unlikely(status == htonl(NFS4ERR_RESOURCE_HDR))) {
+		status = htonl(NFS4ERR_RESOURCE);
+		nops--;
+	}
+
 	*hdr_res.status = status;
 	*hdr_res.nops = htonl(nops);
 	dprintk("%s: done, status = %u\n", __func__, ntohl(status));
-- 
1.6.5.2


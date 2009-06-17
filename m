From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 2/3] SQUASHME: nfs41: refactor op preprocessing out of process_op
Date: Wed, 17 Jun 2009 20:22:04 +0300
Message-ID: <1245259324-9371-1-git-send-email-bhalevy@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:14434
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755091AbZFQRWD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Jun 2009 13:22:03 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fixes Trond's review comment from 2009-06-15:
Re: [pnfs] [RFC 27/39] nfs41: consider minorversion in callback_xdr:process_op
http://linux-nfs.org/pipermail/pnfs/2009-June/007845.html

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/callback_xdr.c |  119 +++++++++++++++++++++++++++---------------------
 1 files changed, 67 insertions(+), 52 deletions(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 654a6a2..28242a0 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -523,8 +523,67 @@ out:
 	return status;
 }
 
+static __be32
+preprocess_nfs41_op(int nop, unsigned int op_nr, struct callback_op **op)
+{
+	if (op_nr == OP_CB_SEQUENCE) {
+		if (nop != 0)
+			return htonl(NFS4ERR_SEQUENCE_POS);
+	} else {
+		if (nop == 0)
+			return htonl(NFS4ERR_OP_NOT_IN_SESSION);
+	}
+
+	switch (op_nr) {
+	case OP_CB_GETATTR:
+	case OP_CB_RECALL:
+	case OP_CB_SEQUENCE:
+		*op = &callback_ops[op_nr];
+		break;
+
+	case OP_CB_LAYOUTRECALL:
+	case OP_CB_NOTIFY_DEVICEID:
+	case OP_CB_NOTIFY:
+	case OP_CB_PUSH_DELEG:
+	case OP_CB_RECALL_ANY:
+	case OP_CB_RECALLABLE_OBJ_AVAIL:
+	case OP_CB_RECALL_SLOT:
+	case OP_CB_WANTS_CANCELLED:
+	case OP_CB_NOTIFY_LOCK:
+		return htonl(NFS4ERR_NOTSUPP);
+
+	default:
+		return htonl(NFS4ERR_OP_ILLEGAL);
+	}
+
+	return htonl(NFS_OK);
+}
+
+#else /* CONFIG_NFS_V4_1 */
+
+static __be32
+preprocess_nfs41_op(int nop, unsigned int op_nr, struct callback_op **op)
+{
+	return htonl(NFS4ERR_MINOR_VERS_MISMATCH);
+}
+
 #endif /* CONFIG_NFS_V4_1 */
 
+static __be32
+preprocess_nfs4_op(unsigned int op_nr, struct callback_op **op)
+{
+	switch (op_nr) {
+	case OP_CB_GETATTR:
+	case OP_CB_RECALL:
+		*op = &callback_ops[op_nr];
+		break;
+	default:
+		return htonl(NFS4ERR_OP_ILLEGAL);
+	}
+
+	return htonl(NFS_OK);
+}
+
 static __be32 process_op(uint32_t minorversion, int nop,
 		struct svc_rqst *rqstp,
 		struct xdr_stream *xdr_in, void *argp,
@@ -538,56 +597,18 @@ static __be32 process_op(uint32_t minorversion, int nop,
 
 	dprintk("%s: start\n", __func__);
 	status = decode_op_hdr(xdr_in, &op_nr);
-	if (unlikely(status))
-		goto out_illegal;
+	if (unlikely(status)) {
+		status = htonl(NFS4ERR_OP_ILLEGAL);
+		goto out;
+	}
 
 	dprintk("%s: minorversion=%d nop=%d op_nr=%u\n",
 		__func__, minorversion, nop, op_nr);
-#if defined(CONFIG_NFS_V4_1)
-	if (minorversion == 1) {
-		if (op_nr == OP_CB_SEQUENCE) {
-			if (nop != 0) {
-				status = htonl(NFS4ERR_SEQUENCE_POS);
-				goto out;
-			}
-		} else if (nop == 0)
-			status = htonl(NFS4ERR_OP_NOT_IN_SESSION);
-
-		switch (op_nr) {
-		case OP_CB_GETATTR:
-		case OP_CB_RECALL:
-		case OP_CB_SEQUENCE:
-			op = &callback_ops[op_nr];
-			break;
-
-		case OP_CB_LAYOUTRECALL:
-		case OP_CB_NOTIFY:
-		case OP_CB_PUSH_DELEG:
-		case OP_CB_RECALL_ANY:
-		case OP_CB_RECALLABLE_OBJ_AVAIL:
-		case OP_CB_RECALL_SLOT:
-		case OP_CB_WANTS_CANCELLED:
-		case OP_CB_NOTIFY_LOCK:
-		case OP_CB_NOTIFY_DEVICEID:
-			op = &callback_ops[0];
-			status = htonl(NFS4ERR_NOTSUPP);
-			break;
-		default:
-			goto out_illegal;
-		}
 
-		goto out;
-	}
-#endif /* defined(CONFIG_NFS_V4_1) */
-
-	switch (op_nr) {
-	case OP_CB_GETATTR:
-	case OP_CB_RECALL:
-		op = &callback_ops[op_nr];
-		break;
-	default:
-		goto out_illegal;
-	}
+	status = minorversion ? preprocess_nfs41_op(nop, op_nr, &op) :
+				preprocess_nfs4_op(op_nr, &op);
+	if (status == htonl(NFS4ERR_OP_ILLEGAL))
+		op_nr = OP_CB_ILLEGAL;
 out:
 	maxlen = xdr_out->end - xdr_out->p;
 	if (maxlen > 0 && maxlen < PAGE_SIZE) {
@@ -605,12 +626,6 @@ out:
 		status = op->encode_res(rqstp, xdr_out, resp);
 	dprintk("%s: done, status = %d\n", __func__, ntohl(status));
 	return status;
-
-out_illegal:
-	op_nr = OP_CB_ILLEGAL;
-	op = &callback_ops[0];
-	status = htonl(NFS4ERR_OP_ILLEGAL);
-	goto out;
 }
 
 /*
-- 
1.6.3.1


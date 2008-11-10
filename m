From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 84/85] nfs41: cb_sequence xdr implementation
Date: Mon, 10 Nov 2008 22:33:12 +0200
Message-ID: <1226349192-10041-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:53161 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753237AbYKJUdS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:33:18 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/callback_xdr.c |  191 ++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 189 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 9db88ce..7b96b09 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -20,8 +20,28 @@
 				2 + 2 + 3 + 3)
 #define CB_OP_RECALL_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ)
 
+#if defined(CONFIG_NFS_V4_1)
+#define CB_OP_SEQUENCE_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ + \
+					4 + 1 + 3)
+#endif /* CONFIG_NFS_V4_1 */
+
 #define NFSDBG_FACILITY NFSDBG_CALLBACK
 
+#define READ64(x)         do {			\
+	(x) = (u64)ntohl(*p++) << 32;		\
+	(x) |= ntohl(*p++);			\
+} while (0)
+
+#define READMEM(x,nbytes) do {			\
+	x = (char *)p;				\
+	p += XDR_QUADLEN(nbytes);		\
+} while (0)
+
+#define COPYMEM(x,nbytes) do {			\
+	memcpy((x), p, nbytes);			\
+	p += XDR_QUADLEN(nbytes);		\
+} while (0)
+
 typedef __be32 (*callback_process_op_t)(void *, void *);
 typedef __be32 (*callback_decode_arg_t)(struct svc_rqst *, struct xdr_stream *, void *);
 typedef __be32 (*callback_encode_res_t)(struct svc_rqst *, struct xdr_stream *, void *);
@@ -210,6 +230,122 @@ out:
 	return status;
 }
 
+#if defined(CONFIG_NFS_V4_1)
+
+static unsigned decode_sessionid(struct xdr_stream *xdr,
+				 nfs41_sessionid *sid)
+{
+	uint32_t *p;
+	int len = 16;
+
+	p = read_buf(xdr, len);
+	if (unlikely(p == NULL))
+		return htonl(NFS4ERR_RESOURCE);;
+
+	memcpy(sid, p, len);
+	return 0;
+}
+
+static unsigned decode_rc_list(struct xdr_stream *xdr,
+			       struct referring_call_list *rc_list)
+{
+	uint32_t *p;
+	int i;
+	unsigned status;
+
+	status = decode_sessionid(xdr, &rc_list->rcl_sessionid);
+	if (status)
+		goto out;
+
+	status = htonl(NFS4ERR_RESOURCE);
+	p = read_buf(xdr, sizeof(uint32_t));
+	if (unlikely(p == NULL))
+		goto out;
+
+	rc_list->rcl_nrefcalls = ntohl(*p++);
+	if (rc_list->rcl_nrefcalls) {
+		p = read_buf(xdr,
+			     rc_list->rcl_nrefcalls * 2 * sizeof(uint32_t));
+		if (unlikely(p == NULL))
+			goto out;
+		rc_list->rcl_refcalls = kmalloc(rc_list->rcl_nrefcalls *
+						sizeof(*rc_list->rcl_refcalls),
+						GFP_KERNEL);
+		if (unlikely(rc_list->rcl_refcalls == NULL))
+			goto out;
+		for (i = 0; i < rc_list->rcl_nrefcalls; i++) {
+			rc_list->rcl_refcalls[i].rc_sequenceid = ntohl(*p++);
+			rc_list->rcl_refcalls[i].rc_slotid = ntohl(*p++);
+		}
+	}
+	status = 0;
+
+out:
+	return status;
+}
+
+static unsigned decode_cb_sequence_args(struct svc_rqst *rqstp,
+					struct xdr_stream *xdr,
+					struct cb_sequenceargs *args)
+{
+	uint32_t *p;
+	int i;
+	unsigned status;
+
+	status = decode_sessionid(xdr, &args->csa_sessionid);
+	if (status)
+		goto out;
+
+	status = htonl(NFS4ERR_RESOURCE);
+	p = read_buf(xdr, 5 * sizeof(uint32_t));
+	if (unlikely(p == NULL))
+		goto out;
+
+	args->csa_addr = svc_addr_in(rqstp);
+	args->csa_sequenceid = ntohl(*p++);
+	args->csa_slotid = ntohl(*p++);
+	args->csa_highestslotid = ntohl(*p++);
+	args->csa_cachethis = ntohl(*p++);
+	args->csa_nrclists = ntohl(*p++);
+	args->csa_rclists = NULL;
+	if (args->csa_nrclists) {
+		args->csa_rclists = kmalloc(args->csa_nrclists *
+					    sizeof(*args->csa_rclists),
+					    GFP_KERNEL);
+		if (unlikely(args->csa_rclists == NULL))
+			goto out;
+
+		for (i = 0; i < args->csa_nrclists; i++) {
+			status = decode_rc_list(xdr, &args->csa_rclists[i]);
+			if (status)
+				goto out_free;
+		}
+	}
+	status = 0;
+
+	dprintk("%s: sessionid %x:%x:%x:%x sequenceid %u slotid %u "
+		"highestslotid %u cachethis %d nrclists %u\n",
+		__func__,
+		((u32 *)&args->csa_sessionid)[0],
+		((u32 *)&args->csa_sessionid)[1],
+		((u32 *)&args->csa_sessionid)[2],
+		((u32 *)&args->csa_sessionid)[3],
+		args->csa_sequenceid, args->csa_slotid,
+		args->csa_highestslotid, args->csa_cachethis,
+		args->csa_nrclists);
+out:
+	dprintk("%s: exit with status = %d\n", __func__, ntohl(status));
+	return status;
+
+out_free:
+	for (i = 0; i < args->csa_nrclists; i++)
+		kfree(args->csa_rclists[i].rcl_refcalls);
+	kfree(args->csa_rclists);
+	goto out;
+}
+
+#endif /* CONFIG_NFS_V4_1 */
+
 static __be32 encode_string(struct xdr_stream *xdr, unsigned int len, const char *str)
 {
 	__be32 *p;
@@ -359,6 +495,49 @@ out:
 	return status;
 }
 
+#if defined(CONFIG_NFS_V4_1)
+
+static unsigned encode_sessionid(struct xdr_stream *xdr,
+				 const nfs41_sessionid *sid)
+{
+	uint32_t *p;
+	int len = 4 * sizeof(uint32_t);
+
+	p = xdr_reserve_space(xdr, len);
+	if (unlikely(p == NULL))
+		return htonl(NFS4ERR_RESOURCE);
+
+	memcpy(p, sid, len);
+	return 0;
+}
+
+static unsigned encode_cb_sequence_res(struct svc_rqst *rqstp,
+				       struct xdr_stream *xdr,
+				       const struct cb_sequenceres *res)
+{
+	uint32_t *p;
+	unsigned status = res->csr_status;
+
+	if (unlikely(status != 0))
+		goto out;
+
+	encode_sessionid(xdr, &res->csr_sessionid);
+
+	p = xdr_reserve_space(xdr, 4 * sizeof(uint32_t));
+	if (unlikely(p == NULL))
+		return htonl(NFS4ERR_RESOURCE);
+
+	*p++ = htonl(res->csr_sequenceid);
+	*p++ = htonl(res->csr_slotid);
+	*p++ = htonl(res->csr_highestslotid);
+	*p++ = htonl(res->csr_target_highestslotid);
+out:
+	dprintk("%s: exit with status = %d\n", __func__, ntohl(status));
+	return status;
+}
+
+#endif /* CONFIG_NFS_V4_1 */
+
 static __be32 process_op(uint32_t minorversion, int nop,
 		struct svc_rqst *rqstp,
 		struct xdr_stream *xdr_in, void *argp,
@@ -382,6 +561,7 @@ static __be32 process_op(uint32_t minorversion, int nop,
 		switch (op_nr) {
 		case OP_CB_GETATTR:
 		case OP_CB_RECALL:
+		case OP_CB_SEQUENCE:
 			op = &callback_ops[op_nr];
 			break;
 
@@ -391,7 +571,6 @@ static __be32 process_op(uint32_t minorversion, int nop,
 		case OP_CB_RECALL_ANY:
 		case OP_CB_RECALLABLE_OBJ_AVAIL:
 		case OP_CB_RECALL_SLOT:
-		case OP_CB_SEQUENCE:
 		case OP_CB_WANTS_CANCELLED:
 		case OP_CB_NOTIFY_LOCK:
 		case OP_CB_NOTIFY_DEVICEID:
@@ -496,7 +675,15 @@ static struct callback_op callback_ops[] = {
 		.process_op = (callback_process_op_t)nfs4_callback_recall,
 		.decode_args = (callback_decode_arg_t)decode_recall_args,
 		.res_maxsize = CB_OP_RECALL_RES_MAXSZ,
-	}
+	},
+#if defined(CONFIG_NFS_V4_1)
+	[OP_CB_SEQUENCE] = {
+		.process_op = (callback_process_op_t)nfs4_callback_sequence,
+		.decode_args = (callback_decode_arg_t)decode_cb_sequence_args,
+		.encode_res = (callback_encode_res_t)encode_cb_sequence_res,
+		.res_maxsize = CB_OP_SEQUENCE_RES_MAXSZ,
+	},
+#endif /* CONFIG_NFS_V4_1 */
 };
 
 /*
-- 
1.6.0.2


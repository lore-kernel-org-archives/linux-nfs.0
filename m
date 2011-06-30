Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52337 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1758530Ab1F3IQw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Jun 2011 04:16:52 -0400
Message-ID: <4E0C31B5.9090302@cn.fujitsu.com>
Date: Thu, 30 Jun 2011 16:20:05 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: [RFC][PATCH 2/2] nfsd41: try to check reply size before operation
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Implementing each operation's enc_size, and try to check reply size 
before operation.

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 fs/nfsd/nfs4proc.c |    2 +-
 fs/nfsd/nfs4xdr.c  |  210 +++++++++++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 193 insertions(+), 19 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 3a6dbd7..06ca11c 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1165,7 +1165,7 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 			goto encode_op;
 		}
 
-		if (opdesc->op_func)
+		if (op->status == 0 && opdesc->op_func)
 			op->status = opdesc->op_func(rqstp, cstate, &op->u);
 		else
 			BUG_ON(op->status == nfs_ok);
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 1273661..ae35f7e 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3153,6 +3153,89 @@ struct nfsd4_enc_op {
 	u32 enc_size;
 };
 
+#define op_encode_hdr_size	(2)
+
+#define encode_stateid_maxsz	(XDR_QUADLEN(NFS4_STATEID_SIZE))
+#define encode_verifier_maxsz	(XDR_QUADLEN(NFS4_VERIFIER_SIZE))
+
+#define nfsd4_enc_access_sz	(op_encode_hdr_size + 2)
+#define nfsd4_enc_close_sz	(op_encode_hdr_size + encode_stateid_maxsz)
+#define nfsd4_enc_commit_sz	(op_encode_hdr_size + encode_verifier_maxsz)
+#define nfsd4_enc_create_sz	(op_encode_hdr_size + encode_stateid_maxsz)
+
+#define nfs4_owner_maxsz	(1 + XDR_QUADLEN(IDMAP_NAMESZ))
+#define nfs4_group_maxsz	(1 + XDR_QUADLEN(IDMAP_NAMESZ))
+#define nfs4_fattr_bitmap_maxsz	(3)
+#define nfs4_fattr_value_maxsz	(1 + (1 + 2 + 2 + 4 + 2 + 1 + 1 + 2 + 2 + \
+				 3 + 3 + 3 + nfs4_owner_maxsz + \
+				 nfs4_group_maxsz))
+#define nfs4_fattr_maxsz	(nfs4_fattr_bitmap_maxsz + \
+				 nfs4_fattr_value_maxsz)
+#define nfsd4_enc_getattr_sz	(op_encode_hdr_size + nfs4_fattr_maxsz)
+#define nfsd4_enc_getfh_sz	(op_encode_hdr_size + 1 + \
+				 ((3+NFS4_FHSIZE) >> 2))
+
+#define encode_change_info_maxsz (5)
+#define nfsd4_enc_link_sz	(op_encode_hdr_size + encode_change_info_maxsz)
+
+#define encode_lockowner_maxsz  (1 + XDR_QUADLEN(IDMAP_NAMESZ))
+#define encode_lock_denied_maxsz \
+				(8 + encode_lockowner_maxsz)
+#define nfsd4_enc_lock_sz	(op_encode_hdr_size + encode_lock_denied_maxsz)
+#define nfsd4_enc_lockt_sz	(op_encode_hdr_size + encode_lock_denied_maxsz)
+#define nfsd4_enc_locku_sz	(op_encode_hdr_size + encode_stateid_maxsz)
+
+#define encode_ace_maxsz	(3 + nfs4_owner_maxsz)
+#define encode_delegation_maxsz	(1 + encode_stateid_maxsz + 1 + \
+				 encode_ace_maxsz)
+#define nfsd4_enc_open_sz	(op_encode_hdr_size + encode_stateid_maxsz + \
+				 encode_change_info_maxsz + 1 + \
+				 nfs4_fattr_bitmap_maxsz + \
+				 encode_delegation_maxsz)
+#define nfsd4_enc_open_confirm_sz \
+				(op_encode_hdr_size + encode_stateid_maxsz)
+#define nfsd4_enc_open_downgrade_sz \
+				(op_encode_hdr_size + encode_stateid_maxsz)
+#define nfsd4_enc_read_sz	(op_encode_hdr_size + 2)
+#define nfsd4_enc_readdir_sz	(op_encode_hdr_size + encode_verifier_maxsz)
+#define nfsd4_enc_readlink_sz	(op_encode_hdr_size + 1)
+#define nfsd4_enc_remove_sz	(op_encode_hdr_size + encode_change_info_maxsz)
+#define nfsd4_enc_rename_sz	(op_encode_hdr_size + \
+				 encode_change_info_maxsz + \
+				 encode_change_info_maxsz)
+
+#define NFS_MAX_SECFLAVORS	(12)
+#define nfsd4_enc_secinfo_sz	(op_encode_hdr_size + 4 + \
+				 (NFS_MAX_SECFLAVORS * (16 + GSS_OID_MAX_LEN)))
+
+#define nfsd4_enc_setattr_sz	(op_encode_hdr_size + nfs4_fattr_bitmap_maxsz)
+#define nfsd4_enc_setclientid_sz \
+				(op_encode_hdr_size + 2 + 1024)
+#define nfsd4_enc_write_sz	(op_encode_hdr_size + 2 + encode_verifier_maxsz)
+
+/* For NFSv4.1*/
+#define nfsd4_enc_bind_conn_to_session_sz \
+				(op_encode_hdr_size + \
+				 XDR_QUADLEN(NFS4_MAX_SESSIONID_LEN) + 2)
+#define nfsd4_enc_exchange_id_sz \
+				(op_encode_hdr_size + 2 + 1 + 1 + 1 + 0 + \
+				 2 + XDR_QUADLEN(NFS4_OPAQUE_LIMIT) + 1 + \
+				 XDR_QUADLEN(NFS4_OPAQUE_LIMIT) + 1 + \
+				 1 + 0)
+
+#define encode_channel_attrs_maxsz  (6 + 1 + 1)
+#define nfsd4_enc_create_session_sz \
+				(op_encode_hdr_size + \
+				 XDR_QUADLEN(NFS4_MAX_SESSIONID_LEN) + \
+				 1 + 1 + encode_channel_attrs_maxsz + \
+				 encode_channel_attrs_maxsz)
+
+#define nfsd4_enc_destroy_session_sz \
+				(op_encode_hdr_size)
+#define nfsd4_enc_secinfo_no_name_sz nfsd4_enc_secinfo_sz
+#define nfsd4_enc_sequence_sz 	(op_encode_hdr_size + \
+				 XDR_QUADLEN(NFS4_MAX_SESSIONID_LEN) + 5)
+
 /*
  * Note: nfsd4_enc_ops vector is shared for v4.0 and v4.1
  * since we don't need to filter out obsolete ops as this is
@@ -3161,222 +3244,313 @@ struct nfsd4_enc_op {
 static struct nfsd4_enc_op nfsd4_enc_ops[] = {
 	[OP_ACCESS] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_access,
+		.enc_size = nfsd4_enc_access_sz,
 	},
 	[OP_CLOSE] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_close,
+		.enc_size = nfsd4_enc_close_sz,
 	},
 	[OP_COMMIT] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_commit,
+		.enc_size = nfsd4_enc_commit_sz,
 	},
 	[OP_CREATE] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_create,
+		.enc_size = nfsd4_enc_create_sz,
 	},
 	[OP_DELEGPURGE]	= {
 		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+		.enc_size = op_encode_hdr_size,
 	},
 	[OP_DELEGRETURN] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+		.enc_size = op_encode_hdr_size,
 	},
 	[OP_GETATTR] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_getattr,
+		.enc_size = nfsd4_enc_getattr_sz,
 	},
 	[OP_GETFH] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_getfh,
+		.enc_size = nfsd4_enc_getfh_sz,
 	},
 	[OP_LINK] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_link,
+		.enc_size = nfsd4_enc_link_sz,
 	},
 	[OP_LOCK] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_lock,
+		.enc_size = nfsd4_enc_lock_sz,
 	},
 	[OP_LOCKT] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_lockt,
+		.enc_size = nfsd4_enc_lockt_sz,
 	},
 	[OP_LOCKU] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_locku,
+		.enc_size = nfsd4_enc_locku_sz,
 	},
 	[OP_LOOKUP] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+		.enc_size = op_encode_hdr_size,
 	},
 	[OP_LOOKUPP] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+		.enc_size = op_encode_hdr_size,
 	},
 	[OP_NVERIFY] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+		.enc_size = op_encode_hdr_size,
 	},
 	[OP_OPEN] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_open,
+		.enc_size = nfsd4_enc_open_sz,
 	},
 	[OP_OPENATTR] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+		.enc_size = op_encode_hdr_size,
 	},
 	[OP_OPEN_CONFIRM] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_open_confirm,
+		.enc_size = nfsd4_enc_open_confirm_sz,
 	},
 	[OP_OPEN_DOWNGRADE] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_open_downgrade,
+		.enc_size = nfsd4_enc_open_downgrade_sz,
 	},
 	[OP_PUTFH] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+		.enc_size = op_encode_hdr_size,
 	},
 	[OP_PUTPUBFH] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+		.enc_size = op_encode_hdr_size,
 	},
 	[OP_PUTROOTFH] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+		.enc_size = op_encode_hdr_size,
 	},
 	[OP_READ] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_read,
+		.enc_size = nfsd4_enc_read_sz,
 	},
 	[OP_READDIR] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_readdir,
+		.enc_size = nfsd4_enc_readdir_sz,
 	},
 	[OP_READLINK] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_readlink,
+		.enc_size = nfsd4_enc_readlink_sz,
 	},
         [OP_REMOVE] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_remove,
+		.enc_size = nfsd4_enc_remove_sz,
 	},
         [OP_RENAME] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_rename,
+		.enc_size = nfsd4_enc_rename_sz,
 	},
         [OP_RENEW] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+		.enc_size = op_encode_hdr_size,
 	},
         [OP_RESTOREFH] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+		.enc_size = op_encode_hdr_size,
 	},
         [OP_SAVEFH] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+		.enc_size = op_encode_hdr_size,
 	},
         [OP_SECINFO] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_secinfo,
+		.enc_size = nfsd4_enc_secinfo_sz,
 	},
         [OP_SETATTR] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_setattr,
+		.enc_size = nfsd4_enc_setattr_sz,
 	},
         [OP_SETCLIENTID] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_setclientid,
+		.enc_size = nfsd4_enc_setclientid_sz,
 	},
         [OP_SETCLIENTID_CONFIRM] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+		.enc_size = op_encode_hdr_size,
 	},
         [OP_VERIFY] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+		.enc_size = op_encode_hdr_size,
 	},
         [OP_WRITE] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_write,
+		.enc_size = nfsd4_enc_write_sz,
 	},
         [OP_RELEASE_LOCKOWNER] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+		.enc_size = op_encode_hdr_size,
 	},
 
         /* NFSv4.1 operations */
         [OP_BACKCHANNEL_CTL] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+		.enc_size = op_encode_hdr_size,
 	},
         [OP_BIND_CONN_TO_SESSION] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_bind_conn_to_session,
+		.enc_size = nfsd4_enc_bind_conn_to_session_sz,
 	},
         [OP_EXCHANGE_ID] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_exchange_id,
+		.enc_size = nfsd4_enc_exchange_id_sz,
 	},
         [OP_CREATE_SESSION] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_create_session,
+		.enc_size = nfsd4_enc_create_session_sz,
 	},
         [OP_DESTROY_SESSION] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_destroy_session,
+		.enc_size = nfsd4_enc_destroy_session_sz,
 	},
         [OP_FREE_STATEID] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+		.enc_size = op_encode_hdr_size,
 	},
         [OP_GET_DIR_DELEGATION] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+		.enc_size = op_encode_hdr_size,
 	},
         [OP_GETDEVICEINFO] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+		.enc_size = op_encode_hdr_size,
 	},
         [OP_GETDEVICELIST] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+		.enc_size = op_encode_hdr_size,
 	},
         [OP_LAYOUTCOMMIT] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+		.enc_size = op_encode_hdr_size,
 	},
         [OP_LAYOUTGET] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+		.enc_size = op_encode_hdr_size,
 	},
         [OP_LAYOUTRETURN] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+		.enc_size = op_encode_hdr_size,
 	},
         [OP_SECINFO_NO_NAME] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_secinfo_no_name,
+		.enc_size = nfsd4_enc_secinfo_no_name_sz,
 	},
         [OP_SEQUENCE] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_sequence,
+		.enc_size = nfsd4_enc_sequence_sz,
 	},
         [OP_SET_SSV] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+		.enc_size = op_encode_hdr_size,
 	},
         [OP_TEST_STATEID] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+		.enc_size = op_encode_hdr_size,
 	},
         [OP_WANT_DELEGATION] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+		.enc_size = op_encode_hdr_size,
 	},
         [OP_DESTROY_CLIENTID] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+		.enc_size = op_encode_hdr_size,
 	},
         [OP_RECLAIM_COMPLETE] = {
 		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+		.enc_size = op_encode_hdr_size,
 	},
 };
 
+static u32 get_ops_max_rsz(struct nfsd4_compoundres *resp)
+{
+	struct nfsd4_compoundargs *args = resp->rqstp->rq_argp;
+	struct nfsd4_op op = args->ops[resp->opcnt];
+	int length = 0, maxcount = 0;
+
+	switch (op.opnum) {
+	case OP_READ:
+		maxcount = svc_max_payload(resp->rqstp);
+		if (maxcount > op.u.read.rd_length)
+			length = op.u.read.rd_length;
+		else
+			length = maxcount;
+		break;
+
+	case OP_READDIR:
+		if (op.u.readdir.rd_maxcount < PAGE_SIZE)
+			length = op.u.readdir.rd_maxcount;
+		else
+			length = PAGE_SIZE;
+		break;
+	case OP_READLINK:
+		length = PATH_MAX;
+		break;
+	}
+
+	length += nfsd4_enc_ops[op.opnum].enc_size * 4;
+	dprintk("%s opnum %u max reply %u\n", __func__, op.opnum, length);
+
+	return length;
+}
+
 /*
  * Calculate the total amount of memory that the compound response has taken
  * after encoding the current operation.
  *
- * pad: add on 8 bytes for the next operation's op_code and status so that
- * there is room to cache a failure on the next operation.
- *
- * Compare this length to the session se_fmaxresp_cached.
+ * Compare this length to the session se_fmaxresp_sz and se_fmaxresp_cached.
  *
  * Our se_fmaxresp_cached will always be a multiple of PAGE_SIZE, and so
  * will be at least a page and will therefore hold the xdr_buf head.
  */
-static int nfsd4_check_drc_limit(struct nfsd4_compoundres *resp)
+static int nfsd4_check_resp_limit(struct nfsd4_compoundres *resp)
 {
 	int status = 0;
 	struct xdr_buf *xb = &resp->rqstp->rq_res;
 	struct nfsd4_compoundargs *args = resp->rqstp->rq_argp;
 	struct nfsd4_session *session = NULL;
 	struct nfsd4_slot *slot = resp->cstate.slot;
-	u32 length, tlen = 0, pad = 8;
+	u32 length = 0, tlen = 0, nlen = 0;
 
 	if (!nfsd4_has_session(&resp->cstate))
 		return status;
 
 	session = resp->cstate.session;
-	if (session == NULL || slot->sl_cachethis == 0)
+	if (session == NULL)
 		return status;
 
-	if (resp->opcnt >= args->opcnt)
-		pad = 0; /* this is the last operation */
+	if (resp->opcnt < args->opcnt)
+		nlen = get_ops_max_rsz(resp);
+	else
+		return status;
 
 	if (xb->page_len == 0) {
-		length = (char *)resp->p - (char *)xb->head[0].iov_base + pad;
+		length = (char *)resp->p - (char *)xb->head[0].iov_base + nlen;
 	} else {
 		if (xb->tail[0].iov_base && xb->tail[0].iov_len > 0)
 			tlen = (char *)resp->p - (char *)xb->tail[0].iov_base;
 
-		length = xb->head[0].iov_len + xb->page_len + tlen + pad;
+		length = xb->head[0].iov_len + xb->page_len + tlen + nlen;
 	}
-	dprintk("%s length %u, xb->page_len %u tlen %u pad %u\n", __func__,
-		length, xb->page_len, tlen, pad);
+	dprintk("%s length %u, xb->page_len %u tlen %u nlen %u\n", __func__,
+		length, xb->page_len, tlen, nlen);
 
-	if (length <= session->se_fchannel.maxresp_cached)
-		return status;
-	else
-		return nfserr_rep_too_big_to_cache;
+	if (length > session->se_fchannel.maxresp_sz)
+		args->ops[resp->opcnt].status = nfserr_rep_too_big;
+
+	if (slot->sl_cachethis == 1 &&
+	    length > session->se_fchannel.maxresp_cached)
+		args->ops[resp->opcnt].status = nfserr_rep_too_big_to_cache;
+
+	return 0;
 }
 
 void
@@ -3396,7 +3570,7 @@ nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
 	       !nfsd4_enc_ops[op->opnum].enc_func);
 	op->status = nfsd4_enc_ops[op->opnum].enc_func(resp, op->status, &op->u);
 	/* nfsd4_check_drc_limit guarantees enough room for error status */
-	if (!op->status && nfsd4_check_drc_limit(resp))
+	if (!op->status && nfsd4_check_resp_limit(resp))
 		op->status = nfserr_rep_too_big_to_cache;
 status:
 	/*
-- 
1.7.5.4




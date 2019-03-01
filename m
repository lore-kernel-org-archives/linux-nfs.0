Return-Path: <SRS0=Psyw=RE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C14C4C4360F
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 19:27:00 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7F73A2084F
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 19:27:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="C4ANg3DH"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725996AbfCAT1A (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 1 Mar 2019 14:27:00 -0500
Received: from mail-yw1-f67.google.com ([209.85.161.67]:38927 "EHLO
        mail-yw1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725999AbfCAT07 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Mar 2019 14:26:59 -0500
Received: by mail-yw1-f67.google.com with SMTP id z191so14307986ywa.6
        for <linux-nfs@vger.kernel.org>; Fri, 01 Mar 2019 11:26:58 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=O7uQZ4SCyRgpCI3Is4zIruVaJrthWY99VJtaa2ePIh4=;
        b=C4ANg3DHkLTREQa+j3YX3rFfRDkfEQmxSaVhtXwX0CIwYOYd7uWjiT+zTbTvdOJUQK
         1Dieg9r6R1BbPB9omMP/jZmAnmTcQOO4+P+ml0x6y97BpMdUyafvdD+EMNffaJNaElWR
         E5vL03NGOnxYkLj6kHgV9AYjvsJSfKHcbxCKxi34Qu1RBwMMfwzaqubu/o1f6BqECtQE
         vI/XD7D9Ik600dhV1oXXCvNho+LQdJi2ZMMuLPrqfPNXun3HBL6rY6Sk2IeCG/NDUqnS
         UUXHqO1xB1Y7eRDsaGw2IyZHOal6CjPCNekCsCie2VQti5vkOi0aJIrXWTkklMWIDQON
         +Z8w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=O7uQZ4SCyRgpCI3Is4zIruVaJrthWY99VJtaa2ePIh4=;
        b=NcWjeuuMqHpbg4HzRrZIfzUN/t0g+tSiaX5Vi9oo4+RFpkiMcdHZtRcuQlDSSryrFb
         laJEOD1iuJ6iUkKmxkhv02funBRfC/rgDMqiQGCcmPMAjiU2UtmyUtR62My1LCbbrJUm
         wchoOf08n3meFqYjuLTl/kPd7rO7W8p2zHq5k2Ksm0ASM+yGTYim8LPARG2sLHZTAxdM
         ncFdqPyYLQhJ2/5tG4suDX8NPwNEZBOvz+9PcLmgSrft6q3+kvoWL4HUc8Gi7rduCV2N
         ozqFEcHBXKLNJf2N6j993IbkNjlbwW7tf41NBD5AwZ72i9f/rJSRLaK2eNqO7JdKuDPd
         q7Pg==
X-Gm-Message-State: APjAAAVvnX7RfrpH8fap6m7VLAIvhoU+QClAm25RPVmEAWYskbfxlwoo
        yjd586PYpbQcsigzffpIE7FqW8E=
X-Google-Smtp-Source: APXvYqwy5cNgawnlHxmxwhfKVbj8bjBBFVEQkqSBYp8Gfga7fCVapV2pt47P0JeopNz745BkgpPnUw==
X-Received: by 2002:a81:35d0:: with SMTP id c199mr4968651ywa.439.1551468417590;
        Fri, 01 Mar 2019 11:26:57 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id l71sm7509193ywl.65.2019.03.01.11.26.56
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 01 Mar 2019 11:26:57 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 05/19] NFSv4.2: Add client support for the generic 'layouterror' RPC call
Date:   Fri,  1 Mar 2019 14:24:41 -0500
Message-Id: <20190301192455.104943-6-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190301192455.104943-5-trond.myklebust@hammerspace.com>
References: <20190301192455.104943-1-trond.myklebust@hammerspace.com>
 <20190301192455.104943-2-trond.myklebust@hammerspace.com>
 <20190301192455.104943-3-trond.myklebust@hammerspace.com>
 <20190301192455.104943-4-trond.myklebust@hammerspace.com>
 <20190301192455.104943-5-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs42.h            |   3 +
 fs/nfs/nfs42proc.c        | 164 ++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs42xdr.c         |  99 +++++++++++++++++++++++
 fs/nfs/nfs4proc.c         |   3 +-
 fs/nfs/nfs4xdr.c          |   1 +
 include/linux/nfs4.h      |   1 +
 include/linux/nfs_fs_sb.h |   1 +
 include/linux/nfs_xdr.h   |  35 ++++++++
 8 files changed, 306 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs42.h b/fs/nfs/nfs42.h
index 19ec38f85ce0..901cca7542f9 100644
--- a/fs/nfs/nfs42.h
+++ b/fs/nfs/nfs42.h
@@ -20,5 +20,8 @@ loff_t nfs42_proc_llseek(struct file *, loff_t, int);
 int nfs42_proc_layoutstats_generic(struct nfs_server *,
 				   struct nfs42_layoutstat_data *);
 int nfs42_proc_clone(struct file *, struct file *, loff_t, loff_t, loff_t);
+int nfs42_proc_layouterror(struct pnfs_layout_segment *lseg,
+			   const struct nfs42_layout_error *errors,
+			   size_t n);
 
 #endif /* __LINUX_FS_NFS_NFS4_2_H */
diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index fed06fd9998d..ff6f85fb676b 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -672,6 +672,170 @@ int nfs42_proc_layoutstats_generic(struct nfs_server *server,
 	return 0;
 }
 
+static struct nfs42_layouterror_data *
+nfs42_alloc_layouterror_data(struct pnfs_layout_segment *lseg, gfp_t gfp_flags)
+{
+	struct nfs42_layouterror_data *data;
+	struct inode *inode = lseg->pls_layout->plh_inode;
+
+	data = kzalloc(sizeof(*data), gfp_flags);
+	if (data) {
+		data->args.inode = data->inode = nfs_igrab_and_active(inode);
+		if (data->inode) {
+			data->lseg = pnfs_get_lseg(lseg);
+			if (data->lseg)
+				return data;
+			nfs_iput_and_deactive(data->inode);
+		}
+		kfree(data);
+	}
+	return NULL;
+}
+
+static void
+nfs42_free_layouterror_data(struct nfs42_layouterror_data *data)
+{
+	pnfs_put_lseg(data->lseg);
+	nfs_iput_and_deactive(data->inode);
+	kfree(data);
+}
+
+static void
+nfs42_layouterror_prepare(struct rpc_task *task, void *calldata)
+{
+	struct nfs42_layouterror_data *data = calldata;
+	struct inode *inode = data->inode;
+	struct nfs_server *server = NFS_SERVER(inode);
+	struct pnfs_layout_hdr *lo = data->lseg->pls_layout;
+	unsigned i;
+
+	spin_lock(&inode->i_lock);
+	if (!pnfs_layout_is_valid(lo)) {
+		spin_unlock(&inode->i_lock);
+		rpc_exit(task, 0);
+		return;
+	}
+	for (i = 0; i < data->args.num_errors; i++)
+		nfs4_stateid_copy(&data->args.errors[i].stateid,
+				&lo->plh_stateid);
+	spin_unlock(&inode->i_lock);
+	nfs4_setup_sequence(server->nfs_client, &data->args.seq_args,
+			    &data->res.seq_res, task);
+}
+
+static void
+nfs42_layouterror_done(struct rpc_task *task, void *calldata)
+{
+	struct nfs42_layouterror_data *data = calldata;
+	struct inode *inode = data->inode;
+	struct pnfs_layout_hdr *lo = data->lseg->pls_layout;
+
+	if (!nfs4_sequence_done(task, &data->res.seq_res))
+		return;
+
+	switch (task->tk_status) {
+	case 0:
+		break;
+	case -NFS4ERR_BADHANDLE:
+	case -ESTALE:
+		pnfs_destroy_layout(NFS_I(inode));
+		break;
+	case -NFS4ERR_EXPIRED:
+	case -NFS4ERR_ADMIN_REVOKED:
+	case -NFS4ERR_DELEG_REVOKED:
+	case -NFS4ERR_STALE_STATEID:
+	case -NFS4ERR_BAD_STATEID:
+		spin_lock(&inode->i_lock);
+		if (pnfs_layout_is_valid(lo) &&
+		    nfs4_stateid_match(&data->args.errors[0].stateid,
+					     &lo->plh_stateid)) {
+			LIST_HEAD(head);
+
+			/*
+			 * Mark the bad layout state as invalid, then retry
+			 * with the current stateid.
+			 */
+			pnfs_mark_layout_stateid_invalid(lo, &head);
+			spin_unlock(&inode->i_lock);
+			pnfs_free_lseg_list(&head);
+			nfs_commit_inode(inode, 0);
+		} else
+			spin_unlock(&inode->i_lock);
+		break;
+	case -NFS4ERR_OLD_STATEID:
+		spin_lock(&inode->i_lock);
+		if (pnfs_layout_is_valid(lo) &&
+		    nfs4_stateid_match_other(&data->args.errors[0].stateid,
+					&lo->plh_stateid)) {
+			/* Do we need to delay before resending? */
+			if (!nfs4_stateid_is_newer(&lo->plh_stateid,
+						&data->args.errors[0].stateid))
+				rpc_delay(task, HZ);
+			rpc_restart_call_prepare(task);
+		}
+		spin_unlock(&inode->i_lock);
+		break;
+	case -ENOTSUPP:
+	case -EOPNOTSUPP:
+		NFS_SERVER(inode)->caps &= ~NFS_CAP_LAYOUTERROR;
+	}
+}
+
+static void
+nfs42_layouterror_release(void *calldata)
+{
+	struct nfs42_layouterror_data *data = calldata;
+
+	nfs42_free_layouterror_data(data);
+}
+
+static const struct rpc_call_ops nfs42_layouterror_ops = {
+	.rpc_call_prepare = nfs42_layouterror_prepare,
+	.rpc_call_done = nfs42_layouterror_done,
+	.rpc_release = nfs42_layouterror_release,
+};
+
+int nfs42_proc_layouterror(struct pnfs_layout_segment *lseg,
+		const struct nfs42_layout_error *errors, size_t n)
+{
+	struct inode *inode = lseg->pls_layout->plh_inode;
+	struct nfs42_layouterror_data *data;
+	struct rpc_task *task;
+	struct rpc_message msg = {
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_LAYOUTERROR],
+	};
+	struct rpc_task_setup task_setup = {
+		.rpc_message = &msg,
+		.callback_ops = &nfs42_layouterror_ops,
+		.flags = RPC_TASK_ASYNC,
+	};
+	unsigned int i;
+
+	if (!nfs_server_capable(inode, NFS_CAP_LAYOUTERROR))
+		return -EOPNOTSUPP;
+	if (n > NFS42_LAYOUTERROR_MAX)
+		return -EINVAL;
+	data = nfs42_alloc_layouterror_data(lseg, GFP_NOFS);
+	if (!data)
+		return -ENOMEM;
+	for (i = 0; i < n; i++) {
+		data->args.errors[i] = errors[i];
+		data->args.num_errors++;
+		data->res.num_errors++;
+	}
+	msg.rpc_argp = &data->args;
+	msg.rpc_resp = &data->res;
+	task_setup.callback_data = data;
+	task_setup.rpc_client = NFS_SERVER(inode)->client;
+	nfs4_init_sequence(&data->args.seq_args, &data->res.seq_res, 0, 0);
+	task = rpc_run_task(&task_setup);
+	if (IS_ERR(task))
+		return PTR_ERR(task);
+	rpc_put_task(task);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(nfs42_proc_layouterror);
+
 static int _nfs42_proc_clone(struct rpc_message *msg, struct file *src_f,
 		struct file *dst_f, struct nfs_lock_context *src_lock,
 		struct nfs_lock_context *dst_lock, loff_t src_offset,
diff --git a/fs/nfs/nfs42xdr.c b/fs/nfs/nfs42xdr.c
index 22b3425df08f..fa5e796697fb 100644
--- a/fs/nfs/nfs42xdr.c
+++ b/fs/nfs/nfs42xdr.c
@@ -51,6 +51,15 @@
 					1 /* opaque devaddr4 length */ + \
 					XDR_QUADLEN(PNFS_LAYOUTSTATS_MAXSIZE))
 #define decode_layoutstats_maxsz	(op_decode_hdr_maxsz)
+#define encode_device_error_maxsz	(XDR_QUADLEN(NFS4_DEVICEID4_SIZE) + \
+					1 /* status */ + 1 /* opnum */)
+#define encode_layouterror_maxsz	(op_decode_hdr_maxsz + \
+					2 /* offset */ + \
+					2 /* length */ + \
+					encode_stateid_maxsz + \
+					1 /* Array size */ + \
+					encode_device_error_maxsz)
+#define decode_layouterror_maxsz	(op_decode_hdr_maxsz)
 #define encode_clone_maxsz		(encode_stateid_maxsz + \
 					encode_stateid_maxsz + \
 					2 /* src offset */ + \
@@ -106,6 +115,16 @@
 					 decode_sequence_maxsz + \
 					 decode_putfh_maxsz + \
 					 PNFS_LAYOUTSTATS_MAXDEV * decode_layoutstats_maxsz)
+#define NFS4_enc_layouterror_sz		(compound_encode_hdr_maxsz + \
+					 encode_sequence_maxsz + \
+					 encode_putfh_maxsz + \
+					 NFS42_LAYOUTERROR_MAX * \
+					 encode_layouterror_maxsz)
+#define NFS4_dec_layouterror_sz		(compound_decode_hdr_maxsz + \
+					 decode_sequence_maxsz + \
+					 decode_putfh_maxsz + \
+					 NFS42_LAYOUTERROR_MAX * \
+					 decode_layouterror_maxsz)
 #define NFS4_enc_clone_sz		(compound_encode_hdr_maxsz + \
 					 encode_sequence_maxsz + \
 					 encode_putfh_maxsz + \
@@ -223,6 +242,34 @@ static void encode_clone(struct xdr_stream *xdr,
 	xdr_encode_hyper(p, args->count);
 }
 
+static void encode_device_error(struct xdr_stream *xdr,
+				const struct nfs42_device_error *error)
+{
+	__be32 *p;
+
+	p = reserve_space(xdr, NFS4_DEVICEID4_SIZE + 2*4);
+	p = xdr_encode_opaque_fixed(p, error->dev_id.data,
+			NFS4_DEVICEID4_SIZE);
+	*p++ = cpu_to_be32(error->status);
+	*p = cpu_to_be32(error->opnum);
+}
+
+static void encode_layouterror(struct xdr_stream *xdr,
+			       const struct nfs42_layout_error *args,
+			       struct compound_hdr *hdr)
+{
+	__be32 *p;
+
+	encode_op_hdr(xdr, OP_LAYOUTERROR, decode_layouterror_maxsz, hdr);
+	p = reserve_space(xdr, 8 + 8);
+	p = xdr_encode_hyper(p, args->offset);
+	p = xdr_encode_hyper(p, args->length);
+	encode_nfs4_stateid(xdr, &args->stateid);
+	p = reserve_space(xdr, 4);
+	*p = cpu_to_be32(1);
+	encode_device_error(xdr, &args->errors[0]);
+}
+
 /*
  * Encode ALLOCATE request
  */
@@ -381,6 +428,27 @@ static void nfs4_xdr_enc_clone(struct rpc_rqst *req,
 	encode_nops(&hdr);
 }
 
+/*
+ * Encode LAYOUTERROR request
+ */
+static void nfs4_xdr_enc_layouterror(struct rpc_rqst *req,
+				     struct xdr_stream *xdr,
+				     const void *data)
+{
+	const struct nfs42_layouterror_args *args = data;
+	struct compound_hdr hdr = {
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
+	};
+	int i;
+
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->seq_args, &hdr);
+	encode_putfh(xdr, NFS_FH(args->inode), &hdr);
+	for (i = 0; i < args->num_errors; i++)
+		encode_layouterror(xdr, &args->errors[i], &hdr);
+	encode_nops(&hdr);
+}
+
 static int decode_allocate(struct xdr_stream *xdr, struct nfs42_falloc_res *res)
 {
 	return decode_op_hdr(xdr, OP_ALLOCATE);
@@ -484,6 +552,11 @@ static int decode_clone(struct xdr_stream *xdr)
 	return decode_op_hdr(xdr, OP_CLONE);
 }
 
+static int decode_layouterror(struct xdr_stream *xdr)
+{
+	return decode_op_hdr(xdr, OP_LAYOUTERROR);
+}
+
 /*
  * Decode ALLOCATE request
  */
@@ -693,4 +766,30 @@ static int nfs4_xdr_dec_clone(struct rpc_rqst *rqstp,
 	return status;
 }
 
+/*
+ * Decode LAYOUTERROR request
+ */
+static int nfs4_xdr_dec_layouterror(struct rpc_rqst *rqstp,
+				    struct xdr_stream *xdr,
+				    void *data)
+{
+	struct nfs42_layouterror_res *res = data;
+	struct compound_hdr hdr;
+	int status, i;
+
+	status = decode_compound_hdr(xdr, &hdr);
+	if (status)
+		goto out;
+	status = decode_sequence(xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
+	status = decode_putfh(xdr);
+
+	for (i = 0; i < res->num_errors && status == 0; i++)
+		status = decode_layouterror(xdr);
+out:
+	res->rpc_status = status;
+	return status;
+}
+
 #endif /* __LINUX_FS_NFS_NFS4_2XDR_H */
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5b980246b035..73889ea7d196 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -9690,7 +9690,8 @@ static const struct nfs4_minor_version_ops nfs_v4_2_minor_ops = {
 		| NFS_CAP_DEALLOCATE
 		| NFS_CAP_SEEK
 		| NFS_CAP_LAYOUTSTATS
-		| NFS_CAP_CLONE,
+		| NFS_CAP_CLONE
+		| NFS_CAP_LAYOUTERROR,
 	.init_client = nfs41_init_client,
 	.shutdown_client = nfs41_shutdown_client,
 	.match_stateid = nfs41_match_stateid,
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 6d9d5e2f6308..cfcabc33e24d 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -7572,6 +7572,7 @@ const struct rpc_procinfo nfs4_procedures[] = {
 	PROC42(COPY,		enc_copy,		dec_copy),
 	PROC42(OFFLOAD_CANCEL,	enc_offload_cancel,	dec_offload_cancel),
 	PROC(LOOKUPP,		enc_lookupp,		dec_lookupp),
+	PROC42(LAYOUTERROR,	enc_layouterror,	dec_layouterror),
 };
 
 static unsigned int nfs_version4_counts[ARRAY_SIZE(nfs4_procedures)];
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 1b06f0b28453..22494d170619 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -538,6 +538,7 @@ enum {
 	NFSPROC4_CLNT_OFFLOAD_CANCEL,
 
 	NFSPROC4_CLNT_LOOKUPP,
+	NFSPROC4_CLNT_LAYOUTERROR,
 };
 
 /* nfs41 types */
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 6aa8cc83c3b6..c827d31298cc 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -261,5 +261,6 @@ struct nfs_server {
 #define NFS_CAP_CLONE		(1U << 23)
 #define NFS_CAP_COPY		(1U << 24)
 #define NFS_CAP_OFFLOAD_CANCEL	(1U << 25)
+#define NFS_CAP_LAYOUTERROR	(1U << 26)
 
 #endif
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index b4bd2bf5f585..9b8324ec08f3 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -383,6 +383,41 @@ struct nfs42_layoutstat_data {
 	struct nfs42_layoutstat_res res;
 };
 
+struct nfs42_device_error {
+	struct nfs4_deviceid dev_id;
+	int status;
+	enum nfs_opnum4 opnum;
+};
+
+struct nfs42_layout_error {
+	__u64 offset;
+	__u64 length;
+	nfs4_stateid stateid;
+	struct nfs42_device_error errors[1];
+};
+
+#define NFS42_LAYOUTERROR_MAX 5
+
+struct nfs42_layouterror_args {
+	struct nfs4_sequence_args seq_args;
+	struct inode *inode;
+	unsigned int num_errors;
+	struct nfs42_layout_error errors[NFS42_LAYOUTERROR_MAX];
+};
+
+struct nfs42_layouterror_res {
+	struct nfs4_sequence_res seq_res;
+	unsigned int num_errors;
+	int rpc_status;
+};
+
+struct nfs42_layouterror_data {
+	struct nfs42_layouterror_args args;
+	struct nfs42_layouterror_res res;
+	struct inode *inode;
+	struct pnfs_layout_segment *lseg;
+};
+
 struct nfs42_clone_args {
 	struct nfs4_sequence_args	seq_args;
 	struct nfs_fh			*src_fh;
-- 
2.20.1


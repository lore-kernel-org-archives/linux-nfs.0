Return-Path: <SRS0=ibFv=Q5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,UNWANTED_LANGUAGE_BODY,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 00CA7C10F00
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 21:59:27 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AABEF20675
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 21:59:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="oumKCo5y"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726239AbfBVV70 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 22 Feb 2019 16:59:26 -0500
Received: from mail-io1-f66.google.com ([209.85.166.66]:33903 "EHLO
        mail-io1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726080AbfBVV7Z (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Feb 2019 16:59:25 -0500
Received: by mail-io1-f66.google.com with SMTP id e1so3028244iok.1
        for <linux-nfs@vger.kernel.org>; Fri, 22 Feb 2019 13:59:24 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=Ia7aST5lPiAEQVsVWLwzrWewgh95bZPNwt/gEeGIXvc=;
        b=oumKCo5y6WnousE+ihR6Ap8QTWIhh5II8ZoQJ+It007PAp5ohra4LUo1rn2T/omlO8
         TlOBwcmHOdipbhu8u9W2CVdxqd36JCs52e9PAI9IMVn5BV1W7xamU+rIhczPGFLBh8QQ
         kUnZixD/i9Dz6xqbIuOvQ0gv4FRE1Hd5ZlPdzmCt0Hz0KuiwWj+M/KB8iS3/sWwLKA3X
         N7sYHbnPVDlAQ179/CwIOyF8mU6iECfJKlZXQBNhTQhaqH6X4HDY2ktltVOKZ0NTU7SG
         WCI0ixUpnWiOL2N4gVoImJJjKWOIrZ/i3V+ai80QrkuttWGrVOH5nqSSoZKSWB1Y22JL
         pyYg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:from:to:cc:subject:date:message-id
         :in-reply-to:references:mime-version:content-transfer-encoding;
        bh=Ia7aST5lPiAEQVsVWLwzrWewgh95bZPNwt/gEeGIXvc=;
        b=IzcnGz9U1mB7L2IM5InRCYZjRfjp4BgdHX/gx3+e+nOKpS1FCoAQCLDi1akjYHQvPM
         vfQDJmqS1d3m6ItsjIzsePRBZeI+A3bxtyCbPd1xzziPEfMuYD0xZXMiDCznLg3ReYAf
         TQN/XVdnseAKvhP7+k064hX6AufBiPBtNDfhPEqIx3PQiJgQFCqmollU/rnFw9Vw8Zpn
         qcx4O2JTXLCC7oLwaoDDJ9uBPBuS/KIPvu4/+1KVJzMjKXLiKhXdL7yZ+5HXuUlLdBlA
         WenuYGk1FKaC4o4dGckYnueKWST6EVDnLaeAP0VLEunV+zvxK9JJagSihLGGM8oSGNe3
         jvZQ==
X-Gm-Message-State: AHQUAuaEaqBZDCLygf7DFPZ1uXibQC5W4NK3cawOj3VgOlCef66FnKZa
        uFsvV6cwpb/p1/RWWg+kP2PyifxzhNk=
X-Google-Smtp-Source: AHgI3Iaa+366gmgGFl2MmtGEVSVfVC2oBpzBU9kiB7nQSSN00UxFQh2yHSdY5ePmqh17Uka2lyVFDg==
X-Received: by 2002:a6b:e219:: with SMTP id z25mr3426271ioc.116.1550872764201;
        Fri, 22 Feb 2019 13:59:24 -0800 (PST)
Received: from gouda.nowheycreamery.com.nowheycreamery.com (d28-23-121-75.dim.wideopenwest.com. [23.28.75.121])
        by smtp.gmail.com with ESMTPSA id f13sm998171iol.82.2019.02.22.13.59.23
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 13:59:23 -0800 (PST)
From:   schumaker.anna@gmail.com
X-Google-Original-From: Anna.Schumaker@Netapp.com
To:     Trond.Myklebust@hammerspace.com, linux-nfs@vger.kernel.org
Cc:     Anna.Schumaker@Netapp.com
Subject: [PATCH 4/6] NFS: Add basic READ_PLUS support
Date:   Fri, 22 Feb 2019 16:59:16 -0500
Message-Id: <20190222215918.20647-5-Anna.Schumaker@Netapp.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190222215918.20647-1-Anna.Schumaker@Netapp.com>
References: <20190222215918.20647-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

This patch adds support for decoding a single NFS4_CONTENT_DATA or
NFS4_CONTENT_HOLE segment returned by the server.  This gives a simple
implementation that does not need to spent a lot of time shifting data
arount.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs42xdr.c         | 160 ++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4proc.c         |  32 +++++++-
 fs/nfs/nfs4xdr.c          |   1 +
 include/linux/nfs4.h      |   1 +
 include/linux/nfs_fs_sb.h |   1 +
 include/linux/nfs_xdr.h   |   2 +-
 6 files changed, 193 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs42xdr.c b/fs/nfs/nfs42xdr.c
index 69f72ed2bf87..57ec9c0fc00a 100644
--- a/fs/nfs/nfs42xdr.c
+++ b/fs/nfs/nfs42xdr.c
@@ -32,6 +32,14 @@
 #define encode_deallocate_maxsz		(op_encode_hdr_maxsz + \
 					 encode_fallocate_maxsz)
 #define decode_deallocate_maxsz		(op_decode_hdr_maxsz)
+#define encode_read_plus_maxsz		(op_encode_hdr_maxsz + \
+					 encode_stateid_maxsz + 3)
+#define decode_read_plus_maxsz		(op_decode_hdr_maxsz + \
+					 1 /* rpr_eof */ + \
+					 1 /* rpr_contents count */ + \
+					 1 /* data_content4 */ + \
+					 2 /* data_info4.di_offset */ + \
+					 2 /* data_info4.di_length */)
 #define encode_seek_maxsz		(op_encode_hdr_maxsz + \
 					 encode_stateid_maxsz + \
 					 2 /* offset */ + \
@@ -92,6 +100,12 @@
 					 decode_putfh_maxsz + \
 					 decode_deallocate_maxsz + \
 					 decode_getattr_maxsz)
+#define NFS4_enc_read_plus_sz		(compound_encode_hdr_maxsz + \
+					 encode_putfh_maxsz + \
+					 encode_read_plus_maxsz)
+#define NFS4_dec_read_plus_sz		(compound_decode_hdr_maxsz + \
+					 decode_putfh_maxsz + \
+					 decode_read_plus_maxsz)
 #define NFS4_enc_seek_sz		(compound_encode_hdr_maxsz + \
 					 encode_putfh_maxsz + \
 					 encode_seek_maxsz)
@@ -170,6 +184,16 @@ static void encode_deallocate(struct xdr_stream *xdr,
 	encode_fallocate(xdr, args);
 }
 
+static void encode_read_plus(struct xdr_stream *xdr,
+			     const struct nfs_pgio_args *args,
+			     struct compound_hdr *hdr)
+{
+	encode_op_hdr(xdr, OP_READ_PLUS, decode_read_plus_maxsz, hdr);
+	encode_nfs4_stateid(xdr, &args->stateid);
+	encode_uint64(xdr, args->offset);
+	encode_uint32(xdr, args->count);
+}
+
 static void encode_seek(struct xdr_stream *xdr,
 			const struct nfs42_seek_args *args,
 			struct compound_hdr *hdr)
@@ -317,6 +341,29 @@ static void nfs4_xdr_enc_deallocate(struct rpc_rqst *req,
 	encode_nops(&hdr);
 }
 
+/*
+ * Encode READ_PLUS request
+ */
+static void nfs4_xdr_enc_read_plus(struct rpc_rqst *req,
+				   struct xdr_stream *xdr,
+				   const void *data)
+{
+	const struct nfs_pgio_args *args = data;
+	struct compound_hdr hdr = {
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
+	};
+
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->seq_args, &hdr);
+	encode_putfh(xdr, args->fh, &hdr);
+	encode_read_plus(xdr, args, &hdr);
+
+	xdr_inline_pages(&req->rq_rcv_buf, hdr.replen << 2,
+			 args->pages, args->pgbase, args->count);
+	req->rq_rcv_buf.flags |= XDRBUF_READ;
+	encode_nops(&hdr);
+}
+
 /*
  * Encode SEEK request
  */
@@ -463,6 +510,92 @@ static int decode_deallocate(struct xdr_stream *xdr, struct nfs42_falloc_res *re
 	return decode_op_hdr(xdr, OP_DEALLOCATE);
 }
 
+static int decode_read_plus_data(struct xdr_stream *xdr, struct nfs_pgio_res *res)
+{
+	__be32 *p;
+	uint32_t count, recvd;
+	uint64_t offset;
+
+	p = xdr_inline_decode(xdr, 8 + 4);
+	if (unlikely(!p))
+		goto out_overflow;
+
+	p = xdr_decode_hyper(p, &offset);
+	count = be32_to_cpup(p);
+
+	recvd = xdr_read_pages(xdr, count);
+	if (recvd < count)
+		res->eof = 0;
+
+	res->count = recvd;
+	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
+static int decode_read_plus_hole(struct xdr_stream *xdr, struct nfs_pgio_res *res)
+{
+	__be32 *p;
+	uint64_t offset, length;
+	size_t recvd;
+
+	p = xdr_inline_decode(xdr, 8 + 8);
+	if (unlikely(!p))
+		goto out_overflow;
+
+	p = xdr_decode_hyper(p, &offset);
+	p = xdr_decode_hyper(p, &length);
+
+	recvd = xdr_expand_hole(xdr, 0, length);
+	if (recvd < length)
+		res->eof = 0;
+
+	res->count = recvd;
+	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
+static int decode_read_plus(struct xdr_stream *xdr, struct nfs_pgio_res *res)
+{
+	__be32 *p;
+	int status, type;
+	uint32_t segments;
+
+	status = decode_op_hdr(xdr, OP_READ_PLUS);
+	if (status)
+		return status;
+
+	p = xdr_inline_decode(xdr, 4 + 4);
+	if (unlikely(!p))
+		goto out_overflow;
+
+	res->count = 0;
+	res->eof = be32_to_cpup(p++);
+	segments = be32_to_cpup(p++);
+	if (segments == 0)
+		return 0;
+
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(!p))
+		goto out_overflow;
+
+	type = be32_to_cpup(p++);
+	if (type == NFS4_CONTENT_DATA)
+		status = decode_read_plus_data(xdr, res);
+	else
+		status = decode_read_plus_hole(xdr, res);
+
+	if (segments > 1)
+		res->eof = 0;
+	return status;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
 static int decode_seek(struct xdr_stream *xdr, struct nfs42_seek_res *res)
 {
 	int status;
@@ -612,6 +745,33 @@ static int nfs4_xdr_dec_deallocate(struct rpc_rqst *rqstp,
 	return status;
 }
 
+/*
+ * Decode READ_PLUS request
+ */
+static int nfs4_xdr_dec_read_plus(struct rpc_rqst *rqstp,
+				  struct xdr_stream *xdr,
+				  void *data)
+{
+	struct nfs_pgio_res *res = data;
+	struct compound_hdr hdr;
+	int status;
+
+	status = decode_compound_hdr(xdr, &hdr);
+	if (status)
+		goto out;
+	status = decode_sequence(xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
+	status = decode_putfh(xdr);
+	if (status)
+		goto out;
+	status = decode_read_plus(xdr, res);
+	if (!status)
+		status = res->count;
+out:
+	return status;
+}
+
 /*
  * Decode SEEK request
  */
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 557a5d636183..0aabddc900e0 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -69,6 +69,10 @@
 
 #include "nfs4trace.h"
 
+#ifdef CONFIG_NFS_V4_2
+#include "nfs42.h"
+#endif /* CONFIG_NFS_V4_2 */
+
 #define NFSDBG_FACILITY		NFSDBG_PROC
 
 #define NFS4_BITMASK_SZ		3
@@ -5007,9 +5011,15 @@ static bool nfs4_read_stateid_changed(struct rpc_task *task,
 
 static int nfs4_read_done(struct rpc_task *task, struct nfs_pgio_header *hdr)
 {
-
+	struct nfs_server *server = NFS_SERVER(hdr->inode);
 	dprintk("--> %s\n", __func__);
 
+	if ((server->caps & NFS_CAP_READ_PLUS) && (task->tk_status == -ENOTSUPP)) {
+		server->caps &= ~NFS_CAP_READ_PLUS;
+		if (rpc_restart_call_prepare(task))
+			task->tk_status = 0;
+		return -EAGAIN;
+	}
 	if (!nfs4_sequence_done(task, &hdr->res.seq_res))
 		return -EAGAIN;
 	if (nfs4_read_stateid_changed(task, &hdr->args))
@@ -5020,13 +5030,28 @@ static int nfs4_read_done(struct rpc_task *task, struct nfs_pgio_header *hdr)
 				    nfs4_read_done_cb(task, hdr);
 }
 
+#ifdef CONFIG_NFS_V4_2
+static void nfs42_read_plus_support(struct nfs_server *server, struct rpc_message *msg)
+{
+	if (server->caps & NFS_CAP_READ_PLUS)
+		msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_READ_PLUS];
+	else
+		msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_READ];
+}
+#else
+static void nfs42_read_plus_support(struct nfs_server *server, struct rpc_message *msg)
+{
+	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_READ];
+}
+#endif /* CONFIG_NFS_V4_2 */
+
 static void nfs4_proc_read_setup(struct nfs_pgio_header *hdr,
 				 struct rpc_message *msg)
 {
 	hdr->timestamp   = jiffies;
 	if (!hdr->pgio_done_cb)
 		hdr->pgio_done_cb = nfs4_read_done_cb;
-	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_READ];
+	nfs42_read_plus_support(NFS_SERVER(hdr->inode), msg);
 	nfs4_init_sequence(&hdr->args.seq_args, &hdr->res.seq_res, 0, 0);
 }
 
@@ -9691,7 +9716,8 @@ static const struct nfs4_minor_version_ops nfs_v4_2_minor_ops = {
 		| NFS_CAP_DEALLOCATE
 		| NFS_CAP_SEEK
 		| NFS_CAP_LAYOUTSTATS
-		| NFS_CAP_CLONE,
+		| NFS_CAP_CLONE
+		| NFS_CAP_READ_PLUS,
 	.init_client = nfs41_init_client,
 	.shutdown_client = nfs41_shutdown_client,
 	.match_stateid = nfs41_match_stateid,
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 2fc8f6fa25e4..b18a0143a4af 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -7790,6 +7790,7 @@ const struct rpc_procinfo nfs4_procedures[] = {
 	PROC42(CLONE,		enc_clone,		dec_clone),
 	PROC42(COPY,		enc_copy,		dec_copy),
 	PROC42(OFFLOAD_CANCEL,	enc_offload_cancel,	dec_offload_cancel),
+	PROC42(READ_PLUS,	enc_read_plus,		dec_read_plus),
 	PROC(LOOKUPP,		enc_lookupp,		dec_lookupp),
 };
 
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 1b06f0b28453..db465ad6659b 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -536,6 +536,7 @@ enum {
 	NFSPROC4_CLNT_CLONE,
 	NFSPROC4_CLNT_COPY,
 	NFSPROC4_CLNT_OFFLOAD_CANCEL,
+	NFSPROC4_CLNT_READ_PLUS,
 
 	NFSPROC4_CLNT_LOOKUPP,
 };
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 6aa8cc83c3b6..e431c2a7affd 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -261,5 +261,6 @@ struct nfs_server {
 #define NFS_CAP_CLONE		(1U << 23)
 #define NFS_CAP_COPY		(1U << 24)
 #define NFS_CAP_OFFLOAD_CANCEL	(1U << 25)
+#define NFS_CAP_READ_PLUS	(1U << 26)
 
 #endif
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 441a93ebcac0..4fb9b9d11685 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -620,7 +620,7 @@ struct nfs_pgio_args {
 struct nfs_pgio_res {
 	struct nfs4_sequence_res	seq_res;
 	struct nfs_fattr *	fattr;
-	__u32			count;
+	__u64			count;
 	__u32			op_status;
 	union {
 		struct {
-- 
2.20.1


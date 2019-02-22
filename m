Return-Path: <SRS0=ibFv=Q5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49E25C43381
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 21:58:58 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1006D20675
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 21:58:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="RDI47Ep+"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725859AbfBVV65 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 22 Feb 2019 16:58:57 -0500
Received: from mail-it1-f194.google.com ([209.85.166.194]:38155 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725832AbfBVV64 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Feb 2019 16:58:56 -0500
Received: by mail-it1-f194.google.com with SMTP id l66so5462495itg.3
        for <linux-nfs@vger.kernel.org>; Fri, 22 Feb 2019 13:58:55 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=c19mU9xxCZ+W0WDN14jOva6jpIOjR0D5ezB4RZcR8j8=;
        b=RDI47Ep+w6hR4WmMd1Ze50t1eRQYkg0dkeMgTFoc87uTZX/CB63lyB7bTowx4ZyXPf
         bRlcdpIoSPgCAE+eeXXB/4ZEO3QZCwUh1cIZm+xfi6WIJTDUA5rcUzs2gxpGzMbp83cC
         zxlebymoc24l1twVz/Y8nSKInO9ui8UBfvjPj10DPEbv+H6N1YHWoYpvajO3y8cGyWRs
         NVlVC5MygGD9OCPM4iCyZUItcCyw4qidxRtrfSAhWWVBCOwCNDg4Ci7kqNP8/TJz5H4S
         3qcgF0aZSA1AqNmyNpPDvvihDqHeMd9c/1QrOYI4qyJLB1oCGlj5l8FGVaJST/hV/sN/
         WP7w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:from:to:cc:subject:date:message-id
         :in-reply-to:references:mime-version:content-transfer-encoding;
        bh=c19mU9xxCZ+W0WDN14jOva6jpIOjR0D5ezB4RZcR8j8=;
        b=kvN/rs3ssUz4WimObKO+gpf7HytarhxzFSImc8ss+4rVYxAp6UeSgZ3tpzFSBDLdAU
         3FoNritvD8kq0bB4AXb+/m0vV91R5O8C2uJI3708i0ay9Q7ue8krJqOGnFxqAjYQh9GB
         REkJYvS8iWjPnSsD1AJvLsDPrrNCawgb9AG+n+aYLCzwx/oH4/2dtVgHe0kesqfUmOIu
         Br+yZ0BECjd2YVNE7bxfAu/tNzbiVo9H+SrdT+mSA5btwN74bT+UuSnm0PA+y1xiuDNP
         JSOOGKwHqp2Dhvbdh8fbuPNTD53LCq6Ow1a+Pj9G2BPSKIL1qDtk1KNle+oFgvo9/Wyq
         NThA==
X-Gm-Message-State: AHQUAubHsqVZN+9D3LFcc64B25f6M3BdFvsnuGrplLuE9TK6XQnuwfr6
        +pSAXKTQJ9T1EcHM6vwY0oUGddLwBjY=
X-Google-Smtp-Source: AHgI3Ibli1+cEvKV+It19hnADLLesdtl9GAmTasrP5RIm1TCwNS3UEItmLkGsDYKtkPbGk1KpQU2/Q==
X-Received: by 2002:a24:f443:: with SMTP id u3mr3409702iti.165.1550872735177;
        Fri, 22 Feb 2019 13:58:55 -0800 (PST)
Received: from gouda.nowheycreamery.com.nowheycreamery.com (d28-23-121-75.dim.wideopenwest.com. [23.28.75.121])
        by smtp.gmail.com with ESMTPSA id t74sm1532459itt.29.2019.02.22.13.58.54
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 13:58:54 -0800 (PST)
From:   Anna Schumaker <schumaker.anna@gmail.com>
X-Google-Original-From: Anna Schumaker <Anna.Schumaker@Netapp.com>
To:     bfields@fieldses.org
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] NFSD: Add basic READ_PLUS support
Date:   Fri, 22 Feb 2019 16:58:50 -0500
Message-Id: <20190222215850.20508-3-Anna.Schumaker@Netapp.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190222215850.20508-1-Anna.Schumaker@Netapp.com>
References: <20190222215850.20508-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This patch adds READ_PLUS support for both NFS4_CONTENT_DATA and
NFS4_CONTENT_HOLE segments.  I keep things simple for now by only
returning a hole segment if it is the first segment found at the given
offset.  Everything else, including other hole segments, will be encoded
as data.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfsd/nfs4proc.c |  16 +++++++
 fs/nfsd/nfs4xdr.c  | 113 ++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 127 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 0cfd257ffdaf..1c5f2c3da55f 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -2180,6 +2180,16 @@ static inline u32 nfsd4_read_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
 	return (op_encode_hdr_size + 2 + XDR_QUADLEN(rlen)) * sizeof(__be32);
 }
 
+static inline u32 nfsd4_read_plus_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
+{
+	u32 maxcount = svc_max_payload(rqstp);
+	u32 rlen = min(op->u.read.rd_length, maxcount);
+	/* enough extra xdr space for encoding either a hole or data segment. */
+	u32 xdr  = 5;
+
+	return (op_encode_hdr_size + 2 + xdr + XDR_QUADLEN(rlen)) * sizeof(__be32);
+}
+
 static inline u32 nfsd4_readdir_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
 {
 	u32 maxcount = 0, rlen = 0;
@@ -2701,6 +2711,12 @@ static const struct nfsd4_operation nfsd4_ops[] = {
 		.op_name = "OP_COPY",
 		.op_rsize_bop = nfsd4_copy_rsize,
 	},
+	[OP_READ_PLUS] = {
+		.op_func = nfsd4_read,
+		.op_name = "OP_READ_PLUS",
+		.op_rsize_bop = nfsd4_read_plus_rsize,
+		.op_get_currentstateid = nfsd4_get_readstateid,
+	},
 	[OP_SEEK] = {
 		.op_func = nfsd4_seek,
 		.op_name = "OP_SEEK",
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index bb487e5c022c..ec953efd24c2 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1882,7 +1882,7 @@ static const nfsd4_dec nfsd4_dec_ops[] = {
 	[OP_LAYOUTSTATS]	= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_OFFLOAD_CANCEL]	= (nfsd4_dec)nfsd4_decode_offload_status,
 	[OP_OFFLOAD_STATUS]	= (nfsd4_dec)nfsd4_decode_offload_status,
-	[OP_READ_PLUS]		= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_READ_PLUS]		= (nfsd4_dec)nfsd4_decode_read,
 	[OP_SEEK]		= (nfsd4_dec)nfsd4_decode_seek,
 	[OP_WRITE_SAME]		= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_CLONE]		= (nfsd4_dec)nfsd4_decode_clone,
@@ -4273,7 +4273,116 @@ nfsd4_encode_offload_status(struct nfsd4_compoundres *resp, __be32 nfserr,
 		return nfserr_resource;
 	p = xdr_encode_hyper(p, os->count);
 	*p++ = cpu_to_be32(0);
+	return nfserr;
+}
+
+static __be32
+nfsd4_encode_read_plus_data(struct nfsd4_compoundres *resp, struct nfsd4_read *read,
+			    struct file *file)
+{
+	struct xdr_stream *xdr = &resp->xdr;
+	unsigned long maxcount;
+	__be32 *p, nfserr;
+
+	p = xdr_reserve_space(xdr, 4 + 8 + 4);
+	if (!p)
+		return nfserr_resource;
+	xdr_commit_encode(xdr);
+
+	maxcount = svc_max_payload(resp->rqstp);
+	maxcount = min_t(unsigned long, maxcount,
+			 (xdr->buf->buflen - xdr->buf->len));
+	maxcount = min_t(unsigned long, maxcount, read->rd_length);
+
+	if (file->f_op->splice_read &&
+	    test_bit(RQ_SPLICE_OK, &resp->rqstp->rq_flags))
+		nfserr = nfsd4_encode_splice_read(resp, read, file, &maxcount);
+	else
+		nfserr = nfsd4_encode_readv(resp, read, file, &maxcount);
+
+	*p++ = cpu_to_be32(NFS4_CONTENT_DATA);
+	 p   = xdr_encode_hyper(p, read->rd_offset);
+	*p++ = cpu_to_be32(maxcount);
+
+	read->rd_offset += maxcount;
+	return nfserr;
+}
+
+static __be32
+nfsd4_encode_read_plus_hole(struct nfsd4_compoundres *resp, struct nfsd4_read *read,
+			    unsigned long length)
+{
+	__be32 *p = xdr_reserve_space(&resp->xdr, 4 + 8 + 8);
+	if (!p)
+		return nfserr_resource;
+
+	length = min_t(unsigned long, read->rd_length, length);
+
+	*p++ = cpu_to_be32(NFS4_CONTENT_HOLE);
+	p = xdr_encode_hyper(p, read->rd_offset);
+	p = xdr_encode_hyper(p, length);
+
+	read->rd_offset += length;
+	read->rd_length -= length;
+	return nfs_ok;
+}
 
+static __be32
+nfsd4_encode_read_plus(struct nfsd4_compoundres *resp, __be32 nfserr,
+		       struct nfsd4_read *read)
+{
+	struct xdr_stream *xdr = &resp->xdr;
+	struct file *file = read->rd_filp;
+	int starting_len = xdr->buf->len;
+	struct raparms *ra = NULL;
+	loff_t data_pos;
+	__be32 *p;
+	u32 eof, segments = 0;
+
+	if (nfserr)
+		goto out;
+
+	/* eof flag, segment count */
+	p = xdr_reserve_space(xdr, 4 + 4 );
+	if (!p) {
+		nfserr = nfserr_resource;
+		goto out;
+	}
+	xdr_commit_encode(xdr);
+
+	if (read->rd_tmp_file)
+		ra = nfsd_init_raparms(file);
+
+	data_pos = vfs_llseek(file, read->rd_offset, SEEK_DATA);
+	if (data_pos == -ENXIO)
+		data_pos = i_size_read(file_inode(file));
+
+	if (data_pos > read->rd_offset) {
+		nfserr = nfsd4_encode_read_plus_hole(resp, read,
+						data_pos - read->rd_offset);
+		if (nfserr)
+			goto out;
+		segments++;
+	}
+
+	if (read->rd_length > 0) {
+		nfserr = nfsd4_encode_read_plus_data(resp, read, file);
+		segments++;
+	}
+
+	eof = (read->rd_offset >= i_size_read(file_inode(file)));
+	*p++ = cpu_to_be32(eof);
+	*p++ = cpu_to_be32(segments);
+
+	if (ra)
+		nfsd_put_raparams(file, ra);
+
+	if (nfserr)
+		xdr_truncate_encode(xdr, starting_len);
+
+out:
+	if (file)
+		fput(file);
 	return nfserr;
 }
 
@@ -4381,7 +4490,7 @@ static const nfsd4_enc nfsd4_enc_ops[] = {
 	[OP_LAYOUTSTATS]	= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_OFFLOAD_CANCEL]	= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_OFFLOAD_STATUS]	= (nfsd4_enc)nfsd4_encode_offload_status,
-	[OP_READ_PLUS]		= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_READ_PLUS]		= (nfsd4_enc)nfsd4_encode_read_plus,
 	[OP_SEEK]		= (nfsd4_enc)nfsd4_encode_seek,
 	[OP_WRITE_SAME]		= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_CLONE]		= (nfsd4_enc)nfsd4_encode_noop,
-- 
2.20.1


Return-Path: <SRS0=ULVj=QS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4596CC169C4
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Feb 2019 16:24:28 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CB7AE218F0
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Feb 2019 16:24:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="RT6IV632"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726892AbfBKQY1 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 11 Feb 2019 11:24:27 -0500
Received: from mail-it1-f193.google.com ([209.85.166.193]:36453 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728699AbfBKQY1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Feb 2019 11:24:27 -0500
Received: by mail-it1-f193.google.com with SMTP id c9so27703436itj.1;
        Mon, 11 Feb 2019 08:24:24 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=vohwSmtxVZDRnsxGkWRgI3AgTVFb8G2hi8pq3cZnTqU=;
        b=RT6IV632vnBB8q1BgVSruUlLveqdT4AG0eE96tlzBleeEjXFkXgUSBeHVujfvoI/OL
         FGPg0SO7MFK2la9/Qg2zXOlGlqi3eixLZ6ILsHDatKA7NBvozim9KK+V6HpzYEZXzAcT
         GeEDD2bbM5oxFHWBzdbMpFVotQ/aaMQQIe2SXqtGW7owP8dk8lgXQ1UmABwf+gSuF93U
         bitdvf4+Sjo/5NOd9ul9+0b6LQHEBCsa2rNmZt5KTEfv/a0sZkIjlYEHiO0HRMDlj4vV
         rrpsSCbxGR30b0lPhz/hoMvtSoci36HAAm9WRmmSTs4LGKBaSN+bAOzvpX2oEbte0iac
         TE4g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=vohwSmtxVZDRnsxGkWRgI3AgTVFb8G2hi8pq3cZnTqU=;
        b=G4lXpEsnDRx/+s3Q8E7oMskKqYqmEEawiAKOk/Bu88JXS6lfub3xP7z4ESWjc8k6gn
         CNdLu1JWft2yG6rhuvJempipZpx1wMKsKN7pob0h+aa87+38LcxDranfckCx5QUi2ImH
         X1QiwzysXwtuPnhveeOvzSPyePLUQaJ0AXiX7ld/fKqYrNbTXFCGnwuEMtpr72EbEazw
         Trb9fZxoT9sRCAPnQCJkksqCe9DdOQH3zOGXu+GC1zeIL3iPestj0UVajBpGJbHtJUXE
         xFuUVDPJWALMVv2O2gbQ3ISjXwMATd/kF5tlG5FiOajDPLDYq/GPZiC4Ge/bUohY5a/J
         dylA==
X-Gm-Message-State: AHQUAuYavJ1CwB5YsGrLUmtJdL83EgJnvUtTg2TidRLUXckerzj7tYJk
        IS2uqfopouDXTaz0QaQPOGl+hFY1
X-Google-Smtp-Source: AHgI3IZ1cqbiDUObfExqIKqffreKt++rZ7SVNQl/AU8n2PqXeyNENPcmMkCUUY/df9SY/oQ0CzR6rw==
X-Received: by 2002:a6b:500a:: with SMTP id e10mr16125359iob.127.1549902262899;
        Mon, 11 Feb 2019 08:24:22 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id t64sm5646640itb.5.2019.02.11.08.24.22
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 08:24:22 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x1BGOLtp029976;
        Mon, 11 Feb 2019 16:24:21 GMT
Subject: [PATCH v1 08/23] NFS: Remove print_overflow_msg()
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 11 Feb 2019 11:24:21 -0500
Message-ID: <20190211162421.2817.14327.stgit@manet.1015granger.net>
In-Reply-To: <20190211161920.2817.20881.stgit@manet.1015granger.net>
References: <20190211161920.2817.20881.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This issue is now captured by a trace point in the RPC client.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/lockd/clnt4xdr.c    |   14 -
 fs/lockd/clntxdr.c     |   14 -
 fs/nfs/callback_xdr.c  |   59 +++---
 fs/nfs/nfs2xdr.c       |   84 +++------
 fs/nfs/nfs3xdr.c       |  163 +++++------------
 fs/nfs/nfs42xdr.c      |   21 +-
 fs/nfs/nfs4xdr.c       |  451 +++++++++++++-----------------------------------
 fs/nfsd/nfs4callback.c |   13 -
 8 files changed, 219 insertions(+), 600 deletions(-)

diff --git a/fs/lockd/clnt4xdr.c b/fs/lockd/clnt4xdr.c
index 214a2fa..7df6324 100644
--- a/fs/lockd/clnt4xdr.c
+++ b/fs/lockd/clnt4xdr.c
@@ -75,17 +75,6 @@ static void nlm4_compute_offsets(const struct nlm_lock *lock,
 }
 
 /*
- * Handle decode buffer overflows out-of-line.
- */
-static void print_overflow_msg(const char *func, const struct xdr_stream *xdr)
-{
-	dprintk("lockd: %s prematurely hit the end of our receive buffer. "
-		"Remaining buffer length is %tu words.\n",
-		func, xdr->end - xdr->p);
-}
-
-
-/*
  * Encode/decode NLMv4 basic data types
  *
  * Basic NLMv4 data types are defined in Appendix II, section 6.1.4
@@ -176,7 +165,6 @@ static int decode_cookie(struct xdr_stream *xdr,
 	dprintk("NFS: returned cookie was too long: %u\n", length);
 	return -EIO;
 out_overflow:
-	print_overflow_msg(__func__, xdr);
 	return -EIO;
 }
 
@@ -236,7 +224,6 @@ static int decode_nlm4_stat(struct xdr_stream *xdr, __be32 *stat)
 			__func__, be32_to_cpup(p));
 	return -EIO;
 out_overflow:
-	print_overflow_msg(__func__, xdr);
 	return -EIO;
 }
 
@@ -309,7 +296,6 @@ static int decode_nlm4_holder(struct xdr_stream *xdr, struct nlm_res *result)
 out:
 	return error;
 out_overflow:
-	print_overflow_msg(__func__, xdr);
 	return -EIO;
 }
 
diff --git a/fs/lockd/clntxdr.c b/fs/lockd/clntxdr.c
index 747b9c8..4df62f6 100644
--- a/fs/lockd/clntxdr.c
+++ b/fs/lockd/clntxdr.c
@@ -71,17 +71,6 @@ static void nlm_compute_offsets(const struct nlm_lock *lock,
 }
 
 /*
- * Handle decode buffer overflows out-of-line.
- */
-static void print_overflow_msg(const char *func, const struct xdr_stream *xdr)
-{
-	dprintk("lockd: %s prematurely hit the end of our receive buffer. "
-		"Remaining buffer length is %tu words.\n",
-		func, xdr->end - xdr->p);
-}
-
-
-/*
  * Encode/decode NLMv3 basic data types
  *
  * Basic NLMv3 data types are not defined in an IETF standards
@@ -173,7 +162,6 @@ static int decode_cookie(struct xdr_stream *xdr,
 	dprintk("NFS: returned cookie was too long: %u\n", length);
 	return -EIO;
 out_overflow:
-	print_overflow_msg(__func__, xdr);
 	return -EIO;
 }
 
@@ -231,7 +219,6 @@ static int decode_nlm_stat(struct xdr_stream *xdr,
 		__func__, be32_to_cpup(p));
 	return -EIO;
 out_overflow:
-	print_overflow_msg(__func__, xdr);
 	return -EIO;
 }
 
@@ -303,7 +290,6 @@ static int decode_nlm_holder(struct xdr_stream *xdr, struct nlm_res *result)
 out:
 	return error;
 out_overflow:
-	print_overflow_msg(__func__, xdr);
 	return -EIO;
 }
 
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index bc7c176..06233bf 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -72,16 +72,6 @@ static int nfs4_encode_void(struct svc_rqst *rqstp, __be32 *p)
 	return xdr_ressize_check(rqstp, p);
 }
 
-static __be32 *read_buf(struct xdr_stream *xdr, size_t nbytes)
-{
-	__be32 *p;
-
-	p = xdr_inline_decode(xdr, nbytes);
-	if (unlikely(p == NULL))
-		printk(KERN_WARNING "NFS: NFSv4 callback reply buffer overflowed!\n");
-	return p;
-}
-
 static __be32 decode_string(struct xdr_stream *xdr, unsigned int *len,
 		const char **str, size_t maxlen)
 {
@@ -98,13 +88,13 @@ static __be32 decode_fh(struct xdr_stream *xdr, struct nfs_fh *fh)
 {
 	__be32 *p;
 
-	p = read_buf(xdr, 4);
+	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(p == NULL))
 		return htonl(NFS4ERR_RESOURCE);
 	fh->size = ntohl(*p);
 	if (fh->size > NFS4_FHSIZE)
 		return htonl(NFS4ERR_BADHANDLE);
-	p = read_buf(xdr, fh->size);
+	p = xdr_inline_decode(xdr, fh->size);
 	if (unlikely(p == NULL))
 		return htonl(NFS4ERR_RESOURCE);
 	memcpy(&fh->data[0], p, fh->size);
@@ -117,11 +107,11 @@ static __be32 decode_bitmap(struct xdr_stream *xdr, uint32_t *bitmap)
 	__be32 *p;
 	unsigned int attrlen;
 
-	p = read_buf(xdr, 4);
+	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(p == NULL))
 		return htonl(NFS4ERR_RESOURCE);
 	attrlen = ntohl(*p);
-	p = read_buf(xdr, attrlen << 2);
+	p = xdr_inline_decode(xdr, attrlen << 2);
 	if (unlikely(p == NULL))
 		return htonl(NFS4ERR_RESOURCE);
 	if (likely(attrlen > 0))
@@ -135,7 +125,7 @@ static __be32 decode_stateid(struct xdr_stream *xdr, nfs4_stateid *stateid)
 {
 	__be32 *p;
 
-	p = read_buf(xdr, NFS4_STATEID_SIZE);
+	p = xdr_inline_decode(xdr, NFS4_STATEID_SIZE);
 	if (unlikely(p == NULL))
 		return htonl(NFS4ERR_RESOURCE);
 	memcpy(stateid->data, p, NFS4_STATEID_SIZE);
@@ -156,7 +146,7 @@ static __be32 decode_compound_hdr_arg(struct xdr_stream *xdr, struct cb_compound
 	status = decode_string(xdr, &hdr->taglen, &hdr->tag, CB_OP_TAGLEN_MAXSZ);
 	if (unlikely(status != 0))
 		return status;
-	p = read_buf(xdr, 12);
+	p = xdr_inline_decode(xdr, 12);
 	if (unlikely(p == NULL))
 		return htonl(NFS4ERR_RESOURCE);
 	hdr->minorversion = ntohl(*p++);
@@ -176,7 +166,7 @@ static __be32 decode_compound_hdr_arg(struct xdr_stream *xdr, struct cb_compound
 static __be32 decode_op_hdr(struct xdr_stream *xdr, unsigned int *op)
 {
 	__be32 *p;
-	p = read_buf(xdr, 4);
+	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(p == NULL))
 		return htonl(NFS4ERR_RESOURCE_HDR);
 	*op = ntohl(*p);
@@ -205,7 +195,7 @@ static __be32 decode_recall_args(struct svc_rqst *rqstp,
 	status = decode_delegation_stateid(xdr, &args->stateid);
 	if (unlikely(status != 0))
 		return status;
-	p = read_buf(xdr, 4);
+	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(p == NULL))
 		return htonl(NFS4ERR_RESOURCE);
 	args->truncate = ntohl(*p);
@@ -227,7 +217,7 @@ static __be32 decode_layoutrecall_args(struct svc_rqst *rqstp,
 	__be32 status = 0;
 	uint32_t iomode;
 
-	p = read_buf(xdr, 4 * sizeof(uint32_t));
+	p = xdr_inline_decode(xdr, 4 * sizeof(uint32_t));
 	if (unlikely(p == NULL))
 		return htonl(NFS4ERR_BADXDR);
 
@@ -245,14 +235,14 @@ static __be32 decode_layoutrecall_args(struct svc_rqst *rqstp,
 		if (unlikely(status != 0))
 			return status;
 
-		p = read_buf(xdr, 2 * sizeof(uint64_t));
+		p = xdr_inline_decode(xdr, 2 * sizeof(uint64_t));
 		if (unlikely(p == NULL))
 			return htonl(NFS4ERR_BADXDR);
 		p = xdr_decode_hyper(p, &args->cbl_range.offset);
 		p = xdr_decode_hyper(p, &args->cbl_range.length);
 		return decode_layout_stateid(xdr, &args->cbl_stateid);
 	} else if (args->cbl_recall_type == RETURN_FSID) {
-		p = read_buf(xdr, 2 * sizeof(uint64_t));
+		p = xdr_inline_decode(xdr, 2 * sizeof(uint64_t));
 		if (unlikely(p == NULL))
 			return htonl(NFS4ERR_BADXDR);
 		p = xdr_decode_hyper(p, &args->cbl_fsid.major);
@@ -275,7 +265,7 @@ __be32 decode_devicenotify_args(struct svc_rqst *rqstp,
 	args->ndevs = 0;
 
 	/* Num of device notifications */
-	p = read_buf(xdr, sizeof(uint32_t));
+	p = xdr_inline_decode(xdr, sizeof(uint32_t));
 	if (unlikely(p == NULL)) {
 		status = htonl(NFS4ERR_BADXDR);
 		goto out;
@@ -298,7 +288,8 @@ __be32 decode_devicenotify_args(struct svc_rqst *rqstp,
 	for (i = 0; i < n; i++) {
 		struct cb_devicenotifyitem *dev = &args->devs[i];
 
-		p = read_buf(xdr, (4 * sizeof(uint32_t)) + NFS4_DEVICEID4_SIZE);
+		p = xdr_inline_decode(xdr, (4 * sizeof(uint32_t)) +
+				      NFS4_DEVICEID4_SIZE);
 		if (unlikely(p == NULL)) {
 			status = htonl(NFS4ERR_BADXDR);
 			goto err;
@@ -329,7 +320,7 @@ __be32 decode_devicenotify_args(struct svc_rqst *rqstp,
 		p += XDR_QUADLEN(NFS4_DEVICEID4_SIZE);
 
 		if (dev->cbd_layout_type == NOTIFY_DEVICEID4_CHANGE) {
-			p = read_buf(xdr, sizeof(uint32_t));
+			p = xdr_inline_decode(xdr, sizeof(uint32_t));
 			if (unlikely(p == NULL)) {
 				status = htonl(NFS4ERR_BADXDR);
 				goto err;
@@ -359,7 +350,7 @@ static __be32 decode_sessionid(struct xdr_stream *xdr,
 {
 	__be32 *p;
 
-	p = read_buf(xdr, NFS4_MAX_SESSIONID_LEN);
+	p = xdr_inline_decode(xdr, NFS4_MAX_SESSIONID_LEN);
 	if (unlikely(p == NULL))
 		return htonl(NFS4ERR_RESOURCE);
 
@@ -379,13 +370,13 @@ static __be32 decode_rc_list(struct xdr_stream *xdr,
 		goto out;
 
 	status = htonl(NFS4ERR_RESOURCE);
-	p = read_buf(xdr, sizeof(uint32_t));
+	p = xdr_inline_decode(xdr, sizeof(uint32_t));
 	if (unlikely(p == NULL))
 		goto out;
 
 	rc_list->rcl_nrefcalls = ntohl(*p++);
 	if (rc_list->rcl_nrefcalls) {
-		p = read_buf(xdr,
+		p = xdr_inline_decode(xdr,
 			     rc_list->rcl_nrefcalls * 2 * sizeof(uint32_t));
 		if (unlikely(p == NULL))
 			goto out;
@@ -418,7 +409,7 @@ static __be32 decode_cb_sequence_args(struct svc_rqst *rqstp,
 	if (status)
 		return status;
 
-	p = read_buf(xdr, 5 * sizeof(uint32_t));
+	p = xdr_inline_decode(xdr, 5 * sizeof(uint32_t));
 	if (unlikely(p == NULL))
 		return htonl(NFS4ERR_RESOURCE);
 
@@ -461,7 +452,7 @@ static __be32 decode_recallany_args(struct svc_rqst *rqstp,
 	uint32_t bitmap[2];
 	__be32 *p, status;
 
-	p = read_buf(xdr, 4);
+	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(p == NULL))
 		return htonl(NFS4ERR_BADXDR);
 	args->craa_objs_to_keep = ntohl(*p++);
@@ -480,7 +471,7 @@ static __be32 decode_recallslot_args(struct svc_rqst *rqstp,
 	struct cb_recallslotargs *args = argp;
 	__be32 *p;
 
-	p = read_buf(xdr, 4);
+	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(p == NULL))
 		return htonl(NFS4ERR_BADXDR);
 	args->crsa_target_highest_slotid = ntohl(*p++);
@@ -492,14 +483,14 @@ static __be32 decode_lockowner(struct xdr_stream *xdr, struct cb_notify_lock_arg
 	__be32		*p;
 	unsigned int	len;
 
-	p = read_buf(xdr, 12);
+	p = xdr_inline_decode(xdr, 12);
 	if (unlikely(p == NULL))
 		return htonl(NFS4ERR_BADXDR);
 
 	p = xdr_decode_hyper(p, &args->cbnl_owner.clientid);
 	len = be32_to_cpu(*p);
 
-	p = read_buf(xdr, len);
+	p = xdr_inline_decode(xdr, len);
 	if (unlikely(p == NULL))
 		return htonl(NFS4ERR_BADXDR);
 
@@ -537,7 +528,7 @@ static __be32 decode_write_response(struct xdr_stream *xdr,
 	__be32 *p;
 
 	/* skip the always zero field */
-	p = read_buf(xdr, 4);
+	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
 		goto out;
 	p++;
@@ -577,7 +568,7 @@ static __be32 decode_offload_args(struct svc_rqst *rqstp,
 		return status;
 
 	/* decode status */
-	p = read_buf(xdr, 4);
+	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
 		goto out;
 	args->error = ntohl(*p++);
diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 350675e..7661431 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -80,17 +80,6 @@ static void prepare_reply_buffer(struct rpc_rqst *req, struct page **pages,
 }
 
 /*
- * Handle decode buffer overflows out-of-line.
- */
-static void print_overflow_msg(const char *func, const struct xdr_stream *xdr)
-{
-	dprintk("NFS: %s prematurely hit the end of our receive buffer. "
-		"Remaining buffer length is %tu words.\n",
-		func, xdr->end - xdr->p);
-}
-
-
-/*
  * Encode/decode NFSv2 basic data types
  *
  * Basic NFSv2 data types are defined in section 2.3 of RFC 1094:
@@ -110,8 +99,8 @@ static int decode_nfsdata(struct xdr_stream *xdr, struct nfs_pgio_res *result)
 	__be32 *p;
 
 	p = xdr_inline_decode(xdr, 4);
-	if (unlikely(p == NULL))
-		goto out_overflow;
+	if (unlikely(!p))
+		return -EIO;
 	count = be32_to_cpup(p);
 	recvd = xdr_read_pages(xdr, count);
 	if (unlikely(count > recvd))
@@ -125,9 +114,6 @@ static int decode_nfsdata(struct xdr_stream *xdr, struct nfs_pgio_res *result)
 		"count %u > recvd %u\n", count, recvd);
 	count = recvd;
 	goto out;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 /*
@@ -157,13 +143,10 @@ static int decode_stat(struct xdr_stream *xdr, enum nfs_stat *status)
 	__be32 *p;
 
 	p = xdr_inline_decode(xdr, 4);
-	if (unlikely(p == NULL))
-		goto out_overflow;
+	if (unlikely(!p))
+		return -EIO;
 	*status = be32_to_cpup(p);
 	return 0;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 /*
@@ -205,14 +188,11 @@ static int decode_fhandle(struct xdr_stream *xdr, struct nfs_fh *fh)
 	__be32 *p;
 
 	p = xdr_inline_decode(xdr, NFS2_FHSIZE);
-	if (unlikely(p == NULL))
-		goto out_overflow;
+	if (unlikely(!p))
+		return -EIO;
 	fh->size = NFS2_FHSIZE;
 	memcpy(fh->data, p, NFS2_FHSIZE);
 	return 0;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 /*
@@ -282,8 +262,8 @@ static int decode_fattr(struct xdr_stream *xdr, struct nfs_fattr *fattr)
 	__be32 *p;
 
 	p = xdr_inline_decode(xdr, NFS_fattr_sz << 2);
-	if (unlikely(p == NULL))
-		goto out_overflow;
+	if (unlikely(!p))
+		return -EIO;
 
 	fattr->valid |= NFS_ATTR_FATTR_V2;
 
@@ -325,9 +305,6 @@ static int decode_fattr(struct xdr_stream *xdr, struct nfs_fattr *fattr)
 out_gid:
 	dprintk("NFS: returned invalid gid\n");
 	return -EINVAL;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 /*
@@ -416,23 +393,20 @@ static int decode_filename_inline(struct xdr_stream *xdr,
 	u32 count;
 
 	p = xdr_inline_decode(xdr, 4);
-	if (unlikely(p == NULL))
-		goto out_overflow;
+	if (unlikely(!p))
+		return -EIO;
 	count = be32_to_cpup(p);
 	if (count > NFS3_MAXNAMLEN)
 		goto out_nametoolong;
 	p = xdr_inline_decode(xdr, count);
-	if (unlikely(p == NULL))
-		goto out_overflow;
+	if (unlikely(!p))
+		return -EIO;
 	*name = (const char *)p;
 	*length = count;
 	return 0;
 out_nametoolong:
 	dprintk("NFS: returned filename too long: %u\n", count);
 	return -ENAMETOOLONG;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 /*
@@ -455,8 +429,8 @@ static int decode_path(struct xdr_stream *xdr)
 	__be32 *p;
 
 	p = xdr_inline_decode(xdr, 4);
-	if (unlikely(p == NULL))
-		goto out_overflow;
+	if (unlikely(!p))
+		return -EIO;
 	length = be32_to_cpup(p);
 	if (unlikely(length >= xdr->buf->page_len || length > NFS_MAXPATHLEN))
 		goto out_size;
@@ -472,9 +446,6 @@ static int decode_path(struct xdr_stream *xdr)
 	dprintk("NFS: server cheating in pathname result: "
 		"length %u > received %u\n", length, recvd);
 	return -EIO;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 /*
@@ -951,12 +922,12 @@ int nfs2_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
 	int error;
 
 	p = xdr_inline_decode(xdr, 4);
-	if (unlikely(p == NULL))
-		goto out_overflow;
+	if (unlikely(!p))
+		return -EAGAIN;
 	if (*p++ == xdr_zero) {
 		p = xdr_inline_decode(xdr, 4);
-		if (unlikely(p == NULL))
-			goto out_overflow;
+		if (unlikely(!p))
+			return -EAGAIN;
 		if (*p++ == xdr_zero)
 			return -EAGAIN;
 		entry->eof = 1;
@@ -964,8 +935,8 @@ int nfs2_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
 	}
 
 	p = xdr_inline_decode(xdr, 4);
-	if (unlikely(p == NULL))
-		goto out_overflow;
+	if (unlikely(!p))
+		return -EAGAIN;
 	entry->ino = be32_to_cpup(p);
 
 	error = decode_filename_inline(xdr, &entry->name, &entry->len);
@@ -978,17 +949,13 @@ int nfs2_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
 	 */
 	entry->prev_cookie = entry->cookie;
 	p = xdr_inline_decode(xdr, 4);
-	if (unlikely(p == NULL))
-		goto out_overflow;
+	if (unlikely(!p))
+		return -EAGAIN;
 	entry->cookie = be32_to_cpup(p);
 
 	entry->d_type = DT_UNKNOWN;
 
 	return 0;
-
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EAGAIN;
 }
 
 /*
@@ -1052,17 +1019,14 @@ static int decode_info(struct xdr_stream *xdr, struct nfs2_fsstat *result)
 	__be32 *p;
 
 	p = xdr_inline_decode(xdr, NFS_info_sz << 2);
-	if (unlikely(p == NULL))
-		goto out_overflow;
+	if (unlikely(!p))
+		return -EIO;
 	result->tsize  = be32_to_cpup(p++);
 	result->bsize  = be32_to_cpup(p++);
 	result->blocks = be32_to_cpup(p++);
 	result->bfree  = be32_to_cpup(p++);
 	result->bavail = be32_to_cpup(p);
 	return 0;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int nfs2_xdr_dec_statfsres(struct rpc_rqst *req, struct xdr_stream *xdr,
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index 78df4eb..e561980 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -119,17 +119,6 @@ static void prepare_reply_buffer(struct rpc_rqst *req, struct page **pages,
 }
 
 /*
- * Handle decode buffer overflows out-of-line.
- */
-static void print_overflow_msg(const char *func, const struct xdr_stream *xdr)
-{
-	dprintk("NFS: %s prematurely hit the end of our receive buffer. "
-		"Remaining buffer length is %tu words.\n",
-		func, xdr->end - xdr->p);
-}
-
-
-/*
  * Encode/decode NFSv3 basic data types
  *
  * Basic NFSv3 data types are defined in section 2.5 of RFC 1813:
@@ -151,13 +140,10 @@ static int decode_uint32(struct xdr_stream *xdr, u32 *value)
 	__be32 *p;
 
 	p = xdr_inline_decode(xdr, 4);
-	if (unlikely(p == NULL))
-		goto out_overflow;
+	if (unlikely(!p))
+		return -EIO;
 	*value = be32_to_cpup(p);
 	return 0;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_uint64(struct xdr_stream *xdr, u64 *value)
@@ -165,13 +151,10 @@ static int decode_uint64(struct xdr_stream *xdr, u64 *value)
 	__be32 *p;
 
 	p = xdr_inline_decode(xdr, 8);
-	if (unlikely(p == NULL))
-		goto out_overflow;
+	if (unlikely(!p))
+		return -EIO;
 	xdr_decode_hyper(p, value);
 	return 0;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 /*
@@ -211,14 +194,14 @@ static int decode_inline_filename3(struct xdr_stream *xdr,
 	u32 count;
 
 	p = xdr_inline_decode(xdr, 4);
-	if (unlikely(p == NULL))
-		goto out_overflow;
+	if (unlikely(!p))
+		return -EIO;
 	count = be32_to_cpup(p);
 	if (count > NFS3_MAXNAMLEN)
 		goto out_nametoolong;
 	p = xdr_inline_decode(xdr, count);
-	if (unlikely(p == NULL))
-		goto out_overflow;
+	if (unlikely(!p))
+		return -EIO;
 	*name = (const char *)p;
 	*length = count;
 	return 0;
@@ -226,9 +209,6 @@ static int decode_inline_filename3(struct xdr_stream *xdr,
 out_nametoolong:
 	dprintk("NFS: returned filename too long: %u\n", count);
 	return -ENAMETOOLONG;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 /*
@@ -249,8 +229,8 @@ static int decode_nfspath3(struct xdr_stream *xdr)
 	__be32 *p;
 
 	p = xdr_inline_decode(xdr, 4);
-	if (unlikely(p == NULL))
-		goto out_overflow;
+	if (unlikely(!p))
+		return -EIO;
 	count = be32_to_cpup(p);
 	if (unlikely(count >= xdr->buf->page_len || count > NFS3_MAXPATHLEN))
 		goto out_nametoolong;
@@ -267,9 +247,6 @@ static int decode_nfspath3(struct xdr_stream *xdr)
 	dprintk("NFS: server cheating in pathname result: "
 		"count %u > recvd %u\n", count, recvd);
 	return -EIO;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 /*
@@ -303,13 +280,10 @@ static int decode_cookieverf3(struct xdr_stream *xdr, __be32 *verifier)
 	__be32 *p;
 
 	p = xdr_inline_decode(xdr, NFS3_COOKIEVERFSIZE);
-	if (unlikely(p == NULL))
-		goto out_overflow;
+	if (unlikely(!p))
+		return -EIO;
 	memcpy(verifier, p, NFS3_COOKIEVERFSIZE);
 	return 0;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 /*
@@ -330,13 +304,10 @@ static int decode_writeverf3(struct xdr_stream *xdr, struct nfs_write_verifier *
 	__be32 *p;
 
 	p = xdr_inline_decode(xdr, NFS3_WRITEVERFSIZE);
-	if (unlikely(p == NULL))
-		goto out_overflow;
+	if (unlikely(!p))
+		return -EIO;
 	memcpy(verifier->data, p, NFS3_WRITEVERFSIZE);
 	return 0;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 /*
@@ -364,13 +335,10 @@ static int decode_nfsstat3(struct xdr_stream *xdr, enum nfs_stat *status)
 	__be32 *p;
 
 	p = xdr_inline_decode(xdr, 4);
-	if (unlikely(p == NULL))
-		goto out_overflow;
+	if (unlikely(!p))
+		return -EIO;
 	*status = be32_to_cpup(p);
 	return 0;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 /*
@@ -453,23 +421,20 @@ static int decode_nfs_fh3(struct xdr_stream *xdr, struct nfs_fh *fh)
 	__be32 *p;
 
 	p = xdr_inline_decode(xdr, 4);
-	if (unlikely(p == NULL))
-		goto out_overflow;
+	if (unlikely(!p))
+		return -EIO;
 	length = be32_to_cpup(p++);
 	if (unlikely(length > NFS3_FHSIZE))
 		goto out_toobig;
 	p = xdr_inline_decode(xdr, length);
-	if (unlikely(p == NULL))
-		goto out_overflow;
+	if (unlikely(!p))
+		return -EIO;
 	fh->size = length;
 	memcpy(fh->data, p, length);
 	return 0;
 out_toobig:
 	dprintk("NFS: file handle size (%u) too big\n", length);
 	return -E2BIG;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static void zero_nfs_fh3(struct nfs_fh *fh)
@@ -655,8 +620,8 @@ static int decode_fattr3(struct xdr_stream *xdr, struct nfs_fattr *fattr)
 	__be32 *p;
 
 	p = xdr_inline_decode(xdr, NFS3_fattr_sz << 2);
-	if (unlikely(p == NULL))
-		goto out_overflow;
+	if (unlikely(!p))
+		return -EIO;
 
 	p = xdr_decode_ftype3(p, &fmode);
 
@@ -690,9 +655,6 @@ static int decode_fattr3(struct xdr_stream *xdr, struct nfs_fattr *fattr)
 out_gid:
 	dprintk("NFS: returned invalid gid\n");
 	return -EINVAL;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 /*
@@ -710,14 +672,11 @@ static int decode_post_op_attr(struct xdr_stream *xdr, struct nfs_fattr *fattr)
 	__be32 *p;
 
 	p = xdr_inline_decode(xdr, 4);
-	if (unlikely(p == NULL))
-		goto out_overflow;
+	if (unlikely(!p))
+		return -EIO;
 	if (*p != xdr_zero)
 		return decode_fattr3(xdr, fattr);
 	return 0;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 /*
@@ -733,8 +692,8 @@ static int decode_wcc_attr(struct xdr_stream *xdr, struct nfs_fattr *fattr)
 	__be32 *p;
 
 	p = xdr_inline_decode(xdr, NFS3_wcc_attr_sz << 2);
-	if (unlikely(p == NULL))
-		goto out_overflow;
+	if (unlikely(!p))
+		return -EIO;
 
 	fattr->valid |= NFS_ATTR_FATTR_PRESIZE
 		| NFS_ATTR_FATTR_PRECHANGE
@@ -747,9 +706,6 @@ static int decode_wcc_attr(struct xdr_stream *xdr, struct nfs_fattr *fattr)
 	fattr->pre_change_attr = nfs_timespec_to_change_attr(&fattr->pre_ctime);
 
 	return 0;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 /*
@@ -773,14 +729,11 @@ static int decode_pre_op_attr(struct xdr_stream *xdr, struct nfs_fattr *fattr)
 	__be32 *p;
 
 	p = xdr_inline_decode(xdr, 4);
-	if (unlikely(p == NULL))
-		goto out_overflow;
+	if (unlikely(!p))
+		return -EIO;
 	if (*p != xdr_zero)
 		return decode_wcc_attr(xdr, fattr);
 	return 0;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_wcc_data(struct xdr_stream *xdr, struct nfs_fattr *fattr)
@@ -808,15 +761,12 @@ static int decode_wcc_data(struct xdr_stream *xdr, struct nfs_fattr *fattr)
 static int decode_post_op_fh3(struct xdr_stream *xdr, struct nfs_fh *fh)
 {
 	__be32 *p = xdr_inline_decode(xdr, 4);
-	if (unlikely(p == NULL))
-		goto out_overflow;
+	if (unlikely(!p))
+		return -EIO;
 	if (*p != xdr_zero)
 		return decode_nfs_fh3(xdr, fh);
 	zero_nfs_fh3(fh);
 	return 0;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 /*
@@ -1643,8 +1593,8 @@ static int decode_read3resok(struct xdr_stream *xdr,
 	__be32 *p;
 
 	p = xdr_inline_decode(xdr, 4 + 4 + 4);
-	if (unlikely(p == NULL))
-		goto out_overflow;
+	if (unlikely(!p))
+		return -EIO;
 	count = be32_to_cpup(p++);
 	eof = be32_to_cpup(p++);
 	ocount = be32_to_cpup(p++);
@@ -1667,9 +1617,6 @@ static int decode_read3resok(struct xdr_stream *xdr,
 	count = recvd;
 	eof = 0;
 	goto out;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int nfs3_xdr_dec_read3res(struct rpc_rqst *req, struct xdr_stream *xdr,
@@ -1731,22 +1678,18 @@ static int decode_write3resok(struct xdr_stream *xdr,
 	__be32 *p;
 
 	p = xdr_inline_decode(xdr, 4 + 4);
-	if (unlikely(p == NULL))
-		goto out_overflow;
+	if (unlikely(!p))
+		return -EIO;
 	result->count = be32_to_cpup(p++);
 	result->verf->committed = be32_to_cpup(p++);
 	if (unlikely(result->verf->committed > NFS_FILE_SYNC))
 		goto out_badvalue;
 	if (decode_writeverf3(xdr, &result->verf->verifier))
-		goto out_eio;
+		return -EIO;
 	return result->count;
 out_badvalue:
 	dprintk("NFS: bad stable_how value: %u\n", result->verf->committed);
 	return -EIO;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-out_eio:
-	return -EIO;
 }
 
 static int nfs3_xdr_dec_write3res(struct rpc_rqst *req, struct xdr_stream *xdr,
@@ -2010,12 +1953,12 @@ int nfs3_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
 	u64 new_cookie;
 
 	p = xdr_inline_decode(xdr, 4);
-	if (unlikely(p == NULL))
-		goto out_overflow;
+	if (unlikely(!p))
+		return -EAGAIN;
 	if (*p == xdr_zero) {
 		p = xdr_inline_decode(xdr, 4);
-		if (unlikely(p == NULL))
-			goto out_overflow;
+		if (unlikely(!p))
+			return -EAGAIN;
 		if (*p == xdr_zero)
 			return -EAGAIN;
 		entry->eof = 1;
@@ -2051,8 +1994,8 @@ int nfs3_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
 
 		/* In fact, a post_op_fh3: */
 		p = xdr_inline_decode(xdr, 4);
-		if (unlikely(p == NULL))
-			goto out_overflow;
+		if (unlikely(!p))
+			return -EAGAIN;
 		if (*p != xdr_zero) {
 			error = decode_nfs_fh3(xdr, entry->fh);
 			if (unlikely(error)) {
@@ -2069,9 +2012,6 @@ int nfs3_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
 
 	return 0;
 
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EAGAIN;
 out_truncated:
 	dprintk("NFS: directory entry contains invalid file handle\n");
 	*entry = old;
@@ -2183,8 +2123,8 @@ static int decode_fsstat3resok(struct xdr_stream *xdr,
 	__be32 *p;
 
 	p = xdr_inline_decode(xdr, 8 * 6 + 4);
-	if (unlikely(p == NULL))
-		goto out_overflow;
+	if (unlikely(!p))
+		return -EIO;
 	p = xdr_decode_size3(p, &result->tbytes);
 	p = xdr_decode_size3(p, &result->fbytes);
 	p = xdr_decode_size3(p, &result->abytes);
@@ -2193,9 +2133,6 @@ static int decode_fsstat3resok(struct xdr_stream *xdr,
 	xdr_decode_size3(p, &result->afiles);
 	/* ignore invarsec */
 	return 0;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int nfs3_xdr_dec_fsstat3res(struct rpc_rqst *req,
@@ -2255,8 +2192,8 @@ static int decode_fsinfo3resok(struct xdr_stream *xdr,
 	__be32 *p;
 
 	p = xdr_inline_decode(xdr, 4 * 7 + 8 + 8 + 4);
-	if (unlikely(p == NULL))
-		goto out_overflow;
+	if (unlikely(!p))
+		return -EIO;
 	result->rtmax  = be32_to_cpup(p++);
 	result->rtpref = be32_to_cpup(p++);
 	result->rtmult = be32_to_cpup(p++);
@@ -2270,9 +2207,6 @@ static int decode_fsinfo3resok(struct xdr_stream *xdr,
 	/* ignore properties */
 	result->lease_time = 0;
 	return 0;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int nfs3_xdr_dec_fsinfo3res(struct rpc_rqst *req,
@@ -2328,15 +2262,12 @@ static int decode_pathconf3resok(struct xdr_stream *xdr,
 	__be32 *p;
 
 	p = xdr_inline_decode(xdr, 4 * 6);
-	if (unlikely(p == NULL))
-		goto out_overflow;
+	if (unlikely(!p))
+		return -EIO;
 	result->max_link = be32_to_cpup(p++);
 	result->max_namelen = be32_to_cpup(p);
 	/* ignore remaining fields */
 	return 0;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int nfs3_xdr_dec_pathconf3res(struct rpc_rqst *req,
diff --git a/fs/nfs/nfs42xdr.c b/fs/nfs/nfs42xdr.c
index 69f72ed..22b3425 100644
--- a/fs/nfs/nfs42xdr.c
+++ b/fs/nfs/nfs42xdr.c
@@ -394,7 +394,7 @@ static int decode_write_response(struct xdr_stream *xdr,
 
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
-		goto out_overflow;
+		return -EIO;
 	count = be32_to_cpup(p);
 	if (count > 1)
 		return -EREMOTEIO;
@@ -402,18 +402,14 @@ static int decode_write_response(struct xdr_stream *xdr,
 		status = decode_opaque_fixed(xdr, &res->stateid,
 				NFS4_STATEID_SIZE);
 		if (unlikely(status))
-			goto out_overflow;
+			return -EIO;
 	}
 	p = xdr_inline_decode(xdr, 8 + 4);
 	if (unlikely(!p))
-		goto out_overflow;
+		return -EIO;
 	p = xdr_decode_hyper(p, &res->count);
 	res->verifier.committed = be32_to_cpup(p);
 	return decode_verifier(xdr, &res->verifier.verifier);
-
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_copy_requirements(struct xdr_stream *xdr,
@@ -422,14 +418,11 @@ static int decode_copy_requirements(struct xdr_stream *xdr,
 
 	p = xdr_inline_decode(xdr, 4 + 4);
 	if (unlikely(!p))
-		goto out_overflow;
+		return -EIO;
 
 	res->consecutive = be32_to_cpup(p++);
 	res->synchronous = be32_to_cpup(p++);
 	return 0;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_copy(struct xdr_stream *xdr, struct nfs42_copy_res *res)
@@ -474,15 +467,11 @@ static int decode_seek(struct xdr_stream *xdr, struct nfs42_seek_res *res)
 
 	p = xdr_inline_decode(xdr, 4 + 8);
 	if (unlikely(!p))
-		goto out_overflow;
+		return -EIO;
 
 	res->sr_eof = be32_to_cpup(p++);
 	p = xdr_decode_hyper(p, &res->sr_offset);
 	return 0;
-
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_layoutstats(struct xdr_stream *xdr)
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 2fc8f6f..24e6a45 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -3144,22 +3144,12 @@ static void nfs4_xdr_enc_free_stateid(struct rpc_rqst *req,
 }
 #endif /* CONFIG_NFS_V4_1 */
 
-static void print_overflow_msg(const char *func, const struct xdr_stream *xdr)
-{
-	dprintk("nfs: %s: prematurely hit end of receive buffer. "
-		"Remaining buffer length is %tu words.\n",
-		func, xdr->end - xdr->p);
-}
-
 static int decode_opaque_inline(struct xdr_stream *xdr, unsigned int *len, char **string)
 {
 	ssize_t ret = xdr_stream_decode_opaque_inline(xdr, (void **)string,
 			NFS4_OPAQUE_LIMIT);
-	if (unlikely(ret < 0)) {
-		if (ret == -EBADMSG)
-			print_overflow_msg(__func__, xdr);
+	if (unlikely(ret < 0))
 		return -EIO;
-	}
 	*len = ret;
 	return 0;
 }
@@ -3170,22 +3160,19 @@ static int decode_compound_hdr(struct xdr_stream *xdr, struct compound_hdr *hdr)
 
 	p = xdr_inline_decode(xdr, 8);
 	if (unlikely(!p))
-		goto out_overflow;
+		return -EIO;
 	hdr->status = be32_to_cpup(p++);
 	hdr->taglen = be32_to_cpup(p);
 
 	p = xdr_inline_decode(xdr, hdr->taglen + 4);
 	if (unlikely(!p))
-		goto out_overflow;
+		return -EIO;
 	hdr->tag = (char *)p;
 	p += XDR_QUADLEN(hdr->taglen);
 	hdr->nops = be32_to_cpup(p);
 	if (unlikely(hdr->nops < 1))
 		return nfs4_stat_to_errno(hdr->status);
 	return 0;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static bool __decode_op_hdr(struct xdr_stream *xdr, enum nfs_opnum4 expected,
@@ -3214,7 +3201,6 @@ static bool __decode_op_hdr(struct xdr_stream *xdr, enum nfs_opnum4 expected,
 	*nfs_retval = -EREMOTEIO;
 	return false;
 out_overflow:
-	print_overflow_msg(__func__, xdr);
 	*nfs_retval = -EIO;
 	return false;
 }
@@ -3235,10 +3221,9 @@ static int decode_ace(struct xdr_stream *xdr, void *ace)
 	char *str;
 
 	p = xdr_inline_decode(xdr, 12);
-	if (likely(p))
-		return decode_opaque_inline(xdr, &strlen, &str);
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
+	if (unlikely(!p))
+		return -EIO;
+	return decode_opaque_inline(xdr, &strlen, &str);
 }
 
 static ssize_t
@@ -3249,10 +3234,9 @@ static int decode_ace(struct xdr_stream *xdr, void *ace)
 	ret = xdr_stream_decode_uint32_array(xdr, bitmap, sz);
 	if (likely(ret >= 0))
 		return ret;
-	if (ret == -EMSGSIZE)
-		return sz;
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
+	if (ret != -EMSGSIZE)
+		return -EIO;
+	return sz;
 }
 
 static int decode_attr_bitmap(struct xdr_stream *xdr, uint32_t *bitmap)
@@ -3268,13 +3252,10 @@ static int decode_attr_length(struct xdr_stream *xdr, uint32_t *attrlen, unsigne
 
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
-		goto out_overflow;
+		return -EIO;
 	*attrlen = be32_to_cpup(p);
 	*savep = xdr_stream_pos(xdr);
 	return 0;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_attr_supported(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t *bitmask)
@@ -3303,7 +3284,7 @@ static int decode_attr_type(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t *
 	if (likely(bitmap[0] & FATTR4_WORD0_TYPE)) {
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
-			goto out_overflow;
+			return -EIO;
 		*type = be32_to_cpup(p);
 		if (*type < NF4REG || *type > NF4NAMEDATTR) {
 			dprintk("%s: bad type %d\n", __func__, *type);
@@ -3314,9 +3295,6 @@ static int decode_attr_type(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t *
 	}
 	dprintk("%s: type=0%o\n", __func__, nfs_type2fmt[*type]);
 	return ret;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_attr_fh_expire_type(struct xdr_stream *xdr,
@@ -3330,15 +3308,12 @@ static int decode_attr_fh_expire_type(struct xdr_stream *xdr,
 	if (likely(bitmap[0] & FATTR4_WORD0_FH_EXPIRE_TYPE)) {
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
-			goto out_overflow;
+			return -EIO;
 		*type = be32_to_cpup(p);
 		bitmap[0] &= ~FATTR4_WORD0_FH_EXPIRE_TYPE;
 	}
 	dprintk("%s: expire type=0x%x\n", __func__, *type);
 	return 0;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_attr_change(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t *change)
@@ -3352,7 +3327,7 @@ static int decode_attr_change(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t
 	if (likely(bitmap[0] & FATTR4_WORD0_CHANGE)) {
 		p = xdr_inline_decode(xdr, 8);
 		if (unlikely(!p))
-			goto out_overflow;
+			return -EIO;
 		xdr_decode_hyper(p, change);
 		bitmap[0] &= ~FATTR4_WORD0_CHANGE;
 		ret = NFS_ATTR_FATTR_CHANGE;
@@ -3360,9 +3335,6 @@ static int decode_attr_change(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t
 	dprintk("%s: change attribute=%Lu\n", __func__,
 			(unsigned long long)*change);
 	return ret;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_attr_size(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t *size)
@@ -3376,16 +3348,13 @@ static int decode_attr_size(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t *
 	if (likely(bitmap[0] & FATTR4_WORD0_SIZE)) {
 		p = xdr_inline_decode(xdr, 8);
 		if (unlikely(!p))
-			goto out_overflow;
+			return -EIO;
 		xdr_decode_hyper(p, size);
 		bitmap[0] &= ~FATTR4_WORD0_SIZE;
 		ret = NFS_ATTR_FATTR_SIZE;
 	}
 	dprintk("%s: file size=%Lu\n", __func__, (unsigned long long)*size);
 	return ret;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_attr_link_support(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t *res)
@@ -3398,15 +3367,12 @@ static int decode_attr_link_support(struct xdr_stream *xdr, uint32_t *bitmap, ui
 	if (likely(bitmap[0] & FATTR4_WORD0_LINK_SUPPORT)) {
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
-			goto out_overflow;
+			return -EIO;
 		*res = be32_to_cpup(p);
 		bitmap[0] &= ~FATTR4_WORD0_LINK_SUPPORT;
 	}
 	dprintk("%s: link support=%s\n", __func__, *res == 0 ? "false" : "true");
 	return 0;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_attr_symlink_support(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t *res)
@@ -3419,15 +3385,12 @@ static int decode_attr_symlink_support(struct xdr_stream *xdr, uint32_t *bitmap,
 	if (likely(bitmap[0] & FATTR4_WORD0_SYMLINK_SUPPORT)) {
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
-			goto out_overflow;
+			return -EIO;
 		*res = be32_to_cpup(p);
 		bitmap[0] &= ~FATTR4_WORD0_SYMLINK_SUPPORT;
 	}
 	dprintk("%s: symlink support=%s\n", __func__, *res == 0 ? "false" : "true");
 	return 0;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_attr_fsid(struct xdr_stream *xdr, uint32_t *bitmap, struct nfs_fsid *fsid)
@@ -3442,7 +3405,7 @@ static int decode_attr_fsid(struct xdr_stream *xdr, uint32_t *bitmap, struct nfs
 	if (likely(bitmap[0] & FATTR4_WORD0_FSID)) {
 		p = xdr_inline_decode(xdr, 16);
 		if (unlikely(!p))
-			goto out_overflow;
+			return -EIO;
 		p = xdr_decode_hyper(p, &fsid->major);
 		xdr_decode_hyper(p, &fsid->minor);
 		bitmap[0] &= ~FATTR4_WORD0_FSID;
@@ -3452,9 +3415,6 @@ static int decode_attr_fsid(struct xdr_stream *xdr, uint32_t *bitmap, struct nfs
 			(unsigned long long)fsid->major,
 			(unsigned long long)fsid->minor);
 	return ret;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_attr_lease_time(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t *res)
@@ -3467,15 +3427,12 @@ static int decode_attr_lease_time(struct xdr_stream *xdr, uint32_t *bitmap, uint
 	if (likely(bitmap[0] & FATTR4_WORD0_LEASE_TIME)) {
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
-			goto out_overflow;
+			return -EIO;
 		*res = be32_to_cpup(p);
 		bitmap[0] &= ~FATTR4_WORD0_LEASE_TIME;
 	}
 	dprintk("%s: file size=%u\n", __func__, (unsigned int)*res);
 	return 0;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_attr_error(struct xdr_stream *xdr, uint32_t *bitmap, int32_t *res)
@@ -3487,14 +3444,11 @@ static int decode_attr_error(struct xdr_stream *xdr, uint32_t *bitmap, int32_t *
 	if (likely(bitmap[0] & FATTR4_WORD0_RDATTR_ERROR)) {
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
-			goto out_overflow;
+			return -EIO;
 		bitmap[0] &= ~FATTR4_WORD0_RDATTR_ERROR;
 		*res = -be32_to_cpup(p);
 	}
 	return 0;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_attr_exclcreat_supported(struct xdr_stream *xdr,
@@ -3526,13 +3480,13 @@ static int decode_attr_filehandle(struct xdr_stream *xdr, uint32_t *bitmap, stru
 	if (likely(bitmap[0] & FATTR4_WORD0_FILEHANDLE)) {
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
-			goto out_overflow;
+			return -EIO;
 		len = be32_to_cpup(p);
 		if (len > NFS4_FHSIZE)
 			return -EIO;
 		p = xdr_inline_decode(xdr, len);
 		if (unlikely(!p))
-			goto out_overflow;
+			return -EIO;
 		if (fh != NULL) {
 			memcpy(fh->data, p, len);
 			fh->size = len;
@@ -3540,9 +3494,6 @@ static int decode_attr_filehandle(struct xdr_stream *xdr, uint32_t *bitmap, stru
 		bitmap[0] &= ~FATTR4_WORD0_FILEHANDLE;
 	}
 	return 0;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_attr_aclsupport(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t *res)
@@ -3555,15 +3506,12 @@ static int decode_attr_aclsupport(struct xdr_stream *xdr, uint32_t *bitmap, uint
 	if (likely(bitmap[0] & FATTR4_WORD0_ACLSUPPORT)) {
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
-			goto out_overflow;
+			return -EIO;
 		*res = be32_to_cpup(p);
 		bitmap[0] &= ~FATTR4_WORD0_ACLSUPPORT;
 	}
 	dprintk("%s: ACLs supported=%u\n", __func__, (unsigned int)*res);
 	return 0;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_attr_fileid(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t *fileid)
@@ -3577,16 +3525,13 @@ static int decode_attr_fileid(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t
 	if (likely(bitmap[0] & FATTR4_WORD0_FILEID)) {
 		p = xdr_inline_decode(xdr, 8);
 		if (unlikely(!p))
-			goto out_overflow;
+			return -EIO;
 		xdr_decode_hyper(p, fileid);
 		bitmap[0] &= ~FATTR4_WORD0_FILEID;
 		ret = NFS_ATTR_FATTR_FILEID;
 	}
 	dprintk("%s: fileid=%Lu\n", __func__, (unsigned long long)*fileid);
 	return ret;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_attr_mounted_on_fileid(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t *fileid)
@@ -3600,16 +3545,13 @@ static int decode_attr_mounted_on_fileid(struct xdr_stream *xdr, uint32_t *bitma
 	if (likely(bitmap[1] & FATTR4_WORD1_MOUNTED_ON_FILEID)) {
 		p = xdr_inline_decode(xdr, 8);
 		if (unlikely(!p))
-			goto out_overflow;
+			return -EIO;
 		xdr_decode_hyper(p, fileid);
 		bitmap[1] &= ~FATTR4_WORD1_MOUNTED_ON_FILEID;
 		ret = NFS_ATTR_FATTR_MOUNTED_ON_FILEID;
 	}
 	dprintk("%s: fileid=%Lu\n", __func__, (unsigned long long)*fileid);
 	return ret;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_attr_files_avail(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t *res)
@@ -3623,15 +3565,12 @@ static int decode_attr_files_avail(struct xdr_stream *xdr, uint32_t *bitmap, uin
 	if (likely(bitmap[0] & FATTR4_WORD0_FILES_AVAIL)) {
 		p = xdr_inline_decode(xdr, 8);
 		if (unlikely(!p))
-			goto out_overflow;
+			return -EIO;
 		xdr_decode_hyper(p, res);
 		bitmap[0] &= ~FATTR4_WORD0_FILES_AVAIL;
 	}
 	dprintk("%s: files avail=%Lu\n", __func__, (unsigned long long)*res);
 	return status;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_attr_files_free(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t *res)
@@ -3645,15 +3584,12 @@ static int decode_attr_files_free(struct xdr_stream *xdr, uint32_t *bitmap, uint
 	if (likely(bitmap[0] & FATTR4_WORD0_FILES_FREE)) {
 		p = xdr_inline_decode(xdr, 8);
 		if (unlikely(!p))
-			goto out_overflow;
+			return -EIO;
 		xdr_decode_hyper(p, res);
 		bitmap[0] &= ~FATTR4_WORD0_FILES_FREE;
 	}
 	dprintk("%s: files free=%Lu\n", __func__, (unsigned long long)*res);
 	return status;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_attr_files_total(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t *res)
@@ -3667,15 +3603,12 @@ static int decode_attr_files_total(struct xdr_stream *xdr, uint32_t *bitmap, uin
 	if (likely(bitmap[0] & FATTR4_WORD0_FILES_TOTAL)) {
 		p = xdr_inline_decode(xdr, 8);
 		if (unlikely(!p))
-			goto out_overflow;
+			return -EIO;
 		xdr_decode_hyper(p, res);
 		bitmap[0] &= ~FATTR4_WORD0_FILES_TOTAL;
 	}
 	dprintk("%s: files total=%Lu\n", __func__, (unsigned long long)*res);
 	return status;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_pathname(struct xdr_stream *xdr, struct nfs4_pathname *path)
@@ -3686,7 +3619,7 @@ static int decode_pathname(struct xdr_stream *xdr, struct nfs4_pathname *path)
 
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
-		goto out_overflow;
+		return -EIO;
 	n = be32_to_cpup(p);
 	if (n == 0)
 		goto root_path;
@@ -3718,9 +3651,6 @@ static int decode_pathname(struct xdr_stream *xdr, struct nfs4_pathname *path)
 	dprintk(" status %d", status);
 	status = -EIO;
 	goto out;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, struct nfs4_fs_locations *res)
@@ -3745,7 +3675,7 @@ static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, st
 		goto out;
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
-		goto out_overflow;
+		goto out_eio;
 	n = be32_to_cpup(p);
 	if (n <= 0)
 		goto out_eio;
@@ -3758,7 +3688,7 @@ static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, st
 		loc = &res->locations[res->nlocations];
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
-			goto out_overflow;
+			goto out_eio;
 		m = be32_to_cpup(p);
 
 		dprintk("%s: servers:\n", __func__);
@@ -3796,8 +3726,6 @@ static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, st
 out:
 	dprintk("%s: fs_locations done, error = %d\n", __func__, status);
 	return status;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
 out_eio:
 	status = -EIO;
 	goto out;
@@ -3814,15 +3742,12 @@ static int decode_attr_maxfilesize(struct xdr_stream *xdr, uint32_t *bitmap, uin
 	if (likely(bitmap[0] & FATTR4_WORD0_MAXFILESIZE)) {
 		p = xdr_inline_decode(xdr, 8);
 		if (unlikely(!p))
-			goto out_overflow;
+			return -EIO;
 		xdr_decode_hyper(p, res);
 		bitmap[0] &= ~FATTR4_WORD0_MAXFILESIZE;
 	}
 	dprintk("%s: maxfilesize=%Lu\n", __func__, (unsigned long long)*res);
 	return status;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_attr_maxlink(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t *maxlink)
@@ -3836,15 +3761,12 @@ static int decode_attr_maxlink(struct xdr_stream *xdr, uint32_t *bitmap, uint32_
 	if (likely(bitmap[0] & FATTR4_WORD0_MAXLINK)) {
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
-			goto out_overflow;
+			return -EIO;
 		*maxlink = be32_to_cpup(p);
 		bitmap[0] &= ~FATTR4_WORD0_MAXLINK;
 	}
 	dprintk("%s: maxlink=%u\n", __func__, *maxlink);
 	return status;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_attr_maxname(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t *maxname)
@@ -3858,15 +3780,12 @@ static int decode_attr_maxname(struct xdr_stream *xdr, uint32_t *bitmap, uint32_
 	if (likely(bitmap[0] & FATTR4_WORD0_MAXNAME)) {
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
-			goto out_overflow;
+			return -EIO;
 		*maxname = be32_to_cpup(p);
 		bitmap[0] &= ~FATTR4_WORD0_MAXNAME;
 	}
 	dprintk("%s: maxname=%u\n", __func__, *maxname);
 	return status;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_attr_maxread(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t *res)
@@ -3881,7 +3800,7 @@ static int decode_attr_maxread(struct xdr_stream *xdr, uint32_t *bitmap, uint32_
 		uint64_t maxread;
 		p = xdr_inline_decode(xdr, 8);
 		if (unlikely(!p))
-			goto out_overflow;
+			return -EIO;
 		xdr_decode_hyper(p, &maxread);
 		if (maxread > 0x7FFFFFFF)
 			maxread = 0x7FFFFFFF;
@@ -3890,9 +3809,6 @@ static int decode_attr_maxread(struct xdr_stream *xdr, uint32_t *bitmap, uint32_
 	}
 	dprintk("%s: maxread=%lu\n", __func__, (unsigned long)*res);
 	return status;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_attr_maxwrite(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t *res)
@@ -3907,7 +3823,7 @@ static int decode_attr_maxwrite(struct xdr_stream *xdr, uint32_t *bitmap, uint32
 		uint64_t maxwrite;
 		p = xdr_inline_decode(xdr, 8);
 		if (unlikely(!p))
-			goto out_overflow;
+			return -EIO;
 		xdr_decode_hyper(p, &maxwrite);
 		if (maxwrite > 0x7FFFFFFF)
 			maxwrite = 0x7FFFFFFF;
@@ -3916,9 +3832,6 @@ static int decode_attr_maxwrite(struct xdr_stream *xdr, uint32_t *bitmap, uint32
 	}
 	dprintk("%s: maxwrite=%lu\n", __func__, (unsigned long)*res);
 	return status;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_attr_mode(struct xdr_stream *xdr, uint32_t *bitmap, umode_t *mode)
@@ -3933,7 +3846,7 @@ static int decode_attr_mode(struct xdr_stream *xdr, uint32_t *bitmap, umode_t *m
 	if (likely(bitmap[1] & FATTR4_WORD1_MODE)) {
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
-			goto out_overflow;
+			return -EIO;
 		tmp = be32_to_cpup(p);
 		*mode = tmp & ~S_IFMT;
 		bitmap[1] &= ~FATTR4_WORD1_MODE;
@@ -3941,9 +3854,6 @@ static int decode_attr_mode(struct xdr_stream *xdr, uint32_t *bitmap, umode_t *m
 	}
 	dprintk("%s: file mode=0%o\n", __func__, (unsigned int)*mode);
 	return ret;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_attr_nlink(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t *nlink)
@@ -3957,16 +3867,13 @@ static int decode_attr_nlink(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t
 	if (likely(bitmap[1] & FATTR4_WORD1_NUMLINKS)) {
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
-			goto out_overflow;
+			return -EIO;
 		*nlink = be32_to_cpup(p);
 		bitmap[1] &= ~FATTR4_WORD1_NUMLINKS;
 		ret = NFS_ATTR_FATTR_NLINK;
 	}
 	dprintk("%s: nlink=%u\n", __func__, (unsigned int)*nlink);
 	return ret;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static ssize_t decode_nfs4_string(struct xdr_stream *xdr,
@@ -4011,10 +3918,9 @@ static int decode_attr_owner(struct xdr_stream *xdr, uint32_t *bitmap,
 		return NFS_ATTR_FATTR_OWNER;
 	}
 out:
-	if (len != -EBADMSG)
-		return 0;
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
+	if (len == -EBADMSG)
+		return -EIO;
+	return 0;
 }
 
 static int decode_attr_group(struct xdr_stream *xdr, uint32_t *bitmap,
@@ -4046,10 +3952,9 @@ static int decode_attr_group(struct xdr_stream *xdr, uint32_t *bitmap,
 		return NFS_ATTR_FATTR_GROUP;
 	}
 out:
-	if (len != -EBADMSG)
-		return 0;
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
+	if (len == -EBADMSG)
+		return -EIO;
+	return 0;
 }
 
 static int decode_attr_rdev(struct xdr_stream *xdr, uint32_t *bitmap, dev_t *rdev)
@@ -4066,7 +3971,7 @@ static int decode_attr_rdev(struct xdr_stream *xdr, uint32_t *bitmap, dev_t *rde
 
 		p = xdr_inline_decode(xdr, 8);
 		if (unlikely(!p))
-			goto out_overflow;
+			return -EIO;
 		major = be32_to_cpup(p++);
 		minor = be32_to_cpup(p);
 		tmp = MKDEV(major, minor);
@@ -4077,9 +3982,6 @@ static int decode_attr_rdev(struct xdr_stream *xdr, uint32_t *bitmap, dev_t *rde
 	}
 	dprintk("%s: rdev=(0x%x:0x%x)\n", __func__, major, minor);
 	return ret;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_attr_space_avail(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t *res)
@@ -4093,15 +3995,12 @@ static int decode_attr_space_avail(struct xdr_stream *xdr, uint32_t *bitmap, uin
 	if (likely(bitmap[1] & FATTR4_WORD1_SPACE_AVAIL)) {
 		p = xdr_inline_decode(xdr, 8);
 		if (unlikely(!p))
-			goto out_overflow;
+			return -EIO;
 		xdr_decode_hyper(p, res);
 		bitmap[1] &= ~FATTR4_WORD1_SPACE_AVAIL;
 	}
 	dprintk("%s: space avail=%Lu\n", __func__, (unsigned long long)*res);
 	return status;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_attr_space_free(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t *res)
@@ -4115,15 +4014,12 @@ static int decode_attr_space_free(struct xdr_stream *xdr, uint32_t *bitmap, uint
 	if (likely(bitmap[1] & FATTR4_WORD1_SPACE_FREE)) {
 		p = xdr_inline_decode(xdr, 8);
 		if (unlikely(!p))
-			goto out_overflow;
+			return -EIO;
 		xdr_decode_hyper(p, res);
 		bitmap[1] &= ~FATTR4_WORD1_SPACE_FREE;
 	}
 	dprintk("%s: space free=%Lu\n", __func__, (unsigned long long)*res);
 	return status;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_attr_space_total(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t *res)
@@ -4137,15 +4033,12 @@ static int decode_attr_space_total(struct xdr_stream *xdr, uint32_t *bitmap, uin
 	if (likely(bitmap[1] & FATTR4_WORD1_SPACE_TOTAL)) {
 		p = xdr_inline_decode(xdr, 8);
 		if (unlikely(!p))
-			goto out_overflow;
+			return -EIO;
 		xdr_decode_hyper(p, res);
 		bitmap[1] &= ~FATTR4_WORD1_SPACE_TOTAL;
 	}
 	dprintk("%s: space total=%Lu\n", __func__, (unsigned long long)*res);
 	return status;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_attr_space_used(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t *used)
@@ -4159,7 +4052,7 @@ static int decode_attr_space_used(struct xdr_stream *xdr, uint32_t *bitmap, uint
 	if (likely(bitmap[1] & FATTR4_WORD1_SPACE_USED)) {
 		p = xdr_inline_decode(xdr, 8);
 		if (unlikely(!p))
-			goto out_overflow;
+			return -EIO;
 		xdr_decode_hyper(p, used);
 		bitmap[1] &= ~FATTR4_WORD1_SPACE_USED;
 		ret = NFS_ATTR_FATTR_SPACE_USED;
@@ -4167,9 +4060,6 @@ static int decode_attr_space_used(struct xdr_stream *xdr, uint32_t *bitmap, uint
 	dprintk("%s: space used=%Lu\n", __func__,
 			(unsigned long long)*used);
 	return ret;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static __be32 *
@@ -4189,12 +4079,9 @@ static int decode_attr_time(struct xdr_stream *xdr, struct timespec *time)
 
 	p = xdr_inline_decode(xdr, nfstime4_maxsz << 2);
 	if (unlikely(!p))
-		goto out_overflow;
+		return -EIO;
 	xdr_decode_nfstime4(p, time);
 	return 0;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_attr_time_access(struct xdr_stream *xdr, uint32_t *bitmap, struct timespec *time)
@@ -4265,19 +4152,19 @@ static int decode_attr_security_label(struct xdr_stream *xdr, uint32_t *bitmap,
 	if (likely(bitmap[2] & FATTR4_WORD2_SECURITY_LABEL)) {
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
-			goto out_overflow;
+			return -EIO;
 		lfs = be32_to_cpup(p++);
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
-			goto out_overflow;
+			return -EIO;
 		pi = be32_to_cpup(p++);
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
-			goto out_overflow;
+			return -EIO;
 		len = be32_to_cpup(p++);
 		p = xdr_inline_decode(xdr, len);
 		if (unlikely(!p))
-			goto out_overflow;
+			return -EIO;
 		if (len < NFS4_MAXLABELLEN) {
 			if (label) {
 				memcpy(label->label, p, len);
@@ -4295,10 +4182,6 @@ static int decode_attr_security_label(struct xdr_stream *xdr, uint32_t *bitmap,
 		dprintk("%s: label=%s, len=%d, PI=%d, LFS=%d\n", __func__,
 			(char *)label->label, label->len, label->pi, label->lfs);
 	return status;
-
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_attr_time_modify(struct xdr_stream *xdr, uint32_t *bitmap, struct timespec *time)
@@ -4342,14 +4225,11 @@ static int decode_change_info(struct xdr_stream *xdr, struct nfs4_change_info *c
 
 	p = xdr_inline_decode(xdr, 20);
 	if (unlikely(!p))
-		goto out_overflow;
+		return -EIO;
 	cinfo->atomic = be32_to_cpup(p++);
 	p = xdr_decode_hyper(p, &cinfo->before);
 	xdr_decode_hyper(p, &cinfo->after);
 	return 0;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_access(struct xdr_stream *xdr, u32 *supported, u32 *access)
@@ -4363,24 +4243,19 @@ static int decode_access(struct xdr_stream *xdr, u32 *supported, u32 *access)
 		return status;
 	p = xdr_inline_decode(xdr, 8);
 	if (unlikely(!p))
-		goto out_overflow;
+		return -EIO;
 	supp = be32_to_cpup(p++);
 	acc = be32_to_cpup(p);
 	*supported = supp;
 	*access = acc;
 	return 0;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_opaque_fixed(struct xdr_stream *xdr, void *buf, size_t len)
 {
 	ssize_t ret = xdr_stream_decode_opaque_fixed(xdr, buf, len);
-	if (unlikely(ret < 0)) {
-		print_overflow_msg(__func__, xdr);
+	if (unlikely(ret < 0))
 		return -EIO;
-	}
 	return 0;
 }
 
@@ -4460,13 +4335,11 @@ static int decode_create(struct xdr_stream *xdr, struct nfs4_change_info *cinfo)
 		return status;
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
-		goto out_overflow;
+		return -EIO;
 	bmlen = be32_to_cpup(p);
 	p = xdr_inline_decode(xdr, bmlen << 2);
 	if (likely(p))
 		return 0;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
 	return -EIO;
 }
 
@@ -4574,13 +4447,10 @@ static int decode_threshold_hint(struct xdr_stream *xdr,
 	if (likely(bitmap[0] & hint_bit)) {
 		p = xdr_inline_decode(xdr, 8);
 		if (unlikely(!p))
-			goto out_overflow;
+			return -EIO;
 		xdr_decode_hyper(p, res);
 	}
 	return 0;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_first_threshold_item4(struct xdr_stream *xdr,
@@ -4593,10 +4463,8 @@ static int decode_first_threshold_item4(struct xdr_stream *xdr,
 
 	/* layout type */
 	p = xdr_inline_decode(xdr, 4);
-	if (unlikely(!p)) {
-		print_overflow_msg(__func__, xdr);
+	if (unlikely(!p))
 		return -EIO;
-	}
 	res->l_type = be32_to_cpup(p);
 
 	/* thi_hintset bitmap */
@@ -4654,7 +4522,7 @@ static int decode_attr_mdsthreshold(struct xdr_stream *xdr,
 			return -EREMOTEIO;
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
-			goto out_overflow;
+			return -EIO;
 		num = be32_to_cpup(p);
 		if (num == 0)
 			return 0;
@@ -4667,9 +4535,6 @@ static int decode_attr_mdsthreshold(struct xdr_stream *xdr,
 		bitmap[2] &= ~FATTR4_WORD2_MDSTHRESHOLD;
 	}
 	return status;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_getfattr_attrs(struct xdr_stream *xdr, uint32_t *bitmap,
@@ -4857,7 +4722,7 @@ static int decode_pnfs_layout_types(struct xdr_stream *xdr,
 
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
-		goto out_overflow;
+		return -EIO;
 	fsinfo->nlayouttypes = be32_to_cpup(p);
 
 	/* pNFS is not supported by the underlying file system */
@@ -4867,7 +4732,7 @@ static int decode_pnfs_layout_types(struct xdr_stream *xdr,
 	/* Decode and set first layout type, move xdr->p past unused types */
 	p = xdr_inline_decode(xdr, fsinfo->nlayouttypes * 4);
 	if (unlikely(!p))
-		goto out_overflow;
+		return -EIO;
 
 	/* If we get too many, then just cap it at the max */
 	if (fsinfo->nlayouttypes > NFS_MAX_LAYOUT_TYPES) {
@@ -4879,9 +4744,6 @@ static int decode_pnfs_layout_types(struct xdr_stream *xdr,
 	for(i = 0; i < fsinfo->nlayouttypes; ++i)
 		fsinfo->layouttype[i] = be32_to_cpup(p++);
 	return 0;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 /*
@@ -4915,10 +4777,8 @@ static int decode_attr_layout_blksize(struct xdr_stream *xdr, uint32_t *bitmap,
 	*res = 0;
 	if (bitmap[2] & FATTR4_WORD2_LAYOUT_BLKSIZE) {
 		p = xdr_inline_decode(xdr, 4);
-		if (unlikely(!p)) {
-			print_overflow_msg(__func__, xdr);
+		if (unlikely(!p))
 			return -EIO;
-		}
 		*res = be32_to_cpup(p);
 		bitmap[2] &= ~FATTR4_WORD2_LAYOUT_BLKSIZE;
 	}
@@ -4937,10 +4797,8 @@ static int decode_attr_clone_blksize(struct xdr_stream *xdr, uint32_t *bitmap,
 	*res = 0;
 	if (bitmap[2] & FATTR4_WORD2_CLONE_BLKSIZE) {
 		p = xdr_inline_decode(xdr, 4);
-		if (unlikely(!p)) {
-			print_overflow_msg(__func__, xdr);
+		if (unlikely(!p))
 			return -EIO;
-		}
 		*res = be32_to_cpup(p);
 		bitmap[2] &= ~FATTR4_WORD2_CLONE_BLKSIZE;
 	}
@@ -5016,19 +4874,16 @@ static int decode_getfh(struct xdr_stream *xdr, struct nfs_fh *fh)
 
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
-		goto out_overflow;
+		return -EIO;
 	len = be32_to_cpup(p);
 	if (len > NFS4_FHSIZE)
 		return -EIO;
 	fh->size = len;
 	p = xdr_inline_decode(xdr, len);
 	if (unlikely(!p))
-		goto out_overflow;
+		return -EIO;
 	memcpy(fh->data, p, len);
 	return 0;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_link(struct xdr_stream *xdr, struct nfs4_change_info *cinfo)
@@ -5052,7 +4907,7 @@ static int decode_lock_denied (struct xdr_stream *xdr, struct file_lock *fl)
 
 	p = xdr_inline_decode(xdr, 32); /* read 32 bytes */
 	if (unlikely(!p))
-		goto out_overflow;
+		return -EIO;
 	p = xdr_decode_hyper(p, &offset); /* read 2 8-byte long words */
 	p = xdr_decode_hyper(p, &length);
 	type = be32_to_cpup(p++); /* 4 byte read */
@@ -5069,11 +4924,9 @@ static int decode_lock_denied (struct xdr_stream *xdr, struct file_lock *fl)
 	p = xdr_decode_hyper(p, &clientid); /* read 8 bytes */
 	namelen = be32_to_cpup(p); /* read 4 bytes */  /* have read all 32 bytes now */
 	p = xdr_inline_decode(xdr, namelen); /* variable size field */
-	if (likely(p))
-		return -NFS4ERR_DENIED;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
+	if (likely(!p))
+		return -EIO;
+	return -NFS4ERR_DENIED;
 }
 
 static int decode_lock(struct xdr_stream *xdr, struct nfs_lock_res *res)
@@ -5142,7 +4995,7 @@ static int decode_space_limit(struct xdr_stream *xdr,
 
 	p = xdr_inline_decode(xdr, 12);
 	if (unlikely(!p))
-		goto out_overflow;
+		return -EIO;
 	limit_type = be32_to_cpup(p++);
 	switch (limit_type) {
 	case NFS4_LIMIT_SIZE:
@@ -5156,9 +5009,6 @@ static int decode_space_limit(struct xdr_stream *xdr,
 	maxsize >>= PAGE_SHIFT;
 	*pagemod_limit = min_t(u64, maxsize, ULONG_MAX);
 	return 0;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_rw_delegation(struct xdr_stream *xdr,
@@ -5173,7 +5023,7 @@ static int decode_rw_delegation(struct xdr_stream *xdr,
 		return status;
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
-		goto out_overflow;
+		return -EIO;
 	res->do_recall = be32_to_cpup(p);
 
 	switch (delegation_type) {
@@ -5186,9 +5036,6 @@ static int decode_rw_delegation(struct xdr_stream *xdr,
 				return -EIO;
 	}
 	return decode_ace(xdr, NULL);
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_no_delegation(struct xdr_stream *xdr, struct nfs_openres *res)
@@ -5198,7 +5045,7 @@ static int decode_no_delegation(struct xdr_stream *xdr, struct nfs_openres *res)
 
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
-		goto out_overflow;
+		return -EIO;
 	why_no_delegation = be32_to_cpup(p);
 	switch (why_no_delegation) {
 		case WND4_CONTENTION:
@@ -5207,9 +5054,6 @@ static int decode_no_delegation(struct xdr_stream *xdr, struct nfs_openres *res)
 			/* Ignore for now */
 	}
 	return 0;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_delegation(struct xdr_stream *xdr, struct nfs_openres *res)
@@ -5219,7 +5063,7 @@ static int decode_delegation(struct xdr_stream *xdr, struct nfs_openres *res)
 
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
-		goto out_overflow;
+		return -EIO;
 	delegation_type = be32_to_cpup(p);
 	res->delegation_type = 0;
 	switch (delegation_type) {
@@ -5232,9 +5076,6 @@ static int decode_delegation(struct xdr_stream *xdr, struct nfs_openres *res)
 		return decode_no_delegation(xdr, res);
 	}
 	return -EIO;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_open(struct xdr_stream *xdr, struct nfs_openres *res)
@@ -5256,7 +5097,7 @@ static int decode_open(struct xdr_stream *xdr, struct nfs_openres *res)
 
 	p = xdr_inline_decode(xdr, 8);
 	if (unlikely(!p))
-		goto out_overflow;
+		return -EIO;
 	res->rflags = be32_to_cpup(p++);
 	bmlen = be32_to_cpup(p);
 	if (bmlen > 10)
@@ -5264,7 +5105,7 @@ static int decode_open(struct xdr_stream *xdr, struct nfs_openres *res)
 
 	p = xdr_inline_decode(xdr, bmlen << 2);
 	if (unlikely(!p))
-		goto out_overflow;
+		return -EIO;
 	savewords = min_t(uint32_t, bmlen, NFS4_BITMAP_SIZE);
 	for (i = 0; i < savewords; ++i)
 		res->attrset[i] = be32_to_cpup(p++);
@@ -5275,9 +5116,6 @@ static int decode_open(struct xdr_stream *xdr, struct nfs_openres *res)
 xdr_error:
 	dprintk("%s: Bitmap too large! Length = %u\n", __func__, bmlen);
 	return -EIO;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_open_confirm(struct xdr_stream *xdr, struct nfs_open_confirmres *res)
@@ -5326,7 +5164,7 @@ static int decode_read(struct xdr_stream *xdr, struct rpc_rqst *req,
 		return status;
 	p = xdr_inline_decode(xdr, 8);
 	if (unlikely(!p))
-		goto out_overflow;
+		return -EIO;
 	eof = be32_to_cpup(p++);
 	count = be32_to_cpup(p);
 	recvd = xdr_read_pages(xdr, count);
@@ -5339,9 +5177,6 @@ static int decode_read(struct xdr_stream *xdr, struct rpc_rqst *req,
 	res->eof = eof;
 	res->count = count;
 	return 0;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_readdir(struct xdr_stream *xdr, struct rpc_rqst *req, struct nfs4_readdir_res *readdir)
@@ -5374,7 +5209,7 @@ static int decode_readlink(struct xdr_stream *xdr, struct rpc_rqst *req)
 	/* Convert length of symlink */
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
-		goto out_overflow;
+		return -EIO;
 	len = be32_to_cpup(p);
 	if (len >= rcvbuf->page_len || len <= 0) {
 		dprintk("nfs: server returned giant symlink!\n");
@@ -5395,9 +5230,6 @@ static int decode_readlink(struct xdr_stream *xdr, struct rpc_rqst *req)
 	 */
 	xdr_terminate_string(rcvbuf, len);
 	return 0;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_remove(struct xdr_stream *xdr, struct nfs4_change_info *cinfo)
@@ -5500,7 +5332,6 @@ static int decode_setattr(struct xdr_stream *xdr)
 		return status;
 	if (decode_bitmap4(xdr, NULL, 0) >= 0)
 		return 0;
-	print_overflow_msg(__func__, xdr);
 	return -EIO;
 }
 
@@ -5512,7 +5343,7 @@ static int decode_setclientid(struct xdr_stream *xdr, struct nfs4_setclientid_re
 
 	p = xdr_inline_decode(xdr, 8);
 	if (unlikely(!p))
-		goto out_overflow;
+		return -EIO;
 	opnum = be32_to_cpup(p++);
 	if (opnum != OP_SETCLIENTID) {
 		dprintk("nfs: decode_setclientid: Server returned operation"
@@ -5523,7 +5354,7 @@ static int decode_setclientid(struct xdr_stream *xdr, struct nfs4_setclientid_re
 	if (nfserr == NFS_OK) {
 		p = xdr_inline_decode(xdr, 8 + NFS4_VERIFIER_SIZE);
 		if (unlikely(!p))
-			goto out_overflow;
+			return -EIO;
 		p = xdr_decode_hyper(p, &res->clientid);
 		memcpy(res->confirm.data, p, NFS4_VERIFIER_SIZE);
 	} else if (nfserr == NFSERR_CLID_INUSE) {
@@ -5532,28 +5363,25 @@ static int decode_setclientid(struct xdr_stream *xdr, struct nfs4_setclientid_re
 		/* skip netid string */
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
-			goto out_overflow;
+			return -EIO;
 		len = be32_to_cpup(p);
 		p = xdr_inline_decode(xdr, len);
 		if (unlikely(!p))
-			goto out_overflow;
+			return -EIO;
 
 		/* skip uaddr string */
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
-			goto out_overflow;
+			return -EIO;
 		len = be32_to_cpup(p);
 		p = xdr_inline_decode(xdr, len);
 		if (unlikely(!p))
-			goto out_overflow;
+			return -EIO;
 		return -NFSERR_CLID_INUSE;
 	} else
 		return nfs4_stat_to_errno(nfserr);
 
 	return 0;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_setclientid_confirm(struct xdr_stream *xdr)
@@ -5572,13 +5400,10 @@ static int decode_write(struct xdr_stream *xdr, struct nfs_pgio_res *res)
 
 	p = xdr_inline_decode(xdr, 8);
 	if (unlikely(!p))
-		goto out_overflow;
+		return -EIO;
 	res->count = be32_to_cpup(p++);
 	res->verf->committed = be32_to_cpup(p++);
 	return decode_write_verifier(xdr, &res->verf->verifier);
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_delegreturn(struct xdr_stream *xdr)
@@ -5594,30 +5419,24 @@ static int decode_secinfo_gss(struct xdr_stream *xdr,
 
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
-		goto out_overflow;
+		return -EIO;
 	oid_len = be32_to_cpup(p);
 	if (oid_len > GSS_OID_MAX_LEN)
-		goto out_err;
+		return -EINVAL;
 
 	p = xdr_inline_decode(xdr, oid_len);
 	if (unlikely(!p))
-		goto out_overflow;
+		return -EIO;
 	memcpy(flavor->flavor_info.oid.data, p, oid_len);
 	flavor->flavor_info.oid.len = oid_len;
 
 	p = xdr_inline_decode(xdr, 8);
 	if (unlikely(!p))
-		goto out_overflow;
+		return -EIO;
 	flavor->flavor_info.qop = be32_to_cpup(p++);
 	flavor->flavor_info.service = be32_to_cpup(p);
 
 	return 0;
-
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
-out_err:
-	return -EINVAL;
 }
 
 static int decode_secinfo_common(struct xdr_stream *xdr, struct nfs4_secinfo_res *res)
@@ -5629,7 +5448,7 @@ static int decode_secinfo_common(struct xdr_stream *xdr, struct nfs4_secinfo_res
 
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
-		goto out_overflow;
+		return -EIO;
 
 	res->flavors->num_flavors = 0;
 	num_flavors = be32_to_cpup(p);
@@ -5641,7 +5460,7 @@ static int decode_secinfo_common(struct xdr_stream *xdr, struct nfs4_secinfo_res
 
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
-			goto out_overflow;
+			return -EIO;
 		sec_flavor->flavor = be32_to_cpup(p);
 
 		if (sec_flavor->flavor == RPC_AUTH_GSS) {
@@ -5655,9 +5474,6 @@ static int decode_secinfo_common(struct xdr_stream *xdr, struct nfs4_secinfo_res
 	status = 0;
 out:
 	return status;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_secinfo(struct xdr_stream *xdr, struct nfs4_secinfo_res *res)
@@ -5711,11 +5527,11 @@ static int decode_exchange_id(struct xdr_stream *xdr,
 
 	p = xdr_inline_decode(xdr, 8);
 	if (unlikely(!p))
-		goto out_overflow;
+		return -EIO;
 	xdr_decode_hyper(p, &res->clientid);
 	p = xdr_inline_decode(xdr, 12);
 	if (unlikely(!p))
-		goto out_overflow;
+		return -EIO;
 	res->seqid = be32_to_cpup(p++);
 	res->flags = be32_to_cpup(p++);
 
@@ -5739,7 +5555,7 @@ static int decode_exchange_id(struct xdr_stream *xdr,
 	/* server_owner4.so_minor_id */
 	p = xdr_inline_decode(xdr, 8);
 	if (unlikely(!p))
-		goto out_overflow;
+		return -EIO;
 	p = xdr_decode_hyper(p, &res->server_owner->minor_id);
 
 	/* server_owner4.so_major_id */
@@ -5759,7 +5575,7 @@ static int decode_exchange_id(struct xdr_stream *xdr,
 	/* Implementation Id */
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
-		goto out_overflow;
+		return -EIO;
 	impl_id_count = be32_to_cpup(p++);
 
 	if (impl_id_count) {
@@ -5778,16 +5594,13 @@ static int decode_exchange_id(struct xdr_stream *xdr,
 		/* nii_date */
 		p = xdr_inline_decode(xdr, 12);
 		if (unlikely(!p))
-			goto out_overflow;
+			return -EIO;
 		p = xdr_decode_hyper(p, &res->impl_id->date.seconds);
 		res->impl_id->date.nseconds = be32_to_cpup(p);
 
 		/* if there's more than one entry, ignore the rest */
 	}
 	return 0;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_chan_attrs(struct xdr_stream *xdr,
@@ -5798,7 +5611,7 @@ static int decode_chan_attrs(struct xdr_stream *xdr,
 
 	p = xdr_inline_decode(xdr, 28);
 	if (unlikely(!p))
-		goto out_overflow;
+		return -EIO;
 	val = be32_to_cpup(p++);	/* headerpadsz */
 	if (val)
 		return -EINVAL;		/* no support for header padding yet */
@@ -5816,12 +5629,9 @@ static int decode_chan_attrs(struct xdr_stream *xdr,
 	if (nr_attrs == 1) {
 		p = xdr_inline_decode(xdr, 4); /* skip rdma_attrs */
 		if (unlikely(!p))
-			goto out_overflow;
+			return -EIO;
 	}
 	return 0;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_sessionid(struct xdr_stream *xdr, struct nfs4_sessionid *sid)
@@ -5844,7 +5654,7 @@ static int decode_bind_conn_to_session(struct xdr_stream *xdr,
 	/* dir flags, rdma mode bool */
 	p = xdr_inline_decode(xdr, 8);
 	if (unlikely(!p))
-		goto out_overflow;
+		return -EIO;
 
 	res->dir = be32_to_cpup(p++);
 	if (res->dir == 0 || res->dir > NFS4_CDFS4_BOTH)
@@ -5855,9 +5665,6 @@ static int decode_bind_conn_to_session(struct xdr_stream *xdr,
 		res->use_conn_in_rdma_mode = true;
 
 	return 0;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_create_session(struct xdr_stream *xdr,
@@ -5875,7 +5682,7 @@ static int decode_create_session(struct xdr_stream *xdr,
 	/* seqid, flags */
 	p = xdr_inline_decode(xdr, 8);
 	if (unlikely(!p))
-		goto out_overflow;
+		return -EIO;
 	res->seqid = be32_to_cpup(p++);
 	res->flags = be32_to_cpup(p);
 
@@ -5884,9 +5691,6 @@ static int decode_create_session(struct xdr_stream *xdr,
 	if (!status)
 		status = decode_chan_attrs(xdr, &res->bc_attrs);
 	return status;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_destroy_session(struct xdr_stream *xdr, void *dummy)
@@ -5967,7 +5771,6 @@ static int decode_sequence(struct xdr_stream *xdr,
 	res->sr_status = status;
 	return status;
 out_overflow:
-	print_overflow_msg(__func__, xdr);
 	status = -EIO;
 	goto out_err;
 #else  /* CONFIG_NFS_V4_1 */
@@ -5995,7 +5798,7 @@ static int decode_getdeviceinfo(struct xdr_stream *xdr,
 		if (status == -ETOOSMALL) {
 			p = xdr_inline_decode(xdr, 4);
 			if (unlikely(!p))
-				goto out_overflow;
+				return -EIO;
 			pdev->mincount = be32_to_cpup(p);
 			dprintk("%s: Min count too small. mincnt = %u\n",
 				__func__, pdev->mincount);
@@ -6005,7 +5808,7 @@ static int decode_getdeviceinfo(struct xdr_stream *xdr,
 
 	p = xdr_inline_decode(xdr, 8);
 	if (unlikely(!p))
-		goto out_overflow;
+		return -EIO;
 	type = be32_to_cpup(p++);
 	if (type != pdev->layout_type) {
 		dprintk("%s: layout mismatch req: %u pdev: %u\n",
@@ -6019,19 +5822,19 @@ static int decode_getdeviceinfo(struct xdr_stream *xdr,
 	 */
 	pdev->mincount = be32_to_cpup(p);
 	if (xdr_read_pages(xdr, pdev->mincount) != pdev->mincount)
-		goto out_overflow;
+		return -EIO;
 
 	/* Parse notification bitmap, verifying that it is zero. */
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
-		goto out_overflow;
+		return -EIO;
 	len = be32_to_cpup(p);
 	if (len) {
 		uint32_t i;
 
 		p = xdr_inline_decode(xdr, 4 * len);
 		if (unlikely(!p))
-			goto out_overflow;
+			return -EIO;
 
 		res->notification = be32_to_cpup(p++);
 		for (i = 1; i < len; i++) {
@@ -6043,9 +5846,6 @@ static int decode_getdeviceinfo(struct xdr_stream *xdr,
 		}
 	}
 	return 0;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_layoutget(struct xdr_stream *xdr, struct rpc_rqst *req,
@@ -6115,7 +5915,6 @@ static int decode_layoutget(struct xdr_stream *xdr, struct rpc_rqst *req,
 	res->status = status;
 	return status;
 out_overflow:
-	print_overflow_msg(__func__, xdr);
 	status = -EIO;
 	goto out;
 }
@@ -6131,16 +5930,13 @@ static int decode_layoutreturn(struct xdr_stream *xdr,
 		return status;
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
-		goto out_overflow;
+		return -EIO;
 	res->lrs_present = be32_to_cpup(p);
 	if (res->lrs_present)
 		status = decode_layout_stateid(xdr, &res->stateid);
 	else
 		nfs4_stateid_copy(&res->stateid, &invalid_stateid);
 	return status;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_layoutcommit(struct xdr_stream *xdr,
@@ -6158,19 +5954,16 @@ static int decode_layoutcommit(struct xdr_stream *xdr,
 
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
-		goto out_overflow;
+		return -EIO;
 	sizechanged = be32_to_cpup(p);
 
 	if (sizechanged) {
 		/* throw away new size */
 		p = xdr_inline_decode(xdr, 8);
 		if (unlikely(!p))
-			goto out_overflow;
+			return -EIO;
 	}
 	return 0;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_test_stateid(struct xdr_stream *xdr,
@@ -6186,21 +5979,17 @@ static int decode_test_stateid(struct xdr_stream *xdr,
 
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
-		goto out_overflow;
+		return -EIO;
 	num_res = be32_to_cpup(p++);
 	if (num_res != 1)
-		goto out;
+		return -EIO;
 
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
-		goto out_overflow;
+		return -EIO;
 	res->status = be32_to_cpup(p++);
 
 	return status;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-out:
-	return -EIO;
 }
 
 static int decode_free_stateid(struct xdr_stream *xdr,
@@ -7570,11 +7359,11 @@ int nfs4_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
 	uint64_t new_cookie;
 	__be32 *p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
-		goto out_overflow;
+		return -EAGAIN;
 	if (*p == xdr_zero) {
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
-			goto out_overflow;
+			return -EAGAIN;
 		if (*p == xdr_zero)
 			return -EAGAIN;
 		entry->eof = 1;
@@ -7583,13 +7372,13 @@ int nfs4_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
 
 	p = xdr_inline_decode(xdr, 12);
 	if (unlikely(!p))
-		goto out_overflow;
+		return -EAGAIN;
 	p = xdr_decode_hyper(p, &new_cookie);
 	entry->len = be32_to_cpup(p);
 
 	p = xdr_inline_decode(xdr, entry->len);
 	if (unlikely(!p))
-		goto out_overflow;
+		return -EAGAIN;
 	entry->name = (const char *) p;
 
 	/*
@@ -7601,14 +7390,14 @@ int nfs4_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
 	entry->fattr->valid = 0;
 
 	if (decode_attr_bitmap(xdr, bitmap) < 0)
-		goto out_overflow;
+		return -EAGAIN;
 
 	if (decode_attr_length(xdr, &len, &savep) < 0)
-		goto out_overflow;
+		return -EAGAIN;
 
 	if (decode_getfattr_attrs(xdr, bitmap, entry->fattr, entry->fh,
 			NULL, entry->label, entry->server) < 0)
-		goto out_overflow;
+		return -EAGAIN;
 	if (entry->fattr->valid & NFS_ATTR_FATTR_MOUNTED_ON_FILEID)
 		entry->ino = entry->fattr->mounted_on_fileid;
 	else if (entry->fattr->valid & NFS_ATTR_FATTR_FILEID)
@@ -7622,10 +7411,6 @@ int nfs4_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
 	entry->cookie = new_cookie;
 
 	return 0;
-
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EAGAIN;
 }
 
 /*
diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index c74e453..a9d24d5 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -60,16 +60,6 @@ struct nfs4_cb_compound_hdr {
 	int		status;
 };
 
-/*
- * Handle decode buffer overflows out-of-line.
- */
-static void print_overflow_msg(const char *func, const struct xdr_stream *xdr)
-{
-	dprintk("NFS: %s prematurely hit the end of our receive buffer. "
-		"Remaining buffer length is %tu words.\n",
-		func, xdr->end - xdr->p);
-}
-
 static __be32 *xdr_encode_empty_array(__be32 *p)
 {
 	*p++ = xdr_zero;
@@ -240,7 +230,6 @@ static int decode_cb_op_status(struct xdr_stream *xdr,
 	*status = nfs_cb_stat_to_errno(be32_to_cpup(p));
 	return 0;
 out_overflow:
-	print_overflow_msg(__func__, xdr);
 	return -EIO;
 out_unexpected:
 	dprintk("NFSD: Callback server returned operation %d but "
@@ -309,7 +298,6 @@ static int decode_cb_compound4res(struct xdr_stream *xdr,
 	hdr->nops = be32_to_cpup(p);
 	return 0;
 out_overflow:
-	print_overflow_msg(__func__, xdr);
 	return -EIO;
 }
 
@@ -437,7 +425,6 @@ static int decode_cb_sequence4resok(struct xdr_stream *xdr,
 	cb->cb_seq_status = status;
 	return status;
 out_overflow:
-	print_overflow_msg(__func__, xdr);
 	status = -EIO;
 	goto out;
 }


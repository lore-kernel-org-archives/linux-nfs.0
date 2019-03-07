Return-Path: <SRS0=nj1J=RK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A217C10F0D
	for <linux-nfs@archiver.kernel.org>; Thu,  7 Mar 2019 15:29:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3ADC820851
	for <linux-nfs@archiver.kernel.org>; Thu,  7 Mar 2019 15:29:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="eEcbH0U+"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726652AbfCGP3J (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 7 Mar 2019 10:29:09 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:36176 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726637AbfCGP3I (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Mar 2019 10:29:08 -0500
Received: by mail-it1-f196.google.com with SMTP id v83so16397228itf.1;
        Thu, 07 Mar 2019 07:29:07 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=o2UQ2h9kFQ9mi1tvZ+VBQBdugYPoGNKKT7miBcW4OYA=;
        b=eEcbH0U+x/f+z2jftZRgEz3ULU5EmhIq/ZLr5dFXhid5UeHkGOiCGoMs76SrKgnBA5
         72Fwmm86mgnS4eyn5qiiuPrJO0MpBE7qTotvY0NMzUQBcWve6+aYhquJzZzkRXFxKwDm
         Izuw/wNTgV8u53wrqrz59xmbVggXP516KmBUFJYoMpFVnpyKd4Bnl8ewXSuts0PGdAhz
         46c3gVKeyx50Gup7oaJReH1wI+ATWf0YIlogCfk4VuYgwiTQBjP8uPYW/2FTeehnfIZG
         MdhmwWYXDBGQ0niTsSn+9Z4icEuMo0OQK52YxRx1n06i1WXivUg1pS1BsVUcr0BTRqsw
         4+BA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=o2UQ2h9kFQ9mi1tvZ+VBQBdugYPoGNKKT7miBcW4OYA=;
        b=bLLTQ9CqwA3sXzDyJPszmtZUADqkL2/o2qSRIoXnw9UcVKbXyPFI2V6r88Hrg4QSNF
         OF4g9/kZ4XvS4w/edQfDGwrZbq6tmlqC3MQ2Zn1qSrQdx/9f1srSUyzOUx8dkeZAVnSB
         hcBsZ7NQRjW9iJDS8yX9acP1QlcDy9C4kM0Hr8TByCOSYQZKU/1ckP1gw4XBc96MheUV
         bh+yIhCRy64RNsotbPbVUOzNR19tFuetTQavX63wl4EIbYC7jbqjoxGbXHjXLtvtafO3
         FaBWGSLtkbJrxuOd0JrO23DYT1KO7TcP3X1KK0CU2EcKlbJwWqnic2ylqVftedT4PI1c
         lerg==
X-Gm-Message-State: APjAAAWPZjj8FsbrvEmHJzFUIeAFP2XPN6Kiqy1HuM/lkMg08Mj9GrH2
        FqQxy4OgaXPXIxPIVHw5pulKV7j/
X-Google-Smtp-Source: APXvYqyJftW2aVaRwJNFMd04hzhGJY5EnLJ17BxHSA5l71VRKgJ4JvwH/i9J/yvw+1g5bGjLWhB/CQ==
X-Received: by 2002:a02:ac81:: with SMTP id x1mr8124363jan.31.1551972546074;
        Thu, 07 Mar 2019 07:29:06 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id 7sm2014905iow.58.2019.03.07.07.29.05
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 07:29:05 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x27FT4eo007230;
        Thu, 7 Mar 2019 15:29:04 GMT
Subject: [PATCH v2 5/5] NFS: Prototype support for IMA on NFS (client)
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org, linux-integrity@vger.kernel.org
Date:   Thu, 07 Mar 2019 10:29:04 -0500
Message-ID: <20190307152904.11306.22101.stgit@manet.1015granger.net>
In-Reply-To: <20190307151838.11306.94183.stgit@manet.1015granger.net>
References: <20190307151838.11306.94183.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

When NFSv4 Security Label support is enabled and kernel Integrity
and IMA support is enabled (via CONFIG), then build in code to
handle the "security.ima" xattr. The NFS client converts this to
a particular FATTR4 bit which can be handled on the wire via a
standard NFSv4 GETATTR or SETATTR operation.

The new FATTR4 bit is made up; meaning we still have to go through a
standards process to allocate a bit that all NFS vendors agree on.
Thus there is no guarantee this prototype will interoperate with
others or with a future standards-based implementation.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4_fs.h          |    1 
 fs/nfs/nfs4proc.c         |  111 ++++++++++++++++++++++++++-
 fs/nfs/nfs4xdr.c          |  186 +++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfs4.h      |    3 +
 include/linux/nfs_fs_sb.h |    1 
 include/linux/nfs_xdr.h   |   21 +++++
 6 files changed, 321 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 06ac3d9a..795f2f5 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -424,6 +424,7 @@ extern int nfs4_detect_session_trunking(struct nfs_client *clp,
 extern const u32 nfs4_pathconf_bitmap[3];
 extern const u32 nfs4_fsinfo_bitmap[3];
 extern const u32 nfs4_fs_locations_bitmap[3];
+extern const u32 nfs4_ima_bitmap[3];
 
 void nfs40_shutdown_client(struct nfs_client *);
 void nfs41_shutdown_client(struct nfs_client *);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index df0ee42..fc4cb55 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -205,6 +205,9 @@ static int nfs4_map_errors(int err)
 	| FATTR4_WORD1_MOUNTED_ON_FILEID,
 #ifdef CONFIG_NFS_V4_SECURITY_LABEL
 	FATTR4_WORD2_SECURITY_LABEL
+#ifdef CONFIG_IMA
+	| FATTR4_WORD2_LINUX_IMA
+#endif
 #endif
 };
 
@@ -275,6 +278,8 @@ static int nfs4_map_errors(int err)
 	| FATTR4_WORD1_MOUNTED_ON_FILEID,
 };
 
+const u32 nfs4_ima_bitmap[3] = { 0, 0, FATTR4_WORD2_LINUX_IMA };
+
 static void nfs4_bitmap_copy_adjust(__u32 *dst, const __u32 *src,
 		struct inode *inode)
 {
@@ -3575,7 +3580,7 @@ static void nfs4_close_context(struct nfs_open_context *ctx, int is_sync)
 
 #define FATTR4_WORD1_NFS40_MASK (2*FATTR4_WORD1_MOUNTED_ON_FILEID - 1UL)
 #define FATTR4_WORD2_NFS41_MASK (2*FATTR4_WORD2_SUPPATTR_EXCLCREAT - 1UL)
-#define FATTR4_WORD2_NFS42_MASK (2*FATTR4_WORD2_MODE_UMASK - 1UL)
+#define FATTR4_WORD2_NFS42_MASK (2*FATTR4_WORD2_LINUX_IMA - 1UL)
 
 static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *fhandle)
 {
@@ -3621,7 +3626,8 @@ static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *f
 				NFS_CAP_MODE|NFS_CAP_NLINK|NFS_CAP_OWNER|
 				NFS_CAP_OWNER_GROUP|NFS_CAP_ATIME|
 				NFS_CAP_CTIME|NFS_CAP_MTIME|
-				NFS_CAP_SECURITY_LABEL);
+				NFS_CAP_SECURITY_LABEL|
+				NFS_CAP_IMA);
 		if (res.attr_bitmask[0] & FATTR4_WORD0_ACL &&
 				res.acl_bitmask & ACL4_SUPPORT_ALLOW_ACL)
 			server->caps |= NFS_CAP_ACLS;
@@ -3648,6 +3654,12 @@ static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *f
 #ifdef CONFIG_NFS_V4_SECURITY_LABEL
 		if (res.attr_bitmask[2] & FATTR4_WORD2_SECURITY_LABEL)
 			server->caps |= NFS_CAP_SECURITY_LABEL;
+#ifdef CONFIG_IMA
+		if (res.attr_bitmask[2] & FATTR4_WORD2_LINUX_IMA) {
+			res.attr_bitmask[2] &= ~FATTR4_WORD2_LINUX_IMA;
+			server->caps |= NFS_CAP_IMA;
+		}
+#endif
 #endif
 		memcpy(server->attr_bitmask_nl, res.attr_bitmask,
 				sizeof(server->attr_bitmask));
@@ -5723,6 +5735,85 @@ static int nfs4_do_set_security_label(struct inode *inode,
 out:
 	return status;
 }
+
+#ifdef CONFIG_IMA
+
+static int _nfs4_get_security_ima(struct inode *inode, void *buf, size_t buflen)
+{
+	struct nfs_server *server = NFS_SERVER(inode);
+	struct nfs4_getima_arg arg = {
+		.fh = NFS_FH(inode),
+		.bitmask = nfs4_ima_bitmap,
+	};
+	struct nfs4_getima_res res = {
+		.data = buf,
+		.len = buflen,
+		.server = server,
+	};
+	struct rpc_message msg = {
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_GETIMA],
+		.rpc_argp = &arg,
+		.rpc_resp = &res,
+	};
+
+	return nfs4_call_sync(server->client, server, &msg, &arg.seq_args,
+			      &res.seq_res, 0);
+}
+
+static int nfs4_get_security_ima(struct inode *inode, void *buf, size_t buflen)
+{
+	struct nfs4_exception exception = {};
+	int err;
+
+	if (!nfs_server_capable(inode, NFS_CAP_IMA))
+		return -EOPNOTSUPP;
+	do {
+		err = _nfs4_get_security_ima(inode, buf, buflen);
+		err = nfs4_handle_exception(NFS_SERVER(inode), err, &exception);
+	} while (exception.retry);
+	return err;
+}
+
+static int _nfs4_set_security_ima(struct inode *inode, const void *buf,
+				  size_t buflen)
+{
+	struct nfs_server *server = NFS_SERVER(inode);
+	struct nfs4_setima_arg arg = {
+		.fh = NFS_FH(inode),
+		.data = buf,
+		.len = buflen,
+	};
+	struct nfs_setattrres res = {
+		.server = server,
+	};
+	struct rpc_message msg = {
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_SETIMA],
+		.rpc_argp = &arg,
+		.rpc_resp = &res,
+	};
+
+	nfs4_stateid_copy(&arg.stateid, &zero_stateid);
+	return nfs4_call_sync(server->client, server, &msg, &arg.seq_args,
+			      &res.seq_res, 1);
+}
+
+static int nfs4_set_security_ima(struct inode *inode, const void *buf,
+				 size_t buflen)
+{
+	struct nfs4_exception exception = {};
+	int err;
+
+	if (!nfs_server_capable(inode, NFS_CAP_IMA))
+		return -EOPNOTSUPP;
+	do {
+		err = _nfs4_set_security_ima(inode, buf, buflen);
+		err = nfs4_handle_exception(NFS_SERVER(inode), err, &exception);
+	} while (exception.retry);
+	return err;
+}
+
+#endif /* CONFIG_IMA */
+
 #endif	/* CONFIG_NFS_V4_SECURITY_LABEL */
 
 
@@ -7128,11 +7219,23 @@ static bool nfs4_xattr_list_nfs4_acl(struct dentry *dentry)
 
 #ifdef CONFIG_NFS_V4_SECURITY_LABEL
 
+#ifdef CONFIG_IMA
+/* XXX: security/ does not seem to provide this helper */
+static bool nfs4_security_isima(const char *name)
+{
+	return (strcmp(name, XATTR_IMA_SUFFIX) == 0);
+}
+#endif /* CONFIG_IMA */
+
 static int nfs4_xattr_set_security(const struct xattr_handler *handler,
 				   struct dentry *unused, struct inode *inode,
 				   const char *key, const void *buf,
 				   size_t buflen, int flags)
 {
+#ifdef CONFIG_IMA
+	if (nfs4_security_isima(key))
+		return nfs4_set_security_ima(inode, buf, buflen);
+#endif /* CONFIG_IMA */
 	if (security_ismaclabel(key))
 		return nfs4_set_security_label(inode, buf, buflen);
 	return -EOPNOTSUPP;
@@ -7142,6 +7245,10 @@ static int nfs4_xattr_get_security(const struct xattr_handler *handler,
 				   struct dentry *unused, struct inode *inode,
 				   const char *key, void *buf, size_t buflen)
 {
+#ifdef CONFIG_IMA
+	if (nfs4_security_isima(key))
+		return nfs4_get_security_ima(inode, buf, buflen);
+#endif /* CONFIG_IMA */
 	if (security_ismaclabel(key))
 		return nfs4_get_security_label(inode, buf, buflen);
 	return -EOPNOTSUPP;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 2fc8f6f..01f9a70 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -434,6 +434,14 @@ static int decode_layoutget(struct xdr_stream *xdr, struct rpc_rqst *req,
 #define decode_layoutget_maxsz	0
 #endif /* CONFIG_NFS_V4_1 */
 
+#define encode_getima_maxsz	(encode_getattr_maxsz)
+/* XXX: not quite right: we don't need getfattr_maxsz here */
+#define decode_getima_maxsz	(decode_getattr_maxsz + \
+				 1 + XDR_QUADLEN(NFS4_MAXIMALEN))
+#define encode_setima_maxsz	(encode_setattr_maxsz + \
+				 1 + XDR_QUADLEN(NFS4_MAXIMALEN))
+#define decode_setima_maxsz	(decode_setattr_maxsz)
+
 #define NFS4_enc_compound_sz	(1024)  /* XXX: large enough? */
 #define NFS4_dec_compound_sz	(1024)  /* XXX: large enough? */
 #define NFS4_enc_read_sz	(compound_encode_hdr_maxsz + \
@@ -901,6 +909,22 @@ static int decode_layoutget(struct xdr_stream *xdr, struct rpc_rqst *req,
 #define NFS4_dec_free_stateid_sz	(compound_decode_hdr_maxsz + \
 					 decode_sequence_maxsz + \
 					 decode_free_stateid_maxsz)
+#define NFS4_enc_getima_sz	(compound_encode_hdr_maxsz + \
+				 encode_sequence_maxsz + \
+				 encode_putfh_maxsz + \
+				 encode_getima_maxsz)
+#define NFS4_dec_getima_sz	(compound_decode_hdr_maxsz + \
+				 decode_sequence_maxsz + \
+				 decode_putfh_maxsz + \
+				 decode_getima_maxsz)
+#define NFS4_enc_setima_sz	(compound_encode_hdr_maxsz +\
+				 encode_sequence_maxsz + \
+				 encode_putfh_maxsz + \
+				 encode_setima_maxsz)
+#define NFS4_dec_setima_sz	(compound_decode_hdr_maxsz +\
+				 decode_sequence_maxsz + \
+				 decode_putfh_maxsz + \
+				 decode_setima_maxsz)
 
 const u32 nfs41_maxwrite_overhead = ((RPC_MAX_HEADER_WITH_AUTH +
 				      compound_encode_hdr_maxsz +
@@ -1280,6 +1304,15 @@ static void encode_fs_locations(struct xdr_stream *xdr, const u32* bitmask, stru
 			ARRAY_SIZE(nfs4_fs_locations_bitmap), hdr);
 }
 
+#if defined(CONFIG_NFS_V4_2)
+static void encode_getima(struct xdr_stream *xdr, const u32 *bitmask,
+			  struct compound_hdr *hdr)
+{
+	encode_getattr(xdr, nfs4_ima_bitmap, bitmask,
+		       ARRAY_SIZE(nfs4_ima_bitmap), hdr);
+}
+#endif /* CONFIG_NFS_V4_2 */
+
 static void encode_getfh(struct xdr_stream *xdr, struct compound_hdr *hdr)
 {
 	encode_op_hdr(xdr, OP_GETFH, decode_getfh_maxsz, hdr);
@@ -1698,6 +1731,19 @@ static void encode_setattr(struct xdr_stream *xdr, const struct nfs_setattrargs
 			server->attr_bitmask);
 }
 
+#if defined(CONFIG_NFS_V4_2)
+static void encode_setima(struct xdr_stream *xdr,
+			  const struct nfs4_setima_arg *arg,
+			  struct compound_hdr *hdr)
+{
+	encode_op_hdr(xdr, OP_SETATTR, decode_setattr_maxsz, hdr);
+	encode_nfs4_stateid(xdr, &arg->stateid);
+	xdr_encode_bitmap4(xdr, nfs4_ima_bitmap, ARRAY_SIZE(nfs4_ima_bitmap));
+	xdr_stream_encode_u32(xdr, sizeof(__be32) + xdr_align_size(arg->len));
+	xdr_stream_encode_opaque(xdr, arg->data, arg->len);
+}
+#endif	/* CONFIG_NFS_V4_2 */
+
 static void encode_setclientid(struct xdr_stream *xdr, const struct nfs4_setclientid *setclientid, struct compound_hdr *hdr)
 {
 	__be32 *p;
@@ -3144,6 +3190,44 @@ static void nfs4_xdr_enc_free_stateid(struct rpc_rqst *req,
 }
 #endif /* CONFIG_NFS_V4_1 */
 
+#if defined(CONFIG_NFS_V4_2)
+/*
+ * Encode GETATTR(IMA) request
+ */
+static void nfs4_xdr_enc_getima(struct rpc_rqst *req, struct xdr_stream *xdr,
+				const void *data)
+{
+	const struct nfs4_getima_arg *args = data;
+	struct compound_hdr hdr = {
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
+	};
+
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->seq_args, &hdr);
+	encode_putfh(xdr, args->fh, &hdr);
+	encode_getima(xdr, args->bitmask, &hdr);
+	encode_nops(&hdr);
+}
+
+/*
+ * Encode an SETATTR(IMA) request
+ */
+static void nfs4_xdr_enc_setima(struct rpc_rqst *req, struct xdr_stream *xdr,
+				const void *data)
+{
+	const struct nfs4_setima_arg *args = data;
+	struct compound_hdr hdr = {
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
+	};
+
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->seq_args, &hdr);
+	encode_putfh(xdr, args->fh, &hdr);
+	encode_setima(xdr, args, &hdr);
+	encode_nops(&hdr);
+}
+#endif /* CONFIG_NFS_V4_2 */
+
 static void print_overflow_msg(const char *func, const struct xdr_stream *xdr)
 {
 	dprintk("nfs: %s: prematurely hit end of receive buffer. "
@@ -4846,6 +4930,54 @@ static int decode_getfattr(struct xdr_stream *xdr, struct nfs_fattr *fattr,
 	return decode_getfattr_generic(xdr, fattr, NULL, NULL, NULL, server);
 }
 
+#if defined(CONFIG_NFS_V4_2)
+static int decode_getima(struct xdr_stream *xdr, void *data, u32 len,
+			 const struct nfs_server *server)
+{
+	u32 attrlen, bitmap[3] = { 0 };
+	unsigned int savep;
+	int status;
+	u32 size;
+
+	status = decode_op_hdr(xdr, OP_GETATTR);
+	if (status < 0)
+		return status;
+	status = decode_attr_bitmap(xdr, bitmap);
+	if (status < 0)
+		return status;
+	status = decode_attr_length(xdr, &attrlen, &savep);
+	if (status < 0)
+		return status;
+
+	if (likely(bitmap[2] & FATTR4_WORD2_LINUX_IMA)) {
+		__be32 *p;
+
+		p = xdr_inline_decode(xdr, 4);
+		if (unlikely(!p))
+			return -EIO;
+		size = be32_to_cpup(p++);
+		p = xdr_inline_decode(xdr, size);
+		if (unlikely(!p))
+			return -EIO;
+
+		if (size > NFS4_MAXIMALEN)
+			return -E2BIG;
+		/* @len == 0 means "just return the size" */
+		if (len > 0) {
+			if (size > len)
+				return -ERANGE;
+			memcpy(data, p, len);
+		}
+	} else
+		return -ENODATA;
+
+	status = verify_attr_len(xdr, savep, attrlen);
+	if (status < 0)
+		return status;
+	return size;
+}
+#endif /* CONFIG_NFS_V4_2 */
+
 /*
  * Decode potentially multiple layout types.
  */
@@ -7547,6 +7679,58 @@ static int nfs4_xdr_dec_free_stateid(struct rpc_rqst *rqstp,
 }
 #endif /* CONFIG_NFS_V4_1 */
 
+#if defined(CONFIG_NFS_V4_2)
+
+/*
+ * Decode GETATTR(IMA) response
+ */
+static int nfs4_xdr_dec_getima(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
+			       void *data)
+{
+	struct nfs4_getima_res *res = data;
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
+	status = decode_getima(xdr, res->data, res->len, res->server);
+out:
+	return status;
+}
+
+/*
+ * Decode SETATTR(IMA) response
+ */
+static int nfs4_xdr_dec_setima(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
+			       void *data)
+{
+	struct nfs_setattrres *res = data;
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
+	status = decode_setattr(xdr);
+out:
+	return status;
+}
+
+#endif /* CONFIG_NFS_V4_2 */
+
 /**
  * nfs4_decode_dirent - Decode a single NFSv4 directory entry stored in
  *                      the local page cache.
@@ -7791,6 +7975,8 @@ int nfs4_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
 	PROC42(COPY,		enc_copy,		dec_copy),
 	PROC42(OFFLOAD_CANCEL,	enc_offload_cancel,	dec_offload_cancel),
 	PROC(LOOKUPP,		enc_lookupp,		dec_lookupp),
+	PROC42(GETIMA,		enc_getima,		dec_getima),
+	PROC42(SETIMA,		enc_setima,		dec_setima),
 };
 
 static unsigned int nfs_version4_counts[ARRAY_SIZE(nfs4_procedures)];
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index ca3adb1..4d5c771 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -540,6 +540,9 @@ enum {
 	NFSPROC4_CLNT_OFFLOAD_CANCEL,
 
 	NFSPROC4_CLNT_LOOKUPP,
+
+	NFSPROC4_CLNT_GETIMA,
+	NFSPROC4_CLNT_SETIMA,
 };
 
 /* nfs41 types */
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 6aa8cc8..b92f954 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -261,5 +261,6 @@ struct nfs_server {
 #define NFS_CAP_CLONE		(1U << 23)
 #define NFS_CAP_COPY		(1U << 24)
 #define NFS_CAP_OFFLOAD_CANCEL	(1U << 25)
+#define NFS_CAP_IMA		(1U << 26)
 
 #endif
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 441a93e..4ee30f0 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1010,6 +1010,27 @@ struct nfs4_getattr_res {
 	struct nfs4_label		*label;
 };
 
+struct nfs4_getima_arg {
+	struct nfs4_sequence_args	seq_args;
+	const struct nfs_fh		*fh;
+	const u32			*bitmask;
+};
+
+struct nfs4_getima_res {
+	struct nfs4_sequence_res	seq_res;
+	const struct nfs_server		*server;
+	void				*data;
+	u32				len;
+};
+
+struct nfs4_setima_arg {
+	struct nfs4_sequence_args	seq_args;
+	struct nfs_fh			*fh;
+	nfs4_stateid                    stateid;
+	const void			*data;
+	u32				len;
+};
+
 struct nfs4_link_arg {
 	struct nfs4_sequence_args 	seq_args;
 	const struct nfs_fh *		fh;


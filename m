Return-Path: <SRS0=08pM=S2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44899C282CE
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 21:49:08 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E812120811
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 21:49:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Fh12DS0M"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730815AbfDXVtH (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 24 Apr 2019 17:49:07 -0400
Received: from mail-it1-f195.google.com ([209.85.166.195]:37579 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730434AbfDXVtG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Apr 2019 17:49:06 -0400
Received: by mail-it1-f195.google.com with SMTP id u65so8863130itc.2
        for <linux-nfs@vger.kernel.org>; Wed, 24 Apr 2019 14:49:06 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=d+VBPeRAWvniHaItP07oNPJfUyUDaar7gdqvn1z/zX8=;
        b=Fh12DS0M9jEZ0yXEcbTsxzwWqrsaRG1SAXS2+XO5fflhr1YZZsOpk95016atAR7u16
         3UOmysbTeom8h/pDr5kncLh+J+EaBlQwMol3+OlunWVEPUE4CA6yHbsSimPTUcpRfIT8
         sTRR28NP1F7/PX00WwdAWIexCTqT7SglLOGxT6A59Y8Gg6AXbKw7immpO5vyHVMpK4sE
         pVF/GqRyJTYBuXtyjfzTJSRu5h2bSF1m8T8yRajUHa6k4wHrKH+CqQqAaILdCytuRd2M
         6rlUPTkBnwru4gKz6xwClPb1q/F3EF3m7n+mfHy7B4QRAz0x6c1ydtaCcC43Zqt0dlcV
         BHLw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=d+VBPeRAWvniHaItP07oNPJfUyUDaar7gdqvn1z/zX8=;
        b=pw17HLnzI6yFi0CvCGqmIrf5r1JvOLrJJEfnXYOmCl3KPI229UsO0zDzFCdTDM+jrm
         AAyfx9jCQlOkifm/2gDGT81TbTQx3V1uFwey6rZ4ydWMU6agGWG+qk0Li1eRngmvq0Sg
         dbkCU9WJrQNYa8qI60fRJOwYH/ZCDc4eFyjrK+GPvjKo8yUiaMP+a3/40WtXXqiXs49g
         QKi72ewH5r0cowT8HAQDtG2ZhkciKpwfnW8rHLfGCvGzEUS3F+OkPYl+s5e1oHOIJGqt
         IqdK31891oV1cbg4Y1PJzc5xXL4QpStCJk/dqyetaAqxbtJz9y7/rytXm3F2ObOdyb0Y
         Guug==
X-Gm-Message-State: APjAAAUGPBczU3F3kIaK5eo9mLuPHT/jhDdy5W8SuS6LnkmDtgg3wAd5
        TVVG/4+ataNhEUnhLoRPOw==
X-Google-Smtp-Source: APXvYqzaYRuOyZ//+3af2ZQ4wFp1t10lDo1IrvU5ssBlRtNFP1vtdjsQKTB9qjHAVcA6ihUllqpOYw==
X-Received: by 2002:a24:67c5:: with SMTP id u188mr1024635itc.177.1556142545690;
        Wed, 24 Apr 2019 14:49:05 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id x10sm9838282ita.4.2019.04.24.14.49.04
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 24 Apr 2019 14:49:04 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Anna Schumaker <Anna.Schumaker@netapp.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 5/9] NFS: Convert NFSv3 to use the container user namespace
Date:   Wed, 24 Apr 2019 17:46:46 -0400
Message-Id: <20190424214650.4658-6-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190424214650.4658-5-trond.myklebust@hammerspace.com>
References: <20190424214650.4658-1-trond.myklebust@hammerspace.com>
 <20190424214650.4658-2-trond.myklebust@hammerspace.com>
 <20190424214650.4658-3-trond.myklebust@hammerspace.com>
 <20190424214650.4658-4-trond.myklebust@hammerspace.com>
 <20190424214650.4658-5-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

When mapping NFS identities, we want to substitute for the uids and
gids on the wire as we would for the AUTH_UNIX creds.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs3xdr.c | 142 ++++++++++++++++++++++++++++-------------------
 1 file changed, 86 insertions(+), 56 deletions(-)

diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index 110358f4986d..abbbdde97e31 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -104,6 +104,20 @@ static const umode_t nfs_type2fmt[] = {
 	[NF3FIFO] = S_IFIFO,
 };
 
+static struct user_namespace *rpc_userns(const struct rpc_clnt *clnt)
+{
+	if (clnt && clnt->cl_cred)
+		return clnt->cl_cred->user_ns;
+	return &init_user_ns;
+}
+
+static struct user_namespace *rpc_rqst_userns(const struct rpc_rqst *rqstp)
+{
+	if (rqstp->rq_task)
+		return rpc_userns(rqstp->rq_task->tk_client);
+	return &init_user_ns;
+}
+
 /*
  * Encode/decode NFSv3 basic data types
  *
@@ -516,7 +530,8 @@ static __be32 *xdr_decode_nfstime3(__be32 *p, struct timespec *timep)
  *		set_mtime	mtime;
  *	};
  */
-static void encode_sattr3(struct xdr_stream *xdr, const struct iattr *attr)
+static void encode_sattr3(struct xdr_stream *xdr, const struct iattr *attr,
+		struct user_namespace *userns)
 {
 	struct timespec ts;
 	u32 nbytes;
@@ -551,13 +566,13 @@ static void encode_sattr3(struct xdr_stream *xdr, const struct iattr *attr)
 
 	if (attr->ia_valid & ATTR_UID) {
 		*p++ = xdr_one;
-		*p++ = cpu_to_be32(from_kuid(&init_user_ns, attr->ia_uid));
+		*p++ = cpu_to_be32(from_kuid_munged(userns, attr->ia_uid));
 	} else
 		*p++ = xdr_zero;
 
 	if (attr->ia_valid & ATTR_GID) {
 		*p++ = xdr_one;
-		*p++ = cpu_to_be32(from_kgid(&init_user_ns, attr->ia_gid));
+		*p++ = cpu_to_be32(from_kgid_munged(userns, attr->ia_gid));
 	} else
 		*p++ = xdr_zero;
 
@@ -606,7 +621,8 @@ static void encode_sattr3(struct xdr_stream *xdr, const struct iattr *attr)
  *		nfstime3	ctime;
  *	};
  */
-static int decode_fattr3(struct xdr_stream *xdr, struct nfs_fattr *fattr)
+static int decode_fattr3(struct xdr_stream *xdr, struct nfs_fattr *fattr,
+		struct user_namespace *userns)
 {
 	umode_t fmode;
 	__be32 *p;
@@ -619,10 +635,10 @@ static int decode_fattr3(struct xdr_stream *xdr, struct nfs_fattr *fattr)
 
 	fattr->mode = (be32_to_cpup(p++) & ~S_IFMT) | fmode;
 	fattr->nlink = be32_to_cpup(p++);
-	fattr->uid = make_kuid(&init_user_ns, be32_to_cpup(p++));
+	fattr->uid = make_kuid(userns, be32_to_cpup(p++));
 	if (!uid_valid(fattr->uid))
 		goto out_uid;
-	fattr->gid = make_kgid(&init_user_ns, be32_to_cpup(p++));
+	fattr->gid = make_kgid(userns, be32_to_cpup(p++));
 	if (!gid_valid(fattr->gid))
 		goto out_gid;
 
@@ -659,7 +675,8 @@ static int decode_fattr3(struct xdr_stream *xdr, struct nfs_fattr *fattr)
  *		void;
  *	};
  */
-static int decode_post_op_attr(struct xdr_stream *xdr, struct nfs_fattr *fattr)
+static int decode_post_op_attr(struct xdr_stream *xdr, struct nfs_fattr *fattr,
+		struct user_namespace *userns)
 {
 	__be32 *p;
 
@@ -667,7 +684,7 @@ static int decode_post_op_attr(struct xdr_stream *xdr, struct nfs_fattr *fattr)
 	if (unlikely(!p))
 		return -EIO;
 	if (*p != xdr_zero)
-		return decode_fattr3(xdr, fattr);
+		return decode_fattr3(xdr, fattr, userns);
 	return 0;
 }
 
@@ -728,14 +745,15 @@ static int decode_pre_op_attr(struct xdr_stream *xdr, struct nfs_fattr *fattr)
 	return 0;
 }
 
-static int decode_wcc_data(struct xdr_stream *xdr, struct nfs_fattr *fattr)
+static int decode_wcc_data(struct xdr_stream *xdr, struct nfs_fattr *fattr,
+		struct user_namespace *userns)
 {
 	int error;
 
 	error = decode_pre_op_attr(xdr, fattr);
 	if (unlikely(error))
 		goto out;
-	error = decode_post_op_attr(xdr, fattr);
+	error = decode_post_op_attr(xdr, fattr, userns);
 out:
 	return error;
 }
@@ -837,7 +855,7 @@ static void nfs3_xdr_enc_setattr3args(struct rpc_rqst *req,
 {
 	const struct nfs3_sattrargs *args = data;
 	encode_nfs_fh3(xdr, args->fh);
-	encode_sattr3(xdr, args->sattr);
+	encode_sattr3(xdr, args->sattr, rpc_rqst_userns(req));
 	encode_sattrguard3(xdr, args);
 }
 
@@ -998,13 +1016,14 @@ static void nfs3_xdr_enc_write3args(struct rpc_rqst *req,
  *	};
  */
 static void encode_createhow3(struct xdr_stream *xdr,
-			      const struct nfs3_createargs *args)
+			      const struct nfs3_createargs *args,
+			      struct user_namespace *userns)
 {
 	encode_uint32(xdr, args->createmode);
 	switch (args->createmode) {
 	case NFS3_CREATE_UNCHECKED:
 	case NFS3_CREATE_GUARDED:
-		encode_sattr3(xdr, args->sattr);
+		encode_sattr3(xdr, args->sattr, userns);
 		break;
 	case NFS3_CREATE_EXCLUSIVE:
 		encode_createverf3(xdr, args->verifier);
@@ -1021,7 +1040,7 @@ static void nfs3_xdr_enc_create3args(struct rpc_rqst *req,
 	const struct nfs3_createargs *args = data;
 
 	encode_diropargs3(xdr, args->fh, args->name, args->len);
-	encode_createhow3(xdr, args);
+	encode_createhow3(xdr, args, rpc_rqst_userns(req));
 }
 
 /*
@@ -1039,7 +1058,7 @@ static void nfs3_xdr_enc_mkdir3args(struct rpc_rqst *req,
 	const struct nfs3_mkdirargs *args = data;
 
 	encode_diropargs3(xdr, args->fh, args->name, args->len);
-	encode_sattr3(xdr, args->sattr);
+	encode_sattr3(xdr, args->sattr, rpc_rqst_userns(req));
 }
 
 /*
@@ -1056,11 +1075,12 @@ static void nfs3_xdr_enc_mkdir3args(struct rpc_rqst *req,
  *	};
  */
 static void encode_symlinkdata3(struct xdr_stream *xdr,
-				const void *data)
+				const void *data,
+				struct user_namespace *userns)
 {
 	const struct nfs3_symlinkargs *args = data;
 
-	encode_sattr3(xdr, args->sattr);
+	encode_sattr3(xdr, args->sattr, userns);
 	encode_nfspath3(xdr, args->pages, args->pathlen);
 }
 
@@ -1071,7 +1091,7 @@ static void nfs3_xdr_enc_symlink3args(struct rpc_rqst *req,
 	const struct nfs3_symlinkargs *args = data;
 
 	encode_diropargs3(xdr, args->fromfh, args->fromname, args->fromlen);
-	encode_symlinkdata3(xdr, args);
+	encode_symlinkdata3(xdr, args, rpc_rqst_userns(req));
 	xdr->buf->flags |= XDRBUF_WRITE;
 }
 
@@ -1100,24 +1120,26 @@ static void nfs3_xdr_enc_symlink3args(struct rpc_rqst *req,
  *	};
  */
 static void encode_devicedata3(struct xdr_stream *xdr,
-			       const struct nfs3_mknodargs *args)
+			       const struct nfs3_mknodargs *args,
+			       struct user_namespace *userns)
 {
-	encode_sattr3(xdr, args->sattr);
+	encode_sattr3(xdr, args->sattr, userns);
 	encode_specdata3(xdr, args->rdev);
 }
 
 static void encode_mknoddata3(struct xdr_stream *xdr,
-			      const struct nfs3_mknodargs *args)
+			      const struct nfs3_mknodargs *args,
+			      struct user_namespace *userns)
 {
 	encode_ftype3(xdr, args->type);
 	switch (args->type) {
 	case NF3CHR:
 	case NF3BLK:
-		encode_devicedata3(xdr, args);
+		encode_devicedata3(xdr, args, userns);
 		break;
 	case NF3SOCK:
 	case NF3FIFO:
-		encode_sattr3(xdr, args->sattr);
+		encode_sattr3(xdr, args->sattr, userns);
 		break;
 	case NF3REG:
 	case NF3DIR:
@@ -1134,7 +1156,7 @@ static void nfs3_xdr_enc_mknod3args(struct rpc_rqst *req,
 	const struct nfs3_mknodargs *args = data;
 
 	encode_diropargs3(xdr, args->fh, args->name, args->len);
-	encode_mknoddata3(xdr, args);
+	encode_mknoddata3(xdr, args, rpc_rqst_userns(req));
 }
 
 /*
@@ -1379,7 +1401,7 @@ static int nfs3_xdr_dec_getattr3res(struct rpc_rqst *req,
 		goto out;
 	if (status != NFS3_OK)
 		goto out_default;
-	error = decode_fattr3(xdr, result);
+	error = decode_fattr3(xdr, result, rpc_rqst_userns(req));
 out:
 	return error;
 out_default:
@@ -1414,7 +1436,7 @@ static int nfs3_xdr_dec_setattr3res(struct rpc_rqst *req,
 	error = decode_nfsstat3(xdr, &status);
 	if (unlikely(error))
 		goto out;
-	error = decode_wcc_data(xdr, result);
+	error = decode_wcc_data(xdr, result, rpc_rqst_userns(req));
 	if (unlikely(error))
 		goto out;
 	if (status != NFS3_OK)
@@ -1449,6 +1471,7 @@ static int nfs3_xdr_dec_lookup3res(struct rpc_rqst *req,
 				   struct xdr_stream *xdr,
 				   void *data)
 {
+	struct user_namespace *userns = rpc_rqst_userns(req);
 	struct nfs3_diropres *result = data;
 	enum nfs_stat status;
 	int error;
@@ -1461,14 +1484,14 @@ static int nfs3_xdr_dec_lookup3res(struct rpc_rqst *req,
 	error = decode_nfs_fh3(xdr, result->fh);
 	if (unlikely(error))
 		goto out;
-	error = decode_post_op_attr(xdr, result->fattr);
+	error = decode_post_op_attr(xdr, result->fattr, userns);
 	if (unlikely(error))
 		goto out;
-	error = decode_post_op_attr(xdr, result->dir_attr);
+	error = decode_post_op_attr(xdr, result->dir_attr, userns);
 out:
 	return error;
 out_default:
-	error = decode_post_op_attr(xdr, result->dir_attr);
+	error = decode_post_op_attr(xdr, result->dir_attr, userns);
 	if (unlikely(error))
 		goto out;
 	return nfs3_stat_to_errno(status);
@@ -1504,7 +1527,7 @@ static int nfs3_xdr_dec_access3res(struct rpc_rqst *req,
 	error = decode_nfsstat3(xdr, &status);
 	if (unlikely(error))
 		goto out;
-	error = decode_post_op_attr(xdr, result->fattr);
+	error = decode_post_op_attr(xdr, result->fattr, rpc_rqst_userns(req));
 	if (unlikely(error))
 		goto out;
 	if (status != NFS3_OK)
@@ -1545,7 +1568,7 @@ static int nfs3_xdr_dec_readlink3res(struct rpc_rqst *req,
 	error = decode_nfsstat3(xdr, &status);
 	if (unlikely(error))
 		goto out;
-	error = decode_post_op_attr(xdr, result);
+	error = decode_post_op_attr(xdr, result, rpc_rqst_userns(req));
 	if (unlikely(error))
 		goto out;
 	if (status != NFS3_OK)
@@ -1623,7 +1646,7 @@ static int nfs3_xdr_dec_read3res(struct rpc_rqst *req, struct xdr_stream *xdr,
 	error = decode_nfsstat3(xdr, &status);
 	if (unlikely(error))
 		goto out;
-	error = decode_post_op_attr(xdr, result->fattr);
+	error = decode_post_op_attr(xdr, result->fattr, rpc_rqst_userns(req));
 	if (unlikely(error))
 		goto out;
 	result->op_status = status;
@@ -1694,7 +1717,7 @@ static int nfs3_xdr_dec_write3res(struct rpc_rqst *req, struct xdr_stream *xdr,
 	error = decode_nfsstat3(xdr, &status);
 	if (unlikely(error))
 		goto out;
-	error = decode_wcc_data(xdr, result->fattr);
+	error = decode_wcc_data(xdr, result->fattr, rpc_rqst_userns(req));
 	if (unlikely(error))
 		goto out;
 	result->op_status = status;
@@ -1728,14 +1751,15 @@ static int nfs3_xdr_dec_write3res(struct rpc_rqst *req, struct xdr_stream *xdr,
  *	};
  */
 static int decode_create3resok(struct xdr_stream *xdr,
-			       struct nfs3_diropres *result)
+			       struct nfs3_diropres *result,
+			       struct user_namespace *userns)
 {
 	int error;
 
 	error = decode_post_op_fh3(xdr, result->fh);
 	if (unlikely(error))
 		goto out;
-	error = decode_post_op_attr(xdr, result->fattr);
+	error = decode_post_op_attr(xdr, result->fattr, userns);
 	if (unlikely(error))
 		goto out;
 	/* The server isn't required to return a file handle.
@@ -1744,7 +1768,7 @@ static int decode_create3resok(struct xdr_stream *xdr,
 	 * values for the new object. */
 	if (result->fh->size == 0)
 		result->fattr->valid = 0;
-	error = decode_wcc_data(xdr, result->dir_attr);
+	error = decode_wcc_data(xdr, result->dir_attr, userns);
 out:
 	return error;
 }
@@ -1753,6 +1777,7 @@ static int nfs3_xdr_dec_create3res(struct rpc_rqst *req,
 				   struct xdr_stream *xdr,
 				   void *data)
 {
+	struct user_namespace *userns = rpc_rqst_userns(req);
 	struct nfs3_diropres *result = data;
 	enum nfs_stat status;
 	int error;
@@ -1762,11 +1787,11 @@ static int nfs3_xdr_dec_create3res(struct rpc_rqst *req,
 		goto out;
 	if (status != NFS3_OK)
 		goto out_default;
-	error = decode_create3resok(xdr, result);
+	error = decode_create3resok(xdr, result, userns);
 out:
 	return error;
 out_default:
-	error = decode_wcc_data(xdr, result->dir_attr);
+	error = decode_wcc_data(xdr, result->dir_attr, userns);
 	if (unlikely(error))
 		goto out;
 	return nfs3_stat_to_errno(status);
@@ -1801,7 +1826,7 @@ static int nfs3_xdr_dec_remove3res(struct rpc_rqst *req,
 	error = decode_nfsstat3(xdr, &status);
 	if (unlikely(error))
 		goto out;
-	error = decode_wcc_data(xdr, result->dir_attr);
+	error = decode_wcc_data(xdr, result->dir_attr, rpc_rqst_userns(req));
 	if (unlikely(error))
 		goto out;
 	if (status != NFS3_OK)
@@ -1836,6 +1861,7 @@ static int nfs3_xdr_dec_rename3res(struct rpc_rqst *req,
 				   struct xdr_stream *xdr,
 				   void *data)
 {
+	struct user_namespace *userns = rpc_rqst_userns(req);
 	struct nfs_renameres *result = data;
 	enum nfs_stat status;
 	int error;
@@ -1843,10 +1869,10 @@ static int nfs3_xdr_dec_rename3res(struct rpc_rqst *req,
 	error = decode_nfsstat3(xdr, &status);
 	if (unlikely(error))
 		goto out;
-	error = decode_wcc_data(xdr, result->old_fattr);
+	error = decode_wcc_data(xdr, result->old_fattr, userns);
 	if (unlikely(error))
 		goto out;
-	error = decode_wcc_data(xdr, result->new_fattr);
+	error = decode_wcc_data(xdr, result->new_fattr, userns);
 	if (unlikely(error))
 		goto out;
 	if (status != NFS3_OK)
@@ -1880,6 +1906,7 @@ static int nfs3_xdr_dec_rename3res(struct rpc_rqst *req,
 static int nfs3_xdr_dec_link3res(struct rpc_rqst *req, struct xdr_stream *xdr,
 				 void *data)
 {
+	struct user_namespace *userns = rpc_rqst_userns(req);
 	struct nfs3_linkres *result = data;
 	enum nfs_stat status;
 	int error;
@@ -1887,10 +1914,10 @@ static int nfs3_xdr_dec_link3res(struct rpc_rqst *req, struct xdr_stream *xdr,
 	error = decode_nfsstat3(xdr, &status);
 	if (unlikely(error))
 		goto out;
-	error = decode_post_op_attr(xdr, result->fattr);
+	error = decode_post_op_attr(xdr, result->fattr, userns);
 	if (unlikely(error))
 		goto out;
-	error = decode_wcc_data(xdr, result->dir_attr);
+	error = decode_wcc_data(xdr, result->dir_attr, userns);
 	if (unlikely(error))
 		goto out;
 	if (status != NFS3_OK)
@@ -1939,6 +1966,7 @@ static int nfs3_xdr_dec_link3res(struct rpc_rqst *req, struct xdr_stream *xdr,
 int nfs3_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
 		       bool plus)
 {
+	struct user_namespace *userns = rpc_userns(entry->server->client);
 	struct nfs_entry old = *entry;
 	__be32 *p;
 	int error;
@@ -1973,7 +2001,7 @@ int nfs3_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
 
 	if (plus) {
 		entry->fattr->valid = 0;
-		error = decode_post_op_attr(xdr, entry->fattr);
+		error = decode_post_op_attr(xdr, entry->fattr, userns);
 		if (unlikely(error))
 			return error;
 		if (entry->fattr->valid & NFS_ATTR_FATTR_V3)
@@ -2045,11 +2073,12 @@ static int decode_dirlist3(struct xdr_stream *xdr)
 }
 
 static int decode_readdir3resok(struct xdr_stream *xdr,
-				struct nfs3_readdirres *result)
+				struct nfs3_readdirres *result,
+				struct user_namespace *userns)
 {
 	int error;
 
-	error = decode_post_op_attr(xdr, result->dir_attr);
+	error = decode_post_op_attr(xdr, result->dir_attr, userns);
 	if (unlikely(error))
 		goto out;
 	/* XXX: do we need to check if result->verf != NULL ? */
@@ -2074,11 +2103,11 @@ static int nfs3_xdr_dec_readdir3res(struct rpc_rqst *req,
 		goto out;
 	if (status != NFS3_OK)
 		goto out_default;
-	error = decode_readdir3resok(xdr, result);
+	error = decode_readdir3resok(xdr, result, rpc_rqst_userns(req));
 out:
 	return error;
 out_default:
-	error = decode_post_op_attr(xdr, result->dir_attr);
+	error = decode_post_op_attr(xdr, result->dir_attr, rpc_rqst_userns(req));
 	if (unlikely(error))
 		goto out;
 	return nfs3_stat_to_errno(status);
@@ -2138,7 +2167,7 @@ static int nfs3_xdr_dec_fsstat3res(struct rpc_rqst *req,
 	error = decode_nfsstat3(xdr, &status);
 	if (unlikely(error))
 		goto out;
-	error = decode_post_op_attr(xdr, result->fattr);
+	error = decode_post_op_attr(xdr, result->fattr, rpc_rqst_userns(req));
 	if (unlikely(error))
 		goto out;
 	if (status != NFS3_OK)
@@ -2212,7 +2241,7 @@ static int nfs3_xdr_dec_fsinfo3res(struct rpc_rqst *req,
 	error = decode_nfsstat3(xdr, &status);
 	if (unlikely(error))
 		goto out;
-	error = decode_post_op_attr(xdr, result->fattr);
+	error = decode_post_op_attr(xdr, result->fattr, rpc_rqst_userns(req));
 	if (unlikely(error))
 		goto out;
 	if (status != NFS3_OK)
@@ -2273,7 +2302,7 @@ static int nfs3_xdr_dec_pathconf3res(struct rpc_rqst *req,
 	error = decode_nfsstat3(xdr, &status);
 	if (unlikely(error))
 		goto out;
-	error = decode_post_op_attr(xdr, result->fattr);
+	error = decode_post_op_attr(xdr, result->fattr, rpc_rqst_userns(req));
 	if (unlikely(error))
 		goto out;
 	if (status != NFS3_OK)
@@ -2315,7 +2344,7 @@ static int nfs3_xdr_dec_commit3res(struct rpc_rqst *req,
 	error = decode_nfsstat3(xdr, &status);
 	if (unlikely(error))
 		goto out;
-	error = decode_wcc_data(xdr, result->fattr);
+	error = decode_wcc_data(xdr, result->fattr, rpc_rqst_userns(req));
 	if (unlikely(error))
 		goto out;
 	result->op_status = status;
@@ -2331,14 +2360,15 @@ static int nfs3_xdr_dec_commit3res(struct rpc_rqst *req,
 #ifdef CONFIG_NFS_V3_ACL
 
 static inline int decode_getacl3resok(struct xdr_stream *xdr,
-				      struct nfs3_getaclres *result)
+				      struct nfs3_getaclres *result,
+				      struct user_namespace *userns)
 {
 	struct posix_acl **acl;
 	unsigned int *aclcnt;
 	size_t hdrlen;
 	int error;
 
-	error = decode_post_op_attr(xdr, result->fattr);
+	error = decode_post_op_attr(xdr, result->fattr, userns);
 	if (unlikely(error))
 		goto out;
 	error = decode_uint32(xdr, &result->mask);
@@ -2386,7 +2416,7 @@ static int nfs3_xdr_dec_getacl3res(struct rpc_rqst *req,
 		goto out;
 	if (status != NFS3_OK)
 		goto out_default;
-	error = decode_getacl3resok(xdr, result);
+	error = decode_getacl3resok(xdr, result, rpc_rqst_userns(req));
 out:
 	return error;
 out_default:
@@ -2405,7 +2435,7 @@ static int nfs3_xdr_dec_setacl3res(struct rpc_rqst *req,
 		goto out;
 	if (status != NFS3_OK)
 		goto out_default;
-	error = decode_post_op_attr(xdr, result);
+	error = decode_post_op_attr(xdr, result, rpc_rqst_userns(req));
 out:
 	return error;
 out_default:
-- 
2.21.0


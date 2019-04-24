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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77B59C282CE
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 21:49:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 37F6920811
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 21:49:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bYA/xKrB"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730942AbfDXVtJ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 24 Apr 2019 17:49:09 -0400
Received: from mail-it1-f195.google.com ([209.85.166.195]:51347 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730434AbfDXVtI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Apr 2019 17:49:08 -0400
Received: by mail-it1-f195.google.com with SMTP id s3so9098444itk.1
        for <linux-nfs@vger.kernel.org>; Wed, 24 Apr 2019 14:49:08 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=0uwEX1YfIAaHcWNmUTqu3XD8912UqMju8K8gxjXeB2Y=;
        b=bYA/xKrBFq86c4o81mZFnaIlDmwrEt96DaqzrlBlXISOC16HYDCeaaZLUi0ScaqBnF
         Gy9YzEPBKRn5r3EVIPpfXMyLX4BJEJAtq7zSdTVcdd0wTk821trg5LNGxesL4Bp9d020
         73dQvigVRRiGZsef/W0H6VCqQ1cBY1pah2rqSnFPkMe1lmsMUxFcvlVseu6WFxamjoqY
         SCVHRYxI43v61s4BIx5WOvuW5bAWh3eA4qDLEzZSyAXQscSdmD+QBLwp2Z5znGpJ1U5W
         VthYHIiN1SMadNLssxVz4aEaIT3Zz3BJZPyoy87pIQEWMfUcMkeG43Uzbu25GqBlkq8g
         UizA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=0uwEX1YfIAaHcWNmUTqu3XD8912UqMju8K8gxjXeB2Y=;
        b=aHFhFyVlcRMXxhxmVSEFxem3VcD2A5vqM8TKPtiRBPfOUmXY2sD5KdkX/tNuG0OvQo
         6q1fM+40+L42Q17e67Y1EULZjQ6o1uN1Mz1moJMiCtrqVuvSlSHl4ZKkdF8LADH9kIem
         MhLAfUx5wdtdtcxgjLwPoa9QTPjfzEcHrQQ/nanAD6zDaa7gjXCOuFr3muDuK4z5bsS6
         4WiPgqQLYOPFf6O+bAK3oRrl2bhqh/nrDHCKOnzJkTCBdQTNmfKK6ZfBkJMEtFzC+k2y
         42FL53nRgkT1w8QBNC3UuYV+wIPvTBdZJMGuGJQrdUadr05Tuw/HSKVs5b1fC2DNDSiV
         OLmg==
X-Gm-Message-State: APjAAAVHkt7aeLSJf8lbfjDgAtd3Xr7ZpdcPs8zRaDEaMy3c5fEW3jcE
        MF9Zbbsmk1Ter2W+vjHWIfpL4YY=
X-Google-Smtp-Source: APXvYqyPJ+YP/qhoZsdOwEGec0pT4wKRB8bF5cLR4VPVXGBmSpi9vEKkqCND6tVCJaXV6FTluYFn/g==
X-Received: by 2002:a24:7c8c:: with SMTP id a134mr1016218itd.144.1556142547492;
        Wed, 24 Apr 2019 14:49:07 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id x10sm9838282ita.4.2019.04.24.14.49.06
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 24 Apr 2019 14:49:06 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Anna Schumaker <Anna.Schumaker@netapp.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 7/9] NFS: Convert NFSv2 to use the container user namespace
Date:   Wed, 24 Apr 2019 17:46:48 -0400
Message-Id: <20190424214650.4658-8-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190424214650.4658-7-trond.myklebust@hammerspace.com>
References: <20190424214650.4658-1-trond.myklebust@hammerspace.com>
 <20190424214650.4658-2-trond.myklebust@hammerspace.com>
 <20190424214650.4658-3-trond.myklebust@hammerspace.com>
 <20190424214650.4658-4-trond.myklebust@hammerspace.com>
 <20190424214650.4658-5-trond.myklebust@hammerspace.com>
 <20190424214650.4658-6-trond.myklebust@hammerspace.com>
 <20190424214650.4658-7-trond.myklebust@hammerspace.com>
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
 fs/nfs/nfs2xdr.c | 58 ++++++++++++++++++++++++++++++++----------------
 1 file changed, 39 insertions(+), 19 deletions(-)

diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index a7ed29de0a40..572794dab4b1 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -76,6 +76,20 @@ static int nfs_stat_to_errno(enum nfs_stat);
  * or decoded inline.
  */
 
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
  *	typedef opaque	nfsdata<>;
  */
@@ -248,7 +262,8 @@ static __be32 *xdr_decode_time(__be32 *p, struct timespec *timep)
  *	};
  *
  */
-static int decode_fattr(struct xdr_stream *xdr, struct nfs_fattr *fattr)
+static int decode_fattr(struct xdr_stream *xdr, struct nfs_fattr *fattr,
+		struct user_namespace *userns)
 {
 	u32 rdev, type;
 	__be32 *p;
@@ -263,10 +278,10 @@ static int decode_fattr(struct xdr_stream *xdr, struct nfs_fattr *fattr)
 
 	fattr->mode = be32_to_cpup(p++);
 	fattr->nlink = be32_to_cpup(p++);
-	fattr->uid = make_kuid(&init_user_ns, be32_to_cpup(p++));
+	fattr->uid = make_kuid(userns, be32_to_cpup(p++));
 	if (!uid_valid(fattr->uid))
 		goto out_uid;
-	fattr->gid = make_kgid(&init_user_ns, be32_to_cpup(p++));
+	fattr->gid = make_kgid(userns, be32_to_cpup(p++));
 	if (!gid_valid(fattr->gid))
 		goto out_gid;
 		
@@ -321,7 +336,8 @@ static __be32 *xdr_time_not_set(__be32 *p)
 	return p;
 }
 
-static void encode_sattr(struct xdr_stream *xdr, const struct iattr *attr)
+static void encode_sattr(struct xdr_stream *xdr, const struct iattr *attr,
+		struct user_namespace *userns)
 {
 	struct timespec ts;
 	__be32 *p;
@@ -333,11 +349,11 @@ static void encode_sattr(struct xdr_stream *xdr, const struct iattr *attr)
 	else
 		*p++ = cpu_to_be32(NFS2_SATTR_NOT_SET);
 	if (attr->ia_valid & ATTR_UID)
-		*p++ = cpu_to_be32(from_kuid(&init_user_ns, attr->ia_uid));
+		*p++ = cpu_to_be32(from_kuid_munged(userns, attr->ia_uid));
 	else
 		*p++ = cpu_to_be32(NFS2_SATTR_NOT_SET);
 	if (attr->ia_valid & ATTR_GID)
-		*p++ = cpu_to_be32(from_kgid(&init_user_ns, attr->ia_gid));
+		*p++ = cpu_to_be32(from_kgid_munged(userns, attr->ia_gid));
 	else
 		*p++ = cpu_to_be32(NFS2_SATTR_NOT_SET);
 	if (attr->ia_valid & ATTR_SIZE)
@@ -451,7 +467,8 @@ static int decode_path(struct xdr_stream *xdr)
  *	};
  */
 static int decode_attrstat(struct xdr_stream *xdr, struct nfs_fattr *result,
-			   __u32 *op_status)
+			   __u32 *op_status,
+			   struct user_namespace *userns)
 {
 	enum nfs_stat status;
 	int error;
@@ -463,7 +480,7 @@ static int decode_attrstat(struct xdr_stream *xdr, struct nfs_fattr *result,
 		*op_status = status;
 	if (status != NFS_OK)
 		goto out_default;
-	error = decode_fattr(xdr, result);
+	error = decode_fattr(xdr, result, userns);
 out:
 	return error;
 out_default:
@@ -498,19 +515,21 @@ static void encode_diropargs(struct xdr_stream *xdr, const struct nfs_fh *fh,
  *		void;
  *	};
  */
-static int decode_diropok(struct xdr_stream *xdr, struct nfs_diropok *result)
+static int decode_diropok(struct xdr_stream *xdr, struct nfs_diropok *result,
+		struct user_namespace *userns)
 {
 	int error;
 
 	error = decode_fhandle(xdr, result->fh);
 	if (unlikely(error))
 		goto out;
-	error = decode_fattr(xdr, result->fattr);
+	error = decode_fattr(xdr, result->fattr, userns);
 out:
 	return error;
 }
 
-static int decode_diropres(struct xdr_stream *xdr, struct nfs_diropok *result)
+static int decode_diropres(struct xdr_stream *xdr, struct nfs_diropok *result,
+		struct user_namespace *userns)
 {
 	enum nfs_stat status;
 	int error;
@@ -520,7 +539,7 @@ static int decode_diropres(struct xdr_stream *xdr, struct nfs_diropok *result)
 		goto out;
 	if (status != NFS_OK)
 		goto out_default;
-	error = decode_diropok(xdr, result);
+	error = decode_diropok(xdr, result, userns);
 out:
 	return error;
 out_default:
@@ -559,7 +578,7 @@ static void nfs2_xdr_enc_sattrargs(struct rpc_rqst *req,
 	const struct nfs_sattrargs *args = data;
 
 	encode_fhandle(xdr, args->fh);
-	encode_sattr(xdr, args->sattr);
+	encode_sattr(xdr, args->sattr, rpc_rqst_userns(req));
 }
 
 static void nfs2_xdr_enc_diropargs(struct rpc_rqst *req,
@@ -674,7 +693,7 @@ static void nfs2_xdr_enc_createargs(struct rpc_rqst *req,
 	const struct nfs_createargs *args = data;
 
 	encode_diropargs(xdr, args->fh, args->name, args->len);
-	encode_sattr(xdr, args->sattr);
+	encode_sattr(xdr, args->sattr, rpc_rqst_userns(req));
 }
 
 static void nfs2_xdr_enc_removeargs(struct rpc_rqst *req,
@@ -741,7 +760,7 @@ static void nfs2_xdr_enc_symlinkargs(struct rpc_rqst *req,
 
 	encode_diropargs(xdr, args->fromfh, args->fromname, args->fromlen);
 	encode_path(xdr, args->pages, args->pathlen);
-	encode_sattr(xdr, args->sattr);
+	encode_sattr(xdr, args->sattr, rpc_rqst_userns(req));
 }
 
 /*
@@ -803,13 +822,13 @@ static int nfs2_xdr_dec_stat(struct rpc_rqst *req, struct xdr_stream *xdr,
 static int nfs2_xdr_dec_attrstat(struct rpc_rqst *req, struct xdr_stream *xdr,
 				 void *result)
 {
-	return decode_attrstat(xdr, result, NULL);
+	return decode_attrstat(xdr, result, NULL, rpc_rqst_userns(req));
 }
 
 static int nfs2_xdr_dec_diropres(struct rpc_rqst *req, struct xdr_stream *xdr,
 				 void *result)
 {
-	return decode_diropres(xdr, result);
+	return decode_diropres(xdr, result, rpc_rqst_userns(req));
 }
 
 /*
@@ -864,7 +883,7 @@ static int nfs2_xdr_dec_readres(struct rpc_rqst *req, struct xdr_stream *xdr,
 	result->op_status = status;
 	if (status != NFS_OK)
 		goto out_default;
-	error = decode_fattr(xdr, result->fattr);
+	error = decode_fattr(xdr, result->fattr, rpc_rqst_userns(req));
 	if (unlikely(error))
 		goto out;
 	error = decode_nfsdata(xdr, result);
@@ -881,7 +900,8 @@ static int nfs2_xdr_dec_writeres(struct rpc_rqst *req, struct xdr_stream *xdr,
 
 	/* All NFSv2 writes are "file sync" writes */
 	result->verf->committed = NFS_FILE_SYNC;
-	return decode_attrstat(xdr, result->fattr, &result->op_status);
+	return decode_attrstat(xdr, result->fattr, &result->op_status,
+			rpc_rqst_userns(req));
 }
 
 /**
-- 
2.21.0


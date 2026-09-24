Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EF1B34AA3E0
	for <linux-nfs@vger.kernel.org>; Thu, 24 Sep 2026 17:10:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790269830; cv=none; b=DcnSk49juc0nYYjX8lV1Bns19pcBhUW4eRRnZWiqc2/65qNHdpyB+v0XGCod+1v8/wvZzhzzVbVJsZp+glOQ3NwOZSxE86leq6pivZ2A5x9j2ZgFXH0PGAU1x6C/uO1tsc1iyeSoV9HmIJASRqcZzsE6TCO3L8V39csrd+SCwoU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790269830; c=relaxed/simple;
	bh=e/Z4hCZIb5cKFbqrRTdS1rQZVGl46ieWoU/c95dmkAY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=m3IiyI5RjgMe/QImWcqL+wrKLGoxJljFvq2aILILeQll7l7O3hizyKwnlcS+WDEAJBZjpe+9ZoBAuULQcw/wNMM9owZFcNrePr4w7W69UmL7c3+4R0oh3Rga6ktB8mwViT1LcB2kwJ9hIMCDslyhA77L28gPhCrvgFfYpilqnYY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=j+3dpaNc; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="j+3dpaNc"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 46FC61F0089B;
	Thu, 24 Sep 2026 17:10:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790269827;
	bh=Q8F70PfGUPFMkg46eag7n8haR9IEuezW96YUisQQldU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=j+3dpaNcGhIoPs2zyWDiUkssWMDqClrUTJ+rp415NJ2saSWcHl7buO12QRTju4VY8
	 vYZMVhxCdoGncdBOXqX9CM1s27Jky9j/qS5GcBPIO0RITIPGbJTWP1owHXOCiWNLaK
	 9n12l/FU6OG4hPny+wWzLu8lmcp5eCNrA4BzZ43VJKT9lVBoJMQXXP/Fe3QCysbWQe
	 r6RvahDiGaAYuqlNcOatGoeb3bNohwqkxjm1sskdK21RkUQ9iyyZ+52xoQKd7fl+Co
	 3JoZUNUJJWBxVvAQF8cmk4AmoXTXM7RikUR/i6uV2FUgBYqhn5bkTa9NE0LDsqG9Cz
	 8TlktEB/24xGA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 16/33] NFSD: Use xdrgen XDR functions for NFSv3 MKDIR procedure
Date: Thu, 24 Sep 2026 13:09:55 -0400
Message-ID: <20260924171012.3978-17-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260924171012.3978-1-cel@kernel.org>
References: <20260924171012.3978-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Replace the NFSPROC3_MKDIR entry in the nfsd_procedures3 array
with an entry that dispatches the xdrgen-generated
nfs_svc_decode_MKDIR3args and nfs_svc_encode_MKDIR3res. Wrapper
structures bridge the generated xdrgen types and the legacy
svc_fh and iattr representations the NFSD VFS layer still uses.

Filename validity is now checked by nfsd3_proc_mkdir() so that a
proper NFS3ERR status code can be returned to the client rather
than GARBAGE_ARGS.

The pc_argzero field is now set to zero for the NFSv3 MKDIR
procedure. The xdrgen decoders are trusted to initialize all
arguments in the argp->xdrgen field, making the early defensive
memset unnecessary. The remaining argp fields are cleared as
needed.

Because nfsd3_proc_mkdir() now fills in the post-op file handle,
the post-op attributes, and the WCC data, the fh_getattr() calls
are made in the proc function rather than in the XDR result
encoder, and the references to the file handles can be released
directly by nfsd3_proc_mkdir(). A separate ->pc_release callback
is thus no longer needed. This makes it straightforward to
confirm that the file handles are properly released during every
error flow.

nfs3svc_decode_mkdirargs() no longer has any callers, so it is
removed.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs3proc.c | 102 +++++++++++++++++++++++++++++++++------------
 fs/nfsd/nfs3xdr.c  |  10 -----
 fs/nfsd/xdr3.h     |  10 -----
 3 files changed, 75 insertions(+), 47 deletions(-)

diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index eb8773e6ae17..64e5be5fecee 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -115,6 +115,22 @@ struct CREATE3res_wrapper {
 
 static_assert(offsetof(struct CREATE3res_wrapper, xdrgen) == 0);
 
+struct MKDIR3args_wrapper {
+	struct MKDIR3args	xdrgen;
+	struct svc_fh		fh;
+	struct iattr		iattrs;
+};
+
+static_assert(offsetof(struct MKDIR3args_wrapper, xdrgen) == 0);
+
+struct MKDIR3res_wrapper {
+	struct MKDIR3res	xdrgen;
+	struct svc_fh		fh;
+	u8			fh_data[NFS3_FHSIZE];
+};
+
+static_assert(offsetof(struct MKDIR3res_wrapper, xdrgen) == 0);
+
 static int	nfs3_ftypes[] = {
 	0,			/* NF3NON */
 	S_IFREG,		/* NF3REG */
@@ -985,29 +1001,61 @@ static __be32 nfsd3_proc_create(struct svc_rqst *rqstp)
 	return rpc_success;
 }
 
-/*
- * Make directory. This operation is not idempotent.
+/**
+ * nfsd3_proc_mkdir - MKDIR: Create a directory
+ * @rqstp: RPC transaction context
+ *
+ * Return:
+ *   %rpc_success:		RPC executed successfully
+ *
+ * RPC synopsis:
+ *   MKDIR3res NFSPROC3_MKDIR(MKDIR3args) = 9;
  */
-static __be32
-nfsd3_proc_mkdir(struct svc_rqst *rqstp)
+static __be32 nfsd3_proc_mkdir(struct svc_rqst *rqstp)
 {
-	struct nfsd3_createargs *argp = rqstp->rq_argp;
-	struct nfsd3_diropres *resp = rqstp->rq_resp;
-	struct nfsd_attrs attrs = {
-		.na_iattr	= &argp->attrs,
+	struct MKDIR3args_wrapper *argp = rqstp->rq_argp;
+	struct diropargs3 *where = &argp->xdrgen.where;
+	struct MKDIR3res_wrapper *resp = rqstp->rq_resp;
+	struct iattr *iattrs = &argp->iattrs;
+	struct svc_fh *dirfhp = &argp->fh;
+	struct svc_fh *fhp = &resp->fh;
+	struct nfsd_attrs nattrs = {
+		.na_iattr	= iattrs,
 	};
 
-	argp->attrs.ia_valid &= ~ATTR_SIZE;
-	fh_copy(&resp->dirfh, &argp->fh);
-	fh_init(&resp->fh, NFS3_FHSIZE);
-	if (!nfsd3_time_in_range(&argp->attrs)) {
-		resp->status = nfserr_inval;
+	nfsd3_fh3_to_svc_fh(dirfhp, &where->dir);
+	resp->xdrgen.status = nfsd3_check_filename(where->name.data,
+						   where->name.len);
+	if (resp->xdrgen.status != nfs_ok)
+		goto out;
+	nfsd3_sattr3_to_iattr(rqstp, iattrs, &argp->xdrgen.attributes);
+	if (!nfsd3_time_in_range(iattrs)) {
+		resp->xdrgen.status = nfserr_inval;
 		goto out;
 	}
-	resp->status = nfsd_create(rqstp, &resp->dirfh, argp->name, argp->len,
-				   &attrs, S_IFDIR, 0, &resp->fh);
+
+	fh_init(fhp, NFS3_FHSIZE);
+	iattrs->ia_valid &= ~ATTR_SIZE;
+	resp->xdrgen.status = nfsd_create(rqstp, dirfhp, (char *)where->name.data,
+					  where->name.len, &nattrs, S_IFDIR,
+					  0, fhp);
+
 out:
-	resp->status = nfsd3_map_status(resp->status);
+	if (resp->xdrgen.status == nfs_ok) {
+		struct MKDIR3resok *resok = &resp->xdrgen.u.resok;
+
+		nfsd3_fill_post_op_fh3(&resok->obj, fhp, resp->fh_data);
+		nfsd3_fill_post_op_attr(rqstp, &resok->obj_attributes, fhp);
+		nfsd3_fill_wcc_data(rqstp, &resok->dir_wcc, dirfhp);
+	} else {
+		struct MKDIR3resfail *resfail = &resp->xdrgen.u.resfail;
+
+		resp->xdrgen.status = nfsd3_map_status(resp->xdrgen.status);
+		nfsd3_fill_wcc_data(rqstp, &resfail->dir_wcc, dirfhp);
+	}
+
+	fh_put(fhp);
+	fh_put(dirfhp);
 	return rpc_success;
 }
 
@@ -1407,7 +1455,6 @@ nfsd3_proc_commit(struct svc_rqst *rqstp)
  * Only the results of non-idempotent operations are cached.
  */
 #define nfs3svc_encode_wccstatres	nfs3svc_encode_wccstat
-#define nfsd3_mkdirargs			nfsd3_createargs
 #define nfsd3_readdirplusargs		nfsd3_readdirargs
 #define nfsd3_fhandleargs		nfsd_fhandle
 #define nfsd3_wccstatres		nfsd3_attrstat
@@ -1522,16 +1569,15 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 		.pc_name	= "CREATE",
 	},
 	[NFSPROC3_MKDIR] = {
-		.pc_func = nfsd3_proc_mkdir,
-		.pc_decode = nfs3svc_decode_mkdirargs,
-		.pc_encode = nfs3svc_encode_createres,
-		.pc_release = nfs3svc_release_fhandle2,
-		.pc_argsize = sizeof(struct nfsd3_mkdirargs),
-		.pc_argzero = sizeof(struct nfsd3_mkdirargs),
-		.pc_ressize = sizeof(struct nfsd3_diropres),
-		.pc_cachetype = RC_REPLBUFF,
-		.pc_xdrressize = ST+(1+FH+pAT)+WC,
-		.pc_name = "MKDIR",
+		.pc_func	= nfsd3_proc_mkdir,
+		.pc_decode	= nfs_svc_decode_MKDIR3args,
+		.pc_encode	= nfs_svc_encode_MKDIR3res,
+		.pc_argsize	= sizeof(struct MKDIR3args_wrapper),
+		.pc_argzero	= 0,
+		.pc_ressize	= sizeof(struct MKDIR3res_wrapper),
+		.pc_cachetype	= RC_REPLBUFF,
+		.pc_xdrressize	= NFS3_MKDIR3res_sz,
+		.pc_name	= "MKDIR",
 	},
 	[NFSPROC3_SYMLINK] = {
 		.pc_func = nfsd3_proc_symlink,
@@ -1692,6 +1738,8 @@ union nfsd3_xdrstore {
 	struct WRITE3args_wrapper	writeargs;
 	struct CREATE3args_wrapper	createargs;
 	struct CREATE3res_wrapper	createres;
+	struct MKDIR3args_wrapper	mkdirargs;
+	struct MKDIR3res_wrapper	mkdirres;
 	struct nfsd3_renameargs		renameargs;
 	struct nfsd3_linkargs		linkargs;
 	struct nfsd3_symlinkargs	symlinkargs;
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index 1bdfe5398031..67cf76c13636 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -490,16 +490,6 @@ nfs3svc_decode_diropargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 	return svcxdr_decode_diropargs3(xdr, &args->fh, &args->name, &args->len);
 }
 
-bool
-nfs3svc_decode_mkdirargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd3_createargs *args = rqstp->rq_argp;
-
-	return svcxdr_decode_diropargs3(xdr, &args->fh,
-					&args->name, &args->len) &&
-		svcxdr_decode_sattr3(rqstp, xdr, &args->attrs);
-}
-
 bool
 nfs3svc_decode_symlinkargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 {
diff --git a/fs/nfsd/xdr3.h b/fs/nfsd/xdr3.h
index 30347cce5517..c8d22a1be9d6 100644
--- a/fs/nfsd/xdr3.h
+++ b/fs/nfsd/xdr3.h
@@ -30,15 +30,6 @@ struct nfsd3_accessargs {
 	__u32			access;
 };
 
-struct nfsd3_createargs {
-	struct svc_fh		fh;
-	char *			name;
-	unsigned int		len;
-	int			createmode;
-	struct iattr		attrs;
-	__be32 *		verf;
-};
-
 struct nfsd3_mknodargs {
 	struct svc_fh		fh;
 	char *			name;
@@ -207,7 +198,6 @@ struct nfsd3_fhandle_pair {
 
 bool nfs3svc_decode_fhandleargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_diropargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-bool nfs3svc_decode_mkdirargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_mknodargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_renameargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_linkargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-- 
2.55.0


Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2E3A535DA6E
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2026 12:49:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791895780; cv=none; b=AReE5QJPhFRrM8UeFDmfE7gZUVXRBH98efzSVwfQ/fiRfKF9bWkv/dDbStr0Sal+bitPeTIB8TTMzU0KvI7ex977Q3JMYpKUp56REVVKHi8qWzAZSNRrdylsfWqakgN1g+AoIoMr7MSa3X+1PIjiU30nK+S3AskbcVxnPjEvt4o=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791895780; c=relaxed/simple;
	bh=Gxs1nrWy3ck3HlFB8Il5UiWHZu25OpMAdyJxugClI9g=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=swD5j5J4XHE37QFFHWYWY5m9xp1RRcI690sGt0U+c+93Gt0roJPve0WfzK7d+Kei6WJ1gWCTmO3t+dwEb26xeKNxb0W5cJPqm3NkzGQMUhsxGHoH0R4BEuDH59HnByodDmN/iw9NrI3Dr2ptb7QvS0ivZ3qpB5dOrE/Xfrlaylk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=YWOQQbBr; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="YWOQQbBr"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8B6941F000FF;
	Tue, 13 Oct 2026 12:49:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791895779;
	bh=RPhMSojKEZ/y55oPUwo5EvtfK3UKu3NkAGMCupjHPqY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=YWOQQbBru2k24ch3TzioiAX/h7FGiiOGFmNcrTrUzNhIdIEL3NC9HBXWcDn3I0WgY
	 lSzpvk+auDcyvBNTASzgf/eY3Cgi1o4idwOqLouyPgFWQjY9eMsANkzQ2EeHSyqSMM
	 bRxEG1/aeLbDbQx2RujYIw4EOrOWwfY49i48kXqALuebLNzNVKpMXcsGXw6vlhJ4p7
	 NfpEgGvgGUlphTsuCmaQrIDx1WlXhY2FEJLmi8PttBZjWaVDiwOoy+LGmVFIaNWOy/
	 0uMTS301C98I+Muw9BmjLGQ15CuD1ZLPo5X99CGWWO6yiO7m1QRFsFmEy1mDOtcU1S
	 +WKZd78z7/Dcw==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 16/34] NFSD: Use xdrgen XDR functions for NFSv3 MKDIR procedure
Date: Tue, 13 Oct 2026 08:49:30 -0400
Message-ID: <20261013124933.316765-7-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20261013124933.316765-1-cel@kernel.org>
References: <20261013124933.316765-1-cel@kernel.org>
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
index 6f7b5b1d7f20..94751f50248a 100644
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
@@ -983,29 +999,61 @@ static __be32 nfsd3_proc_create(struct svc_rqst *rqstp)
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
 
@@ -1405,7 +1453,6 @@ nfsd3_proc_commit(struct svc_rqst *rqstp)
  * Only the results of non-idempotent operations are cached.
  */
 #define nfs3svc_encode_wccstatres	nfs3svc_encode_wccstat
-#define nfsd3_mkdirargs			nfsd3_createargs
 #define nfsd3_readdirplusargs		nfsd3_readdirargs
 #define nfsd3_fhandleargs		nfsd_fhandle
 #define nfsd3_wccstatres		nfsd3_attrstat
@@ -1520,16 +1567,15 @@ static const struct svc_procedure nfsd_procedures3[22] = {
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
@@ -1690,6 +1736,8 @@ union nfsd3_xdrstore {
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


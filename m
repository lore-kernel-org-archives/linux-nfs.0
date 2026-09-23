Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C69005304B2
	for <linux-nfs@vger.kernel.org>; Wed, 23 Sep 2026 13:28:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790170106; cv=none; b=C3l83JpVHoc02WMA/dME/f+Xwod4/AvhzIEjcOPfCwHNuDtjUlPAz44MEfppUzn8W01xdjjsp8PsqHSaptbtq6EUspGaLwMaIeLq2RHRYAef3ZT4QWOmLU6aYuuqrfuhoNN3VsX+h8dJgcx7e5rvUXDYyIdIBxW8llhhlumo674=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790170106; c=relaxed/simple;
	bh=KfICAiuQujJx2siQxpRIej7KB09vMGlMLgwfzbhMr1A=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=SxkWhrcQ16Mc4tcKZFrJXYyryTDo2p3afN2qN0fnFo20AQSUsPDccv371MJ2OBmtmGptgsOEuFLXUajP4YCVUZCYKVtSQy4J8WemFNIpE48M/DL28WtUmufoqWN8LCSlaHewy2B+uuSu7d5Ot8nIpJbnTx22Dg6BOr0VihHZXqM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=isjmZRUh; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="isjmZRUh"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 16A9C1F0089B;
	Wed, 23 Sep 2026 13:28:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790170104;
	bh=l9X9yLSXdImAidljD2w6pBkb9lQ39rGbe7fJWf9GxvY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=isjmZRUh6BIAORrPHLKS9tUjZl/IIpNGBoSWN2wU1MMOwE9DZXAR/cE27rMPtyEn2
	 PdWwSvOqJTohhvc+O0FXH1DPtqMLiqdift6qPja1KIpD00jAgkCcvDgVFFmb8cKX/v
	 /RFHYKNqBhUQlx/Rpb9Z+dv7kzUi9ODLk3eqc8Swaj1vzqOfWVCi8CEzdIChV5ZFEb
	 mwEFBn1KN8QPgH4wVVd18ApjZPbaukSMtA99o/yAw80EyHK5MaHNbVESUBxqVZcRY4
	 JbdVUGIGTGwdE79Mlv7WVFd4SFI74c0nmKHHEL4utgBESQI9yoAkUH5eyd0zEtTdVe
	 uxm0Hxs0OXHiQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 11/33] NFSD: Use xdrgen XDR functions for NFSv3 ACCESS procedure
Date: Wed, 23 Sep 2026 09:27:49 -0400
Message-ID: <20260923132811.244160-12-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260923132811.244160-1-cel@kernel.org>
References: <20260923132811.244160-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Replace the NFSPROC3_ACCESS entry in the nfsd_procedures3 array
with an entry that dispatches the xdrgen-generated
nfs_svc_decode_ACCESS3args and nfs_svc_encode_ACCESS3res. Wrapper
structures bridge the generated xdrgen types and the legacy svc_fh
representation the NFSD VFS layer still uses.

The pc_argzero field is now set to zero for the NFSv3 ACCESS
procedure. The xdrgen decoders are trusted to initialize all
arguments in the argp->xdrgen field, making the early defensive
memset unnecessary. The remaining argp fields are cleared as
needed.

Because nfsd3_proc_access() now fills in the post-op attributes,
the fh_getattr() calls are made in the proc function rather than in
the XDR result encoder, and the reference to the file handle can be
released directly by nfsd3_proc_access(). A separate ->pc_release
callback is thus no longer needed. This makes it straightforward to
confirm that the file handle is properly released during every
error flow.

nfs3svc_decode_accessargs() and nfs3svc_encode_accessres() no
longer have any callers, so they are removed.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs3proc.c | 73 ++++++++++++++++++++++++++++++----------------
 fs/nfsd/nfs3xdr.c  | 36 -----------------------
 fs/nfsd/xdr3.h     |  1 -
 3 files changed, 48 insertions(+), 62 deletions(-)

diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 735b4fc21336..5182108999b5 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -71,6 +71,13 @@ struct LOOKUP3res_wrapper {
 
 static_assert(offsetof(struct LOOKUP3res_wrapper, xdrgen) == 0);
 
+struct ACCESS3args_wrapper {
+	struct ACCESS3args	xdrgen;
+	struct svc_fh		fh;
+};
+
+static_assert(offsetof(struct ACCESS3args_wrapper, xdrgen) == 0);
+
 static int	nfs3_ftypes[] = {
 	0,			/* NF3NON */
 	S_IFREG,		/* NF3REG */
@@ -545,24 +552,40 @@ static __be32 nfsd3_proc_lookup(struct svc_rqst *rqstp)
 	return rpc_success;
 }
 
-/*
- * Check file access
+/**
+ * nfsd3_proc_access - ACCESS: Check access permission
+ * @rqstp: RPC transaction context
+ *
+ * Return:
+ *   %rpc_success:		RPC executed successfully
+ *
+ * RPC synopsis:
+ *   ACCESS3res NFSPROC3_ACCESS(ACCESS3args) = 4;
  */
-static __be32
-nfsd3_proc_access(struct svc_rqst *rqstp)
+static __be32 nfsd3_proc_access(struct svc_rqst *rqstp)
 {
-	struct nfsd3_accessargs *argp = rqstp->rq_argp;
-	struct nfsd3_accessres *resp = rqstp->rq_resp;
+	struct ACCESS3args_wrapper *argp = rqstp->rq_argp;
+	struct ACCESS3res *resp = rqstp->rq_resp;
+	struct svc_fh *fhp = &argp->fh;
 
-	dprintk("nfsd: ACCESS(3)   %s 0x%x\n",
-				SVCFH_fmt(&argp->fh),
-				argp->access);
+	nfsd3_fh3_to_svc_fh(fhp, &argp->xdrgen.object);
 
-	fh_copy(&resp->fh, &argp->fh);
-	resp->access = argp->access;
-	resp->status = nfsd_access(rqstp, &resp->fh, &nfsd3_access_maps,
-				   &resp->access, NULL);
-	resp->status = nfsd3_map_status(resp->status);
+	resp->status = nfsd_access(rqstp, fhp, &nfsd3_access_maps,
+				   &argp->xdrgen.access, NULL);
+
+	if (resp->status == nfs_ok) {
+		struct ACCESS3resok *resok = &resp->u.resok;
+
+		resok->access = argp->xdrgen.access;
+		nfsd3_fill_post_op_attr(rqstp, &resok->obj_attributes, fhp);
+	} else {
+		struct ACCESS3resfail *resfail = &resp->u.resfail;
+
+		resp->status = nfsd3_map_status(resp->status);
+		nfsd3_fill_post_op_attr(rqstp, &resfail->obj_attributes, fhp);
+	}
+
+	fh_put(fhp);
 	return rpc_success;
 }
 
@@ -1298,16 +1321,15 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 		.pc_name	= "LOOKUP",
 	},
 	[NFSPROC3_ACCESS] = {
-		.pc_func = nfsd3_proc_access,
-		.pc_decode = nfs3svc_decode_accessargs,
-		.pc_encode = nfs3svc_encode_accessres,
-		.pc_release = nfs3svc_release_fhandle,
-		.pc_argsize = sizeof(struct nfsd3_accessargs),
-		.pc_argzero = sizeof(struct nfsd3_accessargs),
-		.pc_ressize = sizeof(struct nfsd3_accessres),
-		.pc_cachetype = RC_NOCACHE,
-		.pc_xdrressize = ST+pAT+1,
-		.pc_name = "ACCESS",
+		.pc_func	= nfsd3_proc_access,
+		.pc_decode	= nfs_svc_decode_ACCESS3args,
+		.pc_encode	= nfs_svc_encode_ACCESS3res,
+		.pc_argsize	= sizeof(struct ACCESS3args_wrapper),
+		.pc_argzero	= 0,
+		.pc_ressize	= sizeof(struct ACCESS3res),
+		.pc_cachetype	= RC_NOCACHE,
+		.pc_xdrressize	= NFS3_ACCESS3res_sz,
+		.pc_name	= "ACCESS",
 	},
 	[NFSPROC3_READLINK] = {
 		.pc_func = nfsd3_proc_readlink,
@@ -1520,6 +1542,8 @@ union nfsd3_xdrstore {
 	struct SETATTR3res		setattrres;
 	struct LOOKUP3args_wrapper	lookupargs;
 	struct LOOKUP3res_wrapper	lookupres;
+	struct ACCESS3args_wrapper	accessargs;
+	struct ACCESS3res		accessres;
 	struct nfsd3_diropargs		diropargs;
 	struct nfsd3_readargs		readargs;
 	struct nfsd3_writeargs		writeargs;
@@ -1529,7 +1553,6 @@ union nfsd3_xdrstore {
 	struct nfsd3_symlinkargs	symlinkargs;
 	struct nfsd3_readdirargs	readdirargs;
 	struct nfsd3_diropres 		diropres;
-	struct nfsd3_accessres		accessres;
 	struct nfsd3_readlinkres	readlinkres;
 	struct nfsd3_readres		readres;
 	struct nfsd3_writeres		writeres;
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index 36c22611370d..f3f723215114 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -490,19 +490,6 @@ nfs3svc_decode_diropargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 	return svcxdr_decode_diropargs3(xdr, &args->fh, &args->name, &args->len);
 }
 
-bool
-nfs3svc_decode_accessargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd3_accessargs *args = rqstp->rq_argp;
-
-	if (!svcxdr_decode_nfs_fh3(xdr, &args->fh))
-		return false;
-	if (xdr_stream_decode_u32(xdr, &args->access) < 0)
-		return false;
-
-	return true;
-}
-
 bool
 nfs3svc_decode_readargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 {
@@ -721,29 +708,6 @@ nfs3svc_encode_wccstat(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 		svcxdr_encode_wcc_data(rqstp, xdr, &resp->fh);
 }
 
-/* ACCESS */
-bool
-nfs3svc_encode_accessres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd3_accessres *resp = rqstp->rq_resp;
-
-	if (!svcxdr_encode_nfsstat3(xdr, resp->status))
-		return false;
-	switch (resp->status) {
-	case nfs_ok:
-		if (!svcxdr_encode_post_op_attr(rqstp, xdr, &resp->fh))
-			return false;
-		if (xdr_stream_encode_u32(xdr, resp->access) < 0)
-			return false;
-		break;
-	default:
-		if (!svcxdr_encode_post_op_attr(rqstp, xdr, &resp->fh))
-			return false;
-	}
-
-	return true;
-}
-
 /* READLINK */
 bool
 nfs3svc_encode_readlinkres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
diff --git a/fs/nfsd/xdr3.h b/fs/nfsd/xdr3.h
index d17192f3c983..bb23c444c23d 100644
--- a/fs/nfsd/xdr3.h
+++ b/fs/nfsd/xdr3.h
@@ -238,7 +238,6 @@ struct nfsd3_fhandle_pair {
 
 bool nfs3svc_decode_fhandleargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_diropargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-bool nfs3svc_decode_accessargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_readargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_writeargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_createargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-- 
2.55.0


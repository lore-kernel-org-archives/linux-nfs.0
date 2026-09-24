Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7F3214AC15B
	for <linux-nfs@vger.kernel.org>; Thu, 24 Sep 2026 17:10:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790269837; cv=none; b=VFYS6wtHOOj6dSPjRnL7O6ufGmfN3xvqcj4wytCZCvEzpg7ZiVCyZN9B/0Yv9Apgr1xBthsqy3X0Sr6eRW0pgqzhEHE9cu8jsAvzFn1J0etdkkjIKhC00J53X9EGWRwHpraQ1Q2tonW3rDj/FqxDQ+MOniXOJVNg3MORke4SxWs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790269837; c=relaxed/simple;
	bh=OQjl/MmdpC9/kUKuDQ8VyT0C8pL+adZOiiOPysl/3S4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Ac0QZhReLJZHcBy/XTDvRloNV5Il/AlKeABsHMXpRLkK4fmwSQAQ2gZaVwJPYdVxM0CSo0/yXFljbICZSdbVEV4sD46C0IVKVM/9Dw/P6bH8uiWcHHs/02aoHuD8Ua5ijv838epjjXGFnQnPfEHfA+gZj8XrDOUWK7jxQJGhPSk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=D1Pxme5j; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="D1Pxme5j"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DA1DB1F00899;
	Thu, 24 Sep 2026 17:10:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790269835;
	bh=aZukk2VPcXg9WLDvRyaHJzAaMXRiZmJpMUOMI9B31Gs=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=D1Pxme5j+XOMXWv7pWPTNYaotVN8VkQT9D10y4IlEKy5EhflSacTuV2WaaxumxvHq
	 7uE49OuqNfjlzVTEYEOIHLvs0gpiDKVQOgjOrvdnT8YDb6b6uwmhBTWPMTpLKiRFgH
	 GdU60CN1uxZ3VahkJtgLSkdigmAIKQRen41FaY52Zy5cvpX7Wqr+aNXjBGNl2u2x9g
	 B62yuILqSQkIZG8jfa8zbt1ra95KRVgSAwFtphT3Av0NvxCGVWszxI+90rg9fuXa0A
	 cGLpsx8y/vYMB9Svk1dJqu8LqsqxafjzCZoLuktN6evLFxIGmM9SlhTkHO4/yyyQiA
	 EM6BXNXTU437w==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 26/33] NFSD: Use xdrgen XDR functions for the NFSv3 COMMIT procedure
Date: Thu, 24 Sep 2026 13:10:05 -0400
Message-ID: <20260924171012.3978-27-cel@kernel.org>
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

Replace the NFSPROC3_COMMIT entry in the nfsd_procedures3 array with
an entry that dispatches the xdrgen-generated
nfs_svc_decode_COMMIT3args and nfs_svc_encode_COMMIT3res. A wrapper
structure bridges the generated xdrgen argument type and the legacy
svc_fh representation the NFSD VFS layer still uses.

The pc_argzero field is now set to zero for the NFSv3 COMMIT
procedure. The xdrgen decoders are trusted to initialize all
arguments in the argp->xdrgen field, making the early defensive
memset unnecessary. The remaining argp fields are cleared as needed.

Because nfsd3_proc_commit() now fills in the WCC data, including
both the pre-op and post-op attributes, the fh_getattr() calls are
made in the proc function rather than in the XDR result encoder, and
the reference to the file handle can be released directly by
nfsd3_proc_commit(). A separate ->pc_release callback is thus no
longer needed. This makes it straightforward to confirm that the
file handle is properly released during every error flow.

nfs3svc_decode_commitargs() and nfs3svc_encode_commitres() no longer
have any callers, so they are removed. COMMIT was the last caller of
the hand-written WCC encoders, so svcxdr_encode_wcc_data() and its
svcxdr_encode_pre_op_attr() and svcxdr_encode_wcc_attr() helpers are
removed as well, along with the now-orphaned svcxdr_encode_writeverf3()
encode helper.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs3proc.c |  80 +++++++++++++++++++-------------
 fs/nfsd/nfs3xdr.c  | 113 ---------------------------------------------
 fs/nfsd/xdr3.h     |  14 ++----
 3 files changed, 52 insertions(+), 155 deletions(-)

diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index c4b6ccb3a74e..68bf988476cf 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -211,6 +211,13 @@ struct PATHCONF3args_wrapper {
 
 static_assert(offsetof(struct PATHCONF3args_wrapper, xdrgen) == 0);
 
+struct COMMIT3args_wrapper {
+	struct COMMIT3args	xdrgen;
+	struct svc_fh		fh;
+};
+
+static_assert(offsetof(struct COMMIT3args_wrapper, xdrgen) == 0);
+
 static int nfsd3_ftype3_to_mode(ftype3 ftype)
 {
 	switch (ftype) {
@@ -1758,31 +1765,47 @@ static __be32 nfsd3_proc_pathconf(struct svc_rqst *rqstp)
 	return rpc_success;
 }
 
-/*
- * Commit a file (range) to stable storage.
+/**
+ * nfsd3_proc_commit - COMMIT: Commit cached data on a server to stable storage
+ * @rqstp: RPC transaction context
+ *
+ * Return:
+ *   %rpc_success:		RPC executed successfully
+ *
+ * RPC synopsis:
+ *   COMMIT3res NFSPROC3_COMMIT(COMMIT3args) = 21;
  */
-static __be32
-nfsd3_proc_commit(struct svc_rqst *rqstp)
+static __be32 nfsd3_proc_commit(struct svc_rqst *rqstp)
 {
-	struct nfsd3_commitargs *argp = rqstp->rq_argp;
+	struct COMMIT3args_wrapper *argp = rqstp->rq_argp;
 	struct nfsd3_commitres *resp = rqstp->rq_resp;
+	struct svc_fh *fhp = &argp->fh;
 	struct nfsd_file *nf;
 
-	dprintk("nfsd: COMMIT(3)   %s %u@%Lu\n",
-				SVCFH_fmt(&argp->fh),
-				argp->count,
-				(unsigned long long) argp->offset);
+	nfsd3_fh3_to_svc_fh(fhp, &argp->xdrgen.file);
 
-	fh_copy(&resp->fh, &argp->fh);
-	resp->status = nfsd_file_acquire_gc(rqstp, &resp->fh, NFSD_MAY_WRITE |
-					    NFSD_MAY_NOT_BREAK_LEASE, &nf);
-	if (resp->status)
+	resp->xdrgen.status = nfsd_file_acquire_gc(rqstp, fhp, NFSD_MAY_WRITE |
+						   NFSD_MAY_NOT_BREAK_LEASE, &nf);
+	if (resp->xdrgen.status)
 		goto out;
-	resp->status = nfsd_commit(rqstp, &resp->fh, nf, argp->offset,
-				   argp->count, resp->verf);
+	resp->xdrgen.status = nfsd_commit(rqstp, fhp, nf,
+					  argp->xdrgen.offset, argp->xdrgen.count,
+					  (__be32 *)resp->xdrgen.u.resok.verf);
 	nfsd_file_put(nf);
+
 out:
-	resp->status = nfsd3_map_status(resp->status);
+	if (resp->xdrgen.status == nfs_ok) {
+		struct COMMIT3resok *resok = &resp->xdrgen.u.resok;
+
+		nfsd3_fill_wcc_data(rqstp, &resok->file_wcc, fhp);
+	} else {
+		struct COMMIT3resfail *resfail = &resp->xdrgen.u.resfail;
+
+		resp->xdrgen.status = nfsd3_map_status(resp->xdrgen.status);
+		nfsd3_fill_wcc_data(rqstp, &resfail->file_wcc, fhp);
+	}
+
+	fh_put(fhp);
 	return rpc_success;
 }
 
@@ -1793,11 +1816,6 @@ nfsd3_proc_commit(struct svc_rqst *rqstp)
  */
 #define nfsd3_readdirplusargs		nfsd3_readdirargs
 
-#define ST 1		/* status*/
-#define AT 21		/* attributes */
-#define pAT (1+AT)	/* post attributes - conditional */
-#define WC (7+pAT)	/* WCC attributes */
-
 static const struct svc_procedure nfsd_procedures3[22] = {
 	[NFSPROC3_NULL] = {
 		.pc_func	= nfsd3_proc_null,
@@ -2034,16 +2052,15 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 		.pc_name	= "PATHCONF",
 	},
 	[NFSPROC3_COMMIT] = {
-		.pc_func = nfsd3_proc_commit,
-		.pc_decode = nfs3svc_decode_commitargs,
-		.pc_encode = nfs3svc_encode_commitres,
-		.pc_release = nfs3svc_release_fhandle,
-		.pc_argsize = sizeof(struct nfsd3_commitargs),
-		.pc_argzero = sizeof(struct nfsd3_commitargs),
-		.pc_ressize = sizeof(struct nfsd3_commitres),
-		.pc_cachetype = RC_NOCACHE,
-		.pc_xdrressize = ST+WC+2,
-		.pc_name = "COMMIT",
+		.pc_func	= nfsd3_proc_commit,
+		.pc_decode	= nfs_svc_decode_COMMIT3args,
+		.pc_encode	= nfs_svc_encode_COMMIT3res,
+		.pc_argsize	= sizeof(struct COMMIT3args_wrapper),
+		.pc_argzero	= 0,
+		.pc_ressize	= sizeof(struct nfsd3_commitres),
+		.pc_cachetype	= RC_NOCACHE,
+		.pc_xdrressize	= NFS3_COMMIT3res_sz,
+		.pc_name	= "COMMIT",
 	},
 };
 
@@ -2089,6 +2106,7 @@ union nfsd3_xdrstore {
 	struct nfsd3_fsinfores		fsinfores;
 	struct PATHCONF3args_wrapper	pathconfargs;
 	struct nfsd3_pathconfres	pathconfres;
+	struct COMMIT3args_wrapper	commitargs;
 	struct nfsd3_commitres		commitres;
 	struct nfsd3_getaclres		getaclres;
 };
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index 3da66b5cac22..e93983d08aa5 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -133,19 +133,6 @@ svcxdr_encode_cookieverf3(struct xdr_stream *xdr, const __be32 *verf)
 	return true;
 }
 
-static bool
-svcxdr_encode_writeverf3(struct xdr_stream *xdr, const __be32 *verf)
-{
-	__be32 *p;
-
-	p = xdr_reserve_space(xdr, NFS3_WRITEVERFSIZE);
-	if (!p)
-		return false;
-	memcpy(p, verf, NFS3_WRITEVERFSIZE);
-
-	return true;
-}
-
 static bool
 svcxdr_encode_fattr3(struct svc_rqst *rqstp, struct xdr_stream *xdr,
 		     const struct svc_fh *fhp, const struct kstat *stat)
@@ -198,35 +185,6 @@ svcxdr_encode_fattr3(struct svc_rqst *rqstp, struct xdr_stream *xdr,
 	return true;
 }
 
-static bool
-svcxdr_encode_wcc_attr(struct xdr_stream *xdr, const struct svc_fh *fhp)
-{
-	__be32 *p;
-
-	p = xdr_reserve_space(xdr, XDR_UNIT * 6);
-	if (!p)
-		return false;
-	p = xdr_encode_hyper(p, (u64)fhp->fh_pre_size);
-	p = encode_nfstime3(p, &fhp->fh_pre_mtime);
-	encode_nfstime3(p, &fhp->fh_pre_ctime);
-
-	return true;
-}
-
-static bool
-svcxdr_encode_pre_op_attr(struct xdr_stream *xdr, const struct svc_fh *fhp)
-{
-	if (!fhp->fh_pre_saved) {
-		if (xdr_stream_encode_item_absent(xdr) < 0)
-			return false;
-		return true;
-	}
-
-	if (xdr_stream_encode_item_present(xdr) < 0)
-		return false;
-	return svcxdr_encode_wcc_attr(xdr, fhp);
-}
-
 /**
  * svcxdr_encode_post_op_attr - Encode NFSv3 post-op attributes
  * @rqstp: Context of a completed RPC transaction
@@ -266,39 +224,6 @@ svcxdr_encode_post_op_attr(struct svc_rqst *rqstp, struct xdr_stream *xdr,
 	return xdr_stream_encode_item_absent(xdr) > 0;
 }
 
-/*
- * Encode weak cache consistency data
- */
-static bool
-svcxdr_encode_wcc_data(struct svc_rqst *rqstp, struct xdr_stream *xdr,
-		       const struct svc_fh *fhp)
-{
-	struct dentry *dentry = fhp->fh_dentry;
-
-	if (!dentry || !d_really_is_positive(dentry) || !fhp->fh_post_saved)
-		goto neither;
-
-	/* before */
-	if (!svcxdr_encode_pre_op_attr(xdr, fhp))
-		return false;
-
-	/* after */
-	if (xdr_stream_encode_item_present(xdr) < 0)
-		return false;
-	if (!svcxdr_encode_fattr3(rqstp, xdr, fhp, &fhp->fh_post_attr))
-		return false;
-
-	return true;
-
-neither:
-	if (xdr_stream_encode_item_absent(xdr) < 0)
-		return false;
-	if (!svcxdr_encode_post_op_attr(rqstp, xdr, fhp))
-		return false;
-
-	return true;
-}
-
 /*
  * XDR decode functions
  */
@@ -343,21 +268,6 @@ nfs3svc_decode_readdirplusargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 	return true;
 }
 
-bool
-nfs3svc_decode_commitargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd3_commitargs *args = rqstp->rq_argp;
-
-	if (!svcxdr_decode_nfs_fh3(xdr, &args->fh))
-		return false;
-	if (xdr_stream_decode_u64(xdr, &args->offset) < 0)
-		return false;
-	if (xdr_stream_decode_u32(xdr, &args->count) < 0)
-		return false;
-
-	return true;
-}
-
 /*
  * XDR encode functions
  */
@@ -596,29 +506,6 @@ int nfs3svc_encode_entryplus3(void *data, const char *name, int namlen,
 	return -EINVAL;
 }
 
-/* COMMIT */
-bool
-nfs3svc_encode_commitres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd3_commitres *resp = rqstp->rq_resp;
-
-	if (!svcxdr_encode_nfsstat3(xdr, resp->status))
-		return false;
-	switch (resp->status) {
-	case nfs_ok:
-		if (!svcxdr_encode_wcc_data(rqstp, xdr, &resp->fh))
-			return false;
-		if (!svcxdr_encode_writeverf3(xdr, resp->verf))
-			return false;
-		break;
-	default:
-		if (!svcxdr_encode_wcc_data(rqstp, xdr, &resp->fh))
-			return false;
-	}
-
-	return true;
-}
-
 /*
  * XDR release functions
  */
diff --git a/fs/nfsd/xdr3.h b/fs/nfsd/xdr3.h
index 6428d9a190b0..e2110f9a126b 100644
--- a/fs/nfsd/xdr3.h
+++ b/fs/nfsd/xdr3.h
@@ -31,12 +31,6 @@ struct nfsd3_readdirargs {
 	__be32 *		verf;
 };
 
-struct nfsd3_commitargs {
-	struct svc_fh		fh;
-	__u64			offset;
-	__u32			count;
-};
-
 struct nfsd3_getaclargs {
 	struct svc_fh		fh;
 	__u32			mask;
@@ -105,11 +99,11 @@ struct nfsd3_pathconfres {
 static_assert(offsetof(struct nfsd3_pathconfres, xdrgen) == 0);
 
 struct nfsd3_commitres {
-	__be32			status;
-	struct svc_fh		fh;
-	__be32			verf[2];
+	struct COMMIT3res	xdrgen;
 };
 
+static_assert(offsetof(struct nfsd3_commitres, xdrgen) == 0);
+
 struct nfsd3_getaclres {
 	__be32			status;
 	struct svc_fh		fh;
@@ -121,11 +115,9 @@ struct nfsd3_getaclres {
 
 bool nfs3svc_decode_readdirargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_readdirplusargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-bool nfs3svc_decode_commitargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 
 bool nfs3svc_encode_accessres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_encode_readdirres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-bool nfs3svc_encode_commitres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 
 void nfs3svc_release_fhandle(struct svc_rqst *);
 
-- 
2.55.0


Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EE6A6501F4A
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2026 12:49:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791895789; cv=none; b=jS+nSTUd1a+MPgctnaSJ42WGvxXYK/SGKU8praZ5j140adQFR5v/GfxES9bY9/bkYDwRGzS5ecDKWBfJzzFkdKTxsMnrLATMzi/xDZ6qhOsrJJF90xFB2BBW16OHzqg+hFRC2Sn/Pkkn6UQTRkEvScRe4o8BkIcFuvLuY3T9mKc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791895789; c=relaxed/simple;
	bh=V62/Ngkvcli8bqLHgHjMIXJ1a5WLCkwSPZsTDbVBtFo=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=XXCZZmm2aqdBgdmCaHO7iTNnY3ljUSaHDu6FLtNj7cOSONP3BXuJwItgQwr/WbqXzbg2J/rhfP50CuHlykwlkUjQk4SUHpYH67vPRSgpW/tce5xkjct/jgtLVxtGdAozntbV1WtvaxurFjjvB6gnwmoUtpyp4ms1aROr9O3CPJs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=GaYwn5vm; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="GaYwn5vm"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 009E71F00899;
	Tue, 13 Oct 2026 12:49:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791895787;
	bh=8bDnKQ3C3v0mHX/A2SulA0Uz86AoO4Ag0al99jc5934=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=GaYwn5vmBocf308yHIHIVpCFwg0cq+6zdTj4joDFyDDE0yKMzPlgLZhKCfhXPSTgA
	 7nm8s9QaO7znzSEo6xSfQrdmgFgtNIqtyKnqi5N7RiBTmP7I9LLStG5l6ywa8yBeJm
	 w4AsBTdEhFoPQE+ZsY1/ugLqXXssvjbY6hVp1IdrMx0k8p1dp+SQfXU2lsUIdm98t3
	 EieHuyf8j0n3Qk22ZAw07ID01bbytVm5nqW4UsUbhs4l7myL2sRwFLH8rQSiyDAlID
	 Cc/kEEqSU52FB3/6HU3j5ewHIm4jHAOMdtdUkbWhGPDGJzfT1O6iRUEBGVNUCfVADu
	 zZpVYDlDlOJhA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 22/34] NFSD: Use xdrgen XDR functions for the NFSv3 LINK procedure
Date: Tue, 13 Oct 2026 08:49:37 -0400
Message-ID: <20261013124944.316808-3-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20261013124944.316808-1-cel@kernel.org>
References: <20261013124944.316808-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Replace the NFSPROC3_LINK entry in the nfsd_procedures3 array with
an entry that dispatches the xdrgen-generated nfs_svc_decode_LINK3args
and nfs_svc_encode_LINK3res. A wrapper structure bridges the
generated xdrgen argument type and the legacy svc_fh representation
the NFSD VFS layer still uses; the result uses the generated LINK3res
type directly.

Filename validity is now checked by nfsd3_proc_link() so that a
proper NFS3ERR status code can be returned to the client rather than
GARBAGE_ARGS.

The pc_argzero field is now set to zero for the NFSv3 LINK procedure.
The xdrgen decoders are trusted to initialize all arguments in the
argp->xdrgen field, making the early defensive memset unnecessary.
The remaining argp fields are cleared as needed.

Because nfsd3_proc_link() now fills in the post-op attributes and
assembles the WCC data, that work moves out of the XDR result
encoder, and the references to the file handles can be released
directly by nfsd3_proc_link(). A separate ->pc_release callback is
thus no longer needed. This makes it straightforward to confirm that
the file handles are properly released during every error flow.

nfs3svc_decode_linkargs(), nfs3svc_encode_linkres(), and
nfs3svc_release_fhandle2() no longer have any callers, so they are
removed, and with them the now-orphaned svcxdr_decode_filename3() and
svcxdr_decode_diropargs3() decode helpers and the struct
nfsd3_fhandle_pair release type.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs3proc.c | 82 ++++++++++++++++++++++++++++++++++------------
 fs/nfsd/nfs3xdr.c  | 63 -----------------------------------
 fs/nfsd/xdr3.h     | 23 -------------
 3 files changed, 61 insertions(+), 107 deletions(-)

diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 7fd968fdb145..76963187de20 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -185,6 +185,14 @@ struct RENAME3args_wrapper {
 
 static_assert(offsetof(struct RENAME3args_wrapper, xdrgen) == 0);
 
+struct LINK3args_wrapper {
+	struct LINK3args	xdrgen;
+	struct svc_fh		ffh;
+	struct svc_fh		tfh;
+};
+
+static_assert(offsetof(struct LINK3args_wrapper, xdrgen) == 0);
+
 static int nfsd3_ftype3_to_mode(ftype3 ftype)
 {
 	switch (ftype) {
@@ -1406,17 +1414,50 @@ static __be32 nfsd3_proc_rename(struct svc_rqst *rqstp)
 	return rpc_success;
 }
 
-static __be32
-nfsd3_proc_link(struct svc_rqst *rqstp)
+/**
+ * nfsd3_proc_link - LINK: Create Link to an object
+ * @rqstp: RPC transaction context
+ *
+ * Return:
+ *   %rpc_success:		RPC executed successfully
+ *
+ * RPC synopsis:
+ *   LINK3res NFSPROC3_LINK(LINK3args) = 15;
+ */
+static __be32 nfsd3_proc_link(struct svc_rqst *rqstp)
 {
-	struct nfsd3_linkargs *argp = rqstp->rq_argp;
-	struct nfsd3_linkres  *resp = rqstp->rq_resp;
+	struct LINK3args_wrapper *argp = rqstp->rq_argp;
+	struct diropargs3 *link = &argp->xdrgen.link;
+	struct LINK3res *resp = rqstp->rq_resp;
+	struct svc_fh *ffhp = &argp->ffh;
+	struct svc_fh *tfhp = &argp->tfh;
 
-	fh_copy(&resp->fh,  &argp->ffh);
-	fh_copy(&resp->tfh, &argp->tfh);
-	resp->status = nfsd_link(rqstp, &resp->tfh, argp->tname, argp->tlen,
-				 &resp->fh);
-	resp->status = nfsd3_map_status(resp->status);
+	nfsd3_fh3_to_svc_fh(ffhp, &argp->xdrgen.file);
+	nfsd3_fh3_to_svc_fh(tfhp, &link->dir);
+	resp->status = nfsd3_check_filename(link->name.data,
+					    link->name.len);
+	if (resp->status != nfs_ok)
+		goto out;
+
+	resp->status = nfsd_link(rqstp, tfhp, (char *)link->name.data,
+				 link->name.len, ffhp);
+
+out:
+	if (resp->status == nfs_ok) {
+		struct LINK3resok *resok = &resp->u.resok;
+
+		nfsd3_fill_post_op_attr(rqstp, &resok->file_attributes, ffhp);
+		nfsd3_fill_wcc_data(rqstp, &resok->linkdir_wcc, tfhp);
+	} else {
+		struct LINK3resfail *resfail = &resp->u.resfail;
+
+		resp->status = nfsd3_map_status(resp->status);
+		nfsd3_fill_post_op_attr(rqstp, &resfail->file_attributes, ffhp);
+		nfsd3_fill_wcc_data(rqstp, &resfail->linkdir_wcc, tfhp);
+	}
+
+	fh_put(ffhp);
+	fh_put(tfhp);
 	return rpc_success;
 }
 
@@ -1850,16 +1891,15 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 		.pc_name	= "RENAME",
 	},
 	[NFSPROC3_LINK] = {
-		.pc_func = nfsd3_proc_link,
-		.pc_decode = nfs3svc_decode_linkargs,
-		.pc_encode = nfs3svc_encode_linkres,
-		.pc_release = nfs3svc_release_fhandle2,
-		.pc_argsize = sizeof(struct nfsd3_linkargs),
-		.pc_argzero = sizeof(struct nfsd3_linkargs),
-		.pc_ressize = sizeof(struct nfsd3_linkres),
-		.pc_cachetype = RC_REPLBUFF,
-		.pc_xdrressize = ST+pAT+WC,
-		.pc_name = "LINK",
+		.pc_func	= nfsd3_proc_link,
+		.pc_decode	= nfs_svc_decode_LINK3args,
+		.pc_encode	= nfs_svc_encode_LINK3res,
+		.pc_argsize	= sizeof(struct LINK3args_wrapper),
+		.pc_argzero	= 0,
+		.pc_ressize	= sizeof(struct LINK3res),
+		.pc_cachetype	= RC_REPLBUFF,
+		.pc_xdrressize	= NFS3_LINK3res_sz,
+		.pc_name	= "LINK",
 	},
 	[NFSPROC3_READDIR] = {
 		.pc_func = nfsd3_proc_readdir,
@@ -1959,12 +1999,12 @@ union nfsd3_xdrstore {
 	struct RMDIR3res		rmdirres;
 	struct RENAME3args_wrapper	renameargs;
 	struct RENAME3res		renameres;
-	struct nfsd3_linkargs		linkargs;
+	struct LINK3args_wrapper	linkargs;
+	struct LINK3res			linkres;
 	struct nfsd3_readdirargs	readdirargs;
 	struct READLINK3res		readlinkres;
 	struct READ3res			readres;
 	struct nfsd3_writeres		writeres;
-	struct nfsd3_linkres		linkres;
 	struct nfsd3_readdirres		readdirres;
 	struct nfsd3_fsstatres		fsstatres;
 	struct nfsd3_fsinfores		fsinfores;
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index 3ec835e0f364..59e89b7f9d19 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -162,39 +162,6 @@ svcxdr_encode_writeverf3(struct xdr_stream *xdr, const __be32 *verf)
 	return true;
 }
 
-static bool
-svcxdr_decode_filename3(struct xdr_stream *xdr, char **name, unsigned int *len)
-{
-	u32 size, i;
-	__be32 *p;
-	char *c;
-
-	if (xdr_stream_decode_u32(xdr, &size) < 0)
-		return false;
-	if (size == 0 || size > NFS3_MAXNAMLEN)
-		return false;
-	p = xdr_inline_decode(xdr, size);
-	if (!p)
-		return false;
-
-	*len = size;
-	*name = (char *)p;
-	for (i = 0, c = *name; i < size; i++, c++) {
-		if (*c == '\0' || *c == '/')
-			return false;
-	}
-
-	return true;
-}
-
-static bool
-svcxdr_decode_diropargs3(struct xdr_stream *xdr, struct svc_fh *fhp,
-			 char **name, unsigned int *len)
-{
-	return svcxdr_decode_nfs_fh3(xdr, fhp) &&
-		svcxdr_decode_filename3(xdr, name, len);
-}
-
 static bool
 svcxdr_encode_fattr3(struct svc_rqst *rqstp, struct xdr_stream *xdr,
 		     const struct svc_fh *fhp, const struct kstat *stat)
@@ -360,16 +327,6 @@ nfs3svc_decode_fhandleargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 	return svcxdr_decode_nfs_fh3(xdr, &args->fh);
 }
 
-bool
-nfs3svc_decode_linkargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd3_linkargs *args = rqstp->rq_argp;
-
-	return svcxdr_decode_nfs_fh3(xdr, &args->ffh) &&
-		svcxdr_decode_diropargs3(xdr, &args->tfh,
-					 &args->tname, &args->tlen);
-}
-
 bool
 nfs3svc_decode_readdirargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 {
@@ -429,17 +386,6 @@ nfs3svc_decode_commitargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
  * XDR encode functions
  */
 
-/* LINK */
-bool
-nfs3svc_encode_linkres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd3_linkres *resp = rqstp->rq_resp;
-
-	return svcxdr_encode_nfsstat3(xdr, resp->status) &&
-		svcxdr_encode_post_op_attr(rqstp, xdr, &resp->fh) &&
-		svcxdr_encode_wcc_data(rqstp, xdr, &resp->tfh);
-}
-
 /* READDIR */
 bool
 nfs3svc_encode_readdirres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
@@ -840,12 +786,3 @@ nfs3svc_release_fhandle(struct svc_rqst *rqstp)
 
 	fh_put(&resp->fh);
 }
-
-void
-nfs3svc_release_fhandle2(struct svc_rqst *rqstp)
-{
-	struct nfsd3_fhandle_pair *resp = rqstp->rq_resp;
-
-	fh_put(&resp->fh1);
-	fh_put(&resp->fh2);
-}
diff --git a/fs/nfsd/xdr3.h b/fs/nfsd/xdr3.h
index 8a15781d7f3c..9a2bdd5a0da5 100644
--- a/fs/nfsd/xdr3.h
+++ b/fs/nfsd/xdr3.h
@@ -24,13 +24,6 @@ struct nfsd3_accessargs {
 	__u32			access;
 };
 
-struct nfsd3_linkargs {
-	struct svc_fh		ffh;
-	struct svc_fh		tfh;
-	char *			tname;
-	unsigned int		tlen;
-};
-
 struct nfsd3_readdirargs {
 	struct svc_fh		fh;
 	__u64			cookie;
@@ -76,12 +69,6 @@ struct nfsd3_writeres {
 
 static_assert(offsetof(struct nfsd3_writeres, xdrgen) == 0);
 
-struct nfsd3_linkres {
-	__be32			status;
-	struct svc_fh		tfh;
-	struct svc_fh		fh;
-};
-
 struct nfsd3_readdirres {
 	/* Components of the reply */
 	__be32			status;
@@ -142,21 +129,12 @@ struct nfsd3_getaclres {
 	struct kstat		stat;
 };
 
-/* dummy type for release */
-struct nfsd3_fhandle_pair {
-	__u32			dummy;
-	struct svc_fh		fh1;
-	struct svc_fh		fh2;
-};
-
 bool nfs3svc_decode_fhandleargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-bool nfs3svc_decode_linkargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_readdirargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_readdirplusargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_commitargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 
 bool nfs3svc_encode_accessres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-bool nfs3svc_encode_linkres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_encode_readdirres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_encode_fsstatres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_encode_fsinfores(struct svc_rqst *rqstp, struct xdr_stream *xdr);
@@ -164,7 +142,6 @@ bool nfs3svc_encode_pathconfres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_encode_commitres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 
 void nfs3svc_release_fhandle(struct svc_rqst *);
-void nfs3svc_release_fhandle2(struct svc_rqst *);
 
 void nfs3svc_encode_cookie3(struct nfsd3_readdirres *resp, u64 offset);
 int nfs3svc_encode_entry3(void *data, const char *name, int namlen,
-- 
2.55.0


Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EDDF84AB1BC
	for <linux-nfs@vger.kernel.org>; Thu, 24 Sep 2026 17:10:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790269833; cv=none; b=VlN1+3Y2uVStFx2SbCqLbf6qQ2+u6XR8qbzTf1UX393+YgRh7rOcBGlqGYfl1gaH5r5lRskwXg97qIixZ0CCYyLtAIiPseRDl9NdbmC5yyCZBTrG9pyVG7vWTE5DUshI4FtiUOuBvXnjykcXnaiYjcz17vl2G3/uSlHO5w6wc1k=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790269833; c=relaxed/simple;
	bh=S4xy/l4UOY6IQrMbC7XimJaBjQ9B6dl0j08V9ff0rWg=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=SjfjVJWtgVzbOWCYgba9fKnp0s8TLYkz4/6TLdd4pLTP4FDq3ePYrGCIFFhCtXL6ibnpaD0w+8cdB3z6MZHL/0S9w+kK1EZrjxN8E50HOFgjrT9oI1dkhdUPoxPJfKtMNbobfQdSHca6I35rT3YDhoTq6eLINb7RyfxGMjQP3Y4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=BKreGOtr; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="BKreGOtr"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 13F411F0089B;
	Thu, 24 Sep 2026 17:10:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790269831;
	bh=b6b4tknoJGXUrlAkyOcI7y2V7kBqC2LidxXs6k9rmkQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=BKreGOtrWgaRKVnxyhSMgtjqLanhMq6MeuRUqWmDMe8nbebr6kXl88dYnN6ho7lRT
	 whriL5RRsNEGZVB+Sgzo5Fl2Y97qTP2G9+Ur0u5Cr3tkg0e5QCO07raG5mJsp0XpPe
	 LeejnFs2OcxkvLbpmEBdpltf/zyA3TFkB4Aovt5Zxxhr4evoImQHzy3MbOuQSqQ2Kf
	 a+004FVN6baaownKyaK6zNKsbmeN+gBRtRFBykfEVNgocDYVpBz/5c58pTHJqQ8anL
	 mPhY5WsCvn4LQWppbZkT3O+I8wPX2nWELF3XN7vHIlh3TGxIJFsVtkh2Hj0azCkh8W
	 sm8flin5gtJ/Q==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 21/33] NFSD: Use xdrgen XDR functions for the NFSv3 RENAME procedure
Date: Thu, 24 Sep 2026 13:10:00 -0400
Message-ID: <20260924171012.3978-22-cel@kernel.org>
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

Replace the NFSPROC3_RENAME entry in the nfsd_procedures3 array
with an entry that dispatches the xdrgen-generated
nfs_svc_decode_RENAME3args and nfs_svc_encode_RENAME3res. A
wrapper structure bridges the generated xdrgen argument type and
the legacy svc_fh representation the NFSD VFS layer still uses;
the result uses the generated RENAME3res type directly.

Filename validity is now checked by nfsd3_proc_rename() so that a
proper NFS3ERR status code can be returned to the client rather
than GARBAGE_ARGS.

The pc_argzero field is now set to zero for the NFSv3 RENAME
procedure. The xdrgen decoders are trusted to initialize all
arguments in the argp->xdrgen field, making the early defensive
memset unnecessary. The remaining argp fields are cleared as
needed.

Because nfsd3_proc_rename() now assembles the WCC data, that work
moves out of the XDR result encoder, and the references to the
file handles can be released directly by nfsd3_proc_rename(). A
separate ->pc_release callback is thus no longer needed. This
makes it straightforward to confirm that the file handles are
properly released during every error flow.

nfs3svc_decode_renameargs() and nfs3svc_encode_renameres() no
longer have any callers, so they are removed.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs3proc.c | 89 +++++++++++++++++++++++++++++++++++-----------
 fs/nfsd/nfs3xdr.c  | 22 ------------
 fs/nfsd/xdr3.h     | 17 ---------
 3 files changed, 68 insertions(+), 60 deletions(-)

diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index e31b96bf4a80..b9f7f9d74f3f 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -177,6 +177,14 @@ struct RMDIR3args_wrapper {
 
 static_assert(offsetof(struct RMDIR3args_wrapper, xdrgen) == 0);
 
+struct RENAME3args_wrapper {
+	struct RENAME3args	xdrgen;
+	struct svc_fh		ffh;
+	struct svc_fh		tfh;
+};
+
+static_assert(offsetof(struct RENAME3args_wrapper, xdrgen) == 0);
+
 static int nfsd3_ftype3_to_mode(ftype3 ftype)
 {
 	switch (ftype) {
@@ -1348,17 +1356,57 @@ static __be32 nfsd3_proc_rmdir(struct svc_rqst *rqstp)
 	return rpc_success;
 }
 
-static __be32
-nfsd3_proc_rename(struct svc_rqst *rqstp)
+/**
+ * nfsd3_proc_rename - RENAME: Rename a file or directory
+ * @rqstp: RPC transaction context
+ *
+ * Return:
+ *   %rpc_success:		RPC executed successfully
+ *
+ * RPC synopsis:
+ *   RENAME3res NFSPROC3_RENAME(RENAME3args) = 14;
+ */
+static __be32 nfsd3_proc_rename(struct svc_rqst *rqstp)
 {
-	struct nfsd3_renameargs *argp = rqstp->rq_argp;
-	struct nfsd3_renameres *resp = rqstp->rq_resp;
+	struct RENAME3args_wrapper *argp = rqstp->rq_argp;
+	struct diropargs3 *from = &argp->xdrgen.from;
+	struct diropargs3 *to = &argp->xdrgen.to;
+	struct RENAME3res *resp = rqstp->rq_resp;
+	struct svc_fh *ffhp = &argp->ffh;
+	struct svc_fh *tfhp = &argp->tfh;
 
-	fh_copy(&resp->ffh, &argp->ffh);
-	fh_copy(&resp->tfh, &argp->tfh);
-	resp->status = nfsd_rename(rqstp, &resp->ffh, argp->fname, argp->flen,
-				   &resp->tfh, argp->tname, argp->tlen);
-	resp->status = nfsd3_map_status(resp->status);
+	nfsd3_fh3_to_svc_fh(ffhp, &from->dir);
+	nfsd3_fh3_to_svc_fh(tfhp, &to->dir);
+	resp->status = nfsd3_check_filename(from->name.data,
+					    from->name.len);
+	if (resp->status != nfs_ok)
+		goto out;
+	resp->status = nfsd3_check_filename(to->name.data,
+					    to->name.len);
+	if (resp->status != nfs_ok)
+		goto out;
+
+	resp->status = nfsd_rename(rqstp, ffhp, (char *)from->name.data,
+				   from->name.len, tfhp,
+				   (char *)to->name.data,
+				   to->name.len);
+
+out:
+	if (resp->status == nfs_ok) {
+		struct RENAME3resok *resok = &resp->u.resok;
+
+		nfsd3_fill_wcc_data(rqstp, &resok->fromdir_wcc, ffhp);
+		nfsd3_fill_wcc_data(rqstp, &resok->todir_wcc, tfhp);
+	} else {
+		struct RENAME3resfail *resfail = &resp->u.resfail;
+
+		resp->status = nfsd3_map_status(resp->status);
+		nfsd3_fill_wcc_data(rqstp, &resfail->fromdir_wcc, ffhp);
+		nfsd3_fill_wcc_data(rqstp, &resfail->todir_wcc, tfhp);
+	}
+
+	fh_put(ffhp);
+	fh_put(tfhp);
 	return rpc_success;
 }
 
@@ -1795,16 +1843,15 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 		.pc_name	= "RMDIR",
 	},
 	[NFSPROC3_RENAME] = {
-		.pc_func = nfsd3_proc_rename,
-		.pc_decode = nfs3svc_decode_renameargs,
-		.pc_encode = nfs3svc_encode_renameres,
-		.pc_release = nfs3svc_release_fhandle2,
-		.pc_argsize = sizeof(struct nfsd3_renameargs),
-		.pc_argzero = sizeof(struct nfsd3_renameargs),
-		.pc_ressize = sizeof(struct nfsd3_renameres),
-		.pc_cachetype = RC_REPLBUFF,
-		.pc_xdrressize = ST+WC+WC,
-		.pc_name = "RENAME",
+		.pc_func	= nfsd3_proc_rename,
+		.pc_decode	= nfs_svc_decode_RENAME3args,
+		.pc_encode	= nfs_svc_encode_RENAME3res,
+		.pc_argsize	= sizeof(struct RENAME3args_wrapper),
+		.pc_argzero	= 0,
+		.pc_ressize	= sizeof(struct RENAME3res),
+		.pc_cachetype	= RC_REPLBUFF,
+		.pc_xdrressize	= NFS3_RENAME3res_sz,
+		.pc_name	= "RENAME",
 	},
 	[NFSPROC3_LINK] = {
 		.pc_func = nfsd3_proc_link,
@@ -1914,13 +1961,13 @@ union nfsd3_xdrstore {
 	struct REMOVE3res		removeres;
 	struct RMDIR3args_wrapper	rmdirargs;
 	struct RMDIR3res		rmdirres;
-	struct nfsd3_renameargs		renameargs;
+	struct RENAME3args_wrapper	renameargs;
+	struct RENAME3res		renameres;
 	struct nfsd3_linkargs		linkargs;
 	struct nfsd3_readdirargs	readdirargs;
 	struct READLINK3res		readlinkres;
 	struct READ3res			readres;
 	struct nfsd3_writeres		writeres;
-	struct nfsd3_renameres		renameres;
 	struct nfsd3_linkres		linkres;
 	struct nfsd3_readdirres		readdirres;
 	struct nfsd3_fsstatres		fsstatres;
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index 1cfc79724450..3ec835e0f364 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -360,17 +360,6 @@ nfs3svc_decode_fhandleargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 	return svcxdr_decode_nfs_fh3(xdr, &args->fh);
 }
 
-bool
-nfs3svc_decode_renameargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd3_renameargs *args = rqstp->rq_argp;
-
-	return svcxdr_decode_diropargs3(xdr, &args->ffh,
-					&args->fname, &args->flen) &&
-		svcxdr_decode_diropargs3(xdr, &args->tfh,
-					 &args->tname, &args->tlen);
-}
-
 bool
 nfs3svc_decode_linkargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 {
@@ -440,17 +429,6 @@ nfs3svc_decode_commitargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
  * XDR encode functions
  */
 
-/* RENAME */
-bool
-nfs3svc_encode_renameres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd3_renameres *resp = rqstp->rq_resp;
-
-	return svcxdr_encode_nfsstat3(xdr, resp->status) &&
-		svcxdr_encode_wcc_data(rqstp, xdr, &resp->ffh) &&
-		svcxdr_encode_wcc_data(rqstp, xdr, &resp->tfh);
-}
-
 /* LINK */
 bool
 nfs3svc_encode_linkres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
diff --git a/fs/nfsd/xdr3.h b/fs/nfsd/xdr3.h
index fac60fb4cdf9..8a15781d7f3c 100644
--- a/fs/nfsd/xdr3.h
+++ b/fs/nfsd/xdr3.h
@@ -24,15 +24,6 @@ struct nfsd3_accessargs {
 	__u32			access;
 };
 
-struct nfsd3_renameargs {
-	struct svc_fh		ffh;
-	char *			fname;
-	unsigned int		flen;
-	struct svc_fh		tfh;
-	char *			tname;
-	unsigned int		tlen;
-};
-
 struct nfsd3_linkargs {
 	struct svc_fh		ffh;
 	struct svc_fh		tfh;
@@ -85,12 +76,6 @@ struct nfsd3_writeres {
 
 static_assert(offsetof(struct nfsd3_writeres, xdrgen) == 0);
 
-struct nfsd3_renameres {
-	__be32			status;
-	struct svc_fh		ffh;
-	struct svc_fh		tfh;
-};
-
 struct nfsd3_linkres {
 	__be32			status;
 	struct svc_fh		tfh;
@@ -165,14 +150,12 @@ struct nfsd3_fhandle_pair {
 };
 
 bool nfs3svc_decode_fhandleargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-bool nfs3svc_decode_renameargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_linkargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_readdirargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_readdirplusargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_commitargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 
 bool nfs3svc_encode_accessres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-bool nfs3svc_encode_renameres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_encode_linkres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_encode_readdirres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_encode_fsstatres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-- 
2.55.0


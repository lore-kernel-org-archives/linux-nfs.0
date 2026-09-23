Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EED0C52ED5D
	for <linux-nfs@vger.kernel.org>; Wed, 23 Sep 2026 13:28:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790170113; cv=none; b=pQuqxB6AciTQhrl+UqvYE10M5B2FyJ2T0MErr2Hba3nVuZdH04kFpaywt2LVCXI4PX4nQv2MuaNRdHywUxILM4ZSSRQcLp2otQJBqKgaJ8imVGHAjgek0pSy8s7V8k9lN+qH1grhuJK3Dn7GR9OC4Oi0B5zP3uY+UNaUC+dJkfA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790170113; c=relaxed/simple;
	bh=3LePv4vCD+2RZm/vpsWa8HOM3k6s7kiXkAxu7m9b0ZI=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=jxhz5Alk8+j35YHTQIn9xdE62QamFaOduKgLI5tkCoTfSvL4KER97ejtTbVWKqS1Nsz+P+SqWnkcpIm6LI4j+ckbqGXYrvtRdkjb1nfPCZckpFMz310u1x2untjdDp0zXLKpv2XRtvlS8m1JbQgRWIGHxuNP9k2PZNe86oNV/i4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=LJhZo5am; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="LJhZo5am"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1A87C1F00893;
	Wed, 23 Sep 2026 13:28:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790170111;
	bh=5/bdq8iuQhm3q6H0ia8Pnzig6mZplLvrg7aEP6VZvw4=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=LJhZo5am+RMCQBvdCnx7p/DeEqHc5An8gowDNh35PE4wMiUuGsdVguzRb7o5TqItt
	 31nuVeQ+1L7aIwvQ2op0iZtIQOMAzid+KVzejKakn6JerIKHBFNHDMEylITmZ2Sw5S
	 I6YdKC5euGlzHvWJ3IBLoDDEHETSrz2W//pXlO+5SN6OjOt90D/J7Qa5gPHKdZgxwl
	 4q/wUmuL0zsgM3MuBMp35LUD/2Ot8kt4WTR+0vgdA13djutis9oSHA16jjJShVmW18
	 2nNH5aMcHio9zyMqguBWxTCVzlKs1lZ3Qr3D7Wk75PSb40mNsYrvu+wR/e4507GAHU
	 DB+fL32JnmWMA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 20/33] NFSD: Use xdrgen XDR functions for the NFSv3 RMDIR procedure
Date: Wed, 23 Sep 2026 09:27:58 -0400
Message-ID: <20260923132811.244160-21-cel@kernel.org>
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

Replace the NFSPROC3_RMDIR entry in the nfsd_procedures3 array
with an entry that dispatches the xdrgen-generated
nfs_svc_decode_RMDIR3args and nfs_svc_encode_RMDIR3res. A
wrapper structure bridges the generated xdrgen argument type and
the legacy svc_fh representation the NFSD VFS layer still uses;
the result uses the generated RMDIR3res type directly.

Filename validity is now checked by nfsd3_proc_rmdir() so that a
proper NFS3ERR status code can be returned to the client rather
than GARBAGE_ARGS.

The pc_argzero field is now set to zero for the NFSv3 RMDIR
procedure. The xdrgen decoders are trusted to initialize all
arguments in the argp->xdrgen field, making the early defensive
memset unnecessary. The remaining argp fields are cleared as
needed.

Because nfsd3_proc_rmdir() now assembles the WCC data, that work
moves out of the XDR result encoder, and the reference to the
file handle can be released directly by nfsd3_proc_rmdir(). A
separate ->pc_release callback is thus no longer needed. This
makes it straightforward to confirm that the file handle is
properly released during every error flow.

nfs3svc_decode_diropargs() and nfs3svc_encode_wccstat() no longer
have any callers, so they are removed.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs3proc.c | 74 ++++++++++++++++++++++++++++++++--------------
 fs/nfsd/nfs3xdr.c  | 18 -----------
 fs/nfsd/xdr3.h     |  8 -----
 3 files changed, 51 insertions(+), 49 deletions(-)

diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 02c7501c8663..e31b96bf4a80 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -170,6 +170,13 @@ struct REMOVE3args_wrapper {
 
 static_assert(offsetof(struct REMOVE3args_wrapper, xdrgen) == 0);
 
+struct RMDIR3args_wrapper {
+	struct RMDIR3args	xdrgen;
+	struct svc_fh		fh;
+};
+
+static_assert(offsetof(struct RMDIR3args_wrapper, xdrgen) == 0);
+
 static int nfsd3_ftype3_to_mode(ftype3 ftype)
 {
 	switch (ftype) {
@@ -1302,19 +1309,42 @@ static __be32 nfsd3_proc_remove(struct svc_rqst *rqstp)
 	return rpc_success;
 }
 
-/*
- * Remove a directory
+/**
+ * nfsd3_proc_rmdir - RMDIR: Remove a directory
+ * @rqstp: RPC transaction context
+ *
+ * Return:
+ *   %rpc_success:		RPC executed successfully
+ *
+ * RPC synopsis:
+ *   RMDIR3res NFSPROC3_RMDIR(RMDIR3args) = 13;
  */
-static __be32
-nfsd3_proc_rmdir(struct svc_rqst *rqstp)
+static __be32 nfsd3_proc_rmdir(struct svc_rqst *rqstp)
 {
-	struct nfsd3_diropargs *argp = rqstp->rq_argp;
-	struct nfsd3_attrstat *resp = rqstp->rq_resp;
+	struct RMDIR3args_wrapper *argp = rqstp->rq_argp;
+	struct diropargs3 *object = &argp->xdrgen.object;
+	struct RMDIR3res *resp = rqstp->rq_resp;
+	struct svc_fh *fhp = &argp->fh;
 
-	fh_copy(&resp->fh, &argp->fh);
-	resp->status = nfsd_unlink(rqstp, &resp->fh, S_IFDIR,
-				   argp->name, argp->len);
-	resp->status = nfsd3_map_status(resp->status);
+	nfsd3_fh3_to_svc_fh(fhp, &object->dir);
+	resp->status = nfsd3_check_filename(object->name.data,
+					    object->name.len);
+	if (resp->status != nfs_ok)
+		goto out;
+
+	resp->status = nfsd_unlink(rqstp, fhp, S_IFDIR,
+				   (char *)object->name.data,
+				   object->name.len);
+
+out:
+	if (resp->status == nfs_ok) {
+		nfsd3_fill_wcc_data(rqstp, &resp->u.resok.dir_wcc, fhp);
+	} else {
+		resp->status = nfsd3_map_status(resp->status);
+		nfsd3_fill_wcc_data(rqstp, &resp->u.resfail.dir_wcc, fhp);
+	}
+
+	fh_put(fhp);
 	return rpc_success;
 }
 
@@ -1598,10 +1628,8 @@ nfsd3_proc_commit(struct svc_rqst *rqstp)
  * NFSv3 Server procedures.
  * Only the results of non-idempotent operations are cached.
  */
-#define nfs3svc_encode_wccstatres	nfs3svc_encode_wccstat
 #define nfsd3_readdirplusargs		nfsd3_readdirargs
 #define nfsd3_fhandleargs		nfsd_fhandle
-#define nfsd3_wccstatres		nfsd3_attrstat
 
 #define ST 1		/* status*/
 #define AT 21		/* attributes */
@@ -1756,16 +1784,15 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 		.pc_name	= "REMOVE",
 	},
 	[NFSPROC3_RMDIR] = {
-		.pc_func = nfsd3_proc_rmdir,
-		.pc_decode = nfs3svc_decode_diropargs,
-		.pc_encode = nfs3svc_encode_wccstatres,
-		.pc_release = nfs3svc_release_fhandle,
-		.pc_argsize = sizeof(struct nfsd3_diropargs),
-		.pc_argzero = sizeof(struct nfsd3_diropargs),
-		.pc_ressize = sizeof(struct nfsd3_wccstatres),
-		.pc_cachetype = RC_REPLBUFF,
-		.pc_xdrressize = ST+WC,
-		.pc_name = "RMDIR",
+		.pc_func	= nfsd3_proc_rmdir,
+		.pc_decode	= nfs_svc_decode_RMDIR3args,
+		.pc_encode	= nfs_svc_encode_RMDIR3res,
+		.pc_argsize	= sizeof(struct RMDIR3args_wrapper),
+		.pc_argzero	= 0,
+		.pc_ressize	= sizeof(struct RMDIR3res),
+		.pc_cachetype	= RC_REPLBUFF,
+		.pc_xdrressize	= NFS3_RMDIR3res_sz,
+		.pc_name	= "RMDIR",
 	},
 	[NFSPROC3_RENAME] = {
 		.pc_func = nfsd3_proc_rename,
@@ -1874,7 +1901,6 @@ union nfsd3_xdrstore {
 	struct ACCESS3res		accessres;
 	struct READLINK3args_wrapper	readlinkargs;
 	struct READ3args_wrapper	readargs;
-	struct nfsd3_diropargs		diropargs;
 	struct WRITE3args_wrapper	writeargs;
 	struct CREATE3args_wrapper	createargs;
 	struct CREATE3res_wrapper	createres;
@@ -1886,6 +1912,8 @@ union nfsd3_xdrstore {
 	struct MKNOD3res_wrapper	mknodres;
 	struct REMOVE3args_wrapper	removeargs;
 	struct REMOVE3res		removeres;
+	struct RMDIR3args_wrapper	rmdirargs;
+	struct RMDIR3res		rmdirres;
 	struct nfsd3_renameargs		renameargs;
 	struct nfsd3_linkargs		linkargs;
 	struct nfsd3_readdirargs	readdirargs;
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index 53a82af80ad5..1cfc79724450 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -360,14 +360,6 @@ nfs3svc_decode_fhandleargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 	return svcxdr_decode_nfs_fh3(xdr, &args->fh);
 }
 
-bool
-nfs3svc_decode_diropargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd3_diropargs *args = rqstp->rq_argp;
-
-	return svcxdr_decode_diropargs3(xdr, &args->fh, &args->name, &args->len);
-}
-
 bool
 nfs3svc_decode_renameargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 {
@@ -448,16 +440,6 @@ nfs3svc_decode_commitargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
  * XDR encode functions
  */
 
-/* SETATTR, REMOVE, RMDIR */
-bool
-nfs3svc_encode_wccstat(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd3_attrstat *resp = rqstp->rq_resp;
-
-	return svcxdr_encode_nfsstat3(xdr, resp->status) &&
-		svcxdr_encode_wcc_data(rqstp, xdr, &resp->fh);
-}
-
 /* RENAME */
 bool
 nfs3svc_encode_renameres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
diff --git a/fs/nfsd/xdr3.h b/fs/nfsd/xdr3.h
index 184d7852a94a..26ce94e49eda 100644
--- a/fs/nfsd/xdr3.h
+++ b/fs/nfsd/xdr3.h
@@ -19,12 +19,6 @@
 #define NFS3_MAXNAMLEN			NAME_MAX
 #define NFS3_MAXPATHLEN			PATH_MAX
 
-struct nfsd3_diropargs {
-	struct svc_fh		fh;
-	char *			name;
-	unsigned int		len;
-};
-
 struct nfsd3_accessargs {
 	struct svc_fh		fh;
 	__u32			access;
@@ -178,14 +172,12 @@ struct nfsd3_fhandle_pair {
 };
 
 bool nfs3svc_decode_fhandleargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-bool nfs3svc_decode_diropargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_renameargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_linkargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_readdirargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_readdirplusargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_commitargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 
-bool nfs3svc_encode_wccstat(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_encode_accessres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_encode_renameres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_encode_linkres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-- 
2.55.0


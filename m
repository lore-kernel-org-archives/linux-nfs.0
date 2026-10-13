Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4F41E361974
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2026 12:49:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791895776; cv=none; b=WbU+yQq5B0uenos+5n/dQ3vTY1lGR4UZ8yyznm9MThw53SjWASCtrLxo8bZnp168KtNAzdemT34NQJUthRa8ojt/0a8nPGNMZb1F1C86Qjwc6BXAxbAN09uCCYzy9sqIHeymGRkcTQPySgvMXN4zK4gHVwmfG6FRZG9NJ6GinA8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791895776; c=relaxed/simple;
	bh=VQbwm9iCMb681JErU+hOubKe8eLbS4JMIQzyJWGgG7c=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=FERMzNpcNLUZou7mWk5X4VVRzVG0kqYa0gaX3/lt8TUXg47H8l7rVua8jBOK0NaNThaizu9J2Cp4I3QxgP7L3cdFA3uYC4hbhO2YkfTWDRRnM0odE6pmKvvDz2xB3CrlQWnIhl+f8Nml6DacDuwJl1/JFhdEqv6Zr2nCyUN/x64=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Hn6MkW7T; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Hn6MkW7T"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A7C071F00899;
	Tue, 13 Oct 2026 12:49:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791895775;
	bh=uF130FYsZr5+IlvrGADzJcekun+9BAVeNnnWAPWNYmE=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Hn6MkW7TjxRHFLxleFX8V++VtC+wI52oErsGjczgDVkPGK+HRL1NYGza99qsi5t79
	 1uThevYe4u5Jm54PrxAPzgve1IQAungUo4UnN7QXp0ZVnr23Bnhhgh0Gp+MrPXJkFg
	 C3IG95GHZrWnTVHxP4U1k/x/USZT4FN1zQjemFrku1tQS70hRnl1aPrrmBG/OeCusj
	 3XJEwA7b1/xTSWTh0kRlyBGL1qoBr+AMboIKf+qicqz+euMG7mZMaanvmChQ0ZC0wr
	 VC6w4hcT+YKP1gqN04oquJ/Wfklo4083S0whVTzJqeabtksCrpUhB9kv4oFrDk4FQz
	 baKZcqX0KsDLA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 11/34] NFSD: Use xdrgen XDR functions for NFSv3 ACCESS procedure
Date: Tue, 13 Oct 2026 08:49:25 -0400
Message-ID: <20261013124933.316765-2-cel@kernel.org>
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
index 0eedfcf2454f..8f02dcd6404b 100644
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
@@ -543,24 +550,40 @@ static __be32 nfsd3_proc_lookup(struct svc_rqst *rqstp)
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
 
@@ -1296,16 +1319,15 @@ static const struct svc_procedure nfsd_procedures3[22] = {
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
@@ -1518,6 +1540,8 @@ union nfsd3_xdrstore {
 	struct SETATTR3res		setattrres;
 	struct LOOKUP3args_wrapper	lookupargs;
 	struct LOOKUP3res_wrapper	lookupres;
+	struct ACCESS3args_wrapper	accessargs;
+	struct ACCESS3res		accessres;
 	struct nfsd3_diropargs		diropargs;
 	struct nfsd3_readargs		readargs;
 	struct nfsd3_writeargs		writeargs;
@@ -1527,7 +1551,6 @@ union nfsd3_xdrstore {
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


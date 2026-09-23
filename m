Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E03C94AA3EB
	for <linux-nfs@vger.kernel.org>; Wed, 23 Sep 2026 13:28:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790170119; cv=none; b=YuRoEtvjz1+JAHDi2yDuEOUzWbx3gDZg5ELxNpQvfv6FTbO0pPaYx6Doz2s3FlYkT331GAph4zrCpAh8W6vgtpn5dr9XGyuH7XVvWVz2oyDtDSoySU9T3fXpB2gyRppKVpFJv0D6B6K56Pp3UGtyCdfQtxecUBlKvb4fV7RkHM8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790170119; c=relaxed/simple;
	bh=hm1jhUmv5AFAxd2Sjw7cqobzLfIlJBEjHrstxWlb2f8=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Qn2VtvcVO71eDu6su5mo050otz95BZf4B/3h1oOkGbe+mzD1aoPj7lChaW5XItUKTxnHV9Je/tpSqygYD229804Y7d1K7FzoVSqmXyA9eT1lgWmk6BN4Q9oSxbvFbDjX3nb/DlvmrTeuSEel+YJ1KUIJUAygemsuR2os090G39Y=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Xb/wCDMb; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Xb/wCDMb"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 43D971F000FF;
	Wed, 23 Sep 2026 13:28:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790170117;
	bh=zbLbmf11Ks82YvEeom7CHYfvCnYz9DxnQxKFQ/0kN3U=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Xb/wCDMbcE1hYnqhZAP1tdP94XpXZVudLfMsPFytAj38epzlq3fY2G8GbzjldWUFL
	 +PsGE6Z763EcoHCMv9vXmdQXcFXzm2Qug3iY0q0AirPyebXCCxFzwLBjZlkre0BgKJ
	 FDXbBjz8970Ok5xlGPQijkTLToZYFA/wxJPG56vsToqHyX5uGKRmJroZjwP7gOOjDZ
	 JPr0RGYik74pPKle9cJl9URL/rAVpp8xz6ZyNoHavxQuxknya9nT754W2w6HWTMyMi
	 2vAGHMWUOyORNI8KO5IUC9EHnPP9Acvfwv6RHvNIyYMUGks/foJ+qrNprJbTwRWysQ
	 zIrElIg0ECS2g==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 28/33] NFSD: Use xdrgen XDR functions for NFSv3 READDIRPLUS arguments
Date: Wed, 23 Sep 2026 09:28:06 -0400
Message-ID: <20260923132811.244160-29-cel@kernel.org>
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

Replace the NFSPROC3_READDIRPLUS entry in the nfsd_procedures3 array
with an entry that dispatches the xdrgen-generated
nfs_svc_decode_READDIRPLUS3args. A wrapper structure bridges the
generated xdrgen READDIRPLUS3args type and the legacy svc_fh
representation the NFSD VFS layer still uses.

The pc_argzero field is now set to zero for the NFSv3 READDIRPLUS
procedure. The xdrgen decoders are trusted to initialize all
arguments in the argp->xdrgen field, making the early defensive
memset unnecessary. The remaining argp fields are cleared as
needed.

nfs3svc_decode_readdirplusargs() no longer has any callers, so it
is removed.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs3proc.c | 62 +++++++++++++++++++++++++++-------------------
 fs/nfsd/nfs3xdr.c  | 26 -------------------
 fs/nfsd/xdr3.h     |  9 -------
 3 files changed, 36 insertions(+), 61 deletions(-)

diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index f221bd11482e..e09c2a839a1c 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -225,6 +225,13 @@ struct READDIR3args_wrapper {
 
 static_assert(offsetof(struct READDIR3args_wrapper, xdrgen) == 0);
 
+struct READDIRPLUS3args_wrapper {
+	struct READDIRPLUS3args	xdrgen;
+	struct svc_fh		fh;
+};
+
+static_assert(offsetof(struct READDIRPLUS3args_wrapper, xdrgen) == 0);
+
 static int nfsd3_ftype3_to_mode(ftype3 ftype)
 {
 	switch (ftype) {
@@ -1555,27 +1562,32 @@ static __be32 nfsd3_proc_readdir(struct svc_rqst *rqstp)
 	return rpc_success;
 }
 
-/*
- * Read a portion of a directory, including file handles and attrs.
- * For now, we choose to ignore the dircount parameter.
+/**
+ * nfsd3_proc_readdirplus - READDIRPLUS: Extended read from directory
+ * @rqstp: RPC transaction context
+ *
+ * Return:
+ *   %rpc_success:		RPC executed successfully
+ *
+ * RPC synopsis:
+ *   READDIRPLUS3res NFSPROC3_READDIRPLUS(READDIRPLUS3args) = 17;
  */
-static __be32
-nfsd3_proc_readdirplus(struct svc_rqst *rqstp)
+static __be32 nfsd3_proc_readdirplus(struct svc_rqst *rqstp)
 {
-	struct nfsd3_readdirargs *argp = rqstp->rq_argp;
+	struct READDIRPLUS3args_wrapper *argp = rqstp->rq_argp;
 	struct nfsd3_readdirres  *resp = rqstp->rq_resp;
-	loff_t	offset;
+	loff_t offset = argp->xdrgen.cookie;
+	struct svc_fh *fhp = &argp->fh;
 
-	trace_nfsd_vfs_readdir(rqstp, &argp->fh, argp->count, argp->cookie);
+	nfsd3_fh3_to_svc_fh(fhp, &argp->xdrgen.dir);
+	trace_nfsd_vfs_readdir(rqstp, fhp, argp->xdrgen.maxcount,
+			       argp->xdrgen.cookie);
 
-	nfsd3_init_dirlist_pages(rqstp, resp, argp->count);
-
-	fh_copy(&resp->fh, &argp->fh);
+	nfsd3_init_dirlist_pages(rqstp, resp, argp->xdrgen.maxcount);
+	fh_copy(&resp->fh, fhp);
 	resp->common.err = nfs_ok;
 	resp->cookie_offset = 0;
 	resp->rqstp = rqstp;
-	offset = argp->cookie;
-
 	resp->status = fh_verify(rqstp, &resp->fh, S_IFDIR, NFSD_MAY_NOP);
 	if (resp->status != nfs_ok)
 		goto out;
@@ -1587,7 +1599,7 @@ nfsd3_proc_readdirplus(struct svc_rqst *rqstp)
 
 	resp->status = nfsd_readdir(rqstp, &resp->fh, &offset,
 				    &resp->common, nfs3svc_encode_entryplus3);
-	memcpy(resp->verf, argp->verf, 8);
+	memcpy(resp->verf, argp->xdrgen.cookieverf, NFS3_COOKIEVERFSIZE);
 	nfs3svc_encode_cookie3(resp, offset);
 
 	/* Recycle only pages that were part of the reply */
@@ -1828,8 +1840,6 @@ static __be32 nfsd3_proc_commit(struct svc_rqst *rqstp)
  * NFSv3 Server procedures.
  * Only the results of non-idempotent operations are cached.
  */
-#define nfsd3_readdirplusargs		nfsd3_readdirargs
-
 static const struct svc_procedure nfsd_procedures3[22] = {
 	[NFSPROC3_NULL] = {
 		.pc_func	= nfsd3_proc_null,
@@ -2022,15 +2032,15 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 		.pc_name	= "READDIR",
 	},
 	[NFSPROC3_READDIRPLUS] = {
-		.pc_func = nfsd3_proc_readdirplus,
-		.pc_decode = nfs3svc_decode_readdirplusargs,
-		.pc_encode = nfs3svc_encode_readdirres,
-		.pc_release = nfs3svc_release_fhandle,
-		.pc_argsize = sizeof(struct nfsd3_readdirplusargs),
-		.pc_argzero = sizeof(struct nfsd3_readdirplusargs),
-		.pc_ressize = sizeof(struct nfsd3_readdirres),
-		.pc_cachetype = RC_NOCACHE,
-		.pc_name = "READDIRPLUS",
+		.pc_func	= nfsd3_proc_readdirplus,
+		.pc_decode	= nfs_svc_decode_READDIRPLUS3args,
+		.pc_encode	= nfs3svc_encode_readdirres,
+		.pc_release	= nfs3svc_release_fhandle,
+		.pc_argsize	= sizeof(struct READDIRPLUS3args_wrapper),
+		.pc_argzero	= 0,
+		.pc_ressize	= sizeof(struct nfsd3_readdirres),
+		.pc_cachetype	= RC_NOCACHE,
+		.pc_name	= "READDIRPLUS",
 	},
 	[NFSPROC3_FSSTAT] = {
 		.pc_func	= nfsd3_proc_fsstat,
@@ -2110,7 +2120,7 @@ union nfsd3_xdrstore {
 	struct LINK3args_wrapper	linkargs;
 	struct LINK3res			linkres;
 	struct READDIR3args_wrapper	readdirargs;
-	struct nfsd3_readdirargs	readdirplusargs;
+	struct READDIRPLUS3args_wrapper	readdirplusargs;
 	struct READLINK3res		readlinkres;
 	struct READ3res			readres;
 	struct nfsd3_writeres		writeres;
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index 0e83a2245c45..b1a930b857d7 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -224,32 +224,6 @@ svcxdr_encode_post_op_attr(struct svc_rqst *rqstp, struct xdr_stream *xdr,
 	return xdr_stream_encode_item_absent(xdr) > 0;
 }
 
-/*
- * XDR decode functions
- */
-
-bool
-nfs3svc_decode_readdirplusargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd3_readdirargs *args = rqstp->rq_argp;
-	u32 dircount;
-
-	if (!svcxdr_decode_nfs_fh3(xdr, &args->fh))
-		return false;
-	if (xdr_stream_decode_u64(xdr, &args->cookie) < 0)
-		return false;
-	args->verf = xdr_inline_decode(xdr, NFS3_COOKIEVERFSIZE);
-	if (!args->verf)
-		return false;
-	/* dircount is ignored */
-	if (xdr_stream_decode_u32(xdr, &dircount) < 0)
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
diff --git a/fs/nfsd/xdr3.h b/fs/nfsd/xdr3.h
index c67933ad3cd6..eb4a4e9d5073 100644
--- a/fs/nfsd/xdr3.h
+++ b/fs/nfsd/xdr3.h
@@ -31,13 +31,6 @@ struct nfsd3_createargs {
 	__be32 *		verf;
 };
 
-struct nfsd3_readdirargs {
-	struct svc_fh		fh;
-	__u64			cookie;
-	__u32			count;
-	__be32 *		verf;
-};
-
 struct nfsd3_getaclargs {
 	struct svc_fh		fh;
 	__u32			mask;
@@ -120,8 +113,6 @@ struct nfsd3_getaclres {
 	struct kstat		stat;
 };
 
-bool nfs3svc_decode_readdirplusargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-
 bool nfs3svc_encode_accessres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_encode_readdirres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 
-- 
2.55.0


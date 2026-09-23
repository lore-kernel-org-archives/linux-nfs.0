Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 20F365304D1
	for <linux-nfs@vger.kernel.org>; Wed, 23 Sep 2026 13:28:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790170118; cv=none; b=bxCu2WDAr55T/5raXkxgXwxWO5eBo7ae/zQDKz8UjG/A00k6K63qDqUAZt54eIxDafJl2ktB8ow7asG9ELGdlybGQjNsM/i4Gr5ZBGv7ncMy+1EJjb1RduF9d8dRZAppQL9FwPperjWCKBKBUjMd6jVaNG/jSEmKur+aAu1BDkU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790170118; c=relaxed/simple;
	bh=gEL2ISVTI3lCcOSJdfjmzeUWGqUW58IV7apyeEpLp6A=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=gqb97M40w0BSjrJ0oqPdsGyUI++5bcZ5qm3ogUoT1Q5Low4mm97LeVkS2qkDpCttboQwTQkBK5VX6ZTP5YQxXcD807PIBu6zNzX4Wk/PXlRlw43R6tjq9aHq6jUXGLwxdA+DP7RIw9yIOt2quI+xblUdLqMV/DQV/A9bQBx+c7s=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=bW/LxcRb; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="bW/LxcRb"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7B47B1F00893;
	Wed, 23 Sep 2026 13:28:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790170117;
	bh=833IwtWQwUOYwsS0JL3Y0vlwVx5ljklBq9CQpEUKX4I=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=bW/LxcRbvAidrHdRWsasdbKltsGn9CWYJZQV389EM4KKax1GNHl4FbByMlBOGWJWA
	 s+zEKDZa9Oyn6a6P7KB+egBcbDcbpLfECQDsfGNs6UIxCC+Q/h8ZOSh5USngHYMlbv
	 yXoaJiIwb+mKDhp4NztbLhIClDHTFstCeadsMghymWyDWXW+992hYZmNAVE4+hL427
	 TXjoN1HIa874kfQWAzQHGr5knGV6z9MTXSoc6RUkAougzmMHZASU1jQoBJCJwO5FG3
	 lMHfqiKjRRZQ9v28gSBOPIdCy4zSP9fmqYPCXtITgrWqZGIOnkGPCEtuf1NHzkyUd0
	 nvP06jGDfWlWQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 27/33] NFSD: Use xdrgen XDR functions for NFSv3 READDIR arguments
Date: Wed, 23 Sep 2026 09:28:05 -0400
Message-ID: <20260923132811.244160-28-cel@kernel.org>
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

Replace the NFSPROC3_READDIR entry in the nfsd_procedures3 array
with an entry that dispatches the xdrgen-generated
nfs_svc_decode_READDIR3args. A wrapper structure bridges the
generated xdrgen READDIR3args type and the legacy svc_fh
representation the NFSD VFS layer still uses.

The pc_argzero field is now set to zero for the NFSv3 READDIR
procedure. The xdrgen decoders are trusted to initialize all
arguments in the argp->xdrgen field, making the early defensive
memset unnecessary. The remaining argp fields are cleared as
needed.

nfs3svc_decode_readdirargs() no longer has any callers, so it is
removed.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs3proc.c | 59 +++++++++++++++++++++++++++++-----------------
 fs/nfsd/nfs3xdr.c  | 18 --------------
 fs/nfsd/xdr3.h     |  1 -
 3 files changed, 37 insertions(+), 41 deletions(-)

diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 68bf988476cf..f221bd11482e 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -218,6 +218,13 @@ struct COMMIT3args_wrapper {
 
 static_assert(offsetof(struct COMMIT3args_wrapper, xdrgen) == 0);
 
+struct READDIR3args_wrapper {
+	struct READDIR3args	xdrgen;
+	struct svc_fh		fh;
+};
+
+static_assert(offsetof(struct READDIR3args_wrapper, xdrgen) == 0);
+
 static int nfsd3_ftype3_to_mode(ftype3 ftype)
 {
 	switch (ftype) {
@@ -1510,28 +1517,35 @@ static void nfsd3_init_dirlist_pages(struct svc_rqst *rqstp,
 	xdr_init_encode_pages(xdr, buf);
 }
 
-/*
- * Read a portion of a directory.
+/**
+ * nfsd3_proc_readdir - READDIR: Read from directory
+ * @rqstp: RPC transaction context
+ *
+ * Return:
+ *   %rpc_success:		RPC executed successfully
+ *
+ * RPC synopsis:
+ *   READDIR3res NFSPROC3_READDIR(READDIR3args) = 16;
  */
-static __be32
-nfsd3_proc_readdir(struct svc_rqst *rqstp)
+static __be32 nfsd3_proc_readdir(struct svc_rqst *rqstp)
 {
-	struct nfsd3_readdirargs *argp = rqstp->rq_argp;
+	struct READDIR3args_wrapper *argp = rqstp->rq_argp;
 	struct nfsd3_readdirres  *resp = rqstp->rq_resp;
-	loff_t		offset;
+	loff_t offset = argp->xdrgen.cookie;
+	struct svc_fh *fhp = &argp->fh;
 
-	trace_nfsd_vfs_readdir(rqstp, &argp->fh, argp->count, argp->cookie);
+	nfsd3_fh3_to_svc_fh(fhp, &argp->xdrgen.dir);
+	trace_nfsd_vfs_readdir(rqstp, fhp, argp->xdrgen.count,
+			       argp->xdrgen.cookie);
 
-	nfsd3_init_dirlist_pages(rqstp, resp, argp->count);
-
-	fh_copy(&resp->fh, &argp->fh);
+	nfsd3_init_dirlist_pages(rqstp, resp, argp->xdrgen.count);
+	fh_copy(&resp->fh, fhp);
 	resp->common.err = nfs_ok;
 	resp->cookie_offset = 0;
 	resp->rqstp = rqstp;
-	offset = argp->cookie;
 	resp->status = nfsd_readdir(rqstp, &resp->fh, &offset,
 				    &resp->common, nfs3svc_encode_entry3);
-	memcpy(resp->verf, argp->verf, 8);
+	memcpy(resp->verf, argp->xdrgen.cookieverf, NFS3_COOKIEVERFSIZE);
 	nfs3svc_encode_cookie3(resp, offset);
 
 	/* Recycle only pages that were part of the reply */
@@ -1997,15 +2011,15 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 		.pc_name	= "LINK",
 	},
 	[NFSPROC3_READDIR] = {
-		.pc_func = nfsd3_proc_readdir,
-		.pc_decode = nfs3svc_decode_readdirargs,
-		.pc_encode = nfs3svc_encode_readdirres,
-		.pc_release = nfs3svc_release_fhandle,
-		.pc_argsize = sizeof(struct nfsd3_readdirargs),
-		.pc_argzero = sizeof(struct nfsd3_readdirargs),
-		.pc_ressize = sizeof(struct nfsd3_readdirres),
-		.pc_cachetype = RC_NOCACHE,
-		.pc_name = "READDIR",
+		.pc_func	= nfsd3_proc_readdir,
+		.pc_decode	= nfs_svc_decode_READDIR3args,
+		.pc_encode	= nfs3svc_encode_readdirres,
+		.pc_release	= nfs3svc_release_fhandle,
+		.pc_argsize	= sizeof(struct READDIR3args_wrapper),
+		.pc_argzero	= 0,
+		.pc_ressize	= sizeof(struct nfsd3_readdirres),
+		.pc_cachetype	= RC_NOCACHE,
+		.pc_name	= "READDIR",
 	},
 	[NFSPROC3_READDIRPLUS] = {
 		.pc_func = nfsd3_proc_readdirplus,
@@ -2095,7 +2109,8 @@ union nfsd3_xdrstore {
 	struct RENAME3res		renameres;
 	struct LINK3args_wrapper	linkargs;
 	struct LINK3res			linkres;
-	struct nfsd3_readdirargs	readdirargs;
+	struct READDIR3args_wrapper	readdirargs;
+	struct nfsd3_readdirargs	readdirplusargs;
 	struct READLINK3res		readlinkres;
 	struct READ3res			readres;
 	struct nfsd3_writeres		writeres;
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index e93983d08aa5..0e83a2245c45 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -228,24 +228,6 @@ svcxdr_encode_post_op_attr(struct svc_rqst *rqstp, struct xdr_stream *xdr,
  * XDR decode functions
  */
 
-bool
-nfs3svc_decode_readdirargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd3_readdirargs *args = rqstp->rq_argp;
-
-	if (!svcxdr_decode_nfs_fh3(xdr, &args->fh))
-		return false;
-	if (xdr_stream_decode_u64(xdr, &args->cookie) < 0)
-		return false;
-	args->verf = xdr_inline_decode(xdr, NFS3_COOKIEVERFSIZE);
-	if (!args->verf)
-		return false;
-	if (xdr_stream_decode_u32(xdr, &args->count) < 0)
-		return false;
-
-	return true;
-}
-
 bool
 nfs3svc_decode_readdirplusargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 {
diff --git a/fs/nfsd/xdr3.h b/fs/nfsd/xdr3.h
index c434c93462a8..c67933ad3cd6 100644
--- a/fs/nfsd/xdr3.h
+++ b/fs/nfsd/xdr3.h
@@ -120,7 +120,6 @@ struct nfsd3_getaclres {
 	struct kstat		stat;
 };
 
-bool nfs3svc_decode_readdirargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_readdirplusargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 
 bool nfs3svc_encode_accessres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-- 
2.55.0


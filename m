Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 74AE8501F4F
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2026 12:49:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791895792; cv=none; b=KEnLlF5iIIjoqoULFROvM/QA3g3O2CKqzkGwBEtfOYdH7lLOYng0ZYKtJq/Q3cu0wTb0nyALRU5P5PBKqpMZdD8k/e9VxQIsH31a2CjU4c3FTFVO0NQ8dv8+WcMyHgbRgvLPVv4+KKJDA6s1S9BexO6hqOmoKdBxhVDvW5ivAQk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791895792; c=relaxed/simple;
	bh=dYVgftObvW4DlhQSAZar0BXe9PN3xzaMbji9R5ZiKjw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=udhvcPp+lYusFPoEVnh748GfzlSK0L22eeR4+p/bcdbIea0ROnMO+zPvkN4WzipVwbL2wZqU/dqab0Ug6xL7h5cJgXqk/kkNO3EMKBkYkNviNqcltIalqCSuSVbI5OlyMB1qcdVUOTQSu0esqWUNX87m7u+qeGnS9Vs13Bgh4fY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=n6vntCTg; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="n6vntCTg"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D47F31F000FF;
	Tue, 13 Oct 2026 12:49:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791895791;
	bh=+WWvJX4N4y8emTt4nrHBD2UlFwn3REQwRzjEYnL5WTU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=n6vntCTgnLuXxbf5AMXrx1yDFm8K3zV4YFGIRCa6hw5qZ9CI9xDhXST+fwfHOM4IW
	 vGKoyDJxN0CVYhruc7EWeE3fsYLY7NrmH5iu9qEW4jXxqTBZKW/c119trpHGNhtUbJ
	 vL6K2Fg/1RIX2N3plQKvCKkbGi3d67USXOPM/6dz7jv96Lrad3Lv/5HNaGHkdCo9qg
	 onZgIc2A/gLRb/Yl28vclii9ua9iUcd+s9Xynf5N+gtke1LCD8GOc2HhX7uW8S6IL/
	 ldl20NwHvFsI+SiZoxPkbav+6STTYzwtKYFP12VqIVn6UZ2+e5LeKG2QCbTLbwI6ix
	 6hgu/XlF1lODA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 27/34] NFSD: Use xdrgen XDR functions for NFSv3 READDIR arguments
Date: Tue, 13 Oct 2026 08:49:42 -0400
Message-ID: <20261013124944.316808-8-cel@kernel.org>
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
index 7a03c9ed8fbd..1764cd5e562d 100644
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
@@ -1506,28 +1513,35 @@ static void nfsd3_init_dirlist_pages(struct svc_rqst *rqstp,
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
@@ -1993,15 +2007,15 @@ static const struct svc_procedure nfsd_procedures3[22] = {
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
@@ -2091,7 +2105,8 @@ union nfsd3_xdrstore {
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
index e2110f9a126b..3fb4a01011ca 100644
--- a/fs/nfsd/xdr3.h
+++ b/fs/nfsd/xdr3.h
@@ -113,7 +113,6 @@ struct nfsd3_getaclres {
 	struct kstat		stat;
 };
 
-bool nfs3svc_decode_readdirargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_readdirplusargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 
 bool nfs3svc_encode_accessres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-- 
2.55.0


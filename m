Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E2F5D59481C
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 16:29:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789576166; cv=none; b=nMRdP4C3+SNUTx0bwuktwUbHJyg3PravaJz+OD38DoBbzm1bT+PKYFpur94TMPLLYt+5A4S4WSTr8IqirR3UDdSrX59cbXRlkyv1L53OZxvvPKznfCyatrVSVgpRuVXxLpUq2dz01LZd2eT3JMzQMxeXvxL5yn1AD6tlxQy4PWQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789576166; c=relaxed/simple;
	bh=3O+jAOT+x7dcqqVpdF7mdGHH49HiHO54lcAeg4143/4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=ou7t19vQodKG2s3Gl3fHA52ZD7CERakFWy4YbQlQHH9YXUtth7A9ZLItP5LSmPuJSIKv0lbwa+p1GktE51rILKKEqGWDuB6Mv5ksFbpywlpArcvZvbj0JI3JkFyywHlJJT2iMI1LcNiyUYj+wv3eGO/hBBHaTYgFGfnZooyDCzg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=BXZQRB+7; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="BXZQRB+7"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 70FAF1F00898;
	Wed, 16 Sep 2026 16:29:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789576163;
	bh=hDAZECZPdXJC/xzZvfXYh98m3M1Q5ioc1g4odOpmVL8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=BXZQRB+77Mh+fkmHpFKyTq4NTaXVrjPOJc1F3KD/AIebTeJ8STvMssBwg61+3t2B0
	 6xKK5ffdK0Q0+jcqpKMoeOEJShzjo6qlEc63MP5972dedQkJXddVsrb8ZDBZrRym+K
	 WLB3+pCy42VKJq7gdf9kc2InzTOLlBbRxX3Cf5t/N2uaCAvSlPf+JPQZG99MNcpp+p
	 HnMfD7gNyE8j9uFGIN49pa+r61eiw/r229f6yzrOpEIgalu2BoPtbQNZcEMY9x8P1h
	 iETRmRPlB+JLeiEoW+j1I+RFJ5aso+vr6GlZRuiQ16yJCTytGUYqs4YjcpYsMp27pv
	 YJmQGjTvoix/Q==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 18/27] NFSD: Use xdrgen XDR functions for the NFSv2 RENAME procedure
Date: Wed, 16 Sep 2026 12:28:49 -0400
Message-ID: <20260916162859.2051-21-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260916162859.2051-1-cel@kernel.org>
References: <20260916162859.2051-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Replace the NFSPROC_RENAME entry in the nfsd_procedures2 array
with an entry that dispatches the xdrgen-generated
nfs_svc_decode_renameargs and nfs_svc_encode_nfsstat. A wrapper
structure bridges the generated xdrgen renameargs type and the
legacy svc_fh representations the NFSD VFS layer still uses.

The pc_argzero field is now set to zero for the NFSv2 RENAME
procedure. The xdrgen decoders are trusted to initialize all
arguments in the argp->xdrgen field, making the early defensive
memset unnecessary. The remaining argp fields are cleared as
needed.

nfssvc_decode_renameargs() no longer has any callers, so it is
removed.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfsproc.c | 64 +++++++++++++++++++++++++++++++++--------------
 fs/nfsd/nfsxdr.c  | 11 --------
 fs/nfsd/xdr.h     | 10 --------
 3 files changed, 45 insertions(+), 40 deletions(-)

diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index ae74247a892f..755518f08490 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -85,6 +85,14 @@ struct writeargs_wrapper {
 
 static_assert(offsetof(struct writeargs_wrapper, xdrgen) == 0);
 
+struct renameargs_wrapper {
+	struct renameargs	xdrgen;
+	struct svc_fh		ffh;
+	struct svc_fh		tfh;
+};
+
+static_assert(offsetof(struct renameargs_wrapper, xdrgen) == 0);
+
 static __be32 nfsd_map_status(__be32 status)
 {
 	switch (status) {
@@ -875,17 +883,35 @@ static __be32 nfsd_proc_remove(struct svc_rqst *rqstp)
 	return rpc_success;
 }
 
-static __be32
-nfsd_proc_rename(struct svc_rqst *rqstp)
+/**
+ * nfsd_proc_rename - RENAME: Rename a file or directory
+ * @rqstp: RPC transaction context
+ *
+ * Return:
+ *   %rpc_success:		RPC executed successfully
+ *
+ * RPC synopsis:
+ *   nfsstat NFSPROC_RENAME(renameargs) = 11;
+ */
+static __be32 nfsd_proc_rename(struct svc_rqst *rqstp)
 {
-	struct nfsd_renameargs *argp = rqstp->rq_argp;
-	struct nfsd_stat *resp = rqstp->rq_resp;
+	struct renameargs_wrapper *argp = rqstp->rq_argp;
+	struct diropargs *from = &argp->xdrgen.from;
+	struct diropargs *to = &argp->xdrgen.to;
+	nfsstat *resp = rqstp->rq_resp;
+	struct svc_fh *ffhp = &argp->ffh;
+	struct svc_fh *tfhp = &argp->tfh;
 
-	resp->status = nfsd_rename(rqstp, &argp->ffh, argp->fname, argp->flen,
-				   &argp->tfh, argp->tname, argp->tlen);
-	fh_put(&argp->ffh);
-	fh_put(&argp->tfh);
-	resp->status = nfsd_map_status(resp->status);
+	nfsd_fhandle_to_svc_fh(ffhp, &from->dir);
+	nfsd_fhandle_to_svc_fh(tfhp, &to->dir);
+
+	*resp = nfsd_rename(rqstp, ffhp, (char *)from->name.data,
+			    from->name.len, tfhp, (char *)to->name.data,
+			    to->name.len);
+	*resp = nfsd_map_status(*resp);
+
+	fh_put(ffhp);
+	fh_put(tfhp);
 	return rpc_success;
 }
 
@@ -1178,15 +1204,15 @@ static const struct svc_procedure nfsd_procedures2[18] = {
 		.pc_name	= "REMOVE",
 	},
 	[NFSPROC_RENAME] = {
-		.pc_func = nfsd_proc_rename,
-		.pc_decode = nfssvc_decode_renameargs,
-		.pc_encode = nfssvc_encode_statres,
-		.pc_argsize = sizeof(struct nfsd_renameargs),
-		.pc_argzero = sizeof(struct nfsd_renameargs),
-		.pc_ressize = sizeof(struct nfsd_stat),
-		.pc_cachetype = RC_REPLSTAT,
-		.pc_xdrressize = ST,
-		.pc_name = "RENAME",
+		.pc_func	= nfsd_proc_rename,
+		.pc_decode	= nfs_svc_decode_renameargs,
+		.pc_encode	= nfs_svc_encode_nfsstat,
+		.pc_argsize	= sizeof(struct renameargs_wrapper),
+		.pc_argzero	= 0,
+		.pc_ressize	= sizeof(nfsstat),
+		.pc_cachetype	= RC_REPLSTAT,
+		.pc_xdrressize	= NFS2_nfsstat_sz,
+		.pc_name	= "RENAME",
 	},
 	[NFSPROC_LINK] = {
 		.pc_func = nfsd_proc_link,
@@ -1266,7 +1292,7 @@ union nfsd_xdrstore {
 	struct readargs_wrapper		readargs;
 	struct writeargs_wrapper	writeargs;
 	struct createargs_wrapper	createargs;
-	struct nfsd_renameargs	rename;
+	struct renameargs_wrapper	renameargs;
 	struct nfsd_linkargs	link;
 	struct nfsd_symlinkargs	symlink;
 	struct nfsd_readdirargs	readdir;
diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
index 33b3fb73053e..63496ad5e2ac 100644
--- a/fs/nfsd/nfsxdr.c
+++ b/fs/nfsd/nfsxdr.c
@@ -321,17 +321,6 @@ nfssvc_decode_createargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 		svcxdr_decode_sattr(rqstp, xdr, &args->attrs);
 }
 
-bool
-nfssvc_decode_renameargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd_renameargs *args = rqstp->rq_argp;
-
-	return svcxdr_decode_diropargs(xdr, &args->ffh,
-				       &args->fname, &args->flen) &&
-		svcxdr_decode_diropargs(xdr, &args->tfh,
-					&args->tname, &args->tlen);
-}
-
 bool
 nfssvc_decode_linkargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 {
diff --git a/fs/nfsd/xdr.h b/fs/nfsd/xdr.h
index 75f40bef6614..45582d21624c 100644
--- a/fs/nfsd/xdr.h
+++ b/fs/nfsd/xdr.h
@@ -21,15 +21,6 @@ struct nfsd_createargs {
 	struct iattr		attrs;
 };
 
-struct nfsd_renameargs {
-	struct svc_fh		ffh;
-	char *			fname;
-	unsigned int		flen;
-	struct svc_fh		tfh;
-	char *			tname;
-	unsigned int		tlen;
-};
-
 struct nfsd_linkargs {
 	struct svc_fh		ffh;
 	struct svc_fh		tfh;
@@ -90,7 +81,6 @@ struct nfsd_statfsres {
 bool nfssvc_decode_fhandleargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfssvc_decode_diropargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfssvc_decode_createargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-bool nfssvc_decode_renameargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfssvc_decode_linkargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfssvc_decode_symlinkargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfssvc_decode_readdirargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-- 
2.55.0


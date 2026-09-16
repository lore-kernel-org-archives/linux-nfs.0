Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6A95152E078
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 16:29:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789576171; cv=none; b=QR/W86bMAxMLSwZJgBPeSQ63zpkdGmjYReIRrWzRVu3plPjrgBbRK9DNg1mFkfRnNTTtzRN4lyFy2silLnqWwSBR6dOpXar7Oxww2Ofl9byRCzLxH6RaxQit9gxQXtBuv/XpdC7cNbpS9x+B9pR823PMgazHVrtYTw/oXR9zeuk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789576171; c=relaxed/simple;
	bh=Jen14Zqk6/u9Ol5sWQgesAhUvKqmXbNkWQ5Ve1N4r/8=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=byQfG7m2BQlxR7/POLhcthY1PLgYIcIS08B7QlxTMAHH1kXo5cjP1+D/qeAW5JWfxKKMWdWduBfbKomV02UnlpxxayryYvmYxrBzVsHnk4f+l+HxYNe7mSyK3N9QNdPA7XDBivvINrMxyfTaWM6dGkj1iFzQ4AXGon2iO2rk9s4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=os8b4wwq; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="os8b4wwq"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 395141F0089D;
	Wed, 16 Sep 2026 16:29:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789576163;
	bh=hSOtu3X6W/9EcByYX5tATW1Q4GojmDiuFLXcpEmtAP4=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=os8b4wwq01pRsHYs3unD5nzgw8XKGonljz98Rw4RKlTzCffLg7pZx4DY43M8cRkOR
	 OGeylKRsmyvjwQKMbsOK3MEH5TjTca43TF8OOTY3nkpCwwEHerWAWggR9DJdOJh/XD
	 dqAJ90M6EK11RzQCIVWJq3LhObQiuk3a2yzqt36lf2qsIk9+7fsb2C26myGt9MjTXN
	 SVOZFhwVnyOaR5thRx2AvbXaJHqoKnRgyG9OQutVP+YGA/OE9+fCtuQXxx7N26Inby
	 4bL8YgurBj+3YHgN2vgzGlsVsjnmwhdqXsV3oJ2darYpB5FQ2jCCG28Pa88KtDsU6w
	 fD50j4HnJQHtA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 19/27] NFSD: Use xdrgen XDR functions for the NFSv2 LINK procedure
Date: Wed, 16 Sep 2026 12:28:50 -0400
Message-ID: <20260916162859.2051-22-cel@kernel.org>
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

Replace the NFSPROC_LINK entry in the nfsd_procedures2 array
with an entry that dispatches the xdrgen-generated
nfs_svc_decode_linkargs and nfs_svc_encode_nfsstat. A wrapper
structure bridges the generated xdrgen linkargs type and the
legacy svc_fh representations the NFSD VFS layer still uses.

The pc_argzero field is now set to zero for the NFSv2 LINK
procedure. The xdrgen decoders are trusted to initialize all
arguments in the argp->xdrgen field, making the early defensive
memset unnecessary. The remaining argp fields are cleared as
needed.

nfssvc_decode_linkargs() no longer has any callers, so it is
removed.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfsproc.c | 62 ++++++++++++++++++++++++++++++++---------------
 fs/nfsd/nfsxdr.c  | 10 --------
 fs/nfsd/xdr.h     |  8 ------
 3 files changed, 43 insertions(+), 37 deletions(-)

diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 755518f08490..c74893060857 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -93,6 +93,14 @@ struct renameargs_wrapper {
 
 static_assert(offsetof(struct renameargs_wrapper, xdrgen) == 0);
 
+struct linkargs_wrapper {
+	struct linkargs		xdrgen;
+	struct svc_fh		ffh;
+	struct svc_fh		tfh;
+};
+
+static_assert(offsetof(struct linkargs_wrapper, xdrgen) == 0);
+
 static __be32 nfsd_map_status(__be32 status)
 {
 	switch (status) {
@@ -915,17 +923,33 @@ static __be32 nfsd_proc_rename(struct svc_rqst *rqstp)
 	return rpc_success;
 }
 
-static __be32
-nfsd_proc_link(struct svc_rqst *rqstp)
+/**
+ * nfsd_proc_link - LINK: Create Link to an object
+ * @rqstp: RPC transaction context
+ *
+ * Return:
+ *   %rpc_success:		RPC executed successfully
+ *
+ * RPC synopsis:
+ *   nfsstat NFSPROC_LINK(linkargs) = 12;
+ */
+static __be32 nfsd_proc_link(struct svc_rqst *rqstp)
 {
-	struct nfsd_linkargs *argp = rqstp->rq_argp;
-	struct nfsd_stat *resp = rqstp->rq_resp;
+	struct linkargs_wrapper *argp = rqstp->rq_argp;
+	struct diropargs *to = &argp->xdrgen.to;
+	nfsstat *resp = rqstp->rq_resp;
+	struct svc_fh *ffhp = &argp->ffh;
+	struct svc_fh *tfhp = &argp->tfh;
 
-	resp->status = nfsd_link(rqstp, &argp->tfh, argp->tname, argp->tlen,
-				 &argp->ffh);
-	fh_put(&argp->ffh);
-	fh_put(&argp->tfh);
-	resp->status = nfsd_map_status(resp->status);
+	nfsd_fhandle_to_svc_fh(ffhp, &argp->xdrgen.from);
+	nfsd_fhandle_to_svc_fh(tfhp, &to->dir);
+
+	*resp = nfsd_link(rqstp, tfhp, (char *)to->name.data, to->name.len,
+			  ffhp);
+	*resp = nfsd_map_status(*resp);
+
+	fh_put(ffhp);
+	fh_put(tfhp);
 	return rpc_success;
 }
 
@@ -1215,15 +1239,15 @@ static const struct svc_procedure nfsd_procedures2[18] = {
 		.pc_name	= "RENAME",
 	},
 	[NFSPROC_LINK] = {
-		.pc_func = nfsd_proc_link,
-		.pc_decode = nfssvc_decode_linkargs,
-		.pc_encode = nfssvc_encode_statres,
-		.pc_argsize = sizeof(struct nfsd_linkargs),
-		.pc_argzero = sizeof(struct nfsd_linkargs),
-		.pc_ressize = sizeof(struct nfsd_stat),
-		.pc_cachetype = RC_REPLSTAT,
-		.pc_xdrressize = ST,
-		.pc_name = "LINK",
+		.pc_func	= nfsd_proc_link,
+		.pc_decode	= nfs_svc_decode_linkargs,
+		.pc_encode	= nfs_svc_encode_nfsstat,
+		.pc_argsize	= sizeof(struct linkargs_wrapper),
+		.pc_argzero	= 0,
+		.pc_ressize	= sizeof(nfsstat),
+		.pc_cachetype	= RC_REPLSTAT,
+		.pc_xdrressize	= NFS2_nfsstat_sz,
+		.pc_name	= "LINK",
 	},
 	[NFSPROC_SYMLINK] = {
 		.pc_func = nfsd_proc_symlink,
@@ -1293,7 +1317,7 @@ union nfsd_xdrstore {
 	struct writeargs_wrapper	writeargs;
 	struct createargs_wrapper	createargs;
 	struct renameargs_wrapper	renameargs;
-	struct nfsd_linkargs	link;
+	struct linkargs_wrapper		linkargs;
 	struct nfsd_symlinkargs	symlink;
 	struct nfsd_readdirargs	readdir;
 	struct attrstat_wrapper		attrstat;
diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
index 63496ad5e2ac..ddbdf10b9982 100644
--- a/fs/nfsd/nfsxdr.c
+++ b/fs/nfsd/nfsxdr.c
@@ -321,16 +321,6 @@ nfssvc_decode_createargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 		svcxdr_decode_sattr(rqstp, xdr, &args->attrs);
 }
 
-bool
-nfssvc_decode_linkargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd_linkargs *args = rqstp->rq_argp;
-
-	return svcxdr_decode_fhandle(xdr, &args->ffh) &&
-		svcxdr_decode_diropargs(xdr, &args->tfh,
-					&args->tname, &args->tlen);
-}
-
 bool
 nfssvc_decode_symlinkargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 {
diff --git a/fs/nfsd/xdr.h b/fs/nfsd/xdr.h
index 45582d21624c..2cc1581788d8 100644
--- a/fs/nfsd/xdr.h
+++ b/fs/nfsd/xdr.h
@@ -21,13 +21,6 @@ struct nfsd_createargs {
 	struct iattr		attrs;
 };
 
-struct nfsd_linkargs {
-	struct svc_fh		ffh;
-	struct svc_fh		tfh;
-	char *			tname;
-	unsigned int		tlen;
-};
-
 struct nfsd_symlinkargs {
 	struct svc_fh		ffh;
 	char *			fname;
@@ -81,7 +74,6 @@ struct nfsd_statfsres {
 bool nfssvc_decode_fhandleargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfssvc_decode_diropargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfssvc_decode_createargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-bool nfssvc_decode_linkargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfssvc_decode_symlinkargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfssvc_decode_readdirargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 
-- 
2.55.0


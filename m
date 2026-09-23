Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0B1115304CC
	for <linux-nfs@vger.kernel.org>; Wed, 23 Sep 2026 13:28:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790170115; cv=none; b=hwLB86JCjz5kWkP8XG4c1Kk4w3xE8qsOCFluy812B+uvV8tl3U556ytkYyPwFNjykg8mD4lNK2dY6MV+Nj8+Xwwc+sZyRDOoY+ZY9B7Wq+B59Qz6WYgUkdFrJDOAZmY58cHbuKLeEX5Otj0QLR2P04UBnTyPMMs4Z0KDFJsWbjI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790170115; c=relaxed/simple;
	bh=r7WE8l/LbZERoR/Z7tjsiuSOP/LI6J40deN8QmZribE=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=dMKOCHXuv2sbPYGG67uuAj1Z89bJcuz8Lc+9aL+ssph2irQa9fsrTkBExHpm7vJKkswUY7o4OvpLeHaWXsXpjQHN2SKZIaQUI5k9+18En5MKnKGMGXlOwrgGBjtx1V8yD1FyQsm1ZTHpP4I19x0pUGvp6BrgMj6j9qFgYN8N0iw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=MTY9vdEJ; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="MTY9vdEJ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 66D781F00899;
	Wed, 23 Sep 2026 13:28:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790170113;
	bh=sImchkM6++WMEaCi7F66sgIL34d/+Yw5giw7ZQqPwzk=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=MTY9vdEJGldW28k76PD2QDkoHOxbzv78WyT9a1qFvRiKba3qqIUK0JiF0bqYoecm5
	 74el+oNmBLmo1fIDOT3MN4o+7yMop5QYETqTJYOQzbynFQWDAxrp8zVfMjrWW0lDET
	 lW30/iivQ5affbY6zpBDYaWUwtgciDQjftxSDJVkS78lk9TUrKW4lmjSkHsavXmI9K
	 csFiNDRzg03G+SId+5KpHJ/VoFJj3SutuVqMNXmfX5q3X6oI1dPeQNfXLu7ocUmvNC
	 +WriFKSs0iJg8GO/MJ38AmMKfyAiWx36relN8lzRl3+PJYb9ecu/30eUDsACfp7upr
	 AMXqk1eTnOeVQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 23/33] NFSD: Use xdrgen XDR functions for the NFSv3 FSSTAT procedure
Date: Wed, 23 Sep 2026 09:28:01 -0400
Message-ID: <20260923132811.244160-24-cel@kernel.org>
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

Replace the NFSPROC3_FSSTAT entry in the nfsd_procedures3 array with
an entry that dispatches the xdrgen-generated
nfs_svc_decode_FSSTAT3args and nfs_svc_encode_FSSTAT3res. A wrapper
structure bridges the generated xdrgen argument type and the legacy
svc_fh representation the NFSD VFS layer still uses. The result
wrapper carries a scratch kstatfs alongside the generated FSSTAT3res
type, which nfsd_statfs() fills before nfsd3_proc_fsstat() copies the
values into the encoded result.

The pc_argzero field is now set to zero for the NFSv3 FSSTAT
procedure. The xdrgen decoders are trusted to initialize all
arguments in the argp->xdrgen field, making the early defensive
memset unnecessary. The remaining argp fields are cleared as needed.

nfsd3_proc_fsstat() now sets the post-op attributes directly. This
makes it straightforward to confirm that the file handle is released
during every error flow.

nfs3svc_encode_fsstatres() no longer has any callers, so it is
removed, and with it the now-orphaned svcxdr_encode_fsstat3resok()
encode helper.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs3proc.c | 71 +++++++++++++++++++++++++++++++++++-----------
 fs/nfsd/nfs3xdr.c  | 45 -----------------------------
 fs/nfsd/xdr3.h     |  6 ++--
 3 files changed, 57 insertions(+), 65 deletions(-)

diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 3706991ecea4..b9bcd05d4152 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -193,6 +193,13 @@ struct LINK3args_wrapper {
 
 static_assert(offsetof(struct LINK3args_wrapper, xdrgen) == 0);
 
+struct FSSTAT3args_wrapper {
+	struct FSSTAT3args	xdrgen;
+	struct svc_fh		fh;
+};
+
+static_assert(offsetof(struct FSSTAT3args_wrapper, xdrgen) == 0);
+
 static int nfsd3_ftype3_to_mode(ftype3 ftype)
 {
 	switch (ftype) {
@@ -1559,18 +1566,47 @@ nfsd3_proc_readdirplus(struct svc_rqst *rqstp)
 	return rpc_success;
 }
 
-/*
- * Get file system stats
+/**
+ * nfsd3_proc_fsstat - FSSTAT: Get dynamic file system information
+ * @rqstp: RPC transaction context
+ *
+ * Return:
+ *   %rpc_success:		RPC executed successfully
+ *
+ * RPC synopsis:
+ *   FSSTAT3res NFSPROC3_FSSTAT(FSSTAT3args) = 18;
  */
-static __be32
-nfsd3_proc_fsstat(struct svc_rqst *rqstp)
+static __be32 nfsd3_proc_fsstat(struct svc_rqst *rqstp)
 {
-	struct nfsd_fhandle *argp = rqstp->rq_argp;
+	struct FSSTAT3args_wrapper *argp = rqstp->rq_argp;
 	struct nfsd3_fsstatres *resp = rqstp->rq_resp;
+	struct kstatfs *statp = &resp->stats;
+	struct svc_fh *fhp = &argp->fh;
 
-	resp->status = nfsd_statfs(rqstp, &argp->fh, &resp->stats, 0);
-	fh_put(&argp->fh);
-	resp->status = nfsd3_map_status(resp->status);
+	nfsd3_fh3_to_svc_fh(fhp, &argp->xdrgen.fsroot);
+
+	resp->xdrgen.status = nfsd_statfs(rqstp, fhp, statp, 0);
+
+	if (resp->xdrgen.status == nfs_ok) {
+		struct FSSTAT3resok *resok = &resp->xdrgen.u.resok;
+		u64 bs = statp->f_bsize;
+
+		resok->obj_attributes.attributes_follow = false;
+		resok->tbytes = bs * statp->f_blocks;
+		resok->fbytes = bs * statp->f_bfree;
+		resok->abytes = bs * statp->f_bavail;
+		resok->tfiles = statp->f_files;
+		resok->ffiles = statp->f_ffree;
+		resok->afiles = statp->f_ffree;
+		resok->invarsec = 0;
+	} else {
+		struct FSSTAT3resfail *resfail = &resp->xdrgen.u.resfail;
+
+		resp->xdrgen.status = nfsd3_map_status(resp->xdrgen.status);
+		resfail->obj_attributes.attributes_follow = false;
+	}
+
+	fh_put(fhp);
 	return rpc_success;
 }
 
@@ -1928,15 +1964,15 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 		.pc_name = "READDIRPLUS",
 	},
 	[NFSPROC3_FSSTAT] = {
-		.pc_func = nfsd3_proc_fsstat,
-		.pc_decode = nfs3svc_decode_fhandleargs,
-		.pc_encode = nfs3svc_encode_fsstatres,
-		.pc_argsize = sizeof(struct nfsd3_fhandleargs),
-		.pc_argzero = sizeof(struct nfsd3_fhandleargs),
-		.pc_ressize = sizeof(struct nfsd3_fsstatres),
-		.pc_cachetype = RC_NOCACHE,
-		.pc_xdrressize = ST+pAT+2*6+1,
-		.pc_name = "FSSTAT",
+		.pc_func	= nfsd3_proc_fsstat,
+		.pc_decode	= nfs_svc_decode_FSSTAT3args,
+		.pc_encode	= nfs_svc_encode_FSSTAT3res,
+		.pc_argsize	= sizeof(struct FSSTAT3args_wrapper),
+		.pc_argzero	= 0,
+		.pc_ressize	= sizeof(struct nfsd3_fsstatres),
+		.pc_cachetype	= RC_NOCACHE,
+		.pc_xdrressize	= NFS3_FSSTAT3res_sz,
+		.pc_name	= "FSSTAT",
 	},
 	[NFSPROC3_FSINFO] = {
 		.pc_func = nfsd3_proc_fsinfo,
@@ -2010,6 +2046,7 @@ union nfsd3_xdrstore {
 	struct READ3res			readres;
 	struct nfsd3_writeres		writeres;
 	struct nfsd3_readdirres		readdirres;
+	struct FSSTAT3args_wrapper	fsstatargs;
 	struct nfsd3_fsstatres		fsstatres;
 	struct nfsd3_fsinfores		fsinfores;
 	struct nfsd3_pathconfres	pathconfres;
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index 59e89b7f9d19..0ca671bdd1c8 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -620,51 +620,6 @@ int nfs3svc_encode_entryplus3(void *data, const char *name, int namlen,
 	return -EINVAL;
 }
 
-static bool
-svcxdr_encode_fsstat3resok(struct xdr_stream *xdr,
-			   const struct nfsd3_fsstatres *resp)
-{
-	const struct kstatfs *s = &resp->stats;
-	u64 bs = s->f_bsize;
-	__be32 *p;
-
-	p = xdr_reserve_space(xdr, XDR_UNIT * 13);
-	if (!p)
-		return false;
-	p = xdr_encode_hyper(p, bs * s->f_blocks);	/* total bytes */
-	p = xdr_encode_hyper(p, bs * s->f_bfree);	/* free bytes */
-	p = xdr_encode_hyper(p, bs * s->f_bavail);	/* user available bytes */
-	p = xdr_encode_hyper(p, s->f_files);		/* total inodes */
-	p = xdr_encode_hyper(p, s->f_ffree);		/* free inodes */
-	p = xdr_encode_hyper(p, s->f_ffree);		/* user available inodes */
-	*p = cpu_to_be32(resp->invarsec);		/* mean unchanged time */
-
-	return true;
-}
-
-/* FSSTAT */
-bool
-nfs3svc_encode_fsstatres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd3_fsstatres *resp = rqstp->rq_resp;
-
-	if (!svcxdr_encode_nfsstat3(xdr, resp->status))
-		return false;
-	switch (resp->status) {
-	case nfs_ok:
-		if (!svcxdr_encode_post_op_attr(rqstp, xdr, &nfs3svc_null_fh))
-			return false;
-		if (!svcxdr_encode_fsstat3resok(xdr, resp))
-			return false;
-		break;
-	default:
-		if (!svcxdr_encode_post_op_attr(rqstp, xdr, &nfs3svc_null_fh))
-			return false;
-	}
-
-	return true;
-}
-
 static bool
 svcxdr_encode_fsinfo3resok(struct xdr_stream *xdr,
 			   const struct nfsd3_fsinfores *resp)
diff --git a/fs/nfsd/xdr3.h b/fs/nfsd/xdr3.h
index 9f29f34cca8f..01c8539e67b8 100644
--- a/fs/nfsd/xdr3.h
+++ b/fs/nfsd/xdr3.h
@@ -93,11 +93,12 @@ struct nfsd3_readdirres {
 };
 
 struct nfsd3_fsstatres {
-	__be32			status;
+	struct FSSTAT3res	xdrgen;
 	struct kstatfs		stats;
-	__u32			invarsec;
 };
 
+static_assert(offsetof(struct nfsd3_fsstatres, xdrgen) == 0);
+
 struct nfsd3_fsinfores {
 	__be32			status;
 	__u32			f_rtmax;
@@ -143,7 +144,6 @@ bool nfs3svc_decode_commitargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 
 bool nfs3svc_encode_accessres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_encode_readdirres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-bool nfs3svc_encode_fsstatres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_encode_fsinfores(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_encode_pathconfres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_encode_commitres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-- 
2.55.0


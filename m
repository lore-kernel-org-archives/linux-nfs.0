Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8BE91595731
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 16:29:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789576171; cv=none; b=r1wLQrV1PRbkzDlYHOKF37q4y3gh+D5lwFeb305e36zqdwHNj9vbXvZ+rYlnstbmouaP9rjLqCvpo1ldidhMlzFy5M2kGCZjSWZgJ7MvY7But/cQMV3q76pO0mMdqCoF64SYH4JGR5ECL0KsGv6MaM19RvpEw3vRG8vZyGovDa4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789576171; c=relaxed/simple;
	bh=bTe1r2DZk4Mkq5lnncs1TdUpa29Qaa0aevNmxMHaEhg=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Clja58g3qcQpngrzfwWFK+b8ZaL4nCKwmOacrrz0Q9uryiuP89gemrCBH+1RnSO/YTRaoklOHY0UNe4T7zKu2yEsKDuxOIByTDEoLLGh2bmJC8ywAEgVCpmAKVNXiVY0SSmUUwNbtXjuFOUxQHP8Y3iifN4UPnoedBy3LeK4lXg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=CYsc8fKJ; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="CYsc8fKJ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3FA261F00893;
	Wed, 16 Sep 2026 16:29:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789576166;
	bh=vVsbhiGX0KEQsg8Vircz8TAhuBrG24qS+OkK0YlAicM=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=CYsc8fKJnZ9Gkck/33tRYrQ7ekxZ8T43jxrSOjTKgjUA/qhB5Mhoe5iKFNVcrzbby
	 tINo+tOCpsXtF1VQNzOiX7KbJ+XKHU//etf6i4C8ChsNcXIURMW7N3ZT8aLjUa9BY5
	 NlzjPuNk8H2rOVh8CRGw/Sg93m/pOrNDaaU5XmJWO6iT5fHTVpYSPhRsvFheux2uAe
	 ZmKXZohtK0ZGgSqiUP28vXWFe7f6DiIVSk4p+ijagaSw3u6tCoJCL5FT0fEiyFh2Tb
	 Wcm32hNUYE/qq92yeAnEK2u6vxY850v8a4t/3yoDeGaPqXEiPBO4JmWd6ENzPbZfmg
	 Wu4nqSwvwI7Aw==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 23/27] NFSD: Use xdrgen XDR functions for the NFSv2 STATFS procedure
Date: Wed, 16 Sep 2026 12:28:54 -0400
Message-ID: <20260916162859.2051-26-cel@kernel.org>
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

Replace the NFSPROC_STATFS entry in the nfsd_procedures2 array
with an entry that dispatches the xdrgen-generated
nfs_svc_decode_fhandle and nfs_svc_encode_statfsres. Wrapper
structures bridge the generated xdrgen types and the legacy
svc_fh and kstatfs representations the NFSD VFS layer still uses.

The pc_argzero field is now set to zero for the NFSv2 STATFS
procedure. The xdrgen decoders are trusted to initialize all
arguments in the argp->xdrgen field, making the early defensive
memset unnecessary. The remaining argp fields are cleared as
needed.

nfsd_proc_statfs() now fills in the statfsres info fields
directly. This makes it straightforward to confirm that the file
handle is released during every error flow.

nfssvc_encode_statfsres() no longer has any callers, so it is
removed.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfsproc.c | 68 +++++++++++++++++++++++++++++++++--------------
 fs/nfsd/nfsxdr.c  | 25 -----------------
 fs/nfsd/xdr.h     |  6 -----
 3 files changed, 48 insertions(+), 51 deletions(-)

diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index ddf743aea89c..327088a1012c 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -109,6 +109,13 @@ struct symlinkargs_wrapper {
 
 static_assert(offsetof(struct symlinkargs_wrapper, xdrgen) == 0);
 
+struct statfsres_wrapper {
+	struct statfsres	xdrgen;
+	struct kstatfs		stats;
+};
+
+static_assert(offsetof(struct statfsres_wrapper, xdrgen) == 0);
+
 static __be32 nfsd_map_status(__be32 status)
 {
 	switch (status) {
@@ -1154,19 +1161,40 @@ nfsd_proc_readdir(struct svc_rqst *rqstp)
 	return rpc_success;
 }
 
-/*
- * Get file system info
+/**
+ * nfsd_proc_statfs - STATFS: Get filesystem attributes
+ * @rqstp: RPC transaction context
+ *
+ * Return:
+ *   %rpc_success:		RPC executed successfully
+ *
+ * RPC synopsis:
+ *   statfsres NFSPROC_STATFS(fhandle) = 17;
  */
-static __be32
-nfsd_proc_statfs(struct svc_rqst *rqstp)
+static __be32 nfsd_proc_statfs(struct svc_rqst *rqstp)
 {
-	struct nfsd_fhandle *argp = rqstp->rq_argp;
-	struct nfsd_statfsres *resp = rqstp->rq_resp;
+	struct fhandle_wrapper *argp = rqstp->rq_argp;
+	struct statfsres_wrapper *resp = rqstp->rq_resp;
+	struct kstatfs *stat = &resp->stats;
+	struct svc_fh *fhp = &argp->fh;
 
-	resp->status = nfsd_statfs(rqstp, &argp->fh, &resp->stats,
-				   NFSD_MAY_BYPASS_GSS_ON_ROOT);
-	fh_put(&argp->fh);
-	resp->status = nfsd_map_status(resp->status);
+	nfsd_fhandle_to_svc_fh(fhp, &argp->xdrgen);
+
+	resp->xdrgen.status = nfsd_statfs(rqstp, fhp, stat,
+					  NFSD_MAY_BYPASS_GSS_ON_ROOT);
+	if (resp->xdrgen.status == nfs_ok) {
+		struct info *resinfo = &resp->xdrgen.u.info;
+
+		resinfo->tsize = NFS_MAXDATA;
+		resinfo->bsize = stat->f_bsize;
+		resinfo->blocks = stat->f_blocks;
+		resinfo->bfree = stat->f_bfree;
+		resinfo->bavail = stat->f_bavail;
+	} else {
+		resp->xdrgen.status = nfsd_map_status(resp->xdrgen.status);
+	}
+
+	fh_put(fhp);
 	return rpc_success;
 }
 
@@ -1367,15 +1395,15 @@ static const struct svc_procedure nfsd_procedures2[18] = {
 		.pc_name = "READDIR",
 	},
 	[NFSPROC_STATFS] = {
-		.pc_func = nfsd_proc_statfs,
-		.pc_decode = nfssvc_decode_fhandleargs,
-		.pc_encode = nfssvc_encode_statfsres,
-		.pc_argsize = sizeof(struct nfsd_fhandle),
-		.pc_argzero = sizeof(struct nfsd_fhandle),
-		.pc_ressize = sizeof(struct nfsd_statfsres),
-		.pc_cachetype = RC_NOCACHE,
-		.pc_xdrressize = ST+5,
-		.pc_name = "STATFS",
+		.pc_func	= nfsd_proc_statfs,
+		.pc_decode	= nfs_svc_decode_fhandle,
+		.pc_encode	= nfs_svc_encode_statfsres,
+		.pc_argsize	= sizeof(struct fhandle_wrapper),
+		.pc_argzero	= 0,
+		.pc_ressize	= sizeof(struct statfsres_wrapper),
+		.pc_cachetype	= RC_NOCACHE,
+		.pc_xdrressize	= NFS2_statfsres_sz,
+		.pc_name	= "STATFS",
 	},
 };
 
@@ -1397,7 +1425,7 @@ union nfsd_xdrstore {
 	struct readlinkres	readlinkres;
 	struct readres		readres;
 	struct nfsd_readdirres	readdirres;
-	struct nfsd_statfsres	statfsres;
+	struct statfsres_wrapper	statfsres;
 };
 
 const struct svc_version nfsd_version2 = {
diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
index e839de8c9815..5da47ba5b465 100644
--- a/fs/nfsd/nfsxdr.c
+++ b/fs/nfsd/nfsxdr.c
@@ -232,31 +232,6 @@ nfssvc_encode_readdirres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 	return true;
 }
 
-bool
-nfssvc_encode_statfsres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd_statfsres *resp = rqstp->rq_resp;
-	struct kstatfs	*stat = &resp->stats;
-	__be32 *p;
-
-	if (!svcxdr_encode_stat(xdr, resp->status))
-		return false;
-	switch (resp->status) {
-	case nfs_ok:
-		p = xdr_reserve_space(xdr, XDR_UNIT * 5);
-		if (!p)
-			return false;
-		*p++ = cpu_to_be32(NFS_MAXDATA);
-		*p++ = cpu_to_be32(stat->f_bsize);
-		*p++ = cpu_to_be32(stat->f_blocks);
-		*p++ = cpu_to_be32(stat->f_bfree);
-		*p = cpu_to_be32(stat->f_bavail);
-		break;
-	}
-
-	return true;
-}
-
 /**
  * nfssvc_encode_nfscookie - Encode a directory offset cookie
  * @resp: readdir result context
diff --git a/fs/nfsd/xdr.h b/fs/nfsd/xdr.h
index 64e0febe32da..6537ea17c63a 100644
--- a/fs/nfsd/xdr.h
+++ b/fs/nfsd/xdr.h
@@ -33,16 +33,10 @@ struct nfsd_readdirres {
 	unsigned int		cookie_offset;
 };
 
-struct nfsd_statfsres {
-	__be32			status;
-	struct kstatfs		stats;
-};
-
 bool nfssvc_decode_fhandleargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfssvc_decode_readdirargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 
 bool nfssvc_encode_attrstatres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-bool nfssvc_encode_statfsres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfssvc_encode_readdirres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 
 void nfssvc_encode_nfscookie(struct nfsd_readdirres *resp, u32 offset);
-- 
2.55.0


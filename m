Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D728150255F
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2026 12:49:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791895791; cv=none; b=Pl8VTWnc1zdrHWLu1dBod5SDWvwwpnO2HVEVBnCoArz7Jc2PJ13+5OGWnBzFmoMI3410QrlbVjsEAiXa2IFyOzd27WaHOW7OR42wSbfoEqHSFHl8XXY74iTpT1KuloopjVGKaS/Z8QYhYnO54epil+aw5ot3yG1wruaFs+Ydfhw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791895791; c=relaxed/simple;
	bh=4nJwLEffR/Tf/cOWtj0H+ZoYa1C1CWbrZLLtuijdMn0=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Ek9ZR6bdJkt/1EBgEpjgKVWjO+1obGmbIdvIL5hjL5CBfJ1OY/h2jwG7Kz8K5Jv9gyO8NE9VVXtJaNORKsCucf8W7NxqQ44PJ8QCCvjxmQQmmWLOyenFVeKJwNouvrlE0oA7ag7zgW2b01dCq+pIXKPbGNAsQ4Grzjzq7Dd84i4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Nt3hp20x; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Nt3hp20x"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3E3471F0089C;
	Tue, 13 Oct 2026 12:49:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791895789;
	bh=HkIUms4CWMkl1xbb6YICgGK78oED+w3TTyqfpOtDEsU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Nt3hp20xzdU5QWT5GKzT8V4G4AE+aSISU5jBmy6kvVKCEX+4jhEOYwM0AfAjYgtaj
	 BhtQkEIfTuLwjtqD1xxyCiguyude5yMx/ny8hAMXpsn7PIrvGGWAcMZf2QXHZ3lljg
	 jakPOaYaRCjbHnQKMG+TX/Cqkstu1RqVCTxNhCoDwvoqYIrjDwjZtaSKFQFMkJcidO
	 Q/HQUnIWgNHKSECvI5u7G01Q0dXfHLl/mg7aD0wWCzrDZTKbybcQUVgZw5pzYshQBK
	 wcf/1DQg3/U6eD0C8VSaG2WHm6UfbtI8o/TnWv2oDEuvq7cF2fr/L6XlzDpqea0BA7
	 Y/702PGU8QEpQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 25/34] NFSD: Use xdrgen XDR functions for the NFSv3 PATHCONF procedure
Date: Tue, 13 Oct 2026 08:49:40 -0400
Message-ID: <20261013124944.316808-6-cel@kernel.org>
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

Replace the NFSPROC3_PATHCONF entry in the nfsd_procedures3 array
with an entry that dispatches the xdrgen-generated
nfs_svc_decode_PATHCONF3args and nfs_svc_encode_PATHCONF3res. A
wrapper structure bridges the generated xdrgen argument type and the
legacy svc_fh representation the NFSD VFS layer still uses.

The pc_argzero field is now set to zero for the NFSv3 PATHCONF
procedure. The xdrgen decoders are trusted to initialize all
arguments in the argp->xdrgen field, making the early defensive
memset unnecessary. The remaining argp fields are cleared as needed.

nfsd3_proc_pathconf() now sets the post-op attributes directly. This
makes it straightforward to confirm that the file handle is released
during every error flow.

nfs3svc_encode_pathconfres() no longer has any callers, so it is
removed, and with it the now-orphaned svcxdr_encode_pathconf3resok()
encode helper and the nfs3svc_null_fh constant it referenced. This
was also the last user of the shared nfs3svc_decode_fhandleargs()
decoder, so that too is removed.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs3proc.c | 94 +++++++++++++++++++++++++++-------------------
 fs/nfsd/nfs3xdr.c  | 57 ----------------------------
 fs/nfsd/xdr3.h     | 12 ++----
 3 files changed, 59 insertions(+), 104 deletions(-)

diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index ff159d3a0fa6..c1bb9ede4535 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -204,6 +204,13 @@ struct FSINFO3args_wrapper {
 
 static_assert(offsetof(struct FSINFO3args_wrapper, xdrgen) == 0);
 
+struct PATHCONF3args_wrapper {
+	struct PATHCONF3args	xdrgen;
+	struct svc_fh		fh;
+};
+
+static_assert(offsetof(struct PATHCONF3args_wrapper, xdrgen) == 0);
+
 static int nfsd3_ftype3_to_mode(ftype3 ftype)
 {
 	switch (ftype) {
@@ -1670,40 +1677,47 @@ static __be32 nfsd3_proc_fsinfo(struct svc_rqst *rqstp)
 	return rpc_success;
 }
 
-/*
- * Get pathconf info for the specified file
+/**
+ * nfsd3_proc_pathconf - PATHCONF: Retrieve POSIX information
+ * @rqstp: RPC transaction context
+ *
+ * Return:
+ *   %rpc_success:		RPC executed successfully
+ *
+ * RPC synopsis:
+ *   PATHCONF3res NFSPROC3_PATHCONF(PATHCONF3args) = 20;
  */
-static __be32
-nfsd3_proc_pathconf(struct svc_rqst *rqstp)
+static __be32 nfsd3_proc_pathconf(struct svc_rqst *rqstp)
 {
-	struct nfsd_fhandle *argp = rqstp->rq_argp;
+	struct PATHCONF3args_wrapper *argp = rqstp->rq_argp;
 	struct nfsd3_pathconfres *resp = rqstp->rq_resp;
+	struct svc_fh *fhp = &argp->fh;
 
-	dprintk("nfsd: PATHCONF(3) %s\n",
-				SVCFH_fmt(&argp->fh));
+	nfsd3_fh3_to_svc_fh(fhp, &argp->xdrgen.object);
 
-	/* Set default pathconf */
-	resp->p_link_max = 255;		/* at least */
-	resp->p_name_max = 255;		/* at least */
-	resp->p_no_trunc = 0;
-	resp->p_chown_restricted = 1;
-	resp->p_case_insensitive = false;
-	resp->p_case_preserving = true;
+	resp->xdrgen.status = fh_verify(rqstp, fhp, 0, NFSD_MAY_NOP);
 
-	resp->status = fh_verify(rqstp, &argp->fh, 0, NFSD_MAY_NOP);
-
-	if (resp->status == nfs_ok) {
-		struct super_block *sb = argp->fh.fh_dentry->d_sb;
+	if (resp->xdrgen.status == nfs_ok) {
+		struct PATHCONF3resok *resok = &resp->xdrgen.u.resok;
+		struct super_block *sb = fhp->fh_dentry->d_sb;
 		int err;
 
+		resok->obj_attributes.attributes_follow = false;
+		resok->linkmax = 255;
+		resok->name_max = NAME_MAX;
+		resok->no_trunc = false;
+		resok->chown_restricted = true;
+		resok->case_insensitive = false;
+		resok->case_preserving = true;
+
 		if (sb->s_magic == EXT2_SUPER_MAGIC) {
-			resp->p_link_max = EXT2_LINK_MAX;
-			resp->p_name_max = EXT2_NAME_LEN;
+			resok->linkmax = EXT2_LINK_MAX;
+			resok->name_max = EXT2_NAME_LEN;
 		}
 
-		err = nfsd_get_case_info(argp->fh.fh_dentry,
-					 &resp->p_case_insensitive,
-					 &resp->p_case_preserving);
+		err = nfsd_get_case_info(fhp->fh_dentry,
+					 &resok->case_insensitive,
+					 &resok->case_preserving);
 		/*
 		 * RFC 1813 lists NFS3ERR_STALE, NFS3ERR_BADHANDLE, and
 		 * NFS3ERR_SERVERFAULT as the only PATHCONF errors.
@@ -1720,19 +1734,23 @@ nfsd3_proc_pathconf(struct svc_rqst *rqstp)
 			 * handle is unusable without implying a server
 			 * malfunction.
 			 */
-			resp->status = nfserr_stale;
+			resp->xdrgen.status = nfserr_stale;
 			break;
 		case -ESTALE:
-			resp->status = nfserr_stale;
+			resp->xdrgen.status = nfserr_stale;
 			break;
 		default:
-			resp->status = nfserr_serverfault;
+			resp->xdrgen.status = nfserr_serverfault;
 			break;
 		}
+	} else {
+		struct PATHCONF3resfail *resfail = &resp->xdrgen.u.resfail;
+
+		resp->xdrgen.status = nfsd3_map_status(resp->xdrgen.status);
+		resfail->obj_attributes.attributes_follow = false;
 	}
 
-	fh_put(&argp->fh);
-	resp->status = nfsd3_map_status(resp->status);
+	fh_put(fhp);
 	return rpc_success;
 }
 
@@ -1770,7 +1788,6 @@ nfsd3_proc_commit(struct svc_rqst *rqstp)
  * Only the results of non-idempotent operations are cached.
  */
 #define nfsd3_readdirplusargs		nfsd3_readdirargs
-#define nfsd3_fhandleargs		nfsd_fhandle
 
 #define ST 1		/* status*/
 #define AT 21		/* attributes */
@@ -2002,15 +2019,15 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 		.pc_name	= "FSINFO",
 	},
 	[NFSPROC3_PATHCONF] = {
-		.pc_func = nfsd3_proc_pathconf,
-		.pc_decode = nfs3svc_decode_fhandleargs,
-		.pc_encode = nfs3svc_encode_pathconfres,
-		.pc_argsize = sizeof(struct nfsd3_fhandleargs),
-		.pc_argzero = sizeof(struct nfsd3_fhandleargs),
-		.pc_ressize = sizeof(struct nfsd3_pathconfres),
-		.pc_cachetype = RC_NOCACHE,
-		.pc_xdrressize = ST+pAT+6,
-		.pc_name = "PATHCONF",
+		.pc_func	= nfsd3_proc_pathconf,
+		.pc_decode	= nfs_svc_decode_PATHCONF3args,
+		.pc_encode	= nfs_svc_encode_PATHCONF3res,
+		.pc_argsize	= sizeof(struct PATHCONF3args_wrapper),
+		.pc_argzero	= 0,
+		.pc_ressize	= sizeof(struct nfsd3_pathconfres),
+		.pc_cachetype	= RC_NOCACHE,
+		.pc_xdrressize	= NFS3_PATHCONF3res_sz,
+		.pc_name	= "PATHCONF",
 	},
 	[NFSPROC3_COMMIT] = {
 		.pc_func = nfsd3_proc_commit,
@@ -2066,6 +2083,7 @@ union nfsd3_xdrstore {
 	struct nfsd3_fsstatres		fsstatres;
 	struct FSINFO3args_wrapper	fsinfoargs;
 	struct nfsd3_fsinfores		fsinfores;
+	struct PATHCONF3args_wrapper	pathconfargs;
 	struct nfsd3_pathconfres	pathconfres;
 	struct nfsd3_commitres		commitres;
 	struct nfsd3_getaclres		getaclres;
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index 9e400a97e435..3da66b5cac22 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -17,13 +17,6 @@
 #include "vfs.h"
 #include "nfserr.h"
 
-/*
- * Force construction of an empty post-op attr
- */
-static const struct svc_fh nfs3svc_null_fh = {
-	.fh_no_wcc	= true,
-};
-
 /*
  * Mapping of S_IF* types to NFS file types
  */
@@ -310,14 +303,6 @@ svcxdr_encode_wcc_data(struct svc_rqst *rqstp, struct xdr_stream *xdr,
  * XDR decode functions
  */
 
-bool
-nfs3svc_decode_fhandleargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd_fhandle *args = rqstp->rq_argp;
-
-	return svcxdr_decode_nfs_fh3(xdr, &args->fh);
-}
-
 bool
 nfs3svc_decode_readdirargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 {
@@ -611,48 +596,6 @@ int nfs3svc_encode_entryplus3(void *data, const char *name, int namlen,
 	return -EINVAL;
 }
 
-static bool
-svcxdr_encode_pathconf3resok(struct xdr_stream *xdr,
-			     const struct nfsd3_pathconfres *resp)
-{
-	__be32 *p;
-
-	p = xdr_reserve_space(xdr, XDR_UNIT * 6);
-	if (!p)
-		return false;
-	*p++ = cpu_to_be32(resp->p_link_max);
-	*p++ = cpu_to_be32(resp->p_name_max);
-	p = xdr_encode_bool(p, resp->p_no_trunc);
-	p = xdr_encode_bool(p, resp->p_chown_restricted);
-	p = xdr_encode_bool(p, resp->p_case_insensitive);
-	xdr_encode_bool(p, resp->p_case_preserving);
-
-	return true;
-}
-
-/* PATHCONF */
-bool
-nfs3svc_encode_pathconfres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd3_pathconfres *resp = rqstp->rq_resp;
-
-	if (!svcxdr_encode_nfsstat3(xdr, resp->status))
-		return false;
-	switch (resp->status) {
-	case nfs_ok:
-		if (!svcxdr_encode_post_op_attr(rqstp, xdr, &nfs3svc_null_fh))
-			return false;
-		if (!svcxdr_encode_pathconf3resok(xdr, resp))
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
 /* COMMIT */
 bool
 nfs3svc_encode_commitres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
diff --git a/fs/nfsd/xdr3.h b/fs/nfsd/xdr3.h
index 979b9ea5b86d..6428d9a190b0 100644
--- a/fs/nfsd/xdr3.h
+++ b/fs/nfsd/xdr3.h
@@ -99,15 +99,11 @@ struct nfsd3_fsinfores {
 static_assert(offsetof(struct nfsd3_fsinfores, xdrgen) == 0);
 
 struct nfsd3_pathconfres {
-	__be32			status;
-	__u32			p_link_max;
-	__u32			p_name_max;
-	__u32			p_no_trunc;
-	__u32			p_chown_restricted;
-	bool			p_case_insensitive;
-	bool			p_case_preserving;
+	struct PATHCONF3res	xdrgen;
 };
 
+static_assert(offsetof(struct nfsd3_pathconfres, xdrgen) == 0);
+
 struct nfsd3_commitres {
 	__be32			status;
 	struct svc_fh		fh;
@@ -123,14 +119,12 @@ struct nfsd3_getaclres {
 	struct kstat		stat;
 };
 
-bool nfs3svc_decode_fhandleargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_readdirargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_readdirplusargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_commitargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 
 bool nfs3svc_encode_accessres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_encode_readdirres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-bool nfs3svc_encode_pathconfres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_encode_commitres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 
 void nfs3svc_release_fhandle(struct svc_rqst *);
-- 
2.55.0


Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C6C815304DF
	for <linux-nfs@vger.kernel.org>; Wed, 23 Sep 2026 13:28:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790170116; cv=none; b=Y9g5MyQhlfx/TA9Z/CBCGY7Lo+Y+R7q1XyvcQtrOvjnWkOaXfDgP/WkY0fwZR/pqGWtEiztaURChpIiQCty6/BHzWIlJvZY/vDjjfagwLvApl4meODVrTBd/nMlXzVtqdys80qPx8VFSuXjN2I1IJUqS9a/l75tJPmK8EI7FaZk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790170116; c=relaxed/simple;
	bh=kklLZzxDAVlFFWcWkK/nidX0DJt0jbsBpq2jP4xRNOs=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=p1X9kQBUSUy99UUMrebAYx1m2LlvbFmUGmQ/ZaEf96wca8HzpGGv9wiU64WW+OsDYkvw916Tw86kkHMAarTU149ya/a8ZoiiRMiCkapA9Cx6MhpRtpcROtGJACd0VFnWRZxrKxG4aPXJjv+Zj8bJwvSp33f7jp6+zmeXbcftLTE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=hN9X7/Or; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="hN9X7/Or"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2D55E1F00893;
	Wed, 23 Sep 2026 13:28:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790170114;
	bh=H2LG7OvDqhu0YkT53d/9tBBRBKiHZvyIvAEyt4D1Vrg=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=hN9X7/OrY/UVRP+2CnSe7MDhRIJFTW7sigde97bBEwoFT5YQrmExX8cnmW1hVv8V6
	 /17e4sD5W4U3ITRellGHY+UF2MLmegVoK8IOZ/SLYJN4GstWtb6a9vOWwGUQnUjaeO
	 53tXcZuwK6yxS+nIWUrni297bDg0yZKuLbd8fliNnzo2sf7Kx7gipvwAHpKl8ZDrz2
	 plISqIfRsofPH+3TGfbO7/DzA3XGo54esqyY9pEFiWmjHUTaIgeH/TrJ/iADrZ/6ue
	 XpkpIom2z86RQXi8EaVGDzPLDGLC8psEeEufpxACVXqpza9k46pbcX0n5ZUWaAuqkC
	 466qM9ZlLwtXg==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 24/33] NFSD: Use xdrgen XDR functions for the NFSv3 FSINFO procedure
Date: Wed, 23 Sep 2026 09:28:02 -0400
Message-ID: <20260923132811.244160-25-cel@kernel.org>
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

Replace the NFSPROC3_FSINFO entry in the nfsd_procedures3 array with
an entry that dispatches the xdrgen-generated nfs_svc_decode_FSINFO3args
and nfs_svc_encode_FSINFO3res. A wrapper structure bridges the
generated xdrgen argument type and the legacy svc_fh representation the
NFSD VFS layer still uses.

The pc_argzero field is now set to zero for the NFSv3 FSINFO
procedure. The xdrgen decoders are trusted to initialize all arguments
in the argp->xdrgen field, making the early defensive memset
unnecessary. The remaining argp fields are cleared as needed.

nfsd3_proc_fsinfo() now sets the post-op attributes directly. This
makes it straightforward to confirm that the file handle is released
during every error flow.

nfs3svc_encode_fsinfores() no longer has any callers, so it is
removed, and with it the now-orphaned svcxdr_encode_fsinfo3resok()
encode helper and the nfs3svc_time_delta constant it referenced.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs3proc.c | 107 +++++++++++++++++++++++++++------------------
 fs/nfsd/nfs3xdr.c  |  55 -----------------------
 fs/nfsd/xdr3.h     |  14 ++----
 3 files changed, 67 insertions(+), 109 deletions(-)

diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index b9bcd05d4152..ea3baab1ed95 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -24,9 +24,6 @@
 
 #define NFSDDBG_FACILITY		NFSDDBG_PROC
 
-#define NFS3_FSF_DEFAULT		0x001b
-#define NFS3_FSF_BILLYBOY		0x0018
-
 /*
  * Wrapper structures combine xdrgen types with legacy structures.
  * The xdrgen field must be first so the structure can be cast
@@ -200,6 +197,13 @@ struct FSSTAT3args_wrapper {
 
 static_assert(offsetof(struct FSSTAT3args_wrapper, xdrgen) == 0);
 
+struct FSINFO3args_wrapper {
+	struct FSINFO3args	xdrgen;
+	struct svc_fh		fh;
+};
+
+static_assert(offsetof(struct FSINFO3args_wrapper, xdrgen) == 0);
+
 static int nfsd3_ftype3_to_mode(ftype3 ftype)
 {
 	switch (ftype) {
@@ -1610,47 +1614,63 @@ static __be32 nfsd3_proc_fsstat(struct svc_rqst *rqstp)
 	return rpc_success;
 }
 
-/*
- * Get file system info
+/**
+ * nfsd3_proc_fsinfo - FSINFO: Get static file system information
+ * @rqstp: RPC transaction context
+ *
+ * Return:
+ *   %rpc_success:		RPC executed successfully
+ *
+ * RPC synopsis:
+ *   FSINFO3res NFSPROC3_FSINFO(FSINFO3args) = 19;
  */
-static __be32
-nfsd3_proc_fsinfo(struct svc_rqst *rqstp)
+static __be32 nfsd3_proc_fsinfo(struct svc_rqst *rqstp)
 {
-	struct nfsd_fhandle *argp = rqstp->rq_argp;
+	struct FSINFO3args_wrapper *argp = rqstp->rq_argp;
 	struct nfsd3_fsinfores *resp = rqstp->rq_resp;
-	u32	max_blocksize = svc_max_payload(rqstp);
+	struct svc_fh *fhp = &argp->fh;
 
-	dprintk("nfsd: FSINFO(3)   %s\n",
-				SVCFH_fmt(&argp->fh));
+	nfsd3_fh3_to_svc_fh(fhp, &argp->xdrgen.fsroot);
 
-	resp->f_rtmax  = max_blocksize;
-	resp->f_rtpref = max_blocksize;
-	resp->f_rtmult = PAGE_SIZE;
-	resp->f_wtmax  = max_blocksize;
-	resp->f_wtpref = max_blocksize;
-	resp->f_wtmult = PAGE_SIZE;
-	resp->f_dtpref = max_blocksize;
-	resp->f_maxfilesize = ~(u32) 0;
-	resp->f_properties = NFS3_FSF_DEFAULT;
+	resp->xdrgen.status = fh_verify(rqstp, fhp, 0, NFSD_MAY_NOP |
+					NFSD_MAY_BYPASS_GSS_ON_ROOT);
 
-	resp->status = fh_verify(rqstp, &argp->fh, 0,
-				 NFSD_MAY_NOP | NFSD_MAY_BYPASS_GSS_ON_ROOT);
+	if (resp->xdrgen.status == nfs_ok) {
+		struct FSINFO3resok *resok = &resp->xdrgen.u.resok;
+		struct super_block *sb = fhp->fh_dentry->d_sb;
+		u32 max_blocksize = svc_max_payload(rqstp);
 
-	/* Check special features of the file system. May request
-	 * different read/write sizes for file systems known to have
-	 * problems with large blocks */
-	if (resp->status == nfs_ok) {
-		struct super_block *sb = argp->fh.fh_dentry->d_sb;
+		resok->obj_attributes.attributes_follow = false;
+		resok->rtmax = max_blocksize;
+		resok->rtpref = max_blocksize;
+		resok->rtmult = PAGE_SIZE;
+		resok->wtmax = max_blocksize;
+		resok->wtpref = max_blocksize;
+		resok->wtmult = PAGE_SIZE;
+		resok->dtpref = max_blocksize;
+		resok->maxfilesize = ~(u32)0;
+		/* NFSD is accurate to the nearest second. */
+		resok->time_delta.seconds = 1;
+		resok->time_delta.nseconds = 0;
+		resok->properties = FSF3_LINK | FSF3_SYMLINK |
+				    FSF3_HOMOGENEOUS | FSF3_CANSETTIME;
 
-		/* Note that we don't care for remote fs's here */
-		if (sb->s_magic == MSDOS_SUPER_MAGIC) {
-			resp->f_properties = NFS3_FSF_BILLYBOY;
-		}
-		resp->f_maxfilesize = sb->s_maxbytes;
+		/*
+		 * Check special features of the file system. May
+		 * request different read/write sizes for file systems
+		 * known to have problems with large blocks.
+		 */
+		if (sb->s_magic == MSDOS_SUPER_MAGIC)
+			resok->properties = FSF3_HOMOGENEOUS | FSF3_CANSETTIME;
+		resok->maxfilesize = sb->s_maxbytes;
+	} else {
+		struct FSINFO3resfail *resfail = &resp->xdrgen.u.resfail;
+
+		resp->xdrgen.status = nfsd3_map_status(resp->xdrgen.status);
+		resfail->obj_attributes.attributes_follow = false;
 	}
 
-	fh_put(&argp->fh);
-	resp->status = nfsd3_map_status(resp->status);
+	fh_put(fhp);
 	return rpc_success;
 }
 
@@ -1975,15 +1995,15 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 		.pc_name	= "FSSTAT",
 	},
 	[NFSPROC3_FSINFO] = {
-		.pc_func = nfsd3_proc_fsinfo,
-		.pc_decode = nfs3svc_decode_fhandleargs,
-		.pc_encode = nfs3svc_encode_fsinfores,
-		.pc_argsize = sizeof(struct nfsd3_fhandleargs),
-		.pc_argzero = sizeof(struct nfsd3_fhandleargs),
-		.pc_ressize = sizeof(struct nfsd3_fsinfores),
-		.pc_cachetype = RC_NOCACHE,
-		.pc_xdrressize = ST+pAT+12,
-		.pc_name = "FSINFO",
+		.pc_func	= nfsd3_proc_fsinfo,
+		.pc_decode	= nfs_svc_decode_FSINFO3args,
+		.pc_encode	= nfs_svc_encode_FSINFO3res,
+		.pc_argsize	= sizeof(struct FSINFO3args_wrapper),
+		.pc_argzero	= 0,
+		.pc_ressize	= sizeof(struct nfsd3_fsinfores),
+		.pc_cachetype	= RC_NOCACHE,
+		.pc_xdrressize	= NFS3_FSINFO3res_sz,
+		.pc_name	= "FSINFO",
 	},
 	[NFSPROC3_PATHCONF] = {
 		.pc_func = nfsd3_proc_pathconf,
@@ -2048,6 +2068,7 @@ union nfsd3_xdrstore {
 	struct nfsd3_readdirres		readdirres;
 	struct FSSTAT3args_wrapper	fsstatargs;
 	struct nfsd3_fsstatres		fsstatres;
+	struct FSINFO3args_wrapper	fsinfoargs;
 	struct nfsd3_fsinfores		fsinfores;
 	struct nfsd3_pathconfres	pathconfres;
 	struct nfsd3_commitres		commitres;
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index 0ca671bdd1c8..9e400a97e435 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -24,15 +24,6 @@ static const struct svc_fh nfs3svc_null_fh = {
 	.fh_no_wcc	= true,
 };
 
-/*
- * time_delta. {1, 0} means the server is accurate only
- * to the nearest second.
- */
-static const struct timespec64 nfs3svc_time_delta = {
-	.tv_sec		= 1,
-	.tv_nsec	= 0,
-};
-
 /*
  * Mapping of S_IF* types to NFS file types
  */
@@ -620,52 +611,6 @@ int nfs3svc_encode_entryplus3(void *data, const char *name, int namlen,
 	return -EINVAL;
 }
 
-static bool
-svcxdr_encode_fsinfo3resok(struct xdr_stream *xdr,
-			   const struct nfsd3_fsinfores *resp)
-{
-	__be32 *p;
-
-	p = xdr_reserve_space(xdr, XDR_UNIT * 12);
-	if (!p)
-		return false;
-	*p++ = cpu_to_be32(resp->f_rtmax);
-	*p++ = cpu_to_be32(resp->f_rtpref);
-	*p++ = cpu_to_be32(resp->f_rtmult);
-	*p++ = cpu_to_be32(resp->f_wtmax);
-	*p++ = cpu_to_be32(resp->f_wtpref);
-	*p++ = cpu_to_be32(resp->f_wtmult);
-	*p++ = cpu_to_be32(resp->f_dtpref);
-	p = xdr_encode_hyper(p, resp->f_maxfilesize);
-	p = encode_nfstime3(p, &nfs3svc_time_delta);
-	*p = cpu_to_be32(resp->f_properties);
-
-	return true;
-}
-
-/* FSINFO */
-bool
-nfs3svc_encode_fsinfores(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd3_fsinfores *resp = rqstp->rq_resp;
-
-	if (!svcxdr_encode_nfsstat3(xdr, resp->status))
-		return false;
-	switch (resp->status) {
-	case nfs_ok:
-		if (!svcxdr_encode_post_op_attr(rqstp, xdr, &nfs3svc_null_fh))
-			return false;
-		if (!svcxdr_encode_fsinfo3resok(xdr, resp))
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
 svcxdr_encode_pathconf3resok(struct xdr_stream *xdr,
 			     const struct nfsd3_pathconfres *resp)
diff --git a/fs/nfsd/xdr3.h b/fs/nfsd/xdr3.h
index 01c8539e67b8..7c39d7c35df0 100644
--- a/fs/nfsd/xdr3.h
+++ b/fs/nfsd/xdr3.h
@@ -100,18 +100,11 @@ struct nfsd3_fsstatres {
 static_assert(offsetof(struct nfsd3_fsstatres, xdrgen) == 0);
 
 struct nfsd3_fsinfores {
-	__be32			status;
-	__u32			f_rtmax;
-	__u32			f_rtpref;
-	__u32			f_rtmult;
-	__u32			f_wtmax;
-	__u32			f_wtpref;
-	__u32			f_wtmult;
-	__u32			f_dtpref;
-	__u64			f_maxfilesize;
-	__u32			f_properties;
+	struct FSINFO3res	xdrgen;
 };
 
+static_assert(offsetof(struct nfsd3_fsinfores, xdrgen) == 0);
+
 struct nfsd3_pathconfres {
 	__be32			status;
 	__u32			p_link_max;
@@ -144,7 +137,6 @@ bool nfs3svc_decode_commitargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 
 bool nfs3svc_encode_accessres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_encode_readdirres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-bool nfs3svc_encode_fsinfores(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_encode_pathconfres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_encode_commitres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 
-- 
2.55.0


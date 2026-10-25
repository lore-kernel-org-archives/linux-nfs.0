Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793050585;
	b=BSnz1LY6tcSST/yZC+a/K7hCw2MX5QDKDC+euH2sfaf6KdpauhfiCTWwGI3+2WVEk71b
	 4Gy5yS8QJ1fwJkWrTR3yqqFYbbY85suJgMbSQrSoC2whpJM3dXQL/4E/rI6fDsddbH4LA
	 NJUGA8D/NC5XGc8lBqcSuEj6v01OwREXVk21zZeaa3vYDPcM41GjGUbEq/ibGCoSm+WL6
	 4h9ZOsuUEI6urPUdAmHSIqENfAAbXBgFRtCEMdgEWOboOmyOlmbZtVp4HV3/yRnMAQfpR
	 l+7vXp+C2RG4auMZa1sbPKYgJXyKWvhz94d+AwMEh6OhFpMUFTwTh7nzjUuRC8NdfVA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793050585;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=dM+GZZzTe1vH3L1xKP/RN24IIIgF1Ea5tmWu50KC6Ps=;
	b=tCI74/o81YpIcDnuZ5IQRYO6IWl+oaVU1BFeDSCG5TFlkT3Ihko2NFzLogp+oQmO4zTf
	 L3zq/betdwBSjD9MFriqbruhrow+qcBDLZwXsna/LerhC8M+JRlsg6GUi+5P1+MU05u6d
	 YKopOi9RBxtL16bKBPl6A9dOJGMQZy2XABtTZsfKuH3yl2YgDdypo2l5cn4uTLv/kIAU6
	 +GQkWLX90DleoKNKQ5ph4Rl2FnkQvzLnr+Ul2tpFCLGkI6c6rnOfgtpT0/OuuHlGST56m
	 8YxEiGwJVrVRWkSFvbRYTOMRshfO/3VmWF2kwIRGEBnJdCpiQEB2Yq/dJSsGMC9xhyQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="RXbpvw/N";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8EAC2606A323
	for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2026 21:36:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=RXbpvw/N
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 72D4A1F031E0;
	Mon, 26 Oct 2026 21:36:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793050585;
	bh=dM+GZZzTe1vH3L1xKP/RN24IIIgF1Ea5tmWu50KC6Ps=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=RXbpvw/NTZG3MIgRwmxiJxavqiIc5i/vk7HWH/oRBEG5rET/+frSdQ0VyTJTPD+QX
	 PBpG+kYAIBvufSjiMtkzQtzAxJzRBtkyH5CdL36lGwTV4Ran+oHvDObpyRGpK7/dDr
	 Y1CX6cJhmnGRfvcPYFnVywOrBWfUp/IA4ZgPzD045Zo3aqyosM9NirGM9QT7Ab9iSv
	 d53yynM9B0XQkcde8YJc7tqQc99UVcbsFxMSqi7CEx4K5V8Q4SxJKhnyTrr8JarIen
	 zGzR0oELmo8lbytU7/BjNxPgRyym6GML5WoQhcHld1/6zXnRQJ6s3ZIuLFSfFDT72N
	 fEaUNl5oANM0w==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 08/13] NFSD: Use xdrgen XDR functions for the NFS-ACL v3 SETACL procedure
Date: Sun, 25 Oct 2026 11:16:17 -0400
Message-ID: <20261025151622.141025-9-cel@kernel.org>
X-Mailer: git-send-email 2.56.0
In-Reply-To: <20261025151622.141025-1-cel@kernel.org>
References: <20261025151622.141025-1-cel@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

SETACL3args decode and SETACL3res encode are the last hand-rolled
NFS_ACLv3 codecs. The previous patch already defined the secattr decode
hooks that the generated SETACL3args decoder drives, so the conversion
is now a matter of wiring the procedure to the generated entry points.

Convert SETACL to the generated codec. The decode hooks publish each
posix_acl into the argument wrapper as it is allocated; a zero-length
default list publishes a NULL posix_acl for ACL removal. When the
decoder has marked the argument ACL invalid (see the codec patch), the
procedure reports ACL3ERR_INVAL once the handle is verified and does
nothing else, so a stale handle or a refused export still takes
precedence over a bad ACL. A default ACL presented for an object that
is not a directory is reported as ACL3ERR_INVAL at the same point,
where set_posix_acl() would have reported EACCES;
draft-ietf-nfsv4-nfs-acl Section 3.4.4.2 lists that case among the
invalid ACLs. SETACL3args
therefore zeroes its whole argument wrapper through pc_argzero so both
ACL pointers and the "invalid" flag start clear and pc_release reaps a
partially decoded request with no leak and no double free.

Both arms of SETACL3res open with a post_op_attr, so the proc fills the
attributes for the reply whether or not the operation succeeded, as
the hand-rolled encoder did. A failed attribute fetch leaves the
post_op_attr absent; it does not turn a SETACL that has already been
applied into a failure. With SETACL generated, the hand-rolled setacl
codecs, the legacy argument and result structures, and the svcxdr
helper declarations they relied on are all removed.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs3acl.c | 174 ++++++++++++++++++++--------------------------
 1 file changed, 76 insertions(+), 98 deletions(-)

diff --git a/fs/nfsd/nfs3acl.c b/fs/nfsd/nfs3acl.c
index beb51b9dc2f1..19f5a6127673 100644
--- a/fs/nfsd/nfs3acl.c
+++ b/fs/nfsd/nfs3acl.c
@@ -52,10 +52,6 @@ struct GETACL3res_wrapper {
 
 static_assert(offsetof(struct GETACL3res_wrapper, xdrgen) == 0);
 
-/*
- * The ACLs are decoded by hand into the posix_acl fields below, so
- * the generated aclent arrays (xdrgen.acl) are left unused.
- */
 struct SETACL3args_wrapper {
 	struct SETACL3args	xdrgen;
 	struct svc_fh		fh;
@@ -72,6 +68,13 @@ struct SETACL3args_wrapper {
 
 static_assert(offsetof(struct SETACL3args_wrapper, xdrgen) == 0);
 
+struct SETACL3res_wrapper {
+	struct SETACL3res	xdrgen;
+	struct kstat		stat;
+};
+
+static_assert(offsetof(struct SETACL3res_wrapper, xdrgen) == 0);
+
 enum {
 	acl3_ok = __constant_cpu_to_be32(ACL3_OK),
 	acl3err_perm = __constant_cpu_to_be32(ACL3ERR_PERM),
@@ -131,26 +134,6 @@ static __be32 nfsd3_map_status(__be32 status)
 	return status;
 }
 
-/* Legacy structures for the hand-rolled SETACL codec. */
-struct nfsd3_setaclargs {
-	struct svc_fh		fh;
-	__u32			mask;
-	struct posix_acl	*acl_access;
-	struct posix_acl	*acl_default;
-};
-
-struct nfsd3_attrstat {
-	__be32			status;
-	struct svc_fh		fh;
-	struct kstat            stat;
-};
-
-/* Helper functions for NFSv3 ACL code */
-bool svcxdr_decode_nfs_fh3(struct xdr_stream *xdr, struct svc_fh *fhp);
-bool svcxdr_encode_nfsstat3(struct xdr_stream *xdr, __be32 status);
-bool svcxdr_encode_post_op_attr(struct svc_rqst *rqstp, struct xdr_stream *xdr,
-				const struct svc_fh *fhp);
-
 static bool
 nfs3acl_decode_fh(const struct nfs_fh3 *fh, struct svc_fh *fhp)
 {
@@ -344,90 +327,91 @@ static __be32 nfsd3_proc_getacl(struct svc_rqst *rqstp)
 	goto out;
 }
 
-/*
- * Set the Access and/or Default ACL of a file.
+/**
+ * nfsd3_proc_setacl - SETACL: Set the Access and/or Default ACL of a file
+ * @rqstp: RPC transaction context
+ *
+ * Return:
+ *   %rpc_success:		RPC executed successfully
+ *
+ * RPC synopsis:
+ *   SETACL3res ACLPROC3_SETACL(SETACL3args) = 2;
  */
 static __be32 nfsd3_proc_setacl(struct svc_rqst *rqstp)
 {
-	struct nfsd3_setaclargs *argp = rqstp->rq_argp;
-	struct nfsd3_attrstat *resp = rqstp->rq_resp;
+	struct SETACL3args_wrapper *argp = rqstp->rq_argp;
+	struct SETACL3res_wrapper *resp = rqstp->rq_resp;
+	struct svc_fh *fhp = &argp->fh;
 	struct inode *inode;
-	svc_fh *fh;
 	int error;
 
-	fh = fh_copy(&resp->fh, &argp->fh);
-	resp->status = fh_verify(rqstp, &resp->fh, 0, NFSD_MAY_SATTR);
-	if (resp->status != acl3_ok)
+	resp->xdrgen.u.resok.attr.attributes_follow = false;
+
+	if (!nfs3acl_decode_fh(&argp->xdrgen.fh, fhp)) {
+		resp->xdrgen.status = acl3err_badhandle;
+		return rpc_success;
+	}
+
+	resp->xdrgen.status = fh_verify(rqstp, fhp, 0, NFSD_MAY_SATTR);
+	if (resp->xdrgen.status != acl3_ok)
 		goto out;
+	inode = d_inode(fhp->fh_dentry);
 
-	inode = d_inode(fh->fh_dentry);
+	if (argp->invalid) {
+		resp->xdrgen.status = acl3err_inval;
+		goto out;
+	}
 
-	error = fh_want_write(fh);
+	/* The VFS reports a default ACL on a non-directory as EACCES. */
+	if (argp->acl_default && !S_ISDIR(inode->i_mode)) {
+		resp->xdrgen.status = acl3err_inval;
+		goto out;
+	}
+
+	error = fh_want_write(fhp);
 	if (error)
 		goto out_errno;
 
 	inode_lock(inode);
 
 	error = 0;
-	if (argp->mask & NA_ACL) {
-		error = set_posix_acl(&nop_mnt_idmap, fh->fh_dentry,
+	if (argp->xdrgen.acl.mask & NA_ACL) {
+		error = set_posix_acl(&nop_mnt_idmap, fhp->fh_dentry,
 				      ACL_TYPE_ACCESS, argp->acl_access);
 		if (error)
 			goto out_drop_lock;
 	}
-	if (argp->mask & NA_DFACL) {
-		error = set_posix_acl(&nop_mnt_idmap, fh->fh_dentry,
+	if (argp->xdrgen.acl.mask & NA_DFACL) {
+		error = set_posix_acl(&nop_mnt_idmap, fhp->fh_dentry,
 				      ACL_TYPE_DEFAULT, argp->acl_default);
+		if (error)
+			goto out_drop_lock;
 	}
 
+	inode_unlock(inode);
+
+	fh_drop_write(fhp);
+
+out:
+	/*
+	 * resok and resfail both open with a post_op_attr, so filling
+	 * the resok arm serves either status.
+	 */
+	if (!fhp->fh_no_wcc && fhp->fh_dentry &&
+	    fh_getattr(fhp, &resp->stat) == acl3_ok)
+		nfs3acl_encode_post_op_attr(rqstp, &resp->xdrgen.u.resok.attr,
+					    &resp->stat, fhp);
+	/* argp->acl_{access,default} are released in nfs3svc_release_setacl. */
+	fh_put(fhp);
+	resp->xdrgen.status = nfsd3_map_status(resp->xdrgen.status);
+	return rpc_success;
+
 out_drop_lock:
 	inode_unlock(inode);
-	fh_drop_write(fh);
+	fh_drop_write(fhp);
 out_errno:
-	resp->status = nfsd3_map_errno(error);
-out:
-	/* argp->acl_{access,default} are released in nfs3svc_release_setacl. */
-	resp->status = nfsd3_map_status(resp->status);
-	return rpc_success;
-}
-
-/*
- * XDR decode functions
- */
-
-static bool
-nfs3svc_decode_setaclargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd3_setaclargs *argp = rqstp->rq_argp;
-
-	if (!svcxdr_decode_nfs_fh3(xdr, &argp->fh))
-		return false;
-	if (xdr_stream_decode_u32(xdr, &argp->mask) < 0)
-		return false;
-	if (argp->mask & ~NFS_ACL_MASK)
-		return false;
-	if (!nfs_stream_decode_acl(xdr, NULL, (argp->mask & NA_ACL) ?
-				   &argp->acl_access : NULL))
-		return false;
-	if (!nfs_stream_decode_acl(xdr, NULL, (argp->mask & NA_DFACL) ?
-				   &argp->acl_default : NULL))
-		return false;
-
-	return true;
-}
-
-/*
- * XDR encode functions
- */
-
-/* SETACL */
-static bool
-nfs3svc_encode_setaclres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd3_attrstat *resp = rqstp->rq_resp;
-
-	return svcxdr_encode_nfsstat3(xdr, resp->status) &&
-		svcxdr_encode_post_op_attr(rqstp, xdr, &resp->fh);
+	resp->xdrgen.status = nfsd3_map_errno(error);
+	goto out;
 }
 
 /*
@@ -655,18 +639,12 @@ static void nfs3svc_release_getacl(struct svc_rqst *rqstp)
 
 static void nfs3svc_release_setacl(struct svc_rqst *rqstp)
 {
-	struct nfsd3_setaclargs *argp = rqstp->rq_argp;
-	struct nfsd3_attrstat *resp = rqstp->rq_resp;
+	struct SETACL3args_wrapper *argp = rqstp->rq_argp;
 
-	fh_put(&resp->fh);
 	posix_acl_release(argp->acl_access);
 	posix_acl_release(argp->acl_default);
 }
 
-#define ST 1		/* status*/
-#define AT 21		/* attributes */
-#define pAT (1+AT)	/* post attributes - conditional */
-
 static const struct svc_procedure nfsd_acl_procedures3[3] = {
 	[ACLPROC3_NULL] = {
 		.pc_func = nfsd3_proc_null,
@@ -693,14 +671,14 @@ static const struct svc_procedure nfsd_acl_procedures3[3] = {
 	},
 	[ACLPROC3_SETACL] = {
 		.pc_func = nfsd3_proc_setacl,
-		.pc_decode = nfs3svc_decode_setaclargs,
-		.pc_encode = nfs3svc_encode_setaclres,
+		.pc_decode = nfs_acl_svc_decode_SETACL3args,
+		.pc_encode = nfs_acl_svc_encode_SETACL3res,
 		.pc_release = nfs3svc_release_setacl,
-		.pc_argsize = sizeof(struct nfsd3_setaclargs),
-		.pc_argzero = sizeof(struct nfsd3_setaclargs),
-		.pc_ressize = sizeof(struct nfsd3_attrstat),
+		.pc_argsize = sizeof(struct SETACL3args_wrapper),
+		.pc_argzero = sizeof(struct SETACL3args_wrapper),
+		.pc_ressize = sizeof(struct SETACL3res_wrapper),
 		.pc_cachetype = RC_NOCACHE,
-		.pc_xdrressize = ST+pAT,
+		.pc_xdrressize = NFS_ACL3_SETACL3res_sz,
 		.pc_name = "SETACL",
 	},
 };
@@ -710,9 +688,9 @@ static const struct svc_procedure nfsd_acl_procedures3[3] = {
  */
 union nfsd_acl3_xdrstore {
 	struct GETACL3args_wrapper	getaclargs;
-	struct nfsd3_setaclargs		setaclargs;
+	struct SETACL3args_wrapper	setaclargs;
 	struct GETACL3res_wrapper	getaclres;
-	struct nfsd3_attrstat		attrstat;
+	struct SETACL3res_wrapper	setaclres;
 };
 
 const struct svc_version nfsd_acl_version3 = {
-- 
2.56.0


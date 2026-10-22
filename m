Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792677237;
	b=Z7ObIPktFbdYNaYlT/DnLq0P/PdLkQ0RPOjOUtouxfyw/BmePmzhbHMP4YgweQLmFmBr
	 fB4t/rE91nN4BUSMsKuUGXONZulwtpQ7O1/ttyjv2uOWy1GtvNMsVc8RpqAS2UsB5Tevs
	 0d5HdUX0xnkT3B4tJWm6pYcGhH/PFxdrATlc9FTHzMBkL2xN5Vca5UupGPvxH28C73T0x
	 THoT03S5q8DqlqfvIlm5nmShqv9Mn24NdaFib6UxRMB/E8re3ydvlSjZpeI/ajr0ZLOCY
	 BJb4z7TADmOxDjz0U0N+W7vF8HehzNP3OHWSqV1O3laj4A5P9q3YP6VKLXky47vHgMw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792677237;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=D2/nzzhZ3jaECcNwVXdt8XbNRjdRvJrnuZEuQiNkBTk=;
	b=Pd6vySo14t+cHOK7WKa27sKJWOd8GNU9JEGjFPtmz/St/PEZrP11a0tL7fFDcptQZ9ul
	 trb8JA8+zuye0lTm4+STsILHGwokHO/rBC0gfmqcAXHjoA46lPspNdtNvRGxYl5ft32rM
	 l3FaJZY9rGJgbnok4GwJ8Mx6eacnc7xwUrHCXychrN+ag5euZFAu/zIjcVHtvpEFgIyzH
	 t+1OYaMdWX90BCDEfumLuMDNOnk+FWN6cNtfEsTc8OlnAeM5EbZLhPPOs2YFJNDT40mpB
	 4vsE0t+/mNBkPfmhEKG/hY8FMfg4Ugf9gvh8ldhTKHOgpbk9y8tVl526hmcpEpBjHOA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=WQvOWo4J;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CA16A60A263F
	for <linux-nfs@vger.kernel.org>; Thu, 22 Oct 2026 13:53:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=WQvOWo4J
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1B4EB1F000D2;
	Thu, 22 Oct 2026 13:53:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792677236;
	bh=D2/nzzhZ3jaECcNwVXdt8XbNRjdRvJrnuZEuQiNkBTk=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=WQvOWo4Jsgl9HJm4VdVacSvkZ/C7scpJxOg3mWcGu+SUN/fvtzEUMu6kvXmRyW3vk
	 UrWuQx/KfaOT9glla7P1kLBWl/vvGn31h9ZVBdqEF6Q8Lm3vBp7B6+4N1MmwnKRT5R
	 yYrVPfVOgOD97LX4+kMKmFb2Oy5oCL3c46P/See8LKvAh3XhoaI2PWUlaDh9R1zGky
	 sA5//hrTRF/FaVqomyf9gOV2W5YBK2LWBqoA5rsVN8klWKIOCRGYJ36/q/omphBTwj
	 sB0I4My/R870xJFR514oud2Nd3DDCFPfm+NSyV0ggBPfs7b4Ed3haVZ3t2yGl5iDvg
	 o/YeX61I8u15g==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 14/17] NFSD: Use xdrgen XDR functions for the NFS-ACL v2 SETACL procedure
Date: Thu, 22 Oct 2026 09:53:38 -0400
Message-ID: <20261022135341.14265-15-cel@kernel.org>
X-Mailer: git-send-email 2.56.0
In-Reply-To: <20261022135341.14265-1-cel@kernel.org>
References: <20261022135341.14265-1-cel@kernel.org>
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

Convert the NFS-ACL version 2 SETACL procedure to xdrgen. Because
the reply carries only a status word and, on success, the file
attributes, it is emitted entirely by the generated
nfs_acl_svc_encode_SETACL2res(); unlike the GETACL conversion, no
hand-written reply tail is needed. A result wrapper bridges the
generated SETACL2res type and the scratch kstat that the NFSD VFS
layer fills.

The argument decoder is generated in full. SETACL2args carries a
secattr whose aclent arrays must become a struct posix_acl for the
VFS layer; the hook-driven aggregate codec added earlier performs
that per-entry transformation, so nfs_acl_svc_decode_SETACL2args()
owns the wire framing and drives the application hooks. An argument
wrapper pairs the generated SETACL2args with the decoded posix_acl
pointers and an "invalid" flag.

pc_argzero covers the whole argument wrapper, so the buffer is
zeroed before decode: the two posix_acl pointers start NULL, as the
unconditional release callback requires, and the "invalid" flag
starts clear.

The reply no longer carries a file handle, so the procedure
verifies the handle, sets the ACLs, captures the resulting
attributes, and releases the handle itself; the release callback
shrinks to the two posix_acl_release() calls for the decoded
argument ACLs. When the decoder has marked the argument ACL invalid
(see the codec patch), the procedure reports ACL2ERR_INVAL before
authorization and does nothing else. A default ACL presented for an
object that is not a directory is reported as ACL2ERR_INVAL once
the handle is verified, where set_posix_acl() would have reported
EACCES; draft-ietf-nfsv4-nfs-acl Section 3.4.4.2 lists that case
among the invalid ACLs. Filling the fattr reuses
nfsacld_stat_to_fattr() from the GETACL conversion, so the wire
result matches what the NFSv2 GETATTR encoder already produces.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs2acl.c | 120 +++++++++++++++++++++++-----------------------
 1 file changed, 60 insertions(+), 60 deletions(-)

diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
index 8f0be7208e89..24ec141796b4 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -80,13 +80,13 @@ struct SETACL2args_wrapper {
 
 static_assert(offsetof(struct SETACL2args_wrapper, xdrgen) == 0);
 
-struct nfsd3_setaclargs {
-	struct svc_fh		fh;
-	__u32			mask;
-	struct posix_acl	*acl_access;
-	struct posix_acl	*acl_default;
+struct SETACL2res_wrapper {
+	struct SETACL2res	xdrgen;
+	struct kstat		stat;
 };
 
+static_assert(offsetof(struct SETACL2res_wrapper, xdrgen) == 0);
+
 struct nfsd3_accessargs {
 	struct svc_fh		fh;
 	__u32			access;
@@ -397,41 +397,59 @@ static __be32 nfsacld_proc_getacl(struct svc_rqst *rqstp)
 	goto out;
 }
 
-/*
- * Set the Access and/or Default ACL of a file.
+/**
+ * nfsacld_proc_setacl - SETACL: Set the Access and/or Default ACL of a file
+ * @rqstp: RPC transaction context
+ *
+ * Return:
+ *   %rpc_success:		RPC executed successfully
+ *
+ * RPC synopsis:
+ *   SETACL2res ACLPROC2_SETACL(SETACL2args) = 2;
  */
 static __be32 nfsacld_proc_setacl(struct svc_rqst *rqstp)
 {
-	struct nfsd3_setaclargs *argp = rqstp->rq_argp;
-	struct nfsd_attrstat *resp = rqstp->rq_resp;
+	struct SETACL2args_wrapper *argp = rqstp->rq_argp;
+	struct SETACL2res_wrapper *resp = rqstp->rq_resp;
+	struct svc_fh *fhp = &argp->fh;
 	struct inode *inode;
-	svc_fh *fh;
 	int error;
 
-	dprintk("nfsd: SETACL(2acl)   %s\n", SVCFH_fmt(&argp->fh));
+	nfsacld_fhandle_to_svc_fh(fhp, &argp->xdrgen.fh);
+	dprintk("nfsd: SETACL(2acl)   %s\n", SVCFH_fmt(fhp));
 
-	fh = fh_copy(&resp->fh, &argp->fh);
-	resp->status = fh_verify(rqstp, &resp->fh, 0, NFSD_MAY_SATTR);
-	if (resp->status != acl2_ok)
+	/* A well-formed but invalid ACL is rejected before authorization. */
+	if (argp->invalid) {
+		resp->xdrgen.status = acl2err_inval;
 		goto out;
+	}
 
-	inode = d_inode(fh->fh_dentry);
+	resp->xdrgen.status = fh_verify(rqstp, fhp, 0, NFSD_MAY_SATTR);
+	if (resp->xdrgen.status != acl2_ok)
+		goto out;
+	inode = d_inode(fhp->fh_dentry);
 
-	error = fh_want_write(fh);
+	/* The VFS reports a default ACL on a non-directory as EACCES. */
+	if (argp->acl_default && !S_ISDIR(inode->i_mode)) {
+		resp->xdrgen.status = acl2err_inval;
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
 		if (error)
 			goto out_drop_lock;
@@ -439,20 +457,24 @@ static __be32 nfsacld_proc_setacl(struct svc_rqst *rqstp)
 
 	inode_unlock(inode);
 
-	fh_drop_write(fh);
+	fh_drop_write(fhp);
 
-	resp->status = fh_getattr(fh, &resp->stat);
+	resp->xdrgen.status = fh_getattr(fhp, &resp->stat);
 
 out:
+	if (resp->xdrgen.status == acl2_ok)
+		nfsacld_stat_to_fattr(rqstp, &resp->xdrgen.u.resok.attr,
+				      &resp->stat, fhp);
 	/* argp->acl_{access,default} are released in nfsaclsvc_release_setacl. */
-	resp->status = nfsacld_map_status(resp->status);
+	fh_put(fhp);
+	resp->xdrgen.status = nfsacld_map_status(resp->xdrgen.status);
 	return rpc_success;
 
 out_drop_lock:
 	inode_unlock(inode);
-	fh_drop_write(fh);
+	fh_drop_write(fhp);
 out_errno:
-	resp->status = nfsacld_map_errno(error);
+	resp->xdrgen.status = nfsacld_map_errno(error);
 	goto out;
 }
 
@@ -699,27 +721,6 @@ bool nfs_acl2_secattr_decode_end(struct xdrgen_aggregate_cursor *c, bool ok)
  * XDR decode functions
  */
 
-static bool
-nfsaclsvc_decode_setaclargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd3_setaclargs *argp = rqstp->rq_argp;
-
-	if (!svcxdr_decode_fhandle(xdr, &argp->fh))
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
 static bool
 nfsaclsvc_decode_accessargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 {
@@ -777,10 +778,8 @@ static void nfsaclsvc_release_access(struct svc_rqst *rqstp)
 
 static void nfsaclsvc_release_setacl(struct svc_rqst *rqstp)
 {
-	struct nfsd3_setaclargs *argp = rqstp->rq_argp;
-	struct nfsd_attrstat *resp = rqstp->rq_resp;
+	struct SETACL2args_wrapper *argp = rqstp->rq_argp;
 
-	fh_put(&resp->fh);
 	posix_acl_release(argp->acl_access);
 	posix_acl_release(argp->acl_default);
 }
@@ -813,16 +812,16 @@ static const struct svc_procedure nfsd_acl_procedures2[5] = {
 		.pc_name	= "GETACL",
 	},
 	[ACLPROC2_SETACL] = {
-		.pc_func = nfsacld_proc_setacl,
-		.pc_decode = nfsaclsvc_decode_setaclargs,
-		.pc_encode = nfssvc_encode_attrstatres,
-		.pc_release = nfsaclsvc_release_setacl,
-		.pc_argsize = sizeof(struct nfsd3_setaclargs),
-		.pc_argzero = sizeof(struct nfsd3_setaclargs),
-		.pc_ressize = sizeof(struct nfsd_attrstat),
-		.pc_cachetype = RC_NOCACHE,
-		.pc_xdrressize = ST+AT,
-		.pc_name = "SETACL",
+		.pc_func	= nfsacld_proc_setacl,
+		.pc_decode	= nfs_acl_svc_decode_SETACL2args,
+		.pc_encode	= nfs_acl_svc_encode_SETACL2res,
+		.pc_release	= nfsaclsvc_release_setacl,
+		.pc_argsize	= sizeof(struct SETACL2args_wrapper),
+		.pc_argzero	= sizeof(struct SETACL2args_wrapper),
+		.pc_ressize	= sizeof(struct SETACL2res_wrapper),
+		.pc_cachetype	= RC_NOCACHE,
+		.pc_xdrressize	= NFS_ACL2_SETACL2res_sz,
+		.pc_name	= "SETACL",
 	},
 	[ACLPROC2_GETATTR] = {
 		.pc_func = nfsacld_proc_getattr,
@@ -855,10 +854,11 @@ static const struct svc_procedure nfsd_acl_procedures2[5] = {
  */
 union nfsd_acl2_xdrstore {
 	struct GETACL2args_wrapper	getaclargs;
-	struct nfsd3_setaclargs		setaclargs;
+	struct SETACL2args_wrapper	setaclargs;
 	struct nfsd3_accessargs		accessargs;
 	struct nfsd_fhandle		fhandle;
 	struct GETACL2res_wrapper	getaclres;
+	struct SETACL2res_wrapper	setaclres;
 	struct nfsd_attrstat		attrstat;
 	struct nfsd3_accessres		accessres;
 };
-- 
2.56.0


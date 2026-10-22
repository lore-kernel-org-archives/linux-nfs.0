Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792677238;
	b=vwgO2923agv3BzALiZoOT2zkul6RCa9ZGsi81ciNuoHnaXjT3o4/udnsCtkLL5P5dCnm
	 +5BPtnFE5IyO/Vcg9/ZGy61G9YpGMJ69HOlkmL4Am9zsEIXjQBXMshapRinRwjwQjAekf
	 BcR9ri1n9t8eXaTfj4n9NjakaCBrsdcs8YT76AD5xN53gzLWHlbT1+0qwlvXVu5Hzc4DF
	 Rjj+ai0A3e5vO6GCXA6n6X/m3XbN8k8YIcbeEvuH1RqWbVouWe+UQUsFiu1yvvRA0ztjs
	 K9u7SiEGe/2/UvVUsbgxTdS6VTqop57r/y8vNhVuym2rNUN48sbN1f0COCmzIme10PQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792677238;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=KYrKCeGh8wjNaUIa5KBnc/r9+htegOGs4zi1rVPnML8=;
	b=C8UPizl/zUXt7pUL6qWMLeUICLWDNfXaVnGxpxtBoFGuRfkFaybjBrIm7eJM/ak/LNUe
	 pHLnyjb2SaY0Fp8BBesXpQkPANUiQt2o+6KhaIZ6GyrrgGWdtXYstwo5rIldAxmQwnBbQ
	 hX32DDUOvW/GmgC9A75Tu9VljfnWSuLll63WcLVYCke55usNKnyKrISF8IlIqEqTNpMB0
	 8K7d+wMyCGsfDXsdlNqY19seVx9aDfPIKRfIuWU1P0gT+qEe2vf82CXSf0KFfNaKkLOcc
	 TyuVClwjAgHCbQnquEheqHe5qw7unAMqmfhL/TEhlzlfn8oAD5frL76kGqA2vqivjbA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ZP+hscM3;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8A0F660A2629
	for <linux-nfs@vger.kernel.org>; Thu, 22 Oct 2026 13:53:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ZP+hscM3
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A4F991F000C8;
	Thu, 22 Oct 2026 13:53:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792677238;
	bh=KYrKCeGh8wjNaUIa5KBnc/r9+htegOGs4zi1rVPnML8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=ZP+hscM3Wwmk/OSh3BX7zxgCNjI355Ok1oXOuHDruy3ZsscIG+Q15kfJdonNTgXNH
	 qGUiqNonSkYXG8NUz2IEnyU/b043PK1F2QS2ei8FKZfZS5dkZ1ymdiiBxulEfOBwoM
	 x1V4ZEKoj7fOYR5w685l9y1hLbrOI160DloD0o875JbId9WCHd0Klr1I8oDOF8Uh9H
	 IsQDTGnoU3FJ4nCx23CMliYesnE/fkOMManb46AWDL8kP19WPtXqOqxFz1KsHCLCLy
	 hZwesZkBXGbS+1tNspgpXT8L7OXmNi+lDD6zb/qoPYChHrdG1n0N/kntnw+dKDh05W
	 RqtQD+KX9E3kg==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 16/17] NFSD: Use xdrgen XDR functions for the NFS-ACL v2 ACCESS procedure
Date: Thu, 22 Oct 2026 09:53:40 -0400
Message-ID: <20261022135341.14265-17-cel@kernel.org>
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

Convert the NFS-ACL version 2 ACCESS procedure to xdrgen. As with
the GETATTR conversion, neither direction needs a hand-written XDR
tail: ACCESS2args carries a file handle and an access bitmask, so
the generated nfs_acl_svc_decode_ACCESS2args decodes the argument
in full, and ACCESS2res carries a status word and, on success, the
file attributes and the granted access bits, so the generated
nfs_acl_svc_encode_ACCESS2res emits the entire reply. On an error
status the encoder emits only the status word, matching what the
hand-written encoder produced. Wrapper structures bridge the
generated ACCESS2args and ACCESS2res types and the legacy svc_fh
and scratch kstat that the NFSD VFS layer still uses.

The procedure's pc_argzero is zero because the generated decoder
writes the whole ACCESS2args, making the earlier defensive memset
of the argument buffer unnecessary.

Because nfsacld_proc_access() now fills in the reply attributes and
releases the file handle itself, the fh_getattr() call moves into
the proc function and the separate ->pc_release callback is dropped.
This makes it straightforward to confirm the handle is released on
every flow.

ACCESS was the only remaining user of the file-local struct
nfsd3_accessargs and struct nfsd3_accessres, so this removes those
definitions, the hand-written accessargs decoder and accessres
encoder, and the ST and AT size macros that only the ACCESS entry
still referenced. The svcxdr_decode_fhandle, svcxdr_encode_stat,
and svcxdr_encode_fattr declarations lose their last callers here
and are removed as well.

While rewriting the procedure entry, correct its pc_name from the
stale "SETATTR" to "ACCESS".

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs2acl.c | 132 ++++++++++++++++------------------------------
 1 file changed, 45 insertions(+), 87 deletions(-)

diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
index d4261ef076bd..a805d2ac76db 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -95,22 +95,19 @@ struct GETATTR2res_wrapper {
 
 static_assert(offsetof(struct GETATTR2res_wrapper, xdrgen) == 0);
 
-struct nfsd3_accessargs {
+struct ACCESS2args_wrapper {
+	struct ACCESS2args	xdrgen;
 	struct svc_fh		fh;
-	__u32			access;
 };
 
-struct nfsd3_accessres {
-	__be32			status;
-	struct svc_fh		fh;
-	__u32			access;
+static_assert(offsetof(struct ACCESS2args_wrapper, xdrgen) == 0);
+
+struct ACCESS2res_wrapper {
+	struct ACCESS2res	xdrgen;
 	struct kstat		stat;
 };
 
-bool svcxdr_decode_fhandle(struct xdr_stream *xdr, struct svc_fh *fhp);
-bool svcxdr_encode_stat(struct xdr_stream *xdr, __be32 status);
-bool svcxdr_encode_fattr(struct svc_rqst *rqstp, struct xdr_stream *xdr,
-			 const struct svc_fh *fhp, const struct kstat *stat);
+static_assert(offsetof(struct ACCESS2res_wrapper, xdrgen) == 0);
 
 /*
  * These maps are identical to the NFSv3 maps (nfs3proc.c). This enables
@@ -514,28 +511,41 @@ static __be32 nfsacld_proc_getattr(struct svc_rqst *rqstp)
 	return rpc_success;
 }
 
-/*
- * Check file access
+/**
+ * nfsacld_proc_access - ACCESS: Check access permission
+ * @rqstp: RPC transaction context
+ *
+ * Return:
+ *   %rpc_success:		RPC executed successfully
+ *
+ * RPC synopsis:
+ *   ACCESS2res ACLPROC2_ACCESS(ACCESS2args) = 4;
  */
 static __be32 nfsacld_proc_access(struct svc_rqst *rqstp)
 {
-	struct nfsd3_accessargs *argp = rqstp->rq_argp;
-	struct nfsd3_accessres *resp = rqstp->rq_resp;
+	struct ACCESS2args_wrapper *argp = rqstp->rq_argp;
+	struct ACCESS2res_wrapper *resp = rqstp->rq_resp;
+	struct svc_fh *fhp = &argp->fh;
 
+	nfsacld_fhandle_to_svc_fh(fhp, &argp->xdrgen.fh);
 	dprintk("nfsd: ACCESS(2acl)   %s 0x%x\n",
-			SVCFH_fmt(&argp->fh),
-			argp->access);
+			SVCFH_fmt(fhp), argp->xdrgen.access);
 
-	fh_copy(&resp->fh, &argp->fh);
-	resp->access = argp->access;
-
-	resp->status = nfsd_access(rqstp, &resp->fh, &nfsd2_access_maps,
-				   &resp->access, NULL);
-	if (resp->status != acl2_ok)
+	resp->xdrgen.status = nfsd_access(rqstp, fhp, &nfsd2_access_maps,
+					  &argp->xdrgen.access, NULL);
+	if (resp->xdrgen.status != acl2_ok)
 		goto out;
-	resp->status = fh_getattr(&resp->fh, &resp->stat);
+	resp->xdrgen.status = fh_getattr(fhp, &resp->stat);
+
 out:
-	resp->status = nfsacld_map_status(resp->status);
+	if (resp->xdrgen.status == acl2_ok) {
+		struct ACCESS2resok *resok = &resp->xdrgen.u.resok;
+
+		resok->access = argp->xdrgen.access;
+		nfsacld_stat_to_fattr(rqstp, &resok->attr, &resp->stat, fhp);
+	}
+	fh_put(fhp);
+	resp->xdrgen.status = nfsacld_map_status(resp->xdrgen.status);
 	return rpc_success;
 }
 
@@ -733,47 +743,6 @@ bool nfs_acl2_secattr_decode_end(struct xdrgen_aggregate_cursor *c, bool ok)
 	return posix_acl_from_nfsacl(acl) == 0;
 }
 
-/*
- * XDR decode functions
- */
-
-static bool
-nfsaclsvc_decode_accessargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd3_accessargs *args = rqstp->rq_argp;
-
-	if (!svcxdr_decode_fhandle(xdr, &args->fh))
-		return false;
-	if (xdr_stream_decode_u32(xdr, &args->access) < 0)
-		return false;
-
-	return true;
-}
-
-/*
- * XDR encode functions
- */
-
-/* ACCESS */
-static bool
-nfsaclsvc_encode_accessres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd3_accessres *resp = rqstp->rq_resp;
-
-	if (!svcxdr_encode_stat(xdr, resp->status))
-		return false;
-	switch (resp->status) {
-	case acl2_ok:
-		if (!svcxdr_encode_fattr(rqstp, xdr, &resp->fh, &resp->stat))
-			return false;
-		if (xdr_stream_encode_u32(xdr, resp->access) < 0)
-			return false;
-		break;
-	}
-
-	return true;
-}
-
 /*
  * XDR release functions
  */
@@ -785,13 +754,6 @@ static void nfsaclsvc_release_getacl(struct svc_rqst *rqstp)
 	posix_acl_release(resp->acl_default);
 }
 
-static void nfsaclsvc_release_access(struct svc_rqst *rqstp)
-{
-	struct nfsd3_accessres *resp = rqstp->rq_resp;
-
-	fh_put(&resp->fh);
-}
-
 static void nfsaclsvc_release_setacl(struct svc_rqst *rqstp)
 {
 	struct SETACL2args_wrapper *argp = rqstp->rq_argp;
@@ -800,9 +762,6 @@ static void nfsaclsvc_release_setacl(struct svc_rqst *rqstp)
 	posix_acl_release(argp->acl_default);
 }
 
-#define ST 1		/* status*/
-#define AT 21		/* attributes */
-
 static const struct svc_procedure nfsd_acl_procedures2[5] = {
 	[ACLPROC2_NULL] = {
 		.pc_func	= nfsacld_proc_null,
@@ -851,16 +810,15 @@ static const struct svc_procedure nfsd_acl_procedures2[5] = {
 		.pc_name	= "GETATTR",
 	},
 	[ACLPROC2_ACCESS] = {
-		.pc_func = nfsacld_proc_access,
-		.pc_decode = nfsaclsvc_decode_accessargs,
-		.pc_encode = nfsaclsvc_encode_accessres,
-		.pc_release = nfsaclsvc_release_access,
-		.pc_argsize = sizeof(struct nfsd3_accessargs),
-		.pc_argzero = sizeof(struct nfsd3_accessargs),
-		.pc_ressize = sizeof(struct nfsd3_accessres),
-		.pc_cachetype = RC_NOCACHE,
-		.pc_xdrressize = ST+AT+1,
-		.pc_name = "SETATTR",
+		.pc_func	= nfsacld_proc_access,
+		.pc_decode	= nfs_acl_svc_decode_ACCESS2args,
+		.pc_encode	= nfs_acl_svc_encode_ACCESS2res,
+		.pc_argsize	= sizeof(struct ACCESS2args_wrapper),
+		.pc_argzero	= 0,
+		.pc_ressize	= sizeof(struct ACCESS2res_wrapper),
+		.pc_cachetype	= RC_NOCACHE,
+		.pc_xdrressize	= NFS_ACL2_ACCESS2res_sz,
+		.pc_name	= "ACCESS",
 	},
 };
 
@@ -871,11 +829,11 @@ union nfsd_acl2_xdrstore {
 	struct GETACL2args_wrapper	getaclargs;
 	struct SETACL2args_wrapper	setaclargs;
 	struct GETATTR2args_wrapper	getattrargs;
-	struct nfsd3_accessargs		accessargs;
+	struct ACCESS2args_wrapper	accessargs;
 	struct GETACL2res_wrapper	getaclres;
 	struct SETACL2res_wrapper	setaclres;
 	struct GETATTR2res_wrapper	getattrres;
-	struct nfsd3_accessres		accessres;
+	struct ACCESS2res_wrapper	accessres;
 };
 
 const struct svc_version nfsd_acl_version2 = {
-- 
2.56.0


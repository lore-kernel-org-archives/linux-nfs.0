Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792677237;
	b=yzGdePdZpCV44UL9WpsLhlWXOnc4MExcuzb5CYzmBDkoDvB/U5dh5zQxXp04brLKOcSe
	 0tsjH/l47mT90VWlCzAQuBET5npDybx2tsmGZ1/EVIMdCx68Ay61GykIhkvYDkvVRY1av
	 +dy9bJr1LYm68bEE/4nJ6ZTwIpy2R4ktH+KpRZETUXs3dkkWHd9mkzGGr1w4vRTdGpFIb
	 JpH1RrwiYtCFlyOktv672HBo2lhRcx/ryerArxg4D6AnySeGxwplmHu0eP6sd/n8+zY7a
	 HqpLJ2xd1+yqPKFdCyTt9DTi2YcZA86hCxZca0kRk7G4zRToJSgLnf1hhs1Ff1v1jww==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792677237;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=FTpRphKJnDwD5KiZa8LGe4a7CTjxSjvsT9Vp9ByB3jg=;
	b=i11qbbsm215UkbTDTMKMRF9DwSUpoby+K58brfafjmE0GMLmkZRt9GDX2Sq74+REm9LY
	 Izyfnh8Ig0kSYsDBKFls9Qn32yh+BbzP/ff0mxNntaobfiHfrDe6poI//y+99UiNKC2yT
	 a+hrmXqC5o6uB1e7ZFzs0h+OiBS3FNb3odGfPTocRrmM6s8bBuaqSj+416f3mXiuTqQyS
	 R7xin6D/jD1SytYNbG+rPor7DEsIsjVa08bushilUd/8Xhg4v5dvenhHrnfCIzsPxTOKK
	 D0wdlIv3d36fqpSFJYhvD4UnGpJ3zCYrBhmCFULzo0bdGnmxU19GVDowc+RIfBTnwvA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=K108UT6e;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8D01360A2629
	for <linux-nfs@vger.kernel.org>; Thu, 22 Oct 2026 13:53:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=K108UT6e
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DB7081F000C2;
	Thu, 22 Oct 2026 13:53:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792677237;
	bh=FTpRphKJnDwD5KiZa8LGe4a7CTjxSjvsT9Vp9ByB3jg=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=K108UT6e8v/Vo3KNurks97tg0lExBmAjc2WGy9ZmV7aK6v+krbsjNc3AtJpqAYwg3
	 CytTgN5L8tRV3qjiAv9mU3TRvkNzV/MmYWhx3birlv7RJKuI28bq+ULf4qGdJVzwPf
	 y4QwTIIthCsLfk2CZEteo9IpB4B/EVSCJMCWMhwJWY/DH2pRKTXdQ8M2blDz/uMt+E
	 NTz/rCwfC4yF12qsE4+1nsn49xsY433FeiC5209HSD4NpYiE3SRv+iKM53De5ZVWGC
	 ow4p8cyQx2So4LToBOQQ1bp9ZeKAEs8FBGi457jML1ZvtPE71Cd+X/9sX367vFCQSZ
	 QAMMmHd5QyopA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 15/17] NFSD: Use xdrgen XDR functions for the NFS-ACL v2 GETATTR procedure
Date: Thu, 22 Oct 2026 09:53:39 -0400
Message-ID: <20261022135341.14265-16-cel@kernel.org>
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

Convert the NFS-ACL version 2 GETATTR procedure to xdrgen. Unlike
the GETACL and SETACL conversions, neither direction needs a
hand-written XDR tail: GETATTR2args carries only a file handle, so
the generated nfs_acl_svc_decode_GETATTR2args decodes the argument
in full, and GETATTR2res carries only a status word and, on
success, the file attributes, so the generated
nfs_acl_svc_encode_GETATTR2res emits the entire reply. Wrapper
structures bridge the generated GETATTR2args and GETATTR2res types
and the legacy svc_fh and scratch kstat that the NFSD VFS layer
still uses.

The procedure's pc_argzero is zero because the generated decoder
writes the whole GETATTR2args, making the earlier defensive memset
of the argument buffer unnecessary.

The reply no longer carries a file handle, so the procedure
verifies the handle, captures the resulting attributes, and
releases the handle itself. GETATTR has no ACLs to release, so its
release callback is dropped entirely. Filling the fattr reuses
nfsacld_stat_to_fattr() from the GETACL conversion, so the wire
result matches what the NFSv2 GETATTR encoder already produces.

GETATTR was the last NFS-ACL v2 procedure to use the file-local
struct nfsd_attrstat and the generic struct nfsd_fhandle, so this
removes that structure definition and the two now-unused members
of the XDR storage union.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs2acl.c | 81 ++++++++++++++++++++++++++++-------------------
 1 file changed, 48 insertions(+), 33 deletions(-)

diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
index 24ec141796b4..d4261ef076bd 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -35,12 +35,6 @@
 
 struct posix_acl;
 
-struct nfsd_attrstat {
-	__be32			status;
-	struct svc_fh		fh;
-	struct kstat		stat;
-};
-
 /*
  * Wrapper structures combine xdrgen types with legacy structures.
  * The xdrgen field must be first so the structure can be cast
@@ -87,6 +81,20 @@ struct SETACL2res_wrapper {
 
 static_assert(offsetof(struct SETACL2res_wrapper, xdrgen) == 0);
 
+struct GETATTR2args_wrapper {
+	struct GETATTR2args	xdrgen;
+	struct svc_fh		fh;
+};
+
+static_assert(offsetof(struct GETATTR2args_wrapper, xdrgen) == 0);
+
+struct GETATTR2res_wrapper {
+	struct GETATTR2res	xdrgen;
+	struct kstat		stat;
+};
+
+static_assert(offsetof(struct GETATTR2res_wrapper, xdrgen) == 0);
+
 struct nfsd3_accessargs {
 	struct svc_fh		fh;
 	__u32			access;
@@ -99,11 +107,6 @@ struct nfsd3_accessres {
 	struct kstat		stat;
 };
 
-bool nfssvc_decode_fhandleargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-bool nfssvc_encode_attrstatres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-
-void nfssvc_release_attrstat(struct svc_rqst *rqstp);
-
 bool svcxdr_decode_fhandle(struct xdr_stream *xdr, struct svc_fh *fhp);
 bool svcxdr_encode_stat(struct xdr_stream *xdr, __be32 status);
 bool svcxdr_encode_fattr(struct svc_rqst *rqstp, struct xdr_stream *xdr,
@@ -478,23 +481,36 @@ static __be32 nfsacld_proc_setacl(struct svc_rqst *rqstp)
 	goto out;
 }
 
-/*
- * Check file attributes
+/**
+ * nfsacld_proc_getattr - GETATTR: Get the attributes of a file
+ * @rqstp: RPC transaction context
+ *
+ * Return:
+ *   %rpc_success:		RPC executed successfully
+ *
+ * RPC synopsis:
+ *   GETATTR2res ACLPROC2_GETATTR(GETATTR2args) = 3;
  */
 static __be32 nfsacld_proc_getattr(struct svc_rqst *rqstp)
 {
-	struct nfsd_fhandle *argp = rqstp->rq_argp;
-	struct nfsd_attrstat *resp = rqstp->rq_resp;
+	struct GETATTR2args_wrapper *argp = rqstp->rq_argp;
+	struct GETATTR2res_wrapper *resp = rqstp->rq_resp;
+	struct svc_fh *fhp = &argp->fh;
 
-	dprintk("nfsd: GETATTR  %s\n", SVCFH_fmt(&argp->fh));
+	nfsacld_fhandle_to_svc_fh(fhp, &argp->xdrgen.fh);
+	dprintk("nfsd: GETATTR  %s\n", SVCFH_fmt(fhp));
 
-	fh_copy(&resp->fh, &argp->fh);
-	resp->status = fh_verify(rqstp, &resp->fh, 0, NFSD_MAY_NOP);
-	if (resp->status != acl2_ok)
+	resp->xdrgen.status = fh_verify(rqstp, fhp, 0, NFSD_MAY_NOP);
+	if (resp->xdrgen.status != acl2_ok)
 		goto out;
-	resp->status = fh_getattr(&resp->fh, &resp->stat);
+	resp->xdrgen.status = fh_getattr(fhp, &resp->stat);
+
 out:
-	resp->status = nfsacld_map_status(resp->status);
+	if (resp->xdrgen.status == acl2_ok)
+		nfsacld_stat_to_fattr(rqstp, &resp->xdrgen.u.resok.attr,
+				      &resp->stat, fhp);
+	fh_put(fhp);
+	resp->xdrgen.status = nfsacld_map_status(resp->xdrgen.status);
 	return rpc_success;
 }
 
@@ -824,16 +840,15 @@ static const struct svc_procedure nfsd_acl_procedures2[5] = {
 		.pc_name	= "SETACL",
 	},
 	[ACLPROC2_GETATTR] = {
-		.pc_func = nfsacld_proc_getattr,
-		.pc_decode = nfssvc_decode_fhandleargs,
-		.pc_encode = nfssvc_encode_attrstatres,
-		.pc_release = nfssvc_release_attrstat,
-		.pc_argsize = sizeof(struct nfsd_fhandle),
-		.pc_argzero = sizeof(struct nfsd_fhandle),
-		.pc_ressize = sizeof(struct nfsd_attrstat),
-		.pc_cachetype = RC_NOCACHE,
-		.pc_xdrressize = ST+AT,
-		.pc_name = "GETATTR",
+		.pc_func	= nfsacld_proc_getattr,
+		.pc_decode	= nfs_acl_svc_decode_GETATTR2args,
+		.pc_encode	= nfs_acl_svc_encode_GETATTR2res,
+		.pc_argsize	= sizeof(struct GETATTR2args_wrapper),
+		.pc_argzero	= 0,
+		.pc_ressize	= sizeof(struct GETATTR2res_wrapper),
+		.pc_cachetype	= RC_NOCACHE,
+		.pc_xdrressize	= NFS_ACL2_GETATTR2res_sz,
+		.pc_name	= "GETATTR",
 	},
 	[ACLPROC2_ACCESS] = {
 		.pc_func = nfsacld_proc_access,
@@ -855,11 +870,11 @@ static const struct svc_procedure nfsd_acl_procedures2[5] = {
 union nfsd_acl2_xdrstore {
 	struct GETACL2args_wrapper	getaclargs;
 	struct SETACL2args_wrapper	setaclargs;
+	struct GETATTR2args_wrapper	getattrargs;
 	struct nfsd3_accessargs		accessargs;
-	struct nfsd_fhandle		fhandle;
 	struct GETACL2res_wrapper	getaclres;
 	struct SETACL2res_wrapper	setaclres;
-	struct nfsd_attrstat		attrstat;
+	struct GETATTR2res_wrapper	getattrres;
 	struct nfsd3_accessres		accessres;
 };
 
-- 
2.56.0


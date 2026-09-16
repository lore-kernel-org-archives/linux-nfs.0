Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C497352121B
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 16:29:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789576164; cv=none; b=Khs8LZFbX59hPhuEKpRIaK84X87wDtBvaFrnIEzIr9SReoRMSksaNhVWJZQ0VLwlsSzgI+5EqZQmv5zadxrPIAwRwezH3hudUhdezBJlPGvPJmYu0/Z32pgiII+UATKp/aIqopQEU0MTSZ8Ybzr1eZCfl7BxEfESO+mgTlUVWSI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789576164; c=relaxed/simple;
	bh=2AVTui0PF5UXVK8mJr6ziEHTmmR/W40BHGdHaa2LHEI=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=MoSnDm+/POLEPqteErDzWDYHbBJZLPUZbetWeGhX8X63XkC+YkW+PjBBUHG9GesaMqdanPGyQV/DXPTmYxzMAkFdSYXmIq6NxNkmftOj8OlyDtyU5n2EX65W6eqbpnY4vLditweuN+ZpJf7RUZzpxTpvXhZJiBo3N0yZKp57q9s=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=mRHv1wGL; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="mRHv1wGL"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A35241F00893;
	Wed, 16 Sep 2026 16:29:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789576162;
	bh=tSLZei0ES0mQSHcWtf1/lEAzsa9r2qi5A7XdTnwiKY0=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=mRHv1wGLSx5CXpdKEIAIA6M0N4FzQRv4d07N98DKNxZ/qgITy3gHS+eheiphpScyV
	 KFQmwIhYhY15hJ5Kop36r21pwadEwYoTnj5ju20puaXPa6y9wo0zJJfSv+/sSd+dtI
	 xL2HRc9C0mcB/iR5gnFpgPJ0iAm2r/6e9uunPPJWL50tTGgClRS7fzW60BylM8sdXj
	 5nC0wp2tUk5cMqOXKxEwE0AUNfZVVc/97Q19OTlgcS/I+q0UnBb20exHeU0Yz/xYGS
	 KJJoxIwmT4u4P6UUyW6iZ060BCKAjLsZWHSXpgXuYQg/GUNPQ/kXxlN0Enf3QtLY7o
	 EsbmyIOcj9Z7A==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 17/27] NFSD: Use xdrgen XDR functions for the NFSv2 REMOVE procedure
Date: Wed, 16 Sep 2026 12:28:48 -0400
Message-ID: <20260916162859.2051-20-cel@kernel.org>
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

Replace the NFSPROC_REMOVE entry in the nfsd_procedures2 array
with an entry that dispatches the xdrgen-generated
nfs_svc_decode_diropargs and nfs_svc_encode_nfsstat. A wrapper
structure bridges the generated xdrgen diropargs type and the
legacy svc_fh representation the NFSD VFS layer still uses.

The pc_argzero field is now set to zero for the NFSv2 REMOVE
procedure. The xdrgen decoders are trusted to initialize all
arguments in the argp->xdrgen field, making the early defensive
memset unnecessary. The remaining argp fields are cleared as
needed.

The hand-coded nfssvc_decode_diropargs and nfssvc_encode_statres
remain for the procedures that still use them.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfsproc.c | 50 ++++++++++++++++++++++++++++++-----------------
 1 file changed, 32 insertions(+), 18 deletions(-)

diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 69dcd482b77f..ae74247a892f 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -847,17 +847,31 @@ static __be32 nfsd_proc_create(struct svc_rqst *rqstp)
 	return rpc_success;
 }
 
-static __be32
-nfsd_proc_remove(struct svc_rqst *rqstp)
+/**
+ * nfsd_proc_remove - REMOVE: Remove a file
+ * @rqstp: RPC transaction context
+ *
+ * Return:
+ *   %rpc_success:		RPC executed successfully
+ *
+ * RPC synopsis:
+ *   nfsstat NFSPROC_REMOVE(diropargs) = 10;
+ */
+static __be32 nfsd_proc_remove(struct svc_rqst *rqstp)
 {
-	struct nfsd_diropargs *argp = rqstp->rq_argp;
-	struct nfsd_stat *resp = rqstp->rq_resp;
+	struct diropargs_wrapper *argp = rqstp->rq_argp;
+	struct diropargs *object = &argp->xdrgen;
+	nfsstat *resp = rqstp->rq_resp;
+	struct svc_fh *fhp = &argp->fh;
 
-	/* Unlink. -SIFDIR means file must not be a directory */
-	resp->status = nfsd_unlink(rqstp, &argp->fh, -S_IFDIR,
-				   argp->name, argp->len);
-	fh_put(&argp->fh);
-	resp->status = nfsd_map_status(resp->status);
+	nfsd_fhandle_to_svc_fh(fhp, &object->dir);
+
+	/* Unlink. -S_IFDIR means file must not be a directory */
+	*resp = nfsd_unlink(rqstp, fhp, -S_IFDIR,
+			    (char *)object->name.data, object->name.len);
+	*resp = nfsd_map_status(*resp);
+
+	fh_put(fhp);
 	return rpc_success;
 }
 
@@ -1153,15 +1167,15 @@ static const struct svc_procedure nfsd_procedures2[18] = {
 		.pc_name	= "CREATE",
 	},
 	[NFSPROC_REMOVE] = {
-		.pc_func = nfsd_proc_remove,
-		.pc_decode = nfssvc_decode_diropargs,
-		.pc_encode = nfssvc_encode_statres,
-		.pc_argsize = sizeof(struct nfsd_diropargs),
-		.pc_argzero = sizeof(struct nfsd_diropargs),
-		.pc_ressize = sizeof(struct nfsd_stat),
-		.pc_cachetype = RC_REPLSTAT,
-		.pc_xdrressize = ST,
-		.pc_name = "REMOVE",
+		.pc_func	= nfsd_proc_remove,
+		.pc_decode	= nfs_svc_decode_diropargs,
+		.pc_encode	= nfs_svc_encode_nfsstat,
+		.pc_argsize	= sizeof(struct diropargs_wrapper),
+		.pc_argzero	= 0,
+		.pc_ressize	= sizeof(nfsstat),
+		.pc_cachetype	= RC_REPLSTAT,
+		.pc_xdrressize	= NFS2_nfsstat_sz,
+		.pc_name	= "REMOVE",
 	},
 	[NFSPROC_RENAME] = {
 		.pc_func = nfsd_proc_rename,
-- 
2.55.0


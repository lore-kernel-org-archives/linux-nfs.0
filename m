Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CFE395304A1
	for <linux-nfs@vger.kernel.org>; Wed, 23 Sep 2026 13:28:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790170102; cv=none; b=BW4T0ZzMWsSxvZs5o1GL2+ZJjnarGOJ3s3uPvO5wh7nvyiZbIK4zX4n+DH098fL9xgDsjw5rU5BxR0N2/osbMT+qfX0naW6G6OeG9CaFrqU9Dm0XUdmpz7Ia09jbE6M4jEvGdI1v9nul7GtjOIswABCbwrX8qX9+weoIEu9jDmE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790170102; c=relaxed/simple;
	bh=lBhmSFm/3dspQhzsrJ+Wds7SBB3/CxzUgLQBOV1HCBM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=jIEbQbWHvYkevabuc5ldJvgVQmAhhQ+j1nOBBFXnquAlFSIn+frclQDFYe+r+t4Otu/KLTFPVQ1Zn1zynw53HSqfCRD0mY1/xOnxXA7TUN41bwcCULy7h+Ob3zfpqZZlgQkXIcexnF9lhiTFmS3+nBelhBWWx20k2G8Ci7B5b8E=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=oqonURao; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="oqonURao"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 34E3F1F0089A;
	Wed, 23 Sep 2026 13:28:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790170100;
	bh=CuYHJlGl/2K/Jm6NMbYMAxp++nnQDwxU3g62zirPWK8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=oqonURaoEJ7L9A41b8WU5W/t+pNk72jpJgVqjXEzgWRfTJtrA4XN5lOHlWx6iRSmS
	 0S3vyyZmDrV/EqrfgPnim2jRp7CrBs7jNZovhhZ6wTRYIYUfmE2xGYYAPhwwHfbKz2
	 atUhuSSnvfrMGDqV6r8n9Q9mHLp2hRO2hsnLE46vCtCy1768Jkk4EDlzTCSzb0pJRf
	 AQA0uREdKiuRi1rT2eCiQ4RUQyMCHBRkNncu0s8FdtwK184Gj7q/fQMDkMBx1qn2Ed
	 FvTeEsH1gZ8I6m2ZGTnLxvVXu1ofw/RyN/9n/6zs7lGSTxhB5ZyV9ogxhBfMyrZ81J
	 WLXsCYtAJ471A==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 06/33] NFSD: Relocate the NFSv3 XDR storage union into nfs3proc.c
Date: Wed, 23 Sep 2026 09:27:44 -0400
Message-ID: <20260923132811.244160-7-cel@kernel.org>
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

union nfsd3_xdrstore and the NFS3_SVC_XDRSIZE macro it feeds exist
only to size service result buffers, yet xdr3.h exposes them to
every file that includes the header. This couples the NFSv3 XDR type
layout to translation units that have no stake in a service's buffer
size.

Three svc_version structures drew their vs_xdrsize from the shared
union: nfsd_version3 in nfs3proc.c and the two NFSACL programs,
nfsd_acl_version2 and nfsd_acl_version3. Give each its own storage
union next to the version structure it sizes, listing only that
program's own argument and result types, and compute vs_xdrsize from
sizeof of the local union. NFS3_SVC_XDRSIZE then has no users left
and is removed from xdr3.h.

The svc layer allocates rqstp->rq_resp at sv_xdrsize -- the largest
vs_xdrsize among a program's versions -- and clears it to the
dispatched procedure's pc_ressize, so each union must bound the
largest result its version encodes. The NFSACL programs previously
borrowed the full NFSv3 union; sizing them from their own result
types is both tighter and self-contained. This mirrors the recent
lockd conversion, which confined each NLM version's storage union to
the file that defines the version structure.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs2acl.c  | 15 ++++++++++++++-
 fs/nfsd/nfs3acl.c  | 12 +++++++++++-
 fs/nfsd/nfs3proc.c | 30 +++++++++++++++++++++++++++++-
 fs/nfsd/xdr3.h     | 30 ------------------------------
 4 files changed, 54 insertions(+), 33 deletions(-)

diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
index 13904e2740bf..db0e260f447d 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -452,10 +452,23 @@ static const struct svc_procedure nfsd_acl_procedures2[5] = {
 	},
 };
 
+/*
+ * Storage requirements for XDR arguments and results.
+ */
+union nfsd_acl2_xdrstore {
+	struct nfsd3_getaclargs		getaclargs;
+	struct nfsd3_setaclargs		setaclargs;
+	struct nfsd3_accessargs		accessargs;
+	struct nfsd_fhandle		fhandle;
+	struct nfsd3_getaclres		getaclres;
+	struct nfsd_attrstat		attrstat;
+	struct nfsd3_accessres		accessres;
+};
+
 const struct svc_version nfsd_acl_version2 = {
 	.vs_vers	= 2,
 	.vs_nproc	= ARRAY_SIZE(nfsd_acl_procedures2),
 	.vs_proc	= nfsd_acl_procedures2,
 	.vs_dispatch	= nfsd_dispatch,
-	.vs_xdrsize	= NFS3_SVC_XDRSIZE,
+	.vs_xdrsize	= sizeof(union nfsd_acl2_xdrstore),
 };
diff --git a/fs/nfsd/nfs3acl.c b/fs/nfsd/nfs3acl.c
index 5219ec634587..324cfdd7b262 100644
--- a/fs/nfsd/nfs3acl.c
+++ b/fs/nfsd/nfs3acl.c
@@ -294,11 +294,21 @@ static const struct svc_procedure nfsd_acl_procedures3[3] = {
 	},
 };
 
+/*
+ * Storage requirements for XDR arguments and results.
+ */
+union nfsd_acl3_xdrstore {
+	struct nfsd3_getaclargs		getaclargs;
+	struct nfsd3_setaclargs		setaclargs;
+	struct nfsd3_getaclres		getaclres;
+	struct nfsd3_attrstat		attrstat;
+};
+
 const struct svc_version nfsd_acl_version3 = {
 	.vs_vers	= 3,
 	.vs_nproc	= ARRAY_SIZE(nfsd_acl_procedures3),
 	.vs_proc	= nfsd_acl_procedures3,
 	.vs_dispatch	= nfsd_dispatch,
-	.vs_xdrsize	= NFS3_SVC_XDRSIZE,
+	.vs_xdrsize	= sizeof(union nfsd_acl3_xdrstore),
 };
 
diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 200e084d749b..180601d2d139 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -1184,10 +1184,38 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 	},
 };
 
+/*
+ * Storage requirements for XDR arguments and results.
+ */
+union nfsd3_xdrstore {
+	struct nfsd3_sattrargs		sattrargs;
+	struct nfsd3_diropargs		diropargs;
+	struct nfsd3_readargs		readargs;
+	struct nfsd3_writeargs		writeargs;
+	struct nfsd3_createargs		createargs;
+	struct nfsd3_renameargs		renameargs;
+	struct nfsd3_linkargs		linkargs;
+	struct nfsd3_symlinkargs	symlinkargs;
+	struct nfsd3_readdirargs	readdirargs;
+	struct nfsd3_diropres 		diropres;
+	struct nfsd3_accessres		accessres;
+	struct nfsd3_readlinkres	readlinkres;
+	struct nfsd3_readres		readres;
+	struct nfsd3_writeres		writeres;
+	struct nfsd3_renameres		renameres;
+	struct nfsd3_linkres		linkres;
+	struct nfsd3_readdirres		readdirres;
+	struct nfsd3_fsstatres		fsstatres;
+	struct nfsd3_fsinfores		fsinfores;
+	struct nfsd3_pathconfres	pathconfres;
+	struct nfsd3_commitres		commitres;
+	struct nfsd3_getaclres		getaclres;
+};
+
 const struct svc_version nfsd_version3 = {
 	.vs_vers	= 3,
 	.vs_nproc	= ARRAY_SIZE(nfsd_procedures3),
 	.vs_proc	= nfsd_procedures3,
 	.vs_dispatch	= nfsd_dispatch,
-	.vs_xdrsize	= NFS3_SVC_XDRSIZE,
+	.vs_xdrsize	= sizeof(union nfsd3_xdrstore),
 };
diff --git a/fs/nfsd/xdr3.h b/fs/nfsd/xdr3.h
index 60c7fe131e2e..35fb715e7c3f 100644
--- a/fs/nfsd/xdr3.h
+++ b/fs/nfsd/xdr3.h
@@ -243,36 +243,6 @@ struct nfsd3_fhandle_pair {
 	struct svc_fh		fh2;
 };
 
-/*
- * Storage requirements for XDR arguments and results.
- */
-union nfsd3_xdrstore {
-	struct nfsd3_sattrargs		sattrargs;
-	struct nfsd3_diropargs		diropargs;
-	struct nfsd3_readargs		readargs;
-	struct nfsd3_writeargs		writeargs;
-	struct nfsd3_createargs		createargs;
-	struct nfsd3_renameargs		renameargs;
-	struct nfsd3_linkargs		linkargs;
-	struct nfsd3_symlinkargs	symlinkargs;
-	struct nfsd3_readdirargs	readdirargs;
-	struct nfsd3_diropres 		diropres;
-	struct nfsd3_accessres		accessres;
-	struct nfsd3_readlinkres	readlinkres;
-	struct nfsd3_readres		readres;
-	struct nfsd3_writeres		writeres;
-	struct nfsd3_renameres		renameres;
-	struct nfsd3_linkres		linkres;
-	struct nfsd3_readdirres		readdirres;
-	struct nfsd3_fsstatres		fsstatres;
-	struct nfsd3_fsinfores		fsinfores;
-	struct nfsd3_pathconfres	pathconfres;
-	struct nfsd3_commitres		commitres;
-	struct nfsd3_getaclres		getaclres;
-};
-
-#define NFS3_SVC_XDRSIZE		sizeof(union nfsd3_xdrstore)
-
 bool nfs3svc_decode_fhandleargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_sattrargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_diropargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-- 
2.55.0


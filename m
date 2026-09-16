Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 47C3A556B88
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 16:29:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789576148; cv=none; b=g2jveshMURDDUvSFK6rrcnp1oYc93P7LXTsAdL4UpnbJqnVkXZoIwSFd49YyOtdurrGFrK2UM4MO7expiwUgs5wzms2pJ3xulZIfsFcdG8zxUGmY4nMNoBJ7OuHaZu+olTGlXAm61YlkjoJf3SZ6gEXaVkVkuRel3MqhXDOAfFo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789576148; c=relaxed/simple;
	bh=eMSGqCatby48TX1b0aKIKUF/e+kd3LiDZUXJPRJ7vpQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=J4Kl9r9wZNPGym71+IdEFO/79QNssOn9fHziMLfzxs7Eo0C8p7UJSNxu0JZfQ0r/pn9JHYH+rB1JxFiNtptlf/SD7Q64yexnFFFczi7X5x7Ue9jvh8G79lgFlOjxIYt0fihGkgDMjvdDpPL3QEgC++uIM+K+YUHuxzd/lUo061k=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=R5ydUhim; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="R5ydUhim"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 748491F00898;
	Wed, 16 Sep 2026 16:29:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789576146;
	bh=EhruQ6UCQFcuZehiI5MmEjHNBgbcYPmXPtpPbdvQmow=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=R5ydUhimMtjsCA6w4yCl2dGx6LdRyGutfURzWP6HP8QamL3gAqR8OhFndxz3Lcqhl
	 Z8fEes7tAHjjtDC1np37aM5GYxk9v0XrDkBtxBsZrSM9E8wPBiQSDEGrynHtUwqn8J
	 xLfQVdz33dV5WwZLcUfYBJO3LmDMFCtnilPfK2CapMuWOY3F8ygvrwYMG8VeKfvksl
	 Nc7LHq3R6xU+DFaiWO2v6ZRICXmiib5BJJbodRHslHSAV+LYtWAY+xYZip+Up+G7tf
	 k4uAaFVn+kmcIApBAjAB1fC08Sb49sujwkBNVndlWebuG21JNTuusj1BF8V8qSnXWT
	 WLQX4Abk5AmKA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 05/27] NFSD: Relocate the NFSv2 XDR storage union into nfsproc.c
Date: Wed, 16 Sep 2026 12:28:36 -0400
Message-ID: <20260916162859.2051-8-cel@kernel.org>
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

union nfsd_xdrstore and the NFS2_SVC_XDRSIZE macro it feeds exist
only to compute nfsd_version2.vs_xdrsize, yet xdr.h exposes them to
every file that includes the header. This couples the NFSv2 XDR
type layout to translation units that have no stake in the
service's buffer size.

Move the union next to nfsd_version2 in nfsproc.c, its sole
consumer, and compute vs_xdrsize directly from sizeof(union
nfsd_xdrstore). NFS2_SVC_XDRSIZE then has no users left and is
removed from xdr.h. This mirrors the recent lockd conversion, which
confined each NLM version's storage union to the file that defines
the version structure.

The union also gains the NFSv2 result structures. The svc layer
allocates rqstp->rq_resp at sv_xdrsize -- the largest vs_xdrsize
among a program's versions -- and clears it to the dispatched
procedure's pc_ressize, so vs_xdrsize must bound the largest result
the version encodes, not only its largest argument. The NFSv3
storage union already lists both.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfsproc.c | 23 ++++++++++++++++++++++-
 fs/nfsd/xdr.h     | 18 ------------------
 2 files changed, 22 insertions(+), 19 deletions(-)

diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 1ce75779312b..fd303d7dbad3 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -878,10 +878,31 @@ static const struct svc_procedure nfsd_procedures2[18] = {
 	},
 };
 
+/*
+ * Storage requirements for XDR arguments and results.
+ */
+union nfsd_xdrstore {
+	struct nfsd_sattrargs	sattr;
+	struct nfsd_diropargs	dirop;
+	struct nfsd_readargs	read;
+	struct nfsd_writeargs	write;
+	struct nfsd_createargs	create;
+	struct nfsd_renameargs	rename;
+	struct nfsd_linkargs	link;
+	struct nfsd_symlinkargs	symlink;
+	struct nfsd_readdirargs	readdir;
+	struct nfsd_attrstat	attrstat;
+	struct nfsd_diropres	diropres;
+	struct nfsd_readlinkres	readlinkres;
+	struct nfsd_readres	readres;
+	struct nfsd_readdirres	readdirres;
+	struct nfsd_statfsres	statfsres;
+};
+
 const struct svc_version nfsd_version2 = {
 	.vs_vers	= 2,
 	.vs_nproc	= ARRAY_SIZE(nfsd_procedures2),
 	.vs_proc	= nfsd_procedures2,
 	.vs_dispatch	= nfsd_dispatch,
-	.vs_xdrsize	= NFS2_SVC_XDRSIZE,
+	.vs_xdrsize	= sizeof(union nfsd_xdrstore),
 };
diff --git a/fs/nfsd/xdr.h b/fs/nfsd/xdr.h
index a2a3b2f58a1d..05b3a18c879a 100644
--- a/fs/nfsd/xdr.h
+++ b/fs/nfsd/xdr.h
@@ -119,24 +119,6 @@ struct nfsd_statfsres {
 	struct kstatfs		stats;
 };
 
-/*
- * Storage requirements for XDR arguments and results.
- */
-union nfsd_xdrstore {
-	struct nfsd_sattrargs	sattr;
-	struct nfsd_diropargs	dirop;
-	struct nfsd_readargs	read;
-	struct nfsd_writeargs	write;
-	struct nfsd_createargs	create;
-	struct nfsd_renameargs	rename;
-	struct nfsd_linkargs	link;
-	struct nfsd_symlinkargs	symlink;
-	struct nfsd_readdirargs	readdir;
-};
-
-#define NFS2_SVC_XDRSIZE	sizeof(union nfsd_xdrstore)
-
-
 bool nfssvc_decode_fhandleargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfssvc_decode_sattrargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfssvc_decode_diropargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-- 
2.55.0


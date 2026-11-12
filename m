Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794516197;
	b=F+DKCR+0soXbwJdTASVDy8FBw+EosX7RaeFD7XGGoEZZwS9JftkdsyI4zSukbU09riDd
	 DVqpscru2wcU5/WUniTOUzBcWt8JOtBAUvidEa6dvCxHCwU/w26bjiYwJde/4OOx0v/LE
	 dX7H7HSwSeKLVZCPPCrUCR6m89hVlz9CDqvmBQhdABME95YcU4vXDDj2rSp6l5no92m4A
	 Z2yavJWUZxbRAYvWWV6NnjYN+MJdHNMtlml4DJrtH5bYPcShO8BN0eb/KrMtjRA+4l/Qc
	 zc5us1qvZvWViiy/28b5/qcLb5rI+2iictrGuviz/6my5TJyLPh0f2UQenC16cUpWfg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794516197;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=70M9/vfkhgLzrnME2+9AKgIEOsZpFUmxMvk2hA29+6g=;
	b=bxxxpXS33QecBRBelalaZR9dqQxdtiE/6rc1QRBGj40/CoT7pccDU/bo8zow7W+zprnj
	 o5hJ9wlE6mMIGa4BskRT4yeaWu3GZ61Kq5JVk761K/WjrQt9BymPd3i8lm8s0kdmG3vQi
	 Pjnsyvy8y3FQ10zNeVImaec+c57bJnT5sY5/BeK30cVsr9voZDn7FOQcwJijNG0KEDo/R
	 ztdxq6uN5n5Yk7FmO2/B38zHUfm2znMeqYK3uDVoMKmEn1oucIKZ+BWTm0pcSFJrfgUbM
	 zjGVX2RGlL3M6mEye4PpodOlyca/wU7X9zzg77xXjAw1f9QQuS/6dzoOV5rvQ+E6DBg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ofc5Rixx;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 57BE8606A321
	for <linux-nfs@vger.kernel.org>; Thu, 12 Nov 2026 20:43:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ofc5Rixx
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D96131F000C5;
	Thu, 12 Nov 2026 20:43:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794516196;
	bh=70M9/vfkhgLzrnME2+9AKgIEOsZpFUmxMvk2hA29+6g=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=ofc5RixxY25tKdzk/bAORyC9Noj3iMhwJPbj/XIFt36n+HqsZdwchNxxYO10BOc1s
	 6W1E22CsInbphUvdRBCMFfAgIQrrQFcQeX0tfKAXY/iVqWYMK4bTMV3nS+3k96wSI0
	 3Ks2hTgLlFKxz4k8vPyPs6dSyhaWqwu8DWJpmrTwfFGGmByDljMsKxCHMS+OISmbVo
	 fJJk7RWGp1E6BXrG+H4i4tXcodLRJ5tdjNsA0k3s9y9DL0gz+YhEXI6DPCKTQHc60t
	 FyKHP7NN2buiBSpkKRmVhTiIbvyMzf/hclIwtqGrJ3Dg9OZwc6mayVih45tH9zVvbE
	 kFzvDSpBwMXgA==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 12 Nov 2026 15:43:03 -0500
Subject: [PATCH v3 3/7] NFSD: Defer the PUTFH secure-port check
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261112-verofess-2-v3-3-487532e4d7ca@kernel.org>
References: <20261112-verofess-2-v3-0-487532e4d7ca@kernel.org>
In-Reply-To: <20261112-verofess-2-v3-0-487532e4d7ca@kernel.org>
To: VeroFess <coderzeng@gmail.com>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=10407; i=cel@kernel.org;
 h=from:subject:message-id; bh=5xdaWsyG45rQzv1lIJXF7G959opB4Lwg0rpwVJTxt28=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq9iTeaQbIiaq6m8vPXFxrWhgTaVmeYVh2L+Y9F
 7r8YASKeZKJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavYk3gAKCRAzarMzb2Z/
 l6myD/95F0WKZyqalv+x7dZ4eMVq5ftjRYs4dz1qrTufZT0BmMNWOa2YqG4ogHWGDih30bfEByT
 ZeQdAi9jA3LZRIDWMV60/PmXJLl7iUsdYLWEqZ9J64ii5wkXkKQgfajmgw/EF6fBlqgLJrsnN7u
 SUjrZfrOlH1QsTb69OS2gOWcJOUp5Qlo9XPehXHfJQCQ1TLTgvJaKylza2I3Lks6rig6VIRPpGd
 rXOgpYRACPsAdx995Shja4u5AeuLk2msrQqlUrOjx6ryck4inl/d2PMbxGK6xg7mOTE5D/du+ew
 zc4lKN8P9Tkl5U/h4XuKzBt/gap3LiWI53zNLXN0fofsCGgCW4gXOambasl5GczVW9jBIc1m0jE
 0TKjrvNcXks0fkrQbBXsRpmS+0bcMLdoJigkd6l5n7vghROWVvpc/33LGVb9w86YjzGdxa96krX
 TvNUmPTTLdFyCn84SyDmI+REkytyOEXgU7MPIO17FQR1sNUuYthXI7AA4zjnYOTJsq9kgTQ3a2X
 Y0giXIkkYMFC47znwQTetvcsmvKEE89dRxBmnQCxD+4G5p/H0TUhFvDhMm1JfXjNUV+MhGJDKyV
 2JD2aHxM5WN/KMwJoGTKpqRhtwNaN+T/GI88/V8EpNEUI1/xS4ca3QHyEroYOvGEPJdRWpUz9jj
 W2+mdCgbYbXjytw==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

When an AUTH_SYS request from an insecure port presents a filehandle
in an export that requires a secure port, fh_verify() fails PUTFH with
NFS4ERR_WRONGSEC. RFC 8881 Sections 2.6.3.1.1.2 through 2.6.3.1.1.5
forbid NFS4ERR_WRONGSEC from a put-filehandle operation that another
put-filehandle operation, LOOKUP, LOOKUPP, OPEN, SECINFO, or
SECINFO_NO_NAME follows. PUTFH therefore cannot report the denial
before it knows which operation follows. SECINFO and SECINFO_NO_NAME
also fail a port denial themselves, so a client cannot learn which
flavors the export accepts.

Defer the port check in PUTFH, as "NFSD: Defer the PUTFH export
security flavor check" deferred the flavor check.
need_wrongsec_check() needs no change, because check_nfsd_access()
already checks the port. Skip the port check in SECINFO and
SECINFO_NO_NAME, as those operations skip the flavor check. Do not
mark the transport valid when fh_verify() skips the port check. After
the change, LOOKUP, LOOKUPP, OPEN, LINK, and RENAME return
NFS4ERR_WRONGSEC for a port denial. For NFSv4.1 and later, SECINFO and
SECINFO_NO_NAME report the flavors the export accepts. An NFSv4.0 PUTFH
that SECINFO follows still reports the denial itself. NFSv2 and NFSv3
still return NFSERR_PERM.

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/export.c   |  4 ++--
 fs/nfsd/nfs4proc.c | 16 ++++++++++------
 fs/nfsd/nfsfh.c    | 24 +++++++++++++++---------
 fs/nfsd/nfsfh.h    |  4 ++--
 fs/nfsd/trace.h    |  3 ++-
 fs/nfsd/vfs.c      |  3 ++-
 fs/nfsd/vfs.h      |  1 +
 7 files changed, 34 insertions(+), 21 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 99a7d92dc43b..d952fdde7314 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -2074,7 +2074,7 @@ __be32 check_security_flavor(struct svc_export *exp, struct svc_rqst *rqstp,
  * @exp: svc_export that is being accessed.
  * @rqstp: svc_rqst attempting to access @exp.
  * @access: NFSD_MAY_* flags; %NFSD_MAY_BYPASS_FLAVOR skips the security
- *	flavor check
+ *	flavor check, %NFSD_MAY_BYPASS_PORT skips the secure-port check
  *
  * Context: Process context.
  *
@@ -2089,7 +2089,7 @@ __be32 check_nfsd_access(struct svc_export *exp, struct svc_rqst *rqstp,
 {
 	__be32 status;
 
-	status = nfsd_check_port(rqstp, &rqstp->rq_cred, exp);
+	status = nfsd_check_port(rqstp, &rqstp->rq_cred, exp, access);
 	if (status != nfs_ok)
 		return status;
 	status = check_xprtsec_policy(exp, rqstp);
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 60e365678d4c..39d648c34ae7 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -843,8 +843,9 @@ nfsd4_putfh(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	cstate->current_fh.fh_handle.fh_size = putfh->pf_fhlen;
 	memcpy(&cstate->current_fh.fh_handle.fh_raw, putfh->pf_fhval,
 	       putfh->pf_fhlen);
-	/* need_wrongsec_check() decides whether the flavor check applies. */
-	ret = fh_verify(rqstp, &cstate->current_fh, 0, NFSD_MAY_BYPASS_FLAVOR);
+	/* need_wrongsec_check() decides whether the bypassed checks apply. */
+	ret = fh_verify(rqstp, &cstate->current_fh, 0,
+			NFSD_MAY_BYPASS_FLAVOR | NFSD_MAY_BYPASS_PORT);
 #ifdef CONFIG_NFSD_V4_2_INTER_SSC
 	if (ret == nfserr_stale && putfh->no_verify) {
 		SET_FH_FLAG(&cstate->current_fh, NFSD4_FH_FOREIGN);
@@ -1280,13 +1281,15 @@ nfsd4_secinfo(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	__be32 err;
 
 	err = fh_verify(rqstp, &cstate->current_fh, S_IFDIR,
-			NFSD_MAY_EXEC | NFSD_MAY_BYPASS_FLAVOR);
+			NFSD_MAY_EXEC | NFSD_MAY_BYPASS_FLAVOR |
+			NFSD_MAY_BYPASS_PORT);
 	if (err)
 		return nfsd4_secinfo_status(err);
 	err = nfsd_lookup_dentry(rqstp, &cstate->current_fh,
 				    secinfo->si_name, secinfo->si_namelen,
 				    &exp, &dentry,
-				    NFSD_MAY_EXEC | NFSD_MAY_BYPASS_FLAVOR);
+				    NFSD_MAY_EXEC | NFSD_MAY_BYPASS_FLAVOR |
+				    NFSD_MAY_BYPASS_PORT);
 	if (err)
 		return nfsd4_secinfo_status(err);
 	if (d_really_is_negative(dentry)) {
@@ -1310,13 +1313,14 @@ nfsd4_secinfo_no_name(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstat
 	switch (u->secinfo_no_name.sin_style) {
 	case NFS4_SECINFO_STYLE4_CURRENT_FH:
 		err = fh_verify(rqstp, &cstate->current_fh, 0,
-				NFSD_MAY_BYPASS_FLAVOR);
+				NFSD_MAY_BYPASS_FLAVOR | NFSD_MAY_BYPASS_PORT);
 		if (err)
 			return nfsd4_secinfo_status(err);
 		break;
 	case NFS4_SECINFO_STYLE4_PARENT:
 		err = nfsd4_do_lookupp(rqstp, &cstate->current_fh,
-				       NFSD_MAY_EXEC | NFSD_MAY_BYPASS_FLAVOR);
+				       NFSD_MAY_EXEC | NFSD_MAY_BYPASS_FLAVOR |
+				       NFSD_MAY_BYPASS_PORT);
 		if (err)
 			return nfsd4_secinfo_status(err);
 		break;
diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index 6a18cf52ab8e..6f85701cbe8b 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -107,6 +107,7 @@ static bool nfsd_originating_port_ok(struct svc_rqst *rqstp,
  * @rqstp: request being checked, or %NULL for a local caller
  * @cred: credential whose flavor selects the export options to check
  * @exp: export being checked
+ * @access: NFSD_MAY_* flags; %NFSD_MAY_BYPASS_PORT skips the check
  *
  * Context: Process context.
  *
@@ -116,9 +117,11 @@ static bool nfsd_originating_port_ok(struct svc_rqst *rqstp,
  * Return: %nfs_ok if allowed, %nfserr_wrongsec for an NFSv4 client,
  * %nfserr_perm otherwise.
  */
-__be32 nfsd_check_port(struct svc_rqst *rqstp,
-		       struct svc_cred *cred, struct svc_export *exp)
+__be32 nfsd_check_port(struct svc_rqst *rqstp, struct svc_cred *cred,
+		       struct svc_export *exp, int access)
 {
+	if (access & NFSD_MAY_BYPASS_PORT)
+		return nfs_ok;
 	if (rqstp && !nfsd_originating_port_ok(rqstp, cred, exp)) {
 		if (IS_ENABLED(CONFIG_SUNRPC_DEBUG)) {
 			char buf[RPC_MAX_ADDRBUFLEN];
@@ -133,11 +136,11 @@ __be32 nfsd_check_port(struct svc_rqst *rqstp,
 
 static __be32 nfsd_setuser_and_check_port(struct svc_rqst *rqstp,
 					  struct svc_cred *cred,
-					  struct svc_export *exp)
+					  struct svc_export *exp, int access)
 {
 	__be32 status;
 
-	status = nfsd_check_port(rqstp, cred, exp);
+	status = nfsd_check_port(rqstp, cred, exp, access);
 	if (status)
 		return status;
 
@@ -226,7 +229,7 @@ static __be32 nfsd_set_fh_dentry(struct svc_rqst *rqstp, struct net *net,
 				 struct svc_cred *cred,
 				 struct auth_domain *client,
 				 struct auth_domain *gssclient,
-				 struct svc_fh *fhp)
+				 struct svc_fh *fhp, int access)
 {
 	struct knfsd_fh	*fh = &fhp->fh_handle;
 	struct fid *fid = NULL;
@@ -305,7 +308,7 @@ static __be32 nfsd_set_fh_dentry(struct svc_rqst *rqstp, struct net *net,
 					   new->cap_permitted);
 		put_cred(override_creds(new));
 	} else {
-		error = nfsd_setuser_and_check_port(rqstp, cred, exp);
+		error = nfsd_setuser_and_check_port(rqstp, cred, exp, access);
 		if (error)
 			goto out;
 	}
@@ -423,7 +426,7 @@ __fh_verify(struct svc_rqst *rqstp,
 
 	if (!fhp->fh_dentry) {
 		error = nfsd_set_fh_dentry(rqstp, net, cred, client,
-					   gssclient, fhp);
+					   gssclient, fhp, access);
 		if (error)
 			goto out;
 	}
@@ -452,7 +455,7 @@ __fh_verify(struct svc_rqst *rqstp,
 	if (error)
 		goto out;
 
-	error = nfsd_setuser_and_check_port(rqstp, cred, exp);
+	error = nfsd_setuser_and_check_port(rqstp, cred, exp, access);
 	if (error)
 		goto out;
 
@@ -500,9 +503,12 @@ __fh_verify(struct svc_rqst *rqstp,
 		error = check_security_flavor(exp, rqstp, may_bypass_gss);
 		if (error)
 			goto out;
-		svc_xprt_set_valid(rqstp->rq_xprt);
 	}
 
+	/* A deferred check has not yet shown that the peer has access. */
+	if (!(access & (NFSD_MAY_BYPASS_FLAVOR | NFSD_MAY_BYPASS_PORT)))
+		svc_xprt_set_valid(rqstp->rq_xprt);
+
 check_permissions:
 	/* Finally, check access permissions. */
 	error = nfsd_permission(cred, exp, dentry, access);
diff --git a/fs/nfsd/nfsfh.h b/fs/nfsd/nfsfh.h
index 90b6429cbcef..51788712d630 100644
--- a/fs/nfsd/nfsfh.h
+++ b/fs/nfsd/nfsfh.h
@@ -226,8 +226,8 @@ extern char * SVCFH_fmt(struct svc_fh *fhp);
 /*
  * Function prototypes
  */
-__be32	nfsd_check_port(struct svc_rqst *rqstp,
-			struct svc_cred *cred, struct svc_export *exp);
+__be32	nfsd_check_port(struct svc_rqst *rqstp, struct svc_cred *cred,
+			struct svc_export *exp, int access);
 __be32	fh_verify(struct svc_rqst *, struct svc_fh *, umode_t, int);
 __be32	fh_verify_local(struct net *, struct svc_cred *, struct auth_domain *,
 			struct svc_fh *, umode_t, int);
diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index 4a2d68410a7d..11a6d7d66f6f 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -143,7 +143,8 @@ DEFINE_NFSD_DYNTHREAD_EVENT(trylock_fail);
 		{ NFSD_MAY_READ_IF_EXEC,	"READ_IF_EXEC" },	\
 		{ NFSD_MAY_64BIT_COOKIE,	"64BIT_COOKIE" },	\
 		{ NFSD_MAY_LOCALIO,		"LOCALIO" },	\
-		{ NFSD_MAY_BYPASS_FLAVOR,	"BYPASS_FLAVOR" })
+		{ NFSD_MAY_BYPASS_FLAVOR,	"BYPASS_FLAVOR" },	\
+		{ NFSD_MAY_BYPASS_PORT,		"BYPASS_PORT" })
 
 TRACE_EVENT(nfsd_compound,
 	TP_PROTO(
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 8db5fa3be86a..b9d76a1a3e65 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -326,7 +326,8 @@ nfsd_lookup_dentry(struct svc_rqst *rqstp, struct svc_fh *fhp,
  * @len:     length of name to examine
  * @resfh:   pointer to pre-initialised filehandle to hold result.
  * @access:  NFSD_MAY_* flags for the fh_verify() of @fhp; adding
- *	     NFSD_MAY_BYPASS_FLAVOR skips the export security flavor checks
+ *	     NFSD_MAY_BYPASS_FLAVOR skips the export security flavor checks,
+ *	     NFSD_MAY_BYPASS_PORT the export's secure-port check
  *
  * Variant of nfsd_lookup() that takes the fh_verify() access flags.
  * The filehandle and mountpoint crossing rules are documented there.
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index f8d90714ef60..40115d9aa245 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -34,6 +34,7 @@
 
 #define NFSD_MAY_LOCALIO		0x2000 /* for tracing, reflects when localio used */
 #define NFSD_MAY_BYPASS_FLAVOR		0x4000 /* skip the export's sec= check */
+#define NFSD_MAY_BYPASS_PORT		0x8000 /* skip the export's secure-port check */
 
 #define NFSD_MAY_CREATE		(NFSD_MAY_EXEC|NFSD_MAY_WRITE)
 #define NFSD_MAY_REMOVE		(NFSD_MAY_EXEC|NFSD_MAY_WRITE|NFSD_MAY_TRUNC)

-- 
2.56.0


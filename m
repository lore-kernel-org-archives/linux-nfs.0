Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793735578;
	b=F1ktlSzaohSD4OvsGCXI74TMyoQDRe5YxYXf01cov16Oy6cPWlVTlnGZWof8FgmJyxff
	 zgC6y2SAb2Vd++5yFTi0R1HdFEq+jtiMrw5vLPc+unwiDWJx9lCiwKzxywGJDufFQ+7ee
	 3lVPPFj132diduDRJe6jcPQ49IurMIM6S6d3pz/jHT4fQ7yE6u9rMBBH6tUCF3sSUqHN3
	 1yAhDtekEQRA6t7QkSUob2QZG4P17/nC8kJ4AXdcfkU7j3UY4eR7CBMI+kbsadKyYbY2S
	 5Yi3Kn1fXFyPrv6ViUAmpMXS2vgLVll7JaMd2yQ68GA95iO2fHrNId3K9a7derekNDA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793735578;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=E0kGWQPbebWHPqbELqp8biWQPb6rOn4JIDPWfuoeJ4g=;
	b=PPw5k8Pcix4jz+GiQl/1RWWrOofZtRutoDeO3i74V1FSWcfJf+7L+hbLijSHKe/IaPUY
	 2Gmze/Nzg7IYCzb3kMhlCooTpATV3/yIv8QgaKpFkwN46FiKUNDM7E5ausmLBGT/V88C5
	 OQDpzAbArFnvkzRFIlo3cl3gJ5TOqxYTbIsjNuOtMX0fvvotpvfkMNeS1i4wvJ9aWczHf
	 iyuljSHnrSCf8WjW0z+8CJHP1/LgMZp2p7i4AXvVc423rClVAt+1O3JYod8TeCCBluHAB
	 uU7YeRBa9DvVGTdap2Dtdn3AYb0KN/O67JY9+3rlK4h/LCxgAPQpPFL/jkrdFnovpwg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="YGF7/WLi";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 17245606D80F
	for <linux-nfs@vger.kernel.org>; Tue,  3 Nov 2026 19:52:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=YGF7/WLi
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 36DB61F00A17;
	Tue,  3 Nov 2026 19:52:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793735577;
	bh=E0kGWQPbebWHPqbELqp8biWQPb6rOn4JIDPWfuoeJ4g=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=YGF7/WLiOVRtDF5vUhLtjCwpWbn/6KYM8HCG2HTEDHtknwLJuRD6GDg/LA0qUp9tU
	 pwEy8b2plDY7Hcl3as4LLAFQF+nBAs5FC6LpPiUv1O1fGJD/pq0bN7QcyXSa6O2oYR
	 Z9jlUop3+2cQ0IeBxDhZANAdMim1YOU7sV1pnJyl4aINCoGgp7fbztNnsx6GsmT9NY
	 pZWovgG+ZKT7l4iu1hjOkchUOSV3USSOkpA90gKFxpwg2+0SZScC/qO5veifYPzg6t
	 SXzILqXJtLyc8pH+Y52RbonaxiP3t7sit1EDDXMt4Rslc/j3EY/dvfnvW9P2WRPj84
	 RmedmTZPLIH1w==
From: Chuck Lever <cel@kernel.org>
Date: Tue, 03 Nov 2026 14:52:37 -0500
Subject: [PATCH 2/5] NFSD: Defer the PUTFH secure-port check
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
Message-Id: <20261103-verofess-2-v1-2-9e6568221beb@kernel.org>
References: <20261103-verofess-2-v1-0-9e6568221beb@kernel.org>
In-Reply-To: <20261103-verofess-2-v1-0-9e6568221beb@kernel.org>
To: VeroFess <coderzeng@gmail.com>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=8963; i=cel@kernel.org;
 h=from:subject:message-id; bh=nJkaw/4gmWueuyxZ6nHaVjQECCx6kEat/uaRK7XvUt8=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq6juWsHxO7Q0b+55q3fo13q/eoA30NabD3eQ2U
 HdV67l/jAyJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCauo7lgAKCRAzarMzb2Z/
 l6lQEACQ0PcuqJ2LoRl0/WTniYYo9ScgzwFsnuG4bicednhcti3SAFYSTLKgbJXZkYiKyF/LPMG
 Kq6OG6J/wYd5musUOZMMWuRFUopBi/gR6FYT8FkBKPpPzTdO1QSl0jLDa6too9fQ0sfvm7Ufmvj
 F7EU+7Ib5JHEsg5Q6fvrWSH7nTZ+t73t22DKNNOAG0VIOszHY4ug6+R4Gy420JkGyoY4uFSfIO+
 bqsX1eBeeG1kPfsrda3+AOmQoU/sMqumufzGrKJg6+7mxFSN9A5OdBFzeeUjd0zywIi7qREkkfj
 yh7ffXPvazcY0BQ3Bpfp9GeG/3ouj5yJzqO99kaAURdW+b93zCo0lsy3IKIp7nQOykfbJ8RkvEy
 Vc2V94OEWQcno4YnFYWMaZ1E0wy7UZ+sT5tQL6aoQr/3W213gUTipTRP13Kxlxze3iRXQ8Ukiju
 2rgFIqs0KSwgcIHnL15wftYYdTvkka8euTOzvHy0Wb4sBm01jjeSGBICu5dKVMvDt9tByR4W2pM
 X/uLtL7+ibcbOSbKhzpBowwhqAR6R1HGZRsRJVJEfO3HZx7a1ouQmKBMGf2WNNfauibMrFNIltz
 uhxkwVxgAi4X1blw28G/F+lWyH22OkG8jb86vR6E9jKHiLTJo8xp4G+sC6121cvHa9qLjKq8J3Q
 sRJIxMxISP4av+w==
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
SECINFO_NO_NAME, as those operations skip the flavor check. After the
change, LOOKUP, LOOKUPP, OPEN, LINK, and RENAME return
NFS4ERR_WRONGSEC for a port denial, and SECINFO and SECINFO_NO_NAME
report the flavors the export accepts. NFSv2 and NFSv3 still return
NFSERR_PERM.

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/export.c   |  4 ++--
 fs/nfsd/nfs4proc.c | 16 ++++++++++------
 fs/nfsd/nfsfh.c    | 19 +++++++++++--------
 fs/nfsd/nfsfh.h    |  4 ++--
 fs/nfsd/trace.h    |  3 ++-
 fs/nfsd/vfs.h      |  1 +
 6 files changed, 28 insertions(+), 19 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index b5147c9797aa..31e691554837 100644
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
index af4cc3a66682..faed08eb1b98 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -827,8 +827,9 @@ nfsd4_putfh(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
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
@@ -1264,13 +1265,15 @@ nfsd4_secinfo(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
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
@@ -1294,13 +1297,14 @@ nfsd4_secinfo_no_name(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstat
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
index f76ce9cc405c..0a5590f1f1bb 100644
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
index e58b753c1ebc..89b1c575f6af 100644
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
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index 939124de6bd7..73ab9d34a275 100644
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


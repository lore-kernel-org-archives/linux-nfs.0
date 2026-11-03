Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793735577;
	b=gOCgYMriEPKSsc9cN5xzoA/Tc2N5ZlelcR22qtTfz1ttb2hmDo+bX0VyOcCC2en44NtV
	 IDm2OZKDarCcEXasql9eHxgI5R9/VIq95s7emQxIO2iwsQZxK9jWa1DnODwdiv6J6PrQj
	 yQ9pvdCzWHlFVwkJTTEfKd8EoFoLJCwUzJMfB2lumwrFulZBvLzFnAMz0/eo1TJR9VGVG
	 xqkF5pc7hHrDgu38xFM5pt/ZWrnxx9hxIOdA715n/WhTlsj4Z21kxvPkgvZSqyhC2t0Aw
	 z6D9I6Bhaii83PPs+unOEi1bXIHkndKg6pKcGlJZkudDwWF31T7QpnlzHNOoBEYPw0Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793735577;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=Tp9ygbndpRe7hdKr5A4LjYmjioWE9eNw75RC8OyJKrw=;
	b=mLnKLTpS0dkVFjBWA6rzZUMX+y/V5g5DQXjA2WnKXdDonwJ4pO0hV3epzxM32vFBUjLM
	 8TibUaRMNgXTp/W0s0IT9Hl0eG166fs7RC7UkOmPTe8QnHho+YQSoTZmBBf8jePnetsmj
	 ANf/y0VsSeXxBxPExmT2Wdjzv+pAIbOl8TGpDxLAcxu03EaUzyTv9v5ojmc0OaSc5heux
	 aE+kduJK4Mp+4SIVVL2aYZL65nMkXo5arJNUlE1esgV93Ak4d3WL20/VVaCui7PtRn8nG
	 BaN4p7KlQ/be2S8DzJqH4ir0gD/hdA872ZSinEEP1nXGUlkToyLWPBRGGecg54tgcEw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=VbxWG5PT;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2016B606A339
	for <linux-nfs@vger.kernel.org>; Tue,  3 Nov 2026 19:52:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=VbxWG5PT
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 471801F00A16;
	Tue,  3 Nov 2026 19:52:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793735577;
	bh=Tp9ygbndpRe7hdKr5A4LjYmjioWE9eNw75RC8OyJKrw=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=VbxWG5PTji/x9XnT5JO8dUtcCTzO1YPrmJHmkAW85DmB4Rf3A5mGugsjuL35bC5UQ
	 es3c2Ya3YVpAQgGjXcmEQaKjT2qeZJfBszU7rso8pHu/CetCAH6AIUEy4TsnHJTyq4
	 CtDRNWHbVUU8AmHy9AuQLYA0E8vi0fAsXsGUhr1LJnPrm9GQHWlib8PgcurnxLqXIt
	 f9h521K852BKd/ojdvPx8wsRztad7NrODXZmf4zHiOewfCkoQWs3jCMjbqIuM/3FXR
	 riFAHpDL81jggadWTek9qHizUeTac6AHjYwAQmYHGEv7nOADsH83bmL/4eDELj8qcE
	 gCSMPzNS7Dq7A==
From: Chuck Lever <cel@kernel.org>
Date: Tue, 03 Nov 2026 14:52:36 -0500
Subject: [PATCH 1/5] NFSD: Check the secure-port policy when entering an
 export
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
Message-Id: <20261103-verofess-2-v1-1-9e6568221beb@kernel.org>
References: <20261103-verofess-2-v1-0-9e6568221beb@kernel.org>
In-Reply-To: <20261103-verofess-2-v1-0-9e6568221beb@kernel.org>
To: VeroFess <coderzeng@gmail.com>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=9008; i=cel@kernel.org;
 h=from:subject:message-id; bh=/LbUttIbR/f4H1CWtneGuDP4xckyvkEDSzMvMdAJR2E=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq6juWipz6VkCuw4DUnK6EvoA5pon431NhqNFB+
 grpArP7PfeJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCauo7lgAKCRAzarMzb2Z/
 l0ZeD/9EMbfaaLL/YaE0dkKETJ2CZWldQz9pq62HWBK1+9kHrKYR2Dts92laknl3gg+vEF5V7zC
 LeTP3EXAcsPzvSlPRZ8dEts3ruTXDzqBKtS2IDFS2Hhwg26TW1qgcKfaGkQhQO+gWrRehzadBKd
 nOOOlLiyJJckSe8AcTJyB9XYbMOZm5n8mdTzTY9Qq6zVXvUGwh+gy5Gg6HL0KKK7b1DR/hlwe44
 uomT3PIfqGSrBxbkzvlf6ayYwOKj0GcBnfreJ8kmfmjgW8ENkRkAa49Zu9m+t0IXTvRkAj+ujGy
 R8Kywh4xEIF/gJE6qBLZc3nCPhMHW3YSyUhY2iLf/CmWi+aocf7LjdhCwvtMCb0ZSAhBge2Rt1x
 +mBYHIGXTODx6U7TW07ZFcg0eex7wo5j+fb6VIM2fWC9hY9T63MCwoKRWPnLi7ny9jYdB5AHF3n
 7mrgG9Fx+e1MQo6CrPdrc/jj5aYYbMA3RdsAmDt2y8WR0dPdHevRBiU0OKZYupetSbkOp1CXeB/
 arMYnHKaAL3jfflxfnsbElOaFjLJKynTj0nEKdP3XGG4VkYCYQ3Uk+qRnW7zVBFU4uih4Hb+lg5
 7rA6WwTiakLcZVGgU5R408PWYdLuuMeH2u59eaK5yztlM5TccZ+97L2AuK2z91jVYW1lx+effIx
 /SHGQyY6eM0sPgQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

When LOOKUP or LOOKUPP crosses into another export, check_nfsd_access()
checks the xprtsec policy and security flavor of the entered export but
skips the secure-port setting. An AUTH_SYS request from an insecure port
can therefore enter a secure export by LOOKUP, though PUTFH of the same
filehandle returns NFS4ERR_PERM. A client that obtained an OPEN stateid
for a file in that export from a privileged port can then READ or CLONE
the file from an insecure port. Commit 6fa02839bf94 ("nfsd4: recheck
for secure ports in fh_verify") rechecks the port in fh_verify(), but
READ and CLONE with an OPEN stateid go through
nfs4_preprocess_stateid_op() and never call fh_verify().

Check the secure-port setting in check_nfsd_access() with
nfsd_check_port(), factored out of fh_verify(). The SECINFO lookups
must still skip the flavor check, so pass the NFSD_MAY_* access flags
to check_nfsd_access() rather than have the mount-crossing paths
assemble their own subset of its checks. After the change, a check
added to check_nfsd_access() also covers the mount-crossing paths.

Report a port denial to an NFSv4 client as NFS4ERR_WRONGSEC. RFC 8881
does not permit NFS4ERR_PERM, the current result, from LOOKUP, LOOKUPP,
or the put-filehandle operations. NFS4ERR_WRONGSEC is permitted there
and is accurate, since a GSS flavor is exempt from the port check.
READDIR, COPY, CLONE, SECINFO, and the NFSv2 and NFSv3 status mapping
already convert NFS4ERR_WRONGSEC to an access error.

Reported-by: VeroFess <coderzeng@gmail.com>
Closes: https://patch.msgid.link/20261103013237.1174538-2-coderzeng@gmail.com
Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/export.c   | 24 +++++++++++++++++-------
 fs/nfsd/export.h   |  3 ++-
 fs/nfsd/nfs4proc.c |  5 +++--
 fs/nfsd/nfsfh.c    | 34 +++++++++++++++++++++++++++++-----
 fs/nfsd/nfsfh.h    |  2 ++
 fs/nfsd/vfs.c      |  8 ++------
 6 files changed, 55 insertions(+), 21 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index f0dd9fb22ec2..b5147c9797aa 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -1976,10 +1976,8 @@ static struct svc_export *exp_find(struct cache_detail *cd,
  *
  * Helper function for check_nfsd_access().  Note that callers should be
  * using check_nfsd_access() instead of calling this function directly.  The
- * exceptions are __fh_verify(), which has logic that may result in one
- * or both of the helpers being skipped, and the mount-crossing paths in
- * nfsd_cross_mnt() and nfsd_lookup_parent(), which enforce only the
- * transport policy when NFSD_MAY_BYPASS_FLAVOR is set.
+ * one exception is __fh_verify() since it has logic that may result in one
+ * or both of the helpers being skipped.
  *
  * Return values:
  *   %nfs_ok if access is granted, or
@@ -2075,18 +2073,30 @@ __be32 check_security_flavor(struct svc_export *exp, struct svc_rqst *rqstp,
  * check_nfsd_access - check if access to export is allowed.
  * @exp: svc_export that is being accessed.
  * @rqstp: svc_rqst attempting to access @exp.
+ * @access: NFSD_MAY_* flags; %NFSD_MAY_BYPASS_FLAVOR skips the security
+ *	flavor check
+ *
+ * Context: Process context.
  *
  * Return values:
- *   %nfs_ok if access is granted, or
- *   %nfserr_wrongsec if access is denied
+ *   %nfs_ok if access is granted,
+ *   %nfserr_wrongsec if access is denied, or
+ *   %nfserr_perm if the secure-port check denies an NFSv2 or NFSv3
+ *   request
  */
-__be32 check_nfsd_access(struct svc_export *exp, struct svc_rqst *rqstp)
+__be32 check_nfsd_access(struct svc_export *exp, struct svc_rqst *rqstp,
+			 int access)
 {
 	__be32 status;
 
+	status = nfsd_check_port(rqstp, &rqstp->rq_cred, exp);
+	if (status != nfs_ok)
+		return status;
 	status = check_xprtsec_policy(exp, rqstp);
 	if (status != nfs_ok)
 		return status;
+	if (access & NFSD_MAY_BYPASS_FLAVOR)
+		return nfs_ok;
 	return check_security_flavor(exp, rqstp, false);
 }
 
diff --git a/fs/nfsd/export.h b/fs/nfsd/export.h
index dcff16618edf..640109da3dda 100644
--- a/fs/nfsd/export.h
+++ b/fs/nfsd/export.h
@@ -123,7 +123,8 @@ int nfsexp_flags(struct svc_cred *cred, struct svc_export *exp);
 __be32 check_xprtsec_policy(struct svc_export *exp, struct svc_rqst *rqstp);
 __be32 check_security_flavor(struct svc_export *exp, struct svc_rqst *rqstp,
 			     bool may_bypass_gss);
-__be32 check_nfsd_access(struct svc_export *exp, struct svc_rqst *rqstp);
+__be32 check_nfsd_access(struct svc_export *exp, struct svc_rqst *rqstp,
+			 int access);
 
 /*
  * Function declarations
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 2c653027d578..af4cc3a66682 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1510,7 +1510,7 @@ nfsd4_verify_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		return nfserr_nofilehandle;
 
 	/* A cached open stateid does not authorize the saved source export. */
-	status = check_nfsd_access(cstate->save_fh.fh_export, rqstp);
+	status = check_nfsd_access(cstate->save_fh.fh_export, rqstp, 0);
 	if (status)
 		return status == nfserr_wrongsec ? nfserr_acces : status;
 
@@ -3486,7 +3486,8 @@ nfsd4_proc_compound(struct svc_rqst *rqstp)
 
 			if (current_fh->fh_export &&
 					need_wrongsec_check(rqstp))
-				op->status = check_nfsd_access(current_fh->fh_export, rqstp);
+				op->status = check_nfsd_access(current_fh->fh_export,
+							       rqstp, 0);
 		}
 encode_op:
 		if (op->status == nfserr_replay_me) {
diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index 09391464803f..f76ce9cc405c 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -102,11 +102,23 @@ static bool nfsd_originating_port_ok(struct svc_rqst *rqstp,
 	return test_bit(RQ_SECURE, &rqstp->rq_flags);
 }
 
-static __be32 nfsd_setuser_and_check_port(struct svc_rqst *rqstp,
-					  struct svc_cred *cred,
-					  struct svc_export *exp)
+/**
+ * nfsd_check_port - check an export's secure-port requirement
+ * @rqstp: request being checked, or %NULL for a local caller
+ * @cred: credential whose flavor selects the export options to check
+ * @exp: export being checked
+ *
+ * Context: Process context.
+ *
+ * A GSS flavor is exempt from the port check, so a denial reports
+ * NFS4ERR_WRONGSEC to an NFSv4 client.
+ *
+ * Return: %nfs_ok if allowed, %nfserr_wrongsec for an NFSv4 client,
+ * %nfserr_perm otherwise.
+ */
+__be32 nfsd_check_port(struct svc_rqst *rqstp,
+		       struct svc_cred *cred, struct svc_export *exp)
 {
-	/* Check if the request originated from a secure port. */
 	if (rqstp && !nfsd_originating_port_ok(rqstp, cred, exp)) {
 		if (IS_ENABLED(CONFIG_SUNRPC_DEBUG)) {
 			char buf[RPC_MAX_ADDRBUFLEN];
@@ -114,8 +126,20 @@ static __be32 nfsd_setuser_and_check_port(struct svc_rqst *rqstp,
 			dprintk("nfsd: request from insecure port %s!\n",
 			        svc_print_addr(rqstp, buf, sizeof(buf)));
 		}
-		return nfserr_perm;
+		return nfsd_v4client(rqstp) ? nfserr_wrongsec : nfserr_perm;
 	}
+	return nfs_ok;
+}
+
+static __be32 nfsd_setuser_and_check_port(struct svc_rqst *rqstp,
+					  struct svc_cred *cred,
+					  struct svc_export *exp)
+{
+	__be32 status;
+
+	status = nfsd_check_port(rqstp, cred, exp);
+	if (status)
+		return status;
 
 	/* Set user creds for this exportpoint */
 	return nfserrno(nfsd_setuser(cred, exp));
diff --git a/fs/nfsd/nfsfh.h b/fs/nfsd/nfsfh.h
index aa3ff3086406..90b6429cbcef 100644
--- a/fs/nfsd/nfsfh.h
+++ b/fs/nfsd/nfsfh.h
@@ -226,6 +226,8 @@ extern char * SVCFH_fmt(struct svc_fh *fhp);
 /*
  * Function prototypes
  */
+__be32	nfsd_check_port(struct svc_rqst *rqstp,
+			struct svc_cred *cred, struct svc_export *exp);
 __be32	fh_verify(struct svc_rqst *, struct svc_fh *, umode_t, int);
 __be32	fh_verify_local(struct net *, struct svc_cred *, struct auth_domain *,
 			struct svc_fh *, umode_t, int);
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 269dc4968f19..6332341a8fba 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -168,9 +168,7 @@ nfsd_cross_mnt(struct svc_rqst *rqstp, struct dentry **dpp,
 			err = 0;
 	} else if (nfsd_v4client(rqstp) ||
 		(exp->ex_flags & NFSEXP_CROSSMOUNT) || EX_NOHIDE(exp2)) {
-		nfserr = (access & NFSD_MAY_BYPASS_FLAVOR) ?
-			 check_xprtsec_policy(exp2, rqstp) :
-			 check_nfsd_access(exp2, rqstp);
+		nfserr = check_nfsd_access(exp2, rqstp, access);
 		if (nfserr == nfs_ok) {
 			/* successfully crossed mount point */
 			/*
@@ -222,9 +220,7 @@ static __be32 nfsd_lookup_parent(struct svc_rqst *rqstp, struct dentry *dparent,
 	} else if (IS_ERR(exp2)) {
 		nfserr = nfserrno(PTR_ERR(exp2));
 	} else {
-		nfserr = (access & NFSD_MAY_BYPASS_FLAVOR) ?
-			 check_xprtsec_policy(exp2, rqstp) :
-			 check_nfsd_access(exp2, rqstp);
+		nfserr = check_nfsd_access(exp2, rqstp, access);
 		if (nfserr != nfs_ok) {
 			exp_put(exp2);
 		} else {

-- 
2.56.0


Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794419039;
	b=rWIl/b8p1pR52VVvfMBXSvAJTeL5Spl6albNLxeWSuZ1ddRE/0AROddebO6+6h8Y4luQ
	 MveetXVVvFzghs5E1gUxdM9jEL+64+pWoBTwn3M8fUQ454I9lPY46+90pGYbAdpXh/97I
	 Lg/FFNOvVgyfs978E6V/2OKisd21n6uWgQrSSn0SzyuwT3Jfkh1bEBLAQUvH+nwk+U/u7
	 7EDvuQfO5FSAt3BRyQ4je286Zdznpxic0TgNjcOqwWlF5esJvWfMT+lquqMdoPgna48G9
	 4YSGIOaLidsuctdQxVeJFynnbyZauQhR0TcMdo8a8m0OXsE/YfsQNPukpV1wAbJkenQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794419039;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=lXdMHq6UOXamyE9PoLHZgTWlAnidRfb8CKxbgeNbEy0=;
	b=oECP3yO1/ffSlsLLh8EGYbOly5Ac0TekbrKXxLhnlmE0zvVVdLtAD+3WrroldtqahqGF
	 3IK3RYUvGtHzazO2TaNsq+kMvyeHYC1rvD8k58qhIoQHBkxrcaJdWeuZBji8kx/9Ta2ZW
	 VODPhUf1OHwtviC5JbPivZ188rl5spUv1YoL/BrVJNbeVvMzOK18Q2gRPcGXUOnz36CED
	 EMByThGwSG7nhTAQ+JlWCZyEKgtJG7te+/JQZAOSDAn3cp/PM3hDIrNjQ/U4ekILoofRB
	 KTTfEti318hV2+8MdgMCc3RucJgOxrh2hYpLTOKS0ATi4iVCsRrzbDN6l5RkTJ7ktBw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=OQJTjrE8;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5E3B4606A334
	for <linux-nfs@vger.kernel.org>; Wed, 11 Nov 2026 17:43:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=OQJTjrE8
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 159901F00A07;
	Wed, 11 Nov 2026 17:43:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794419038;
	bh=lXdMHq6UOXamyE9PoLHZgTWlAnidRfb8CKxbgeNbEy0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=OQJTjrE8U0zi83oJroZ+tg88DMfwJzl7NG2HFoj8lyH47DQ7IVvpm9bncWmryw71P
	 Bj46R9gVc1DTIuqFQBU20DyLVpegiQiIIsJ25EUtrhTdiQP2POxY6/CfirvM6SzTsw
	 nuJAXJH4sDdJAkMDo6rOIakwKzkcRBYvS+WED29aQ/bjgG4wk0FCu9iOpTtbcRM0yh
	 CRd+UVHMO6U4WrE1e3MwKGeayjZ4kn937jCTFkDh4QXUHqng9Ri2OzS6yKPSzMPkkF
	 ILwpgAvg6BIHNLFHaGxlzauEhWOPGgvQZzBipc1HqJvalCI5OuVLP6/Mqox3wiLk6s
	 yxZ2dhnrZ8uQg==
From: Chuck Lever <cel@kernel.org>
Date: Wed, 11 Nov 2026 12:43:41 -0500
Subject: [PATCH v2 1/7] NFSD: Check the secure-port policy when entering an
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
Message-Id: <20261111-verofess-2-v2-1-01596ca4d8b1@kernel.org>
References: <20261111-verofess-2-v2-0-01596ca4d8b1@kernel.org>
In-Reply-To: <20261111-verofess-2-v2-0-01596ca4d8b1@kernel.org>
To: VeroFess <coderzeng@gmail.com>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=9008; i=cel@kernel.org;
 h=from:subject:message-id; bh=9trmw7y7G6YsWpPHNN+0D+QDcX4aGK0H+DwmG2gJcME=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq9KlbD3sppZq1l/ZR+RGDBVj+5oKIFTZ2exI6Z
 mKBupgFh42JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavSpWwAKCRAzarMzb2Z/
 l6yyD/4xI0QAR2z27ZZm9OxGNJqskXRumAHLVRe89vn+ZL2dTi7EwZavwcW1VEG2Y8x0wir0qO0
 SuwNTUu+8jFanTYUWvP0i7n86bnjaAj+V1L7Qt+bAEvhJG93fx6uI0lSqbx3Rk6R8tl61VVyX7w
 XnXlzz/sOrRGZX0EZaMZQymjXYuQwOPB8sXu0yad+cO1/qO8D9FycV+1cykuYktzeIvcp2fJXle
 973mh+CTJNdl3p/YKosInzFzcqO8sNed29Y2qOsAS0LEq0ycfNwD566ODMZ/ro/Z/3q/DepC92A
 GKSpBm6N/joH7KA6trwGMLWwGMBmLWZTeoJhHLYoU4lBfwnC8Dk5xlPNReS3voNukafN5vvBCPu
 kY4cyi1CLcvQSHvKo5y4zqfZ7MrK0WMAaWDtZ+E5EG09i5L2VJuVG4yLVEMx7UX3PyCm354Zwo+
 /1A4lSCNoXFX2EDLd5gTo0M7sQmNtmIh2yYWPykfGZA1xgAt6eEGCJXYmLkd5EhOKKmjmTtG7Ot
 53bhKCjegc12w5PaRPuJpYgWEv7QPjILBI2Mq02Bwn04YGy47se2VsMhuamKRO88kVjJtVl8PcW
 3rRi7YUTTHpLlOWMfjkqKti0N2fZYERUoaDmrD55sdFwPSo/t7UEt72rUtwbwQ5l76qlrnkszVx
 94BinHO5SAEz9fA==
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
index a058897297bf..99a7d92dc43b 100644
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
index dc87142a227c..db4a07b2c1a8 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1526,7 +1526,7 @@ nfsd4_verify_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		return nfserr_nofilehandle;
 
 	/* A cached open stateid does not authorize the saved source export. */
-	status = check_nfsd_access(cstate->save_fh.fh_export, rqstp);
+	status = check_nfsd_access(cstate->save_fh.fh_export, rqstp, 0);
 	if (status)
 		return status == nfserr_wrongsec ? nfserr_acces : status;
 
@@ -3502,7 +3502,8 @@ nfsd4_proc_compound(struct svc_rqst *rqstp)
 
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
index f60e7c346311..8db5fa3be86a 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -167,9 +167,7 @@ nfsd_cross_mnt(struct svc_rqst *rqstp, struct dentry **dpp,
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
@@ -221,9 +219,7 @@ static __be32 nfsd_lookup_parent(struct svc_rqst *rqstp, struct dentry *dparent,
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


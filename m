Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794516194;
	b=Iy1/R7PdEV87FiRHD/6Jn8zC5DU4k3JhmQwVTLaPTcfPPZGMMKaCCWCOEqoYFpuwhlWq
	 39/R3Mt2f+YrBsMehtOXbapgJf/JoucAmWeURkceOT9oYTZ5C0Jle8R1z4zyHnLYvXOcH
	 9kZb2uLrPgGZU8dC6buoUovLMr1qoDDXSAiQgy0LaLeFJ9LQGjvpWULEI32jErA5eKO5k
	 2W8MeweuYfZg1P/q4HPcRlwj9zMO73tKzcdDrVbL777Ij39dS3fcZo7w2lnWo8hBazud9
	 57VEfV6csrPEmwniMssm8cuizhBcsDKnC6AGzstVR4uOoQ8iCRmpXPzRJRjFHD0NOTw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794516194;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=LZQvyPyyJ6Qow92NHcTz4P5CV93XqQWhMOBLUSG8orc=;
	b=tvvRaib+FGj4jFBO4kiw9G0CG31oc7I4qi+g3sRUybfbGt5f8yIlAzJEv9B4yYhTPNtu
	 4AG0zZ5tdKivvZL2EbsPS/bcO4b6HgSLuIAOr8DhHRebOH4gZ1chsb65OCfDShTKKLE19
	 RTWgDMf06gRPDunBEx/aMzuYVsIeYxX+55cy4Ep5r+83HLf/uCrjmwkl0Zz2DwKI6DVcq
	 KpvbHqFpSY8dqe3cPr7Yu8m5SUQq/bpaszaQ93XxZEhc5ZQtX9LjPRXndNpH6ilY8supx
	 cD72UG99+dYD1jTF0LOpwYOi/UIevNQSLqf0Ect5c8plYjBLsYmWDbDwAeuezMHG38Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="RuD28w/j";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B5715606A335
	for <linux-nfs@vger.kernel.org>; Thu, 12 Nov 2026 20:43:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=RuD28w/j
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 508871F000C5;
	Thu, 12 Nov 2026 20:43:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794516194;
	bh=LZQvyPyyJ6Qow92NHcTz4P5CV93XqQWhMOBLUSG8orc=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=RuD28w/j/3vYUgqR0JBsO0eAQ82gFlSiGKZH6uruGk0VOjtgnbp7BC3mZ+MoZe7YW
	 XWDFmfvqxP/TtLtzd9i23N51Hggz1lc/myLSQgu+hgiLYdtTttwk6vQQVo1KC4mTwd
	 IvOrHEPPkbB3mzyc2T2oYDuXQnQwX5WSdwv4y7Vk6h5HEEc+M+vvz7hOysvYPdH3Hb
	 syDnJEZfQ14Mqny8eYPRZK75R5ZSUei54PtF9lo9KXgqQbdkaboy6GX23D4ao2vHnM
	 QgaJVdXZtCdrzqlW+XYPDwC2mzSv2JyymxRVjUtPg5MVfuI3iWNlUwTaQ0rZGo32i9
	 kjg4SB3+wq6Lg==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 12 Nov 2026 15:43:01 -0500
Subject: [PATCH v3 1/7] NFSD: Check the secure-port policy when entering an
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
Message-Id: <20261112-verofess-2-v3-1-487532e4d7ca@kernel.org>
References: <20261112-verofess-2-v3-0-487532e4d7ca@kernel.org>
In-Reply-To: <20261112-verofess-2-v3-0-487532e4d7ca@kernel.org>
To: VeroFess <coderzeng@gmail.com>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=9615; i=cel@kernel.org;
 h=from:subject:message-id; bh=IpFQ2pdHmwaMrDlj6DUQUFXkiex8u5b2Lnpemy+ioJY=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq9iTeqn0V2oCzFNBydi0oh9xz8+nlUuHI3LRgd
 z1hrVYCeHCJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavYk3gAKCRAzarMzb2Z/
 l0hhD/9L+4CYSwNN8N0R6oLj4tDPijuv5GoW8yEIlWlfZLT1hiCGZIa7I7tby8x6QcJcbFBYALa
 D+AZCffTEpKGXxxVSY5cvgRlgu7c1TZv/uXDAZgc3OyPGhDaCMNnMSb9FZYSIh4zdWfri1Kxw3r
 40P/WiyCHq/EC1WtKeMF3Cn4aTClWCFWBNp8eRimGvgaf++S8octkYMwpDItkK/R0fd1UegRG7U
 craIuj3o3OoYuUnhTQMWE8aeVc4Rmvbx1MEw9SFMPXdshHK5L6PzcJklYgjH88vxYOmbdjyM5gl
 bW3vtqdgihee2Dfg9DvCe3Vjzfe+EYxQog3YCR2seLdk7akOth0xbRif3iJ5s9nlKmHzdc+bAkl
 N/7HeSr8r1Kp30UNBQ6rH7mozA8TKBXjJ3LKD+L0UKMT4qdXdZj6XVZ+7LxhIu+Eu2DlruLR1+f
 mQqWgpcMKX8ApcCtYzocLbgDwEdWeMnEjsWCExWtqkPKC8fdPoVLB2DMucgZtCn8LoF/0X3xdwe
 21i2vMwy2Sn8pAR6NzWi9pECuBHAPp3UDTRuiv0QB9+Heh5XIeNj4hcMtL0eNSoLS5gTCPTvR3d
 /W2AoGDHFvaS63CR/Y1C5wcG4FLAKxHUbaZuZ4sDF6py9coaJ+R/YSUsotvcKzmEqMl0w2yoLb8
 Gz4+tp7hqvXManw==
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
already convert NFS4ERR_WRONGSEC to an access error. After the change,
READDIR treats a port denial at a mount crossing like a flavor denial.
The entry carries only rdattr_error, and READDIR fails with
NFS4ERR_ACCESS when the client did not request rdattr_error.

When the export accepts only flavors that are subject to the port
check, SECINFO lists the flavor that was just denied, and a retry with
that flavor fails again. NFS4ERR_WRONGSEC is still reported in that
case. RFC 8881 does not permit a put-filehandle operation to return
NFS4ERR_ACCESS or NFS4ERR_PERM. The Linux NFS client retries a LOOKUP
once after SECINFO and then returns EPERM.

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


Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793627900;
	b=o47WQ+i2EkceTueVm3qOQOmSuKUVTxxHNl97N+4CnQ2gL7hlP18uaGWTlBqwOMKI/nAK
	 TV1J8+Hf0tIo2y72uD21A454A0bO+uOkICQ1qsRmX6i6uckNw0w6UxRXruiqxI8hbIZ3Y
	 3/leE208fyH1Ab3xVK/QoLkHc178zvox5oPqCB6t/+axACz8FpiFcZRTOs6Kua/PoOXcm
	 7Cmq65CPoRKrJTLnvTJYFeJ7xRHCy+EPQozCc2l7QC6ycIYtipyE+eWaFgXRpneqjTmis
	 dan9xYzQujFs9kS6tmXhfRNXWYG7yuAc43DZnYfP5m2lR+KQOsPtvEwB1XxFWj4m9CQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793627900;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=9yFioRJQ6d4j71IKWMXAIOXzU3IYJnMlRwhRpdK85nE=;
	b=YGOGunG1zRJ39IcM+0d/C5yKLWyuKGXygo7NyCZzbaS/ynAu92SBBFRl1mJ4JtVLDeyX
	 IOvnSOEh0lkB3gqBpDjK/DTj1/EPlaE+IEN3zgO7xOvJB0yQpy08zaf9TvuBy1BALl6x0
	 3V+bU/Atci4GVvU370eAtHudW4E1qnElYy9V5ISBjZ4+NT7IZXtbqaZkDUrV6+wa0PZzB
	 UMyz8r5oL+MYzy/kCyak5Y077L8KSQL9lesbbKDPGRNvHn+ZKMUWPAj6muOTvHkmCod/K
	 vRGy9PUv1okf4STDwwUiMauiYn+T8GW19BQD7WI2ESo1Az5WyvbADugkoSB5lO140iw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=lQn0+iR5;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E77FC60A261A
	for <linux-nfs@vger.kernel.org>; Mon,  2 Nov 2026 13:58:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=lQn0+iR5
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B1BD71F00A1A;
	Mon,  2 Nov 2026 13:58:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793627899;
	bh=9yFioRJQ6d4j71IKWMXAIOXzU3IYJnMlRwhRpdK85nE=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=lQn0+iR5M9SiiLdk8uPSfzif6iFFJFj7Njgu5YnAtP9n84H63ro5tg8uuSU0xLC6n
	 NWjDAq71SEIFrwDwAKblL72rIcrbZqVylTrU+xq+jDN2iJ/rivqvqw8Vo98FWb3pJp
	 bgjkP/w2ygd5udntOpiFPibNBZLkSqjpRBz2VIqiudRC34mLmxYnfGbooNLHhXCE8s
	 xkA3ncga1gjkdExBU8zRMN0IB8FpsFjUUG56Vr//7YSyO/wCLms1fcdoA0e/JlWsur
	 zk1jm9jJCrc1LGCLBdyKvSTOtTln4Jjzl8a2EvHlw2zgHsj5miYsr9oHBu9oRbzBnQ
	 MpGCMFwB8riSw==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 02 Nov 2026 08:58:04 -0500
Subject: [PATCH v7 4/5] NFSD: Let SECINFO query an export that excludes the
 request's flavor
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
Message-Id: <20261102-verofess-v7-4-d2cc0de4d44e@kernel.org>
References: <20261102-verofess-v7-0-d2cc0de4d44e@kernel.org>
In-Reply-To: <20261102-verofess-v7-0-d2cc0de4d44e@kernel.org>
To: VeroFess <coderzeng@gmail.com>, Chuck Lever <cel@kernel.org>, 
 Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=17889; i=cel@kernel.org;
 h=from:subject:message-id; bh=cTb58EFM04xmrGDF/FmJkjUY//AVTz9zgOHym1KtWIE=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq6Jb1WWKqeumkhQOXa/u9sO9MR+K9R1gQ7AMP7
 6EmJVF9QQWJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCauiW9QAKCRAzarMzb2Z/
 lzjJD/9A/1AGE+yyrkXYTcvhhacNfiwNjkTtBHeHbsMaVPwCT6qg4Dm7KkDd/GnpZT66jeUgH12
 KHnkaeCDQCcdkKvJnGQX5VNJG1QZrTILAcYKamv+2pm7C7RyBfJt85IDf+sAldZd+YgkCY1Wxlk
 RQYFKy8fCd9sLCvSNAFMl66+UXIY8wNOTDQtsnjc400YL2S9+L3AkchC9vJ+5mZyTOr4vmGuIr1
 1jvHAO8GesOQb+yh94SEGSvqBlojOMFPM9HbHPm7fxSje3+VzCIZaY3baQOeDnrR+52Gpgk44aZ
 b91ojA9SEBQQlrCN30+KcdZHOqd2xavrSE1ASAO9mThC+8PnOQc1/tbTMPWN/To9LdYc1GAo5Tw
 Nfhghu9wj7Sv8DvOX/qcpdjU7T0yvvghPzdvzTUD7obfiw8ICUBWvMYfBXFmULWrQEMXuOHkXaH
 4t/pZ6m2zNjiMN35s7JnRz7IpRK41qHTyOxjjUZhgYlV5fXaJME/KA61STDwYD8oMPq0DGRmDwS
 coRAegc1Xknbrb5UJI4zq/CLSn7DsC8MU4PmmcYTMh9dC9ztokbbea/DL8HS4cOFe2p+aH0nsQd
 pqP1eGcjvlz9H63ZtuZQCTj+g3QiMc1mQ7DJ4+JfvYHg+UnJGrhdBdPmXUcb7uueFmB/tKrummS
 mmWW6ANBcj2j6xw==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

From: VeroFess <coderzeng@gmail.com>

SECINFO and SECINFO_NO_NAME report export security policies. RFC
8881 Section 2.6.3.1.1.5 forbids NFS4ERR_WRONGSEC from either
operation, which allows a client using any flavor to learn whether
a name exists in a directory on a sec=krb5p export. The starting
directory's fh_verify(..., NFSD_MAY_EXEC) call rejects SECINFO and
SECINFO_NO_NAME(PARENT) when that export does not allow the request's
flavor, and a mount crossing rejects it again on the crossed-into
export. SECINFO_NO_NAME(CURRENT_FH) never calls fh_verify() at all, so
after PUTROOTFH it reports the pseudo-root's flavors without checking
that export's transport policy or secure port requirement.

Add NFSD_MAY_BYPASS_FLAVOR, which fh_verify() and the lookup path
both read: it skips the starting export's security flavor check and
the flavor check on a mount crossing or parent step-up. Verify the
current filehandle with it in SECINFO_NO_NAME(CURRENT_FH) as well.
NFSv4.0 is different: RFC 7530 permits NFS4ERR_WRONGSEC from PUTFH and
from neither SECINFO nor the operation after it, and a v4.0 SECINFO
leaves the current filehandle in place. A v4.0 put-filehandle operation
followed by SECINFO therefore keeps its own export check, so the error
is reported where RFC 7530 allows it. The Linux and illumos clients
send SECINFO only with a parent directory they already hold under the
same flavor, and FreeBSD does not send SECINFO at all, so the check does
not fire for any of them. The export's transport policy (xprtsec=) is a
transport-layer requirement, not part of the flavor negotiation SECINFO
performs, so SECINFO still enforces it on the starting export and on
any export a crossing enters. When SECINFO or SECINFO_NO_NAME itself
detects the transport policy mismatch, report NFS4ERR_ACCESS, the error
RFC 8881 Section 18.29.3 specifies for a SECINFO access failure. The
directory type, secure-port, and execute-permission checks on the
starting directory still apply.

Fixes: 29a78a3ed7fc ("nfsd4: make fh_verify responsibility of nfsd_lookup_dentry caller")
Fixes: 04f4ad16b231 ("nfsd4: implement secinfo_no_name")
Signed-off-by: VeroFess <coderzeng@gmail.com>
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/export.c    |  6 ++++--
 fs/nfsd/nfs3proc.c  |  2 +-
 fs/nfsd/nfs4proc.c  | 44 ++++++++++++++++++++++++++++++++++----------
 fs/nfsd/nfs4state.c |  2 +-
 fs/nfsd/nfs4xdr.c   |  2 +-
 fs/nfsd/nfsfh.c     |  9 ++++++---
 fs/nfsd/nfsproc.c   |  2 +-
 fs/nfsd/trace.h     |  3 ++-
 fs/nfsd/vfs.c       | 48 ++++++++++++++++++++++++------------------------
 fs/nfsd/vfs.h       | 43 +++++++++++++++++++++++++++++++++++++------
 10 files changed, 111 insertions(+), 50 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 397767d756c6..f0dd9fb22ec2 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -1976,8 +1976,10 @@ static struct svc_export *exp_find(struct cache_detail *cd,
  *
  * Helper function for check_nfsd_access().  Note that callers should be
  * using check_nfsd_access() instead of calling this function directly.  The
- * one exception is __fh_verify() since it has logic that may result in one
- * or both of the helpers being skipped.
+ * exceptions are __fh_verify(), which has logic that may result in one
+ * or both of the helpers being skipped, and the mount-crossing paths in
+ * nfsd_cross_mnt() and nfsd_lookup_parent(), which enforce only the
+ * transport policy when NFSD_MAY_BYPASS_FLAVOR is set.
  *
  * Return values:
  *   %nfs_ok if access is granted, or
diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 11e05b2e5e84..1025cec447a9 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -961,7 +961,7 @@ nfsd3_create_file(struct svc_rqst *rqstp, struct svc_fh *dirfhp,
 		 */
 		if (d_is_reg(child) &&
 		    unlikely(nfsd_mountpoint(child, exp))) {
-			status = nfsd_cross_mnt(rqstp, &child, &exp);
+			status = nfsd_cross_mnt(rqstp, &child, &exp, 0);
 			if (status != nfs_ok) {
 				exp_put(exp);
 				goto out;
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index b6dcb889b5eb..6ff59fac9094 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -342,7 +342,7 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		    unlikely(nfsd_mountpoint(child, fhp->fh_export))) {
 			struct svc_export *exp = exp_get(fhp->fh_export);
 
-			status = nfsd_cross_mnt(rqstp, &child, &exp);
+			status = nfsd_cross_mnt(rqstp, &child, &exp, 0);
 			if (status == nfs_ok)
 				status = fh_compose(resfhp, exp,
 						    child, fhp);
@@ -1079,7 +1079,17 @@ nfsd4_link(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	return status;
 }
 
-static __be32 nfsd4_do_lookupp(struct svc_rqst *rqstp, struct svc_fh *fh)
+/*
+ * RFC 8881 Section 2.6.3.1.1.5 forbids NFS4ERR_WRONGSEC from SECINFO.
+ * Section 18.29.3 has SECINFO report a denied lookup as NFS4ERR_ACCESS.
+ */
+static __be32 nfsd4_secinfo_status(__be32 status)
+{
+	return status == nfserr_wrongsec ? nfserr_acces : status;
+}
+
+static __be32 nfsd4_do_lookupp(struct svc_rqst *rqstp, struct svc_fh *fh,
+			       int access)
 {
 	struct svc_fh tmp_fh;
 	__be32 ret;
@@ -1093,14 +1103,14 @@ static __be32 nfsd4_do_lookupp(struct svc_rqst *rqstp, struct svc_fh *fh)
 		return nfserr_noent;
 	}
 	fh_put(&tmp_fh);
-	return nfsd_lookup(rqstp, fh, "..", 2, fh);
+	return __nfsd_lookup(rqstp, fh, "..", 2, fh, access);
 }
 
 static __be32
 nfsd4_lookupp(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	      union nfsd4_op_u *u)
 {
-	return nfsd4_do_lookupp(rqstp, &cstate->current_fh);
+	return nfsd4_do_lookupp(rqstp, &cstate->current_fh, NFSD_MAY_EXEC);
 }
 
 static __be32
@@ -1252,14 +1262,16 @@ nfsd4_secinfo(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	struct dentry *dentry;
 	__be32 err;
 
-	err = fh_verify(rqstp, &cstate->current_fh, S_IFDIR, NFSD_MAY_EXEC);
+	err = fh_verify(rqstp, &cstate->current_fh, S_IFDIR,
+			NFSD_MAY_EXEC | NFSD_MAY_BYPASS_FLAVOR);
 	if (err)
-		return err;
+		return nfsd4_secinfo_status(err);
 	err = nfsd_lookup_dentry(rqstp, &cstate->current_fh,
 				    secinfo->si_name, secinfo->si_namelen,
-				    &exp, &dentry);
+				    &exp, &dentry,
+				    NFSD_MAY_EXEC | NFSD_MAY_BYPASS_FLAVOR);
 	if (err)
-		return err;
+		return nfsd4_secinfo_status(err);
 	if (d_really_is_negative(dentry)) {
 		exp_put(exp);
 		err = nfserr_noent;
@@ -1280,11 +1292,16 @@ nfsd4_secinfo_no_name(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstat
 
 	switch (u->secinfo_no_name.sin_style) {
 	case NFS4_SECINFO_STYLE4_CURRENT_FH:
+		err = fh_verify(rqstp, &cstate->current_fh, 0,
+				NFSD_MAY_BYPASS_FLAVOR);
+		if (err)
+			return nfsd4_secinfo_status(err);
 		break;
 	case NFS4_SECINFO_STYLE4_PARENT:
-		err = nfsd4_do_lookupp(rqstp, &cstate->current_fh);
+		err = nfsd4_do_lookupp(rqstp, &cstate->current_fh,
+				       NFSD_MAY_EXEC | NFSD_MAY_BYPASS_FLAVOR);
 		if (err)
-			return err;
+			return nfsd4_secinfo_status(err);
 		break;
 	default:
 		return nfserr_inval;
@@ -3267,6 +3284,13 @@ static bool need_wrongsec_check(struct svc_rqst *rqstp)
 
 	if (next->opnum == OP_ILLEGAL)
 		return false;
+	/*
+	 * RFC 7530 permits NFS4ERR_WRONGSEC from PUTFH but not from
+	 * SECINFO, and NFSv4.0 SECINFO leaves the current filehandle in
+	 * place for the next operation.
+	 */
+	if (resp->cstate.minorversion == 0 && next->opnum == OP_SECINFO)
+		return true;
 	nextd = OPDESC(next);
 	/*
 	 * RFC 8881 Section 2.6.3.1.1.2: a later put-filehandle operation
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index cafdf80f32de..97b4fa30362a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -7126,7 +7126,7 @@ nfsd4_verify_deleg_dentry(struct nfsd4_open *open, struct nfs4_file *fp,
 
 	err = nfsd_lookup_dentry(open->op_rqstp, parent,
 				 open->op_fname, open->op_fnamelen,
-				 &exp, &child);
+				 &exp, &child, 0);
 
 	if (err)
 		return -ESTALE;
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index a6651349bcc8..111bf2b8ebd1 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -4676,7 +4676,7 @@ nfsd4_encode_entry4_fattr(struct nfsd4_readdir *cd, const char *name,
 		 * Different "."/".." handling?  Something else?
 		 * At least, add a comment here to explain....
 		 */
-		nfserr = nfsd_cross_mnt(cd->rd_rqstp, &dentry, &exp);
+		nfserr = nfsd_cross_mnt(cd->rd_rqstp, &dentry, &exp, 0);
 		if (nfserr)
 			goto out_put;
 		crossed = true;
diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index f1ba5a14bb85..09391464803f 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -471,9 +471,12 @@ __fh_verify(struct svc_rqst *rqstp,
 			&& exp->ex_path.dentry == dentry)
 		may_bypass_gss = true;
 
-	error = check_security_flavor(exp, rqstp, may_bypass_gss);
-	if (error)
-		goto out;
+	/* The xprtsec= policy applies even when the flavor check is bypassed. */
+	if (!(access & NFSD_MAY_BYPASS_FLAVOR)) {
+		error = check_security_flavor(exp, rqstp, may_bypass_gss);
+		if (error)
+			goto out;
+	}
 
 	svc_xprt_set_valid(rqstp->rq_xprt);
 
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 2f8da62ad6b0..43e6a4b6a259 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -712,7 +712,7 @@ nfsd_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	exp = exp_get(fhp->fh_export);
 	if (d_is_reg(dchild) &&
 	    unlikely(nfsd_mountpoint(dchild, exp))) {
-		status = nfsd_cross_mnt(rqstp, &dchild, &exp);
+		status = nfsd_cross_mnt(rqstp, &dchild, &exp, 0);
 		if (status != nfs_ok) {
 			exp_put(exp);
 			goto out;
diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index e7b186307c21..e58b753c1ebc 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -142,7 +142,8 @@ DEFINE_NFSD_DYNTHREAD_EVENT(trylock_fail);
 		{ NFSD_MAY_BYPASS_GSS,		"BYPASS_GSS" },		\
 		{ NFSD_MAY_READ_IF_EXEC,	"READ_IF_EXEC" },	\
 		{ NFSD_MAY_64BIT_COOKIE,	"64BIT_COOKIE" },	\
-		{ NFSD_MAY_LOCALIO,		"LOCALIO" })
+		{ NFSD_MAY_LOCALIO,		"LOCALIO" },	\
+		{ NFSD_MAY_BYPASS_FLAVOR,	"BYPASS_FLAVOR" })
 
 TRACE_EVENT(nfsd_compound,
 	TP_PROTO(
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 3486a2ee26ba..269dc4968f19 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -124,14 +124,13 @@ nfserrno(int errno)
 }
 
 /*
- * Called from nfsd_lookup and encode_dirent. Check if we have crossed
- * a mount point.
+ * Check if we have crossed a mount point.
  * Returns an nfs error leaving *dpp and *expp unchanged,
  *  or nfs_ok having possibly changed *dpp and *expp
  */
 __be32
 nfsd_cross_mnt(struct svc_rqst *rqstp, struct dentry **dpp,
-	       struct svc_export **expp)
+	       struct svc_export **expp, int access)
 {
 	struct svc_export *exp = *expp, *exp2 = NULL;
 	struct dentry *dentry = *dpp;
@@ -169,7 +168,9 @@ nfsd_cross_mnt(struct svc_rqst *rqstp, struct dentry **dpp,
 			err = 0;
 	} else if (nfsd_v4client(rqstp) ||
 		(exp->ex_flags & NFSEXP_CROSSMOUNT) || EX_NOHIDE(exp2)) {
-		nfserr = check_nfsd_access(exp2, rqstp);
+		nfserr = (access & NFSD_MAY_BYPASS_FLAVOR) ?
+			 check_xprtsec_policy(exp2, rqstp) :
+			 check_nfsd_access(exp2, rqstp);
 		if (nfserr == nfs_ok) {
 			/* successfully crossed mount point */
 			/*
@@ -205,7 +206,8 @@ static void follow_to_parent(struct path *path)
 }
 
 static __be32 nfsd_lookup_parent(struct svc_rqst *rqstp, struct dentry *dparent,
-				 struct svc_export **exp, struct dentry **dentryp)
+				 struct svc_export **exp, struct dentry **dentryp,
+				 int access)
 {
 	struct svc_export *exp2;
 	struct path path = {.mnt = mntget((*exp)->ex_path.mnt),
@@ -220,7 +222,9 @@ static __be32 nfsd_lookup_parent(struct svc_rqst *rqstp, struct dentry *dparent,
 	} else if (IS_ERR(exp2)) {
 		nfserr = nfserrno(PTR_ERR(exp2));
 	} else {
-		nfserr = check_nfsd_access(exp2, rqstp);
+		nfserr = (access & NFSD_MAY_BYPASS_FLAVOR) ?
+			 check_xprtsec_policy(exp2, rqstp) :
+			 check_nfsd_access(exp2, rqstp);
 		if (nfserr != nfs_ok) {
 			exp_put(exp2);
 		} else {
@@ -261,7 +265,8 @@ int nfsd_mountpoint(struct dentry *dentry, struct svc_export *exp)
 __be32
 nfsd_lookup_dentry(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		   const char *name, unsigned int len,
-		   struct svc_export **exp_ret, struct dentry **dentry_ret)
+		   struct svc_export **exp_ret, struct dentry **dentry_ret,
+		   int access)
 {
 	struct svc_export	*exp;
 	struct dentry		*dparent;
@@ -284,7 +289,7 @@ nfsd_lookup_dentry(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		else {
 			/* checking mountpoint crossing is very different when stepping up */
 			__be32 nfserr = nfsd_lookup_parent(rqstp, dparent,
-							   &exp, &dentry);
+							   &exp, &dentry, access);
 
 			if (nfserr) {
 				exp_put(exp);
@@ -298,7 +303,8 @@ nfsd_lookup_dentry(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		if (IS_ERR(dentry))
 			goto out_nfserr;
 		if (nfsd_mountpoint(dentry, exp)) {
-			__be32 nfserr = nfsd_cross_mnt(rqstp, &dentry, &exp);
+			__be32 nfserr = nfsd_cross_mnt(rqstp, &dentry, &exp,
+						       access);
 
 			if (nfserr) {
 				dput(dentry);
@@ -317,37 +323,31 @@ nfsd_lookup_dentry(struct svc_rqst *rqstp, struct svc_fh *fhp,
 }
 
 /**
- * nfsd_lookup - look up a single path component for nfsd
+ * __nfsd_lookup - look up a single path component for nfsd
  *
  * @rqstp:   the request context
  * @fhp:     the file handle of the directory
  * @name:    the component name, or %NULL to look up parent
  * @len:     length of name to examine
  * @resfh:   pointer to pre-initialised filehandle to hold result.
+ * @access:  NFSD_MAY_* flags for the fh_verify() of @fhp; adding
+ *	     NFSD_MAY_BYPASS_FLAVOR skips the export security flavor checks
  *
- * Look up one component of a pathname.
- * N.B. After this call _both_ fhp and resfh need an fh_put
- *
- * If the lookup would cross a mountpoint, and the mounted filesystem
- * is exported to the client with NFSEXP_NOHIDE, then the lookup is
- * accepted as it stands and the mounted directory is
- * returned. Otherwise the covered directory is returned.
- * NOTE: this mountpoint crossing is not supported properly by all
- *   clients and is explicitly disallowed for NFSv3
- *
+ * Variant of nfsd_lookup() that takes the fh_verify() access flags.
+ * The filehandle and mountpoint crossing rules are documented there.
  */
 __be32
-nfsd_lookup(struct svc_rqst *rqstp, struct svc_fh *fhp, const char *name,
-	    unsigned int len, struct svc_fh *resfh)
+__nfsd_lookup(struct svc_rqst *rqstp, struct svc_fh *fhp, const char *name,
+	      unsigned int len, struct svc_fh *resfh, int access)
 {
 	struct svc_export	*exp;
 	struct dentry		*dentry;
 	__be32 err;
 
-	err = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_EXEC);
+	err = fh_verify(rqstp, fhp, S_IFDIR, access);
 	if (err)
 		return err;
-	err = nfsd_lookup_dentry(rqstp, fhp, name, len, &exp, &dentry);
+	err = nfsd_lookup_dentry(rqstp, fhp, name, len, &exp, &dentry, access);
 	if (err)
 		return err;
 	/*
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index 3cac25adf16b..939124de6bd7 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -33,6 +33,7 @@
 #define NFSD_MAY_64BIT_COOKIE		0x1000 /* 64 bit readdir cookies for >= NFSv3 */
 
 #define NFSD_MAY_LOCALIO		0x2000 /* for tracing, reflects when localio used */
+#define NFSD_MAY_BYPASS_FLAVOR		0x4000 /* skip the export's sec= check */
 
 #define NFSD_MAY_CREATE		(NFSD_MAY_EXEC|NFSD_MAY_WRITE)
 #define NFSD_MAY_REMOVE		(NFSD_MAY_EXEC|NFSD_MAY_WRITE|NFSD_MAY_TRUNC)
@@ -128,12 +129,42 @@ void		nfsd_maybe_reset_write_verifier(struct nfsd_net *nn,
 						struct svc_rqst *rqstp,
 						int err);
 __be32		nfsd_cross_mnt(struct svc_rqst *rqstp, struct dentry **dpp,
-			       struct svc_export **expp);
-__be32		nfsd_lookup(struct svc_rqst *, struct svc_fh *,
-				const char *, unsigned int, struct svc_fh *);
-__be32		 nfsd_lookup_dentry(struct svc_rqst *, struct svc_fh *,
-				const char *, unsigned int,
-				struct svc_export **, struct dentry **);
+			       struct svc_export **expp, int access);
+__be32		__nfsd_lookup(struct svc_rqst *rqstp, struct svc_fh *fhp,
+			      const char *name, unsigned int len,
+			      struct svc_fh *resfh, int access);
+
+/**
+ * nfsd_lookup - look up a single path component for nfsd
+ *
+ * @rqstp:   the request context
+ * @fhp:     the file handle of the directory
+ * @name:    the component name, or %NULL to look up parent
+ * @len:     length of name to examine
+ * @resfh:   pointer to pre-initialised filehandle to hold result.
+ *
+ * Look up one component of a pathname.
+ * N.B. After this call _both_ fhp and resfh need an fh_put
+ *
+ * If the lookup would cross a mountpoint, and the mounted filesystem
+ * is exported to the client with NFSEXP_NOHIDE, then the lookup is
+ * accepted as it stands and the mounted directory is
+ * returned. Otherwise the covered directory is returned.
+ * NOTE: this mountpoint crossing is not supported properly by all
+ *   clients and is explicitly disallowed for NFSv3
+ *
+ */
+static inline __be32 nfsd_lookup(struct svc_rqst *rqstp, struct svc_fh *fhp,
+				 const char *name, unsigned int len,
+				 struct svc_fh *resfh)
+{
+	return __nfsd_lookup(rqstp, fhp, name, len, resfh, NFSD_MAY_EXEC);
+}
+
+__be32		nfsd_lookup_dentry(struct svc_rqst *rqstp, struct svc_fh *fhp,
+				   const char *name, unsigned int len,
+				   struct svc_export **exp_ret,
+				   struct dentry **dentry_ret, int access);
 __be32		nfsd_setattr(struct svc_rqst *, struct svc_fh *,
 			     struct nfsd_attrs *, const struct timespec64 *);
 int nfsd_mountpoint(struct dentry *, struct svc_export *);

-- 
2.56.0


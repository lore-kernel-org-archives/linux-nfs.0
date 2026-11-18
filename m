Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794962539;
	b=5Q36+TB5M99vrY9++gc5TXWmxTfBSJdDIA1vWJYP1KlpYo0GORRp0D6xiQY6UERbKedD
	 M4xnl18CVJpQ7yYnrXfCi6tPYw/zC46gcEHfFyzl2zhblARH+bK1KHhyCxkAHGdGSMLxz
	 uT7BQ9kx0OM8g0KdbZVwp8eeqnV/RLz6dL5xizMMUE7uJ1o43Krc+jPIX1Ym5zCV/7KCE
	 vVGf9p687oXvafM7RIUbVrPrzt02xn0qYk1SlTWEJ3FshrittTNpItMrWIYlo09rze771
	 LtJkr1yRZ48X+SPmOCkEokx/KexhqEKvkYMRhZtoHgTn3WR0/vY1OEpAWtYBA4Q8aOg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794962539;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=5V54YSfj7UhOjRoXJ9aJffnlbPXGRFjysd4a1ZA0yjs=;
	b=RvpTNGtd7shOzetvDcr8Y9LzybZRSnZ1d4qHqG4ifszen66fGYx15FA96vwDLVroFciF
	 dMwU4TjOfzryPqKtF3RaTjCwk07uo9K7reRiEP2RAS/wzOsNU7ikq6AOlyvnlApKeWry2
	 pvbqrq3VmRF3KWF+Md/C90TuszzecAk70jL4wUPqV4T/SH6TqB6blaGh+aUanXf/StVYZ
	 JJvjPAEP6tDOMwlDf1IIwz2rtqGreYv+25HvXmWq9n9eTeh63MRv80VTZaZel7+a7t5uN
	 eWXz2WLMNfv0iqmU4Qw11eZlpf8o3jykKnG7IY8dzjGZZBiLTQWY9dYOK2ibWNl3i8w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BpHg1tCO;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D31E7606A88E
	for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 00:42:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BpHg1tCO
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6D99B1F000C8;
	Wed, 18 Nov 2026 00:42:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794962539;
	bh=5V54YSfj7UhOjRoXJ9aJffnlbPXGRFjysd4a1ZA0yjs=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=BpHg1tCOCh8DHGYNBjURenK9M7O5+2YvniYF4+B/3bLT6RIp3IL5sIKbyy9yj/lUE
	 9wR2UdeclHuQ5NFmQfmN+uwgKHb/gIelJ9dzKpquhz9geTYdc2j44LjQUKE1V6saId
	 81hyGrYjz0v6GXVtXXWY1oqqjUEJM9VLvOmErEOsZxQUTGx51J21oFiW0JNePdm1oe
	 NL4+JdnHSOz2dWC9pytoPooV24KLiP5A4TI9BmdsPrc09yAvbuMupH8r8P2s1ykU3S
	 syY0ZF+OBF0YQWMbd4QmnC7xU2lAB8b3Jm6zr44/d6DzME5iUdul76iLPQpIqEU7h0
	 MOXXJKA5fEuvQ==
From: Chuck Lever <cel@kernel.org>
Date: Tue, 17 Nov 2026 19:42:10 -0500
Subject: [PATCH 2/2] NFSD: Move the spo_must_allow check out of
 check_security_flavor()
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
Message-Id: <20261117-nfsd-spo-must-allow-v1-2-ac351b60d1a3@kernel.org>
References: <20261117-nfsd-spo-must-allow-v1-0-ac351b60d1a3@kernel.org>
In-Reply-To: <20261117-nfsd-spo-must-allow-v1-0-ac351b60d1a3@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Andrew Elble <aweits@rit.edu>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=13543; i=cel@kernel.org;
 h=from:subject:message-id; bh=NLNVza9ZGhxlAodmBZBAc5uYzmaZJN3fH4Vhicy0+yA=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq/PRqKWbeMe+Bjcz6rF5xs2injnm3g4WuOAPXj
 0SQrLF4eaOJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavz0agAKCRAzarMzb2Z/
 ly40D/4xmKnNyAbn1lv9qEHKYg5emzmxfi5j73yBYYvd+EjQAjZZ0KdOUps/45t3ObtCteBl/Ti
 6wHcexhERXfaCO2N91VtFikhDA3IBPVaavMtO5VFDoPk7oZZ4itntHgzDpbiOtu2yehsTOqnJ2h
 UYzd2STOmRil732Vs9LTHyPZyDgPENOPiIT5HErNZ1Qk7upL9iLxRFEx7R6SmGvHFWZ1/k582hD
 VB6VNJtvCDC6k8VeWTaZPZ2eBm4kPYmHrbdDFe9y44qnCzZvPv/R9z/W0ctZFsbUvT36RdBZvsL
 11nBBycztLm5O2CmV9q4hEM/19oC1IP+Zh55NfZgkOVrPj/ukAhs2Bxk3qvdm81EzebOdd/vOWf
 PGiEY+BUZnAflnxNHtLLP3wbdPb2RNFI+9XYKAplKsGPVMoP6cbB4mLyolmIqLh68u5QZjG8hj0
 7zoHBDAKujlcrK3FcXk2dl1ds0lIfWBzskjFmimX34YPAQYhfBaB4s1XBH6VxbW23J58fm6gCpt
 HHTydn7cCmWrHSl6Z4dKw6YcGoogH2BlKQgErHONMCHUMsX0Q0Ijt7LlwX5JXQ/Pru58dszTAA4
 Mx3y8gIKFFkxA0N0fFtB/ZKIEyv7F7URM7FDUWEB2XCy5MbgkjXiTAmbIXt3iEcHKhZDumVsGZw
 jN09FIoMKNIx0aw==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

check_security_flavor() serves NFSv2, NFSv3, NFSv4, and
NLM requests, and calls nfsd4_spo_must_allow() on a flavor
mismatch. nfsd4_spo_must_allow() casts rq_resp and rq_argp to NFSv4
COMPOUND structures and relies on an rq_procinfo comparison to reject
other requests. nfsd4_spo_must_allow() also scans the rest of the
COMPOUND and caches a match, so one spo_must_allow operation exempts
every filehandle the COMPOUND uses.

RFC 8881 Section 2.6.3.1.1.7 requires the put filehandle
operation to return NFS4ERR_WRONGSEC on a security tuple mismatch
and forbids NFS4ERR_WRONGSEC from most of the operations that
follow. Apply the SP4_MACH_CRED rule in the deferred WRONGSEC check in
nfsd4_proc_compound(), and set fh_spo_allowed in the current filehandle
when the rule applies. Stop the scan at the next put filehandle
operation or operation that handles NFS4ERR_WRONGSEC itself, skip
operations that do not use the current filehandle, and remove the cache
and the rq_procinfo comparison.

Skip the flavor check in __fh_verify() for a filehandle with
fh_spo_allowed set. Because the flavor check is per export, have
fh_compose() copy fh_spo_allowed only to a filehandle in the same
export. nfsd4_verify_copy() checks the source export without calling
__fh_verify(), so test fh_spo_allowed there too. Clear fh_spo_allowed
in the saved filehandle when a put filehandle operation starts a new
subseries, so the exemption does not reach a LINK, RENAME, COPY, or
CLONE in a later subseries.

RFC 8881 Section 18.35.3 grants the machine credential only to
spo_must_allow operations. Clear fh_spo_allowed before dispatching an
operation that handles NFS4ERR_WRONGSEC itself, such as LOOKUP, LOOKUPP,
or OPEN by component name, so that operation's flavor check ignores any
earlier deferred check.

After the change, one spo_must_allow operation exempts the filehandles
of one subseries instead of every filehandle the COMPOUND uses. The
exemption is still broader than Section 18.35.3 permits. __fh_verify()
skips the flavor check for every operation that uses a filehandle with
fh_spo_allowed set, so in a COMPOUND of PUTFH, WRITE, CLOSE the WRITE
is exempt too.

Fixes: ed94164398c9 ("nfsd: implement machine credential support for some operations")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/export.c   | 13 ++------
 fs/nfsd/nfs4ctl.h  |  5 ----
 fs/nfsd/nfs4proc.c | 88 ++++++++++++++++++++++++++++++++++++++++--------------
 fs/nfsd/nfsfh.c    |  9 +++++-
 fs/nfsd/nfsfh.h    |  1 +
 fs/nfsd/xdr4.h     |  1 -
 6 files changed, 76 insertions(+), 41 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index d952fdde7314..f8a9bfbf652f 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -2013,8 +2013,8 @@ __be32 check_xprtsec_policy(struct svc_export *exp, struct svc_rqst *rqstp)
  *
  * Helper function for check_nfsd_access().  Note that callers should be
  * using check_nfsd_access() instead of calling this function directly.  The
- * one exception is __fh_verify() since it has logic that may result in one
- * or both of the helpers being skipped.
+ * exceptions are __fh_verify(), which can skip one or both helpers, and
+ * nfsd4_check_putfh_access(), which can override a flavor mismatch.
  *
  * Return values:
  *   %nfs_ok if access is granted, or
@@ -2040,15 +2040,6 @@ __be32 check_security_flavor(struct svc_export *exp, struct svc_rqst *rqstp,
 			return nfs_ok;
 	}
 
-	/* If the compound op contains a spo_must_allowed op,
-	 * it will be sent with integrity/protection which
-	 * will have to be expressly allowed on mounts that
-	 * don't support it
-	 */
-
-	if (nfsd4_spo_must_allow(rqstp))
-		return nfs_ok;
-
 	/* Some calls may be processed without authentication
 	 * on GSS exports. For example NFS2/3 calls on root
 	 * directory, see section 2.3.2 of rfc 2623.
diff --git a/fs/nfsd/nfs4ctl.h b/fs/nfsd/nfs4ctl.h
index e0d1246ca337..22af2ef54c96 100644
--- a/fs/nfsd/nfs4ctl.h
+++ b/fs/nfsd/nfs4ctl.h
@@ -31,7 +31,6 @@ int nfs4_state_start(void);
 int nfs4_state_start_net(struct net *net);
 void nfs4_state_shutdown(void);
 void nfs4_state_shutdown_net(struct net *net);
-bool nfsd4_spo_must_allow(struct svc_rqst *rqstp);
 int nfsd4_create_laundry_wq(void);
 void nfsd4_destroy_laundry_wq(void);
 bool nfsd_wait_for_delegreturn(struct svc_rqst *rqstp, struct inode *inode);
@@ -52,10 +51,6 @@ static inline int nfs4_state_start(void) { return 0; }
 static inline int nfs4_state_start_net(struct net *net) { return 0; }
 static inline void nfs4_state_shutdown(void) { }
 static inline void nfs4_state_shutdown_net(struct net *net) { }
-static inline bool nfsd4_spo_must_allow(struct svc_rqst *rqstp)
-{
-	return false;
-}
 static inline int nfsd4_create_laundry_wq(void) { return 0; };
 static inline void nfsd4_destroy_laundry_wq(void) {};
 static inline bool nfsd_wait_for_delegreturn(struct svc_rqst *rqstp,
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index bd08f7b5181d..71d6a473c1bc 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1545,7 +1545,9 @@ nfsd4_verify_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		return nfserr_nofilehandle;
 
 	/* A cached open stateid does not authorize the saved source export. */
-	status = check_nfsd_access(cstate->save_fh.fh_export, rqstp, 0);
+	status = check_nfsd_access(cstate->save_fh.fh_export, rqstp,
+				   cstate->save_fh.fh_spo_allowed ?
+				   NFSD_MAY_BYPASS_FLAVOR : 0);
 	if (status)
 		return status == nfserr_wrongsec ? nfserr_acces : status;
 	crossed = cstate->save_fh.fh_export != cstate->current_fh.fh_export;
@@ -3324,6 +3326,13 @@ static bool open_handles_wrongsec(const struct nfsd4_op *op)
 	}
 }
 
+static bool op_handles_wrongsec(const struct nfsd4_op *op)
+{
+	if (op->opnum == OP_OPEN)
+		return open_handles_wrongsec(op);
+	return op->opdesc->op_flags & OP_HANDLES_WRONGSEC;
+}
+
 static bool need_wrongsec_check(struct svc_rqst *rqstp)
 {
 	struct nfsd4_compoundres *resp = rqstp->rq_resp;
@@ -3331,7 +3340,6 @@ static bool need_wrongsec_check(struct svc_rqst *rqstp)
 	struct nfsd4_op *this = &argp->ops[resp->opcnt - 1];
 	struct nfsd4_op *next = NULL;
 	const struct nfsd4_operation *thisd = OPDESC(this);
-	const struct nfsd4_operation *nextd;
 	unsigned int i;
 
 	/* Only put-filehandle operations need a deferred WRONGSEC check. */
@@ -3361,16 +3369,34 @@ static bool need_wrongsec_check(struct svc_rqst *rqstp)
 	 */
 	if (resp->cstate.minorversion == 0 && next->opnum == OP_SECINFO)
 		return true;
-	if (next->opnum == OP_OPEN)
-		return !open_handles_wrongsec(next);
-	nextd = OPDESC(next);
 	/*
 	 * RFC 8881 Section 2.6.3.1.1.2: a later put-filehandle operation
 	 * replaces this one. Other marked operations check WRONGSEC
 	 * themselves.
 	 */
-	return !(nextd->op_flags &
-		  (OP_HANDLES_WRONGSEC | OP_IS_PUTFH_LIKE));
+	return !op_handles_wrongsec(next) &&
+	       !(next->opdesc->op_flags & OP_IS_PUTFH_LIKE);
+}
+
+static bool nfsd4_spo_must_allow(struct svc_rqst *rqstp);
+
+static __be32 nfsd4_check_putfh_access(struct svc_rqst *rqstp)
+{
+	struct nfsd4_compoundres *resp = rqstp->rq_resp;
+	struct svc_fh *fhp = &resp->cstate.current_fh;
+	__be32 status;
+
+	status = check_nfsd_access(fhp->fh_export, rqstp,
+				   NFSD_MAY_BYPASS_FLAVOR);
+	if (status != nfs_ok)
+		return status;
+	status = check_security_flavor(fhp->fh_export, rqstp, false);
+	if (status != nfserr_wrongsec || !nfsd4_spo_must_allow(rqstp))
+		return status;
+
+	/* The machine credential's flavor can be absent from the sec= list. */
+	fhp->fh_spo_allowed = true;
+	return nfs_ok;
 }
 
 #ifdef CONFIG_NFSD_V4_2_INTER_SSC
@@ -3537,6 +3563,17 @@ nfsd4_proc_compound(struct svc_rqst *rqstp)
 		if (op->status)
 			goto encode_op;
 
+		/*
+		 * The SP4_MACH_CRED exception does not extend to an operation
+		 * that checks the export's sec= list itself.
+		 */
+		if (op_handles_wrongsec(op))
+			current_fh->fh_spo_allowed = false;
+
+		/* A new subseries ends the saved filehandle's exemption. */
+		if (op->opdesc->op_flags & OP_IS_PUTFH_LIKE)
+			cstate->save_fh.fh_spo_allowed = false;
+
 		if (op->opdesc->op_get_currentstateid)
 			op->opdesc->op_get_currentstateid(cstate, &op->u);
 		op->status = op->opdesc->op_func(rqstp, cstate, &op->u);
@@ -3557,8 +3594,7 @@ nfsd4_proc_compound(struct svc_rqst *rqstp)
 
 			if (current_fh->fh_export &&
 					need_wrongsec_check(rqstp)) {
-				op->status = check_nfsd_access(current_fh->fh_export,
-							       rqstp, 0);
+				op->status = nfsd4_check_putfh_access(rqstp);
 				/* READ with a stateid does not call fh_verify(). */
 				if (!op->status)
 					svc_xprt_set_valid(rqstp->rq_xprt);
@@ -4405,16 +4441,20 @@ static const struct nfsd4_operation nfsd4_ops[] = {
 };
 
 /**
- * nfsd4_spo_must_allow - Determine if the compound op contains an
+ * nfsd4_spo_must_allow - Determine if the current subseries contains an
  * operation that is allowed to be sent with machine credentials
  *
- * @rqstp: a pointer to the struct svc_rqst
+ * @rqstp: an NFSv4 COMPOUND request that nfsd4_proc_compound() is processing
  *
- * Checks to see if the compound contains a spo_must_allow op
- * and confirms that it was sent with the proper machine creds.
+ * Checks whether the operations after the current one, up to the next operation
+ * that replaces the current filehandle, include a spo_must_allow op that uses
+ * the current filehandle.
+ *
+ * Return: %true if such an operation is present and @rqstp carries the client's
+ * machine credential, otherwise %false.
  */
 
-bool nfsd4_spo_must_allow(struct svc_rqst *rqstp)
+static bool nfsd4_spo_must_allow(struct svc_rqst *rqstp)
 {
 	struct nfsd4_compoundres *resp = rqstp->rq_resp;
 	struct nfsd4_compoundargs *argp = rqstp->rq_argp;
@@ -4423,26 +4463,28 @@ bool nfsd4_spo_must_allow(struct svc_rqst *rqstp)
 	struct nfs4_op_map *allow;
 	u32 opiter;
 
-	if (rqstp->rq_procinfo != &nfsd_version4.vs_proc[NFSPROC4_COMPOUND] ||
-	    cstate->minorversion == 0)
+	if (cstate->minorversion == 0)
 		return false;
 
-	if (cstate->spo_must_allowed)
-		return true;
-
 	allow = &cstate->clp->cl_spo_must_allow;
 	opiter = resp->opcnt;
 	while (opiter < argp->opcnt) {
 		this = &argp->ops[opiter++];
+		/* Later operations use the filehandle this one sets. */
+		if (this->opdesc &&
+		    ((this->opdesc->op_flags & OP_IS_PUTFH_LIKE) ||
+		     op_handles_wrongsec(this)))
+			break;
+		/* Only an operation that uses the filehandle can exempt it. */
+		if (this->opdesc &&
+		    (this->opdesc->op_flags & ALLOWED_WITHOUT_FH))
+			continue;
 		if (this->opnum <= LAST_NFS4_OP &&
 		    test_bit(this->opnum, allow->u.longs) &&
 		    cstate->clp->cl_mach_cred &&
-		    nfsd4_mach_creds_match(cstate->clp, rqstp)) {
-			cstate->spo_must_allowed = true;
+		    nfsd4_mach_creds_match(cstate->clp, rqstp))
 			return true;
-		}
 	}
-	cstate->spo_must_allowed = false;
 	return false;
 }
 
diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index 6f85701cbe8b..9faecec08d6f 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -499,7 +499,7 @@ __fh_verify(struct svc_rqst *rqstp,
 		may_bypass_gss = true;
 
 	/* The xprtsec= policy applies even when the flavor check is bypassed. */
-	if (!(access & NFSD_MAY_BYPASS_FLAVOR)) {
+	if (!(access & NFSD_MAY_BYPASS_FLAVOR) && !fhp->fh_spo_allowed) {
 		error = check_security_flavor(exp, rqstp, may_bypass_gss);
 		if (error)
 			goto out;
@@ -709,6 +709,7 @@ fh_compose(struct svc_fh *fhp, struct svc_export *exp, struct dentry *dentry,
 
 	struct inode * inode = d_inode(dentry);
 	dev_t ex_dev = exp_sb(exp)->s_dev;
+	bool spo_allowed;
 
 	dprintk("nfsd: fh_compose(exp %02x:%02x/%llu %pd2, ino=%llu)\n",
 		MAJOR(ex_dev), MINOR(ex_dev),
@@ -725,8 +726,13 @@ fh_compose(struct svc_fh *fhp, struct svc_export *exp, struct dentry *dentry,
 	/* If we have a ref_fh, then copy the fh_no_wcc setting from it. */
 	fhp->fh_no_wcc = ref_fh ? ref_fh->fh_no_wcc : false;
 
+	/* The sec= check is per export, so its result holds for @fhp too. */
+	spo_allowed = ref_fh && ref_fh->fh_export == exp &&
+		      ref_fh->fh_spo_allowed;
+
 	if (ref_fh == fhp)
 		fh_put(ref_fh);
+	fhp->fh_spo_allowed = spo_allowed;
 
 	if (fhp->fh_dentry) {
 		printk(KERN_ERR "fh_compose: fh %pd2 not initialized!\n",
@@ -914,6 +920,7 @@ fh_put(struct svc_fh *fhp)
 		fhp->fh_export = NULL;
 	}
 	fhp->fh_no_wcc = false;
+	fhp->fh_spo_allowed = false;
 	return;
 }
 
diff --git a/fs/nfsd/nfsfh.h b/fs/nfsd/nfsfh.h
index 51788712d630..f62d75fa4c02 100644
--- a/fs/nfsd/nfsfh.h
+++ b/fs/nfsd/nfsfh.h
@@ -93,6 +93,7 @@ typedef struct svc_fh {
 						 */
 	bool			fh_use_wgather;	/* NFSv2 wgather option */
 	bool			fh_64bit_cookies;/* readdir cookie size */
+	bool			fh_spo_allowed;	/* SP4_MACH_CRED skips sec= */
 	int			fh_flags;	/* FH flags */
 	bool			fh_post_saved;	/* post-op attrs saved */
 	bool			fh_pre_saved;	/* pre-op attrs saved */
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 9c31e9172ad7..28481a2c8285 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -61,7 +61,6 @@ struct nfsd4_compound_state {
 	struct nfsd4_session	*session;
 	struct nfsd4_slot	*slot;
 	int			data_offset;
-	bool                    spo_must_allowed;
 	bool			slot_owned;
 	size_t			iovlen;
 	u32			minorversion;

-- 
2.56.0


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:57449 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754892Ab1DJQ3j (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 10 Apr 2011 12:29:39 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Cc: Bryan Schumaker <bjschuma@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 5/5] nfsd4: fix wrongsec handling for PUTFH + op cases
Date: Sun, 10 Apr 2011 12:29:33 -0400
Message-Id: <1302452973-27272-5-git-send-email-bfields@redhat.com>
In-Reply-To: <20110410162536.GC26233@fieldses.org>
References: <20110410162536.GC26233@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

When PUTFH is followed by an operation that uses the filehandle, and
when the current client is using a security flavor that is inconsistent
with the given filehandle, we have a choice: we can return WRONGSEC
either when the current filehandle is set using the PUTFH, or when the
filehandle is first used by the following operation.

Follow the recommendations of RFC 5661 in making this choice.

(Our current behavior prevented the client from doing security
negotiation by returning WRONGSEC on SECINFO.)

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/export.c   |    6 -----
 fs/nfsd/nfs4proc.c |   57 ++++++++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 49 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index ad000ae..b9566e4 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -1354,12 +1354,6 @@ exp_pseudoroot(struct svc_rqst *rqstp, struct svc_fh *fhp)
 	if (IS_ERR(exp))
 		return nfserrno(PTR_ERR(exp));
 	rv = fh_compose(fhp, exp, exp->ex_path.dentry, NULL);
-	if (rv)
-		goto out;
-	rv = check_nfsd_access(exp, rqstp);
-	if (rv)
-		fh_put(fhp);
-out:
 	exp_put(exp);
 	return rv;
 }
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 8059ada..c7d0b1e 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -403,7 +403,7 @@ nfsd4_putfh(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	cstate->current_fh.fh_handle.fh_size = putfh->pf_fhlen;
 	memcpy(&cstate->current_fh.fh_handle.fh_base, putfh->pf_fhval,
 	       putfh->pf_fhlen);
-	return fh_verify(rqstp, &cstate->current_fh, 0, NFSD_MAY_NOP);
+	return fh_verify(rqstp, &cstate->current_fh, 0, NFSD_MAY_BYPASS_GSS);
 }
 
 static __be32
@@ -762,9 +762,6 @@ nfsd4_secinfo(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	__be32 err;
 
 	fh_init(&resfh, NFS4_FHSIZE);
-	err = fh_verify(rqstp, &cstate->current_fh, S_IFDIR, NFSD_MAY_EXEC);
-	if (err)
-		return err;
 	err = nfsd_lookup_dentry(rqstp, &cstate->current_fh,
 				    secinfo->si_name, secinfo->si_namelen,
 				    &exp, &dentry);
@@ -989,6 +986,9 @@ enum nfsd4_op_flags {
 	ALLOWED_WITHOUT_FH = 1 << 0,	/* No current filehandle required */
 	ALLOWED_ON_ABSENT_FS = 1 << 1,	/* ops processed on absent fs */
 	ALLOWED_AS_FIRST_OP = 1 << 2,	/* ops reqired first in compound */
+	/* For rfc 5661 section 2.6.3.1.1: */
+	OP_HANDLES_WRONGSEC = 1 << 3,
+	OP_IS_PUTFH_LIKE = 1 << 4,
 };
 
 struct nfsd4_operation {
@@ -1039,6 +1039,34 @@ static inline struct nfsd4_operation *OPDESC(struct nfsd4_op *op)
 	return &nfsd4_ops[op->opnum];
 }
 
+static bool need_wrongsec_check(struct svc_rqst *rqstp)
+{
+	struct nfsd4_compoundres *resp = rqstp->rq_resp;
+	struct nfsd4_compoundargs *argp = rqstp->rq_argp;
+	struct nfsd4_op *this = &argp->ops[resp->opcnt - 1];
+	struct nfsd4_op *next = &argp->ops[resp->opcnt];
+	struct nfsd4_operation *thisd;
+	struct nfsd4_operation *nextd;
+
+	/*
+	 * rfc 5661 2.6.3.1.1.6: don't bother erroring out a
+	 * put-filehandle operation if we're not going to use the
+	 * result:
+	 */
+	if (argp->opcnt == resp->opcnt)
+		return false;
+
+	thisd = OPDESC(this);
+	nextd = OPDESC(next);
+	/*
+	 * Rest of 2.6.3.1.1: certain operations will return WRONGSEC
+	 * errors themselves as necessary; others should check for them
+	 * now:
+	 */
+	return thisd->op_flags & OP_IS_PUTFH_LIKE
+		&& !(nextd->op_flags & OP_HANDLES_WRONGSEC);
+}
+
 /*
  * COMPOUND call.
  */
@@ -1134,6 +1162,9 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 		else
 			BUG_ON(op->status == nfs_ok);
 
+		if (!op->status && need_wrongsec_check(rqstp))
+			op->status = check_nfsd_access(cstate->current_fh.fh_export, rqstp);
+
 encode_op:
 		/* Only from SEQUENCE */
 		if (resp->cstate.status == nfserr_replay_cache) {
@@ -1225,10 +1256,12 @@ static struct nfsd4_operation nfsd4_ops[] = {
 	},
 	[OP_LOOKUP] = {
 		.op_func = (nfsd4op_func)nfsd4_lookup,
+		.op_flags = OP_HANDLES_WRONGSEC,
 		.op_name = "OP_LOOKUP",
 	},
 	[OP_LOOKUPP] = {
 		.op_func = (nfsd4op_func)nfsd4_lookupp,
+		.op_flags = OP_HANDLES_WRONGSEC,
 		.op_name = "OP_LOOKUPP",
 	},
 	[OP_NVERIFY] = {
@@ -1237,6 +1270,7 @@ static struct nfsd4_operation nfsd4_ops[] = {
 	},
 	[OP_OPEN] = {
 		.op_func = (nfsd4op_func)nfsd4_open,
+		.op_flags = OP_HANDLES_WRONGSEC,
 		.op_name = "OP_OPEN",
 	},
 	[OP_OPEN_CONFIRM] = {
@@ -1249,17 +1283,20 @@ static struct nfsd4_operation nfsd4_ops[] = {
 	},
 	[OP_PUTFH] = {
 		.op_func = (nfsd4op_func)nfsd4_putfh,
-		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS,
+		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS
+				| OP_IS_PUTFH_LIKE,
 		.op_name = "OP_PUTFH",
 	},
 	[OP_PUTPUBFH] = {
 		.op_func = (nfsd4op_func)nfsd4_putrootfh,
-		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS,
+		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS
+				| OP_IS_PUTFH_LIKE,
 		.op_name = "OP_PUTPUBFH",
 	},
 	[OP_PUTROOTFH] = {
 		.op_func = (nfsd4op_func)nfsd4_putrootfh,
-		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS,
+		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS
+				| OP_IS_PUTFH_LIKE,
 		.op_name = "OP_PUTROOTFH",
 	},
 	[OP_READ] = {
@@ -1289,15 +1326,18 @@ static struct nfsd4_operation nfsd4_ops[] = {
 	},
 	[OP_RESTOREFH] = {
 		.op_func = (nfsd4op_func)nfsd4_restorefh,
-		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS,
+		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS
+				| OP_IS_PUTFH_LIKE,
 		.op_name = "OP_RESTOREFH",
 	},
 	[OP_SAVEFH] = {
 		.op_func = (nfsd4op_func)nfsd4_savefh,
+		.op_flags = OP_HANDLES_WRONGSEC,
 		.op_name = "OP_SAVEFH",
 	},
 	[OP_SECINFO] = {
 		.op_func = (nfsd4op_func)nfsd4_secinfo,
+		.op_flags = OP_HANDLES_WRONGSEC,
 		.op_name = "OP_SECINFO",
 	},
 	[OP_SETATTR] = {
@@ -1361,6 +1401,7 @@ static struct nfsd4_operation nfsd4_ops[] = {
 	},
 	[OP_SECINFO_NO_NAME] = {
 		.op_func = (nfsd4op_func)nfsd4_secinfo_no_name,
+		.op_flags = OP_HANDLES_WRONGSEC,
 		.op_name = "OP_SECINFO_NO_NAME",
 	},
 };
-- 
1.7.1


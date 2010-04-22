From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 1/2] nfsd4: complete enforcement of 4.1 op ordering
Date: Thu, 22 Apr 2010 10:32:23 -0400
Message-ID: <1271946744-5877-1-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48712 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754466Ab0DVOcY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Apr 2010 10:32:24 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Enforce the rules about compound op ordering.

Motivated by implementing RECLAIM_COMPLETE, for which the client is
implicit in the current session, so it is important to ensure a
succesful SEQUENCE proceeds the RECLAIM_COMPLETE.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4proc.c  |   44 ++++++++++++++++++++++++++++++--------------
 fs/nfsd/nfs4state.c |   13 +++++++++++++
 2 files changed, 43 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 37514c4..e147dbc 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -968,20 +968,36 @@ static struct nfsd4_operation nfsd4_ops[];
 static const char *nfsd4_op_name(unsigned opnum);
 
 /*
- * Enforce NFSv4.1 COMPOUND ordering rules.
+ * Enforce NFSv4.1 COMPOUND ordering rules:
  *
- * TODO:
- * - enforce NFS4ERR_NOT_ONLY_OP,
- * - DESTROY_SESSION MUST be the final operation in the COMPOUND request.
+ * Also note, enforced elsewhere:
+ *	- SEQUENCE other than as first op results in
+ *	  NFS4ERR_SEQUENCE_POS. (Enforced in nfsd4_sequence().)
+ *	- BIND_CONN_TO_SESSION must be the only op in its compound
+ *	  (Will be enforced in nfsd4_bind_conn_to_session().)
+ *	- DESTROY_SESSION must be the final operation in a compound, if
+ *	  sessionid's in SEQUENCE and DESTROY_SESSION are the same.
+ *	  (Enforced in nfsd4_destroy_session().)
  */
-static bool nfs41_op_ordering_ok(struct nfsd4_compoundargs *args)
+static __be32 nfs41_check_op_ordering(struct nfsd4_compoundargs *args)
 {
-	if (args->minorversion && args->opcnt > 0) {
-		struct nfsd4_op *op = &args->ops[0];
-		return (op->status == nfserr_op_illegal) ||
-		       (nfsd4_ops[op->opnum].op_flags & ALLOWED_AS_FIRST_OP);
-	}
-	return true;
+	struct nfsd4_op *op = &args->ops[0];
+
+	/* These ordering requirements don't apply to NFSv4.0: */
+	if (args->minorversion == 0)
+		return nfs_ok;
+	/* This is weird, but OK, not our problem: */
+	if (args->opcnt == 0)
+		return nfs_ok;
+	if (op->status == nfserr_op_illegal)
+		return nfs_ok;
+	if (!(nfsd4_ops[op->opnum].op_flags & ALLOWED_AS_FIRST_OP))
+		return nfserr_op_not_in_session;
+	if (op->opnum == OP_SEQUENCE)
+		return nfs_ok;
+	if (args->opcnt != 1)
+		return nfserr_not_only_op;
+	return nfs_ok;
 }
 
 /*
@@ -1023,13 +1039,13 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 	if (args->minorversion > nfsd_supported_minorversion)
 		goto out;
 
-	if (!nfs41_op_ordering_ok(args)) {
+	status = nfs41_check_op_ordering(args);
+	if (status) {
 		op = &args->ops[0];
-		op->status = nfserr_sequence_pos;
+		op->status = status;
 		goto encode_op;
 	}
 
-	status = nfs_ok;
 	while (!status && resp->opcnt < args->opcnt) {
 		op = &args->ops[resp->opcnt++];
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 5051ade..e444829 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1365,6 +1365,14 @@ out:
 	return status;
 }
 
+static bool nfsd4_last_compound_op(struct svc_rqst *rqstp)
+{
+	struct nfsd4_compoundres *resp = rqstp->rq_resp;
+	struct nfsd4_compoundargs *argp = rqstp->rq_argp;
+
+	return argp->opcnt == resp->opcnt;
+}
+
 __be32
 nfsd4_destroy_session(struct svc_rqst *r,
 		      struct nfsd4_compound_state *cstate,
@@ -1380,6 +1388,11 @@ nfsd4_destroy_session(struct svc_rqst *r,
 	 * - Do we need to clear any callback info from previous session?
 	 */
 
+	if (!memcmp(&sessionid->sessionid, &cstate->session->se_sessionid,
+					sizeof(struct nfs4_sessionid))) {
+		if (!nfsd4_last_compound_op(r))
+			return nfserr_not_only_op;
+	}
 	dump_sessionid(__func__, &sessionid->sessionid);
 	spin_lock(&sessionid_lock);
 	ses = find_in_sessionid_hashtbl(&sessionid->sessionid);
-- 
1.6.3.3


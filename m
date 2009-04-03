From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v3 13/35] nfsd41: enforce NFS4ERR_SEQUENCE_POS operation order rules for minorversion != 0 only.
Date: Fri,  3 Apr 2009 08:28:12 +0300
Message-ID: <1238736492-17483-1-git-send-email-bhalevy@panasas.com>
References: <49D599EA.6060705@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:24626 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755199AbZDCF2R (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Apr 2009 01:28:17 -0400
In-Reply-To: <49D599EA.6060705@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson<andros@netapp.com>
[nfsd41: do not verify nfserr_sequence_pos for minorversion 0]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4proc.c  |   40 ++++++++++++++++++++++++++++++++--------
 fs/nfsd/nfs4state.c |    4 ++++
 2 files changed, 36 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index f7be7fa..ec51936 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -811,14 +811,15 @@ static inline void nfsd4_increment_op_stats(u32 opnum)
 
 typedef __be32(*nfsd4op_func)(struct svc_rqst *, struct nfsd4_compound_state *,
 			      void *);
+enum nfsd4_op_flags {
+	ALLOWED_WITHOUT_FH = 1 << 0,	/* No current filehandle required */
+	ALLOWED_ON_ABSENT_FS = 2 << 0,	/* ops processed on absent fs */
+	ALLOWED_AS_FIRST_OP = 3 << 0,	/* ops reqired first in compound */
+};
 
 struct nfsd4_operation {
 	nfsd4op_func op_func;
 	u32 op_flags;
-/* Most ops require a valid current filehandle; a few don't: */
-#define ALLOWED_WITHOUT_FH 1
-/* GETATTR and ops not listed as returning NFS4ERR_MOVED: */
-#define ALLOWED_ON_ABSENT_FS 2
 	char *op_name;
 };
 
@@ -827,6 +828,23 @@ static struct nfsd4_operation nfsd4_ops[];
 static const char *nfsd4_op_name(unsigned opnum);
 
 /*
+ * Enforce NFSv4.1 COMPOUND ordering rules.
+ *
+ * TODO:
+ * - enforce NFS4ERR_NOT_ONLY_OP,
+ * - DESTROY_SESSION MUST be the final operation in the COMPOUND request.
+ */
+static bool nfs41_op_ordering_ok(struct nfsd4_compoundargs *args)
+{
+	if (args->minorversion && args->opcnt > 0) {
+		struct nfsd4_op *op = &args->ops[0];
+		return (op->status == nfserr_op_illegal) ||
+		       (nfsd4_ops[op->opnum].op_flags & ALLOWED_AS_FIRST_OP);
+	}
+	return true;
+}
+
+/*
  * COMPOUND call.
  */
 static __be32
@@ -864,6 +882,12 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 	if (args->minorversion > NFSD_SUPPORTED_MINOR_VERSION)
 		goto out;
 
+	if (!nfs41_op_ordering_ok(args)) {
+		op = &args->ops[0];
+		op->status = nfserr_sequence_pos;
+		goto encode_op;
+	}
+
 	status = nfs_ok;
 	while (!status && resp->opcnt < args->opcnt) {
 		op = &args->ops[resp->opcnt++];
@@ -1105,22 +1129,22 @@ static struct nfsd4_operation nfsd4_ops[] = {
 	/* NFSv4.1 operations */
 	[OP_EXCHANGE_ID] = {
 		.op_func = (nfsd4op_func)nfsd4_exchange_id,
-		.op_flags = ALLOWED_WITHOUT_FH,
+		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_AS_FIRST_OP,
 		.op_name = "OP_EXCHANGE_ID",
 	},
 	[OP_CREATE_SESSION] = {
 		.op_func = (nfsd4op_func)nfsd4_create_session,
-		.op_flags = ALLOWED_WITHOUT_FH,
+		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_AS_FIRST_OP,
 		.op_name = "OP_CREATE_SESSION",
 	},
 	[OP_DESTROY_SESSION] = {
 		.op_func = (nfsd4op_func)nfsd4_destroy_session,
-		.op_flags = ALLOWED_WITHOUT_FH,
+		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_AS_FIRST_OP,
 		.op_name = "OP_DESTROY_SESSION",
 	},
 	[OP_SEQUENCE] = {
 		.op_func = (nfsd4op_func)nfsd4_sequence,
-		.op_flags = ALLOWED_WITHOUT_FH,
+		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_AS_FIRST_OP,
 		.op_name = "OP_SEQUENCE",
 	},
 };
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 24b6e05..9243dca 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1047,10 +1047,14 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 	       struct nfsd4_compound_state *cstate,
 	       struct nfsd4_sequence *seq)
 {
+	struct nfsd4_compoundres *resp = rqstp->rq_resp;
 	struct nfsd4_session *session;
 	struct nfsd4_slot *slot;
 	int status;
 
+	if (resp->opcnt != 1)
+		return nfserr_sequence_pos;
+
 	spin_lock(&sessionid_lock);
 	status = nfserr_badsession;
 	session = find_in_sessionid_hashtbl(&seq->sessionid);
-- 
1.6.2.1


From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 19/47] nfsd41: enforce NFS4ERR_SEQUENCE_POS operation order rules
Date: Fri, 27 Mar 2009 06:15:52 +0300
Message-ID: <1238123752-7546-1-git-send-email-bhalevy@panasas.com>
References: <49CC40E5.2080506@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:24523 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755536AbZC0DP6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Mar 2009 23:15:58 -0400
In-Reply-To: <49CC40E5.2080506@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4proc.c  |   24 ++++++++++++++++--------
 fs/nfsd/nfs4state.c |    4 ++++
 2 files changed, 20 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index f618e8e..e703ac2 100644
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
 
@@ -864,6 +865,13 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 	if (args->minorversion > NFSD_SUPPORTED_MINOR_VERSION)
 		goto out;
 
+	op = &args->ops[0];
+	if (args->opcnt > 0 && op->status != nfserr_op_illegal &&
+	    !(nfsd4_ops[op->opnum].op_flags & ALLOWED_AS_FIRST_OP)) {
+		op->status = nfserr_sequence_pos;
+		goto encode_op;
+	}
+
 	status = nfs_ok;
 	while (!status && resp->opcnt < args->opcnt) {
 		op = &args->ops[resp->opcnt++];
@@ -1104,22 +1112,22 @@ static struct nfsd4_operation nfsd4_ops[] = {
 #if defined(CONFIG_NFSD_V4_1)
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
 #endif /* CONFIG_NFSD_V4_1 */
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a19f292..10eb67b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1051,10 +1051,14 @@ nfsd4_sequence(struct svc_rqst *rqstp,
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


From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 47/51] nfsd41: enforce NFS4ERR_SEQUENCE_POS operation order rules
Date: Mon, 10 Nov 2008 22:56:50 +0200
Message-ID: <1226350610-11887-1-git-send-email-bhalevy@panasas.com>
References: <491895A0.3040809@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:44363 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751640AbYKJU5F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:57:05 -0500
In-Reply-To: <491895A0.3040809@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4proc.c |   30 ++++++++++++++++++++++--------
 1 files changed, 22 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index eaebe5b..4a6ec7e 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -914,14 +914,18 @@ nfsd4_save_deferred_state(struct svc_rqst *rqstp,
 
 typedef __be32(*nfsd4op_func)(struct svc_rqst *, struct nfsd4_compound_state *,
 			      void *);
+enum nfsd4_op_flags {
+/* Most ops require a valid current filehandle; a few don't: */
+	ALLOWED_WITHOUT_FH = 1 << 0,
+/* GETATTR and ops not listed as returning NFS4ERR_MOVED: */
+	ALLOWED_ON_ABSENT_FS = 2 << 0,
+/* NFSv4.1 insists on some operations being first in a compound. */
+	ALLOWED_AS_FIRST_OP = 3 << 0,
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
 
@@ -1037,6 +1041,16 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 			op->status = nfserr_moved;
 			goto encode_op;
 		}
+#ifdef CONFIG_NFSD_V4_1
+		if (resp->minorversion == 1) {
+			if ((resp->opcnt == 1 &&
+			    !(opdesc->op_flags & ALLOWED_AS_FIRST_OP)) ||
+			    (resp->opcnt > 1 && (op->opnum == OP_SEQUENCE))) {
+				op->status = nfserr_sequence_pos;
+				goto encode_op;
+			}
+		}
+#endif /* CONFIG_NFSD_V4_1 */
 
 		if (opdesc->op_func)
 			op->status = opdesc->op_func(rqstp, cstate, &op->u);
@@ -1261,22 +1275,22 @@ static struct nfsd4_operation nfsd4_ops[NFSD4_LAST_OP+1] = {
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
-- 
1.6.0.2


From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 1/2] SQUASHME: nfsd41: do not verify nfserr_sequence_pos for minorversion 0
Date: Sat, 28 Mar 2009 21:33:49 +0300
Message-ID: <1238265229-17223-1-git-send-email-bhalevy@panasas.com>
References: <49CE6D27.8020601@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:16501 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752974AbZC1Seu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 Mar 2009 14:34:50 -0400
In-Reply-To: <49CE6D27.8020601@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

squash into "nfsd41: enforce NFS4ERR_SEQUENCE_POS operation order rules"

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4proc.c |   17 ++++++++++++++---
 1 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 6d7d7c5..20583ab 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -894,6 +894,18 @@ nfsd4_enc_no_page_replay(struct nfsd4_compoundargs *args,
 	return op->status;
 }
 
+static bool nfs41_op_ordering_ok(struct nfsd4_compoundargs *args)
+{
+#if defined(CONFIG_NFSD_V4_1)
+	if (args->minorversion && args->opcnt > 0) {
+		struct nfsd4_op *op = &args->ops[0];
+		return (op->status == nfserr_op_illegal) ||
+		       (nfsd4_ops[op->opnum].op_flags & ALLOWED_AS_FIRST_OP);
+	}
+#endif /* CONFIG_NFSD_V4_1 */
+	return true;
+}
+
 /*
  * COMPOUND call.
  */
@@ -933,9 +945,8 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 	if (args->minorversion > NFSD_SUPPORTED_MINOR_VERSION)
 		goto out;
 
-	op = &args->ops[0];
-	if (args->opcnt > 0 && op->status != nfserr_op_illegal &&
-	    !(nfsd4_ops[op->opnum].op_flags & ALLOWED_AS_FIRST_OP)) {
+	if (!nfs41_op_ordering_ok(args)) {
+		op = &args->ops[0];
 		op->status = nfserr_sequence_pos;
 		goto encode_op;
 	}
-- 
1.6.2.1


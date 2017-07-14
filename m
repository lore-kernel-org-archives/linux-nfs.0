Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:37370 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751069AbdGNUZD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 14 Jul 2017 16:25:03 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 4/5] nfsd4: skip encoder in trivial error cases
Date: Fri, 14 Jul 2017 16:24:54 -0400
Message-Id: <1500063895-29457-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1500063895-29457-1-git-send-email-bfields@redhat.com>
References: <1500063895-29457-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Most encoders do nothing in the error case.  But they can still screw
things up in that case: most errors happen very early in rpc processing,
possibly before argument fields are filled in and bounds-tested, so
encoders that do anything other than immediately bail on error can
easily crash in odd error cases.

So just handle errors centrally most of the time to remove the chance of
error.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c | 10 +++++++---
 fs/nfsd/nfs4xdr.c  |  3 +++
 fs/nfsd/xdr4.h     |  2 ++
 3 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 8944b00fd3cd..f37598240700 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -2140,13 +2140,15 @@ static const struct nfsd4_operation nfsd4_ops[] = {
 	},
 	[OP_LOCK] = {
 		.op_func = nfsd4_lock,
-		.op_flags = OP_MODIFIES_SOMETHING,
+		.op_flags = OP_MODIFIES_SOMETHING |
+				OP_NONTRIVIAL_ERROR_ENCODE,
 		.op_name = "OP_LOCK",
 		.op_rsize_bop = nfsd4_lock_rsize,
 		.op_set_currentstateid = nfsd4_set_lockstateid,
 	},
 	[OP_LOCKT] = {
 		.op_func = nfsd4_lockt,
+		.op_flags = OP_NONTRIVIAL_ERROR_ENCODE,
 		.op_name = "OP_LOCKT",
 		.op_rsize_bop = nfsd4_lock_rsize,
 	},
@@ -2276,14 +2278,16 @@ static const struct nfsd4_operation nfsd4_ops[] = {
 	[OP_SETATTR] = {
 		.op_func = nfsd4_setattr,
 		.op_name = "OP_SETATTR",
-		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
+		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME
+				| OP_NONTRIVIAL_ERROR_ENCODE,
 		.op_rsize_bop = nfsd4_setattr_rsize,
 		.op_get_currentstateid = nfsd4_get_setattrstateid,
 	},
 	[OP_SETCLIENTID] = {
 		.op_func = nfsd4_setclientid,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS
-				| OP_MODIFIES_SOMETHING | OP_CACHEME,
+				| OP_MODIFIES_SOMETHING | OP_CACHEME
+				| OP_NONTRIVIAL_ERROR_ENCODE,
 		.op_name = "OP_SETCLIENTID",
 		.op_rsize_bop = nfsd4_setclientid_rsize,
 	},
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 7d683e3aebf0..08badcf64554 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -4461,6 +4461,9 @@ nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
 
 	if (op->opnum == OP_ILLEGAL)
 		goto status;
+	if (op->status && opdesc &&
+			!(opdesc->op_flags & OP_NONTRIVIAL_ERROR_ENCODE))
+		goto status;
 	BUG_ON(op->opnum < 0 || op->opnum >= ARRAY_SIZE(nfsd4_enc_ops) ||
 	       !nfsd4_enc_ops[op->opnum]);
 	encoder = nfsd4_enc_ops[op->opnum];
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 1e6274e0e066..f8a0b6549a88 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -778,6 +778,8 @@ enum nfsd4_op_flags {
 	 * These are ops which clear current state id.
 	 */
 	OP_CLEAR_STATEID = 1 << 7,
+	/* Most ops return only an error on failure; some may do more: */
+	OP_NONTRIVIAL_ERROR_ENCODE = 1 << 8,
 };
 
 struct nfsd4_operation {
-- 
2.9.4


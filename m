Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:37366 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751062AbdGNUZD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 14 Jul 2017 16:25:03 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/5] opdesc will be useful outside nfs4proc.c
Date: Fri, 14 Jul 2017 16:24:52 -0400
Message-Id: <1500063895-29457-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1500063895-29457-1-git-send-email-bfields@redhat.com>
References: <1500063895-29457-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

---
 fs/nfsd/nfs4proc.c | 25 +++++++++++--------------
 fs/nfsd/nfs4xdr.c  |  1 +
 fs/nfsd/xdr4.h     |  2 ++
 3 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 9a627a6c52aa..01d7f2456f62 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1578,7 +1578,7 @@ static __be32 nfs41_check_op_ordering(struct nfsd4_compoundargs *args)
 	return nfs_ok;
 }
 
-static inline const struct nfsd4_operation *OPDESC(struct nfsd4_op *op)
+const struct nfsd4_operation *OPDESC(struct nfsd4_op *op)
 {
 	return &nfsd4_ops[op->opnum];
 }
@@ -1651,7 +1651,6 @@ nfsd4_proc_compound(struct svc_rqst *rqstp)
 	struct nfsd4_compoundargs *args = rqstp->rq_argp;
 	struct nfsd4_compoundres *resp = rqstp->rq_resp;
 	struct nfsd4_op	*op;
-	const struct nfsd4_operation *opdesc;
 	struct nfsd4_compound_state *cstate = &resp->cstate;
 	struct svc_fh *current_fh = &cstate->current_fh;
 	struct svc_fh *save_fh = &cstate->save_fh;
@@ -1704,15 +1703,13 @@ nfsd4_proc_compound(struct svc_rqst *rqstp)
 			goto encode_op;
 		}
 
-		opdesc = OPDESC(op);
-
 		if (!current_fh->fh_dentry) {
-			if (!(opdesc->op_flags & ALLOWED_WITHOUT_FH)) {
+			if (!(op->opdesc->op_flags & ALLOWED_WITHOUT_FH)) {
 				op->status = nfserr_nofilehandle;
 				goto encode_op;
 			}
 		} else if (current_fh->fh_export->ex_fslocs.migrated &&
-			  !(opdesc->op_flags & ALLOWED_ON_ABSENT_FS)) {
+			  !(op->opdesc->op_flags & ALLOWED_ON_ABSENT_FS)) {
 			op->status = nfserr_moved;
 			goto encode_op;
 		}
@@ -1720,12 +1717,12 @@ nfsd4_proc_compound(struct svc_rqst *rqstp)
 		fh_clear_wcc(current_fh);
 
 		/* If op is non-idempotent */
-		if (opdesc->op_flags & OP_MODIFIES_SOMETHING) {
+		if (op->opdesc->op_flags & OP_MODIFIES_SOMETHING) {
 			/*
 			 * Don't execute this op if we couldn't encode a
 			 * succesful reply:
 			 */
-			u32 plen = opdesc->op_rsize_bop(rqstp, op);
+			u32 plen = op->opdesc->op_rsize_bop(rqstp, op);
 			/*
 			 * Plus if there's another operation, make sure
 			 * we'll have space to at least encode an error:
@@ -1738,9 +1735,9 @@ nfsd4_proc_compound(struct svc_rqst *rqstp)
 		if (op->status)
 			goto encode_op;
 
-		if (opdesc->op_get_currentstateid)
-			opdesc->op_get_currentstateid(cstate, &op->u);
-		op->status = opdesc->op_func(rqstp, cstate, &op->u);
+		if (op->opdesc->op_get_currentstateid)
+			op->opdesc->op_get_currentstateid(cstate, &op->u);
+		op->status = op->opdesc->op_func(rqstp, cstate, &op->u);
 
 		/* Only from SEQUENCE */
 		if (cstate->status == nfserr_replay_cache) {
@@ -1749,10 +1746,10 @@ nfsd4_proc_compound(struct svc_rqst *rqstp)
 			goto out;
 		}
 		if (!op->status) {
-			if (opdesc->op_set_currentstateid)
-				opdesc->op_set_currentstateid(cstate, &op->u);
+			if (op->opdesc->op_set_currentstateid)
+				op->opdesc->op_set_currentstateid(cstate, &op->u);
 
-			if (opdesc->op_flags & OP_CLEAR_STATEID)
+			if (op->opdesc->op_flags & OP_CLEAR_STATEID)
 				clear_current_stateid(cstate);
 
 			if (need_wrongsec_check(rqstp))
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 20fbcab97753..40ed23fda814 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1929,6 +1929,7 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
 			op->opnum = OP_ILLEGAL;
 			op->status = nfserr_op_illegal;
 		}
+		op->opdesc = OPDESC(op);
 		/*
 		 * We'll try to cache the result in the DRC if any one
 		 * op in the compound wants to be cached:
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index fcdfe1c3ff4f..90b928006bc7 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -538,6 +538,7 @@ struct nfsd4_seek {
 
 struct nfsd4_op {
 	int					opnum;
+	const struct nfsd4_operation *		opdesc;
 	__be32					status;
 	union nfsd4_op_u {
 		struct nfsd4_access		access;
@@ -661,6 +662,7 @@ static inline bool nfsd4_last_compound_op(struct svc_rqst *rqstp)
 	return argp->opcnt == resp->opcnt;
 }
 
+const struct nfsd4_operation *OPDESC(struct nfsd4_op *op);
 int nfsd4_max_reply(struct svc_rqst *rqstp, struct nfsd4_op *op);
 void warn_on_nonidempotent_op(struct nfsd4_op *op);
 
-- 
2.9.4


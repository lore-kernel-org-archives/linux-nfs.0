Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:37368 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751066AbdGNUZD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 14 Jul 2017 16:25:03 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/5] nfsd4: define ->op_release for compound ops
Date: Fri, 14 Jul 2017 16:24:53 -0400
Message-Id: <1500063895-29457-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1500063895-29457-1-git-send-email-bfields@redhat.com>
References: <1500063895-29457-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Run a separate ->op_release function if necessary instead of depending
on the xdr encoder to do this.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c | 31 +++++++++++++++++++++++++++++++
 fs/nfsd/nfs4xdr.c  |  9 +++------
 fs/nfsd/xdr4.h     |  1 +
 3 files changed, 35 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 01d7f2456f62..8944b00fd3cd 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -784,6 +784,14 @@ nfsd4_read(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	return status;
 }
 
+
+static void
+nfsd4_read_release(union nfsd4_op_u *u)
+{
+	if (u->read.rd_filp)
+		fput(u->read.rd_filp);
+}
+
 static __be32
 nfsd4_readdir(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	      union nfsd4_op_u *u)
@@ -912,6 +920,13 @@ nfsd4_secinfo_no_name(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstat
 	return nfs_ok;
 }
 
+static void
+nfsd4_secinfo_release(union nfsd4_op_u *u)
+{
+	if (u->secinfo.si_exp)
+		exp_put(u->secinfo.si_exp);
+}
+
 static __be32
 nfsd4_setattr(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	      union nfsd4_op_u *u)
@@ -1335,6 +1350,12 @@ nfsd4_getdeviceinfo(struct svc_rqst *rqstp,
 	return nfserr;
 }
 
+static void
+nfsd4_getdeviceinfo_release(union nfsd4_op_u *u)
+{
+	kfree(gdev->gd_device);
+}
+
 static __be32
 nfsd4_layoutget(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *cstate, union nfsd4_op_u *u)
@@ -1415,6 +1436,11 @@ nfsd4_layoutget(struct svc_rqst *rqstp,
 	return nfserr;
 }
 
+nfsd4_layoutget_release(union nfsd4_op_u *u)
+{
+	kfree(lgp->lg_content);
+}
+
 static __be32
 nfsd4_layoutcommit(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *cstate, union nfsd4_op_u *u)
@@ -2192,6 +2218,7 @@ static const struct nfsd4_operation nfsd4_ops[] = {
 	},
 	[OP_READ] = {
 		.op_func = nfsd4_read,
+		.op_release = nfsd4_read_release,
 		.op_name = "OP_READ",
 		.op_rsize_bop = nfsd4_read_rsize,
 		.op_get_currentstateid = nfsd4_get_readstateid,
@@ -2241,6 +2268,7 @@ static const struct nfsd4_operation nfsd4_ops[] = {
 	},
 	[OP_SECINFO] = {
 		.op_func = nfsd4_secinfo,
+		.op_release = nfsd4_secinfo_release,
 		.op_flags = OP_HANDLES_WRONGSEC,
 		.op_name = "OP_SECINFO",
 		.op_rsize_bop = nfsd4_secinfo_rsize,
@@ -2342,6 +2370,7 @@ static const struct nfsd4_operation nfsd4_ops[] = {
 	},
 	[OP_SECINFO_NO_NAME] = {
 		.op_func = nfsd4_secinfo_no_name,
+		.op_release = nfsd4_secinfo_release,
 		.op_flags = OP_HANDLES_WRONGSEC,
 		.op_name = "OP_SECINFO_NO_NAME",
 		.op_rsize_bop = nfsd4_secinfo_rsize,
@@ -2362,12 +2391,14 @@ static const struct nfsd4_operation nfsd4_ops[] = {
 #ifdef CONFIG_NFSD_PNFS
 	[OP_GETDEVICEINFO] = {
 		.op_func = nfsd4_getdeviceinfo,
+		.op_release = nfsd4_getdeviceinfo_release,
 		.op_flags = ALLOWED_WITHOUT_FH,
 		.op_name = "OP_GETDEVICEINFO",
 		.op_rsize_bop = nfsd4_getdeviceinfo_rsize,
 	},
 	[OP_LAYOUTGET] = {
 		.op_func = nfsd4_layoutget,
+		.op_release = nfsd4_layoutget_release,
 		.op_flags = OP_MODIFIES_SOMETHING,
 		.op_name = "OP_LAYOUTGET",
 		.op_rsize_bop = nfsd4_layoutget_rsize,
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 40ed23fda814..7d683e3aebf0 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3593,8 +3593,6 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 		xdr_truncate_encode(xdr, starting_len);
 
 out:
-	if (file)
-		fput(file);
 	return nfserr;
 }
 
@@ -3838,8 +3836,6 @@ nfsd4_do_encode_secinfo(struct xdr_stream *xdr,
 	*flavorsp = htonl(supported);
 	nfserr = 0;
 out:
-	if (exp)
-		exp_put(exp);
 	return nfserr;
 }
 
@@ -4172,7 +4168,6 @@ nfsd4_encode_getdeviceinfo(struct nfsd4_compoundres *resp, __be32 nfserr,
 
 	nfserr = 0;
 out:
-	kfree(gdev->gd_device);
 	dprintk("%s: done: %d\n", __func__, be32_to_cpu(nfserr));
 	return nfserr;
 
@@ -4221,7 +4216,6 @@ nfsd4_encode_layoutget(struct nfsd4_compoundres *resp, __be32 nfserr,
 	ops = nfsd4_layout_ops[lgp->lg_layout_type];
 	nfserr = ops->encode_layoutget(xdr, lgp);
 out:
-	kfree(lgp->lg_content);
 	return nfserr;
 }
 
@@ -4452,6 +4446,7 @@ nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
 	struct xdr_stream *xdr = &resp->xdr;
 	struct nfs4_stateowner *so = resp->cstate.replay_owner;
 	struct svc_rqst *rqstp = resp->rqstp;
+	const struct nfsd4_operation *opdesc = op->opdesc;
 	int post_err_offset;
 	nfsd4_enc encoder;
 	__be32 *p;
@@ -4470,6 +4465,8 @@ nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
 	       !nfsd4_enc_ops[op->opnum]);
 	encoder = nfsd4_enc_ops[op->opnum];
 	op->status = encoder(resp, op->status, &op->u);
+	if (opdesc && opdesc->op_release)
+		opdesc->op_release(&op->u);
 	xdr_commit_encode(xdr);
 
 	/* nfsd4_check_resp_size guarantees enough room for error status */
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 90b928006bc7..1e6274e0e066 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -783,6 +783,7 @@ enum nfsd4_op_flags {
 struct nfsd4_operation {
 	__be32 (*op_func)(struct svc_rqst *, struct nfsd4_compound_state *,
 			union nfsd4_op_u *);
+	void (*op_release)(union nfsd4_op_u *);
 	u32 op_flags;
 	char *op_name;
 	/* Try to get response size before operation */
-- 
2.9.4


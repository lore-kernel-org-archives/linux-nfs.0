Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41561 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753864Ab3CEWR7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Mar 2013 17:17:59 -0500
Received: from bfields by fieldses.org with local (Exim 4.76)
	(envelope-from <bfields@fieldses.org>)
	id 1UD0BL-0004sE-Cu
	for linux-nfs@vger.kernel.org; Tue, 05 Mar 2013 17:17:59 -0500
Date: Tue, 5 Mar 2013 17:17:59 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] nfsd4: handle seqid-mutating open errors from xdr
 decoding
Message-ID: <20130305221759.GF15816@fieldses.org>
References: <20130305221722.GE15816@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130305221722.GE15816@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

If a client sets an owner (or group_owner or acl) attribute on open for
create, and the mapping of that owner to an id fails, then we return
BAD_OWNER.  But BAD_OWNER is a seqid-mutating error, so we can't
shortcut the open processing that case: we have to at least look up the
owner so we can find the seqid to bump.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c |   27 ++++++++++++++++++++++++++-
 fs/nfsd/nfs4xdr.c  |    1 +
 fs/nfsd/xdr4.h     |    1 +
 3 files changed, 28 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index c7e4e8c..42c498c 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -351,6 +351,10 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	}
 	if (status)
 		goto out;
+	if (open->op_xdr_error) {
+		status = open->op_xdr_error;
+		goto out;
+	}
 
 	status = nfsd4_check_open_attributes(rqstp, cstate, open);
 	if (status)
@@ -417,6 +421,24 @@ out:
 }
 
 /*
+ * OPEN is the only seqid-mutating operation whose decoding can fail
+ * with a seqid-mutating error (specifically, decoding of user names in
+ * the attributes).  Therefore we have to do some processing to look up
+ * the stateowner so that we can bump the seqid.
+ */
+static __be32 nfsd4_open_omfg(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate, struct nfsd4_op *op)
+{
+	struct nfsd4_open *open = (struct nfsd4_open *)&op->u;
+
+	if (!seqid_mutating_err(ntohl(op->status)))
+		return op->status;
+	if (nfsd4_has_session(cstate))
+		return op->status;
+	open->op_xdr_error = op->status;
+	return nfsd4_open(rqstp, cstate, open);
+}
+
+/*
  * filehandle-manipulating ops.
  */
 static __be32
@@ -1244,8 +1266,11 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 		 * for example, if there is a miscellaneous XDR error
 		 * it will be set to nfserr_bad_xdr.
 		 */
-		if (op->status)
+		if (op->status) {
+			if (op->opnum == OP_OPEN)
+				op->status = nfsd4_open_omfg(rqstp, cstate, op);
 			goto encode_op;
+		}
 
 		/* We must be able to encode a successful response to
 		 * this operation, with enough room left over to encode a
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 0116886..a82df26 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -804,6 +804,7 @@ nfsd4_decode_open(struct nfsd4_compoundargs *argp, struct nfsd4_open *open)
 	open->op_iattr.ia_valid = 0;
 	open->op_openowner = NULL;
 
+	open->op_xdr_error = 0;
 	/* seqid, share_access, share_deny, clientid, ownerlen */
 	READ_BUF(4);
 	READ32(open->op_seqid);
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 546f898..be0a79d 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -237,6 +237,7 @@ struct nfsd4_open {
 	u32		op_share_deny;      /* request */
 	u32		op_deleg_want;      /* request */
 	stateid_t	op_stateid;         /* response */
+	__be32		op_xdr_error;       /* see nfsd4_open_omfg() */
 	u32		op_recall;          /* recall */
 	struct nfsd4_change_info  op_cinfo; /* response */
 	u32		op_rflags;          /* response */
-- 
1.7.9.5


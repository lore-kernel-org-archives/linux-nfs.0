Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59385 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752299Ab0LQTB5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Dec 2010 14:01:57 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/3] nfsd4: implement secinfo_no_name
Date: Fri, 17 Dec 2010 14:01:51 -0500
Message-Id: <1292612511-14203-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1292612511-14203-1-git-send-email-bfields@redhat.com>
References: <1292612511-14203-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Implementation of this operation is mandatory for NFSv4.1.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c   |   27 +++++++++++++++++++++++++++
 fs/nfsd/nfs4xdr.c    |   15 +++++++++++++--
 fs/nfsd/xdr4.h       |    5 +++++
 include/linux/nfs4.h |    3 +++
 4 files changed, 48 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 095431a..f80c399 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -780,6 +780,29 @@ nfsd4_secinfo(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 }
 
 static __be32
+nfsd4_secinfo_no_name(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
+	      struct nfsd4_secinfo_no_name *sin)
+{
+	__be32 err;
+
+	switch (sin->sin_style) {
+	case NFS4_SECINFO_STYLE4_CURRENT_FH:
+		break;
+	case NFS4_SECINFO_STYLE4_PARENT:
+		err = nfsd4_do_lookupp(rqstp, &cstate->current_fh);
+		if (err)
+			return err;
+		break;
+	default:
+		return nfserr_inval;
+	}
+	exp_get(cstate->current_fh.fh_export);
+	sin->sin_exp = cstate->current_fh.fh_export;
+	fh_put(&cstate->current_fh);
+	return nfs_ok;
+}
+
+static __be32
 nfsd4_setattr(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	      struct nfsd4_setattr *setattr)
 {
@@ -1327,6 +1350,10 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_flags = ALLOWED_WITHOUT_FH,
 		.op_name = "OP_RECLAIM_COMPLETE",
 	},
+	[OP_SECINFO_NO_NAME] = {
+		.op_func = (nfsd4op_func)nfsd4_secinfo_no_name,
+		.op_name = "OP_SECINFO_NO_NAME",
+	},
 };
 
 static const char *nfsd4_op_name(unsigned opnum)
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 71d7d33..b543b24 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -847,6 +847,17 @@ nfsd4_decode_secinfo(struct nfsd4_compoundargs *argp,
 }
 
 static __be32
+nfsd4_decode_secinfo_no_name(struct nfsd4_compoundargs *argp,
+		     struct nfsd4_secinfo_no_name *sin)
+{
+	DECODE_HEAD;
+
+	READ_BUF(4);
+	READ32(sin->sin_style);
+	DECODE_TAIL;
+}
+
+static __be32
 nfsd4_decode_setattr(struct nfsd4_compoundargs *argp, struct nfsd4_setattr *setattr)
 {
 	__be32 status;
@@ -1358,7 +1369,7 @@ static nfsd4_dec nfsd41_dec_ops[] = {
 	[OP_LAYOUTCOMMIT]	= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_LAYOUTGET]		= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_LAYOUTRETURN]	= (nfsd4_dec)nfsd4_decode_notsupp,
-	[OP_SECINFO_NO_NAME]	= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_SECINFO_NO_NAME]	= (nfsd4_dec)nfsd4_decode_secinfo_no_name,
 	[OP_SEQUENCE]		= (nfsd4_dec)nfsd4_decode_sequence,
 	[OP_SET_SSV]		= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_TEST_STATEID]	= (nfsd4_dec)nfsd4_decode_notsupp,
@@ -3162,7 +3173,7 @@ static nfsd4_enc nfsd4_enc_ops[] = {
 	[OP_LAYOUTCOMMIT]	= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_LAYOUTGET]		= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_LAYOUTRETURN]	= (nfsd4_enc)nfsd4_encode_noop,
-	[OP_SECINFO_NO_NAME]	= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_SECINFO_NO_NAME]	= (nfsd4_enc)nfsd4_encode_secinfo,
 	[OP_SEQUENCE]		= (nfsd4_enc)nfsd4_encode_sequence,
 	[OP_SET_SSV]		= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_TEST_STATEID]	= (nfsd4_enc)nfsd4_encode_noop,
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 60fce3d..799c30c 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -311,6 +311,11 @@ struct nfsd4_secinfo {
 	struct svc_export *si_exp;			/* response */
 };
 
+struct nfsd4_secinfo_no_name {
+	u32 sin_style;					/* request */
+	struct svc_export *sin_exp;			/* response */
+};
+
 struct nfsd4_setattr {
 	stateid_t	sa_stateid;         /* request */
 	u32		sa_bmval[3];        /* request */
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 4925b22..26afa30 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -136,6 +136,9 @@
 #define SEQ4_STATUS_CB_PATH_DOWN_SESSION	0x00000200
 #define SEQ4_STATUS_BACKCHANNEL_FAULT		0x00000400
 
+#define NFS4_SECINFO_STYLE4_CURRENT_FH	0
+#define NFS4_SECINFO_STYLE4_PARENT	1
+
 #define NFS4_MAX_UINT64	(~(u64)0)
 
 /* An NFS4 sessions server must support at least NFS4_MAX_OPS operations.
-- 
1.7.1


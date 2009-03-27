From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 46/47] nfsd41: CREATE_EXCLUSIVE4_1
Date: Fri, 27 Mar 2009 06:22:51 +0300
Message-ID: <1238124171-8350-1-git-send-email-bhalevy@panasas.com>
References: <49CC40E5.2080506@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:24423 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756547AbZC0DW4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Mar 2009 23:22:56 -0400
In-Reply-To: <49CC40E5.2080506@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Implement the CREATE_EXCLUSIVE4_1 open mode conforming to
http://tools.ietf.org/html/draft-ietf-nfsv4-minorversion1-26

This mode allows the client to atomically create a file
if it doesn't exist while setting some of its attributes.

It must be implemented if the server supports persistent
reply cache and/or pnfs.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4proc.c        |   15 +++++++++++++++
 fs/nfsd/nfs4xdr.c         |   17 +++++++++++++++++
 include/linux/nfs4.h      |    8 +++++++-
 include/linux/nfsd/xdr4.h |   10 ++++------
 4 files changed, 43 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index f3b560f..6d7d7c5 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -93,6 +93,21 @@ do_open_lookup(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_o
 	open->op_truncate = 0;
 
 	if (open->op_create) {
+		/* FIXME: check session persistence and pnfs flags.
+		 * The nfsv4.1 spec requires the following semantics:
+		 *
+		 * Persistent   | pNFS   | Server REQUIRED | Client Allowed
+		 * Reply Cache  | server |                 |
+		 * -------------+--------+-----------------+--------------------
+		 * no           | no     | EXCLUSIVE4_1    | EXCLUSIVE4_1
+		 *              |        |                 | (SHOULD)
+		 *              |        | and EXCLUSIVE4  | or EXCLUSIVE4
+		 *              |        |                 | (SHOULD NOT)
+		 * no           | yes    | EXCLUSIVE4_1    | EXCLUSIVE4_1
+		 * yes          | no     | GUARDED4        | GUARDED4
+		 * yes          | yes    | GUARDED4        | GUARDED4
+		 */
+
 		/*
 		 * Note: create modes (UNCHECKED,GUARDED...) are the same
 		 * in NFSv4 as in v3.
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 288332c..0084459 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -260,6 +260,12 @@ static u32 nfsd_attrmask[] = {
 	NFSD_WRITEABLE_ATTRS_WORD2
 };
 
+static u32 nfsd41_ex_attrmask[] = {
+	NFSD_SUPPATTR_EXCLCREAT_WORD0,
+	NFSD_SUPPATTR_EXCLCREAT_WORD1,
+	NFSD_SUPPATTR_EXCLCREAT_WORD2
+};
+
 static __be32
 nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval, u32 *writable,
 		   struct iattr *iattr, struct nfs4_acl **acl)
@@ -684,6 +690,17 @@ nfsd4_decode_open(struct nfsd4_compoundargs *argp, struct nfsd4_open *open)
 			READ_BUF(8);
 			COPYMEM(open->op_verf.data, 8);
 			break;
+		case NFS4_CREATE_EXCLUSIVE4_1:
+			if (argp->minorversion < 1)
+				goto xdr_error;
+			READ_BUF(8);
+			COPYMEM(open->op_verf.data, 8);
+			status = nfsd4_decode_fattr(argp, open->op_bmval,
+				nfsd41_ex_attrmask, &open->op_iattr,
+				&open->op_acl);
+			if (status)
+				goto out;
+			break;
 		default:
 			goto xdr_error;
 		}
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 735c7d8..5756359 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -368,7 +368,13 @@ enum opentype4 {
 enum createmode4 {
 	NFS4_CREATE_UNCHECKED = 0,
 	NFS4_CREATE_GUARDED = 1,
-	NFS4_CREATE_EXCLUSIVE = 2
+	NFS4_CREATE_EXCLUSIVE = 2,
+	/*
+	 * New to NFSv4.1. If session is persistent,
+	 * GUARDED4 MUST be used. Otherwise, use
+	 * EXCLUSIVE4_1 instead of EXCLUSIVE4.
+	 */
+	NFS4_CREATE_EXCLUSIVE4_1 = 3
 };
 
 enum limit_by4 {
diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index d7a8050..7ed9955 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -218,10 +218,8 @@ struct nfsd4_open {
 	u32		op_create;     	    /* request */
 	u32		op_createmode;      /* request */
 	u32		op_bmval[3];        /* request */
-	union {                             /* request */
-		struct iattr	iattr;                      /* UNCHECKED4,GUARDED4 */
-		nfs4_verifier	verf;                                /* EXCLUSIVE4 */
-	} u;
+	struct iattr	iattr;              /* UNCHECKED4, GUARDED4, EXCLUSIVE4_1 */
+	nfs4_verifier	verf;               /* EXCLUSIVE4 */
 	clientid_t	op_clientid;        /* request */
 	struct xdr_netobj op_owner;           /* request */
 	u32		op_seqid;           /* request */
@@ -235,8 +233,8 @@ struct nfsd4_open {
 	struct nfs4_stateowner *op_stateowner; /* used during processing */
 	struct nfs4_acl *op_acl;
 };
-#define op_iattr	u.iattr
-#define op_verf		u.verf
+#define op_iattr	iattr
+#define op_verf		verf
 
 struct nfsd4_open_confirm {
 	stateid_t	oc_req_stateid		/* request */;
-- 
1.6.2.1


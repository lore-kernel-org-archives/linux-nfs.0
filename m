Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38529 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757101AbaEKUwz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 11 May 2014 16:52:55 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 05/43] nfsd4: move nfsd4_operation to xdr4.h
Date: Sun, 11 May 2014 16:52:10 -0400
Message-Id: <1399841568-19716-6-git-send-email-bfields@redhat.com>
In-Reply-To: <1399841568-19716-1-git-send-email-bfields@redhat.com>
References: <1399841568-19716-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

We want to share some of these definitions.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c |   58 ++++------------------------------------------------
 fs/nfsd/xdr4.h     |   53 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 57 insertions(+), 54 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 3d4b044..99aa348 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1123,58 +1123,8 @@ static inline void nfsd4_increment_op_stats(u32 opnum)
 		nfsdstats.nfs4_opcount[opnum]++;
 }
 
-typedef __be32(*nfsd4op_func)(struct svc_rqst *, struct nfsd4_compound_state *,
-			      void *);
-typedef u32(*nfsd4op_rsize)(struct svc_rqst *, struct nfsd4_op *op);
-typedef void(*stateid_setter)(struct nfsd4_compound_state *, void *);
-typedef void(*stateid_getter)(struct nfsd4_compound_state *, void *);
-
-enum nfsd4_op_flags {
-	ALLOWED_WITHOUT_FH = 1 << 0,	/* No current filehandle required */
-	ALLOWED_ON_ABSENT_FS = 1 << 1,	/* ops processed on absent fs */
-	ALLOWED_AS_FIRST_OP = 1 << 2,	/* ops reqired first in compound */
-	/* For rfc 5661 section 2.6.3.1.1: */
-	OP_HANDLES_WRONGSEC = 1 << 3,
-	OP_IS_PUTFH_LIKE = 1 << 4,
-	/*
-	 * These are the ops whose result size we estimate before
-	 * encoding, to avoid performing an op then not being able to
-	 * respond or cache a response.  This includes writes and setattrs
-	 * as well as the operations usually called "nonidempotent":
-	 */
-	OP_MODIFIES_SOMETHING = 1 << 5,
-	/*
-	 * Cache compounds containing these ops in the xid-based drc:
-	 * We use the DRC for compounds containing non-idempotent
-	 * operations, *except* those that are 4.1-specific (since
-	 * sessions provide their own EOS), and except for stateful
-	 * operations other than setclientid and setclientid_confirm
-	 * (since sequence numbers provide EOS for open, lock, etc in
-	 * the v4.0 case).
-	 */
-	OP_CACHEME = 1 << 6,
-	/*
-	 * These are ops which clear current state id.
-	 */
-	OP_CLEAR_STATEID = 1 << 7,
-};
-
-struct nfsd4_operation {
-	nfsd4op_func op_func;
-	u32 op_flags;
-	char *op_name;
-	/* Try to get response size before operation */
-	nfsd4op_rsize op_rsize_bop;
-	stateid_getter op_get_currentstateid;
-	stateid_setter op_set_currentstateid;
-};
-
 static struct nfsd4_operation nfsd4_ops[];
 
-#ifdef NFSD_DEBUG
-static const char *nfsd4_op_name(unsigned opnum);
-#endif
-
 /*
  * Enforce NFSv4.1 COMPOUND ordering rules:
  *
@@ -1208,7 +1158,7 @@ static __be32 nfs41_check_op_ordering(struct nfsd4_compoundargs *args)
 	return nfs_ok;
 }
 
-static inline struct nfsd4_operation *OPDESC(struct nfsd4_op *op)
+struct nfsd4_operation *OPDESC(struct nfsd4_op *op)
 {
 	return &nfsd4_ops[op->opnum];
 }
@@ -1856,14 +1806,14 @@ static struct nfsd4_operation nfsd4_ops[] = {
 	},
 };
 
-#ifdef NFSD_DEBUG
-static const char *nfsd4_op_name(unsigned opnum)
+const char *nfsd4_op_name(unsigned opnum)
 {
+#ifdef NFSD_DEBUG
 	if (opnum < ARRAY_SIZE(nfsd4_ops))
 		return nfsd4_ops[opnum].op_name;
+#endif
 	return "unknown_operation";
 }
-#endif
 
 #define nfsd4_voidres			nfsd4_voidargs
 struct nfsd4_voidargs { int dummy; };
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index f62a055..fa3a589 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -536,6 +536,59 @@ static inline bool nfsd4_last_compound_op(struct svc_rqst *rqstp)
 	return argp->opcnt == resp->opcnt;
 }
 
+
+
+typedef __be32(*nfsd4op_func)(struct svc_rqst *, struct nfsd4_compound_state *,
+			      void *);
+typedef u32(*nfsd4op_rsize)(struct svc_rqst *, struct nfsd4_op *op);
+typedef void(*stateid_setter)(struct nfsd4_compound_state *, void *);
+typedef void(*stateid_getter)(struct nfsd4_compound_state *, void *);
+
+enum nfsd4_op_flags {
+	ALLOWED_WITHOUT_FH = 1 << 0,	/* No current filehandle required */
+	ALLOWED_ON_ABSENT_FS = 1 << 1,	/* ops processed on absent fs */
+	ALLOWED_AS_FIRST_OP = 1 << 2,	/* ops reqired first in compound */
+	/* For rfc 5661 section 2.6.3.1.1: */
+	OP_HANDLES_WRONGSEC = 1 << 3,
+	OP_IS_PUTFH_LIKE = 1 << 4,
+	/*
+	 * These are the ops whose result size we estimate before
+	 * encoding, to avoid performing an op then not being able to
+	 * respond or cache a response.  This includes writes and setattrs
+	 * as well as the operations usually called "nonidempotent":
+	 */
+	OP_MODIFIES_SOMETHING = 1 << 5,
+	/*
+	 * Cache compounds containing these ops in the xid-based drc:
+	 * We use the DRC for compounds containing non-idempotent
+	 * operations, *except* those that are 4.1-specific (since
+	 * sessions provide their own EOS), and except for stateful
+	 * operations other than setclientid and setclientid_confirm
+	 * (since sequence numbers provide EOS for open, lock, etc in
+	 * the v4.0 case).
+	 */
+	OP_CACHEME = 1 << 6,
+	/*
+	 * These are ops which clear current state id.
+	 */
+	OP_CLEAR_STATEID = 1 << 7,
+};
+
+struct nfsd4_operation {
+	nfsd4op_func op_func;
+	u32 op_flags;
+	char *op_name;
+	/* Try to get response size before
+	 * operation */
+	nfsd4op_rsize op_rsize_bop;
+	stateid_getter op_get_currentstateid;
+	stateid_setter op_set_currentstateid;
+};
+
+struct nfsd4_operation *OPDESC(struct nfsd4_op *op);
+
+const char *nfsd4_op_name(unsigned opnum);
+
 #define NFS4_SVC_XDRSIZE		sizeof(struct nfsd4_compoundargs)
 
 static inline void
-- 
1.7.9.5


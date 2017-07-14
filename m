Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:37364 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751012AbdGNUZD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 14 Jul 2017 16:25:03 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/5] nfsd4: move some nfsd4 op definitions to xdr4.h
Date: Fri, 14 Jul 2017 16:24:51 -0400
Message-Id: <1500063895-29457-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1500063895-29457-1-git-send-email-bfields@redhat.com>
References: <1500063895-29457-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

I want code in nfs4xdr.c to have access to this stuff.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c | 43 -------------------------------------------
 fs/nfsd/xdr4.h     | 44 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 44 insertions(+), 43 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index d27e75ad25e3..9a627a6c52aa 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1541,49 +1541,6 @@ static inline void nfsd4_increment_op_stats(u32 opnum)
 		nfsdstats.nfs4_opcount[opnum]++;
 }
 
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
-	__be32 (*op_func)(struct svc_rqst *, struct nfsd4_compound_state *,
-			union nfsd4_op_u *);
-	u32 op_flags;
-	char *op_name;
-	/* Try to get response size before operation */
-	u32 (*op_rsize_bop)(struct svc_rqst *, struct nfsd4_op *);
-	void (*op_get_currentstateid)(struct nfsd4_compound_state *,
-			union nfsd4_op_u *);
-	void (*op_set_currentstateid)(struct nfsd4_compound_state *,
-			union nfsd4_op_u *);
-};
-
 static const struct nfsd4_operation nfsd4_ops[];
 
 static const char *nfsd4_op_name(unsigned opnum);
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 72c6ad136107..fcdfe1c3ff4f 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -748,6 +748,50 @@ extern __be32 nfsd4_free_stateid(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *, union nfsd4_op_u *);
 extern void nfsd4_bump_seqid(struct nfsd4_compound_state *, __be32 nfserr);
 
+enum nfsd4_op_flags {
+	ALLOWED_WITHOUT_FH = 1 << 0,    /* No current filehandle required */
+	ALLOWED_ON_ABSENT_FS = 1 << 1,  /* ops processed on absent fs */
+	ALLOWED_AS_FIRST_OP = 1 << 2,   /* ops reqired first in compound */
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
+	__be32 (*op_func)(struct svc_rqst *, struct nfsd4_compound_state *,
+			union nfsd4_op_u *);
+	u32 op_flags;
+	char *op_name;
+	/* Try to get response size before operation */
+	u32 (*op_rsize_bop)(struct svc_rqst *, struct nfsd4_op *);
+	void (*op_get_currentstateid)(struct nfsd4_compound_state *,
+			union nfsd4_op_u *);
+	void (*op_set_currentstateid)(struct nfsd4_compound_state *,
+			union nfsd4_op_u *);
+};
+
+
 #endif
 
 /*
-- 
2.9.4


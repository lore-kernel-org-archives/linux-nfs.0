Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:40905 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760609Ab3ICS0i (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Sep 2013 14:26:38 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: <bfields@fieldses.org>
CC: <linux-nfs@vger.kernel.org>, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH] nfsd: SECINFO* can use integrity protected flavors
Date: Tue, 3 Sep 2013 14:26:12 -0400
Message-ID: <1378232772-4066-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

SECINFO and SECINFO_NONAME should be able to use integrity protected auth
flavors even if the export wasn't explicitly configured to use them.

An example is a sec=sys export - upstream linux clients will attempt to use
krb5i for EXCHANGE_ID, CREATE_SESSION, DESTROY_SESSION, etc.  If this is
successful, the client will try to use the same auth flavor for SECINFO
as described in the Security Considerations sections of rfc3530 and rfc5661.

This patch adds a nfsd4_op_flag to describe operations that may use these
auth flavors to get around nfsd_access() checks. This should be useful in
future implementations of SP4_MACH_CRED (nfsd_permission still needs to be
handled).

This patch also stops SECINFO* from returning NFS4ERR_WRONGSEC which is
not allowed by either rfc3530 (not in list of allowed errors) or rfc6551
(section 2.6.3.1.1.5 says it MUST NOT).

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 fs/nfsd/export.c   | 10 ++++++++++
 fs/nfsd/nfs4proc.c | 27 ++++++++++++++++++++++++---
 fs/nfsd/xdr4.h     |  2 ++
 3 files changed, 36 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 5f38ea3..e2e5a13 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -22,6 +22,7 @@
 #include "nfsd.h"
 #include "nfsfh.h"
 #include "netns.h"
+#include "xdr4.h"
 
 #define NFSDDBG_FACILITY	NFSDDBG_EXPORT
 
@@ -909,6 +910,15 @@ __be32 check_nfsd_access(struct svc_export *exp, struct svc_rqst *rqstp)
 		    rqstp->rq_cred.cr_flavor == RPC_AUTH_UNIX)
 			return 0;
 	}
+
+	/* some operations allow use of integrity even though the mount
+	 * may not be */
+	if (nfsd4_allow_integrity(rqstp)) {
+		if (rqstp->rq_cred.cr_flavor == RPC_AUTH_GSS_KRB5I ||
+		    rqstp->rq_cred.cr_flavor == RPC_AUTH_GSS_KRB5P)
+			return 0;
+	}
+
 	return nfserr_wrongsec;
 }
 
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 0d4c410..ce79483 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1158,6 +1158,11 @@ enum nfsd4_op_flags {
 	 * These are ops which clear current state id.
 	 */
 	OP_CLEAR_STATEID = 1 << 7,
+	/*
+	 * Procedures that can use auth flavors other than flavors
+	 * specified in the export as long as they are integrity protected.
+	 */
+	OP_ALLOW_INTEGRITY = 1 << 8,
 };
 
 struct nfsd4_operation {
@@ -1249,7 +1254,23 @@ static bool need_wrongsec_check(struct svc_rqst *rqstp)
 	 * errors themselves as necessary; others should check for them
 	 * now:
 	 */
-	return !(nextd->op_flags & OP_HANDLES_WRONGSEC);
+	return !(nextd->op_flags & (OP_HANDLES_WRONGSEC | OP_ALLOW_INTEGRITY));
+}
+
+bool
+nfsd4_allow_integrity(struct svc_rqst *rqstp)
+{
+	struct nfsd4_compoundres *resp = rqstp->rq_resp;
+	struct nfsd4_compoundargs *argp = rqstp->rq_argp;
+	struct nfsd4_op *this = &argp->ops[resp->opcnt - 1];
+	struct nfsd4_operation *thisd;
+
+	thisd = OPDESC(this);
+
+	if (thisd->op_flags & OP_ALLOW_INTEGRITY)
+		return true;
+
+	return false;
 }
 
 /*
@@ -1727,7 +1748,7 @@ static struct nfsd4_operation nfsd4_ops[] = {
 	},
 	[OP_SECINFO] = {
 		.op_func = (nfsd4op_func)nfsd4_secinfo,
-		.op_flags = OP_HANDLES_WRONGSEC,
+		.op_flags = OP_ALLOW_INTEGRITY,
 		.op_name = "OP_SECINFO",
 	},
 	[OP_SETATTR] = {
@@ -1825,7 +1846,7 @@ static struct nfsd4_operation nfsd4_ops[] = {
 	},
 	[OP_SECINFO_NO_NAME] = {
 		.op_func = (nfsd4op_func)nfsd4_secinfo_no_name,
-		.op_flags = OP_HANDLES_WRONGSEC,
+		.op_flags = OP_ALLOW_INTEGRITY,
 		.op_name = "OP_SECINFO_NO_NAME",
 	},
 	[OP_TEST_STATEID] = {
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index b3ed644..ed79b6d 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -481,6 +481,8 @@ struct nfsd4_op {
 
 bool nfsd4_cache_this_op(struct nfsd4_op *);
 
+bool nfsd4_allow_integrity(struct svc_rqst *);
+
 struct nfsd4_compoundargs {
 	/* scratch variables for XDR decode */
 	__be32 *			p;
-- 
1.7.12.4 (Apple Git-37)


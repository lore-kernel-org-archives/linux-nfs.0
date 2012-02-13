Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:49022 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752167Ab2BMVwW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Feb 2012 16:52:22 -0500
Received: by eekc14 with SMTP id c14so2011170eek.19
        for <linux-nfs@vger.kernel.org>; Mon, 13 Feb 2012 13:52:20 -0800 (PST)
From: Tigran Mkrtchyan <kofemann@googlemail.com>
To: linux-nfs@vger.kernel.org
Cc: Tigran Mkrtchyan <kofemann@gmail.com>
Subject: [PATH v9 02/10] nfsd41: handle current stateid in open and close
Date: Mon, 13 Feb 2012 22:55:24 +0100
Message-Id: <1329170132-7081-3-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1329170132-7081-1-git-send-email-tigran.mkrtchyan@desy.de>
References: <1329170132-7081-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tigran Mkrtchyan <kofemann@gmail.com>


Signed-off-by: Tigran Mkrtchyan <kofemann@gmail.com>
---
 fs/nfsd/current_stateid.h |   11 +++++++++++
 fs/nfsd/nfs4proc.c        |   30 ++++++++++++++++++++++++++----
 fs/nfsd/nfs4state.c       |   32 ++++++++++++++++++++++++++++++++
 fs/nfsd/xdr4.h            |    1 +
 4 files changed, 70 insertions(+), 4 deletions(-)
 create mode 100644 fs/nfsd/current_stateid.h

diff --git a/fs/nfsd/current_stateid.h b/fs/nfsd/current_stateid.h
new file mode 100644
index 0000000..a83dd50
--- /dev/null
+++ b/fs/nfsd/current_stateid.h
@@ -0,0 +1,11 @@
+#ifndef _NFSD4_CURRENT_STATE_H
+#define _NFSD4_CURRENT_STATE_H
+
+#include "state.h"
+#include "xdr4.h"
+
+extern void nfsd4_set_openstateid(struct nfsd4_compound_state *, struct nfsd4_open *);
+extern void nfsd4_get_closestateid(struct nfsd4_compound_state *, struct nfsd4_close *);
+extern void nfsd4_set_closestateid(struct nfsd4_compound_state *, struct nfsd4_close *);
+
+#endif   /* _NFSD4_CURRENT_STATE_H */
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 9415bc4..a457551 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -39,6 +39,7 @@
 #include "cache.h"
 #include "xdr4.h"
 #include "vfs.h"
+#include "current_stateid.h"
 
 #define NFSDDBG_FACILITY		NFSDDBG_PROC
 
@@ -1000,6 +1001,8 @@ static inline void nfsd4_increment_op_stats(u32 opnum)
 typedef __be32(*nfsd4op_func)(struct svc_rqst *, struct nfsd4_compound_state *,
 			      void *);
 typedef u32(*nfsd4op_rsize)(struct svc_rqst *, struct nfsd4_op *op);
+typedef void(*stateid_setter)(struct nfsd4_compound_state *, void *);
+typedef void(*stateid_getter)(struct nfsd4_compound_state *, void *);
 
 enum nfsd4_op_flags {
 	ALLOWED_WITHOUT_FH = 1 << 0,	/* No current filehandle required */
@@ -1025,6 +1028,10 @@ enum nfsd4_op_flags {
 	 * the v4.0 case).
 	 */
 	OP_CACHEME = 1 << 6,
+	/*
+	 * These are ops which clear current state id.
+	 */
+	OP_CLEAR_STATEID = 1 << 7,
 };
 
 struct nfsd4_operation {
@@ -1033,6 +1040,8 @@ struct nfsd4_operation {
 	char *op_name;
 	/* Try to get response size before operation */
 	nfsd4op_rsize op_rsize_bop;
+	stateid_setter op_get_currentstateid;
+	stateid_getter op_set_currentstateid;
 };
 
 static struct nfsd4_operation nfsd4_ops[];
@@ -1215,13 +1224,23 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 		if (op->status)
 			goto encode_op;
 
-		if (opdesc->op_func)
+		if (opdesc->op_func) {
+			if (opdesc->op_get_currentstateid)
+				opdesc->op_get_currentstateid(cstate, &op->u);
 			op->status = opdesc->op_func(rqstp, cstate, &op->u);
-		else
+		} else
 			BUG_ON(op->status == nfs_ok);
 
-		if (!op->status && need_wrongsec_check(rqstp))
-			op->status = check_nfsd_access(cstate->current_fh.fh_export, rqstp);
+		if (!op->status) {
+			if (opdesc->op_set_currentstateid)
+				opdesc->op_set_currentstateid(cstate, &op->u);
+
+			if (opdesc->op_flags & OP_CLEAR_STATEID)
+				cstate->current_stateid = NULL;
+
+			if (need_wrongsec_check(rqstp))
+				op->status = check_nfsd_access(cstate->current_fh.fh_export, rqstp);
+		}
 
 encode_op:
 		/* Only from SEQUENCE */
@@ -1413,6 +1432,8 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_flags = OP_MODIFIES_SOMETHING,
 		.op_name = "OP_CLOSE",
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_status_stateid_rsize,
+		.op_get_currentstateid = (stateid_getter)nfsd4_get_closestateid,
+		.op_set_currentstateid = (stateid_setter)nfsd4_set_closestateid,
 	},
 	[OP_COMMIT] = {
 		.op_func = (nfsd4op_func)nfsd4_commit,
@@ -1483,6 +1504,7 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_flags = OP_HANDLES_WRONGSEC | OP_MODIFIES_SOMETHING,
 		.op_name = "OP_OPEN",
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_open_rsize,
+		.op_set_currentstateid = (stateid_setter)nfsd4_set_openstateid,
 	},
 	[OP_OPEN_CONFIRM] = {
 		.op_func = (nfsd4op_func)nfsd4_open_confirm,
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 8ca5ed1..6322a59 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4695,3 +4695,35 @@ nfs4_state_shutdown(void)
 	nfs4_unlock_state();
 	nfsd4_destroy_callback_queue();
 }
+
+static void
+get_stateid(struct nfsd4_compound_state *cstate, stateid_t *stateid)
+{
+	if (cstate->current_stateid && CURRENT_STATEID(stateid))
+		memcpy(stateid, cstate->current_stateid, sizeof(stateid_t));
+}
+
+static void
+put_stateid(struct nfsd4_compound_state *cstate, stateid_t *stateid)
+{
+	if (cstate->minorversion)
+		cstate->current_stateid = stateid;
+}
+
+void
+nfsd4_set_openstateid(struct nfsd4_compound_state *cstate, struct nfsd4_open *open)
+{
+	put_stateid(cstate, &open->op_stateid);
+}
+
+void
+nfsd4_get_closestateid(struct nfsd4_compound_state *cstate, struct nfsd4_close *close)
+{
+	get_stateid(cstate, &close->cl_stateid);
+}
+
+void
+nfsd4_set_closestateid(struct nfsd4_compound_state *cstate, struct nfsd4_close *close)
+{
+	get_stateid(cstate, &close->cl_stateid);
+}
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 2364747..c1fe8ba 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -54,6 +54,7 @@ struct nfsd4_compound_state {
 	size_t			iovlen;
 	u32			minorversion;
 	u32			status;
+	const stateid_t	*current_stateid;
 };
 
 static inline bool nfsd4_has_session(struct nfsd4_compound_state *cs)
-- 
1.7.7.6


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:62622 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753965Ab1LLU6Z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Dec 2011 15:58:25 -0500
Received: by mail-ee0-f46.google.com with SMTP id c4so1814320eek.19
        for <linux-nfs@vger.kernel.org>; Mon, 12 Dec 2011 12:58:24 -0800 (PST)
From: Tigran Mkrtchyan <kofemann@googlemail.com>
To: linux-nfs@vger.kernel.org
Cc: Tigran Mkrtchyan <kofemann@gmail.com>
Subject: [PATH v4 1/3] nfsd41: handle current stateid in open and close
Date: Mon, 12 Dec 2011 22:00:25 +0100
Message-Id: <1323723627-413-2-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1323723627-413-1-git-send-email-tigran.mkrtchyan@desy.de>
References: <1323723627-413-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tigran Mkrtchyan <kofemann@gmail.com>


Signed-off-by: Tigran Mkrtchyan <kofemann@gmail.com>
---
 fs/nfsd/current_stateid.h |   11 +++++++++++
 fs/nfsd/nfs4proc.c        |   35 ++++++++++++++++++++++++++++++-----
 fs/nfsd/nfs4state.c       |   36 ++++++++++++++++++++++++++++++++++++
 fs/nfsd/xdr4.h            |    1 +
 4 files changed, 78 insertions(+), 5 deletions(-)
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
index fa38336..3dfb235 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -39,6 +39,7 @@
 #include "cache.h"
 #include "xdr4.h"
 #include "vfs.h"
+#include "current_stateid.h"
 
 #define NFSDDBG_FACILITY		NFSDDBG_PROC
 
@@ -556,7 +557,6 @@ nfsd4_create(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 				     create->cr_name, create->cr_namelen,
 				     &create->cr_iattr, S_IFSOCK, 0, &resfh);
 		break;
-
 	case NF4FIFO:
 		status = nfsd_create(rqstp, &cstate->current_fh,
 				     create->cr_name, create->cr_namelen,
@@ -1001,6 +1001,9 @@ static inline void nfsd4_increment_op_stats(u32 opnum)
 typedef __be32(*nfsd4op_func)(struct svc_rqst *, struct nfsd4_compound_state *,
 			      void *);
 typedef u32(*nfsd4op_rsize)(struct svc_rqst *, struct nfsd4_op *op);
+typedef void(*stateid_setter)(struct nfsd4_compound_state *, void *);
+typedef void(*stateid_getter)(struct nfsd4_compound_state *, void *);
+typedef void(*stateid_cleaner)(struct nfsd4_compound_state *);
 
 enum nfsd4_op_flags {
 	ALLOWED_WITHOUT_FH = 1 << 0,	/* No current filehandle required */
@@ -1034,6 +1037,9 @@ struct nfsd4_operation {
 	char *op_name;
 	/* Try to get response size before operation */
 	nfsd4op_rsize op_rsize_bop;
+	stateid_setter op_get_currentstateid;
+	stateid_getter op_set_currentstateid;
+	stateid_cleaner op_clear_currentstateid;
 };
 
 static struct nfsd4_operation nfsd4_ops[];
@@ -1116,6 +1122,11 @@ static bool need_wrongsec_check(struct svc_rqst *rqstp)
 	return !(nextd->op_flags & OP_HANDLES_WRONGSEC);
 }
 
+static void
+nfsd4_clear_currentstateid(struct nfsd4_compound_state *cstate)
+{
+	cstate->current_stateid = NULL;
+}
 /*
  * COMPOUND call.
  */
@@ -1216,13 +1227,24 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
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
+			if (opdesc->op_set_currentstateid) {
+				opdesc->op_set_currentstateid(cstate, &op->u);
+			}
+
+			if (opdesc->op_clear_currentstateid)
+				opdesc->op_clear_currentstateid(cstate);
+
+			if (need_wrongsec_check(rqstp))
+				op->status = check_nfsd_access(cstate->current_fh.fh_export, rqstp);
+		}
 
 encode_op:
 		/* Only from SEQUENCE */
@@ -1414,6 +1436,8 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_flags = OP_MODIFIES_SOMETHING,
 		.op_name = "OP_CLOSE",
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_status_stateid_rsize,
+		.op_get_currentstateid = (stateid_getter)nfsd4_get_closestateid,
+		.op_set_currentstateid = (stateid_setter)nfsd4_set_closestateid,
 	},
 	[OP_COMMIT] = {
 		.op_func = (nfsd4op_func)nfsd4_commit,
@@ -1484,6 +1508,7 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_flags = OP_HANDLES_WRONGSEC | OP_MODIFIES_SOMETHING,
 		.op_name = "OP_OPEN",
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_open_rsize,
+		.op_set_currentstateid = (stateid_setter)nfsd4_set_openstateid,
 	},
 	[OP_OPEN_CONFIRM] = {
 		.op_func = (nfsd4op_func)nfsd4_open_confirm,
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 47e94e3..594b44e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -51,10 +51,12 @@ time_t nfsd4_grace = 90;
 static time_t boot_time;
 static stateid_t zerostateid;             /* bits all 0 */
 static stateid_t onestateid;              /* bits all 1 */
+static stateid_t currentstateid;         /* other all 0, seqid 1 */
 static u64 current_sessionid = 1;
 
 #define ZERO_STATEID(stateid) (!memcmp((stateid), &zerostateid, sizeof(stateid_t)))
 #define ONE_STATEID(stateid)  (!memcmp((stateid), &onestateid, sizeof(stateid_t)))
+#define CURRENT_STATEID(stateid) (!memcmp((stateid), &currentstateid, sizeof(stateid_t)))
 
 /* forward declarations */
 static int check_for_locks(struct nfs4_file *filp, struct nfs4_lockowner *lowner);
@@ -4423,6 +4425,8 @@ nfs4_state_init(void)
 		INIT_LIST_HEAD(&lock_ownerstr_hashtbl[i]);
 	}
 	memset(&onestateid, ~0, sizeof(stateid_t));
+	/* seqid 1, other all 0 */
+	currentstateid.si_generation = 1;
 	INIT_LIST_HEAD(&close_lru);
 	INIT_LIST_HEAD(&client_lru);
 	INIT_LIST_HEAD(&del_recall_lru);
@@ -4545,3 +4549,35 @@ nfs4_state_shutdown(void)
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
1.7.7.4


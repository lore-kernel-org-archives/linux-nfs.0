Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:43833 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752853Ab1LFVm1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Dec 2011 16:42:27 -0500
Received: by eekd41 with SMTP id d41so702eek.19
        for <linux-nfs@vger.kernel.org>; Tue, 06 Dec 2011 13:42:26 -0800 (PST)
From: Tigran Mkrtchyan <kofemann@googlemail.com>
To: linux-nfs@vger.kernel.org
Cc: Tigran Mkrtchyan <kofemann@gmail.com>
Subject: [PATCH] nfsd41: handle current stateid in open and close
Date: Tue,  6 Dec 2011 22:44:07 +0100
Message-Id: <1323207847-19118-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tigran Mkrtchyan <kofemann@gmail.com>


Signed-off-by: Tigran Mkrtchyan <kofemann@gmail.com>
---
 fs/nfsd/current_stateid.h |   44 ++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfs4proc.c        |   22 ++++++++++++++++++----
 fs/nfsd/nfs4state.c       |   17 +++++++++++++++++
 fs/nfsd/xdr4.h            |    1 +
 4 files changed, 80 insertions(+), 4 deletions(-)
 create mode 100644 fs/nfsd/current_stateid.h

diff --git a/fs/nfsd/current_stateid.h b/fs/nfsd/current_stateid.h
new file mode 100644
index 0000000..f1ad6e9
--- /dev/null
+++ b/fs/nfsd/current_stateid.h
@@ -0,0 +1,44 @@
+/*
+ *  Copyright (c) 2001 The Regents of the University of Michigan.
+ *  All rights reserved.
+ *
+ *  Kendrick Smith <kmsmith@umich.edu>
+ *  Andy Adamson <andros@umich.edu>
+ *  
+ *  Redistribution and use in source and binary forms, with or without
+ *  modification, are permitted provided that the following conditions
+ *  are met:
+ *  
+ *  1. Redistributions of source code must retain the above copyright
+ *     notice, this list of conditions and the following disclaimer.
+ *  2. Redistributions in binary form must reproduce the above copyright
+ *     notice, this list of conditions and the following disclaimer in the
+ *     documentation and/or other materials provided with the distribution.
+ *  3. Neither the name of the University nor the names of its
+ *     contributors may be used to endorse or promote products derived
+ *     from this software without specific prior written permission.
+ *
+ *  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
+ *  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
+ *  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ *  DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
+ *  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
+ *  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
+ *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
+ *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ */
+
+#ifndef _NFSD4_CURRENT_STATE_H
+#define _NFSD4_CURRENT_STATE_H
+
+#include "state.h"
+#include "xdr4.h"
+
+extern void nfsd4_set_openstateid(struct nfsd4_compound_state *cstate, struct nfsd4_open *open);
+extern void nfsd4_get_closestateid(struct nfsd4_compound_state *cstate, struct nfsd4_close *close);
+
+#endif   /* _NFSD4_CURRENT_STATE_H */
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index fa38336..bfed3cb 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -39,6 +39,7 @@
 #include "cache.h"
 #include "xdr4.h"
 #include "vfs.h"
+#include "current_stateid.h"
 
 #define NFSDDBG_FACILITY		NFSDDBG_PROC
 
@@ -1001,6 +1002,8 @@ static inline void nfsd4_increment_op_stats(u32 opnum)
 typedef __be32(*nfsd4op_func)(struct svc_rqst *, struct nfsd4_compound_state *,
 			      void *);
 typedef u32(*nfsd4op_rsize)(struct svc_rqst *, struct nfsd4_op *op);
+typedef void(*stateid_setter)(struct nfsd4_compound_state *, void *);
+typedef void(*stateid_getter)(struct nfsd4_compound_state *, void *);
 
 enum nfsd4_op_flags {
 	ALLOWED_WITHOUT_FH = 1 << 0,	/* No current filehandle required */
@@ -1026,6 +1029,8 @@ enum nfsd4_op_flags {
 	 * the v4.0 case).
 	 */
 	OP_CACHEME = 1 << 6,
+	CONSUMES_CURRENT_STATEID = 1 << 7,
+	PROVIDES_CURRENT_STATEID = 1 << 8,
 };
 
 struct nfsd4_operation {
@@ -1034,6 +1039,8 @@ struct nfsd4_operation {
 	char *op_name;
 	/* Try to get response size before operation */
 	nfsd4op_rsize op_rsize_bop;
+	stateid_setter op_get_currentstateid;
+	stateid_getter op_set_currentstateid;
 };
 
 static struct nfsd4_operation nfsd4_ops[];
@@ -1216,11 +1223,16 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 		if (op->status)
 			goto encode_op;
 
-		if (opdesc->op_func)
+		if (opdesc->op_func) {
+			if (opdesc->op_flags & CONSUMES_CURRENT_STATEID)
+				opdesc->op_get_currentstateid(cstate, &op->u);
 			op->status = opdesc->op_func(rqstp, cstate, &op->u);
-		else
+		} else
 			BUG_ON(op->status == nfs_ok);
 
+		if (!op->status && opdesc->op_flags & PROVIDES_CURRENT_STATEID)
+			opdesc->op_set_currentstateid(cstate, &op->u);
+
 		if (!op->status && need_wrongsec_check(rqstp))
 			op->status = check_nfsd_access(cstate->current_fh.fh_export, rqstp);
 
@@ -1411,9 +1423,10 @@ static struct nfsd4_operation nfsd4_ops[] = {
 	},
 	[OP_CLOSE] = {
 		.op_func = (nfsd4op_func)nfsd4_close,
-		.op_flags = OP_MODIFIES_SOMETHING,
+		.op_flags = OP_MODIFIES_SOMETHING | CONSUMES_CURRENT_STATEID,
 		.op_name = "OP_CLOSE",
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_status_stateid_rsize,
+		.op_get_currentstateid = (stateid_getter)nfsd4_get_closestateid,
 	},
 	[OP_COMMIT] = {
 		.op_func = (nfsd4op_func)nfsd4_commit,
@@ -1481,9 +1494,10 @@ static struct nfsd4_operation nfsd4_ops[] = {
 	},
 	[OP_OPEN] = {
 		.op_func = (nfsd4op_func)nfsd4_open,
-		.op_flags = OP_HANDLES_WRONGSEC | OP_MODIFIES_SOMETHING,
+		.op_flags = OP_HANDLES_WRONGSEC | OP_MODIFIES_SOMETHING | PROVIDES_CURRENT_STATEID,
 		.op_name = "OP_OPEN",
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_open_rsize,
+		.op_set_currentstateid = (stateid_setter)nfsd4_set_openstateid,
 	},
 	[OP_OPEN_CONFIRM] = {
 		.op_func = (nfsd4op_func)nfsd4_open_confirm,
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 47e94e3..9dc1de8 100644
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
@@ -4545,3 +4549,16 @@ nfs4_state_shutdown(void)
 	nfs4_unlock_state();
 	nfsd4_destroy_callback_queue();
 }
+
+void
+nfsd4_set_openstateid(struct nfsd4_compound_state *cstate, struct nfsd4_open *open)
+{
+	memcpy(&cstate->current_stateid, &open->op_stateid, sizeof(stateid_t));
+}
+
+void
+nfsd4_get_closestateid(struct nfsd4_compound_state *cstate, struct nfsd4_close *close)
+{
+	if (CURRENT_STATEID(&close->cl_stateid))
+		 memcpy(&close->cl_stateid, &cstate->current_stateid, sizeof(stateid_t));
+}
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 2364747..96f9966 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -54,6 +54,7 @@ struct nfsd4_compound_state {
 	size_t			iovlen;
 	u32			minorversion;
 	u32			status;
+	stateid_t               current_stateid;
 };
 
 static inline bool nfsd4_has_session(struct nfsd4_compound_state *cs)
-- 
1.7.7.3


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:40918 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752121Ab1LKQj5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 11 Dec 2011 11:39:57 -0500
Received: by mail-ee0-f46.google.com with SMTP id c4so1219348eek.19
        for <linux-nfs@vger.kernel.org>; Sun, 11 Dec 2011 08:39:56 -0800 (PST)
From: Tigran Mkrtchyan <kofemann@googlemail.com>
To: linux-nfs@vger.kernel.org
Cc: Tigran Mkrtchyan <kofemann@gmail.com>
Subject: [PATH v3 2/5] nfsd41: handle current stateid on lock and locku
Date: Sun, 11 Dec 2011 17:41:45 +0100
Message-Id: <1323621708-25138-3-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1323621708-25138-1-git-send-email-tigran.mkrtchyan@desy.de>
References: <1323621708-25138-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tigran Mkrtchyan <kofemann@gmail.com>

plus minor fixes

Signed-off-by: Tigran Mkrtchyan <kofemann@gmail.com>
---
 fs/nfsd/current_stateid.h |   11 ++++++++++-
 fs/nfsd/nfs4proc.c        |    8 +++++---
 fs/nfsd/nfs4state.c       |   22 ++++++++++++++++++++--
 3 files changed, 35 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/current_stateid.h b/fs/nfsd/current_stateid.h
index a83dd50..21550b6 100644
--- a/fs/nfsd/current_stateid.h
+++ b/fs/nfsd/current_stateid.h
@@ -4,8 +4,17 @@
 #include "state.h"
 #include "xdr4.h"
 
+/*
+ * functions to set current state id
+ */
 extern void nfsd4_set_openstateid(struct nfsd4_compound_state *, struct nfsd4_open *);
-extern void nfsd4_get_closestateid(struct nfsd4_compound_state *, struct nfsd4_close *);
+extern void nfsd4_set_lockstateid(struct nfsd4_compound_state *, struct nfsd4_lock *);
 extern void nfsd4_set_closestateid(struct nfsd4_compound_state *, struct nfsd4_close *);
 
+/*
+ * functions to consume current state id
+ */
+extern void nfsd4_get_closestateid(struct nfsd4_compound_state *, struct nfsd4_close *);
+extern void nfsd4_get_lockustateid(struct nfsd4_compound_state *, struct nfsd4_locku *);
+
 #endif   /* _NFSD4_CURRENT_STATE_H */
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 4b8d81a..70534a0 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1441,7 +1441,7 @@ static struct nfsd4_operation nfsd4_ops[] = {
 	},
 	[OP_CLOSE] = {
 		.op_func = (nfsd4op_func)nfsd4_close,
-		.op_flags = OP_MODIFIES_SOMETHING | CONSUMES_CURRENT_STATEID,
+		.op_flags = OP_MODIFIES_SOMETHING | CONSUMES_CURRENT_STATEID | PROVIDES_CURRENT_STATEID,
 		.op_name = "OP_CLOSE",
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_status_stateid_rsize,
 		.op_get_currentstateid = (stateid_getter)nfsd4_get_closestateid,
@@ -1483,9 +1483,10 @@ static struct nfsd4_operation nfsd4_ops[] = {
 	},
 	[OP_LOCK] = {
 		.op_func = (nfsd4op_func)nfsd4_lock,
-		.op_flags = OP_MODIFIES_SOMETHING,
+		.op_flags = OP_MODIFIES_SOMETHING | PROVIDES_CURRENT_STATEID,
 		.op_name = "OP_LOCK",
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_lock_rsize,
+		.op_set_currentstateid = (stateid_setter)nfsd4_set_lockstateid,
 	},
 	[OP_LOCKT] = {
 		.op_func = (nfsd4op_func)nfsd4_lockt,
@@ -1493,9 +1494,10 @@ static struct nfsd4_operation nfsd4_ops[] = {
 	},
 	[OP_LOCKU] = {
 		.op_func = (nfsd4op_func)nfsd4_locku,
-		.op_flags = OP_MODIFIES_SOMETHING,
+		.op_flags = OP_MODIFIES_SOMETHING | CONSUMES_CURRENT_STATEID,
 		.op_name = "OP_LOCKU",
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_status_stateid_rsize,
+		.op_get_currentstateid = (stateid_getter)nfsd4_get_lockustateid,
 	},
 	[OP_LOOKUP] = {
 		.op_func = (nfsd4op_func)nfsd4_lookup,
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 278e0af..fd10283 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4564,6 +4564,9 @@ put_stateid(struct nfsd4_compound_state *cstate, stateid_t *stateid)
 		memcpy(&cstate->current_stateid, stateid, sizeof(stateid_t));
 }
 
+/*
+ * functions to set current state id
+ */
 void
 nfsd4_set_openstateid(struct nfsd4_compound_state *cstate, struct nfsd4_open *open)
 {
@@ -4571,13 +4574,28 @@ nfsd4_set_openstateid(struct nfsd4_compound_state *cstate, struct nfsd4_open *op
 }
 
 void
+nfsd4_set_closestateid(struct nfsd4_compound_state *cstate, struct nfsd4_close *close)
+{
+	put_stateid(cstate, &close->cl_stateid);
+}
+
+void
+nfsd4_set_lockstateid(struct nfsd4_compound_state *cstate, struct nfsd4_lock *lock)
+{
+	put_stateid(cstate, &lock->lk_resp_stateid);
+}
+
+/*
+ * functions to consume current state id
+ */
+void
 nfsd4_get_closestateid(struct nfsd4_compound_state *cstate, struct nfsd4_close *close)
 {
 	get_stateid(cstate, &close->cl_stateid);
 }
 
 void
-nfsd4_set_closestateid(struct nfsd4_compound_state *cstate, struct nfsd4_close *close)
+nfsd4_get_lockustateid(struct nfsd4_compound_state *cstate, struct nfsd4_locku *locku)
 {
-	get_stateid(cstate, &close->cl_stateid);
+	get_stateid(cstate, &locku->lu_stateid);
 }
-- 
1.7.7.4


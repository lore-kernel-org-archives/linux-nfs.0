Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ey0-f174.google.com ([209.85.215.174]:63705 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753904Ab1LLU60 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Dec 2011 15:58:26 -0500
Received: by eaaj10 with SMTP id j10so849656eaa.19
        for <linux-nfs@vger.kernel.org>; Mon, 12 Dec 2011 12:58:25 -0800 (PST)
From: Tigran Mkrtchyan <kofemann@googlemail.com>
To: linux-nfs@vger.kernel.org
Cc: Tigran Mkrtchyan <kofemann@gmail.com>
Subject: [PATH v4 2/3] nfsd41: handle current stateid on lock and locku
Date: Mon, 12 Dec 2011 22:00:26 +0100
Message-Id: <1323723627-413-3-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1323723627-413-1-git-send-email-tigran.mkrtchyan@desy.de>
References: <1323723627-413-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tigran Mkrtchyan <kofemann@gmail.com>

plus minor fixes

Conflicts:

	fs/nfsd/nfs4proc.c

Signed-off-by: Tigran Mkrtchyan <kofemann@gmail.com>
---
 fs/nfsd/current_stateid.h |   11 ++++++++++-
 fs/nfsd/nfs4proc.c        |    2 ++
 fs/nfsd/nfs4state.c       |   22 ++++++++++++++++++++--
 3 files changed, 32 insertions(+), 3 deletions(-)

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
index 3dfb235..90c532b 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1478,6 +1478,7 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_flags = OP_MODIFIES_SOMETHING,
 		.op_name = "OP_LOCK",
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_lock_rsize,
+		.op_set_currentstateid = (stateid_setter)nfsd4_set_lockstateid,
 	},
 	[OP_LOCKT] = {
 		.op_func = (nfsd4op_func)nfsd4_lockt,
@@ -1488,6 +1489,7 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_flags = OP_MODIFIES_SOMETHING,
 		.op_name = "OP_LOCKU",
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_status_stateid_rsize,
+		.op_get_currentstateid = (stateid_getter)nfsd4_get_lockustateid,
 	},
 	[OP_LOOKUP] = {
 		.op_func = (nfsd4op_func)nfsd4_lookup,
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 594b44e..58410b2 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4564,6 +4564,9 @@ put_stateid(struct nfsd4_compound_state *cstate, stateid_t *stateid)
 		cstate->current_stateid = stateid;
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


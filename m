Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ey0-f174.google.com ([209.85.215.174]:58266 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751799Ab2BERFE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 5 Feb 2012 12:05:04 -0500
Received: by mail-ey0-f174.google.com with SMTP id h12so2181895eaa.19
        for <linux-nfs@vger.kernel.org>; Sun, 05 Feb 2012 09:05:03 -0800 (PST)
From: Tigran Mkrtchyan <kofemann@googlemail.com>
To: linux-nfs@vger.kernel.org, bfields@fieldses.org
Cc: Tigran Mkrtchyan <kofemann@gmail.com>
Subject: [PATH v8 10/10] nfsd41: use current stateid by value
Date: Sun,  5 Feb 2012 18:07:59 +0100
Message-Id: <1328461679-4108-11-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1328461679-4108-1-git-send-email-tigran.mkrtchyan@desy.de>
References: <1328461679-4108-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tigran Mkrtchyan <kofemann@gmail.com>


Signed-off-by: Tigran Mkrtchyan <kofemann@gmail.com>
---
 fs/nfsd/current_stateid.h |    1 +
 fs/nfsd/nfs4proc.c        |   12 +++++++++---
 fs/nfsd/nfs4state.c       |   16 ++++++++++++----
 fs/nfsd/xdr4.h            |   13 +++++++++++--
 4 files changed, 33 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/current_stateid.h b/fs/nfsd/current_stateid.h
index d8c9992..4123551 100644
--- a/fs/nfsd/current_stateid.h
+++ b/fs/nfsd/current_stateid.h
@@ -4,6 +4,7 @@
 #include "state.h"
 #include "xdr4.h"
 
+extern void clear_current_stateid(struct nfsd4_compound_state *cstate);
 /*
  * functions to set current state id
  */
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index dffc9bd..c45ad2f 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -453,7 +453,10 @@ nfsd4_restorefh(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		return nfserr_restorefh;
 
 	fh_dup2(&cstate->current_fh, &cstate->save_fh);
-	cstate->current_stateid = cstate->save_stateid;
+	if (HAS_STATE_ID(cstate, SAVED_STATE_ID_FLAG)) {
+		memcpy(&cstate->current_stateid, &cstate->save_stateid, sizeof(stateid_t));
+		SET_STATE_ID(cstate, CURRENT_STATE_ID_FLAG);
+	}
 	return nfs_ok;
 }
 
@@ -465,7 +468,10 @@ nfsd4_savefh(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		return nfserr_nofilehandle;
 
 	fh_dup2(&cstate->save_fh, &cstate->current_fh);
-	cstate->save_stateid = cstate->current_stateid;
+	if (HAS_STATE_ID(cstate, CURRENT_STATE_ID_FLAG)) {
+		memcpy(&cstate->save_stateid, &cstate->current_stateid, sizeof(stateid_t));
+		SET_STATE_ID(cstate, SAVED_STATE_ID_FLAG);
+	}
 	return nfs_ok;
 }
 
@@ -1238,7 +1244,7 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 				opdesc->op_set_currentstateid(cstate, &op->u);
 
 			if (opdesc->op_flags & OP_CLEAR_STATEID)
-				cstate->current_stateid = NULL;
+				clear_current_stateid(cstate);
 
 			if (need_wrongsec_check(rqstp))
 				op->status = check_nfsd_access(cstate->current_fh.fh_export, rqstp);
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 9c5a239..8c49a89 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4699,15 +4699,23 @@ nfs4_state_shutdown(void)
 static void
 get_stateid(struct nfsd4_compound_state *cstate, stateid_t *stateid)
 {
-	if (cstate->current_stateid && CURRENT_STATEID(stateid))
-		memcpy(stateid, cstate->current_stateid, sizeof(stateid_t));
+	if (HAS_STATE_ID(cstate, CURRENT_STATE_ID_FLAG) && CURRENT_STATEID(stateid))
+		memcpy(stateid, &cstate->current_stateid, sizeof(stateid_t));
 }
 
 static void
 put_stateid(struct nfsd4_compound_state *cstate, stateid_t *stateid)
 {
-	if (cstate->minorversion)
-		cstate->current_stateid = stateid;
+	if (cstate->minorversion) {
+		memcpy(&cstate->current_stateid, stateid, sizeof(stateid_t));
+		SET_STATE_ID(cstate, CURRENT_STATE_ID_FLAG);
+	}
+}
+
+void
+clear_current_stateid(struct nfsd4_compound_state *cstate)
+{
+	CLEAR_STATE_ID(cstate, CURRENT_STATE_ID_FLAG);
 }
 
 /*
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 2ae378e..4ee102a 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -43,6 +43,13 @@
 #define NFSD4_MAX_TAGLEN	128
 #define XDR_LEN(n)                     (((n) + 3) & ~3)
 
+#define CURRENT_STATE_ID_FLAG 1
+#define SAVED_STATE_ID_FLAG 2
+
+#define SET_STATE_ID(c, f) (c->sid_flags |= f)
+#define HAS_STATE_ID(c, f) (c->sid_flags & f)
+#define CLEAR_STATE_ID(c, f) (c->sid_flags &=  ~f)
+
 struct nfsd4_compound_state {
 	struct svc_fh		current_fh;
 	struct svc_fh		save_fh;
@@ -54,8 +61,10 @@ struct nfsd4_compound_state {
 	size_t			iovlen;
 	u32			minorversion;
 	u32			status;
-	const stateid_t	*current_stateid;
-	const stateid_t	*save_stateid;
+	stateid_t	current_stateid;
+	stateid_t	save_stateid;
+	/* to indicate current and saved state id presents */
+	u32		sid_flags;
 };
 
 static inline bool nfsd4_has_session(struct nfsd4_compound_state *cs)
-- 
1.7.7.6


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:61117 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932865AbbIDRaE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Sep 2015 13:30:04 -0400
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <anna.schumaker@netapp.com>, <bfields@fieldses.org>,
        <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 11/16] NFSD generalize nfsd4_compound_state flag names
Date: Fri, 4 Sep 2015 13:29:33 -0400
Message-ID: <1441387778-16465-12-git-send-email-andros@netapp.com>
In-Reply-To: <1441387778-16465-1-git-send-email-andros@netapp.com>
References: <1441387778-16465-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Allow for sid_flag field non-stateid use.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4proc.c  | 8 ++++----
 fs/nfsd/nfs4state.c | 7 ++++---
 fs/nfsd/xdr4.h      | 6 +++---
 3 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index ef6409e..f81d050 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -538,9 +538,9 @@ nfsd4_restorefh(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		return nfserr_restorefh;
 
 	fh_dup2(&cstate->current_fh, &cstate->save_fh);
-	if (HAS_STATE_ID(cstate, SAVED_STATE_ID_FLAG)) {
+	if (HAS_CSTATE_FLAG(cstate, SAVED_STATE_ID_FLAG)) {
 		memcpy(&cstate->current_stateid, &cstate->save_stateid, sizeof(stateid_t));
-		SET_STATE_ID(cstate, CURRENT_STATE_ID_FLAG);
+		SET_CSTATE_FLAG(cstate, CURRENT_STATE_ID_FLAG);
 	}
 	return nfs_ok;
 }
@@ -553,9 +553,9 @@ nfsd4_savefh(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		return nfserr_nofilehandle;
 
 	fh_dup2(&cstate->save_fh, &cstate->current_fh);
-	if (HAS_STATE_ID(cstate, CURRENT_STATE_ID_FLAG)) {
+	if (HAS_CSTATE_FLAG(cstate, CURRENT_STATE_ID_FLAG)) {
 		memcpy(&cstate->save_stateid, &cstate->current_stateid, sizeof(stateid_t));
-		SET_STATE_ID(cstate, SAVED_STATE_ID_FLAG);
+		SET_CSTATE_FLAG(cstate, SAVED_STATE_ID_FLAG);
 	}
 	return nfs_ok;
 }
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 7b0059d..96de0d3 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -6660,7 +6660,8 @@ nfs4_state_shutdown(void)
 static void
 get_stateid(struct nfsd4_compound_state *cstate, stateid_t *stateid)
 {
-	if (HAS_STATE_ID(cstate, CURRENT_STATE_ID_FLAG) && CURRENT_STATEID(stateid))
+	if (HAS_CSTATE_FLAG(cstate, CURRENT_STATE_ID_FLAG) &&
+	    CURRENT_STATEID(stateid))
 		memcpy(stateid, &cstate->current_stateid, sizeof(stateid_t));
 }
 
@@ -6669,14 +6670,14 @@ put_stateid(struct nfsd4_compound_state *cstate, stateid_t *stateid)
 {
 	if (cstate->minorversion) {
 		memcpy(&cstate->current_stateid, stateid, sizeof(stateid_t));
-		SET_STATE_ID(cstate, CURRENT_STATE_ID_FLAG);
+		SET_CSTATE_FLAG(cstate, CURRENT_STATE_ID_FLAG);
 	}
 }
 
 void
 clear_current_stateid(struct nfsd4_compound_state *cstate)
 {
-	CLEAR_STATE_ID(cstate, CURRENT_STATE_ID_FLAG);
+	CLEAR_CSTATE_FLAG(cstate, CURRENT_STATE_ID_FLAG);
 }
 
 /*
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index e4461f1..2471e34 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -47,9 +47,9 @@
 #define CURRENT_STATE_ID_FLAG (1<<0)
 #define SAVED_STATE_ID_FLAG (1<<1)
 
-#define SET_STATE_ID(c, f) ((c)->sid_flags |= (f))
-#define HAS_STATE_ID(c, f) ((c)->sid_flags & (f))
-#define CLEAR_STATE_ID(c, f) ((c)->sid_flags &= ~(f))
+#define SET_CSTATE_FLAG(c, f) ((c)->sid_flags |= (f))
+#define HAS_CSTATE_FLAG(c, f) ((c)->sid_flags & (f))
+#define CLEAR_CSTATE_FLAG(c, f) ((c)->sid_flags &= ~(f))
 
 struct nfsd4_compound_state {
 	struct svc_fh		current_fh;
-- 
1.8.3.1


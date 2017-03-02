Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:30149 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752664AbdCBQPB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 2 Mar 2017 11:15:01 -0500
From: Olga Kornievskaia <kolga@netapp.com>
To: <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [RFC v1 03/18] NFSD generalize nfsd4_compound_state flag names
Date: Thu, 2 Mar 2017 11:01:27 -0500
Message-ID: <20170302160142.30413-4-kolga@netapp.com>
In-Reply-To: <20170302160142.30413-1-kolga@netapp.com>
References: <20170302160142.30413-1-kolga@netapp.com>
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
index bcd3c51..a680c8c 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -522,9 +522,9 @@ static __be32 nfsd4_open_omfg(struct svc_rqst *rqstp, struct nfsd4_compound_stat
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
@@ -537,9 +537,9 @@ static __be32 nfsd4_open_omfg(struct svc_rqst *rqstp, struct nfsd4_compound_stat
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
index e9ef50a..1d307a7 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -7093,7 +7093,8 @@ static int nfs4_state_create_net(struct net *net)
 static void
 get_stateid(struct nfsd4_compound_state *cstate, stateid_t *stateid)
 {
-	if (HAS_STATE_ID(cstate, CURRENT_STATE_ID_FLAG) && CURRENT_STATEID(stateid))
+	if (HAS_CSTATE_FLAG(cstate, CURRENT_STATE_ID_FLAG) &&
+	    CURRENT_STATEID(stateid))
 		memcpy(stateid, &cstate->current_stateid, sizeof(stateid_t));
 }
 
@@ -7102,14 +7103,14 @@ static int nfs4_state_create_net(struct net *net)
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
index 5db7cd8..38fcb4f 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -46,9 +46,9 @@
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


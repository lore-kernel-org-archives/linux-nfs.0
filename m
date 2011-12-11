Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:40918 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752133Ab1LKQkA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 11 Dec 2011 11:40:00 -0500
Received: by mail-ee0-f46.google.com with SMTP id c4so1219348eek.19
        for <linux-nfs@vger.kernel.org>; Sun, 11 Dec 2011 08:40:00 -0800 (PST)
From: Tigran Mkrtchyan <kofemann@googlemail.com>
To: linux-nfs@vger.kernel.org
Cc: Tigran Mkrtchyan <kofemann@gmail.com>
Subject: [PATH v3 5/5] nfsd41: use pinter to current stateid to avoid extra copy
Date: Sun, 11 Dec 2011 17:41:48 +0100
Message-Id: <1323621708-25138-6-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1323621708-25138-1-git-send-email-tigran.mkrtchyan@desy.de>
References: <1323621708-25138-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tigran Mkrtchyan <kofemann@gmail.com>


Signed-off-by: Tigran Mkrtchyan <kofemann@gmail.com>
---
 fs/nfsd/nfs4proc.c  |    6 +-----
 fs/nfsd/nfs4state.c |    7 +++----
 fs/nfsd/xdr4.h      |    3 +--
 3 files changed, 5 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index f2f7dfa..b7d1a7b 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1126,10 +1126,7 @@ static bool need_wrongsec_check(struct svc_rqst *rqstp)
 static void
 nfsd4_clear_currentstateid(struct nfsd4_compound_state *cstate)
 {
-	if (cstate->has_stateid) {
-		memset(&cstate->current_stateid, 0, sizeof(stateid_t));
-		cstate->has_stateid = false;
-	}
+	cstate->current_stateid = NULL;
 }
 /*
  * COMPOUND call.
@@ -1244,7 +1241,6 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 		if (!op->status) {
 			if (opdesc->op_flags & PROVIDES_CURRENT_STATEID) {
 				opdesc->op_set_currentstateid(cstate, &op->u);
-				cstate->has_stateid = true;
 			}
 
 			if (opdesc->op_flags & CLEARS_CURRENT_STATEID)
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d7b8f25..be77cd3 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4553,16 +4553,15 @@ nfs4_state_shutdown(void)
 static void
 get_stateid(struct nfsd4_compound_state *cstate, stateid_t *stateid)
 {
-	if (cstate->has_stateid && CURRENT_STATEID(stateid))
-		memcpy(stateid, &cstate->current_stateid, sizeof(stateid_t));
+	if (cstate->current_stateid && CURRENT_STATEID(stateid))
+		memcpy(stateid, cstate->current_stateid, sizeof(stateid_t));
 }
 
 static void
 put_stateid(struct nfsd4_compound_state *cstate, stateid_t *stateid)
 {
 	if (cstate->minorversion) {
-		memcpy(&cstate->current_stateid, stateid, sizeof(stateid_t));
-		cstate->has_stateid = true;
+		cstate->current_stateid = stateid;
 	}
 }
 
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index b8435d20..0ad0846 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -54,8 +54,7 @@ struct nfsd4_compound_state {
 	size_t			iovlen;
 	u32			minorversion;
 	u32			status;
-	stateid_t               current_stateid;
-	bool	has_stateid;
+	stateid_t	*current_stateid;
 };
 
 static inline bool nfsd4_has_session(struct nfsd4_compound_state *cs)
-- 
1.7.7.4


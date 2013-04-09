Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50129 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935400Ab3DIX6U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Apr 2013 19:58:20 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 02/10] nfsd4: no need for replay_owner in sessions case
Date: Tue,  9 Apr 2013 19:58:07 -0400
Message-Id: <1365551896-6936-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1365551896-6936-1-git-send-email-bfields@redhat.com>
References: <1365551896-6936-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

The replay_owner will never be used in the sessions case.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c  |    2 +-
 fs/nfsd/nfs4state.c |    8 ++++----
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 609e1e2..c97bb42 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -413,7 +413,7 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	WARN_ON(status && open->op_created);
 out:
 	nfsd4_cleanup_open_state(open, status);
-	if (open->op_openowner)
+	if (open->op_openowner && !nfsd4_has_session(cstate))
 		cstate->replay_owner = &open->op_openowner->oo_owner;
 	nfsd4_bump_seqid(cstate, status);
 	if (!cstate->replay_owner)
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 1226ff6..16db25d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3666,7 +3666,8 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 	if (status)
 		return status;
 	*stpp = openlockstateid(s);
-	cstate->replay_owner = (*stpp)->st_stateowner;
+	if (!nfsd4_has_session(cstate))
+		cstate->replay_owner = (*stpp)->st_stateowner;
 
 	return nfs4_seqid_op_checks(cstate, stateid, seqid, *stpp);
 }
@@ -3858,10 +3859,9 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		oo->oo_last_closed_stid = stp;
 
 	if (list_empty(&oo->oo_owner.so_stateids)) {
-		if (cstate->minorversion) {
+		if (cstate->minorversion)
 			release_openowner(oo);
-			cstate->replay_owner = NULL;
-		} else {
+		else {
 			/*
 			 * In the 4.0 case we need to keep the owners around a
 			 * little while to handle CLOSE replay.
-- 
1.7.9.5


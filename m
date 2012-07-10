Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54140 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753314Ab2GJQHt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jul 2012 12:07:49 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/7] nfsd4: nfsd4_lock() cleanup
Date: Tue, 10 Jul 2012 12:07:41 -0400
Message-Id: <1341936466-3821-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1341936466-3821-1-git-send-email-bfields@redhat.com>
References: <1341936466-3821-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Share a little common logic.  And note the comments here are a little
out of date (e.g. we don't always create new state in the "new" case any
more.)

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   15 +++------------
 1 file changed, 3 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 59b9efc..de8f7e4 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4059,11 +4059,6 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	nfs4_lock_state();
 
 	if (lock->lk_is_new) {
-		/*
-		 * Client indicates that this is a new lockowner.
-		 * Use open owner and open stateid to create lock owner and
-		 * lock stateid.
-		 */
 		struct nfs4_ol_stateid *open_stp = NULL;
 
 		if (nfsd4_has_session(cstate))
@@ -4090,17 +4085,13 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 			goto out;
 		status = lookup_or_create_lock_state(cstate, open_stp, lock,
 							&lock_stp, &new_state);
-		if (status)
-			goto out;
-	} else {
-		/* lock (lock owner + lock stateid) already exists */
+	} else
 		status = nfs4_preprocess_seqid_op(cstate,
 				       lock->lk_old_lock_seqid,
 				       &lock->lk_old_lock_stateid,
 				       NFS4_LOCK_STID, &lock_stp);
-		if (status)
-			goto out;
-	}
+	if (status)
+		goto out;
 	lock_sop = lockowner(lock_stp->st_stateowner);
 
 	lkflg = setlkflg(lock->lk_type);
-- 
1.7.9.5


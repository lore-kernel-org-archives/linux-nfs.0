Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54151 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756131Ab2GJQHu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jul 2012 12:07:50 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 5/7] nfsd4: release openowners on free in >=4.1 case
Date: Tue, 10 Jul 2012 12:07:44 -0400
Message-Id: <1341936466-3821-6-git-send-email-bfields@redhat.com>
In-Reply-To: <1341936466-3821-1-git-send-email-bfields@redhat.com>
References: <1341936466-3821-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

We don't need to keep openowners around in the >=4.1 case, because they
aren't needed to handle CLOSE replays any more (that's a problem for
sessions).  And doing so causes unexpected failures on a subsequent
destroy_clientid to fail.

We probably also need something comparable for lock owners on last
unlock.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   19 +++++++++++++------
 1 file changed, 13 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 9efa405..e404fca 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3763,12 +3763,19 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	nfsd4_close_open_stateid(stp);
 	oo->oo_last_closed_stid = stp;
 
-	/* place unused nfs4_stateowners on so_close_lru list to be
-	 * released by the laundromat service after the lease period
-	 * to enable us to handle CLOSE replay
-	 */
-	if (list_empty(&oo->oo_owner.so_stateids))
-		move_to_close_lru(oo);
+	if (list_empty(&oo->oo_owner.so_stateids)) {
+		if (cstate->minorversion) {
+			release_openowner(oo);
+			cstate->replay_owner = NULL;
+		} else {
+			/*
+			 * In the 4.0 case we need to keep the owners around a
+			 * little while to handle CLOSE replay.
+			 */
+			if (list_empty(&oo->oo_owner.so_stateids))
+				move_to_close_lru(oo);
+		}
+	}
 out:
 	if (!cstate->replay_owner)
 		nfs4_unlock_state();
-- 
1.7.9.5


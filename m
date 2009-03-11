From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 03/14] nfsd4: remove redundant "if" in nfs4_preprocess_stateid_op
Date: Tue, 10 Mar 2009 20:26:51 -0400
Message-ID: <1236731222-3294-4-git-send-email-bfields@fieldses.org>
References: <1236731222-3294-1-git-send-email-bfields@fieldses.org>
 <1236731222-3294-2-git-send-email-bfields@fieldses.org>
 <1236731222-3294-3-git-send-email-bfields@fieldses.org>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:44033 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751921AbZCKA1F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Mar 2009 20:27:05 -0400
In-Reply-To: <1236731222-3294-3-git-send-email-bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

Note that we exit this first big "if" with stp == NULL iff we took the
first branch; therefore, the second "if" is redundant, and we can just
combine the two, simplifying the logic.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4state.c |   19 ++++++++-----------
 1 files changed, 8 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d6ca2be..16fcb65 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2087,6 +2087,14 @@ nfs4_preprocess_stateid_op(struct svc_fh *current_fh, stateid_t *stateid, int fl
 		status = check_stateid_generation(stateid, stidp);
 		if (status)
 			goto out;
+		status = nfs4_check_delegmode(dp, flags);
+		if (status)
+			goto out;
+		renew_client(dp->dl_client);
+		if (flags & DELEG_RET)
+			unhash_delegation(dp);
+		if (filpp)
+			*filpp = dp->dl_vfs_file;
 	} else { /* open or lock stateid */
 		stp = find_stateid(stateid, flags);
 		if (!stp) {
@@ -2101,23 +2109,12 @@ nfs4_preprocess_stateid_op(struct svc_fh *current_fh, stateid_t *stateid, int fl
 		status = check_stateid_generation(stateid, stidp);
 		if (status)
 			goto out;
-	}
-	if (stp) {
 		status = nfs4_check_openmode(stp, flags);
 		if (status)
 			goto out;
 		renew_client(stp->st_stateowner->so_client);
 		if (filpp)
 			*filpp = stp->st_vfs_file;
-	} else {
-		status = nfs4_check_delegmode(dp, flags);
-		if (status)
-			goto out;
-		renew_client(dp->dl_client);
-		if (flags & DELEG_RET)
-			unhash_delegation(dp);
-		if (filpp)
-			*filpp = dp->dl_vfs_file;
 	}
 	status = nfs_ok;
 out:
-- 
1.6.0.4


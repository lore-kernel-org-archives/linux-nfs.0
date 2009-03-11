From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 02/14] nfsd4: move check_stateid_generation check
Date: Tue, 10 Mar 2009 20:26:50 -0400
Message-ID: <1236731222-3294-3-git-send-email-bfields@fieldses.org>
References: <1236731222-3294-1-git-send-email-bfields@fieldses.org>
 <1236731222-3294-2-git-send-email-bfields@fieldses.org>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:44036 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751794AbZCKA1F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Mar 2009 20:27:05 -0400
In-Reply-To: <1236731222-3294-2-git-send-email-bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

No change in behavior.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4state.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b7e2f25..d6ca2be 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2084,6 +2084,9 @@ nfs4_preprocess_stateid_op(struct svc_fh *current_fh, stateid_t *stateid, int fl
 			goto out;
 		}
 		stidp = &dp->dl_stateid;
+		status = check_stateid_generation(stateid, stidp);
+		if (status)
+			goto out;
 	} else { /* open or lock stateid */
 		stp = find_stateid(stateid, flags);
 		if (!stp) {
@@ -2095,10 +2098,10 @@ nfs4_preprocess_stateid_op(struct svc_fh *current_fh, stateid_t *stateid, int fl
 		if (!stp->st_stateowner->so_confirmed)
 			goto out;
 		stidp = &stp->st_stateid;
+		status = check_stateid_generation(stateid, stidp);
+		if (status)
+			goto out;
 	}
-	status = check_stateid_generation(stateid, stidp);
-	if (status)
-		goto out;
 	if (stp) {
 		status = nfs4_check_openmode(stp, flags);
 		if (status)
-- 
1.6.0.4


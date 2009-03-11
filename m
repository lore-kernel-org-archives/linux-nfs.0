From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 01/14] nfsd4: trivial preprocess_stateid_op cleanup
Date: Tue, 10 Mar 2009 20:26:49 -0400
Message-ID: <1236731222-3294-2-git-send-email-bfields@fieldses.org>
References: <1236731222-3294-1-git-send-email-bfields@fieldses.org>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:44038 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752058AbZCKA1F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Mar 2009 20:27:05 -0400
In-Reply-To: <1236731222-3294-1-git-send-email-bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

Remove a couple redundant comments, adjust style; no change in behavior.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4state.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 7f616e9..b7e2f25 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2072,21 +2072,21 @@ nfs4_preprocess_stateid_op(struct svc_fh *current_fh, stateid_t *stateid, int fl
 	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid))
 		return check_special_stateids(current_fh, stateid, flags);
 
-	/* STALE STATEID */
 	status = nfserr_stale_stateid;
 	if (STALE_STATEID(stateid)) 
 		goto out;
 
-	/* BAD STATEID */
 	status = nfserr_bad_stateid;
 	if (!stateid->si_fileid) { /* delegation stateid */
-		if(!(dp = find_delegation_stateid(ino, stateid))) {
+		dp = find_delegation_stateid(ino, stateid);
+		if (!dp) {
 			dprintk("NFSD: delegation stateid not found\n");
 			goto out;
 		}
 		stidp = &dp->dl_stateid;
 	} else { /* open or lock stateid */
-		if (!(stp = find_stateid(stateid, flags))) {
+		stp = find_stateid(stateid, flags);
+		if (!stp) {
 			dprintk("NFSD: open or lock stateid not found\n");
 			goto out;
 		}
@@ -2100,13 +2100,15 @@ nfs4_preprocess_stateid_op(struct svc_fh *current_fh, stateid_t *stateid, int fl
 	if (status)
 		goto out;
 	if (stp) {
-		if ((status = nfs4_check_openmode(stp,flags)))
+		status = nfs4_check_openmode(stp, flags);
+		if (status)
 			goto out;
 		renew_client(stp->st_stateowner->so_client);
 		if (filpp)
 			*filpp = stp->st_vfs_file;
 	} else {
-		if ((status = nfs4_check_delegmode(dp, flags)))
+		status = nfs4_check_delegmode(dp, flags);
+		if (status)
 			goto out;
 		renew_client(dp->dl_client);
 		if (flags & DELEG_RET)
-- 
1.6.0.4


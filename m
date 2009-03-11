From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 05/14] nfsd4: remove some dprintk's
Date: Tue, 10 Mar 2009 20:26:53 -0400
Message-ID: <1236731222-3294-6-git-send-email-bfields@fieldses.org>
References: <1236731222-3294-1-git-send-email-bfields@fieldses.org>
 <1236731222-3294-2-git-send-email-bfields@fieldses.org>
 <1236731222-3294-3-git-send-email-bfields@fieldses.org>
 <1236731222-3294-4-git-send-email-bfields@fieldses.org>
 <1236731222-3294-5-git-send-email-bfields@fieldses.org>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:44042 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752076AbZCKA1F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Mar 2009 20:27:05 -0400
In-Reply-To: <1236731222-3294-5-git-send-email-bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

I can't recall ever seeing these printk's used to debug a problem.  I'll
happily put them back if we see a case where they'd be useful.  (Though
if we do that the find_XXX() errors would probably be better
reported in find_XXX() functions themselves.)

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4state.c |   11 ++---------
 1 files changed, 2 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 099938e..909a7a4 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2059,9 +2059,6 @@ nfs4_preprocess_stateid_op(struct svc_fh *current_fh, stateid_t *stateid, int fl
 	struct inode *ino = current_fh->fh_dentry->d_inode;
 	__be32 status;
 
-	dprintk("NFSD: preprocess_stateid_op: stateid = (%08x/%08x/%08x/%08x)\n",
-		stateid->si_boot, stateid->si_stateownerid, 
-		stateid->si_fileid, stateid->si_generation); 
 	if (filpp)
 		*filpp = NULL;
 
@@ -2078,10 +2075,8 @@ nfs4_preprocess_stateid_op(struct svc_fh *current_fh, stateid_t *stateid, int fl
 	status = nfserr_bad_stateid;
 	if (!stateid->si_fileid) { /* delegation stateid */
 		dp = find_delegation_stateid(ino, stateid);
-		if (!dp) {
-			dprintk("NFSD: delegation stateid not found\n");
+		if (!dp)
 			goto out;
-		}
 		status = check_stateid_generation(stateid, &dp->dl_stateid);
 		if (status)
 			goto out;
@@ -2095,10 +2090,8 @@ nfs4_preprocess_stateid_op(struct svc_fh *current_fh, stateid_t *stateid, int fl
 			*filpp = dp->dl_vfs_file;
 	} else { /* open or lock stateid */
 		stp = find_stateid(stateid, flags);
-		if (!stp) {
-			dprintk("NFSD: open or lock stateid not found\n");
+		if (!stp)
 			goto out;
-		}
 		if ((flags & CHECK_FH) && nfs4_check_fh(current_fh, stp))
 			goto out;
 		if (!stp->st_stateowner->so_confirmed)
-- 
1.6.0.4


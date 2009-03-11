From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 04/14] nfsd4: remove unneeded local variable
Date: Tue, 10 Mar 2009 20:26:52 -0400
Message-ID: <1236731222-3294-5-git-send-email-bfields@fieldses.org>
References: <1236731222-3294-1-git-send-email-bfields@fieldses.org>
 <1236731222-3294-2-git-send-email-bfields@fieldses.org>
 <1236731222-3294-3-git-send-email-bfields@fieldses.org>
 <1236731222-3294-4-git-send-email-bfields@fieldses.org>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:44035 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751696AbZCKA1F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Mar 2009 20:27:05 -0400
In-Reply-To: <1236731222-3294-4-git-send-email-bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

We no longer need stidp.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4state.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 16fcb65..099938e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2056,7 +2056,6 @@ nfs4_preprocess_stateid_op(struct svc_fh *current_fh, stateid_t *stateid, int fl
 {
 	struct nfs4_stateid *stp = NULL;
 	struct nfs4_delegation *dp = NULL;
-	stateid_t *stidp;
 	struct inode *ino = current_fh->fh_dentry->d_inode;
 	__be32 status;
 
@@ -2083,8 +2082,7 @@ nfs4_preprocess_stateid_op(struct svc_fh *current_fh, stateid_t *stateid, int fl
 			dprintk("NFSD: delegation stateid not found\n");
 			goto out;
 		}
-		stidp = &dp->dl_stateid;
-		status = check_stateid_generation(stateid, stidp);
+		status = check_stateid_generation(stateid, &dp->dl_stateid);
 		if (status)
 			goto out;
 		status = nfs4_check_delegmode(dp, flags);
@@ -2105,8 +2103,7 @@ nfs4_preprocess_stateid_op(struct svc_fh *current_fh, stateid_t *stateid, int fl
 			goto out;
 		if (!stp->st_stateowner->so_confirmed)
 			goto out;
-		stidp = &stp->st_stateid;
-		status = check_stateid_generation(stateid, stidp);
+		status = check_stateid_generation(stateid, &stp->st_stateid);
 		if (status)
 			goto out;
 		status = nfs4_check_openmode(stp, flags);
-- 
1.6.0.4


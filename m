From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 09/14] nfsd4: remove unused CHECK_FH flag
Date: Tue, 10 Mar 2009 20:26:57 -0400
Message-ID: <1236731222-3294-10-git-send-email-bfields@fieldses.org>
References: <1236731222-3294-1-git-send-email-bfields@fieldses.org>
 <1236731222-3294-2-git-send-email-bfields@fieldses.org>
 <1236731222-3294-3-git-send-email-bfields@fieldses.org>
 <1236731222-3294-4-git-send-email-bfields@fieldses.org>
 <1236731222-3294-5-git-send-email-bfields@fieldses.org>
 <1236731222-3294-6-git-send-email-bfields@fieldses.org>
 <1236731222-3294-7-git-send-email-bfields@fieldses.org>
 <1236731222-3294-8-git-send-email-bfields@fieldses.org>
 <1236731222-3294-9-git-send-email-bfields@fieldses.org>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:44050 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752373AbZCKA1F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Mar 2009 20:27:05 -0400
In-Reply-To: <1236731222-3294-9-git-send-email-bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

All users now pass this, so it's meaningless.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4proc.c         |    6 +++---
 fs/nfsd/nfs4state.c        |    2 +-
 include/linux/nfsd/state.h |    1 -
 3 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index af66073..77f584f 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -519,7 +519,7 @@ nfsd4_read(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	/* check stateid */
 	if ((status = nfs4_preprocess_stateid_op(&cstate->current_fh,
 				&read->rd_stateid,
-				CHECK_FH | RD_STATE, &read->rd_filp))) {
+				RD_STATE, &read->rd_filp))) {
 		dprintk("NFSD: nfsd4_read: couldn't process stateid!\n");
 		goto out;
 	}
@@ -651,7 +651,7 @@ nfsd4_setattr(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (setattr->sa_iattr.ia_valid & ATTR_SIZE) {
 		nfs4_lock_state();
 		status = nfs4_preprocess_stateid_op(&cstate->current_fh,
-			&setattr->sa_stateid, CHECK_FH | WR_STATE, NULL);
+			&setattr->sa_stateid, WR_STATE, NULL);
 		nfs4_unlock_state();
 		if (status) {
 			dprintk("NFSD: nfsd4_setattr: couldn't process stateid!\n");
@@ -690,7 +690,7 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	nfs4_lock_state();
 	status = nfs4_preprocess_stateid_op(&cstate->current_fh, stateid,
-					CHECK_FH | WR_STATE, &filp);
+					WR_STATE, &filp);
 	if (filp)
 		get_file(filp);
 	nfs4_unlock_state();
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 4a92d1e..caca569 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2091,7 +2091,7 @@ nfs4_preprocess_stateid_op(struct svc_fh *current_fh, stateid_t *stateid, int fl
 		stp = find_stateid(stateid, flags);
 		if (!stp)
 			goto out;
-		if ((flags & CHECK_FH) && nfs4_check_fh(current_fh, stp))
+		if (nfs4_check_fh(current_fh, stp))
 			goto out;
 		if (!stp->st_stateowner->so_confirmed)
 			goto out;
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index c9311a1..503b6bb 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -256,7 +256,6 @@ struct nfs4_stateid {
 };
 
 /* flags for preprocess_seqid_op() */
-#define CHECK_FH                0x00000001
 #define CONFIRM                 0x00000002
 #define OPEN_STATE              0x00000004
 #define LOCK_STATE              0x00000008
-- 
1.6.0.4


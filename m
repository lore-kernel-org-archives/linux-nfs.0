From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 10/14] nfsd4: rename io_during_grace_disallowed
Date: Tue, 10 Mar 2009 20:26:58 -0400
Message-ID: <1236731222-3294-11-git-send-email-bfields@fieldses.org>
References: <1236731222-3294-1-git-send-email-bfields@fieldses.org>
 <1236731222-3294-2-git-send-email-bfields@fieldses.org>
 <1236731222-3294-3-git-send-email-bfields@fieldses.org>
 <1236731222-3294-4-git-send-email-bfields@fieldses.org>
 <1236731222-3294-5-git-send-email-bfields@fieldses.org>
 <1236731222-3294-6-git-send-email-bfields@fieldses.org>
 <1236731222-3294-7-git-send-email-bfields@fieldses.org>
 <1236731222-3294-8-git-send-email-bfields@fieldses.org>
 <1236731222-3294-9-git-send-email-bfields@fieldses.org>
 <1236731222-3294-10-git-send-email-bfields@fieldses.org>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:44052 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752459AbZCKA1F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Mar 2009 20:27:05 -0400
In-Reply-To: <1236731222-3294-10-git-send-email-bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

Use a slightly clearer, more concise name.  Also removed unused
argument.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4state.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index caca569..56e81f9 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2019,7 +2019,7 @@ check_special_stateids(svc_fh *current_fh, stateid_t *stateid, int flags)
  * that are not able to provide mandatory locking.
  */
 static inline int
-io_during_grace_disallowed(struct inode *inode, int flags)
+grace_disallows_io(struct inode *inode)
 {
 	return locks_in_grace() && mandatory_lock(inode);
 }
@@ -2063,7 +2063,7 @@ nfs4_preprocess_stateid_op(struct svc_fh *current_fh, stateid_t *stateid, int fl
 	if (filpp)
 		*filpp = NULL;
 
-	if (io_during_grace_disallowed(ino, flags))
+	if (grace_disallows_io(ino))
 		return nfserr_grace;
 
 	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid))
-- 
1.6.0.4


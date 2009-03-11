From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 06/14] nfsd4: add a helper function to decide if stateid is delegation
Date: Tue, 10 Mar 2009 20:26:54 -0400
Message-ID: <1236731222-3294-7-git-send-email-bfields@fieldses.org>
References: <1236731222-3294-1-git-send-email-bfields@fieldses.org>
 <1236731222-3294-2-git-send-email-bfields@fieldses.org>
 <1236731222-3294-3-git-send-email-bfields@fieldses.org>
 <1236731222-3294-4-git-send-email-bfields@fieldses.org>
 <1236731222-3294-5-git-send-email-bfields@fieldses.org>
 <1236731222-3294-6-git-send-email-bfields@fieldses.org>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:44044 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752234AbZCKA1F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Mar 2009 20:27:05 -0400
In-Reply-To: <1236731222-3294-6-git-send-email-bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

Make this check self-documenting.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4state.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 909a7a4..d555585 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2048,6 +2048,11 @@ static int check_stateid_generation(stateid_t *in, stateid_t *ref)
 	return nfs_ok;
 }
 
+static int is_delegation_stateid(stateid_t *stateid)
+{
+	return stateid->si_fileid == 0;
+}
+
 /*
 * Checks for stateid operations
 */
@@ -2073,7 +2078,7 @@ nfs4_preprocess_stateid_op(struct svc_fh *current_fh, stateid_t *stateid, int fl
 		goto out;
 
 	status = nfserr_bad_stateid;
-	if (!stateid->si_fileid) { /* delegation stateid */
+	if (is_delegation_stateid(stateid)) {
 		dp = find_delegation_stateid(ino, stateid);
 		if (!dp)
 			goto out;
-- 
1.6.0.4


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:46676 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753692Ab1LMVgD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Dec 2011 16:36:03 -0500
From: bjschuma@netapp.com
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH] NFSD: Only reinitilize the recall_lru list under the recall lock
Date: Tue, 13 Dec 2011 16:35:58 -0500
Message-Id: <1323812158-5183-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

unhash_delegation() will grab the recall lock before calling
list_del_init() in each of these places.  This patch removes the
redundant calls.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfsd/nfs4state.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 6ab6779..43d5c22 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1058,7 +1058,6 @@ expire_client(struct nfs4_client *clp)
 	spin_unlock(&recall_lock);
 	while (!list_empty(&reaplist)) {
 		dp = list_entry(reaplist.next, struct nfs4_delegation, dl_recall_lru);
-		list_del_init(&dp->dl_recall_lru);
 		unhash_delegation(dp);
 	}
 	while (!list_empty(&clp->cl_openowners)) {
@@ -3125,7 +3124,6 @@ nfs4_laundromat(void)
 	spin_unlock(&recall_lock);
 	list_for_each_safe(pos, next, &reaplist) {
 		dp = list_entry (pos, struct nfs4_delegation, dl_recall_lru);
-		list_del_init(&dp->dl_recall_lru);
 		unhash_delegation(dp);
 	}
 	test_val = nfsd4_lease;
@@ -4667,7 +4665,6 @@ __nfs4_state_shutdown(void)
 	spin_unlock(&recall_lock);
 	list_for_each_safe(pos, next, &reaplist) {
 		dp = list_entry (pos, struct nfs4_delegation, dl_recall_lru);
-		list_del_init(&dp->dl_recall_lru);
 		unhash_delegation(dp);
 	}
 
-- 
1.7.8


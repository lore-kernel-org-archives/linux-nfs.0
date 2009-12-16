From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 11/11] nfsd: refactor unhash_delegation
Date: Wed, 16 Dec 2009 19:42:41 +0200
Message-ID: <1260985361-21739-1-git-send-email-bhalevy@panasas.com>
References: <4B291B4C.3060603@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:22491 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1762652AbZLPRmo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Dec 2009 12:42:44 -0500
In-Reply-To: <4B291B4C.3060603@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

and use in expire_client

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |   20 +++++++++++++-------
 1 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 053fd2b..01d79cb 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -233,14 +233,20 @@ nfs4_put_delegation(struct nfs4_delegation *dp)
 	}
 }
 
-/* Called under the state lock. */
-static void
-unhash_delegation(struct nfs4_delegation *dp)
+static inline void
+__unhash_delegation_locked(struct nfs4_delegation *dp)
 {
-	spin_lock(&deleg_lock);
 	list_del_init(&dp->dl_perfile);
 	list_del_init(&dp->dl_perclnt);
 	list_del_init(&dp->dl_recall_lru);
+}
+
+/* Called under the state lock. */
+static inline void
+unhash_delegation(struct nfs4_delegation *dp)
+{
+	spin_lock(&deleg_lock);
+	__unhash_delegation_locked(dp);
 	spin_unlock(&deleg_lock);
 	nfs4_put_delegation(dp);
 }
@@ -769,14 +775,14 @@ expire_client(struct nfs4_client *clp)
 		dp = list_entry(clp->cl_delegations.next, struct nfs4_delegation, dl_perclnt);
 		dprintk("NFSD: expire client. dp %p, fp %p\n", dp,
 				dp->dl_flock);
-		list_del_init(&dp->dl_perclnt);
-		list_move(&dp->dl_recall_lru, &reaplist);
+		__unhash_delegation_locked(dp);
+		list_add(&dp->dl_recall_lru, &reaplist);
 	}
 	spin_unlock(&deleg_lock);
 	while (!list_empty(&reaplist)) {
 		dp = list_entry(reaplist.next, struct nfs4_delegation, dl_recall_lru);
 		list_del_init(&dp->dl_recall_lru);
-		unhash_delegation(dp);
+		nfs4_put_delegation(dp);
 	}
 	list_del(&clp->cl_idhash);
 	list_del(&clp->cl_strhash);
-- 
1.6.5.1


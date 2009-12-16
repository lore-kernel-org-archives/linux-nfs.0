From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 08/11] nfsd: use deleg_lock to protect dl_perfile and dl_perclnt
Date: Wed, 16 Dec 2009 19:42:03 +0200
Message-ID: <1260985323-21631-1-git-send-email-bhalevy@panasas.com>
References: <4B291B4C.3060603@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:2505 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757745AbZLPRmG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Dec 2009 12:42:06 -0500
In-Reply-To: <4B291B4C.3060603@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 06e6e2e..ae49d1e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -196,8 +196,10 @@ alloc_init_deleg(struct nfs4_client *clp, struct nfs4_stateid *stp, struct svc_f
 	fh_copy_shallow(&dp->dl_fh, &current_fh->fh_handle);
 	dp->dl_time = 0;
 	atomic_set(&dp->dl_count, 1);
+	spin_lock(&deleg_lock);
 	list_add(&dp->dl_perfile, &fp->fi_delegations);
 	list_add(&dp->dl_perclnt, &clp->cl_delegations);
+	spin_unlock(&deleg_lock);
 	return dp;
 }
 
@@ -235,9 +237,9 @@ nfs4_close_delegation(struct nfs4_delegation *dp)
 static void
 unhash_delegation(struct nfs4_delegation *dp)
 {
+	spin_lock(&deleg_lock);
 	list_del_init(&dp->dl_perfile);
 	list_del_init(&dp->dl_perclnt);
-	spin_lock(&deleg_lock);
 	list_del_init(&dp->dl_recall_lru);
 	spin_unlock(&deleg_lock);
 	nfs4_close_delegation(dp);
@@ -2222,13 +2224,15 @@ nfs4_check_delegmode(struct nfs4_delegation *dp, int flags)
 static struct nfs4_delegation *
 find_delegation_file(struct nfs4_file *fp, stateid_t *stid)
 {
-	struct nfs4_delegation *dp;
+	struct nfs4_delegation *dp = NULL;
 
+	spin_lock(&deleg_lock);
 	list_for_each_entry(dp, &fp->fi_delegations, dl_perfile) {
 		if (dp->dl_stateid.si_stateownerid == stid->si_stateownerid)
-			return dp;
+			break;
 	}
-	return NULL;
+	spin_unlock(&deleg_lock);
+	return dp;
 }
 
 static __be32
-- 
1.6.5.1


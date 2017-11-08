Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:32993 "HELO
        discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with SMTP id S1751245AbdKHWac (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Nov 2017 17:30:32 -0500
From: Andrew Elble <aweits@rit.edu>
To: linux-nfs@vger.kernel.org, bfields@fieldses.org
Cc: Andrew Elble <aweits@rit.edu>
Subject: [PATCH v3] nfsd: fix locking validator warning on nfs4_ol_stateid->st_mutex class
Date: Wed,  8 Nov 2017 17:29:51 -0500
Message-Id: <20171108222951.37763-1-aweits@rit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The use of the st_mutex has been confusing the validator. Use the
proper nested notation so as to not produce warnings.

Signed-off-by: Andrew Elble <aweits@rit.edu>
---
 v2: added mutex_lock_nested to init_lock_stateid() for consistency
 v3: add constants
 
 fs/nfsd/nfs4state.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 0d98d73bd84e..5740ad8075c3 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -87,6 +87,11 @@
  */
 static DEFINE_SPINLOCK(state_lock);
 
+enum nfsd4_st_mutex_lock_subclass {
+	OPEN_STATEID_MUTEX = 0,
+	LOCK_STATEID_MUTEX = 1,
+};
+
 /*
  * A waitqueue for all in-progress 4.0 CLOSE operations that are waiting for
  * the refcount on the open stateid to drop.
@@ -3548,7 +3553,7 @@ static void nfs4_free_openowner(struct nfs4_stateowner *so)
 {
 	__be32 ret;
 
-	mutex_lock(&stp->st_mutex);
+	mutex_lock_nested(&stp->st_mutex, LOCK_STATEID_MUTEX);
 	ret = nfsd4_verify_open_stid(&stp->st_stid);
 	if (ret != nfs_ok)
 		mutex_unlock(&stp->st_mutex);
@@ -3612,7 +3617,7 @@ static void nfs4_free_openowner(struct nfs4_stateowner *so)
 	stp = open->op_stp;
 	/* We are moving these outside of the spinlocks to avoid the warnings */
 	mutex_init(&stp->st_mutex);
-	mutex_lock(&stp->st_mutex);
+	mutex_lock_nested(&stp->st_mutex, OPEN_STATEID_MUTEX);
 
 retry:
 	spin_lock(&oo->oo_owner.so_client->cl_lock);
@@ -5692,7 +5697,7 @@ static void nfs4_free_lockowner(struct nfs4_stateowner *sop)
 	struct nfs4_ol_stateid *retstp;
 
 	mutex_init(&stp->st_mutex);
-	mutex_lock(&stp->st_mutex);
+	mutex_lock_nested(&stp->st_mutex, OPEN_STATEID_MUTEX);
 retry:
 	spin_lock(&clp->cl_lock);
 	spin_lock(&fp->fi_lock);
-- 
1.8.3.1


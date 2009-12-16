From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 07/11] nfsd: rename recall_lock to deleg_lock
Date: Wed, 16 Dec 2009 19:41:51 +0200
Message-ID: <1260985311-21588-1-git-send-email-bhalevy@panasas.com>
References: <4B291B4C.3060603@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:51406 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758206AbZLPRlx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Dec 2009 12:41:53 -0500
In-Reply-To: <4B291B4C.3060603@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

in preparation to expanding its usage to other deleg related lists.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |   36 ++++++++++++++++++------------------
 1 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 38817c3..06e6e2e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -74,7 +74,7 @@ static DEFINE_MUTEX(client_mutex);
  * effort to decrease the scope of the client_mutex, this spinlock may
  * eventually cover more:
  */
-static DEFINE_SPINLOCK(recall_lock);
+static DEFINE_SPINLOCK(deleg_lock);
 
 static struct kmem_cache *stateowner_slab = NULL;
 static struct kmem_cache *file_slab = NULL;
@@ -111,9 +111,9 @@ static struct list_head del_recall_lru;
 static inline void
 put_nfs4_file(struct nfs4_file *fi)
 {
-	if (atomic_dec_and_lock(&fi->fi_ref, &recall_lock)) {
+	if (atomic_dec_and_lock(&fi->fi_ref, &deleg_lock)) {
 		list_del(&fi->fi_hash);
-		spin_unlock(&recall_lock);
+		spin_unlock(&deleg_lock);
 		iput(fi->fi_inode);
 		kmem_cache_free(file_slab, fi);
 	}
@@ -237,9 +237,9 @@ unhash_delegation(struct nfs4_delegation *dp)
 {
 	list_del_init(&dp->dl_perfile);
 	list_del_init(&dp->dl_perclnt);
-	spin_lock(&recall_lock);
+	spin_lock(&deleg_lock);
 	list_del_init(&dp->dl_recall_lru);
-	spin_unlock(&recall_lock);
+	spin_unlock(&deleg_lock);
 	nfs4_close_delegation(dp);
 	nfs4_put_delegation(dp);
 }
@@ -763,7 +763,7 @@ expire_client(struct nfs4_client *clp)
 
 	atomic_set(&clp->cl_state, CL_STATE_EXPIRED);
 	INIT_LIST_HEAD(&reaplist);
-	spin_lock(&recall_lock);
+	spin_lock(&deleg_lock);
 	while (!list_empty(&clp->cl_delegations)) {
 		dp = list_entry(clp->cl_delegations.next, struct nfs4_delegation, dl_perclnt);
 		dprintk("NFSD: expire client. dp %p, fp %p\n", dp,
@@ -771,7 +771,7 @@ expire_client(struct nfs4_client *clp)
 		list_del_init(&dp->dl_perclnt);
 		list_move(&dp->dl_recall_lru, &reaplist);
 	}
-	spin_unlock(&recall_lock);
+	spin_unlock(&deleg_lock);
 	while (!list_empty(&reaplist)) {
 		dp = list_entry(reaplist.next, struct nfs4_delegation, dl_recall_lru);
 		list_del_init(&dp->dl_recall_lru);
@@ -1734,9 +1734,9 @@ alloc_init_file(struct inode *ino)
 		INIT_LIST_HEAD(&fp->fi_hash);
 		INIT_LIST_HEAD(&fp->fi_stateids);
 		INIT_LIST_HEAD(&fp->fi_delegations);
-		spin_lock(&recall_lock);
+		spin_lock(&deleg_lock);
 		list_add(&fp->fi_hash, &file_hashtbl[hashval]);
-		spin_unlock(&recall_lock);
+		spin_unlock(&deleg_lock);
 		fp->fi_inode = igrab(ino);
 		fp->fi_id = current_fileid++;
 		fp->fi_had_conflict = false;
@@ -1910,15 +1910,15 @@ find_file(struct inode *ino)
 	unsigned int hashval = file_hashval(ino);
 	struct nfs4_file *fp;
 
-	spin_lock(&recall_lock);
+	spin_lock(&deleg_lock);
 	list_for_each_entry(fp, &file_hashtbl[hashval], fi_hash) {
 		if (fp->fi_inode == ino) {
 			get_nfs4_file(fp);
-			spin_unlock(&recall_lock);
+			spin_unlock(&deleg_lock);
 			return fp;
 		}
 	}
-	spin_unlock(&recall_lock);
+	spin_unlock(&deleg_lock);
 	return NULL;
 }
 
@@ -2062,9 +2062,9 @@ void nfsd_break_deleg_cb(struct file_lock *fl)
 	atomic_inc(&dp->dl_count);
 	atomic_inc(&dp->dl_client->cl_count);
 
-	spin_lock(&recall_lock);
+	spin_lock(&deleg_lock);
 	list_add_tail(&dp->dl_recall_lru, &del_recall_lru);
-	spin_unlock(&recall_lock);
+	spin_unlock(&deleg_lock);
 
 	/* only place dl_time is set. protected by lock_kernel*/
 	dp->dl_time = get_seconds();
@@ -2619,7 +2619,7 @@ nfs4_laundromat(void)
 		expire_client(clp);
 	}
 	INIT_LIST_HEAD(&reaplist);
-	spin_lock(&recall_lock);
+	spin_lock(&deleg_lock);
 	list_for_each_safe(pos, next, &del_recall_lru) {
 		dp = list_entry (pos, struct nfs4_delegation, dl_recall_lru);
 		if (time_after((unsigned long)dp->dl_time, (unsigned long)cutoff)) {
@@ -2632,7 +2632,7 @@ nfs4_laundromat(void)
 			            dp, dp->dl_flock);
 		list_move(&dp->dl_recall_lru, &reaplist);
 	}
-	spin_unlock(&recall_lock);
+	spin_unlock(&deleg_lock);
 	list_for_each_safe(pos, next, &reaplist) {
 		dp = list_entry (pos, struct nfs4_delegation, dl_recall_lru);
 		list_del_init(&dp->dl_recall_lru);
@@ -4097,12 +4097,12 @@ __nfs4_state_shutdown(void)
 		}
 	}
 	INIT_LIST_HEAD(&reaplist);
-	spin_lock(&recall_lock);
+	spin_lock(&deleg_lock);
 	list_for_each_safe(pos, next, &del_recall_lru) {
 		dp = list_entry (pos, struct nfs4_delegation, dl_recall_lru);
 		list_move(&dp->dl_recall_lru, &reaplist);
 	}
-	spin_unlock(&recall_lock);
+	spin_unlock(&deleg_lock);
 	list_for_each_safe(pos, next, &reaplist) {
 		dp = list_entry (pos, struct nfs4_delegation, dl_recall_lru);
 		list_del_init(&dp->dl_recall_lru);
-- 
1.6.5.1


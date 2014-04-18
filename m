Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f182.google.com ([209.85.223.182]:36344 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751242AbaDRSpN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2014 14:45:13 -0400
Received: by mail-ie0-f182.google.com with SMTP id y20so1904228ier.13
        for <linux-nfs@vger.kernel.org>; Fri, 18 Apr 2014 11:45:13 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 05/70] nfsd4: rename recall_lock to state_lock
Date: Fri, 18 Apr 2014 14:43:59 -0400
Message-Id: <1397846704-14567-6-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1397846704-14567-5-git-send-email-trond.myklebust@primarydata.com>
References: <1397846704-14567-1-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-2-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-3-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-4-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-5-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@primarydata.com>

Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4state.c | 55 +++++++++++++++++++++++++++--------------------------
 1 file changed, 28 insertions(+), 27 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 841495aa9170..34273ca482c3 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -81,7 +81,7 @@ static DEFINE_MUTEX(client_mutex);
  * effort to decrease the scope of the client_mutex, this spinlock may
  * eventually cover more:
  */
-static DEFINE_SPINLOCK(recall_lock);
+static DEFINE_SPINLOCK(state_lock);
 
 static struct kmem_cache *openowner_slab = NULL;
 static struct kmem_cache *lockowner_slab = NULL;
@@ -235,9 +235,9 @@ static void nfsd4_free_file(struct nfs4_file *f)
 static inline void
 put_nfs4_file(struct nfs4_file *fi)
 {
-	if (atomic_dec_and_lock(&fi->fi_ref, &recall_lock)) {
+	if (atomic_dec_and_lock(&fi->fi_ref, &state_lock)) {
 		hlist_del(&fi->fi_hash);
-		spin_unlock(&recall_lock);
+		spin_unlock(&state_lock);
 		iput(fi->fi_inode);
 		nfsd4_free_file(fi);
 	}
@@ -436,10 +436,10 @@ static void
 unhash_delegation(struct nfs4_delegation *dp)
 {
 	list_del_init(&dp->dl_perclnt);
-	spin_lock(&recall_lock);
+	spin_lock(&state_lock);
 	list_del_init(&dp->dl_perfile);
 	list_del_init(&dp->dl_recall_lru);
-	spin_unlock(&recall_lock);
+	spin_unlock(&state_lock);
 	nfs4_put_deleg_lease(dp->dl_file);
 	put_nfs4_file(dp->dl_file);
 	dp->dl_file = NULL;
@@ -1136,13 +1136,13 @@ destroy_client(struct nfs4_client *clp)
 	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 
 	INIT_LIST_HEAD(&reaplist);
-	spin_lock(&recall_lock);
+	spin_lock(&state_lock);
 	while (!list_empty(&clp->cl_delegations)) {
 		dp = list_entry(clp->cl_delegations.next, struct nfs4_delegation, dl_perclnt);
 		list_del_init(&dp->dl_perclnt);
 		list_move(&dp->dl_recall_lru, &reaplist);
 	}
-	spin_unlock(&recall_lock);
+	spin_unlock(&state_lock);
 	while (!list_empty(&reaplist)) {
 		dp = list_entry(reaplist.next, struct nfs4_delegation, dl_recall_lru);
 		destroy_delegation(dp);
@@ -2499,9 +2499,9 @@ static void nfsd4_init_file(struct nfs4_file *fp, struct inode *ino)
 	fp->fi_lease = NULL;
 	memset(fp->fi_fds, 0, sizeof(fp->fi_fds));
 	memset(fp->fi_access, 0, sizeof(fp->fi_access));
-	spin_lock(&recall_lock);
+	spin_lock(&state_lock);
 	hlist_add_head(&fp->fi_hash, &file_hashtbl[hashval]);
-	spin_unlock(&recall_lock);
+	spin_unlock(&state_lock);
 }
 
 static void
@@ -2685,15 +2685,15 @@ find_file(struct inode *ino)
 	unsigned int hashval = file_hashval(ino);
 	struct nfs4_file *fp;
 
-	spin_lock(&recall_lock);
+	spin_lock(&state_lock);
 	hlist_for_each_entry(fp, &file_hashtbl[hashval], fi_hash) {
 		if (fp->fi_inode == ino) {
 			get_nfs4_file(fp);
-			spin_unlock(&recall_lock);
+			spin_unlock(&state_lock);
 			return fp;
 		}
 	}
-	spin_unlock(&recall_lock);
+	spin_unlock(&state_lock);
 	return NULL;
 }
 
@@ -2730,6 +2730,7 @@ static void nfsd_break_one_deleg(struct nfs4_delegation *dp)
 	struct nfs4_client *clp = dp->dl_stid.sc_client;
 	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 
+	lockdep_assert_held(&state_lock);
 	/* We're assuming the state code never drops its reference
 	 * without first removing the lease.  Since we're in this lease
 	 * callback (and since the lease code is serialized by the kernel
@@ -2766,11 +2767,11 @@ static void nfsd_break_deleg_cb(struct file_lock *fl)
 	 */
 	fl->fl_break_time = 0;
 
-	spin_lock(&recall_lock);
+	spin_lock(&state_lock);
 	fp->fi_had_conflict = true;
 	list_for_each_entry(dp, &fp->fi_delegations, dl_perfile)
 		nfsd_break_one_deleg(dp);
-	spin_unlock(&recall_lock);
+	spin_unlock(&state_lock);
 }
 
 static
@@ -3072,15 +3073,15 @@ static int nfs4_set_delegation(struct nfs4_delegation *dp, struct nfs4_file *fp)
 			goto out_free;
 		return 0;
 	}
-	spin_lock(&recall_lock);
+	spin_lock(&state_lock);
 	if (fp->fi_had_conflict) {
-		spin_unlock(&recall_lock);
+		spin_unlock(&state_lock);
 		status = -EAGAIN;
 		goto out_free;
 	}
 	atomic_inc(&fp->fi_delegees);
 	list_add(&dp->dl_perfile, &fp->fi_delegations);
-	spin_unlock(&recall_lock);
+	spin_unlock(&state_lock);
 	list_add(&dp->dl_perclnt, &dp->dl_stid.sc_client->cl_delegations);
 	return 0;
 out_free:
@@ -3422,7 +3423,7 @@ nfs4_laundromat(struct nfsd_net *nn)
 			clp->cl_clientid.cl_id);
 		expire_client(clp);
 	}
-	spin_lock(&recall_lock);
+	spin_lock(&state_lock);
 	list_for_each_safe(pos, next, &nn->del_recall_lru) {
 		dp = list_entry (pos, struct nfs4_delegation, dl_recall_lru);
 		if (net_generic(dp->dl_stid.sc_client->net, nfsd_net_id) != nn)
@@ -3435,7 +3436,7 @@ nfs4_laundromat(struct nfsd_net *nn)
 		}
 		list_move(&dp->dl_recall_lru, &reaplist);
 	}
-	spin_unlock(&recall_lock);
+	spin_unlock(&state_lock);
 	list_for_each_safe(pos, next, &reaplist) {
 		dp = list_entry (pos, struct nfs4_delegation, dl_recall_lru);
 		revoke_delegation(dp);
@@ -4900,9 +4901,9 @@ u64 nfsd_forget_client_delegations(struct nfs4_client *clp, u64 max)
 	LIST_HEAD(victims);
 	u64 count;
 
-	spin_lock(&recall_lock);
+	spin_lock(&state_lock);
 	count = nfsd_find_all_delegations(clp, max, &victims);
-	spin_unlock(&recall_lock);
+	spin_unlock(&state_lock);
 
 	list_for_each_entry_safe(dp, next, &victims, dl_recall_lru)
 		revoke_delegation(dp);
@@ -4916,11 +4917,11 @@ u64 nfsd_recall_client_delegations(struct nfs4_client *clp, u64 max)
 	LIST_HEAD(victims);
 	u64 count;
 
-	spin_lock(&recall_lock);
+	spin_lock(&state_lock);
 	count = nfsd_find_all_delegations(clp, max, &victims);
 	list_for_each_entry_safe(dp, next, &victims, dl_recall_lru)
 		nfsd_break_one_deleg(dp);
-	spin_unlock(&recall_lock);
+	spin_unlock(&state_lock);
 
 	return count;
 }
@@ -4929,9 +4930,9 @@ u64 nfsd_print_client_delegations(struct nfs4_client *clp, u64 max)
 {
 	u64 count = 0;
 
-	spin_lock(&recall_lock);
+	spin_lock(&state_lock);
 	count = nfsd_find_all_delegations(clp, max, NULL);
-	spin_unlock(&recall_lock);
+	spin_unlock(&state_lock);
 
 	nfsd_print_count(clp, count, "delegations");
 	return count;
@@ -5149,12 +5150,12 @@ nfs4_state_shutdown_net(struct net *net)
 
 	nfs4_lock_state();
 	INIT_LIST_HEAD(&reaplist);
-	spin_lock(&recall_lock);
+	spin_lock(&state_lock);
 	list_for_each_safe(pos, next, &nn->del_recall_lru) {
 		dp = list_entry (pos, struct nfs4_delegation, dl_recall_lru);
 		list_move(&dp->dl_recall_lru, &reaplist);
 	}
-	spin_unlock(&recall_lock);
+	spin_unlock(&state_lock);
 	list_for_each_safe(pos, next, &reaplist) {
 		dp = list_entry (pos, struct nfs4_delegation, dl_recall_lru);
 		destroy_delegation(dp);
-- 
1.9.0


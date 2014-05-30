Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f50.google.com ([209.85.192.50]:42997 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932498AbaE3NJx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 May 2014 09:09:53 -0400
Received: by mail-qg0-f50.google.com with SMTP id z60so5103566qgd.37
        for <linux-nfs@vger.kernel.org>; Fri, 30 May 2014 06:09:53 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: trond.myklebust@primarydata.com, bhalevy@primarydata.com,
        linux-nfs@vger.kernel.org
Subject: [PATCH 6/9] nfsd4: rename recall_lock to state_lock
Date: Fri, 30 May 2014 09:09:30 -0400
Message-Id: <1401455373-18207-7-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1401455373-18207-1-git-send-email-jlayton@primarydata.com>
References: <1401455373-18207-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@primarydata.com>

...as the name is a bit more descriptive and we've started using it for
other purposes.

Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4state.c | 63 +++++++++++++++++++++++++++--------------------------
 1 file changed, 32 insertions(+), 31 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 96bdd90b96b1..040000de3732 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -81,7 +81,7 @@ static DEFINE_MUTEX(client_mutex);
  * effort to decrease the scope of the client_mutex, this spinlock may
  * eventually cover more:
  */
-static DEFINE_SPINLOCK(recall_lock);
+static DEFINE_SPINLOCK(state_lock);
 
 static struct kmem_cache *openowner_slab;
 static struct kmem_cache *lockowner_slab;
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
@@ -436,7 +436,7 @@ static void unhash_stid(struct nfs4_stid *s)
 static void
 hash_delegation_locked(struct nfs4_delegation *dp, struct nfs4_file *fp)
 {
-	lockdep_assert_held(&recall_lock);
+	lockdep_assert_held(&state_lock);
 
 	list_add(&dp->dl_perfile, &fp->fi_delegations);
 	list_add(&dp->dl_perclnt, &dp->dl_stid.sc_client->cl_delegations);
@@ -446,11 +446,11 @@ hash_delegation_locked(struct nfs4_delegation *dp, struct nfs4_file *fp)
 static void
 unhash_delegation(struct nfs4_delegation *dp)
 {
-	spin_lock(&recall_lock);
+	spin_lock(&state_lock);
 	list_del_init(&dp->dl_perclnt);
 	list_del_init(&dp->dl_perfile);
 	list_del_init(&dp->dl_recall_lru);
-	spin_unlock(&recall_lock);
+	spin_unlock(&state_lock);
 	if (dp->dl_file) {
 		nfs4_put_deleg_lease(dp->dl_file);
 		put_nfs4_file(dp->dl_file);
@@ -1161,13 +1161,13 @@ destroy_client(struct nfs4_client *clp)
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
@@ -2527,9 +2527,9 @@ static void nfsd4_init_file(struct nfs4_file *fp, struct inode *ino)
 	fp->fi_lease = NULL;
 	memset(fp->fi_fds, 0, sizeof(fp->fi_fds));
 	memset(fp->fi_access, 0, sizeof(fp->fi_access));
-	spin_lock(&recall_lock);
+	spin_lock(&state_lock);
 	hlist_add_head(&fp->fi_hash, &file_hashtbl[hashval]);
-	spin_unlock(&recall_lock);
+	spin_unlock(&state_lock);
 }
 
 void
@@ -2700,15 +2700,15 @@ find_file(struct inode *ino)
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
 
@@ -2745,6 +2745,7 @@ static void nfsd_break_one_deleg(struct nfs4_delegation *dp)
 	struct nfs4_client *clp = dp->dl_stid.sc_client;
 	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 
+	lockdep_assert_held(&state_lock);
 	/* We're assuming the state code never drops its reference
 	 * without first removing the lease.  Since we're in this lease
 	 * callback (and since the lease code is serialized by the kernel
@@ -2781,11 +2782,11 @@ static void nfsd_break_deleg_cb(struct file_lock *fl)
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
@@ -3065,9 +3066,9 @@ static int nfs4_setlease(struct nfs4_delegation *dp)
 	fp->fi_lease = fl;
 	fp->fi_deleg_file = get_file(fl->fl_file);
 	atomic_set(&fp->fi_delegees, 1);
-	spin_lock(&recall_lock);
+	spin_lock(&state_lock);
 	hash_delegation_locked(dp, fp);
-	spin_unlock(&recall_lock);
+	spin_unlock(&state_lock);
 	return 0;
 out_free:
 	locks_free_lock(fl);
@@ -3082,14 +3083,14 @@ static int nfs4_set_delegation(struct nfs4_delegation *dp, struct nfs4_file *fp)
 	dp->dl_file = fp;
 	if (!fp->fi_lease)
 		return nfs4_setlease(dp);
-	spin_lock(&recall_lock);
+	spin_lock(&state_lock);
 	atomic_inc(&fp->fi_delegees);
 	if (fp->fi_had_conflict) {
-		spin_unlock(&recall_lock);
+		spin_unlock(&state_lock);
 		return -EAGAIN;
 	}
 	hash_delegation_locked(dp, fp);
-	spin_unlock(&recall_lock);
+	spin_unlock(&state_lock);
 	return 0;
 }
 
@@ -3423,7 +3424,7 @@ nfs4_laundromat(struct nfsd_net *nn)
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
@@ -4900,7 +4901,7 @@ static u64 nfsd_find_all_delegations(struct nfs4_client *clp, u64 max,
 	struct nfs4_delegation *dp, *next;
 	u64 count = 0;
 
-	lockdep_assert_held(&recall_lock);
+	lockdep_assert_held(&state_lock);
 	list_for_each_entry_safe(dp, next, &clp->cl_delegations, dl_perclnt) {
 		if (victims)
 			list_move(&dp->dl_recall_lru, victims);
@@ -4916,9 +4917,9 @@ u64 nfsd_forget_client_delegations(struct nfs4_client *clp, u64 max)
 	LIST_HEAD(victims);
 	u64 count;
 
-	spin_lock(&recall_lock);
+	spin_lock(&state_lock);
 	count = nfsd_find_all_delegations(clp, max, &victims);
-	spin_unlock(&recall_lock);
+	spin_unlock(&state_lock);
 
 	list_for_each_entry_safe(dp, next, &victims, dl_recall_lru)
 		revoke_delegation(dp);
@@ -4932,11 +4933,11 @@ u64 nfsd_recall_client_delegations(struct nfs4_client *clp, u64 max)
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
@@ -4945,9 +4946,9 @@ u64 nfsd_print_client_delegations(struct nfs4_client *clp, u64 max)
 {
 	u64 count = 0;
 
-	spin_lock(&recall_lock);
+	spin_lock(&state_lock);
 	count = nfsd_find_all_delegations(clp, max, NULL);
-	spin_unlock(&recall_lock);
+	spin_unlock(&state_lock);
 
 	nfsd_print_count(clp, count, "delegations");
 	return count;
@@ -5158,12 +5159,12 @@ nfs4_state_shutdown_net(struct net *net)
 
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
1.9.3


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46284 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751326Ab1BIEz5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Feb 2011 23:55:57 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 6/6] nfsd4: modify fi_delegations under recall_lock
Date: Tue,  8 Feb 2011 23:55:51 -0500
Message-Id: <1297227351-15365-7-git-send-email-bfields@redhat.com>
In-Reply-To: <1297227351-15365-1-git-send-email-bfields@redhat.com>
References: <1297227351-15365-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Modify fi_delegations only under the recall_lock, allowing us to use
that list on lease breaks.

Also some trivial cleanup to simplify later changes.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   99 +++++++++++++++++++++++++++++---------------------
 fs/nfsd/state.h     |    5 ++-
 2 files changed, 60 insertions(+), 44 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 0375e99..a397de6 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -230,9 +230,6 @@ alloc_init_deleg(struct nfs4_client *clp, struct nfs4_stateid *stp, struct svc_f
 	dp->dl_client = clp;
 	get_nfs4_file(fp);
 	dp->dl_file = fp;
-	dp->dl_vfs_file = find_readable_file(fp);
-	get_file(dp->dl_vfs_file);
-	dp->dl_flock = NULL;
 	dp->dl_type = type;
 	dp->dl_stateid.si_boot = boot_time;
 	dp->dl_stateid.si_stateownerid = current_delegid++;
@@ -241,8 +238,6 @@ alloc_init_deleg(struct nfs4_client *clp, struct nfs4_stateid *stp, struct svc_f
 	fh_copy_shallow(&dp->dl_fh, &current_fh->fh_handle);
 	dp->dl_time = 0;
 	atomic_set(&dp->dl_count, 1);
-	list_add(&dp->dl_perfile, &fp->fi_delegations);
-	list_add(&dp->dl_perclnt, &clp->cl_delegations);
 	INIT_WORK(&dp->dl_recall.cb_work, nfsd4_do_callback_rpc);
 	return dp;
 }
@@ -253,36 +248,30 @@ nfs4_put_delegation(struct nfs4_delegation *dp)
 	if (atomic_dec_and_test(&dp->dl_count)) {
 		dprintk("NFSD: freeing dp %p\n",dp);
 		put_nfs4_file(dp->dl_file);
-		fput(dp->dl_vfs_file);
 		kmem_cache_free(deleg_slab, dp);
 		num_delegations--;
 	}
 }
 
-/* Remove the associated file_lock first, then remove the delegation.
- * lease_modify() is called to remove the FS_LEASE file_lock from
- * the i_flock list, eventually calling nfsd's lock_manager
- * fl_release_callback.
- */
-static void
-nfs4_close_delegation(struct nfs4_delegation *dp)
+static void nfs4_put_deleg_lease(struct nfs4_file *fp)
 {
-	dprintk("NFSD: close_delegation dp %p\n",dp);
-	/* XXX: do we even need this check?: */
-	if (dp->dl_flock)
-		vfs_setlease(dp->dl_vfs_file, F_UNLCK, &dp->dl_flock);
+	if (atomic_dec_and_test(&fp->fi_delegees)) {
+		vfs_setlease(fp->fi_deleg_file, F_UNLCK, &fp->fi_lease);
+		fp->fi_lease = NULL;
+		fp->fi_deleg_file = NULL;
+	}
 }
 
 /* Called under the state lock. */
 static void
 unhash_delegation(struct nfs4_delegation *dp)
 {
-	list_del_init(&dp->dl_perfile);
 	list_del_init(&dp->dl_perclnt);
 	spin_lock(&recall_lock);
+	list_del_init(&dp->dl_perfile);
 	list_del_init(&dp->dl_recall_lru);
 	spin_unlock(&recall_lock);
-	nfs4_close_delegation(dp);
+	nfs4_put_deleg_lease(dp->dl_file);
 	nfs4_put_delegation(dp);
 }
 
@@ -2076,6 +2065,7 @@ alloc_init_file(struct inode *ino)
 		fp->fi_inode = igrab(ino);
 		fp->fi_id = current_fileid++;
 		fp->fi_had_conflict = false;
+		fp->fi_lease = NULL;
 		memset(fp->fi_fds, 0, sizeof(fp->fi_fds));
 		memset(fp->fi_access, 0, sizeof(fp->fi_access));
 		spin_lock(&recall_lock);
@@ -2336,9 +2326,7 @@ static void nfsd_break_one_deleg(struct nfs4_delegation *dp)
 	 * it's safe to take a reference: */
 	atomic_inc(&dp->dl_count);
 
-	spin_lock(&recall_lock);
 	list_add_tail(&dp->dl_recall_lru, &del_recall_lru);
-	spin_unlock(&recall_lock);
 
 	/* only place dl_time is set. protected by lock_flocks*/
 	dp->dl_time = get_seconds();
@@ -2346,26 +2334,28 @@ static void nfsd_break_one_deleg(struct nfs4_delegation *dp)
 	nfsd4_cb_recall(dp);
 }
 
-/*
- * Called from break_lease() with lock_flocks() held.
- * Note: we assume break_lease will only call this *once* for any given
- * lease.
- */
+/* Called from break_lease() with lock_flocks() held. */
 static
 void nfsd_break_deleg_cb(struct file_lock *fl)
 {
-	struct nfs4_delegation *dp = (struct nfs4_delegation *)fl->fl_owner;
+	struct nfs4_file *fp = (struct nfs4_file *)fl->fl_owner;
+	struct nfs4_delegation *dp;
 
-	BUG_ON(!dp);
+	BUG_ON(!fp);
+	/* We assume break_lease is only called once per lease: */
+	BUG_ON(fp->fi_had_conflict);
 	/*
 	 * We don't want the locks code to timeout the lease for us;
-	 * we'll remove it ourself if the delegation isn't returned
+	 * we'll remove it ourself if a delegation isn't returned
 	 * in time:
 	 */
 	fl->fl_break_time = 0;
 
-	nfsd_break_one_deleg(dp);
-	dp->dl_file->fi_had_conflict = true;
+	spin_lock(&recall_lock);
+	fp->fi_had_conflict = true;
+	list_for_each_entry(dp, &fp->fi_delegations, dl_perfile)
+		nfsd_break_one_deleg(dp);
+	spin_unlock(&recall_lock);
 }
 
 static
@@ -2456,13 +2446,15 @@ nfs4_check_delegmode(struct nfs4_delegation *dp, int flags)
 static struct nfs4_delegation *
 find_delegation_file(struct nfs4_file *fp, stateid_t *stid)
 {
-	struct nfs4_delegation *dp;
+	struct nfs4_delegation *dp = NULL;
 
+	spin_lock(&recall_lock);
 	list_for_each_entry(dp, &fp->fi_delegations, dl_perfile) {
 		if (dp->dl_stateid.si_stateownerid == stid->si_stateownerid)
-			return dp;
+			break;
 	}
-	return NULL;
+	spin_unlock(&recall_lock);
+	return dp;
 }
 
 int share_access_to_flags(u32 share_access)
@@ -2650,28 +2642,51 @@ static struct file_lock *nfs4_alloc_init_lease(struct nfs4_delegation *dp, int f
 	fl->fl_flags = FL_LEASE;
 	fl->fl_type = flag == NFS4_OPEN_DELEGATE_READ? F_RDLCK: F_WRLCK;
 	fl->fl_end = OFFSET_MAX;
-	fl->fl_owner = (fl_owner_t)dp;
-	fl->fl_file = dp->dl_vfs_file;
-	BUG_ON(!fl->fl_file);
+	fl->fl_owner = (fl_owner_t)(dp->dl_file);
 	fl->fl_pid = current->tgid;
-	dp->dl_flock = fl;
 	return fl;
 }
 
 static int nfs4_setlease(struct nfs4_delegation *dp, int flag)
 {
+	struct nfs4_file *fp = dp->dl_file;
 	struct file_lock *fl;
 	int status;
 
 	fl = nfs4_alloc_init_lease(dp, flag);
 	if (!fl)
 		return -ENOMEM;
-	status = vfs_setlease(dp->dl_vfs_file, fl->fl_type, &fl);
+	fl->fl_file = find_readable_file(fp);
+	list_add(&dp->dl_perclnt, &dp->dl_client->cl_delegations);
+	status = vfs_setlease(fl->fl_file, fl->fl_type, &fl);
 	if (status) {
-		dp->dl_flock = NULL;
+		list_del_init(&dp->dl_perclnt);
 		locks_free_lock(fl);
 		return -ENOMEM;
 	}
+	fp->fi_lease = fl;
+	fp->fi_deleg_file = fl->fl_file;
+	get_file(fp->fi_deleg_file);
+	atomic_set(&fp->fi_delegees, 1);
+	list_add(&dp->dl_perfile, &fp->fi_delegations);
+	return 0;
+}
+
+static int nfs4_set_delegation(struct nfs4_delegation *dp, int flag)
+{
+	struct nfs4_file *fp = dp->dl_file;
+
+	if (!fp->fi_lease)
+		return nfs4_setlease(dp, flag);
+	spin_lock(&recall_lock);
+	if (fp->fi_had_conflict) {
+		spin_unlock(&recall_lock);
+		return -EAGAIN;
+	}
+	atomic_inc(&fp->fi_delegees);
+	list_add(&dp->dl_perfile, &fp->fi_delegations);
+	spin_unlock(&recall_lock);
+	list_add(&dp->dl_perclnt, &dp->dl_client->cl_delegations);
 	return 0;
 }
 
@@ -2716,7 +2731,7 @@ nfs4_open_delegation(struct svc_fh *fh, struct nfsd4_open *open, struct nfs4_sta
 	dp = alloc_init_deleg(sop->so_client, stp, fh, flag);
 	if (dp == NULL)
 		goto out_no_deleg;
-	status = nfs4_setlease(dp, flag);
+	status = nfs4_set_delegation(dp, flag);
 	if (status)
 		goto out_free;
 
@@ -2732,7 +2747,7 @@ out:
 	open->op_delegate_type = flag;
 	return;
 out_free:
-	unhash_delegation(dp);
+	nfs4_put_delegation(dp);
 out_no_deleg:
 	flag = NFS4_OPEN_DELEGATE_NONE;
 	goto out;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 3074656..2d31224 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -83,8 +83,6 @@ struct nfs4_delegation {
 	atomic_t		dl_count;       /* ref count */
 	struct nfs4_client	*dl_client;
 	struct nfs4_file	*dl_file;
-	struct file		*dl_vfs_file;
-	struct file_lock	*dl_flock;
 	u32			dl_type;
 	time_t			dl_time;
 /* For recall: */
@@ -379,6 +377,9 @@ struct nfs4_file {
 	 */
 	atomic_t		fi_readers;
 	atomic_t		fi_writers;
+	struct file		*fi_deleg_file;
+	struct file_lock	*fi_lease;
+	atomic_t		fi_delegees;
 	struct inode		*fi_inode;
 	u32                     fi_id;      /* used with stateowner->so_id 
 					     * for stateid_hashtbl hash */
-- 
1.7.1


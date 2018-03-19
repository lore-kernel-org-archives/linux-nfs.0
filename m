Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:41698 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755763AbeCSOgr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Mar 2018 10:36:47 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 09/10] nfsd: create a separate lease for each delegation
Date: Mon, 19 Mar 2018 10:36:33 -0400
Message-Id: <1521470194-24840-10-git-send-email-bfields@redhat.com>
In-Reply-To: <1521470194-24840-1-git-send-email-bfields@redhat.com>
References: <1521470194-24840-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Currently we only take one vfs-level delegation (lease) for each file,
no matter how many clients hold delegations on that file.

Let's instead keep a one-to-one mapping between NFSv4 delegations and
VFS delegations.  This turns out to be simpler.

There is still a many-to-one mapping of NFS opens to NFS files, and the
delegations on one file are all associated with one struct file.  The
VFS can still distinguish between these delegations since we're setting
fl_owner to the struct nfs4_delegation now, not to the shared file.

I'm replacing at least one complicated function wholesale, which I don't
like to do, but I haven't figured out how to do this more incrementally.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c | 173 ++++++++++++++++++++--------------------------------
 1 file changed, 65 insertions(+), 108 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 26880d0122c5..ca8a5644d9ff 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -848,29 +848,34 @@ nfs4_inc_and_copy_stateid(stateid_t *dst, struct nfs4_stid *stid)
 	spin_unlock(&stid->sc_lock);
 }
 
-static void nfs4_put_deleg_lease(struct nfs4_delegation *dp)
+static void put_deleg_file(struct nfs4_file *fp)
 {
 	struct file *filp = NULL;
-	struct nfs4_file *fp = dp->dl_stid.sc_file;
-
-	WARN_ON_ONCE(!fp->fi_delegees);
 
 	spin_lock(&fp->fi_lock);
-	if (--fp->fi_delegees == 0) {
+	if (--fp->fi_delegees == 0)
 		swap(filp, fp->fi_deleg_file);
-	}
 	spin_unlock(&fp->fi_lock);
 
-	if (filp) {
-		vfs_setlease(filp, F_UNLCK, NULL, (void **)&dp);
+	if (filp)
 		fput(filp);
-	}
+}
+
+static void nfs4_unlock_deleg_lease(struct nfs4_delegation *dp)
+{
+	struct nfs4_file *fp = dp->dl_stid.sc_file;
+	struct file *filp = fp->fi_deleg_file;
+
+	WARN_ON_ONCE(!fp->fi_delegees);
+
+	vfs_setlease(filp, F_UNLCK, NULL, (void **)&dp);
+	put_deleg_file(fp);
 }
 
 static void destroy_unhashed_deleg(struct nfs4_delegation *dp)
 {
 	put_clnt_odstate(dp->dl_clnt_odstate);
-	nfs4_put_deleg_lease(dp);
+	nfs4_unlock_deleg_lease(dp);
 	nfs4_put_stid(&dp->dl_stid);
 }
 
@@ -929,7 +934,6 @@ hash_delegation_locked(struct nfs4_delegation *dp, struct nfs4_file *fp)
 
 	if (nfs4_delegation_exists(clp, fp))
 		return -EAGAIN;
-	++fp->fi_delegees;
 	refcount_inc(&dp->dl_stid.sc_count);
 	dp->dl_stid.sc_type = NFS4_DELEG_STID;
 	list_add(&dp->dl_perfile, &fp->fi_delegations);
@@ -3908,10 +3912,6 @@ nfsd_break_deleg_cb(struct file_lock *fl)
 	struct nfs4_delegation *dp = (struct nfs4_delegation *)fl->fl_owner;
 	struct nfs4_file *fp = dp->dl_stid.sc_file;
 
-	if (fp->fi_had_conflict) {
-		WARN(1, "duplicate break on %p\n", fp);
-		return ret;
-	}
 	/*
 	 * We don't want the locks code to timeout the lease for us;
 	 * we'll remove it ourself if a delegation isn't returned
@@ -3921,15 +3921,7 @@ nfsd_break_deleg_cb(struct file_lock *fl)
 
 	spin_lock(&fp->fi_lock);
 	fp->fi_had_conflict = true;
-	/*
-	 * If there are no delegations on the list, then return true
-	 * so that the lease code will go ahead and delete it.
-	 */
-	if (list_empty(&fp->fi_delegations))
-		ret = true;
-	else
-		list_for_each_entry(dp, &fp->fi_delegations, dl_perfile)
-			nfsd_break_one_deleg(dp);
+	nfsd_break_one_deleg(dp);
 	spin_unlock(&fp->fi_lock);
 	return ret;
 }
@@ -4267,121 +4259,86 @@ static struct file_lock *nfs4_alloc_init_lease(struct nfs4_delegation *dp,
 	fl->fl_end = OFFSET_MAX;
 	fl->fl_owner = dp;
 	fl->fl_pid = current->tgid;
+	fl->fl_file = dp->dl_stid.sc_file->fi_deleg_file;
 	return fl;
 }
 
-/**
- * nfs4_setlease - Obtain a delegation by requesting lease from vfs layer
- * @dp:   a pointer to the nfs4_delegation we're adding.
- *
- * Return:
- *      On success: Return code will be 0 on success.
- *
- *      On error: -EAGAIN if there was an existing delegation.
- *                 nonzero if there is an error in other cases.
- *
- */
-
-static int nfs4_setlease(struct nfs4_delegation *dp)
-{
-	struct nfs4_file *fp = dp->dl_stid.sc_file;
-	struct file_lock *fl;
-	struct file *filp;
-	int status = 0;
-
-	fl = nfs4_alloc_init_lease(dp, NFS4_OPEN_DELEGATE_READ);
-	if (!fl)
-		return -ENOMEM;
-	filp = find_readable_file(fp);
-	if (!filp) {
-		/* We should always have a readable file here */
-		WARN_ON_ONCE(1);
-		locks_free_lock(fl);
-		return -EBADF;
-	}
-	fl->fl_file = filp;
-	status = vfs_setlease(filp, fl->fl_type, &fl, NULL);
-	if (fl)
-		locks_free_lock(fl);
-	if (status)
-		goto out_fput;
-	spin_lock(&state_lock);
-	spin_lock(&fp->fi_lock);
-	/* Did the lease get broken before we took the lock? */
-	status = -EAGAIN;
-	if (fp->fi_had_conflict)
-		goto out_unlock;
-	/* Race breaker */
-	if (fp->fi_deleg_file) {
-		status = hash_delegation_locked(dp, fp);
-		goto out_unlock;
-	}
-	fp->fi_deleg_file = filp;
-	fp->fi_delegees = 0;
-	status = hash_delegation_locked(dp, fp);
-	spin_unlock(&fp->fi_lock);
-	spin_unlock(&state_lock);
-	if (status) {
-		/* Should never happen, this is a new fi_deleg_file  */
-		WARN_ON_ONCE(1);
-		goto out_fput;
-	}
-	return 0;
-out_unlock:
-	spin_unlock(&fp->fi_lock);
-	spin_unlock(&state_lock);
-out_fput:
-	fput(filp);
-	return status;
-}
-
 static struct nfs4_delegation *
 nfs4_set_delegation(struct nfs4_client *clp, struct svc_fh *fh,
 		    struct nfs4_file *fp, struct nfs4_clnt_odstate *odstate)
 {
 	int status = 0;
 	struct nfs4_delegation *dp;
+	struct file *filp;
+	struct file_lock *fl;
 
+	/*
+	 * The fi_had_conflict and nfs_get_existing_delegation checks
+	 * here are just optimizations; we'll need to recheck them at
+	 * the end:
+	 */
 	if (fp->fi_had_conflict)
 		return ERR_PTR(-EAGAIN);
 
+	filp = find_readable_file(fp);
+	if (!filp) {
+		/* We should always have a readable file here */
+		WARN_ON_ONCE(1);
+		return ERR_PTR(-EBADF);
+	}
 	spin_lock(&state_lock);
 	spin_lock(&fp->fi_lock);
 	if (nfs4_delegation_exists(clp, fp))
 		status = -EAGAIN;
+	else if (!fp->fi_deleg_file) {
+		fp->fi_deleg_file = filp;
+		/* increment early to prevent fi_deleg_file from being
+		 * cleared */
+		fp->fi_delegees = 1;
+		filp = NULL;
+	} else
+		fp->fi_delegees++;
 	spin_unlock(&fp->fi_lock);
 	spin_unlock(&state_lock);
-
+	if (filp)
+		fput(filp);
 	if (status)
 		return ERR_PTR(status);
 
+	status = -ENOMEM;
 	dp = alloc_init_deleg(clp, fp, fh, odstate);
 	if (!dp)
-		return ERR_PTR(-ENOMEM);
+		goto out_delegees;
+
+	fl = nfs4_alloc_init_lease(dp, NFS4_OPEN_DELEGATE_READ);
+	if (!fl)
+		goto out_stid;
+
+	status = vfs_setlease(fp->fi_deleg_file, fl->fl_type, &fl, NULL);
+	if (fl)
+		locks_free_lock(fl);
+	if (status)
+		goto out_clnt_odstate;
 
 	spin_lock(&state_lock);
 	spin_lock(&fp->fi_lock);
-	if (!fp->fi_deleg_file) {
-		spin_unlock(&fp->fi_lock);
-		spin_unlock(&state_lock);
-		status = nfs4_setlease(dp);
-		goto out;
-	}
-	if (fp->fi_had_conflict) {
+	if (fp->fi_had_conflict)
 		status = -EAGAIN;
-		goto out_unlock;
-	}
-	status = hash_delegation_locked(dp, fp);
-out_unlock:
+	else
+		status = hash_delegation_locked(dp, fp);
 	spin_unlock(&fp->fi_lock);
 	spin_unlock(&state_lock);
-out:
-	if (status) {
-		put_clnt_odstate(dp->dl_clnt_odstate);
-		nfs4_put_stid(&dp->dl_stid);
-		return ERR_PTR(status);
-	}
+
+	if (status)
+		destroy_unhashed_deleg(dp);
 	return dp;
+out_clnt_odstate:
+	put_clnt_odstate(dp->dl_clnt_odstate);
+out_stid:
+	nfs4_put_stid(&dp->dl_stid);
+out_delegees:
+	put_deleg_file(fp);
+	return ERR_PTR(status);
 }
 
 static void nfsd4_open_deleg_none_ext(struct nfsd4_open *open, int status)
-- 
2.14.3


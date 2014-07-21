Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37610 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751708AbaGUVFi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Jul 2014 17:05:38 -0400
Date: Mon, 21 Jul 2014 17:05:31 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: hch@infradead.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 01/10] nfsd: Protect the nfs4_file delegation fields
 using the fi_lock
Message-ID: <20140721210531.GJ8438@fieldses.org>
References: <1405696416-32585-1-git-send-email-jlayton@primarydata.com>
 <1405696416-32585-2-git-send-email-jlayton@primarydata.com>
 <20140718162825.GA8811@fieldses.org>
 <20140718133140.6a26ea4d@f20.localdomain>
 <20140718174957.GA12801@fieldses.org>
 <20140718150404.3d1e094c@tlielax.poochiereds.net>
 <20140718192149.GC12801@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140718192149.GC12801@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 18, 2014 at 03:21:49PM -0400, J. Bruce Fields wrote:
> On Fri, Jul 18, 2014 at 03:04:04PM -0400, Jeff Layton wrote:
> > On Fri, 18 Jul 2014 13:49:57 -0400
> > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > 
> > > On Fri, Jul 18, 2014 at 01:31:40PM -0400, Jeff Layton wrote:
> > > > On Fri, 18 Jul 2014 12:28:25 -0400
> > > > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > > > 
> > > > > On Fri, Jul 18, 2014 at 11:13:27AM -0400, Jeff Layton wrote:
> > > > > > Move more of the delegation fields to be protected by the fi_lock. It's
> > > > > > more granular than the state_lock and in later patches we'll want to
> > > > > > be able to rely on it in addition to the state_lock.
> > > > > > 
> > > > > > Also, the current code in nfs4_setlease calls vfs_setlease and uses the
> > > > > > client_mutex to ensure that it doesn't disappear before we can hash the
> > > > > > delegation. With the client_mutex gone, we'll have a potential race
> > > > > > condition.
> > > > > > 
> > > > > > It's possible that the delegation could be recalled after we acquire the
> > > > > > lease but before we ever get around to hashing it. If that happens, then
> > > > > > we'd have a nfs4_file that *thinks* it has a delegation, when it
> > > > > > actually has none.
> > > > > 
> > > > > I understand now, thanks: so the lease break code walks the list of
> > > > > delegations associated with the file, finds none, and issues no recall,
> > > > > but the open code continues merrily on and returns a delegation, with
> > > > > the result that we return the client a delegation that will never be
> > > > > recalled.
> > > > > 
> > > > > That could be worded more carefully, and would be worth a separate patch
> > > > > (since the bug predates the new locking).
> > > > > 
> > > > 
> > > > Yes, that's basically correct. I'd have to think about how to fix that
> > > > with the current code. It's probably doable if you think it's
> > > > worthwhile, but I'll need to rebase this set on top of it.
> > > 
> > > Well, I was wondering if this patch could just be split in two, no need
> > > to backport further than that.
> > > 
> > 
> > Erm, now that I've looked, I don't think it'll be that easy. The key
> > here is to ensure that fi_had_conflict is set while holding the
> > fi_lock. The trick here is that we need to take it in nfs4_setlease as
> > well, and check the flag before hashing the delegation without dropping
> > the fi_lock.
> 
> OK, I'll live.  For the sake of anyone that actually runs across that
> bug I'll update the summary and changelog to emphasize the bugfix over
> the locking change.

So, intending to apply as follows.

--b.

commit 417c6629b2d81d5a18d29c4bbb6a9a4c64282a36
Author: Jeff Layton <jlayton@primarydata.com>
Date:   Mon Jul 21 09:34:57 2014 -0400

    nfsd: fix race that grants unrecallable delegation
    
    If nfs4_setlease succesfully acquires a new delegation, then another
    task breaks the delegation before we reach hash_delegation_locked, then
    the breaking task will see an empty fi_delegations list and do nothing.
    The client will receive an open reply incorrectly granting a delegation
    and will never receive a recall.
    
    Move more of the delegation fields to be protected by the fi_lock. It's
    more granular than the state_lock and in later patches we'll want to
    be able to rely on it in addition to the state_lock.
    
    Attempt to acquire a delegation. If that succeeds, take the spinlocks
    and then check to see if the file has had a conflict show up since then.
    If it has, then we assume that the lease is no longer valid and that
    we shouldn't hand out a delegation.
    
    There's also one more potential (but very unlikely) problem. If the
    lease is broken before the delegation is hashed, then it could leak.
    In the event that the fi_delegations list is empty, reset the
    fl_break_time to jiffies so that it's cleaned up ASAP by
    the normal lease handling code.
    
    Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
    Signed-off-by: Jeff Layton <jlayton@primarydata.com>
    Reviewed-by: Christoph Hellwig <hch@lst.de>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 10cdb67..cc477dd 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -624,6 +624,8 @@ nfs4_put_delegation(struct nfs4_delegation *dp)
 
 static void nfs4_put_deleg_lease(struct nfs4_file *fp)
 {
+	lockdep_assert_held(&state_lock);
+
 	if (!fp->fi_lease)
 		return;
 	if (atomic_dec_and_test(&fp->fi_delegees)) {
@@ -643,11 +645,10 @@ static void
 hash_delegation_locked(struct nfs4_delegation *dp, struct nfs4_file *fp)
 {
 	lockdep_assert_held(&state_lock);
+	lockdep_assert_held(&fp->fi_lock);
 
 	dp->dl_stid.sc_type = NFS4_DELEG_STID;
-	spin_lock(&fp->fi_lock);
 	list_add(&dp->dl_perfile, &fp->fi_delegations);
-	spin_unlock(&fp->fi_lock);
 	list_add(&dp->dl_perclnt, &dp->dl_stid.sc_client->cl_delegations);
 }
 
@@ -659,17 +660,18 @@ unhash_delegation(struct nfs4_delegation *dp)
 
 	spin_lock(&state_lock);
 	dp->dl_stid.sc_type = NFS4_CLOSED_DELEG_STID;
+	spin_lock(&fp->fi_lock);
 	list_del_init(&dp->dl_perclnt);
 	list_del_init(&dp->dl_recall_lru);
-	spin_lock(&fp->fi_lock);
 	list_del_init(&dp->dl_perfile);
 	spin_unlock(&fp->fi_lock);
-	spin_unlock(&state_lock);
 	if (fp) {
 		nfs4_put_deleg_lease(fp);
-		put_nfs4_file(fp);
 		dp->dl_file = NULL;
 	}
+	spin_unlock(&state_lock);
+	if (fp)
+		put_nfs4_file(fp);
 }
 
 static void destroy_revoked_delegation(struct nfs4_delegation *dp)
@@ -3141,10 +3143,19 @@ static void nfsd_break_deleg_cb(struct file_lock *fl)
 	 */
 	fl->fl_break_time = 0;
 
-	fp->fi_had_conflict = true;
 	spin_lock(&fp->fi_lock);
-	list_for_each_entry(dp, &fp->fi_delegations, dl_perfile)
-		nfsd_break_one_deleg(dp);
+	fp->fi_had_conflict = true;
+	/*
+	 * If there are no delegations on the list, then we can't count on this
+	 * lease ever being cleaned up. Set the fl_break_time to jiffies so that
+	 * time_out_leases will do it ASAP. The fact that fi_had_conflict is now
+	 * true should keep any new delegations from being hashed.
+	 */
+	if (list_empty(&fp->fi_delegations))
+		fl->fl_break_time = jiffies;
+	else
+		list_for_each_entry(dp, &fp->fi_delegations, dl_perfile)
+			nfsd_break_one_deleg(dp);
 	spin_unlock(&fp->fi_lock);
 }
 
@@ -3491,46 +3502,77 @@ static int nfs4_setlease(struct nfs4_delegation *dp)
 {
 	struct nfs4_file *fp = dp->dl_file;
 	struct file_lock *fl;
-	int status;
+	struct file *filp;
+	int status = 0;
 
 	fl = nfs4_alloc_init_lease(fp, NFS4_OPEN_DELEGATE_READ);
 	if (!fl)
 		return -ENOMEM;
-	fl->fl_file = find_readable_file(fp);
-	status = vfs_setlease(fl->fl_file, fl->fl_type, &fl);
-	if (status)
-		goto out_free;
+	filp = find_readable_file(fp);
+	if (!filp) {
+		/* We should always have a readable file here */
+		WARN_ON_ONCE(1);
+		return -EBADF;
+	}
+	fl->fl_file = filp;
+	status = vfs_setlease(filp, fl->fl_type, &fl);
+	if (status) {
+		locks_free_lock(fl);
+		goto out_fput;
+	}
+	spin_lock(&state_lock);
+	spin_lock(&fp->fi_lock);
+	/* Did the lease get broken before we took the lock? */
+	status = -EAGAIN;
+	if (fp->fi_had_conflict)
+		goto out_unlock;
+	/* Race breaker */
+	if (fp->fi_lease) {
+		status = 0;
+		atomic_inc(&fp->fi_delegees);
+		hash_delegation_locked(dp, fp);
+		goto out_unlock;
+	}
 	fp->fi_lease = fl;
-	fp->fi_deleg_file = fl->fl_file;
+	fp->fi_deleg_file = filp;
 	atomic_set(&fp->fi_delegees, 1);
-	spin_lock(&state_lock);
 	hash_delegation_locked(dp, fp);
+	spin_unlock(&fp->fi_lock);
 	spin_unlock(&state_lock);
 	return 0;
-out_free:
-	if (fl->fl_file)
-		fput(fl->fl_file);
-	locks_free_lock(fl);
+out_unlock:
+	spin_unlock(&fp->fi_lock);
+	spin_unlock(&state_lock);
+out_fput:
+	fput(filp);
 	return status;
 }
 
 static int nfs4_set_delegation(struct nfs4_delegation *dp, struct nfs4_file *fp)
 {
+	int status = 0;
+
 	if (fp->fi_had_conflict)
 		return -EAGAIN;
 	get_nfs4_file(fp);
+	spin_lock(&state_lock);
+	spin_lock(&fp->fi_lock);
 	dp->dl_file = fp;
-	if (!fp->fi_lease)
+	if (!fp->fi_lease) {
+		spin_unlock(&fp->fi_lock);
+		spin_unlock(&state_lock);
 		return nfs4_setlease(dp);
-	spin_lock(&state_lock);
+	}
 	atomic_inc(&fp->fi_delegees);
 	if (fp->fi_had_conflict) {
-		spin_unlock(&state_lock);
-		return -EAGAIN;
+		status = -EAGAIN;
+		goto out_unlock;
 	}
 	hash_delegation_locked(dp, fp);
+out_unlock:
+	spin_unlock(&fp->fi_lock);
 	spin_unlock(&state_lock);
-	return 0;
+	return status;
 }
 
 static void nfsd4_open_deleg_none_ext(struct nfsd4_open *open, int status)

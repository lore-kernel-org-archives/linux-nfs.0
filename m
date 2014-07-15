Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f173.google.com ([209.85.216.173]:63568 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758866AbaGOMNg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jul 2014 08:13:36 -0400
Received: by mail-qc0-f173.google.com with SMTP id c9so4843268qcz.32
        for <linux-nfs@vger.kernel.org>; Tue, 15 Jul 2014 05:13:36 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Tue, 15 Jul 2014 08:13:34 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: nfsd4_locku / nfs4_free_lock_stateid question
Message-ID: <20140715081334.654473fd@tlielax.poochiereds.net>
In-Reply-To: <20140713121919.GA6456@infradead.org>
References: <20140713110047.GA28727@infradead.org>
	<20140713080541.30ecbb51@tlielax.poochiereds.net>
	<20140713121919.GA6456@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 13 Jul 2014 05:19:19 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> On Sun, Jul 13, 2014 at 08:05:41AM -0400, Jeff Layton wrote:
> > It is weird, but I don't think it really matters as the filp is only
> > really used as a way to get to the inode -- it really doesn't matter
> > which struct file we use there. find_any_file will both take a
> > reference to and return the file, which is then eventually fput in
> > filp_close, so there should be no refcount leak or anything.
> > 
> > The weirdness all comes from the vfs-layer file locking interfaces,
> > many of which take a struct file argument when they really would be
> > fine with a struct inode. Maybe one of these days we can get around to
> > cleaning that up.
> 
> If filesystems get the file passed we should assume that they actually
> use it.  In fact AFS does, but it's not NFS exportable at the moment,
> and ceph does in a debug printk.  I'd be much happier to waste a pointer
> in the lock stateid to avoid this inconsistant interface.  And it would
> allow to kill find_any_fileas well..
> 

I started looking at this this morning...

FWIW, I don't see where AFS uses the struct file for anything
non-trivial in the filp_close codepaths. afs_do_unlk doesn't seem to do
much with it, and I don't see a ->flush operation for AFS. Am I missing
something there?

Here's what I think this change would look like. It builds but is
otherwise untested, and the commit log is sort of half-assed right now.
It should get slotted on top of this patch in the series:

    nfsd: do filp_close in sc_free callback for lock stateids

I'm not sure this really improves anything.

For one thing, we can only store a single struct file, but there's no
guarantee that the locks represented by the lock stateid all used that
file. Also, find_any_file is rather cheap, so I don't see this helping
performance much.

Given that, is this really worth the extra memory? Thoughts?

-------------------------[snip]---------------------------

[PATCH] nfsd: avoid having to search for struct file in lock stateid release codepath

Add a struct file pointer to struct nfs4_ol_stateid, and have nfsd4_lock
keep a reference to the file that it finds to set the lock. In the event
that the lock stateid represents more than one lock, then keep the
reference to the last struct file used. With this, we can also eliminate
find_any_file.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 43 +++++++++++++------------------------------
 fs/nfsd/state.h     | 17 +++++++++--------
 2 files changed, 22 insertions(+), 38 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 4606b4ec6dc3..795f3ece5167 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -328,22 +328,6 @@ find_readable_file(struct nfs4_file *f)
 	return ret;
 }
 
-static struct file *
-find_any_file(struct nfs4_file *f)
-{
-	struct file *ret;
-
-	spin_lock(&f->fi_lock);
-	ret = __nfs4_get_fd(f, O_RDWR);
-	if (!ret) {
-		ret = __nfs4_get_fd(f, O_WRONLY);
-		if (!ret)
-			ret = __nfs4_get_fd(f, O_RDONLY);
-	}
-	spin_unlock(&f->fi_lock);
-	return ret;
-}
-
 static int num_delegations;
 unsigned long max_delegations;
 
@@ -914,9 +898,8 @@ static void nfs4_free_lock_stateid(struct nfs4_stid *stid)
 	struct nfs4_lockowner *lo = lockowner(stp->st_stateowner);
 	struct file *file;
 
-	file = find_any_file(stp->st_stid.sc_file);
-	if (file)
-		filp_close(file, (fl_owner_t)lo);
+	if (stp->st_file)
+		filp_close(stp->st_file, (fl_owner_t)lo);
 	nfs4_free_generic_stateid(stid);
 }
 
@@ -4866,8 +4849,10 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		case NFS4_READW_LT:
 			spin_lock(&fp->fi_lock);
 			filp = find_readable_file_locked(fp);
-			if (filp)
+			if (filp) {
+				swap(lock_stp->st_file, filp);
 				get_lock_access(lock_stp, NFS4_SHARE_ACCESS_READ);
+			}
 			spin_unlock(&fp->fi_lock);
 			file_lock->fl_type = F_RDLCK;
 			break;
@@ -4875,8 +4860,10 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		case NFS4_WRITEW_LT:
 			spin_lock(&fp->fi_lock);
 			filp = find_writeable_file_locked(fp);
-			if (filp)
+			if (filp) {
+				swap(lock_stp->st_file, filp);
 				get_lock_access(lock_stp, NFS4_SHARE_ACCESS_WRITE);
+			}
 			spin_unlock(&fp->fi_lock);
 			file_lock->fl_type = F_WRLCK;
 			break;
@@ -5038,7 +5025,6 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	    struct nfsd4_locku *locku)
 {
 	struct nfs4_ol_stateid *stp;
-	struct file *filp = NULL;
 	struct file_lock *file_lock = NULL;
 	__be32 status;
 	int err;
@@ -5058,8 +5044,7 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 					&stp, nn);
 	if (status)
 		goto out;
-	filp = find_any_file(stp->st_stid.sc_file);
-	if (!filp) {
+	if (!stp->st_file) {
 		status = nfserr_lock_range;
 		goto out;
 	}
@@ -5067,13 +5052,13 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (!file_lock) {
 		dprintk("NFSD: %s: unable to allocate lock!\n", __func__);
 		status = nfserr_jukebox;
-		goto fput;
+		goto out;
 	}
 	locks_init_lock(file_lock);
 	file_lock->fl_type = F_UNLCK;
 	file_lock->fl_owner = (fl_owner_t)lockowner(stp->st_stateowner);
 	file_lock->fl_pid = current->tgid;
-	file_lock->fl_file = filp;
+	file_lock->fl_file = stp->st_file;
 	file_lock->fl_flags = FL_POSIX;
 	file_lock->fl_lmops = &nfsd_posix_mng_ops;
 	file_lock->fl_start = locku->lu_offset;
@@ -5082,15 +5067,13 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 						locku->lu_length);
 	nfs4_transform_lock_offset(file_lock);
 
-	err = vfs_lock_file(filp, F_SETLK, file_lock, NULL);
+	err = vfs_lock_file(stp->st_file, F_SETLK, file_lock, NULL);
 	if (err) {
 		dprintk("NFSD: nfs4_locku: vfs_lock_file failed!\n");
 		goto out_nfserr;
 	}
 	update_stateid(&stp->st_stid.sc_stateid);
 	memcpy(&locku->lu_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
-fput:
-	fput(filp);
 out:
 	nfsd4_bump_seqid(cstate, status);
 	nfs4_unlock_state();
@@ -5100,7 +5083,7 @@ out:
 
 out_nfserr:
 	status = nfserrno(err);
-	goto fput;
+	goto out;
 }
 
 /*
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 1b184f92ae51..e9733efc2fe4 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -405,14 +405,15 @@ struct nfs4_file {
 
 /* "ol" stands for "Open or Lock".  Better suggestions welcome. */
 struct nfs4_ol_stateid {
-	struct nfs4_stid    st_stid; /* must be first field */
-	struct list_head              st_perfile;
-	struct list_head              st_perstateowner;
-	struct list_head              st_locks;
-	struct nfs4_stateowner      * st_stateowner;
-	unsigned char                 st_access_bmap;
-	unsigned char                 st_deny_bmap;
-	struct nfs4_ol_stateid         * st_openstp;
+	struct nfs4_stid		st_stid;
+	struct list_head		st_perfile;
+	struct list_head		st_perstateowner;
+	struct list_head		st_locks;
+	struct nfs4_stateowner *	st_stateowner;
+	struct file *			st_file;
+	struct nfs4_ol_stateid *	st_openstp;
+	unsigned char			st_access_bmap;
+	unsigned char			st_deny_bmap;
 };
 
 static inline struct nfs4_ol_stateid *openlockstateid(struct nfs4_stid *s)
-- 
1.9.3


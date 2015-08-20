Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f171.google.com ([209.85.160.171]:33541 "EHLO
	mail-yk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751853AbbHTLRo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Aug 2015 07:17:44 -0400
Received: by ykll84 with SMTP id l84so33736032ykl.0
        for <linux-nfs@vger.kernel.org>; Thu, 20 Aug 2015 04:17:43 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@lst.de, kinglongmee@gmail.com
Subject: [PATCH v3 18/20] nfsd: convert fi_deleg_file and ls_file fields to nfsd_file
Date: Thu, 20 Aug 2015 07:17:18 -0400
Message-Id: <1440069440-27454-19-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1440069440-27454-1-git-send-email-jeff.layton@primarydata.com>
References: <1440069440-27454-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Have them keep an nfsd_file reference instead of a struct file.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfsd/nfs4layouts.c |  12 ++---
 fs/nfsd/nfs4state.c   | 131 ++++++++++++++++++++++++++------------------------
 fs/nfsd/state.h       |   6 +--
 3 files changed, 76 insertions(+), 73 deletions(-)

diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
index ebf90e487c75..9b49876a9cc1 100644
--- a/fs/nfsd/nfs4layouts.c
+++ b/fs/nfsd/nfs4layouts.c
@@ -144,8 +144,8 @@ nfsd4_free_layout_stateid(struct nfs4_stid *stid)
 	list_del_init(&ls->ls_perfile);
 	spin_unlock(&fp->fi_lock);
 
-	vfs_setlease(ls->ls_file, F_UNLCK, NULL, (void **)&ls);
-	fput(ls->ls_file);
+	vfs_setlease(ls->ls_file->nf_file, F_UNLCK, NULL, (void **)&ls);
+	nfsd_file_put(ls->ls_file);
 
 	if (ls->ls_recalled)
 		atomic_dec(&ls->ls_stid.sc_file->fi_lo_recalls);
@@ -169,7 +169,7 @@ nfsd4_layout_setlease(struct nfs4_layout_stateid *ls)
 	fl->fl_end = OFFSET_MAX;
 	fl->fl_owner = ls;
 	fl->fl_pid = current->tgid;
-	fl->fl_file = ls->ls_file;
+	fl->fl_file = ls->ls_file->nf_file;
 
 	status = vfs_setlease(fl->fl_file, fl->fl_type, &fl, NULL);
 	if (status) {
@@ -206,13 +206,13 @@ nfsd4_alloc_layout_stateid(struct nfsd4_compound_state *cstate,
 			NFSPROC4_CLNT_CB_LAYOUT);
 
 	if (parent->sc_type == NFS4_DELEG_STID)
-		ls->ls_file = get_file(fp->fi_deleg_file);
+		ls->ls_file = nfsd_file_get(fp->fi_deleg_file);
 	else
 		ls->ls_file = find_any_file(fp);
 	BUG_ON(!ls->ls_file);
 
 	if (nfsd4_layout_setlease(ls)) {
-		fput(ls->ls_file);
+		nfsd_file_put(ls->ls_file);
 		put_nfs4_file(fp);
 		kmem_cache_free(nfs4_layout_stateid_cache, ls);
 		return NULL;
@@ -598,7 +598,7 @@ nfsd4_cb_layout_fail(struct nfs4_layout_stateid *ls)
 
 	argv[0] = "/sbin/nfsd-recall-failed";
 	argv[1] = addr_str;
-	argv[2] = ls->ls_file->f_path.mnt->mnt_sb->s_id;
+	argv[2] = ls->ls_file->nf_file->f_path.mnt->mnt_sb->s_id;
 	argv[3] = NULL;
 
 	error = call_usermodehelper(argv[0], argv, envp, UMH_WAIT_PROC);
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a92faba3a847..f8394a4cd126 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -289,18 +289,18 @@ put_nfs4_file(struct nfs4_file *fi)
 	}
 }
 
-static struct file *
+static struct nfsd_file *
 __nfs4_get_fd(struct nfs4_file *f, int oflag)
 {
 	if (f->fi_fds[oflag])
-		return get_file(f->fi_fds[oflag]->nf_file);
+		return nfsd_file_get(f->fi_fds[oflag]);
 	return NULL;
 }
 
-static struct file *
+static struct nfsd_file *
 find_writeable_file_locked(struct nfs4_file *f)
 {
-	struct file *ret;
+	struct nfsd_file *ret;
 
 	lockdep_assert_held(&f->fi_lock);
 
@@ -310,10 +310,10 @@ find_writeable_file_locked(struct nfs4_file *f)
 	return ret;
 }
 
-static struct file *
+static struct nfsd_file *
 find_writeable_file(struct nfs4_file *f)
 {
-	struct file *ret;
+	struct nfsd_file *ret;
 
 	spin_lock(&f->fi_lock);
 	ret = find_writeable_file_locked(f);
@@ -322,9 +322,10 @@ find_writeable_file(struct nfs4_file *f)
 	return ret;
 }
 
-static struct file *find_readable_file_locked(struct nfs4_file *f)
+static struct nfsd_file *
+find_readable_file_locked(struct nfs4_file *f)
 {
-	struct file *ret;
+	struct nfsd_file *ret;
 
 	lockdep_assert_held(&f->fi_lock);
 
@@ -334,10 +335,10 @@ static struct file *find_readable_file_locked(struct nfs4_file *f)
 	return ret;
 }
 
-static struct file *
+static struct nfsd_file *
 find_readable_file(struct nfs4_file *f)
 {
-	struct file *ret;
+	struct nfsd_file *ret;
 
 	spin_lock(&f->fi_lock);
 	ret = find_readable_file_locked(f);
@@ -346,10 +347,10 @@ find_readable_file(struct nfs4_file *f)
 	return ret;
 }
 
-struct file *
+struct nfsd_file *
 find_any_file(struct nfs4_file *f)
 {
-	struct file *ret;
+	struct nfsd_file *ret;
 
 	spin_lock(&f->fi_lock);
 	ret = __nfs4_get_fd(f, O_RDWR);
@@ -748,16 +749,16 @@ nfs4_put_stid(struct nfs4_stid *s)
 
 static void nfs4_put_deleg_lease(struct nfs4_file *fp)
 {
-	struct file *filp = NULL;
+	struct nfsd_file *nf = NULL;
 
 	spin_lock(&fp->fi_lock);
 	if (fp->fi_deleg_file && --fp->fi_delegees == 0)
-		swap(filp, fp->fi_deleg_file);
+		swap(nf, fp->fi_deleg_file);
 	spin_unlock(&fp->fi_lock);
 
-	if (filp) {
-		vfs_setlease(filp, F_UNLCK, NULL, (void **)&fp);
-		fput(filp);
+	if (nf) {
+		vfs_setlease(nf->nf_file, F_UNLCK, NULL, (void **)&fp);
+		nfsd_file_put(nf);
 	}
 }
 
@@ -1037,11 +1038,14 @@ static void nfs4_free_lock_stateid(struct nfs4_stid *stid)
 {
 	struct nfs4_ol_stateid *stp = openlockstateid(stid);
 	struct nfs4_lockowner *lo = lockowner(stp->st_stateowner);
-	struct file *file;
+	struct nfsd_file *nf;
 
-	file = find_any_file(stp->st_stid.sc_file);
-	if (file)
-		filp_close(file, (fl_owner_t)lo);
+	nf = find_any_file(stp->st_stid.sc_file);
+	if (nf) {
+		get_file(nf->nf_file);
+		filp_close(nf->nf_file, (fl_owner_t)lo);
+		nfsd_file_put(nf);
+	}
 	nfs4_free_ol_stateid(stid);
 }
 
@@ -3927,21 +3931,21 @@ static int nfs4_setlease(struct nfs4_delegation *dp)
 {
 	struct nfs4_file *fp = dp->dl_stid.sc_file;
 	struct file_lock *fl;
-	struct file *filp;
+	struct nfsd_file *nf;
 	int status = 0;
 
 	fl = nfs4_alloc_init_lease(fp, NFS4_OPEN_DELEGATE_READ);
 	if (!fl)
 		return -ENOMEM;
-	filp = find_readable_file(fp);
-	if (!filp) {
+	nf = find_readable_file(fp);
+	if (!nf) {
 		/* We should always have a readable file here */
 		WARN_ON_ONCE(1);
 		locks_free_lock(fl);
 		return -EBADF;
 	}
-	fl->fl_file = filp;
-	status = vfs_setlease(filp, fl->fl_type, &fl, NULL);
+	fl->fl_file = nf->nf_file;
+	status = vfs_setlease(nf->nf_file, fl->fl_type, &fl, NULL);
 	if (fl)
 		locks_free_lock(fl);
 	if (status)
@@ -3959,7 +3963,7 @@ static int nfs4_setlease(struct nfs4_delegation *dp)
 		hash_delegation_locked(dp, fp);
 		goto out_unlock;
 	}
-	fp->fi_deleg_file = filp;
+	fp->fi_deleg_file = nf;
 	fp->fi_delegees = 1;
 	hash_delegation_locked(dp, fp);
 	spin_unlock(&fp->fi_lock);
@@ -3969,7 +3973,7 @@ out_unlock:
 	spin_unlock(&fp->fi_lock);
 	spin_unlock(&state_lock);
 out_fput:
-	fput(filp);
+	nfsd_file_put(nf);
 	return status;
 }
 
@@ -4575,7 +4579,7 @@ nfsd4_lookup_stateid(struct nfsd4_compound_state *cstate,
 	return nfs_ok;
 }
 
-static struct file *
+static struct nfsd_file *
 nfs4_find_file(struct nfs4_stid *s, int flags)
 {
 	if (!s)
@@ -4585,7 +4589,7 @@ nfs4_find_file(struct nfs4_stid *s, int flags)
 	case NFS4_DELEG_STID:
 		if (WARN_ON_ONCE(!s->sc_file->fi_deleg_file))
 			return NULL;
-		return get_file(s->sc_file->fi_deleg_file);
+		return nfsd_file_get(s->sc_file->fi_deleg_file);
 	case NFS4_OPEN_STID:
 	case NFS4_LOCK_STID:
 		if (flags & RD_STATE)
@@ -4614,21 +4618,17 @@ nfs4_check_file(struct svc_rqst *rqstp, struct svc_fh *fhp, struct nfs4_stid *s,
 		struct file **filpp, bool *tmp_file, int flags)
 {
 	int acc = (flags & RD_STATE) ? NFSD_MAY_READ : NFSD_MAY_WRITE;
-	struct file *file;
+	struct nfsd_file *nf;
 	__be32 status;
 
-	file = nfs4_find_file(s, flags);
-	if (file) {
+	nf = nfs4_find_file(s, flags);
+	if (nf) {
 		status = nfsd_permission(rqstp, fhp->fh_export, fhp->fh_dentry,
 				acc | NFSD_MAY_OWNER_OVERRIDE);
-		if (status) {
-			fput(file);
-			return status;
-		}
-
-		*filpp = file;
+		if (status)
+			goto out;
 	} else {
-		status = nfsd_open(rqstp, fhp, S_IFREG, acc, filpp);
+		status = nfsd_file_acquire(rqstp, fhp, acc, &nf);
 		if (status)
 			return status;
 
@@ -4636,7 +4636,10 @@ nfs4_check_file(struct svc_rqst *rqstp, struct svc_fh *fhp, struct nfs4_stid *s,
 			*tmp_file = true;
 	}
 
-	return 0;
+	*filpp = get_file(nf->nf_file);
+out:
+	nfsd_file_put(nf);
+	return status;
 }
 
 /*
@@ -5362,7 +5365,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	struct nfs4_ol_stateid *lock_stp = NULL;
 	struct nfs4_ol_stateid *open_stp = NULL;
 	struct nfs4_file *fp;
-	struct file *filp = NULL;
+	struct nfsd_file *nf = NULL;
 	struct file_lock *file_lock = NULL;
 	struct file_lock *conflock = NULL;
 	__be32 status = 0;
@@ -5444,8 +5447,8 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		case NFS4_READ_LT:
 		case NFS4_READW_LT:
 			spin_lock(&fp->fi_lock);
-			filp = find_readable_file_locked(fp);
-			if (filp)
+			nf = find_readable_file_locked(fp);
+			if (nf)
 				get_lock_access(lock_stp, NFS4_SHARE_ACCESS_READ);
 			spin_unlock(&fp->fi_lock);
 			file_lock->fl_type = F_RDLCK;
@@ -5453,8 +5456,8 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		case NFS4_WRITE_LT:
 		case NFS4_WRITEW_LT:
 			spin_lock(&fp->fi_lock);
-			filp = find_writeable_file_locked(fp);
-			if (filp)
+			nf = find_writeable_file_locked(fp);
+			if (nf)
 				get_lock_access(lock_stp, NFS4_SHARE_ACCESS_WRITE);
 			spin_unlock(&fp->fi_lock);
 			file_lock->fl_type = F_WRLCK;
@@ -5463,14 +5466,14 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 			status = nfserr_inval;
 		goto out;
 	}
-	if (!filp) {
+	if (!nf) {
 		status = nfserr_openmode;
 		goto out;
 	}
 
 	file_lock->fl_owner = (fl_owner_t)lockowner(nfs4_get_stateowner(&lock_sop->lo_owner));
 	file_lock->fl_pid = current->tgid;
-	file_lock->fl_file = filp;
+	file_lock->fl_file = nf->nf_file;
 	file_lock->fl_flags = FL_POSIX;
 	file_lock->fl_lmops = &nfsd_posix_mng_ops;
 	file_lock->fl_start = lock->lk_offset;
@@ -5484,7 +5487,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		goto out;
 	}
 
-	err = vfs_lock_file(filp, F_SETLK, file_lock, conflock);
+	err = vfs_lock_file(nf->nf_file, F_SETLK, file_lock, conflock);
 	switch (-err) {
 	case 0: /* success! */
 		update_stateid(&lock_stp->st_stid.sc_stateid);
@@ -5506,8 +5509,8 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		break;
 	}
 out:
-	if (filp)
-		fput(filp);
+	if (nf)
+		nfsd_file_put(nf);
 	if (lock_stp) {
 		/* Bump seqid manually if the 4.0 replay owner is openowner */
 		if (cstate->replay_owner &&
@@ -5632,7 +5635,7 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	    struct nfsd4_locku *locku)
 {
 	struct nfs4_ol_stateid *stp;
-	struct file *filp = NULL;
+	struct nfsd_file *nf;
 	struct file_lock *file_lock = NULL;
 	__be32 status;
 	int err;
@@ -5650,8 +5653,8 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 					&stp, nn);
 	if (status)
 		goto out;
-	filp = find_any_file(stp->st_stid.sc_file);
-	if (!filp) {
+	nf = find_any_file(stp->st_stid.sc_file);
+	if (!nf) {
 		status = nfserr_lock_range;
 		goto put_stateid;
 	}
@@ -5659,13 +5662,13 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (!file_lock) {
 		dprintk("NFSD: %s: unable to allocate lock!\n", __func__);
 		status = nfserr_jukebox;
-		goto fput;
+		goto put_file;
 	}
 
 	file_lock->fl_type = F_UNLCK;
 	file_lock->fl_owner = (fl_owner_t)lockowner(nfs4_get_stateowner(stp->st_stateowner));
 	file_lock->fl_pid = current->tgid;
-	file_lock->fl_file = filp;
+	file_lock->fl_file = nf->nf_file;
 	file_lock->fl_flags = FL_POSIX;
 	file_lock->fl_lmops = &nfsd_posix_mng_ops;
 	file_lock->fl_start = locku->lu_offset;
@@ -5674,15 +5677,15 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 						locku->lu_length);
 	nfs4_transform_lock_offset(file_lock);
 
-	err = vfs_lock_file(filp, F_SETLK, file_lock, NULL);
+	err = vfs_lock_file(nf->nf_file, F_SETLK, file_lock, NULL);
 	if (err) {
 		dprintk("NFSD: nfs4_locku: vfs_lock_file failed!\n");
 		goto out_nfserr;
 	}
 	update_stateid(&stp->st_stid.sc_stateid);
 	memcpy(&locku->lu_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
-fput:
-	fput(filp);
+put_file:
+	nfsd_file_put(nf);
 put_stateid:
 	nfs4_put_stid(&stp->st_stid);
 out:
@@ -5693,7 +5696,7 @@ out:
 
 out_nfserr:
 	status = nfserrno(err);
-	goto fput;
+	goto put_file;
 }
 
 /*
@@ -5706,17 +5709,17 @@ check_for_locks(struct nfs4_file *fp, struct nfs4_lockowner *lowner)
 {
 	struct file_lock *fl;
 	int status = false;
-	struct file *filp = find_any_file(fp);
+	struct nfsd_file *nf = find_any_file(fp);
 	struct inode *inode;
 	struct file_lock_context *flctx;
 
-	if (!filp) {
+	if (!nf) {
 		/* Any valid lock stateid should have some sort of access */
 		WARN_ON_ONCE(1);
 		return status;
 	}
 
-	inode = file_inode(filp);
+	inode = file_inode(nf->nf_file);
 	flctx = inode->i_flctx;
 
 	if (flctx && !list_empty_careful(&flctx->flc_posix)) {
@@ -5729,7 +5732,7 @@ check_for_locks(struct nfs4_file *fp, struct nfs4_lockowner *lowner)
 		}
 		spin_unlock(&flctx->flc_lock);
 	}
-	fput(filp);
+	nfsd_file_put(nf);
 	return status;
 }
 
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 70b3e51ba089..8a317de773b9 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -509,7 +509,7 @@ struct nfs4_file {
 	 */
 	atomic_t		fi_access[2];
 	u32			fi_share_deny;
-	struct file		*fi_deleg_file;
+	struct nfsd_file	*fi_deleg_file;
 	int			fi_delegees;
 	struct knfsd_fh		fi_fhandle;
 	bool			fi_had_conflict;
@@ -557,7 +557,7 @@ struct nfs4_layout_stateid {
 	spinlock_t			ls_lock;
 	struct list_head		ls_layouts;
 	u32				ls_layout_type;
-	struct file			*ls_file;
+	struct nfsd_file		*ls_file;
 	struct nfsd4_callback		ls_recall;
 	stateid_t			ls_recall_sid;
 	bool				ls_recalled;
@@ -620,7 +620,7 @@ static inline void get_nfs4_file(struct nfs4_file *fi)
 {
 	atomic_inc(&fi->fi_ref);
 }
-struct file *find_any_file(struct nfs4_file *f);
+struct nfsd_file *find_any_file(struct nfs4_file *f);
 
 /* grace period management */
 void nfsd4_end_grace(struct nfsd_net *nn);
-- 
2.4.3


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f173.google.com ([209.85.213.173]:53791 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752123AbaDRSp2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2014 14:45:28 -0400
Received: by mail-ig0-f173.google.com with SMTP id hl10so937251igb.6
        for <linux-nfs@vger.kernel.org>; Fri, 18 Apr 2014 11:45:28 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 15/70] NFSd: Add locking to the nfs4_file->fi_fds[] array
Date: Fri, 18 Apr 2014 14:44:09 -0400
Message-Id: <1397846704-14567-16-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1397846704-14567-15-git-send-email-trond.myklebust@primarydata.com>
References: <1397846704-14567-1-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-2-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-3-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-4-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-5-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-6-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-7-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-8-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-9-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-10-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-11-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-12-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-13-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-14-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-15-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 107 ++++++++++++++++++++++++++++++++++++++++++++--------
 fs/nfsd/state.h     |  26 -------------
 2 files changed, 91 insertions(+), 42 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index ad7d21e06c36..73e7da308d37 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -249,6 +249,54 @@ get_nfs4_file(struct nfs4_file *fi)
 	atomic_inc(&fi->fi_ref);
 }
 
+static struct file *__nfs4_get_fd(struct nfs4_file *f, int oflag)
+{
+	if (f->fi_fds[oflag])
+		return get_file(f->fi_fds[oflag]);
+	return NULL;
+}
+
+/* XXX: for first cut may fall back on returning file that doesn't work
+ * at all? */
+static struct file *find_writeable_file(struct nfs4_file *f)
+{
+	struct file *ret;
+
+	spin_lock(&f->fi_lock);
+	ret = __nfs4_get_fd(f, O_WRONLY);
+	if (!ret)
+		ret = __nfs4_get_fd(f, O_RDWR);
+	spin_unlock(&f->fi_lock);
+	return ret;
+}
+
+static struct file *find_readable_file(struct nfs4_file *f)
+{
+	struct file *ret;
+
+	spin_lock(&f->fi_lock);
+	ret = __nfs4_get_fd(f, O_RDONLY);
+	if (!ret)
+		ret = __nfs4_get_fd(f, O_RDWR);
+	spin_unlock(&f->fi_lock);
+	return ret;
+}
+
+static struct file *find_any_file(struct nfs4_file *f)
+{
+	struct file *ret;
+
+	spin_lock(&f->fi_lock);
+	ret = __nfs4_get_fd(f, O_RDWR);
+	if (!ret) {
+		ret = __nfs4_get_fd(f, O_WRONLY);
+		if (!ret)
+			ret = __nfs4_get_fd(f, O_RDONLY);
+	}
+	spin_unlock(&f->fi_lock);
+	return ret;
+}
+
 static int num_delegations;
 unsigned long max_delegations;
 
@@ -297,20 +345,29 @@ static void nfs4_file_get_access(struct nfs4_file *fp, int oflag)
 		__nfs4_file_get_access(fp, oflag);
 }
 
-static void nfs4_file_put_fd(struct nfs4_file *fp, int oflag)
+static struct file *nfs4_file_put_fd(struct nfs4_file *fp, int oflag)
 {
-	if (fp->fi_fds[oflag]) {
-		fput(fp->fi_fds[oflag]);
-		fp->fi_fds[oflag] = NULL;
-	}
+	struct file *filp;
+
+	filp = fp->fi_fds[oflag];
+	fp->fi_fds[oflag] = NULL;
+	return filp;
 }
 
 static void __nfs4_file_put_access(struct nfs4_file *fp, int oflag)
 {
-	if (atomic_dec_and_test(&fp->fi_access[oflag])) {
-		nfs4_file_put_fd(fp, oflag);
+	if (atomic_dec_and_lock(&fp->fi_access[oflag], &fp->fi_lock)) {
+		struct file *f1 = NULL;
+		struct file *f2 = NULL;
+
+		f1 = nfs4_file_put_fd(fp, oflag);
 		if (atomic_read(&fp->fi_access[1 - oflag]) == 0)
-			nfs4_file_put_fd(fp, O_RDWR);
+			f2 = nfs4_file_put_fd(fp, O_RDWR);
+		spin_unlock(&fp->fi_lock);
+		if (f1)
+			fput(f1);
+		if (f2)
+			fput(f2);
 	}
 }
 
@@ -651,8 +708,10 @@ static void release_lock_stateid(struct nfs4_ol_stateid *stp)
 	unhash_generic_stateid(stp);
 	unhash_stid(&stp->st_stid);
 	file = find_any_file(stp->st_file);
-	if (file)
+	if (file) {
 		locks_remove_posix(file, (fl_owner_t)lockowner(stp->st_stateowner));
+		fput(file);
+	}
 	close_generic_stateid(stp);
 	free_generic_stateid(stp);
 }
@@ -2985,17 +3044,27 @@ static inline int nfs4_access_to_access(u32 nfs4_access)
 static __be32 nfs4_get_vfs_file(struct svc_rqst *rqstp, struct nfs4_file *fp,
 		struct svc_fh *cur_fh, struct nfsd4_open *open)
 {
+	struct file *filp = NULL;
 	__be32 status;
 	int oflag = nfs4_access_to_omode(open->op_share_access);
 	int access = nfs4_access_to_access(open->op_share_access);
 
+	spin_lock(&fp->fi_lock);
 	if (!fp->fi_fds[oflag]) {
-		status = nfsd_open(rqstp, cur_fh, S_IFREG, access,
-			&fp->fi_fds[oflag]);
+		spin_unlock(&fp->fi_lock);
+		status = nfsd_open(rqstp, cur_fh, S_IFREG, access, &filp);
 		if (status)
 			return status;
+		spin_lock(&fp->fi_lock);
+		if (!fp->fi_fds[oflag]) {
+			fp->fi_fds[oflag] = filp;
+			filp = NULL;
+		}
 	}
 	nfs4_file_get_access(fp, oflag);
+	spin_unlock(&fp->fi_lock);
+	if (filp)
+		fput(filp);
 
 	return nfs_ok;
 }
@@ -3094,13 +3163,15 @@ static int nfs4_setlease(struct nfs4_delegation *dp)
 	if (status)
 		goto out_free;
 	fp->fi_lease = fl;
-	fp->fi_deleg_file = get_file(fl->fl_file);
+	fp->fi_deleg_file = fl->fl_file;
 	atomic_set(&fp->fi_delegees, 1);
 	spin_lock(&state_lock);
 	hash_delegation_locked(dp, fp);
 	spin_unlock(&state_lock);
 	return 0;
 out_free:
+	if (fl->fl_file)
+		fput(fl->fl_file);
 	locks_free_lock(fl);
 	return status;
 }
@@ -3734,6 +3805,7 @@ nfs4_preprocess_stateid_op(struct net *net, struct nfsd4_compound_state *cstate,
 				status = nfserr_serverfault;
 				goto out;
 			}
+			get_file(file);
 		}
 		break;
 	case NFS4_OPEN_STID:
@@ -3761,7 +3833,7 @@ nfs4_preprocess_stateid_op(struct net *net, struct nfsd4_compound_state *cstate,
 	}
 	status = nfs_ok;
 	if (file)
-		*filpp = get_file(file);
+		*filpp = file;
 out:
 	nfs4_unlock_state();
 	return status;
@@ -4489,6 +4561,8 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		break;
 	}
 out:
+	if (filp)
+		fput(filp);
 	if (status && new_state)
 		release_lockowner(lock_sop);
 	nfsd4_bump_seqid(cstate, status);
@@ -4630,7 +4704,7 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (!file_lock) {
 		dprintk("NFSD: %s: unable to allocate lock!\n", __func__);
 		status = nfserr_jukebox;
-		goto out;
+		goto fput;
 	}
 	locks_init_lock(file_lock);
 	file_lock->fl_type = F_UNLCK;
@@ -4652,7 +4726,8 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	}
 	update_stateid(&stp->st_stid.sc_stateid);
 	memcpy(&locku->lu_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
-
+fput:
+	fput(filp);
 out:
 	nfsd4_bump_seqid(cstate, status);
 	nfs4_unlock_state();
@@ -4662,7 +4737,7 @@ out:
 
 out_nfserr:
 	status = nfserrno(err);
-	goto out;
+	goto fput;
 }
 
 /*
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 80789aa5b5b4..004733885cca 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -405,32 +405,6 @@ struct nfs4_file {
 	bool			fi_had_conflict;
 };
 
-/* XXX: for first cut may fall back on returning file that doesn't work
- * at all? */
-static inline struct file *find_writeable_file(struct nfs4_file *f)
-{
-	if (f->fi_fds[O_WRONLY])
-		return f->fi_fds[O_WRONLY];
-	return f->fi_fds[O_RDWR];
-}
-
-static inline struct file *find_readable_file(struct nfs4_file *f)
-{
-	if (f->fi_fds[O_RDONLY])
-		return f->fi_fds[O_RDONLY];
-	return f->fi_fds[O_RDWR];
-}
-
-static inline struct file *find_any_file(struct nfs4_file *f)
-{
-	if (f->fi_fds[O_RDWR])
-		return f->fi_fds[O_RDWR];
-	else if (f->fi_fds[O_WRONLY])
-		return f->fi_fds[O_WRONLY];
-	else
-		return f->fi_fds[O_RDONLY];
-}
-
 /* "ol" stands for "Open or Lock".  Better suggestions welcome. */
 struct nfs4_ol_stateid {
 	struct nfs4_stid    st_stid; /* must be first field */
-- 
1.9.0


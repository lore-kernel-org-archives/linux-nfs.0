Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f48.google.com ([209.85.216.48]:39529 "EHLO
	mail-qa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754652AbaF3PvP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 11:51:15 -0400
Received: by mail-qa0-f48.google.com with SMTP id x12so6646385qac.35
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 08:51:14 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 030/114] nfsd: make deny mode enforcement more efficient and close races in it
Date: Mon, 30 Jun 2014 11:48:59 -0400
Message-Id: <1404143423-24381-31-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The current enforcement of deny modes is both inefficient and scattered
across several places, which makes it hard to guarantee atomicity. The
inefficiency is a problem now, and the lack of atomicity will mean races
once the client_mutex is removed.

First, we address the inefficiency. We have to track deny modes on a
per-stateid basis to ensure that open downgrades are sane, but when the
server goes to enforce them it has to walk the entire list of stateids
and check against each one.

Instead of doing that, maintain a per-nfs4_file deny mode. When a file
is opened, we simply set any deny bits in that mode that were specified
in the OPEN call. We can then use that unified deny mode to do a simple
check to see whether there are any conflicts without needing to walk the
entire stateid list.

The only time we'll need to walk the entire list of stateids is when a
stateid that has a deny mode on it is being released, or one is having
its deny mode downgraded. In that case, we must walk the entire list and
recalculate the fi_share_deny field. Since deny modes are pretty rare
today, this should be very rare under normal workloads.

To address the potential for races once the client_mutex is removed,
protect fi_share_deny with the fi_lock. In nfs4_get_vfs_file, check to
make sure that any deny mode we want to apply won't conflict with
existing access. If that's ok, then have nfs4_file_get_access check that
new access to the file won't conflict with existing deny modes.

If that also passes, then get file access references, set the correct
access and deny bits in the stateid, and update the fi_share_deny field.
If opening the file or truncating it fails, then unwind the whole mess
and return the appropriate error.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 216 +++++++++++++++++++++++++++++++++++-----------------
 fs/nfsd/state.h     |   1 +
 2 files changed, 148 insertions(+), 69 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d0e465cb0781..7eea841aa825 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -359,26 +359,53 @@ static unsigned int file_hashval(struct inode *ino)
 
 static struct hlist_head file_hashtbl[FILE_HASH_SIZE];
 
-static void __nfs4_file_get_access(struct nfs4_file *fp, int oflag)
+static void
+__nfs4_file_get_access(struct nfs4_file *fp, u32 access)
 {
-	WARN_ON_ONCE(!(fp->fi_fds[oflag] || fp->fi_fds[O_RDWR]));
-	atomic_inc(&fp->fi_access[oflag]);
+	int oflag = nfs4_access_to_omode(access);
+
+	if (oflag == O_RDWR) {
+		atomic_inc(&fp->fi_access[O_RDONLY]);
+		atomic_inc(&fp->fi_access[O_WRONLY]);
+	} else
+		atomic_inc(&fp->fi_access[oflag]);
 }
 
-static void nfs4_file_get_access(struct nfs4_file *fp, u32 access)
+static __be32
+nfs4_file_get_access(struct nfs4_file *fp, u32 access)
 {
-	int oflag = nfs4_access_to_omode(access);
+	lockdep_assert_held(&fp->fi_lock);
 
 	/* Note: relies on NFS4_SHARE_ACCESS_BOTH == READ|WRITE */
-	access &= (NFS4_SHARE_ACCESS_READ|NFS4_SHARE_ACCESS_WRITE);
+	access &= NFS4_SHARE_ACCESS_BOTH;
+
+	/* Does this access mask make sense? */
 	if (access == 0)
-		return;
+		return nfserr_inval;
 
-	if (oflag == O_RDWR) {
-		__nfs4_file_get_access(fp, O_RDONLY);
-		__nfs4_file_get_access(fp, O_WRONLY);
-	} else
-		__nfs4_file_get_access(fp, oflag);
+	/* Does it conflict with a deny mode already set? */
+	if ((access & fp->fi_share_deny) != 0)
+		return nfserr_share_denied;
+
+	__nfs4_file_get_access(fp, access);
+	return nfs_ok;
+}
+
+static __be32 nfs4_file_check_deny(struct nfs4_file *fp, u32 deny)
+{
+	/* Common case is that there is no deny mode. */
+	deny &= NFS4_SHARE_DENY_BOTH;
+	if (deny) {
+		/* Note: relies on NFS4_SHARE_DENY_BOTH == READ|WRITE */
+		if ((deny & NFS4_SHARE_DENY_READ) &&
+		    atomic_read(&fp->fi_access[O_RDONLY]))
+			return nfserr_share_denied;
+
+		if ((deny & NFS4_SHARE_DENY_WRITE) &&
+		    atomic_read(&fp->fi_access[O_WRONLY]))
+			return nfserr_share_denied;
+	}
+	return nfs_ok;
 }
 
 static void __nfs4_file_put_access(struct nfs4_file *fp, int oflag)
@@ -707,17 +734,6 @@ bmap_to_share_mode(unsigned long bmap) {
 	return access;
 }
 
-static bool
-test_share(struct nfs4_ol_stateid *stp, struct nfsd4_open *open) {
-	unsigned int access, deny;
-
-	access = bmap_to_share_mode(stp->st_access_bmap);
-	deny = bmap_to_share_mode(stp->st_deny_bmap);
-	if ((access & open->op_share_deny) || (deny & open->op_share_access))
-		return false;
-	return true;
-}
-
 /* set share access for a given stateid */
 static inline void
 set_access(u32 access, struct nfs4_ol_stateid *stp)
@@ -764,11 +780,49 @@ test_deny(u32 deny, struct nfs4_ol_stateid *stp)
 	return test_bit(deny, (unsigned long *)&stp->st_deny_bmap);
 }
 
+/*
+ * A stateid that had a deny mode associated with it is being released
+ * or downgraded. Recalculate the deny mode on the file.
+ */
+static void
+recalculate_deny_mode(struct nfs4_file *fp)
+{
+	struct nfs4_ol_stateid *stp;
+
+	spin_lock(&fp->fi_lock);
+	fp->fi_share_deny = 0;
+	list_for_each_entry(stp, &fp->fi_stateids, st_perfile)
+		fp->fi_share_deny |= bmap_to_share_mode(stp->st_deny_bmap);
+	spin_unlock(&fp->fi_lock);
+}
+
+static void
+reset_union_bmap_deny(u32 deny, struct nfs4_ol_stateid *stp)
+{
+	int i;
+	bool change = false;
+
+	for (i = 1; i < 4; i++) {
+		if ((i & deny) != i) {
+			change = true;
+			clear_deny(i, stp);
+		}
+	}
+
+	/* Recalculate per-file deny mode if there was a change */
+	if (change)
+		recalculate_deny_mode(stp->st_file);
+}
+
 /* release all access and file references for a given stateid */
 static void
 release_all_access(struct nfs4_ol_stateid *stp)
 {
 	int i;
+	struct nfs4_file *fp = stp->st_file;
+
+	if (fp && stp->st_deny_bmap != 0)
+		recalculate_deny_mode(fp);
 
 	for (i = 1; i < 4; i++) {
 		if (test_access(i, stp))
@@ -2759,6 +2813,7 @@ static void nfsd4_init_file(struct nfs4_file *fp, struct inode *ino)
 	fp->fi_inode = ino;
 	fp->fi_had_conflict = false;
 	fp->fi_lease = NULL;
+	fp->fi_share_deny = 0;
 	memset(fp->fi_fds, 0, sizeof(fp->fi_fds));
 	memset(fp->fi_access, 0, sizeof(fp->fi_access));
 	hlist_add_head(&fp->fi_hash, &file_hashtbl[hashval]);
@@ -2987,22 +3042,15 @@ nfs4_share_conflict(struct svc_fh *current_fh, unsigned int deny_type)
 {
 	struct inode *ino = current_fh->fh_dentry->d_inode;
 	struct nfs4_file *fp;
-	struct nfs4_ol_stateid *stp;
-	__be32 ret;
+	__be32 ret = nfs_ok;
 
 	fp = find_file(ino);
 	if (!fp)
-		return nfs_ok;
-	ret = nfserr_locked;
-	/* Search for conflicting share reservations */
+		return ret;
+	/* Check for conflicting share reservations */
 	spin_lock(&fp->fi_lock);
-	list_for_each_entry(stp, &fp->fi_stateids, st_perfile) {
-		if (test_deny(deny_type, stp) ||
-		    test_deny(NFS4_SHARE_DENY_BOTH, stp))
-			goto out;
-	}
-	ret = nfs_ok;
-out:
+	if (fp->fi_share_deny & deny_type)
+		ret = nfserr_locked;
 	spin_unlock(&fp->fi_lock);
 	put_nfs4_file(fp);
 	return ret;
@@ -3241,12 +3289,9 @@ nfs4_check_open(struct nfs4_file *fp, struct nfsd4_open *open, struct nfs4_ol_st
 		if (local->st_stateowner->so_is_open_owner == 0)
 			continue;
 		/* remember if we have seen this open owner */
-		if (local->st_stateowner == &oo->oo_owner)
+		if (local->st_stateowner == &oo->oo_owner) {
 			*stpp = local;
-		/* check for conflicting share reservations */
-		if (!test_share(local, open)) {
-			spin_unlock(&fp->fi_lock);
-			return nfserr_share_denied;
+			break;
 		}
 	}
 	spin_unlock(&fp->fi_lock);
@@ -3287,20 +3332,47 @@ static __be32 nfs4_get_vfs_file(struct svc_rqst *rqstp, struct nfs4_file *fp,
 	__be32 status;
 	int oflag = nfs4_access_to_omode(open->op_share_access);
 	int access = nfs4_access_to_access(open->op_share_access);
+	unsigned char old_access_bmap, old_deny_bmap;
 
 	spin_lock(&fp->fi_lock);
+
+	/*
+	 * Are we trying to set a deny mode that would conflict with
+	 * current access?
+	 */
+	status = nfs4_file_check_deny(fp, open->op_share_deny);
+	if (status != nfs_ok) {
+		spin_unlock(&fp->fi_lock);
+		goto out;
+	}
+
+	/* set access to the file */
+	status = nfs4_file_get_access(fp, open->op_share_access);
+	if (status != nfs_ok) {
+		spin_unlock(&fp->fi_lock);
+		goto out;
+	}
+
+	/* Set access bits in stateid */
+	old_access_bmap = stp->st_access_bmap;
+	set_access(open->op_share_access, stp);
+
+	/* Set new deny mask */
+	old_deny_bmap = stp->st_deny_bmap;
+	set_deny(open->op_share_deny, stp);
+	fp->fi_share_deny |= (open->op_share_deny & NFS4_SHARE_DENY_BOTH);
+
 	if (!fp->fi_fds[oflag]) {
 		spin_unlock(&fp->fi_lock);
 		status = nfsd_open(rqstp, cur_fh, S_IFREG, access, &filp);
 		if (status)
-			goto out;
+			goto out_put_access;
 		spin_lock(&fp->fi_lock);
 		if (!fp->fi_fds[oflag]) {
 			fp->fi_fds[oflag] = filp;
 			filp = NULL;
 		}
 	}
-	nfs4_file_get_access(fp, open->op_share_access);
 	spin_unlock(&fp->fi_lock);
 	if (filp)
 		fput(filp);
@@ -3308,33 +3380,43 @@ static __be32 nfs4_get_vfs_file(struct svc_rqst *rqstp, struct nfs4_file *fp,
 	status = nfsd4_truncate(rqstp, cur_fh, open);
 	if (status)
 		goto out_put_access;
-
-	/* Set access and deny bits in stateid */
-	set_access(open->op_share_access, stp);
-	set_deny(open->op_share_deny, stp);
-	return nfs_ok;
-
-out_put_access:
-	nfs4_file_put_access(fp, open->op_share_access);
 out:
 	return status;
+out_put_access:
+	stp->st_access_bmap = old_access_bmap;
+	nfs4_file_put_access(fp, open->op_share_access);
+	reset_union_bmap_deny(bmap_to_share_mode(old_deny_bmap), stp);
+	goto out;
 }
 
 static __be32
 nfs4_upgrade_open(struct svc_rqst *rqstp, struct nfs4_file *fp, struct svc_fh *cur_fh, struct nfs4_ol_stateid *stp, struct nfsd4_open *open)
 {
 	__be32 status;
+	unsigned char old_deny_bmap;
 
 	if (!test_access(open->op_share_access, stp))
-		status = nfs4_get_vfs_file(rqstp, fp, cur_fh, stp, open);
-	else
-		status = nfsd4_truncate(rqstp, cur_fh, open);
+		return nfs4_get_vfs_file(rqstp, fp, cur_fh, stp, open);
 
-	if (status)
+	/* test and set deny mode */
+	spin_lock(&fp->fi_lock);
+	status = nfs4_file_check_deny(fp, open->op_share_deny);
+	if (status == nfs_ok) {
+		old_deny_bmap = stp->st_deny_bmap;
+		set_deny(open->op_share_deny, stp);
+		fp->fi_share_deny |=
+				(open->op_share_deny & NFS4_SHARE_DENY_BOTH);
+	}
+	spin_unlock(&fp->fi_lock);
+
+	if (status != nfs_ok)
 		return status;
-	return nfs_ok;
-}
 
+	status = nfsd4_truncate(rqstp, cur_fh, open);
+	if (status != nfs_ok)
+		reset_union_bmap_deny(old_deny_bmap, stp);
+	return status;
+}
 
 static void
 nfs4_set_claim_prev(struct nfsd4_open *open, bool has_session)
@@ -3556,7 +3638,8 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 	 */
 	fp = find_or_add_file(ino, open->op_file);
 	if (fp != open->op_file) {
-		if ((status = nfs4_check_open(fp, open, &stp)))
+		status = nfs4_check_open(fp, open, &stp);
+		if (status)
 			goto out;
 		status = nfs4_check_deleg(cl, open, &dp);
 		if (status)
@@ -4241,17 +4324,6 @@ static inline void nfs4_stateid_downgrade(struct nfs4_ol_stateid *stp, u32 to_ac
 	}
 }
 
-static void
-reset_union_bmap_deny(u32 deny, struct nfs4_ol_stateid *stp)
-{
-	int i;
-
-	for (i = 1; i < 4; i++) {
-		if ((i & deny) != i)
-			clear_deny(i, stp);
-	}
-}
-
 __be32
 nfsd4_open_downgrade(struct svc_rqst *rqstp,
 		     struct nfsd4_compound_state *cstate,
@@ -4546,9 +4618,15 @@ static void get_lock_access(struct nfs4_ol_stateid *lock_stp, u32 access)
 {
 	struct nfs4_file *fp = lock_stp->st_file;
 
+	/*
+	 * Lock stateids inherit the same access as the open stateid from which
+	 * they are descended. We don't need to worry about holding the
+	 * fp->fi_lock here since there is no danger of the access refcounts
+	 * going to zero.
+	 */
 	if (test_access(access, lock_stp))
 		return;
-	nfs4_file_get_access(fp, access);
+	__nfs4_file_get_access(fp, access);
 	set_access(access, lock_stp);
 }
 
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 949b331d9e13..e1f6b8847670 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -392,6 +392,7 @@ struct nfs4_file {
 	 *   + 1 to both of the above if NFS4_SHARE_ACCESS_BOTH is set.
 	 */
 	atomic_t		fi_access[2];
+	u32			fi_share_deny;
 	struct file		*fi_deleg_file;
 	struct file_lock	*fi_lease;
 	atomic_t		fi_delegees;
-- 
1.9.3


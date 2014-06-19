Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f51.google.com ([209.85.216.51]:60692 "EHLO
	mail-qa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757913AbaFSOvN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:51:13 -0400
Received: by mail-qa0-f51.google.com with SMTP id j7so2015047qaq.38
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:51:12 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 010/104] NFSd: Protect the nfs4_file delegation fields using the fi_lock
Date: Thu, 19 Jun 2014 10:49:16 -0400
Message-Id: <1403189450-18729-11-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The current code in nfs4_setlease calls vfs_setlease and uses the
client_mutex to ensure that it doesn't disappear before we can hash the
delegation. With the client_mutex gone, we'll have a potential race
condition.

It's possible that the delegation could be recalled after we acquire the
lease but before we ever get around to setting it up. If that happens,
then we'd have a nfs4_file that *thinks* it has a delegation, when it
actually has none.

Attempt to acquire a delegation. If that succeeds, take the state_lock
and recheck to make sure the lease is still there. If it is, then take
the fi_lock and set up the rest of the delegation fields.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 51 ++++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 38 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 17870de5989d..cf940210cc58 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -524,6 +524,8 @@ nfs4_put_delegation(struct nfs4_delegation *dp)
 
 static void nfs4_put_deleg_lease(struct nfs4_file *fp)
 {
+	lockdep_assert_held(&state_lock);
+
 	if (!fp->fi_lease)
 		return;
 	if (atomic_dec_and_test(&fp->fi_delegees)) {
@@ -543,11 +545,10 @@ static void
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
 
@@ -558,17 +559,17 @@ unhash_delegation(struct nfs4_delegation *dp)
 	struct nfs4_file *fp = dp->dl_file;
 
 	spin_lock(&state_lock);
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
+	put_nfs4_file(fp);
 }
 
 
@@ -3245,7 +3246,7 @@ static int nfs4_setlease(struct nfs4_delegation *dp)
 {
 	struct nfs4_file *fp = dp->dl_file;
 	struct file_lock *fl;
-	int status;
+	int status = 0;
 
 	fl = nfs4_alloc_init_lease(dp, NFS4_OPEN_DELEGATE_READ);
 	if (!fl)
@@ -3253,15 +3254,31 @@ static int nfs4_setlease(struct nfs4_delegation *dp)
 	fl->fl_file = find_readable_file(fp);
 	status = vfs_setlease(fl->fl_file, fl->fl_type, &fl);
 	if (status)
-		goto out_free;
+		goto out_fput;
+	spin_lock(&state_lock);
+	/* Did the lease get broken before we took the lock? */
+	status = -EAGAIN;
+	if (!file_has_lease(fl->fl_file))
+		goto out_unlock;
+	spin_lock(&fp->fi_lock);
+	/* Race breaker */
+	if (fp->fi_lease) {
+		status = 0;
+		atomic_inc(&fp->fi_delegees);
+		hash_delegation_locked(dp, fp);
+		spin_unlock(&fp->fi_lock);
+		goto out_unlock;
+	}
 	fp->fi_lease = fl;
 	fp->fi_deleg_file = fl->fl_file;
 	atomic_set(&fp->fi_delegees, 1);
-	spin_lock(&state_lock);
 	hash_delegation_locked(dp, fp);
+	spin_unlock(&fp->fi_lock);
 	spin_unlock(&state_lock);
 	return 0;
-out_free:
+out_unlock:
+	spin_unlock(&state_lock);
+out_fput:
 	if (fl->fl_file)
 		fput(fl->fl_file);
 	locks_free_lock(fl);
@@ -3270,19 +3287,27 @@ out_free:
 
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
 	return 0;
 }
-- 
1.9.3


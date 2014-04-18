Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f173.google.com ([209.85.223.173]:35590 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754022AbaDRSpa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2014 14:45:30 -0400
Received: by mail-ie0-f173.google.com with SMTP id rl12so1910243iec.18
        for <linux-nfs@vger.kernel.org>; Fri, 18 Apr 2014 11:45:30 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 16/70] NFSd: Protect the nfs4_file delegation fields using the fi_lock
Date: Fri, 18 Apr 2014 14:44:10 -0400
Message-Id: <1397846704-14567-17-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1397846704-14567-16-git-send-email-trond.myklebust@primarydata.com>
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
 <1397846704-14567-16-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 33 ++++++++++++++++++++++++++-------
 1 file changed, 26 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 73e7da308d37..5105dbc76888 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -479,6 +479,7 @@ nfs4_put_delegation(struct nfs4_delegation *dp)
 	}
 }
 
+/* Call under fp->fi_lock */
 static void nfs4_put_deleg_lease(struct nfs4_file *fp)
 {
 	if (atomic_dec_and_test(&fp->fi_delegees)) {
@@ -511,6 +512,7 @@ unhash_delegation(struct nfs4_delegation *dp)
 	struct nfs4_file *fp = dp->dl_file;
 
 	spin_lock(&state_lock);
+	spin_lock(&fp->fi_lock);
 	list_del_init(&dp->dl_perclnt);
 	list_del_init(&dp->dl_recall_lru);
 	if (!list_empty(&dp->dl_perfile)) {
@@ -518,10 +520,11 @@ unhash_delegation(struct nfs4_delegation *dp)
 		list_del_init(&dp->dl_perfile);
 		spin_unlock(&fp->fi_inode->i_lock);
 	}
-	spin_unlock(&state_lock);
 	nfs4_put_deleg_lease(fp);
-	put_nfs4_file(fp);
 	dp->dl_file = NULL;
+	spin_unlock(&fp->fi_lock);
+	spin_unlock(&state_lock);
+	put_nfs4_file(fp);
 }
 
 
@@ -3153,23 +3156,33 @@ static int nfs4_setlease(struct nfs4_delegation *dp)
 {
 	struct nfs4_file *fp = dp->dl_file;
 	struct file_lock *fl;
-	int status;
+	int status = 0;
 
 	fl = nfs4_alloc_init_lease(dp, NFS4_OPEN_DELEGATE_READ);
 	if (!fl)
 		return -ENOMEM;
 	fl->fl_file = find_readable_file(fp);
+	spin_lock(&state_lock);
+	spin_lock(&fp->fi_lock);
+	/* Race breaker */
+	if (fp->fi_lease) {
+		atomic_inc(&fp->fi_delegees);
+		hash_delegation_locked(dp, fp);
+		goto out_free;
+	}
 	status = vfs_setlease(fl->fl_file, fl->fl_type, &fl);
 	if (status)
 		goto out_free;
 	fp->fi_lease = fl;
 	fp->fi_deleg_file = fl->fl_file;
 	atomic_set(&fp->fi_delegees, 1);
-	spin_lock(&state_lock);
 	hash_delegation_locked(dp, fp);
+	spin_unlock(&fp->fi_lock);
 	spin_unlock(&state_lock);
 	return 0;
 out_free:
+	spin_unlock(&fp->fi_lock);
+	spin_unlock(&state_lock);
 	if (fl->fl_file)
 		fput(fl->fl_file);
 	locks_free_lock(fl);
@@ -3183,23 +3196,29 @@ static int nfs4_set_delegation(struct nfs4_delegation *dp, struct nfs4_file *fp)
 	if (fp->fi_had_conflict)
 		return -EAGAIN;
 	get_nfs4_file(fp);
+	spin_lock(&state_lock);
+	spin_lock(&fp->fi_lock);
 	dp->dl_file = fp;
 	if (!fp->fi_lease) {
+		spin_unlock(&fp->fi_lock);
+		spin_unlock(&state_lock);
 		status = nfs4_setlease(dp);
 		if (status)
 			goto out_free;
 		return 0;
 	}
-	spin_lock(&state_lock);
 	if (fp->fi_had_conflict) {
-		spin_unlock(&state_lock);
 		status = -EAGAIN;
-		goto out_free;
+		goto unlock_and_free;
 	}
 	atomic_inc(&fp->fi_delegees);
 	hash_delegation_locked(dp, fp);
+	spin_unlock(&fp->fi_lock);
 	spin_unlock(&state_lock);
 	return 0;
+unlock_and_free:
+	spin_unlock(&fp->fi_lock);
+	spin_unlock(&state_lock);
 out_free:
 	put_nfs4_file(fp);
 	dp->dl_file = fp;
-- 
1.9.0


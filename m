Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f50.google.com ([209.85.192.50]:43383 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751650AbaHIOWx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 9 Aug 2014 10:22:53 -0400
Received: by mail-qg0-f50.google.com with SMTP id q108so7266304qgd.9
        for <linux-nfs@vger.kernel.org>; Sat, 09 Aug 2014 07:22:53 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/3] nfsd: protect lease-related nfs4_file fields with fi_lock
Date: Sat,  9 Aug 2014 10:22:40 -0400
Message-Id: <1407594162-28342-2-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1407594162-28342-1-git-send-email-jlayton@primarydata.com>
References: <1407594162-28342-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently these fields are protected with the state_lock, but that
doesn't really make a lot of sense. These fields are "private" to the
nfs4_file, and can be protected with the more granular fi_lock.

The fi_lock is already held when setting these fields. Make the code
hold the fp->fi_lock when clearing the lease-related fields in the
nfs4_file, and no longer require that the state_lock be held when
calling into this function.

To prevent lock inversion with the i_lock, we also move the vfs_setlease
and fput calls outside of the fi_lock. This also sets us up for allowing
vfs_setlease calls to block in the future.

Finally, remove a redundant NULL pointer check. unhash_delegation_locked
locks the fp->fi_lock prior to that check, so fp in that function must
never be NULL.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 22 +++++++++++++---------
 1 file changed, 13 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2e80a59e7e91..309ec3b1090a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -673,15 +673,20 @@ nfs4_put_stid(struct nfs4_stid *s)
 
 static void nfs4_put_deleg_lease(struct nfs4_file *fp)
 {
-	lockdep_assert_held(&state_lock);
+	struct file *filp = NULL;
+	struct file_lock *fl;
 
-	if (!fp->fi_lease)
-		return;
-	if (atomic_dec_and_test(&fp->fi_delegees)) {
-		vfs_setlease(fp->fi_deleg_file, F_UNLCK, &fp->fi_lease);
+	spin_lock(&fp->fi_lock);
+	if (fp->fi_lease && atomic_dec_and_test(&fp->fi_delegees)) {
+		swap(filp, fp->fi_deleg_file);
+		fl = fp->fi_lease;
 		fp->fi_lease = NULL;
-		fput(fp->fi_deleg_file);
-		fp->fi_deleg_file = NULL;
+	}
+	spin_unlock(&fp->fi_lock);
+
+	if (filp) {
+		vfs_setlease(filp, F_UNLCK, &fl);
+		fput(filp);
 	}
 }
 
@@ -717,8 +722,7 @@ unhash_delegation_locked(struct nfs4_delegation *dp)
 	list_del_init(&dp->dl_recall_lru);
 	list_del_init(&dp->dl_perfile);
 	spin_unlock(&fp->fi_lock);
-	if (fp)
-		nfs4_put_deleg_lease(fp);
+	nfs4_put_deleg_lease(fp);
 }
 
 static void destroy_delegation(struct nfs4_delegation *dp)
-- 
1.9.3


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f41.google.com ([209.85.216.41]:62911 "EHLO
	mail-qa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754474AbaGHSE5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jul 2014 14:04:57 -0400
Received: by mail-qa0-f41.google.com with SMTP id cm18so5341654qab.28
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jul 2014 11:04:57 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 016/100] nfsd: always hold the fi_lock when bumping fi_access refcounts
Date: Tue,  8 Jul 2014 14:03:04 -0400
Message-Id: <1404842668-22521-17-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Once we remove the client_mutex, there's an unlikely but possible race
that could occur. It will be possible for nfs4_file_put_access to race
with nfs4_file_get_access. The refcount will go to zero (briefly) and
then bumped back to one. If that happens we set ourselves up for a
use-after-free and the potential for a lock to race onto the i_flock
list as a filp is being torn down.

Ensure that we can safely bump the refcount on the file by holding the
fi_lock whenever that's done. The only place it currently isn't is in
get_lock_access.

In order to ensure atomicity with finding the file, add some
find_*_file_locked calls that can be called while already holding the
fi_lock and then call get_lock_access to get new access references on
the nfs4_file.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 47 +++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 41 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 67d1cb75a667..bd24337a8763 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -277,27 +277,52 @@ static struct file *__nfs4_get_fd(struct nfs4_file *f, int oflag)
 	return NULL;
 }
 
-static struct file *find_writeable_file(struct nfs4_file *f)
+static struct file *
+find_writeable_file_locked(struct nfs4_file *f)
 {
 	struct file *ret;
 
-	spin_lock(&f->fi_lock);
+	lockdep_assert_held(&f->fi_lock);
+
 	ret = __nfs4_get_fd(f, O_WRONLY);
 	if (!ret)
 		ret = __nfs4_get_fd(f, O_RDWR);
-	spin_unlock(&f->fi_lock);
 	return ret;
 }
 
-static struct file *find_readable_file(struct nfs4_file *f)
+static struct file *
+find_writeable_file(struct nfs4_file *f)
 {
 	struct file *ret;
 
 	spin_lock(&f->fi_lock);
+	ret = find_writeable_file_locked(f);
+	spin_unlock(&f->fi_lock);
+
+	return ret;
+}
+
+static struct file *find_readable_file_locked(struct nfs4_file *f)
+{
+	struct file *ret;
+
+	lockdep_assert_held(&f->fi_lock);
+
 	ret = __nfs4_get_fd(f, O_RDONLY);
 	if (!ret)
 		ret = __nfs4_get_fd(f, O_RDWR);
+	return ret;
+}
+
+static struct file *
+find_readable_file(struct nfs4_file *f)
+{
+	struct file *ret;
+
+	spin_lock(&f->fi_lock);
+	ret = find_readable_file_locked(f);
 	spin_unlock(&f->fi_lock);
+
 	return ret;
 }
 
@@ -373,6 +398,8 @@ static void nfs4_file_get_access(struct nfs4_file *fp, u32 access)
 {
 	int oflag = nfs4_access_to_omode(access);
 
+	lockdep_assert_held(&fp->fi_lock);
+
 	/* Note: relies on NFS4_SHARE_ACCESS_BOTH == READ|WRITE */
 	access &= NFS4_SHARE_ACCESS_BOTH;
 	if (access == 0)
@@ -4572,6 +4599,8 @@ static void get_lock_access(struct nfs4_ol_stateid *lock_stp, u32 access)
 {
 	struct nfs4_file *fp = lock_stp->st_file;
 
+	lockdep_assert_held(&fp->fi_lock);
+
 	if (test_access(access, lock_stp))
 		return;
 	nfs4_file_get_access(fp, access);
@@ -4623,6 +4652,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	struct nfs4_openowner *open_sop = NULL;
 	struct nfs4_lockowner *lock_sop = NULL;
 	struct nfs4_ol_stateid *lock_stp;
+	struct nfs4_file *fp;
 	struct file *filp = NULL;
 	struct file_lock *file_lock = NULL;
 	struct file_lock *conflock = NULL;
@@ -4703,20 +4733,25 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		goto out;
 	}
 
+	fp = lock_stp->st_file;
 	locks_init_lock(file_lock);
 	switch (lock->lk_type) {
 		case NFS4_READ_LT:
 		case NFS4_READW_LT:
-			filp = find_readable_file(lock_stp->st_file);
+			spin_lock(&fp->fi_lock);
+			filp = find_readable_file_locked(fp);
 			if (filp)
 				get_lock_access(lock_stp, NFS4_SHARE_ACCESS_READ);
+			spin_unlock(&fp->fi_lock);
 			file_lock->fl_type = F_RDLCK;
 			break;
 		case NFS4_WRITE_LT:
 		case NFS4_WRITEW_LT:
-			filp = find_writeable_file(lock_stp->st_file);
+			spin_lock(&fp->fi_lock);
+			filp = find_writeable_file_locked(fp);
 			if (filp)
 				get_lock_access(lock_stp, NFS4_SHARE_ACCESS_WRITE);
+			spin_unlock(&fp->fi_lock);
 			file_lock->fl_type = F_WRLCK;
 			break;
 		default:
-- 
1.9.3


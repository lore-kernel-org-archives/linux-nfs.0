Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f42.google.com ([209.85.192.42]:60381 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751516AbaGJSH5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 14:07:57 -0400
Received: by mail-qg0-f42.google.com with SMTP id e89so8012629qgf.15
        for <linux-nfs@vger.kernel.org>; Thu, 10 Jul 2014 11:07:57 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: hch@infradead.org, linux-nfs@vger.kernel.org
Subject: [PATCH 09/11] nfsd: always hold the fi_lock when bumping fi_access refcounts
Date: Thu, 10 Jul 2014 14:07:33 -0400
Message-Id: <1405015655-12469-10-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1405015655-12469-1-git-send-email-jlayton@primarydata.com>
References: <1405015655-12469-1-git-send-email-jlayton@primarydata.com>
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

In order to ensure atomicity with finding the file, use the
find_*_file_locked variants and then call get_lock_access to get new
access references on the nfs4_file under the same lock.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 16 ++++++++++++++--
 1 file changed, 14 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 5f7294712ad4..8f320f2f8b84 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -377,6 +377,8 @@ static struct hlist_head file_hashtbl[FILE_HASH_SIZE];
 static void
 __nfs4_file_get_access(struct nfs4_file *fp, u32 access)
 {
+	lockdep_assert_held(&fp->fi_lock);
+
 	if (access & NFS4_SHARE_ACCESS_WRITE)
 		atomic_inc(&fp->fi_access[O_WRONLY]);
 	if (access & NFS4_SHARE_ACCESS_READ)
@@ -386,6 +388,8 @@ __nfs4_file_get_access(struct nfs4_file *fp, u32 access)
 static __be32
 nfs4_file_get_access(struct nfs4_file *fp, u32 access)
 {
+	lockdep_assert_held(&fp->fi_lock);
+
 	/* Does this access mode make sense? */
 	if (access & ~NFS4_SHARE_ACCESS_BOTH)
 		return nfserr_inval;
@@ -4572,6 +4576,8 @@ static void get_lock_access(struct nfs4_ol_stateid *lock_stp, u32 access)
 {
 	struct nfs4_file *fp = lock_stp->st_file;
 
+	lockdep_assert_held(&fp->fi_lock);
+
 	if (test_access(access, lock_stp))
 		return;
 	__nfs4_file_get_access(fp, access);
@@ -4623,6 +4629,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	struct nfs4_openowner *open_sop = NULL;
 	struct nfs4_lockowner *lock_sop = NULL;
 	struct nfs4_ol_stateid *lock_stp;
+	struct nfs4_file *fp;
 	struct file *filp = NULL;
 	struct file_lock *file_lock = NULL;
 	struct file_lock *conflock = NULL;
@@ -4703,20 +4710,25 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
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


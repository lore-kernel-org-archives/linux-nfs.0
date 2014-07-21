Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f176.google.com ([209.85.213.176]:46686 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750737AbaGUWyZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jul 2014 18:54:25 -0400
Received: by mail-ig0-f176.google.com with SMTP id hn18so3374448igb.9
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jul 2014 15:54:24 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/4] knfsd: Store the filehandle with the struct nfs4_file
Date: Mon, 21 Jul 2014 18:54:28 -0400
Message-Id: <1405983271-61861-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For use when we may not have a struct inode.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 10 ++++++----
 fs/nfsd/state.h     |  1 +
 2 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 08ee9ca13cb1..55bc43674fce 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2805,7 +2805,8 @@ static struct nfs4_file *nfsd4_alloc_file(void)
 }
 
 /* OPEN Share state helper functions */
-static void nfsd4_init_file(struct nfs4_file *fp, struct inode *ino)
+static void nfsd4_init_file(struct nfs4_file *fp, struct inode *ino,
+		struct knfsd_fh *fh)
 {
 	unsigned int hashval = file_hashval(ino);
 
@@ -2814,6 +2815,7 @@ static void nfsd4_init_file(struct nfs4_file *fp, struct inode *ino)
 	INIT_LIST_HEAD(&fp->fi_stateids);
 	INIT_LIST_HEAD(&fp->fi_delegations);
 	fp->fi_inode = igrab(ino);
+	fh_copy_shallow(&fp->fi_fhandle, fh);
 	fp->fi_had_conflict = false;
 	fp->fi_lease = NULL;
 	memset(fp->fi_fds, 0, sizeof(fp->fi_fds));
@@ -3073,14 +3075,14 @@ find_file(struct inode *ino)
 }
 
 static struct nfs4_file *
-find_or_add_file(struct inode *ino, struct nfs4_file *new)
+find_or_add_file(struct inode *ino, struct nfs4_file *new, struct knfsd_fh *fh)
 {
 	struct nfs4_file *fp;
 
 	spin_lock(&state_lock);
 	fp = find_file_locked(ino);
 	if (fp == NULL) {
-		nfsd4_init_file(new, ino);
+		nfsd4_init_file(new, ino, fh);
 		fp = new;
 	}
 	spin_unlock(&state_lock);
@@ -3669,7 +3671,7 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 	 * and check for delegations in the process of being recalled.
 	 * If not found, create the nfs4_file struct
 	 */
-	fp = find_or_add_file(ino, open->op_file);
+	fp = find_or_add_file(ino, open->op_file, &current_fh->fh_handle);
 	if (fp != open->op_file) {
 		if ((status = nfs4_check_open(fp, open, &stp)))
 			goto out;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index f11c74f3d40d..38c575c084e4 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -405,6 +405,7 @@ struct nfs4_file {
 	struct file		*fi_deleg_file;
 	struct file_lock	*fi_lease;
 	atomic_t		fi_delegees;
+	struct knfsd_fh		fi_fhandle;
 	struct inode		*fi_inode;
 	bool			fi_had_conflict;
 };
-- 
1.9.3


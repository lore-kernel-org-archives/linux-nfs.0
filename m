Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f49.google.com ([209.85.216.49]:55478 "EHLO
	mail-qa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756323AbaGVQtw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Jul 2014 12:49:52 -0400
Received: by mail-qa0-f49.google.com with SMTP id dc16so6727435qab.8
        for <linux-nfs@vger.kernel.org>; Tue, 22 Jul 2014 09:49:51 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, trond.myklebust@primarydata.com,
        hch@infradead.org
Subject: [PATCH 1/4] nfsd: Store the filehandle with the struct nfs4_file
Date: Tue, 22 Jul 2014 12:49:41 -0400
Message-Id: <1406047784-1578-2-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406047784-1578-1-git-send-email-jlayton@primarydata.com>
References: <1406047784-1578-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

For use when we may not have a struct inode.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 10 ++++++----
 fs/nfsd/state.h     |  1 +
 2 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a3a828d17563..393cd83a4f42 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2833,7 +2833,8 @@ static struct nfs4_file *nfsd4_alloc_file(void)
 }
 
 /* OPEN Share state helper functions */
-static void nfsd4_init_file(struct nfs4_file *fp, struct inode *ino)
+static void nfsd4_init_file(struct nfs4_file *fp, struct inode *ino,
+		struct knfsd_fh *fh)
 {
 	unsigned int hashval = file_hashval(ino);
 
@@ -2845,6 +2846,7 @@ static void nfsd4_init_file(struct nfs4_file *fp, struct inode *ino)
 	INIT_LIST_HEAD(&fp->fi_delegations);
 	ihold(ino);
 	fp->fi_inode = ino;
+	fh_copy_shallow(&fp->fi_fhandle, fh);
 	fp->fi_had_conflict = false;
 	fp->fi_lease = NULL;
 	fp->fi_share_deny = 0;
@@ -3051,14 +3053,14 @@ find_file(struct inode *ino)
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
@@ -3713,7 +3715,7 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 	 * and check for delegations in the process of being recalled.
 	 * If not found, create the nfs4_file struct
 	 */
-	fp = find_or_add_file(ino, open->op_file);
+	fp = find_or_add_file(ino, open->op_file, &current_fh->fh_handle);
 	if (fp != open->op_file) {
 		status = nfs4_check_deleg(cl, open, &dp);
 		if (status)
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index e68a9ae30fd7..33cf950b3873 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -396,6 +396,7 @@ struct nfs4_file {
 	struct file		*fi_deleg_file;
 	struct file_lock	*fi_lease;
 	atomic_t		fi_delegees;
+	struct knfsd_fh		fi_fhandle;
 	struct inode		*fi_inode;
 	bool			fi_had_conflict;
 };
-- 
1.9.3


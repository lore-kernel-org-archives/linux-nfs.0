Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f41.google.com ([209.85.192.41]:38551 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932498AbaE3NJ4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 May 2014 09:09:56 -0400
Received: by mail-qg0-f41.google.com with SMTP id j5so5165522qga.14
        for <linux-nfs@vger.kernel.org>; Fri, 30 May 2014 06:09:56 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: trond.myklebust@primarydata.com, bhalevy@primarydata.com,
        linux-nfs@vger.kernel.org
Subject: [PATCH 8/9] NFSd: Protect addition to the file_hashtbl
Date: Fri, 30 May 2014 09:09:32 -0400
Message-Id: <1401455373-18207-9-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1401455373-18207-1-git-send-email-jlayton@primarydata.com>
References: <1401455373-18207-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Ensure that we only can have a single struct nfs4_file per inode
in the file_hashtbl and make addition atomic with respect to lookup.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 46 +++++++++++++++++++++++++++++++++++-----------
 1 file changed, 35 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a500033a2f87..553c2d6d48dc 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2519,6 +2519,8 @@ static void nfsd4_init_file(struct nfs4_file *fp, struct inode *ino)
 {
 	unsigned int hashval = file_hashval(ino);
 
+	lockdep_assert_held(&state_lock);
+
 	atomic_set(&fp->fi_ref, 1);
 	INIT_LIST_HEAD(&fp->fi_stateids);
 	INIT_LIST_HEAD(&fp->fi_delegations);
@@ -2527,9 +2529,7 @@ static void nfsd4_init_file(struct nfs4_file *fp, struct inode *ino)
 	fp->fi_lease = NULL;
 	memset(fp->fi_fds, 0, sizeof(fp->fi_fds));
 	memset(fp->fi_access, 0, sizeof(fp->fi_access));
-	spin_lock(&state_lock);
 	hlist_add_head(&fp->fi_hash, &file_hashtbl[hashval]);
-	spin_unlock(&state_lock);
 }
 
 void
@@ -2695,23 +2695,49 @@ find_openstateowner_str(unsigned int hashval, struct nfsd4_open *open,
 
 /* search file_hashtbl[] for file */
 static struct nfs4_file *
-find_file(struct inode *ino)
+find_file_locked(struct inode *ino)
 {
 	unsigned int hashval = file_hashval(ino);
 	struct nfs4_file *fp;
 
-	spin_lock(&state_lock);
+	lockdep_assert_held(&state_lock);
+
 	hlist_for_each_entry(fp, &file_hashtbl[hashval], fi_hash) {
 		if (fp->fi_inode == ino) {
 			get_nfs4_file(fp);
-			spin_unlock(&state_lock);
 			return fp;
 		}
 	}
-	spin_unlock(&state_lock);
 	return NULL;
 }
 
+static struct nfs4_file *
+find_file(struct inode *ino)
+{
+	struct nfs4_file *fp;
+
+	spin_lock(&state_lock);
+	fp = find_file_locked(ino);
+	spin_unlock(&state_lock);
+	return fp;
+}
+
+static struct nfs4_file *
+find_or_add_file(struct inode *ino, struct nfs4_file *new)
+{
+	struct nfs4_file *fp;
+
+	spin_lock(&state_lock);
+	fp = find_file_locked(ino);
+	if (fp == NULL) {
+		nfsd4_init_file(new, ino);
+		fp = new;
+	}
+	spin_unlock(&state_lock);
+
+	return fp;
+}
+
 /*
  * Called to check deny when READ with all zero stateid or
  * WRITE with all zero or all one stateid
@@ -3230,21 +3256,19 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 	 * and check for delegations in the process of being recalled.
 	 * If not found, create the nfs4_file struct
 	 */
-	fp = find_file(ino);
-	if (fp) {
+	fp = find_or_add_file(ino, open->op_file);
+	if (fp != open->op_file) {
 		if ((status = nfs4_check_open(fp, open, &stp)))
 			goto out;
 		status = nfs4_check_deleg(cl, open, &dp);
 		if (status)
 			goto out;
 	} else {
+		open->op_file = NULL;
 		status = nfserr_bad_stateid;
 		if (nfsd4_is_deleg_cur(open))
 			goto out;
 		status = nfserr_jukebox;
-		fp = open->op_file;
-		open->op_file = NULL;
-		nfsd4_init_file(fp, ino);
 	}
 
 	/*
-- 
1.9.3


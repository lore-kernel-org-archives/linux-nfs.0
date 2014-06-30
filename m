Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f49.google.com ([209.85.216.49]:48964 "EHLO
	mail-qa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752096AbaF3Pug (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 11:50:36 -0400
Received: by mail-qa0-f49.google.com with SMTP id w8so6504529qac.8
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 08:50:36 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v3 002/114] nfsd: Protect addition to the file_hashtbl
Date: Mon, 30 Jun 2014 11:48:31 -0400
Message-Id: <1404143423-24381-3-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Ensure that we only can have a single struct nfs4_file per inode
in the file_hashtbl and make addition atomic with respect to lookup.

To prevent an i_lock/state_lock inversion, change nfsd4_init_file to
use ihold instead if igrab. That's also more efficient anyway as we
definitely hold a reference to the inode at that point.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4state.c | 49 +++++++++++++++++++++++++++++++++++++------------
 1 file changed, 37 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index c473bd6d52c8..29788fd0da24 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2611,17 +2611,18 @@ static void nfsd4_init_file(struct nfs4_file *fp, struct inode *ino)
 {
 	unsigned int hashval = file_hashval(ino);
 
+	lockdep_assert_held(&state_lock);
+
 	atomic_set(&fp->fi_ref, 1);
 	INIT_LIST_HEAD(&fp->fi_stateids);
 	INIT_LIST_HEAD(&fp->fi_delegations);
-	fp->fi_inode = igrab(ino);
+	ihold(ino);
+	fp->fi_inode = ino;
 	fp->fi_had_conflict = false;
 	fp->fi_lease = NULL;
 	memset(fp->fi_fds, 0, sizeof(fp->fi_fds));
 	memset(fp->fi_access, 0, sizeof(fp->fi_access));
-	spin_lock(&state_lock);
 	hlist_add_head(&fp->fi_hash, &file_hashtbl[hashval]);
-	spin_unlock(&state_lock);
 }
 
 void
@@ -2787,23 +2788,49 @@ find_openstateowner_str(unsigned int hashval, struct nfsd4_open *open,
 
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
@@ -3325,21 +3352,19 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
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


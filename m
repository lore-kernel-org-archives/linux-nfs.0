Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f176.google.com ([209.85.213.176]:34243 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750737AbaGUWy0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jul 2014 18:54:26 -0400
Received: by mail-ig0-f176.google.com with SMTP id hn18so3374448igb.3
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jul 2014 15:54:25 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/4] knfsd: Use the filehandle to look up the struct nfs4_file instead of inode
Date: Mon, 21 Jul 2014 18:54:29 -0400
Message-Id: <1405983271-61861-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1405983271-61861-1-git-send-email-trond.myklebust@primarydata.com>
References: <1405983271-61861-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 46 ++++++++++++++++++++++++++++++----------------
 1 file changed, 30 insertions(+), 16 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 55bc43674fce..2e9519db4927 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -346,10 +346,22 @@ static int nfs4_access_to_omode(u32 access)
 	return O_RDONLY;
 }
 
-static unsigned int file_hashval(struct inode *ino)
+static unsigned int nfsd_fh_hashval(struct knfsd_fh *fh)
 {
-	/* XXX: why are we hashing on inode pointer, anyway? */
-	return hash_ptr(ino, FILE_HASH_BITS);
+	return jhash2(fh->fh_base.fh_pad, XDR_QUADLEN(fh->fh_size), 0);
+}
+
+static unsigned int file_hashval(struct knfsd_fh *fh)
+{
+	return nfsd_fh_hashval(fh) & (FILE_HASH_SIZE - 1);
+}
+
+static bool nfsd_fh_match(struct knfsd_fh *fh1, struct knfsd_fh *fh2)
+{
+	return fh1->fh_size == fh2->fh_size &&
+		!memcmp(fh1->fh_base.fh_pad,
+				fh2->fh_base.fh_pad,
+				fh1->fh_size);
 }
 
 static struct hlist_head file_hashtbl[FILE_HASH_SIZE];
@@ -583,11 +595,13 @@ static void unhash_stid(struct nfs4_stid *s)
 static void
 hash_delegation_locked(struct nfs4_delegation *dp, struct nfs4_file *fp)
 {
+	struct inode *inode = fp->fi_deleg_file->f_dentry->d_inode;
+
 	atomic_inc(&dp->dl_stid.sc_count);
 	dp->dl_stid.sc_type = NFS4_DELEG_STID;
-	spin_lock(&fp->fi_inode->i_lock);
+	spin_lock(&inode->i_lock);
 	list_add(&dp->dl_perfile, &fp->fi_delegations);
-	spin_unlock(&fp->fi_inode->i_lock);
+	spin_unlock(&inode->i_lock);
 	list_add(&dp->dl_perclnt, &dp->dl_stid.sc_client->cl_delegations);
 }
 
@@ -601,9 +615,10 @@ unhash_delegation_locked(struct nfs4_delegation *dp)
 	list_del_init(&dp->dl_perclnt);
 	list_del_init(&dp->dl_recall_lru);
 	if (!list_empty(&dp->dl_perfile)) {
-		spin_lock(&fp->fi_inode->i_lock);
+		struct inode *inode = fp->fi_deleg_file->f_dentry->d_inode;
+		spin_lock(&inode->i_lock);
 		list_del_init(&dp->dl_perfile);
-		spin_unlock(&fp->fi_inode->i_lock);
+		spin_unlock(&inode->i_lock);
 	}
 	nfs4_put_deleg_lease(fp);
 	spin_unlock(&fp->fi_lock);
@@ -2808,7 +2823,7 @@ static struct nfs4_file *nfsd4_alloc_file(void)
 static void nfsd4_init_file(struct nfs4_file *fp, struct inode *ino,
 		struct knfsd_fh *fh)
 {
-	unsigned int hashval = file_hashval(ino);
+	unsigned int hashval = file_hashval(fh);
 
 	atomic_set(&fp->fi_ref, 1);
 	spin_lock_init(&fp->fi_lock);
@@ -3047,15 +3062,15 @@ find_openstateowner_str(unsigned int hashval, struct nfsd4_open *open,
 
 /* search file_hashtbl[] for file */
 static struct nfs4_file *
-find_file_locked(struct inode *ino)
+find_file_locked(struct knfsd_fh *fh)
 {
-	unsigned int hashval = file_hashval(ino);
+	unsigned int hashval = file_hashval(fh);
 	struct nfs4_file *fp;
 
 	assert_spin_locked(&state_lock);
 
 	hlist_for_each_entry(fp, &file_hashtbl[hashval], fi_hash) {
-		if (fp->fi_inode == ino) {
+		if (nfsd_fh_match(&fp->fi_fhandle, fh)) {
 			get_nfs4_file(fp);
 			return fp;
 		}
@@ -3064,12 +3079,12 @@ find_file_locked(struct inode *ino)
 }
 
 static struct nfs4_file *
-find_file(struct inode *ino)
+find_file(struct knfsd_fh *fh)
 {
 	struct nfs4_file *fp;
 
 	spin_lock(&state_lock);
-	fp = find_file_locked(ino);
+	fp = find_file_locked(fh);
 	spin_unlock(&state_lock);
 	return fp;
 }
@@ -3080,7 +3095,7 @@ find_or_add_file(struct inode *ino, struct nfs4_file *new, struct knfsd_fh *fh)
 	struct nfs4_file *fp;
 
 	spin_lock(&state_lock);
-	fp = find_file_locked(ino);
+	fp = find_file_locked(fh);
 	if (fp == NULL) {
 		nfsd4_init_file(new, ino, fh);
 		fp = new;
@@ -3096,12 +3111,11 @@ find_or_add_file(struct inode *ino, struct nfs4_file *new, struct knfsd_fh *fh)
 static __be32
 nfs4_share_conflict(struct svc_fh *current_fh, unsigned int deny_type)
 {
-	struct inode *ino = current_fh->fh_dentry->d_inode;
 	struct nfs4_file *fp;
 	struct nfs4_ol_stateid *stp;
 	__be32 ret;
 
-	fp = find_file(ino);
+	fp = find_file(&current_fh->fh_handle);
 	if (!fp)
 		return nfs_ok;
 	ret = nfserr_locked;
-- 
1.9.3


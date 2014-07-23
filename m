Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f43.google.com ([209.85.192.43]:61334 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933336AbaGWURv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Jul 2014 16:17:51 -0400
Received: by mail-qg0-f43.google.com with SMTP id a108so2100065qge.16
        for <linux-nfs@vger.kernel.org>; Wed, 23 Jul 2014 13:17:50 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, trond.myklebust@primarydata.com,
        hch@infradead.org
Subject: [PATCH v2 2/4] nfsd: Use the filehandle to look up the struct nfs4_file instead of inode
Date: Wed, 23 Jul 2014 16:17:39 -0400
Message-Id: <1406146661-9794-3-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406146661-9794-1-git-send-email-jlayton@primarydata.com>
References: <1406146661-9794-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

This makes more sense anyway since an inode pointer value can change
even when the filehandle doesn't.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 35 +++++++++++++++++++++++------------
 1 file changed, 23 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 859891f30958..ab96718df3cc 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -368,10 +368,22 @@ static unsigned int ownerstr_hashval(u32 clientid, struct xdr_netobj *ownername)
 #define FILE_HASH_BITS                   8
 #define FILE_HASH_SIZE                  (1 << FILE_HASH_BITS)
 
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
@@ -2836,7 +2848,7 @@ static struct nfs4_file *nfsd4_alloc_file(void)
 static void nfsd4_init_file(struct nfs4_file *fp, struct inode *ino,
 		struct knfsd_fh *fh)
 {
-	unsigned int hashval = file_hashval(ino);
+	unsigned int hashval = file_hashval(fh);
 
 	lockdep_assert_held(&state_lock);
 
@@ -3023,15 +3035,15 @@ find_openstateowner_str(unsigned int hashval, struct nfsd4_open *open,
 
 /* search file_hashtbl[] for file */
 static struct nfs4_file *
-find_file_locked(struct inode *ino)
+find_file_locked(struct knfsd_fh *fh)
 {
-	unsigned int hashval = file_hashval(ino);
+	unsigned int hashval = file_hashval(fh);
 	struct nfs4_file *fp;
 
 	lockdep_assert_held(&state_lock);
 
 	hlist_for_each_entry(fp, &file_hashtbl[hashval], fi_hash) {
-		if (fp->fi_inode == ino) {
+		if (nfsd_fh_match(&fp->fi_fhandle, fh)) {
 			get_nfs4_file(fp);
 			return fp;
 		}
@@ -3040,12 +3052,12 @@ find_file_locked(struct inode *ino)
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
@@ -3056,7 +3068,7 @@ find_or_add_file(struct inode *ino, struct nfs4_file *new, struct knfsd_fh *fh)
 	struct nfs4_file *fp;
 
 	spin_lock(&state_lock);
-	fp = find_file_locked(ino);
+	fp = find_file_locked(fh);
 	if (fp == NULL) {
 		nfsd4_init_file(new, ino, fh);
 		fp = new;
@@ -3073,11 +3085,10 @@ find_or_add_file(struct inode *ino, struct nfs4_file *new, struct knfsd_fh *fh)
 static __be32
 nfs4_share_conflict(struct svc_fh *current_fh, unsigned int deny_type)
 {
-	struct inode *ino = current_fh->fh_dentry->d_inode;
 	struct nfs4_file *fp;
 	__be32 ret = nfs_ok;
 
-	fp = find_file(ino);
+	fp = find_file(&current_fh->fh_handle);
 	if (!fp)
 		return ret;
 	/* Check for conflicting share reservations */
-- 
1.9.3


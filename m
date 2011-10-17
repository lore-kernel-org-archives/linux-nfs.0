Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44761 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755623Ab1JQV4X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Oct 2011 17:56:23 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 5/8] nfsd4: preallocate nfs4_file in process_open1()
Date: Mon, 17 Oct 2011 17:55:54 -0400
Message-Id: <1318888557-14719-6-git-send-email-bfields@redhat.com>
In-Reply-To: <1318888557-14719-1-git-send-email-bfields@redhat.com>
References: <1318888557-14719-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Creating a new file is an irrevocable step--once it's visible in the
filesystem, other processes may have seen it and done something with it,
and unlinking it wouldn't simply undo the effects of the create.

Therefore, in the case where OPEN creates a new file, we shouldn't do
the create until we know that the rest of the OPEN processing will
succeed.

For example, we should preallocate a struct file in case we need it
until waiting to allocate it till process_open2(), which is already too
late.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   60 ++++++++++++++++++++++++++++++--------------------
 fs/nfsd/xdr4.h      |    1 +
 2 files changed, 37 insertions(+), 24 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2c9a1a2..ae5d250 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -104,6 +104,11 @@ opaque_hashval(const void *ptr, int nbytes)
 
 static struct list_head del_recall_lru;
 
+static void nfsd4_free_file(struct nfs4_file *f)
+{
+	kmem_cache_free(file_slab, f);
+}
+
 static inline void
 put_nfs4_file(struct nfs4_file *fi)
 {
@@ -111,7 +116,7 @@ put_nfs4_file(struct nfs4_file *fi)
 		list_del(&fi->fi_hash);
 		spin_unlock(&recall_lock);
 		iput(fi->fi_inode);
-		kmem_cache_free(file_slab, fi);
+		nfsd4_free_file(fi);
 	}
 }
 
@@ -2190,30 +2195,28 @@ out:
 	return status;
 }
 
+static struct nfs4_file *nfsd4_alloc_file(void)
+{
+	return kmem_cache_alloc(file_slab, GFP_KERNEL);
+}
+
 /* OPEN Share state helper functions */
-static inline struct nfs4_file *
-alloc_init_file(struct inode *ino)
+static void nfsd4_init_file(struct nfs4_file *fp, struct inode *ino)
 {
-	struct nfs4_file *fp;
 	unsigned int hashval = file_hashval(ino);
 
-	fp = kmem_cache_alloc(file_slab, GFP_KERNEL);
-	if (fp) {
-		atomic_set(&fp->fi_ref, 1);
-		INIT_LIST_HEAD(&fp->fi_hash);
-		INIT_LIST_HEAD(&fp->fi_stateids);
-		INIT_LIST_HEAD(&fp->fi_delegations);
-		fp->fi_inode = igrab(ino);
-		fp->fi_had_conflict = false;
-		fp->fi_lease = NULL;
-		memset(fp->fi_fds, 0, sizeof(fp->fi_fds));
-		memset(fp->fi_access, 0, sizeof(fp->fi_access));
-		spin_lock(&recall_lock);
-		list_add(&fp->fi_hash, &file_hashtbl[hashval]);
-		spin_unlock(&recall_lock);
-		return fp;
-	}
-	return NULL;
+	atomic_set(&fp->fi_ref, 1);
+	INIT_LIST_HEAD(&fp->fi_hash);
+	INIT_LIST_HEAD(&fp->fi_stateids);
+	INIT_LIST_HEAD(&fp->fi_delegations);
+	fp->fi_inode = igrab(ino);
+	fp->fi_had_conflict = false;
+	fp->fi_lease = NULL;
+	memset(fp->fi_fds, 0, sizeof(fp->fi_fds));
+	memset(fp->fi_access, 0, sizeof(fp->fi_access));
+	spin_lock(&recall_lock);
+	list_add(&fp->fi_hash, &file_hashtbl[hashval]);
+	spin_unlock(&recall_lock);
 }
 
 static void
@@ -2509,6 +2512,13 @@ nfsd4_process_open1(struct nfsd4_compound_state *cstate,
 
 	if (STALE_CLIENTID(&open->op_clientid))
 		return nfserr_stale_clientid;
+	/*
+	 * In case we need it later, after we've already created the
+	 * file and don't want to risk a further failure:
+	 */
+	open->op_file = nfsd4_alloc_file();
+	if (open->op_file == NULL)
+		return nfserr_jukebox;
 
 	strhashval = open_ownerstr_hashval(clientid->cl_id, &open->op_owner);
 	oo = find_openstateowner_str(strhashval, open);
@@ -2884,9 +2894,9 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 		if (open->op_claim_type == NFS4_OPEN_CLAIM_DELEGATE_CUR)
 			goto out;
 		status = nfserr_jukebox;
-		fp = alloc_init_file(ino);
-		if (fp == NULL)
-			goto out;
+		fp = open->op_file;
+		open->op_file = NULL;
+		nfsd4_init_file(fp, ino);
 	}
 
 	/*
@@ -2960,6 +2970,8 @@ void nfsd4_cleanup_open_state(struct nfsd4_open *open, __be32 status)
 				oo->oo_flags &= ~NFS4_OO_NEW;
 		}
 	}
+	if (open->op_file)
+		nfsd4_free_file(open->op_file);
 }
 
 __be32
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 32e6fd8..502dd43 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -228,6 +228,7 @@ struct nfsd4_open {
 	u32		op_rflags;          /* response */
 	int		op_truncate;        /* used during processing */
 	struct nfs4_openowner *op_openowner; /* used during processing */
+	struct nfs4_file *op_file;          /* used during processing */
 	struct nfs4_acl *op_acl;
 };
 #define op_iattr	iattr
-- 
1.7.5.4


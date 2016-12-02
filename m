Return-Path: <trondmy@gmail.com>
Sender: Trond Myklebust <trondmy@gmail.com>
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/3] NFS: Be more targeted about readdirplus use when doing lookup/revalidation
Date: Fri,  2 Dec 2016 09:21:34 -0500
Message-Id: <20161202142135.11515-3-trond.myklebust@primarydata.com>
In-Reply-To: <20161202142135.11515-2-trond.myklebust@primarydata.com>
References: <20161202142135.11515-1-trond.myklebust@primarydata.com>
 <20161202142135.11515-2-trond.myklebust@primarydata.com>
List-ID: <linux-nfs.vger.kernel.org>

There is little point in setting NFS_INO_ADVISE_RDPLUS in nfs_lookup and
nfs_lookup_revalidate() unless a process is actually doing readdir on the
parent directory.
Furthermore, there is little point in using readdirplus if we're trying
to revalidate a negative dentry.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/dir.c | 30 +++++++++++++++++++-----------
 1 file changed, 19 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 9220bc7b9cd7..22835150579a 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -455,14 +455,18 @@ bool nfs_use_readdirplus(struct inode *dir, struct dir_context *ctx)
 }
 
 /*
- * This function is called by the lookup code to request the use of
- * readdirplus to accelerate any future lookups in the same
+ * This function is called by the lookup and getattr code to request the
+ * use of readdirplus to accelerate any future lookups in the same
  * directory.
  */
 static
 void nfs_advise_use_readdirplus(struct inode *dir)
 {
-	set_bit(NFS_INO_ADVISE_RDPLUS, &NFS_I(dir)->flags);
+	struct nfs_inode *nfsi = NFS_I(dir);
+
+	if (nfs_server_capable(dir, NFS_CAP_READDIRPLUS) &&
+	    !list_empty(&nfsi->open_files))
+		set_bit(NFS_INO_ADVISE_RDPLUS, &nfsi->flags);
 }
 
 /*
@@ -475,8 +479,11 @@ void nfs_advise_use_readdirplus(struct inode *dir)
  */
 void nfs_force_use_readdirplus(struct inode *dir)
 {
-	if (!list_empty(&NFS_I(dir)->open_files)) {
-		nfs_advise_use_readdirplus(dir);
+	struct nfs_inode *nfsi = NFS_I(dir);
+
+	if (nfs_server_capable(dir, NFS_CAP_READDIRPLUS) &&
+	    !list_empty(&nfsi->open_files)) {
+		set_bit(NFS_INO_ADVISE_RDPLUS, &nfsi->flags);
 		invalidate_mapping_pages(dir->i_mapping, 0, -1);
 	}
 }
@@ -1150,7 +1157,7 @@ static int nfs_lookup_revalidate(struct dentry *dentry, unsigned int flags)
 				return -ECHILD;
 			goto out_bad;
 		}
-		goto out_valid_noent;
+		goto out_valid;
 	}
 
 	if (is_bad_inode(inode)) {
@@ -1173,6 +1180,7 @@ static int nfs_lookup_revalidate(struct dentry *dentry, unsigned int flags)
 				return -ECHILD;
 			goto out_zap_parent;
 		}
+		nfs_advise_use_readdirplus(dir);
 		goto out_valid;
 	}
 
@@ -1208,12 +1216,12 @@ static int nfs_lookup_revalidate(struct dentry *dentry, unsigned int flags)
 	nfs_free_fhandle(fhandle);
 	nfs4_label_free(label);
 
+	/* set a readdirplus hint that we had a cache miss */
+	nfs_force_use_readdirplus(dir);
+
 out_set_verifier:
 	nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
  out_valid:
-	/* Success: notify readdir to use READDIRPLUS */
-	nfs_advise_use_readdirplus(dir);
- out_valid_noent:
 	if (flags & LOOKUP_RCU) {
 		if (parent != ACCESS_ONCE(dentry->d_parent))
 			return -ECHILD;
@@ -1413,8 +1421,8 @@ struct dentry *nfs_lookup(struct inode *dir, struct dentry * dentry, unsigned in
 	if (IS_ERR(res))
 		goto out_label;
 
-	/* Success: notify readdir to use READDIRPLUS */
-	nfs_advise_use_readdirplus(dir);
+	/* Notify readdir to use READDIRPLUS */
+	nfs_force_use_readdirplus(dir);
 
 no_entry:
 	res = d_splice_alias(inode, dentry);
-- 
2.9.3

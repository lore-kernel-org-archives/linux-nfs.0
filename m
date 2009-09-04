From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 1/6] nfsd: move some of fh_compose into helper functions
Date: Fri,  4 Sep 2009 15:47:01 -0400
Message-ID: <1252093626-5560-2-git-send-email-bfields@citi.umich.edu>
References: <1252093626-5560-1-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:50163 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757261AbZIDTrE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Sep 2009 15:47:04 -0400
In-Reply-To: <1252093626-5560-1-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfsfh.c |   83 +++++++++++++++++++++++++++++-------------------------
 1 files changed, 45 insertions(+), 38 deletions(-)

diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index 8847f3f..78d8ebf 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -397,6 +397,40 @@ static inline void _fh_update_old(struct dentry *dentry,
 		fh->ofh_dirino = 0;
 }
 
+static bool is_root_export(struct svc_export *exp)
+{
+	return exp->ex_path.dentry == exp->ex_path.dentry->d_sb->s_root;
+}
+
+static struct super_block *exp_sb(struct svc_export *exp)
+{
+	return exp->ex_path.dentry->d_inode->i_sb;
+}
+
+static bool fsid_type_ok_for_exp(u8 fsid_type, struct svc_export *exp)
+{
+	switch (fsid_type) {
+	case FSID_DEV:
+		if (!old_valid_dev(exp_sb(exp)->s_dev))
+			return 0;
+		/* FALL THROUGH */
+	case FSID_MAJOR_MINOR:
+	case FSID_ENCODE_DEV:
+		return exp_sb(exp)->s_type->fs_flags & FS_REQUIRES_DEV;
+	case FSID_NUM:
+		return exp->ex_flags & NFSEXP_FSID;
+	case FSID_UUID8:
+	case FSID_UUID16:
+		if (!is_root_export(exp))
+			return 0;
+		/* fall through */
+	case FSID_UUID4_INUM:
+	case FSID_UUID16_INUM:
+		return exp->ex_uuid != NULL;
+	}
+	return 1;
+}
+
 __be32
 fh_compose(struct svc_fh *fhp, struct svc_export *exp, struct dentry *dentry,
 	   struct svc_fh *ref_fh)
@@ -414,8 +448,7 @@ fh_compose(struct svc_fh *fhp, struct svc_export *exp, struct dentry *dentry,
 	struct inode * inode = dentry->d_inode;
 	struct dentry *parent = dentry->d_parent;
 	__u32 *datap;
-	dev_t ex_dev = exp->ex_path.dentry->d_inode->i_sb->s_dev;
-	int root_export = (exp->ex_path.dentry == exp->ex_path.dentry->d_sb->s_root);
+	dev_t ex_dev = exp_sb(exp)->s_dev;
 
 	dprintk("nfsd: fh_compose(exp %02x:%02x/%ld %s/%s, ino=%ld)\n",
 		MAJOR(ex_dev), MINOR(ex_dev),
@@ -447,49 +480,24 @@ fh_compose(struct svc_fh *fhp, struct svc_export *exp, struct dentry *dentry,
 			goto retry;
 		}
 
-		/* Need to check that this type works for this
-		 * export point.  As the fsid -> filesystem mapping
-		 * was guided by user-space, there is no guarantee
-		 * that the filesystem actually supports that fsid
-		 * type. If it doesn't we loop around again without
-		 * ref_fh set.
+		/*
+		 * As the fsid -> filesystem mapping was guided by
+		 * user-space, there is no guarantee that the filesystem
+		 * actually supports that fsid type. If it doesn't we
+		 * loop around again without ref_fh set.
 		 */
-		switch(fsid_type) {
-		case FSID_DEV:
-			if (!old_valid_dev(ex_dev))
-				goto retry;
-			/* FALL THROUGH */
-		case FSID_MAJOR_MINOR:
-		case FSID_ENCODE_DEV:
-			if (!(exp->ex_path.dentry->d_inode->i_sb->s_type->fs_flags
-			      & FS_REQUIRES_DEV))
-				goto retry;
-			break;
-		case FSID_NUM:
-			if (! (exp->ex_flags & NFSEXP_FSID))
-				goto retry;
-			break;
-		case FSID_UUID8:
-		case FSID_UUID16:
-			if (!root_export)
-				goto retry;
-			/* fall through */
-		case FSID_UUID4_INUM:
-		case FSID_UUID16_INUM:
-			if (exp->ex_uuid == NULL)
-				goto retry;
-			break;
-		}
+		if (!fsid_type_ok_for_exp(fsid_type, exp))
+			goto retry;
 	} else if (exp->ex_flags & NFSEXP_FSID) {
 		fsid_type = FSID_NUM;
 	} else if (exp->ex_uuid) {
 		if (fhp->fh_maxsize >= 64) {
-			if (root_export)
+			if (is_root_export(exp))
 				fsid_type = FSID_UUID16;
 			else
 				fsid_type = FSID_UUID16_INUM;
 		} else {
-			if (root_export)
+			if (is_root_export(exp))
 				fsid_type = FSID_UUID8;
 			else
 				fsid_type = FSID_UUID4_INUM;
@@ -639,8 +647,7 @@ enum fsid_source fsid_source(struct svc_fh *fhp)
 	case FSID_DEV:
 	case FSID_ENCODE_DEV:
 	case FSID_MAJOR_MINOR:
-		if (fhp->fh_export->ex_path.dentry->d_inode->i_sb->s_type->fs_flags
-		    & FS_REQUIRES_DEV)
+		if (exp_sb(fhp->fh_export)->s_type->fs_flags & FS_REQUIRES_DEV)
 			return FSIDSOURCE_DEV;
 		break;
 	case FSID_NUM:
-- 
1.6.0.4


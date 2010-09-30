Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:36219 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755879Ab0I3Rde (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Sep 2010 13:33:34 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] SQUASHME: pnfsd: factor out pnfsd check_export crap out of check_export
Date: Thu, 30 Sep 2010 19:33:30 +0200
Message-Id: <1285868010-28386-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/export.c |   82 +++++++++++++++++++++++++++++------------------------
 1 files changed, 45 insertions(+), 37 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 91be0d7..e856320 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -398,44 +398,9 @@ static struct svc_export *svc_export_update(struct svc_export *new,
 					    struct svc_export *old);
 static struct svc_export *svc_export_lookup(struct svc_export *);
 
-static int check_export(struct inode *inode, int *flags, unsigned char *uuid)
+static int pnfsd_check_export(struct inode *inode, int *flags)
 {
-
-	/*
-	 * We currently export only dirs, regular files, and (for v4
-	 * pseudoroot) symlinks.
-	 */
-	if (!S_ISDIR(inode->i_mode) &&
-	    !S_ISLNK(inode->i_mode) &&
-	    !S_ISREG(inode->i_mode))
-		return -ENOTDIR;
-
-	/*
-	 * Mountd should never pass down a writeable V4ROOT export, but,
-	 * just to make sure:
-	 */
-	if (*flags & NFSEXP_V4ROOT)
-		*flags |= NFSEXP_READONLY;
-
-	/* There are two requirements on a filesystem to be exportable.
-	 * 1:  We must be able to identify the filesystem from a number.
-	 *       either a device number (so FS_REQUIRES_DEV needed)
-	 *       or an FSID number (so NFSEXP_FSID or ->uuid is needed).
-	 * 2:  We must be able to find an inode from a filehandle.
-	 *       This means that s_export_op must be set.
-	 */
-	if (!(inode->i_sb->s_type->fs_flags & FS_REQUIRES_DEV) &&
-	    !(*flags & NFSEXP_FSID) &&
-	    uuid == NULL) {
-		dprintk("exp_export: export of non-dev fs without fsid\n");
-		return -EINVAL;
-	}
-
-	if (!inode->i_sb->s_export_op ||
-	    !inode->i_sb->s_export_op->fh_to_dentry) {
-		dprintk("exp_export: export of invalid fs type.\n");
-		return -EINVAL;
-	}
+#if defined(CONFIG_PNFSD)
 
 #if !defined(CONFIG_SPNFS)
 	if (inode->i_sb->s_pnfs_op &&
@@ -478,8 +443,51 @@ static int check_export(struct inode *inode, int *flags, unsigned char *uuid)
 	}
 #endif /* CONFIG_SPNFS */
 
+#endif /* CONFIG_PNFSD */
+
 	return 0;
+}
+
+static int check_export(struct inode *inode, int *flags, unsigned char *uuid)
+{
+
+	/*
+	 * We currently export only dirs, regular files, and (for v4
+	 * pseudoroot) symlinks.
+	 */
+	if (!S_ISDIR(inode->i_mode) &&
+	    !S_ISLNK(inode->i_mode) &&
+	    !S_ISREG(inode->i_mode))
+		return -ENOTDIR;
+
+	/*
+	 * Mountd should never pass down a writeable V4ROOT export, but,
+	 * just to make sure:
+	 */
+	if (*flags & NFSEXP_V4ROOT)
+		*flags |= NFSEXP_READONLY;
+
+	/* There are two requirements on a filesystem to be exportable.
+	 * 1:  We must be able to identify the filesystem from a number.
+	 *       either a device number (so FS_REQUIRES_DEV needed)
+	 *       or an FSID number (so NFSEXP_FSID or ->uuid is needed).
+	 * 2:  We must be able to find an inode from a filehandle.
+	 *       This means that s_export_op must be set.
+	 */
+	if (!(inode->i_sb->s_type->fs_flags & FS_REQUIRES_DEV) &&
+	    !(*flags & NFSEXP_FSID) &&
+	    uuid == NULL) {
+		dprintk("exp_export: export of non-dev fs without fsid\n");
+		return -EINVAL;
+	}
+
+	if (!inode->i_sb->s_export_op ||
+	    !inode->i_sb->s_export_op->fh_to_dentry) {
+		dprintk("exp_export: export of invalid fs type.\n");
+		return -EINVAL;
+	}
 
+	return pnfsd_check_export(inode, flags);
 }
 
 #ifdef CONFIG_NFSD_V4
-- 
1.7.2.3


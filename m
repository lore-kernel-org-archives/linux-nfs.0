Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51478 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753606Ab2KHAgW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Nov 2012 19:36:22 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/4] nfsd4: helper function for getting mounted_on ino
Date: Wed,  7 Nov 2012 19:36:09 -0500
Message-Id: <1352334972-28495-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1352334972-28495-1-git-send-email-bfields@redhat.com>
References: <1352334972-28495-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c |   30 ++++++++++++++++++------------
 1 file changed, 18 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index fd548d1..af65fda 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2014,6 +2014,22 @@ static __be32 fattr_handle_absent_fs(u32 *bmval0, u32 *bmval1, u32 *rdattr_err)
 	return 0;
 }
 
+
+static int get_parent_attributes(struct svc_export *exp, struct kstat *stat)
+{
+	struct path path = exp->ex_path;
+	int err;
+
+	path_get(&path);
+	while (follow_up(&path)) {
+		if (path.dentry != path.mnt->mnt_root)
+			break;
+	}
+	err = vfs_getattr(path.mnt, path.dentry, stat);
+	path_put(&path);
+	return err;
+}
+
 /*
  * Note: @fhp can be NULL; in this case, we might have to compose the filehandle
  * ourselves.
@@ -2430,18 +2446,8 @@ out_acl:
 		 * and this is the root of a cross-mounted filesystem.
 		 */
 		if (ignore_crossmnt == 0 &&
-		    dentry == exp->ex_path.mnt->mnt_root) {
-			struct path path = exp->ex_path;
-			path_get(&path);
-			while (follow_up(&path)) {
-				if (path.dentry != path.mnt->mnt_root)
-					break;
-			}
-			err = vfs_getattr(path.mnt, path.dentry, &stat);
-			path_put(&path);
-			if (err)
-				goto out_nfserr;
-		}
+		    dentry == exp->ex_path.mnt->mnt_root)
+			get_parent_attributes(exp, &stat);
 		WRITE64(stat.ino);
 	}
 	if (bmval2 & FATTR4_WORD2_SUPPATTR_EXCLCREAT) {
-- 
1.7.9.5


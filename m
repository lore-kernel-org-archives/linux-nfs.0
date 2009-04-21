From: Al Viro <viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org>
Subject: [PATCH 3/5] switch exp_parent() to struct path
Date: Tue, 21 Apr 2009 21:43:41 +0000
Message-ID: <E1LwNkj-0004WR-BW@ZenIV.linux.org.uk>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:60960 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753466AbZDUVnm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Apr 2009 17:43:42 -0400
Received: from viro by ZenIV.linux.org.uk with local (Exim 4.69 #1 (Red Hat Linux))
	id 1LwNkj-0004WR-BW
	for linux-nfs@vger.kernel.org; Tue, 21 Apr 2009 21:43:41 +0000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


... and lose the always-NULL last argument (non-NULL case had been
split off a while ago).

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 fs/nfsd/export.c |   28 ++++++++++++----------------
 1 files changed, 12 insertions(+), 16 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 3f6d51b..5149dab 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -871,23 +871,19 @@ static svc_export *exp_get_by_name(svc_client *clp, const struct path *path,
 /*
  * Find the export entry for a given dentry.
  */
-static struct svc_export *exp_parent(svc_client *clp, struct vfsmount *mnt,
-				     struct dentry *dentry,
-				     struct cache_req *reqp)
+static struct svc_export *exp_parent(svc_client *clp, struct path *path)
 {
-	struct path path = {.mnt = mnt, .dentry = dentry};
-	svc_export *exp;
-
-	dget(path.dentry);
-	exp = exp_get_by_name(clp, &path, reqp);
-
-	while (PTR_ERR(exp) == -ENOENT && !IS_ROOT(path.dentry)) {
-		struct dentry *parent = dget_parent(path.dentry);
-		dput(path.dentry);
-		path.dentry = parent;
-		exp = exp_get_by_name(clp, &path, reqp);
+	struct dentry *saved = dget(path->dentry);
+	svc_export *exp = exp_get_by_name(clp, path, NULL);
+
+	while (PTR_ERR(exp) == -ENOENT && !IS_ROOT(path->dentry)) {
+		struct dentry *parent = dget_parent(path->dentry);
+		dput(path->dentry);
+		path->dentry = parent;
+		exp = exp_get_by_name(clp, path, NULL);
 	}
-	dput(path.dentry);
+	dput(path->dentry);
+	path->dentry = saved;
 	return exp;
 }
 
@@ -1174,7 +1170,7 @@ exp_rootfh(svc_client *clp, char *name, struct knfsd_fh *f, int maxsize)
 	dprintk("nfsd: exp_rootfh(%s [%p] %s:%s/%ld)\n",
 		 name, path.dentry, clp->name,
 		 inode->i_sb->s_id, inode->i_ino);
-	exp = exp_parent(clp, path.mnt, path.dentry, NULL);
+	exp = exp_parent(clp, &path);
 	if (IS_ERR(exp)) {
 		err = PTR_ERR(exp);
 		goto out;
-- 
1.5.6.5



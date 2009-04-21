From: Al Viro <viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org>
Subject: [PATCH 5/5] switch rqst_exp_parent()
Date: Tue, 21 Apr 2009 21:43:41 +0000
Message-ID: <E1LwNkj-0004WV-CZ@ZenIV.linux.org.uk>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:60961 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753680AbZDUVnm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Apr 2009 17:43:42 -0400
Received: from viro by ZenIV.linux.org.uk with local (Exim 4.69 #1 (Red Hat Linux))
	id 1LwNkj-0004WV-CZ
	for linux-nfs@vger.kernel.org; Tue, 21 Apr 2009 21:43:41 +0000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 fs/nfsd/export.c            |   25 ++++++++++---------------
 fs/nfsd/vfs.c               |   23 ++++++++++++-----------
 include/linux/nfsd/export.h |    3 +--
 3 files changed, 23 insertions(+), 28 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 84f5e5c..8b1f8ef 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -1299,24 +1299,19 @@ gss:
 }
 
 struct svc_export *
-rqst_exp_parent(struct svc_rqst *rqstp, struct vfsmount *mnt,
-		struct dentry *dentry)
+rqst_exp_parent(struct svc_rqst *rqstp, struct path *path)
 {
-	struct svc_export *exp;
-	struct path path = {.mnt = mnt, .dentry = dentry};
-
-	dget(dentry);
-	exp = rqst_exp_get_by_name(rqstp, &path);
-
-	while (PTR_ERR(exp) == -ENOENT && !IS_ROOT(dentry)) {
-		struct dentry *parent;
+	struct dentry *saved = dget(path->dentry);
+	struct svc_export *exp = rqst_exp_get_by_name(rqstp, path);
 
-		parent = dget_parent(dentry);
-		dput(dentry);
-		dentry = parent;
-		exp = rqst_exp_get_by_name(rqstp, &path);
+	while (PTR_ERR(exp) == -ENOENT && !IS_ROOT(path->dentry)) {
+		struct dentry *parent = dget_parent(path->dentry);
+		dput(path->dentry);
+		path->dentry = parent;
+		exp = rqst_exp_get_by_name(rqstp, path);
 	}
-	dput(dentry);
+	dput(path->dentry);
+	path->dentry = saved;
 	return exp;
 }
 
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 51de7e8..1bbf8fd 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -168,28 +168,29 @@ nfsd_lookup_dentry(struct svc_rqst *rqstp, struct svc_fh *fhp,
 			/* checking mountpoint crossing is very different when stepping up */
 			struct svc_export *exp2 = NULL;
 			struct dentry *dp;
-			struct vfsmount *mnt = mntget(exp->ex_path.mnt);
-			dentry = dget(dparent);
-			while(dentry == mnt->mnt_root && follow_up(&mnt, &dentry))
+			struct path path = {.mnt = mntget(exp->ex_path.mnt),
+					    .dentry = dget(dparent)};
+
+			while (path.dentry == path.mnt->mnt_root &&
+			       follow_up(&path.mnt, &path.dentry))
 				;
-			dp = dget_parent(dentry);
-			dput(dentry);
-			dentry = dp;
+			dp = dget_parent(path.dentry);
+			dput(path.dentry);
+			path.dentry = dp;
 
-			exp2 = rqst_exp_parent(rqstp, mnt, dentry);
+			exp2 = rqst_exp_parent(rqstp, &path);
 			if (PTR_ERR(exp2) == -ENOENT) {
-				dput(dentry);
 				dentry = dget(dparent);
 			} else if (IS_ERR(exp2)) {
 				host_err = PTR_ERR(exp2);
-				dput(dentry);
-				mntput(mnt);
+				path_put(&path);
 				goto out_nfserr;
 			} else {
+				dentry = dget(path.dentry);
 				exp_put(exp);
 				exp = exp2;
 			}
-			mntput(mnt);
+			path_put(&path);
 		}
 	} else {
 		fh_lock(fhp);
diff --git a/include/linux/nfsd/export.h b/include/linux/nfsd/export.h
index 98f6fd5..a6d9ef2 100644
--- a/include/linux/nfsd/export.h
+++ b/include/linux/nfsd/export.h
@@ -127,8 +127,7 @@ void			exp_readunlock(void);
 struct svc_export *	rqst_exp_get_by_name(struct svc_rqst *,
 					     struct path *);
 struct svc_export *	rqst_exp_parent(struct svc_rqst *,
-					struct vfsmount *mnt,
-					struct dentry *dentry);
+					struct path *);
 int			exp_rootfh(struct auth_domain *, 
 					char *path, struct knfsd_fh *, int maxsize);
 __be32			exp_pseudoroot(struct svc_rqst *, struct svc_fh *);
-- 
1.5.6.5


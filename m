From: Al Viro <viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org>
Subject: [PATCH 4/5] switch rqst_exp_get_by_name()
Date: Tue, 21 Apr 2009 21:43:41 +0000
Message-ID: <E1LwNkj-0004WT-CW@ZenIV.linux.org.uk>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:60959 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753053AbZDUVnm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Apr 2009 17:43:42 -0400
Received: from viro by ZenIV.linux.org.uk with local (Exim 4.69 #1 (Red Hat Linux))
	id 1LwNkj-0004WT-CW
	for linux-nfs@vger.kernel.org; Tue, 21 Apr 2009 21:43:41 +0000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 fs/nfsd/export.c            |   15 ++++++---------
 fs/nfsd/vfs.c               |   32 ++++++++++++++++----------------
 include/linux/nfsd/export.h |    3 +--
 3 files changed, 23 insertions(+), 27 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 5149dab..84f5e5c 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -1240,18 +1240,15 @@ __be32 check_nfsd_access(struct svc_export *exp, struct svc_rqst *rqstp)
  * use exp_get_by_name() or exp_find().
  */
 struct svc_export *
-rqst_exp_get_by_name(struct svc_rqst *rqstp, struct vfsmount *mnt,
-		struct dentry *dentry)
+rqst_exp_get_by_name(struct svc_rqst *rqstp, struct path *path)
 {
 	struct svc_export *gssexp, *exp = ERR_PTR(-ENOENT);
-	struct path path = {.mnt = mnt, .dentry = dentry};
 
 	if (rqstp->rq_client == NULL)
 		goto gss;
 
 	/* First try the auth_unix client: */
-	exp = exp_get_by_name(rqstp->rq_client, &path,
-						&rqstp->rq_chandle);
+	exp = exp_get_by_name(rqstp->rq_client, path, &rqstp->rq_chandle);
 	if (PTR_ERR(exp) == -ENOENT)
 		goto gss;
 	if (IS_ERR(exp))
@@ -1263,8 +1260,7 @@ gss:
 	/* Otherwise, try falling back on gss client */
 	if (rqstp->rq_gssclient == NULL)
 		return exp;
-	gssexp = exp_get_by_name(rqstp->rq_gssclient, &path,
-						&rqstp->rq_chandle);
+	gssexp = exp_get_by_name(rqstp->rq_gssclient, path, &rqstp->rq_chandle);
 	if (PTR_ERR(gssexp) == -ENOENT)
 		return exp;
 	if (!IS_ERR(exp))
@@ -1307,9 +1303,10 @@ rqst_exp_parent(struct svc_rqst *rqstp, struct vfsmount *mnt,
 		struct dentry *dentry)
 {
 	struct svc_export *exp;
+	struct path path = {.mnt = mnt, .dentry = dentry};
 
 	dget(dentry);
-	exp = rqst_exp_get_by_name(rqstp, mnt, dentry);
+	exp = rqst_exp_get_by_name(rqstp, &path);
 
 	while (PTR_ERR(exp) == -ENOENT && !IS_ROOT(dentry)) {
 		struct dentry *parent;
@@ -1317,7 +1314,7 @@ rqst_exp_parent(struct svc_rqst *rqstp, struct vfsmount *mnt,
 		parent = dget_parent(dentry);
 		dput(dentry);
 		dentry = parent;
-		exp = rqst_exp_get_by_name(rqstp, mnt, dentry);
+		exp = rqst_exp_get_by_name(rqstp, &path);
 	}
 	dput(dentry);
 	return exp;
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 6c68ffd..51de7e8 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -100,36 +100,36 @@ nfsd_cross_mnt(struct svc_rqst *rqstp, struct dentry **dpp,
 {
 	struct svc_export *exp = *expp, *exp2 = NULL;
 	struct dentry *dentry = *dpp;
-	struct vfsmount *mnt = mntget(exp->ex_path.mnt);
-	struct dentry *mounts = dget(dentry);
+	struct path path = {.mnt = mntget(exp->ex_path.mnt),
+			    .dentry = dget(dentry)};
 	int err = 0;
 
-	while (follow_down(&mnt,&mounts)&&d_mountpoint(mounts));
+	while (follow_down(&path.mnt, &path.dentry) &&
+	       d_mountpoint(path.dentry))
+		;
 
-	exp2 = rqst_exp_get_by_name(rqstp, mnt, mounts);
+	exp2 = rqst_exp_get_by_name(rqstp, &path);
 	if (IS_ERR(exp2)) {
 		if (PTR_ERR(exp2) != -ENOENT)
 			err = PTR_ERR(exp2);
-		dput(mounts);
-		mntput(mnt);
+		path_put(&path);
 		goto out;
 	}
 	if ((exp->ex_flags & NFSEXP_CROSSMOUNT) || EX_NOHIDE(exp2)) {
 		/* successfully crossed mount point */
 		/*
-		 * This is subtle: dentry is *not* under mnt at this point.
-		 * The only reason we are safe is that original mnt is pinned
-		 * down by exp, so we should dput before putting exp.
+		 * This is subtle: path.dentry is *not* on path.mnt
+		 * at this point.  The only reason we are safe is that
+		 * original mnt is pinned down by exp, so we should
+		 * put path *before* putting exp
 		 */
-		dput(dentry);
-		*dpp = mounts;
-		exp_put(exp);
+		*dpp = path.dentry;
+		path.dentry = dentry;
 		*expp = exp2;
-	} else {
-		exp_put(exp2);
-		dput(mounts);
+		exp2 = exp;
 	}
-	mntput(mnt);
+	path_put(&path);
+	exp_put(exp2);
 out:
 	return err;
 }
diff --git a/include/linux/nfsd/export.h b/include/linux/nfsd/export.h
index bcd0201..98f6fd5 100644
--- a/include/linux/nfsd/export.h
+++ b/include/linux/nfsd/export.h
@@ -125,8 +125,7 @@ void			nfsd_export_flush(void);
 void			exp_readlock(void);
 void			exp_readunlock(void);
 struct svc_export *	rqst_exp_get_by_name(struct svc_rqst *,
-					     struct vfsmount *,
-					     struct dentry *);
+					     struct path *);
 struct svc_export *	rqst_exp_parent(struct svc_rqst *,
 					struct vfsmount *mnt,
 					struct dentry *dentry);
-- 
1.5.6.5



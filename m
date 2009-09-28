From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 3/4] nfsd: minor nfsd_lookup cleanup
Date: Mon, 28 Sep 2009 12:22:31 -0400
Message-ID: <1254154952-13083-4-git-send-email-bfields@citi.umich.edu>
References: <1254154952-13083-1-git-send-email-bfields@citi.umich.edu>
 <1254154952-13083-2-git-send-email-bfields@citi.umich.edu>
 <1254154952-13083-3-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48555 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752299AbZI1QWN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Sep 2009 12:22:13 -0400
In-Reply-To: <1254154952-13083-3-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Break out some of nfsd_lookup_dentry into helper functions.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/vfs.c |   60 ++++++++++++++++++++++++++++++++++----------------------
 1 files changed, 36 insertions(+), 24 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index b8ed58b..6385739 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -141,6 +141,40 @@ out:
 	return err;
 }
 
+static void follow_to_parent(struct path *path)
+{
+	struct dentry *dp;
+
+	while (path->dentry == path->mnt->mnt_root && follow_up(path))
+		;
+	dp = dget_parent(path->dentry);
+	dput(path->dentry);
+	path->dentry = dp;
+}
+
+static int nfsd_lookup_parent(struct svc_rqst *rqstp, struct dentry *dparent, struct svc_export **exp, struct dentry **dentryp)
+{
+	struct svc_export *exp2;
+	struct path path = {.mnt = mntget((*exp)->ex_path.mnt),
+			    .dentry = dget(dparent)};
+
+	follow_to_parent(&path);
+
+	exp2 = rqst_exp_parent(rqstp, &path);
+	if (PTR_ERR(exp2) == -ENOENT) {
+		*dentryp = dget(dparent);
+	} else if (IS_ERR(exp2)) {
+		path_put(&path);
+		return PTR_ERR(exp2);
+	} else {
+		*dentryp = dget(path.dentry);
+		exp_put(*exp);
+		*exp = exp2;
+	}
+	path_put(&path);
+	return 0;
+}
+
 __be32
 nfsd_lookup_dentry(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		   const char *name, unsigned int len,
@@ -173,31 +207,9 @@ nfsd_lookup_dentry(struct svc_rqst *rqstp, struct svc_fh *fhp,
 			dentry = dget(dparent); /* .. == . just like at / */
 		else {
 			/* checking mountpoint crossing is very different when stepping up */
-			struct svc_export *exp2 = NULL;
-			struct dentry *dp;
-			struct path path = {.mnt = mntget(exp->ex_path.mnt),
-					    .dentry = dget(dparent)};
-
-			while (path.dentry == path.mnt->mnt_root &&
-			       follow_up(&path))
-				;
-			dp = dget_parent(path.dentry);
-			dput(path.dentry);
-			path.dentry = dp;
-
-			exp2 = rqst_exp_parent(rqstp, &path);
-			if (PTR_ERR(exp2) == -ENOENT) {
-				dentry = dget(dparent);
-			} else if (IS_ERR(exp2)) {
-				host_err = PTR_ERR(exp2);
-				path_put(&path);
+			host_err = nfsd_lookup_parent(rqstp, dparent, &exp, &dentry);
+			if (host_err)
 				goto out_nfserr;
-			} else {
-				dentry = dget(path.dentry);
-				exp_put(exp);
-				exp = exp2;
-			}
-			path_put(&path);
 		}
 	} else {
 		fh_lock(fhp);
-- 
1.6.0.4


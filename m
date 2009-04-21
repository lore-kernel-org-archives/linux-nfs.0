From: Al Viro <viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org>
Subject: [PATCH 2/5] nfsd struct path use: exp_get_by_name()
Date: Tue, 21 Apr 2009 21:43:41 +0000
Message-ID: <E1LwNkj-0004WP-BT@ZenIV.linux.org.uk>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:60958 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752867AbZDUVnm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Apr 2009 17:43:42 -0400
Received: from viro by ZenIV.linux.org.uk with local (Exim 4.69 #1 (Red Hat Linux))
	id 1LwNkj-0004WP-BT
	for linux-nfs@vger.kernel.org; Tue, 21 Apr 2009 21:43:41 +0000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 fs/nfsd/export.c |   38 ++++++++++++++++++--------------------
 1 files changed, 18 insertions(+), 20 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 5839b22..3f6d51b 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -847,9 +847,8 @@ exp_get_fsid_key(svc_client *clp, int fsid)
 	return exp_find_key(clp, FSID_NUM, fsidv, NULL);
 }
 
-static svc_export *exp_get_by_name(svc_client *clp, struct vfsmount *mnt,
-				   struct dentry *dentry,
-				   struct cache_req *reqp)
+static svc_export *exp_get_by_name(svc_client *clp, const struct path *path,
+				     struct cache_req *reqp)
 {
 	struct svc_export *exp, key;
 	int err;
@@ -858,8 +857,7 @@ static svc_export *exp_get_by_name(svc_client *clp, struct vfsmount *mnt,
 		return ERR_PTR(-ENOENT);
 
 	key.ex_client = clp;
-	key.ex_path.mnt = mnt;
-	key.ex_path.dentry = dentry;
+	key.ex_path = *path;
 
 	exp = svc_export_lookup(&key);
 	if (exp == NULL)
@@ -877,20 +875,19 @@ static struct svc_export *exp_parent(svc_client *clp, struct vfsmount *mnt,
 				     struct dentry *dentry,
 				     struct cache_req *reqp)
 {
+	struct path path = {.mnt = mnt, .dentry = dentry};
 	svc_export *exp;
 
-	dget(dentry);
-	exp = exp_get_by_name(clp, mnt, dentry, reqp);
-
-	while (PTR_ERR(exp) == -ENOENT && !IS_ROOT(dentry)) {
-		struct dentry *parent;
+	dget(path.dentry);
+	exp = exp_get_by_name(clp, &path, reqp);
 
-		parent = dget_parent(dentry);
-		dput(dentry);
-		dentry = parent;
-		exp = exp_get_by_name(clp, mnt, dentry, reqp);
+	while (PTR_ERR(exp) == -ENOENT && !IS_ROOT(path.dentry)) {
+		struct dentry *parent = dget_parent(path.dentry);
+		dput(path.dentry);
+		path.dentry = parent;
+		exp = exp_get_by_name(clp, &path, reqp);
 	}
-	dput(dentry);
+	dput(path.dentry);
 	return exp;
 }
 
@@ -1018,7 +1015,7 @@ exp_export(struct nfsctl_export *nxp)
 		goto out_put_clp;
 	err = -EINVAL;
 
-	exp = exp_get_by_name(clp, path.mnt, path.dentry, NULL);
+	exp = exp_get_by_name(clp, &path, NULL);
 
 	memset(&new, 0, sizeof(new));
 
@@ -1135,7 +1132,7 @@ exp_unexport(struct nfsctl_export *nxp)
 		goto out_domain;
 
 	err = -EINVAL;
-	exp = exp_get_by_name(dom, path.mnt, path.dentry, NULL);
+	exp = exp_get_by_name(dom, &path, NULL);
 	path_put(&path);
 	if (IS_ERR(exp))
 		goto out_domain;
@@ -1207,7 +1204,7 @@ static struct svc_export *exp_find(struct auth_domain *clp, int fsid_type,
 	if (IS_ERR(ek))
 		return ERR_CAST(ek);
 
-	exp = exp_get_by_name(clp, ek->ek_path.mnt, ek->ek_path.dentry, reqp);
+	exp = exp_get_by_name(clp, &ek->ek_path, reqp);
 	cache_put(&ek->h, &svc_expkey_cache);
 
 	if (IS_ERR(exp))
@@ -1251,12 +1248,13 @@ rqst_exp_get_by_name(struct svc_rqst *rqstp, struct vfsmount *mnt,
 		struct dentry *dentry)
 {
 	struct svc_export *gssexp, *exp = ERR_PTR(-ENOENT);
+	struct path path = {.mnt = mnt, .dentry = dentry};
 
 	if (rqstp->rq_client == NULL)
 		goto gss;
 
 	/* First try the auth_unix client: */
-	exp = exp_get_by_name(rqstp->rq_client, mnt, dentry,
+	exp = exp_get_by_name(rqstp->rq_client, &path,
 						&rqstp->rq_chandle);
 	if (PTR_ERR(exp) == -ENOENT)
 		goto gss;
@@ -1269,7 +1267,7 @@ gss:
 	/* Otherwise, try falling back on gss client */
 	if (rqstp->rq_gssclient == NULL)
 		return exp;
-	gssexp = exp_get_by_name(rqstp->rq_gssclient, mnt, dentry,
+	gssexp = exp_get_by_name(rqstp->rq_gssclient, &path,
 						&rqstp->rq_chandle);
 	if (PTR_ERR(gssexp) == -ENOENT)
 		return exp;
-- 
1.5.6.5



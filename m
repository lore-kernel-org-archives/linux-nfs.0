Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:46527 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752209Ab1H2Ssy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Aug 2011 14:48:54 -0400
Received: by iabu26 with SMTP id u26so731071iab.19
        for <linux-nfs@vger.kernel.org>; Mon, 29 Aug 2011 11:48:54 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/3] NFSD: Cleanup for nfsd4_path()
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 29 Aug 2011 14:48:51 -0400
Message-ID: <20110829184851.3305.54600.stgit@matisse.1015granger.net>
In-Reply-To: <20110829184608.3305.93648.stgit@matisse.1015granger.net>
References: <20110829184608.3305.93648.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Trond Myklebust <Trond.Myklebust@netapp.com>

The current code is sort of hackish in that it assumes a referral is always
matched to an export. When we add support for junctions that may not be the
case.
We can replace nfsd4_path() with a function that encodes the components
directly from the dentries. Since nfsd4_path is currently the only user of
the 'ex_pathname' field in struct svc_export, this has the added benefit
of allowing us to get rid of that.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfsd/export.c            |    4 +-
 fs/nfsd/nfs4xdr.c           |  106 ++++++++++++++++++++++++++++++++-----------
 include/linux/nfsd/export.h |    1 
 3 files changed, 81 insertions(+), 30 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index f4cc1e2..d9a6611 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -1010,7 +1010,7 @@ rqst_exp_parent(struct svc_rqst *rqstp, struct path *path)
 	return exp;
 }
 
-static struct svc_export *find_fsidzero_export(struct svc_rqst *rqstp)
+struct svc_export *rqst_find_fsidzero_export(struct svc_rqst *rqstp)
 {
 	u32 fsidv[2];
 
@@ -1030,7 +1030,7 @@ exp_pseudoroot(struct svc_rqst *rqstp, struct svc_fh *fhp)
 	struct svc_export *exp;
 	__be32 rv;
 
-	exp = find_fsidzero_export(rqstp);
+	exp = rqst_find_fsidzero_export(rqstp);
 	if (IS_ERR(exp))
 		return nfserrno(PTR_ERR(exp));
 	rv = fh_compose(fhp, exp, exp->ex_path.dentry, NULL);
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index c8bf405..f7b068e 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1697,36 +1697,89 @@ static __be32 nfsd4_encode_fs_location4(struct nfsd4_fs_location *location,
 }
 
 /*
- * Return the path to an export point in the pseudo filesystem namespace
- * Returned string is safe to use as long as the caller holds a reference
- * to @exp.
+ * Encode a path in RFC3530 'pathname4' format
  */
-static char *nfsd4_path(struct svc_rqst *rqstp, struct svc_export *exp, __be32 *stat)
+static __be32 nfsd4_encode_path(const struct path *root,
+		const struct path *path, __be32 **pp, int *buflen)
 {
-	struct svc_fh tmp_fh;
-	char *path = NULL, *rootpath;
-	size_t rootlen;
+	struct path cur = {
+		.mnt = path->mnt,
+		.dentry = path->dentry,
+	};
+	__be32 *p = *pp;
+	struct dentry **components = NULL;
+	unsigned int ncomponents = 0;
+	__be32 err = nfserr_resource;
 
-	fh_init(&tmp_fh, NFS4_FHSIZE);
-	*stat = exp_pseudoroot(rqstp, &tmp_fh);
-	if (*stat)
-		return NULL;
-	rootpath = tmp_fh.fh_export->ex_pathname;
+	dprintk("nfsd4_encode_components(");
 
-	path = exp->ex_pathname;
+	path_get(&cur);
+	/* First walk the path up to the nfsd root, and store the
+	 * dentries/path components in an array.
+	 */
+	for (;;) {
+		if (cur.dentry == root->dentry && cur.mnt == root->mnt)
+			break;
+		if (cur.dentry == cur.mnt->mnt_root) {
+			if (follow_up(&cur))
+				continue;
+			goto out_free;
+		}
+		if ((ncomponents & 15) == 0) {
+			struct dentry **new;
+			new = krealloc(components,
+					sizeof(*new) * (ncomponents + 16),
+					GFP_KERNEL);
+			if (!new)
+				goto out_free;
+			components = new;
+		}
+		components[ncomponents++] = cur.dentry;
+		cur.dentry = dget_parent(cur.dentry);
+	}
 
-	rootlen = strlen(rootpath);
-	if (strncmp(path, rootpath, rootlen)) {
-		dprintk("nfsd: fs_locations failed;"
-			"%s is not contained in %s\n", path, rootpath);
-		*stat = nfserr_notsupp;
-		path = NULL;
-		goto out;
+	*buflen -= 4;
+	if (*buflen < 0)
+		goto out_free;
+	WRITE32(ncomponents);
+
+	while (ncomponents) {
+		struct dentry *dentry = components[ncomponents - 1];
+		unsigned int len = dentry->d_name.len;
+
+		*buflen -= 4 + (XDR_QUADLEN(len) << 2);
+		if (*buflen < 0)
+			goto out_free;
+		WRITE32(len);
+		WRITEMEM(dentry->d_name.name, len);
+		dprintk("/%s", dentry->d_name.name);
+		dput(dentry);
+		ncomponents--;
 	}
-	path += rootlen;
-out:
-	fh_put(&tmp_fh);
-	return path;
+
+	*pp = p;
+	err = 0;
+out_free:
+	dprintk(")\n");
+	while (ncomponents)
+		dput(components[--ncomponents]);
+	kfree(components);
+	path_put(&cur);
+	return err;
+}
+
+static __be32 nfsd4_encode_fsloc_fsroot(struct svc_rqst *rqstp,
+		const struct path *path, __be32 **pp, int *buflen)
+{
+	struct svc_export *exp_ps;
+	__be32 res;
+
+	exp_ps = rqst_find_fsidzero_export(rqstp);
+	if (IS_ERR(exp_ps))
+		return nfserrno(PTR_ERR(exp_ps));
+	res = nfsd4_encode_path(&exp_ps->ex_path, path, pp, buflen);
+	exp_put(exp_ps);
+	return res;
 }
 
 /*
@@ -1740,11 +1793,8 @@ static __be32 nfsd4_encode_fs_locations(struct svc_rqst *rqstp,
 	int i;
 	__be32 *p = *pp;
 	struct nfsd4_fs_locations *fslocs = &exp->ex_fslocs;
-	char *root = nfsd4_path(rqstp, exp, &status);
 
-	if (status)
-		return status;
-	status = nfsd4_encode_components('/', root, &p, buflen);
+	status = nfsd4_encode_fsloc_fsroot(rqstp, &exp->ex_path, &p, buflen);
 	if (status)
 		return status;
 	if ((*buflen -= 4) < 0)
diff --git a/include/linux/nfsd/export.h b/include/linux/nfsd/export.h
index 8a31a20..7ba3fd4 100644
--- a/include/linux/nfsd/export.h
+++ b/include/linux/nfsd/export.h
@@ -137,6 +137,7 @@ struct svc_export *	rqst_exp_get_by_name(struct svc_rqst *,
 					     struct path *);
 struct svc_export *	rqst_exp_parent(struct svc_rqst *,
 					struct path *);
+struct svc_export *	rqst_find_fsidzero_export(struct svc_rqst *);
 int			exp_rootfh(struct auth_domain *, 
 					char *path, struct knfsd_fh *, int maxsize);
 __be32			exp_pseudoroot(struct svc_rqst *, struct svc_fh *);


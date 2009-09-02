From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: NFSd: Fix filehandle leaks in exp_pseudoroot() and nfsd4_path()
Date: Wed, 02 Sep 2009 16:48:32 -0400
Message-ID: <1251924512.26601.59.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: "Dr. J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:3470 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752604AbZIBUsq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Sep 2009 16:48:46 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFSd: Fix filehandle leaks in exp_pseudoroot() and nfsd4_path()

From: Trond Myklebust <Trond.Myklebust@netapp.com>

All the callers of exp_pseudoroot() appear to expect the filehandle it
returns to be uninitialised if the function returns an error. This is not
the case if the error is due to the check_nfsd_access() call failing.

In addition, nfsd4_path() currently allocates a temporary filehandle, then
fails to free it before the function exits.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
Note: this patch is still untested, but I can't see how it can
be wrong. The leak is obvious by code inspection, and doing an extra
fh_put() in the error case is obviously harmless.

Also note: there is apparently a similar leak in fh_compose() itself,
but I didn't want to spend the entire afternoon fixing all occurrences
of this bug...

 fs/nfsd/export.c  |    2 ++
 fs/nfsd/nfs4xdr.c |   15 ++++++++++-----
 2 files changed, 12 insertions(+), 5 deletions(-)


diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index d946264..984a5eb 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -1341,6 +1341,8 @@ exp_pseudoroot(struct svc_rqst *rqstp, struct svc_fh *fhp)
 	if (rv)
 		goto out;
 	rv = check_nfsd_access(exp, rqstp);
+	if (rv)
+		fh_put(fhp);
 out:
 	exp_put(exp);
 	return rv;
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 1b07183..370c27e 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1599,7 +1599,8 @@ static __be32 nfsd4_encode_fs_location4(struct nfsd4_fs_location *location,
 static char *nfsd4_path(struct svc_rqst *rqstp, struct svc_export *exp, __be32 *stat)
 {
 	struct svc_fh tmp_fh;
-	char *path, *rootpath;
+	char *path = NULL, *rootpath;
+	size_t rootlen;
 
 	fh_init(&tmp_fh, NFS4_FHSIZE);
 	*stat = exp_pseudoroot(rqstp, &tmp_fh);
@@ -1609,14 +1610,18 @@ static char *nfsd4_path(struct svc_rqst *rqstp, struct svc_export *exp, __be32 *
 
 	path = exp->ex_pathname;
 
-	if (strncmp(path, rootpath, strlen(rootpath))) {
+	rootlen = strlen(rootpath);
+	if (strncmp(path, rootpath, rootlen)) {
 		dprintk("nfsd: fs_locations failed;"
 			"%s is not contained in %s\n", path, rootpath);
 		*stat = nfserr_notsupp;
-		return NULL;
+		path = NULL;
+		goto out;
 	}
-
-	return path + strlen(rootpath);
+	path += rootlen;
+out:
+	fh_put(&tmp_fh);
+	return path;
 }
 
 /*

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

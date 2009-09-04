From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 3/6] NFSd: Fix filehandle leak in exp_pseudoroot() and nfsd4_path()
Date: Fri,  4 Sep 2009 15:47:03 -0400
Message-ID: <1252093626-5560-4-git-send-email-bfields@citi.umich.edu>
References: <1252093626-5560-1-git-send-email-bfields@citi.umich.edu>
 <1252093626-5560-2-git-send-email-bfields@citi.umich.edu>
 <1252093626-5560-3-git-send-email-bfields@citi.umich.edu>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:50174 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757300AbZIDTrE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Sep 2009 15:47:04 -0400
In-Reply-To: <1252093626-5560-3-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <Trond.Myklebust@netapp.com>

nfsd4_path() allocates a temporary filehandle and then fails to free it
before the function exits, leaking reference counts to the dentry and
export that it refers to.

Also, nfsd4_lookupp() puts the result of exp_pseudoroot() in a temporary
filehandle which it releases on success of exp_pseudoroot() but not on
failure; fix exp_pseudoroot to ensure that on failure it releases the
filehandle before returning.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
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
index 00ed16a..0fbd50c 100644
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
1.6.0.4


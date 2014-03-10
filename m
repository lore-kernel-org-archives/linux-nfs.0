Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga02.intel.com ([134.134.136.20]:50359 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751975AbaCJJHD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Mar 2014 05:07:03 -0400
From: "Yan, Zheng" <zheng.z.yan@intel.com>
To: linux-nfs@vger.kernel.org
Cc: bfields@fieldses.org, hch@infradead.org,
        "Yan, Zheng" <zheng.z.yan@intel.com>
Subject: [PATCH v2] nfsd4: fix memory leak in nfsd4_encode_fattr()
Date: Mon, 10 Mar 2014 17:06:23 +0800
Message-Id: <1394442383-19551-1-git-send-email-zheng.z.yan@intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The temporary file handle should be freed when nfsd4_encode_fattr()
finishes its job. Christoph Hellwig suggests to move the code that
generates the temporary file handle into nfsd4_encode_dirent_fattr()

Signed-off-by: Yan, Zheng <zheng.z.yan@intel.com>
---
 fs/nfsd/nfs4xdr.c | 30 ++++++++++++++++--------------
 1 file changed, 16 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 63f2395..c4bd284 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2058,7 +2058,6 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
 	u32 bmval1 = bmval[1];
 	u32 bmval2 = bmval[2];
 	struct kstat stat;
-	struct svc_fh *tempfh = NULL;
 	struct kstatfs statfs;
 	int buflen = count << 2;
 	__be32 *attrlenp;
@@ -2104,17 +2103,6 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
 		if (err)
 			goto out_nfserr;
 	}
-	if ((bmval0 & (FATTR4_WORD0_FILEHANDLE | FATTR4_WORD0_FSID)) && !fhp) {
-		tempfh = kmalloc(sizeof(struct svc_fh), GFP_KERNEL);
-		status = nfserr_jukebox;
-		if (!tempfh)
-			goto out;
-		fh_init(tempfh, NFS4_FHSIZE);
-		status = fh_compose(tempfh, exp, dentry, NULL);
-		if (status)
-			goto out;
-		fhp = tempfh;
-	}
 	if (bmval0 & (FATTR4_WORD0_ACL | FATTR4_WORD0_ACLSUPPORT
 			| FATTR4_WORD0_SUPPORTED_ATTRS)) {
 		err = nfsd4_get_nfs4_acl(rqstp, dentry, &acl);
@@ -2499,8 +2487,6 @@ out:
 		security_release_secctx(context, contextlen);
 #endif /* CONFIG_NFSD_V4_SECURITY_LABEL */
 	kfree(acl);
-	if (tempfh)
-		fh_put(tempfh);
 	return status;
 out_nfserr:
 	status = nfserrno(err);
@@ -2524,6 +2510,7 @@ nfsd4_encode_dirent_fattr(struct nfsd4_readdir *cd,
 		const char *name, int namlen, __be32 **p, int buflen)
 {
 	struct svc_export *exp = cd->rd_fhp->fh_export;
+	struct svc_fh *tempfh = NULL;
 	struct dentry *dentry;
 	__be32 nfserr;
 	int ignore_crossmnt = 0;
@@ -2573,9 +2560,24 @@ nfsd4_encode_dirent_fattr(struct nfsd4_readdir *cd,
 
 	}
 out_encode:
+	if ((cd->rd_bmval[0] & (FATTR4_WORD0_FILEHANDLE | FATTR4_WORD0_FSID))) {
+		tempfh = kmalloc(sizeof(struct svc_fh), GFP_KERNEL);
+		if (!tempfh) {
+			nfserr = nfserr_jukebox;
+			goto out_put;
+		}
+		fh_init(tempfh, NFS4_FHSIZE);
+		nfserr = fh_compose(tempfh, exp, dentry, NULL);
+		if (nfserr)
+			goto out_put;
+	}
 	nfserr = nfsd4_encode_fattr(NULL, exp, dentry, p, buflen, cd->rd_bmval,
 					cd->rd_rqstp, ignore_crossmnt);
 out_put:
+	if (tempfh) {
+		fh_put(tempfh);
+		kfree(tempfh);
+	}
 	dput(dentry);
 	exp_put(exp);
 	return nfserr;
-- 
1.8.5.3


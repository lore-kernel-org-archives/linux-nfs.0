Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49257 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423034Ab3BANPj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Feb 2013 08:15:39 -0500
Date: Fri, 1 Feb 2013 08:15:37 -0500
To: linux-nfs@vger.kernel.org
Cc: Al Viro <viro@zeniv.linux.org.uk>
Subject: [PATCH] nfsd: handle vfs_getattr errors in acl protocol
Message-ID: <20130201131537.GC30668@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

We're currently ignoring errors from vfs_getattr.

The correct thing to do is to do the stat in the main service procedure
not in the response encoding.

Reported-by: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs2acl.c |   31 +++++++++++++++++++++++++++----
 fs/nfsd/nfsxdr.c  |    6 ++----
 fs/nfsd/xdr.h     |    2 +-
 fs/nfsd/xdr3.h    |    2 ++
 4 files changed, 32 insertions(+), 9 deletions(-)

For 3.9.

diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
index 9170861..b99864b 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -24,6 +24,14 @@ nfsacld_proc_null(struct svc_rqst *rqstp, void *argp, void *resp)
 	return nfs_ok;
 }
 
+static __be32 nfsd_getattr(struct svc_fh *fh, struct kstat *stat)
+{
+	int err;
+
+	err = vfs_getattr(fh->fh_export->ex_path.mnt, fh->fh_dentry, stat);
+	return nfserrno(err);
+}
+
 /*
  * Get the Access and/or Default ACL of a file.
  */
@@ -45,6 +53,10 @@ static __be32 nfsacld_proc_getacl(struct svc_rqst * rqstp,
 		RETURN_STATUS(nfserr_inval);
 	resp->mask = argp->mask;
 
+	nfserr = nfsd_getattr(fh, &resp->stat);
+	if (nfserr)
+		goto fail;
+
 	if (resp->mask & (NFS_ACL|NFS_ACLCNT)) {
 		acl = nfsd_get_posix_acl(fh, ACL_TYPE_ACCESS);
 		if (IS_ERR(acl)) {
@@ -115,6 +127,9 @@ static __be32 nfsacld_proc_setacl(struct svc_rqst * rqstp,
 		nfserr = nfserrno( nfsd_set_posix_acl(
 			fh, ACL_TYPE_DEFAULT, argp->acl_default) );
 	}
+	if (!nfserr) {
+		nfserr = nfsd_getattr(fh, &resp->stat);
+	}
 
 	/* argp->acl_{access,default} may have been allocated in
 	   nfssvc_decode_setaclargs. */
@@ -129,10 +144,15 @@ static __be32 nfsacld_proc_setacl(struct svc_rqst * rqstp,
 static __be32 nfsacld_proc_getattr(struct svc_rqst * rqstp,
 		struct nfsd_fhandle *argp, struct nfsd_attrstat *resp)
 {
+	__be32 nfserr;
 	dprintk("nfsd: GETATTR  %s\n", SVCFH_fmt(&argp->fh));
 
 	fh_copy(&resp->fh, &argp->fh);
-	return fh_verify(rqstp, &resp->fh, 0, NFSD_MAY_NOP);
+	nfserr = fh_verify(rqstp, &resp->fh, 0, NFSD_MAY_NOP);
+	if (nfserr)
+		return nfserr;
+	nfserr = nfsd_getattr(&resp->fh, &resp->stat);
+	return nfserr;
 }
 
 /*
@@ -150,6 +170,9 @@ static __be32 nfsacld_proc_access(struct svc_rqst *rqstp, struct nfsd3_accessarg
 	fh_copy(&resp->fh, &argp->fh);
 	resp->access = argp->access;
 	nfserr = nfsd_access(rqstp, &resp->fh, &resp->access, NULL);
+	if (nfserr)
+		return nfserr;
+	nfserr = nfsd_getattr(&resp->fh, &resp->stat);
 	return nfserr;
 }
 
@@ -243,7 +266,7 @@ static int nfsaclsvc_encode_getaclres(struct svc_rqst *rqstp, __be32 *p,
 		return 0;
 	inode = dentry->d_inode;
 
-	p = nfs2svc_encode_fattr(rqstp, p, &resp->fh);
+	p = nfs2svc_encode_fattr(rqstp, p, &resp->fh, &resp->stat);
 	*p++ = htonl(resp->mask);
 	if (!xdr_ressize_check(rqstp, p))
 		return 0;
@@ -274,7 +297,7 @@ static int nfsaclsvc_encode_getaclres(struct svc_rqst *rqstp, __be32 *p,
 static int nfsaclsvc_encode_attrstatres(struct svc_rqst *rqstp, __be32 *p,
 		struct nfsd_attrstat *resp)
 {
-	p = nfs2svc_encode_fattr(rqstp, p, &resp->fh);
+	p = nfs2svc_encode_fattr(rqstp, p, &resp->fh, &resp->stat);
 	return xdr_ressize_check(rqstp, p);
 }
 
@@ -282,7 +305,7 @@ static int nfsaclsvc_encode_attrstatres(struct svc_rqst *rqstp, __be32 *p,
 static int nfsaclsvc_encode_accessres(struct svc_rqst *rqstp, __be32 *p,
 		struct nfsd3_accessres *resp)
 {
-	p = nfs2svc_encode_fattr(rqstp, p, &resp->fh);
+	p = nfs2svc_encode_fattr(rqstp, p, &resp->fh, &resp->stat);
 	*p++ = htonl(resp->access);
 	return xdr_ressize_check(rqstp, p);
 }
diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
index 979b421..90f47fe 100644
--- a/fs/nfsd/nfsxdr.c
+++ b/fs/nfsd/nfsxdr.c
@@ -194,11 +194,9 @@ encode_fattr(struct svc_rqst *rqstp, __be32 *p, struct svc_fh *fhp,
 }
 
 /* Helper function for NFSv2 ACL code */
-__be32 *nfs2svc_encode_fattr(struct svc_rqst *rqstp, __be32 *p, struct svc_fh *fhp)
+__be32 *nfs2svc_encode_fattr(struct svc_rqst *rqstp, __be32 *p, struct svc_fh *fhp, struct kstat *stat)
 {
-	struct kstat stat;
-	vfs_getattr(fhp->fh_export->ex_path.mnt, fhp->fh_dentry, &stat);
-	return encode_fattr(rqstp, p, fhp, &stat);
+	return encode_fattr(rqstp, p, fhp, stat);
 }
 
 /*
diff --git a/fs/nfsd/xdr.h b/fs/nfsd/xdr.h
index 53b1863..4f0481d 100644
--- a/fs/nfsd/xdr.h
+++ b/fs/nfsd/xdr.h
@@ -167,7 +167,7 @@ int nfssvc_encode_entry(void *, const char *name,
 int nfssvc_release_fhandle(struct svc_rqst *, __be32 *, struct nfsd_fhandle *);
 
 /* Helper functions for NFSv2 ACL code */
-__be32 *nfs2svc_encode_fattr(struct svc_rqst *rqstp, __be32 *p, struct svc_fh *fhp);
+__be32 *nfs2svc_encode_fattr(struct svc_rqst *rqstp, __be32 *p, struct svc_fh *fhp, struct kstat *stat);
 __be32 *nfs2svc_decode_fh(__be32 *p, struct svc_fh *fhp);
 
 #endif /* LINUX_NFSD_H */
diff --git a/fs/nfsd/xdr3.h b/fs/nfsd/xdr3.h
index 7df980e..b6d5542 100644
--- a/fs/nfsd/xdr3.h
+++ b/fs/nfsd/xdr3.h
@@ -136,6 +136,7 @@ struct nfsd3_accessres {
 	__be32			status;
 	struct svc_fh		fh;
 	__u32			access;
+	struct kstat		stat;
 };
 
 struct nfsd3_readlinkres {
@@ -225,6 +226,7 @@ struct nfsd3_getaclres {
 	int			mask;
 	struct posix_acl	*acl_access;
 	struct posix_acl	*acl_default;
+	struct kstat		stat;
 };
 
 /* dummy type for release */
-- 
1.7.9.5


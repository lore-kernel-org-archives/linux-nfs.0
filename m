Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49050 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756800Ab3BAUNG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Feb 2013 15:13:06 -0500
Date: Fri, 1 Feb 2013 15:13:04 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: handle vfs_getattr errors in acl protocol
Message-ID: <20130201201304.GE30668@fieldses.org>
References: <20130201131537.GC30668@fieldses.org>
 <20130201185721.GP4503@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130201185721.GP4503@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 01, 2013 at 06:57:22PM +0000, Al Viro wrote:
> On Fri, Feb 01, 2013 at 08:15:37AM -0500, J. Bruce Fields wrote:
> > From: "J. Bruce Fields" <bfields@redhat.com>
> > 
> > We're currently ignoring errors from vfs_getattr.
> > 
> > The correct thing to do is to do the stat in the main service procedure
> > not in the response encoding.
> 
> FWIW, I'd combine that with parts of commit I've got in my tree; I think
> nfsd_getattr() in your variant isn't the best API here.  All callers
> that want nfserrno want vfsmount/dentry coming from some fhandle.  Diff
> below is introducing such helper and switching to its use (warning: edited
> patch; only obvious editing done there, but still).  It does *not* address
> the issue your patch deals with (see /* BUG */ in there), but I really
> think it's a better interface than your variant.

Actually, we have precisely the same interface except for the name:

	__be32 fh_getattr(struct svc_fh *fh, struct kstat *stat)
vs.
	__be32 nfsd_getattr(struct svc_fh *fh, struct kstat *stat)

but I'm fine with your name.

Do you want to take these patches, or should I?

Assuming the latter: this is a version of my bugfix rebased on top of
what you just sent me.  I did a quick test and verified it doesn't crash
when I asked for an acl....

--b.

commit 7afea2b2cd951c3a566356206d84a0f5b8aa0e1a
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Wed Jan 30 16:10:19 2013 -0500

    nfsd: handle vfs_getattr errors in acl protocol
    
    We're currently ignoring errors from vfs_getattr.
    
    The correct thing to do is to do the stat in the main service procedure
    not in the response encoding.
    
    Reported-by: Al Viro <viro@zeniv.linux.org.uk>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
index 9170861..95d76dc 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -45,6 +45,10 @@ static __be32 nfsacld_proc_getacl(struct svc_rqst * rqstp,
 		RETURN_STATUS(nfserr_inval);
 	resp->mask = argp->mask;
 
+	nfserr = fh_getattr(fh, &resp->stat);
+	if (nfserr)
+		goto fail;
+
 	if (resp->mask & (NFS_ACL|NFS_ACLCNT)) {
 		acl = nfsd_get_posix_acl(fh, ACL_TYPE_ACCESS);
 		if (IS_ERR(acl)) {
@@ -115,6 +119,9 @@ static __be32 nfsacld_proc_setacl(struct svc_rqst * rqstp,
 		nfserr = nfserrno( nfsd_set_posix_acl(
 			fh, ACL_TYPE_DEFAULT, argp->acl_default) );
 	}
+	if (!nfserr) {
+		nfserr = fh_getattr(fh, &resp->stat);
+	}
 
 	/* argp->acl_{access,default} may have been allocated in
 	   nfssvc_decode_setaclargs. */
@@ -129,10 +136,15 @@ static __be32 nfsacld_proc_setacl(struct svc_rqst * rqstp,
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
+	nfserr = fh_getattr(&resp->fh, &resp->stat);
+	return nfserr;
 }
 
 /*
@@ -150,6 +162,9 @@ static __be32 nfsacld_proc_access(struct svc_rqst *rqstp, struct nfsd3_accessarg
 	fh_copy(&resp->fh, &argp->fh);
 	resp->access = argp->access;
 	nfserr = nfsd_access(rqstp, &resp->fh, &resp->access, NULL);
+	if (nfserr)
+		return nfserr;
+	nfserr = fh_getattr(&resp->fh, &resp->stat);
 	return nfserr;
 }
 
@@ -243,7 +258,7 @@ static int nfsaclsvc_encode_getaclres(struct svc_rqst *rqstp, __be32 *p,
 		return 0;
 	inode = dentry->d_inode;
 
-	p = nfs2svc_encode_fattr(rqstp, p, &resp->fh);
+	p = nfs2svc_encode_fattr(rqstp, p, &resp->fh, &resp->stat);
 	*p++ = htonl(resp->mask);
 	if (!xdr_ressize_check(rqstp, p))
 		return 0;
@@ -274,7 +289,7 @@ static int nfsaclsvc_encode_getaclres(struct svc_rqst *rqstp, __be32 *p,
 static int nfsaclsvc_encode_attrstatres(struct svc_rqst *rqstp, __be32 *p,
 		struct nfsd_attrstat *resp)
 {
-	p = nfs2svc_encode_fattr(rqstp, p, &resp->fh);
+	p = nfs2svc_encode_fattr(rqstp, p, &resp->fh, &resp->stat);
 	return xdr_ressize_check(rqstp, p);
 }
 
@@ -282,7 +297,7 @@ static int nfsaclsvc_encode_attrstatres(struct svc_rqst *rqstp, __be32 *p,
 static int nfsaclsvc_encode_accessres(struct svc_rqst *rqstp, __be32 *p,
 		struct nfsd3_accessres *resp)
 {
-	p = nfs2svc_encode_fattr(rqstp, p, &resp->fh);
+	p = nfs2svc_encode_fattr(rqstp, p, &resp->fh, &resp->stat);
 	*p++ = htonl(resp->access);
 	return xdr_ressize_check(rqstp, p);
 }
diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
index bf6d3bc..96e5619 100644
--- a/fs/nfsd/nfsxdr.c
+++ b/fs/nfsd/nfsxdr.c
@@ -195,11 +195,9 @@ encode_fattr(struct svc_rqst *rqstp, __be32 *p, struct svc_fh *fhp,
 }
 
 /* Helper function for NFSv2 ACL code */
-__be32 *nfs2svc_encode_fattr(struct svc_rqst *rqstp, __be32 *p, struct svc_fh *fhp)
+__be32 *nfs2svc_encode_fattr(struct svc_rqst *rqstp, __be32 *p, struct svc_fh *fhp, struct kstat *stat)
 {
-	struct kstat stat;
-	fh_getattr(fhp, &stat);	/* BUG */
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

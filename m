Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:51546 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752921Ab3BAS5X (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Feb 2013 13:57:23 -0500
Date: Fri, 1 Feb 2013 18:57:22 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: handle vfs_getattr errors in acl protocol
Message-ID: <20130201185721.GP4503@ZenIV.linux.org.uk>
References: <20130201131537.GC30668@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130201131537.GC30668@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 01, 2013 at 08:15:37AM -0500, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> We're currently ignoring errors from vfs_getattr.
> 
> The correct thing to do is to do the stat in the main service procedure
> not in the response encoding.

FWIW, I'd combine that with parts of commit I've got in my tree; I think
nfsd_getattr() in your variant isn't the best API here.  All callers
that want nfserrno want vfsmount/dentry coming from some fhandle.  Diff
below is introducing such helper and switching to its use (warning: edited
patch; only obvious editing done there, but still).  It does *not* address
the issue your patch deals with (see /* BUG */ in there), but I really
think it's a better interface than your variant.  FWIW, the rest of the
commit in question is switching vfs_getattr() to struct path *; I'd
edited those parts out of the diff below.  Comments?

new helper: fh_getattr

A bunch of places in nfsd want vfs_getattr() done on object an fhandle
refers to, with nfs-encoded error (__be32).  fh_getattr(fh, stat) does
just that; open-coded instances switched to it.
 
Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 1fc02df..4012899 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -43,7 +43,6 @@ static __be32
 nfsd3_proc_getattr(struct svc_rqst *rqstp, struct nfsd_fhandle  *argp,
 					   struct nfsd3_attrstat *resp)
 {
-	int	err;
 	__be32	nfserr;
 
 	dprintk("nfsd: GETATTR(3)  %s\n",
@@ -55,9 +54,7 @@ nfsd3_proc_getattr(struct svc_rqst *rqstp, struct nfsd_fhandle  *argp,
 	if (nfserr)
 		RETURN_STATUS(nfserr);
 
-	err = vfs_getattr(resp->fh.fh_export->ex_path.mnt,
-			  resp->fh.fh_dentry, &resp->stat);
-	nfserr = nfserrno(err);
+	nfserr = fh_getattr(&resp->fh, &resp->stat);
 
 	RETURN_STATUS(nfserr);
 }
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index 324c0ba..7af9417b 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -11,6 +11,7 @@
 #include "xdr3.h"
 #include "auth.h"
 #include "netns.h"
+#include "vfs.h"
 
 #define NFSDDBG_FACILITY		NFSDDBG_XDR
 
@@ -204,10 +205,10 @@ encode_post_op_attr(struct svc_rqst *rqstp, __be32 *p, struct svc_fh *fhp)
 {
 	struct dentry *dentry = fhp->fh_dentry;
 	if (dentry && dentry->d_inode) {
-	        int err;
+	        __be32 err;
 		struct kstat stat;
 
-		err = vfs_getattr(fhp->fh_export->ex_path.mnt, dentry, &stat);
+		err = fh_getattr(fhp, &stat);
 		if (!err) {
 			*p++ = xdr_one;		/* attributes follow */
 			lease_get_mtime(dentry->d_inode, &stat.mtime);
@@ -254,13 +255,12 @@ encode_wcc_data(struct svc_rqst *rqstp, __be32 *p, struct svc_fh *fhp)
  */
 void fill_post_wcc(struct svc_fh *fhp)
 {
-	int err;
+	__be32 err;
 
 	if (fhp->fh_post_saved)
 		printk("nfsd: inode locked twice during operation.\n");
 
-	err = vfs_getattr(fhp->fh_export->ex_path.mnt, fhp->fh_dentry,
-			&fhp->fh_post_attr);
+	err = fh_getattr(fhp, &fhp->fh_post_attr);
 	fhp->fh_post_change = fhp->fh_dentry->d_inode->i_version;
 	if (err) {
 		fhp->fh_post_saved = 0;
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index aad6d45..54c6b3d 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -26,17 +26,13 @@ static __be32
 nfsd_return_attrs(__be32 err, struct nfsd_attrstat *resp)
 {
 	if (err) return err;
-	return nfserrno(vfs_getattr(resp->fh.fh_export->ex_path.mnt,
-				    resp->fh.fh_dentry,
-				    &resp->stat));
+	return fh_getattr(&resp->fh, &resp->stat);
 }
 static __be32
 nfsd_return_dirop(__be32 err, struct nfsd_diropres *resp)
 {
 	if (err) return err;
-	return nfserrno(vfs_getattr(resp->fh.fh_export->ex_path.mnt,
-				    resp->fh.fh_dentry,
-				    &resp->stat));
+	return fh_getattr(&resp->fh, &resp->stat);
 }
 /*
  * Get a file's attributes
@@ -150,9 +146,7 @@ nfsd_proc_read(struct svc_rqst *rqstp, struct nfsd_readargs *argp,
 				  &resp->count);
 
 	if (nfserr) return nfserr;
-	return nfserrno(vfs_getattr(resp->fh.fh_export->ex_path.mnt,
-				    resp->fh.fh_dentry,
-				    &resp->stat));
+	return fh_getattr(&resp->fh, &resp->stat);
 }
 
 /*
diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
index 979b421..bf6d3bc 100644
--- a/fs/nfsd/nfsxdr.c
+++ b/fs/nfsd/nfsxdr.c
@@ -4,6 +4,7 @@
  * Copyright (C) 1995, 1996 Olaf Kirch <okir@monad.swb.de>
  */
 
+#include "vfs.h"
 #include "xdr.h"
 #include "auth.h"
 
@@ -197,7 +198,7 @@ encode_fattr(struct svc_rqst *rqstp, __be32 *p, struct svc_fh *fhp,
 __be32 *nfs2svc_encode_fattr(struct svc_rqst *rqstp, __be32 *p, struct svc_fh *fhp)
 {
 	struct kstat stat;
-	vfs_getattr(fhp->fh_export->ex_path.mnt, fhp->fh_dentry, &stat);
+	fh_getattr(fhp, &stat);	/* BUG */
 	return encode_fattr(rqstp, p, fhp, &stat);
 }
 
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index 359594c..5b58941 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -6,6 +6,7 @@
 #define LINUX_NFSD_VFS_H
 
 #include "nfsfh.h"
+#include "nfsd.h"
 
 /*
  * Flags for nfsd_permission
@@ -125,4 +126,11 @@ static inline void fh_drop_write(struct svc_fh *fh)
 	}
 }
 
+static inline __be32 fh_getattr(struct svc_fh *fh, struct kstat *stat)
+{
+	return nfserrno(vfs_getattr(fh->fh_export->ex_path.mnt,
+				    fh->fh_dentry,
+				    stat));
+}
+
 #endif /* LINUX_NFSD_VFS_H */

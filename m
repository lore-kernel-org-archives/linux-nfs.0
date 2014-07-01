Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f176.google.com ([209.85.192.176]:54666 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753256AbaGAJsy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Jul 2014 05:48:54 -0400
Received: by mail-pd0-f176.google.com with SMTP id ft15so9846764pdb.21
        for <linux-nfs@vger.kernel.org>; Tue, 01 Jul 2014 02:48:53 -0700 (PDT)
Message-ID: <53B283D2.3040902@gmail.com>
Date: Tue, 01 Jul 2014 17:48:02 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, kinglongmee@gmail.com
Subject: [PATCH] NFSD: Remove iattr parameter from nfsd_symlink()
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit db2e747b1499 (vfs: remove mode parameter from vfs_symlink())
have remove mode parameter from vfs_symlink.
So that, iattr isn't needed by nfsd_symlink now, just remove it.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs3proc.c | 3 +--
 fs/nfsd/nfs4proc.c | 3 +--
 fs/nfsd/nfsproc.c  | 4 +---
 fs/nfsd/vfs.c      | 3 +--
 fs/nfsd/vfs.h      | 2 +-
 5 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index f2209aa..6714081 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -281,8 +281,7 @@ nfsd3_proc_symlink(struct svc_rqst *rqstp, struct nfsd3_symlinkargs *argp,
 	fh_copy(&resp->dirfh, &argp->ffh);
 	fh_init(&resp->fh, NFS3_FHSIZE);
 	nfserr = nfsd_symlink(rqstp, &resp->dirfh, argp->fname, argp->flen,
-						   argp->tname,
-						   &resp->fh, &argp->attrs);
+						   argp->tname, &resp->fh);
 	RETURN_STATUS(nfserr);
 }
 
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index e3b7cc9..846fd55 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -632,8 +632,7 @@ nfsd4_create(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	case NF4LNK:
 		status = nfsd_symlink(rqstp, &cstate->current_fh,
 				      create->cr_name, create->cr_namelen,
-				      create->cr_data,
-				      &resfh, &create->cr_iattr);
+				      create->cr_data, &resfh);
 		break;
 
 	case NF4BLK:
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 5343e29..c0fc465 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -407,9 +407,7 @@ nfsd_proc_symlink(struct svc_rqst *rqstp, struct nfsd_symlinkargs *argp,
 	 */
 	argp->tname[argp->tlen] = '\0';
 	nfserr = nfsd_symlink(rqstp, &argp->ffh, argp->fname, argp->flen,
-						 argp->tname,
-				 		 &newfh, &argp->attrs);
-
+						 argp->tname, &newfh);
 
 	fh_put(&argp->ffh);
 	fh_put(&newfh);
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index b94c9c5..654adad 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1491,8 +1491,7 @@ __be32
 nfsd_symlink(struct svc_rqst *rqstp, struct svc_fh *fhp,
 				char *fname, int flen,
 				char *path,
-				struct svc_fh *resfhp,
-				struct iattr *iap)
+				struct svc_fh *resfhp)
 {
 	struct dentry	*dentry, *dnew;
 	__be32		err, cerr;
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index 20e4b66..c2ff3f1 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -86,7 +86,7 @@ __be32		nfsd_readlink(struct svc_rqst *, struct svc_fh *,
 				char *, int *);
 __be32		nfsd_symlink(struct svc_rqst *, struct svc_fh *,
 				char *name, int len, char *path,
-				struct svc_fh *res, struct iattr *);
+				struct svc_fh *res);
 __be32		nfsd_link(struct svc_rqst *, struct svc_fh *,
 				char *, int, struct svc_fh *);
 __be32		nfsd_rename(struct svc_rqst *,
-- 
1.9.3


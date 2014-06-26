Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46904 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755341AbaFZBsN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Jun 2014 21:48:13 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trondmy@gmail.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/8] nfsd: let nfsd_symlink assume null-terminated data
Date: Wed, 25 Jun 2014 21:48:03 -0400
Message-Id: <1403747288-21590-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1403747288-21590-1-git-send-email-bfields@redhat.com>
References: <20140624204418.GG2343@pad.redhat.com>
 <1403747288-21590-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Currently nfsd_symlink has a weird hack to serve callers who don't
null-terminate symlink data: it looks ahead at the next byte to see if
it's zero, and copies it to a new buffer to null-terminate if not.

That means callers don't have to null-terminate, but they *do* have to
ensure that the byte following the end of the data is theirs to read.

That's a bit subtle, and the NFSv4 code actually got this wrong.

So let's just throw out that code and let callers pass null-terminated
strings; we've already fixed them to do that.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs3proc.c |    2 +-
 fs/nfsd/nfs4proc.c |    2 +-
 fs/nfsd/nfsproc.c  |    2 +-
 fs/nfsd/vfs.c      |   17 +++--------------
 fs/nfsd/vfs.h      |    2 +-
 5 files changed, 7 insertions(+), 18 deletions(-)

diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 61ef42c..19ba233 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -282,7 +282,7 @@ nfsd3_proc_symlink(struct svc_rqst *rqstp, struct nfsd3_symlinkargs *argp,
 	fh_copy(&resp->dirfh, &argp->ffh);
 	fh_init(&resp->fh, NFS3_FHSIZE);
 	nfserr = nfsd_symlink(rqstp, &resp->dirfh, argp->fname, argp->flen,
-						   argp->tname, argp->tlen,
+						   argp->tname,
 						   &resp->fh, &argp->attrs);
 	RETURN_STATUS(nfserr);
 }
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 2b3795a..7aa83bf 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -623,7 +623,7 @@ nfsd4_create(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	case NF4LNK:
 		status = nfsd_symlink(rqstp, &cstate->current_fh,
 				      create->cr_name, create->cr_namelen,
-				      create->cr_linkname, create->cr_linklen,
+				      create->cr_linkname,
 				      &resfh, &create->cr_iattr);
 		break;
 
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index aebe23c..583ed03 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -409,7 +409,7 @@ nfsd_proc_symlink(struct svc_rqst *rqstp, struct nfsd_symlinkargs *argp,
 	 */
 	argp->tname[argp->tlen] = '\0';
 	nfserr = nfsd_symlink(rqstp, &argp->ffh, argp->fname, argp->flen,
-						 argp->tname, argp->tlen,
+						 argp->tname,
 				 		 &newfh, &argp->attrs);
 
 
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 6ffaa70..7518c65 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1504,7 +1504,7 @@ out_nfserr:
 __be32
 nfsd_symlink(struct svc_rqst *rqstp, struct svc_fh *fhp,
 				char *fname, int flen,
-				char *path,  int plen,
+				char *path,
 				struct svc_fh *resfhp,
 				struct iattr *iap)
 {
@@ -1513,7 +1513,7 @@ nfsd_symlink(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	int		host_err;
 
 	err = nfserr_noent;
-	if (!flen || !plen)
+	if (!flen || path[0] == '\0')
 		goto out;
 	err = nfserr_exist;
 	if (isdotent(fname, flen))
@@ -1534,18 +1534,7 @@ nfsd_symlink(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if (IS_ERR(dnew))
 		goto out_nfserr;
 
-	if (unlikely(path[plen] != 0)) {
-		char *path_alloced = kmalloc(plen+1, GFP_KERNEL);
-		if (path_alloced == NULL)
-			host_err = -ENOMEM;
-		else {
-			strncpy(path_alloced, path, plen);
-			path_alloced[plen] = 0;
-			host_err = vfs_symlink(dentry->d_inode, dnew, path_alloced);
-			kfree(path_alloced);
-		}
-	} else
-		host_err = vfs_symlink(dentry->d_inode, dnew, path);
+	host_err = vfs_symlink(dentry->d_inode, dnew, path);
 	err = nfserrno(host_err);
 	if (!err)
 		err = nfserrno(commit_metadata(fhp));
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index b84aef5..20e4b66 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -85,7 +85,7 @@ __be32 		nfsd_write(struct svc_rqst *, struct svc_fh *,struct file *,
 __be32		nfsd_readlink(struct svc_rqst *, struct svc_fh *,
 				char *, int *);
 __be32		nfsd_symlink(struct svc_rqst *, struct svc_fh *,
-				char *name, int len, char *path, int plen,
+				char *name, int len, char *path,
 				struct svc_fh *res, struct iattr *);
 __be32		nfsd_link(struct svc_rqst *, struct svc_fh *,
 				char *, int, struct svc_fh *);
-- 
1.7.9.5


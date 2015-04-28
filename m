Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:39881 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030395AbbD1Nmp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Apr 2015 09:42:45 -0400
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 6/6] nfsd: drop the file argument to nfsd_write
Date: Tue, 28 Apr 2015 15:41:20 +0200
Message-Id: <1430228480-7656-7-git-send-email-hch@lst.de>
In-Reply-To: <1430228480-7656-1-git-send-email-hch@lst.de>
References: <1430228480-7656-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

All remaining callers of nfsd_write will never pass a file argument, so
remove it and the associated code.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs3proc.c |  2 +-
 fs/nfsd/nfsproc.c  |  2 +-
 fs/nfsd/vfs.c      | 32 +++++++++++---------------------
 fs/nfsd/vfs.h      |  5 +++--
 4 files changed, 16 insertions(+), 25 deletions(-)

diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 7b755b7..4e46ac5 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -192,7 +192,7 @@ nfsd3_proc_write(struct svc_rqst *rqstp, struct nfsd3_writeargs *argp,
 
 	fh_copy(&resp->fh, &argp->fh);
 	resp->committed = argp->stable;
-	nfserr = nfsd_write(rqstp, &resp->fh, NULL,
+	nfserr = nfsd_write(rqstp, &resp->fh,
 				   argp->offset,
 				   rqstp->rq_vec, argp->vlen,
 				   &cnt,
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index aecbcd3..83100b5 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -165,7 +165,7 @@ nfsd_proc_write(struct svc_rqst *rqstp, struct nfsd_writeargs *argp,
 		SVCFH_fmt(&argp->fh),
 		argp->len, argp->offset);
 
-	nfserr = nfsd_write(rqstp, fh_copy(&resp->fh, &argp->fh), NULL,
+	nfserr = nfsd_write(rqstp, fh_copy(&resp->fh, &argp->fh),
 				   argp->offset,
 				   rqstp->rq_vec, argp->vlen,
 			           &cnt,
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 2418419..b8a0a3b 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1038,30 +1038,20 @@ __be32 nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
  * N.B. After this call fhp needs an fh_put
  */
 __be32
-nfsd_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
-		loff_t offset, struct kvec *vec, int vlen, unsigned long *cnt,
-		int *stablep)
+nfsd_write(struct svc_rqst *rqstp, struct svc_fh *fhp, loff_t offset,
+		struct kvec *vec, int vlen, unsigned long *cnt, int *stablep)
 {
-	__be32			err = 0;
+	struct file		*file;
+	__be32			err;
 
-	if (file) {
-		err = nfsd_permission(rqstp, fhp->fh_export, fhp->fh_dentry,
-				NFSD_MAY_WRITE|NFSD_MAY_OWNER_OVERRIDE);
-		if (err)
-			goto out;
-		err = nfsd_vfs_write(rqstp, fhp, file, offset, vec, vlen, cnt,
-				stablep);
-	} else {
-		err = nfsd_open(rqstp, fhp, S_IFREG, NFSD_MAY_WRITE, &file);
-		if (err)
-			goto out;
+	err = nfsd_open(rqstp, fhp, S_IFREG, NFSD_MAY_WRITE, &file);
+	if (err)
+		return err;
 
-		if (cnt)
-			err = nfsd_vfs_write(rqstp, fhp, file, offset, vec, vlen,
-					     cnt, stablep);
-		fput(file);
-	}
-out:
+	if (cnt)
+		err = nfsd_vfs_write(rqstp, fhp, file, offset, vec, vlen,
+				     cnt, stablep);
+	fput(file);
 	return err;
 }
 
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index 5be875e..f1a7a3b 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -78,8 +78,9 @@ __be32		nfsd_readv(struct file *, loff_t, struct kvec *, int,
 				unsigned long *);
 __be32 		nfsd_read(struct svc_rqst *, struct svc_fh *,
 				loff_t, struct kvec *, int, unsigned long *);
-__be32 		nfsd_write(struct svc_rqst *, struct svc_fh *,struct file *,
-				loff_t, struct kvec *,int, unsigned long *, int *);
+__be32		nfsd_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
+				loff_t offset, struct kvec *vec, int vlen,
+				unsigned long *cnt, int *stablep);
 __be32		nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 				struct file *file, loff_t offset,
 				struct kvec *vec, int vlen, unsigned long *cnt,
-- 
1.9.1


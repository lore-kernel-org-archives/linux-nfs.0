Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36642 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752060AbcLWBcb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Dec 2016 20:32:31 -0500
Received: by mail-pg0-f68.google.com with SMTP id n5so677571pgh.3
        for <linux-nfs@vger.kernel.org>; Thu, 22 Dec 2016 17:32:31 -0800 (PST)
To: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Cc: kinglongmee@gmail.com
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH 2/3] NFSD: cleanup dead codes and values in nfsd_write
Message-ID: <5cd74fe8-37ac-ff17-3b17-c9b0032e3196@gmail.com>
Date: Fri, 23 Dec 2016 09:32:25 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs3proc.c |  2 +-
 fs/nfsd/nfsproc.c  |  2 +-
 fs/nfsd/vfs.c      | 35 +++++++++++------------------------
 fs/nfsd/vfs.h      |  4 ++--
 4 files changed, 15 insertions(+), 28 deletions(-)

diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 69cd0f1..ec7a63f 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -193,7 +193,7 @@ nfsd3_proc_write(struct svc_rqst *rqstp, struct nfsd3_writeargs *argp,
 
 	fh_copy(&resp->fh, &argp->fh);
 	resp->committed = argp->stable;
-	nfserr = nfsd_write(rqstp, &resp->fh, NULL,
+	nfserr = nfsd_write(rqstp, &resp->fh,
 				   argp->offset,
 				   rqstp->rq_vec, argp->vlen,
 				   &cnt,
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index f157c7e..45ca598 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -210,7 +210,7 @@ nfsd_proc_write(struct svc_rqst *rqstp, struct nfsd_writeargs *argp,
 		SVCFH_fmt(&argp->fh),
 		argp->len, argp->offset);
 
-	nfserr = nfsd_write(rqstp, fh_copy(&resp->fh, &argp->fh), NULL,
+	nfserr = nfsd_write(rqstp, fh_copy(&resp->fh, &argp->fh),
 				   argp->offset,
 				   rqstp->rq_vec, argp->vlen,
 			           &cnt,
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index cc80d2d..cba7c30 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1034,35 +1034,22 @@ __be32 nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
  * N.B. After this call fhp needs an fh_put
  */
 __be32
-nfsd_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
-		loff_t offset, struct kvec *vec, int vlen, unsigned long *cnt,
-		int stable)
+nfsd_write(struct svc_rqst *rqstp, struct svc_fh *fhp, loff_t offset,
+	   struct kvec *vec, int vlen, unsigned long *cnt, int stable)
 {
-	__be32			err = 0;
+	struct file *file = NULL;
+	__be32 err = 0;
 
 	trace_write_start(rqstp, fhp, offset, vlen);
 
-	if (file) {
-		err = nfsd_permission(rqstp, fhp->fh_export, fhp->fh_dentry,
-				NFSD_MAY_WRITE|NFSD_MAY_OWNER_OVERRIDE);
-		if (err)
-			goto out;
-		trace_write_opened(rqstp, fhp, offset, vlen);
-		err = nfsd_vfs_write(rqstp, fhp, file, offset, vec, vlen, cnt,
-				stable);
-		trace_write_io_done(rqstp, fhp, offset, vlen);
-	} else {
-		err = nfsd_open(rqstp, fhp, S_IFREG, NFSD_MAY_WRITE, &file);
-		if (err)
-			goto out;
+	err = nfsd_open(rqstp, fhp, S_IFREG, NFSD_MAY_WRITE, &file);
+	if (err)
+		goto out;
 
-		trace_write_opened(rqstp, fhp, offset, vlen);
-		if (cnt)
-			err = nfsd_vfs_write(rqstp, fhp, file, offset, vec, vlen,
-					     cnt, stable);
-		trace_write_io_done(rqstp, fhp, offset, vlen);
-		fput(file);
-	}
+	trace_write_opened(rqstp, fhp, offset, vlen);
+	err = nfsd_vfs_write(rqstp, fhp, file, offset, vec, vlen, cnt, stable);
+	trace_write_io_done(rqstp, fhp, offset, vlen);
+	fput(file);
 out:
 	trace_write_done(rqstp, fhp, offset, vlen);
 	return err;
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index 8458d8c..db98c48 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -83,8 +83,8 @@ __be32		nfsd_readv(struct file *, loff_t, struct kvec *, int,
 				unsigned long *);
 __be32 		nfsd_read(struct svc_rqst *, struct svc_fh *,
 				loff_t, struct kvec *, int, unsigned long *);
-__be32 		nfsd_write(struct svc_rqst *, struct svc_fh *,struct file *,
-				loff_t, struct kvec *,int, unsigned long *, int);
+__be32 		nfsd_write(struct svc_rqst *, struct svc_fh *, loff_t,
+				struct kvec *, int, unsigned long *, int);
 __be32		nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 				struct file *file, loff_t offset,
 				struct kvec *vec, int vlen, unsigned long *cnt,
-- 
2.9.3


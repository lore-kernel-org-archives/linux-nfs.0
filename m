Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f172.google.com ([209.85.160.172]:33395 "EHLO
	mail-yk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751801AbbHTLRe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Aug 2015 07:17:34 -0400
Received: by ykll84 with SMTP id l84so33732223ykl.0
        for <linux-nfs@vger.kernel.org>; Thu, 20 Aug 2015 04:17:33 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@lst.de, kinglongmee@gmail.com
Subject: [PATCH v3 07/20] nfsd: hook up nfsd_write to the new nfsd_file cache
Date: Thu, 20 Aug 2015 07:17:07 -0400
Message-Id: <1440069440-27454-8-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1440069440-27454-1-git-send-email-jeff.layton@primarydata.com>
References: <1440069440-27454-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Note that all callers currently pass in NULL for "file" anyway, so
there was already some dead code in here. Just eliminate that parm
and have it use the file cache instead of dealing directly with a
filp.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfsd/nfs3proc.c |  2 +-
 fs/nfsd/nfsproc.c  |  2 +-
 fs/nfsd/vfs.c      | 33 +++++++++++----------------------
 fs/nfsd/vfs.h      |  2 +-
 4 files changed, 14 insertions(+), 25 deletions(-)

diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 7b755b7f785c..4e46ac511479 100644
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
index 4cd78ef4c95c..9893095cbee1 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -213,7 +213,7 @@ nfsd_proc_write(struct svc_rqst *rqstp, struct nfsd_writeargs *argp,
 		SVCFH_fmt(&argp->fh),
 		argp->len, argp->offset);
 
-	nfserr = nfsd_write(rqstp, fh_copy(&resp->fh, &argp->fh), NULL,
+	nfserr = nfsd_write(rqstp, fh_copy(&resp->fh, &argp->fh),
 				   argp->offset,
 				   rqstp->rq_vec, argp->vlen,
 			           &cnt,
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index b5e077a6e7d4..7c1e7866fec9 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -42,6 +42,7 @@
 
 #include "nfsd.h"
 #include "vfs.h"
+#include "filecache.h"
 
 #define NFSDDBG_FACILITY		NFSDDBG_FILEOP
 
@@ -1002,30 +1003,18 @@ __be32 nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
  * N.B. After this call fhp needs an fh_put
  */
 __be32
-nfsd_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
-		loff_t offset, struct kvec *vec, int vlen, unsigned long *cnt,
-		int *stablep)
+nfsd_write(struct svc_rqst *rqstp, struct svc_fh *fhp, loff_t offset,
+	   struct kvec *vec, int vlen, unsigned long *cnt, int *stablep)
 {
-	__be32			err = 0;
-
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
-
-		if (cnt)
-			err = nfsd_vfs_write(rqstp, fhp, file, offset, vec, vlen,
-					     cnt, stablep);
-		fput(file);
+	__be32			err;
+	struct nfsd_file	*nf;
+
+	err = nfsd_file_acquire(rqstp, fhp, NFSD_MAY_WRITE, &nf);
+	if (err == nfs_ok) {
+		err = nfsd_vfs_write(rqstp, fhp, nf->nf_file, offset, vec,
+					vlen, cnt, stablep);
+		nfsd_file_put(nf);
 	}
-out:
 	return err;
 }
 
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index 5be875e3e638..78b5527cba93 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -78,7 +78,7 @@ __be32		nfsd_readv(struct file *, loff_t, struct kvec *, int,
 				unsigned long *);
 __be32 		nfsd_read(struct svc_rqst *, struct svc_fh *,
 				loff_t, struct kvec *, int, unsigned long *);
-__be32 		nfsd_write(struct svc_rqst *, struct svc_fh *,struct file *,
+__be32 		nfsd_write(struct svc_rqst *, struct svc_fh *,
 				loff_t, struct kvec *,int, unsigned long *, int *);
 __be32		nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 				struct file *file, loff_t offset,
-- 
2.4.3


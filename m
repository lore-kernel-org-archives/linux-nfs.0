Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:41551 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754245AbaE1IoR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 May 2014 04:44:17 -0400
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: remove unused function nfsd_read_file
Date: Wed, 28 May 2014 10:46:32 +0200
Message-Id: <1401266792-19086-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/vfs.c |   20 --------------------
 fs/nfsd/vfs.h |    2 --
 2 files changed, 22 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index b7d35a4..140c496 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1026,26 +1026,6 @@ __be32 nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	return err;
 }
 
-/* As above, but use the provided file descriptor. */
-__be32
-nfsd_read_file(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
-		loff_t offset, struct kvec *vec, int vlen,
-		unsigned long *count)
-{
-	__be32		err;
-
-	if (file) {
-		err = nfsd_permission(rqstp, fhp->fh_export, fhp->fh_dentry,
-				NFSD_MAY_READ|NFSD_MAY_OWNER_OVERRIDE);
-		if (err)
-			goto out;
-		err = nfsd_vfs_read(rqstp, file, offset, vec, vlen, count);
-	} else /* Note file may still be NULL in NFSv4 special stateid case: */
-		err = nfsd_read(rqstp, fhp, offset, vec, vlen, count);
-out:
-	return err;
-}
-
 /*
  * Write data to a file.
  * The stable flag requests synchronous writes.
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index 7441e96..91b6ae3 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -80,8 +80,6 @@ int		nfsd_readv(struct file *, loff_t, struct kvec *, int,
 				unsigned long *);
 __be32 		nfsd_read(struct svc_rqst *, struct svc_fh *,
 				loff_t, struct kvec *, int, unsigned long *);
-__be32 		nfsd_read_file(struct svc_rqst *, struct svc_fh *, struct file *,
-				loff_t, struct kvec *, int, unsigned long *);
 __be32 		nfsd_write(struct svc_rqst *, struct svc_fh *,struct file *,
 				loff_t, struct kvec *,int, unsigned long *, int *);
 __be32		nfsd_readlink(struct svc_rqst *, struct svc_fh *,
-- 
1.7.10.4


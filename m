Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35917 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751264AbcLaNA1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 31 Dec 2016 08:00:27 -0500
Received: by mail-pg0-f66.google.com with SMTP id n5so25065625pgh.3
        for <linux-nfs@vger.kernel.org>; Sat, 31 Dec 2016 05:00:27 -0800 (PST)
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH 3/3 v2] NFSD: Remove unused value inode in nfsd_vfs_write
To: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>, kinglongmee@gmail.com
Message-ID: <9a495047-179e-180b-2482-c413ae614d7d@gmail.com>
Date: Sat, 31 Dec 2016 21:00:21 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/vfs.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index d1d4a11..2c13216 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -943,7 +943,6 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 				unsigned long *cnt, int stable)
 {
 	struct svc_export	*exp;
-	struct inode		*inode;
 	mm_segment_t		oldfs;
 	__be32			err = 0;
 	int			host_err;
@@ -961,9 +960,7 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 		 */
 		current->flags |= PF_LESS_THROTTLE;
 
-	inode = file_inode(file);
-	exp   = fhp->fh_export;
-
+	exp = fhp->fh_export;
 	use_wgather = (rqstp->rq_vers == 2) && EX_WGATHER(exp);
 
 	if (!EX_ISSYNC(exp))
-- 
2.9.3


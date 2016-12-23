Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36679 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755808AbcLWBcg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Dec 2016 20:32:36 -0500
Received: by mail-pg0-f66.google.com with SMTP id n5so677742pgh.3
        for <linux-nfs@vger.kernel.org>; Thu, 22 Dec 2016 17:32:35 -0800 (PST)
To: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Cc: kinglongmee@gmail.com
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH 3/3] nfsd: Remove unused value inode in nfsd_vfs_write
Message-ID: <f292ec39-990d-44a7-d05f-cccdec42df71@gmail.com>
Date: Fri, 23 Dec 2016 09:32:30 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/vfs.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index cba7c30..41b354d 100644
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


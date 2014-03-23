Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47926 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752266AbaCWBMd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 22 Mar 2014 21:12:33 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 44/50] nfsd4: nfsd_vfs_read  doesn't use file handle parameter
Date: Sat, 22 Mar 2014 21:12:15 -0400
Message-Id: <1395537141-10389-45-git-send-email-bfields@redhat.com>
In-Reply-To: <1395537141-10389-1-git-send-email-bfields@redhat.com>
References: <1395537141-10389-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/vfs.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index eea5ad1..cbf7690 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -821,7 +821,7 @@ static int nfsd_direct_splice_actor(struct pipe_inode_info *pipe,
 }
 
 static __be32
-nfsd_vfs_read(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
+nfsd_vfs_read(struct svc_rqst *rqstp, struct file *file,
               loff_t offset, struct kvec *vec, int vlen, unsigned long *count)
 {
 	mm_segment_t	oldfs;
@@ -987,7 +987,7 @@ __be32 nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if (ra && ra->p_set)
 		file->f_ra = ra->p_ra;
 
-	err = nfsd_vfs_read(rqstp, fhp, file, offset, vec, vlen, count);
+	err = nfsd_vfs_read(rqstp, file, offset, vec, vlen, count);
 
 	/* Write back readahead params */
 	if (ra) {
@@ -1016,7 +1016,7 @@ nfsd_read_file(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 				NFSD_MAY_READ|NFSD_MAY_OWNER_OVERRIDE);
 		if (err)
 			goto out;
-		err = nfsd_vfs_read(rqstp, fhp, file, offset, vec, vlen, count);
+		err = nfsd_vfs_read(rqstp, file, offset, vec, vlen, count);
 	} else /* Note file may still be NULL in NFSv4 special stateid case: */
 		err = nfsd_read(rqstp, fhp, offset, vec, vlen, count);
 out:
-- 
1.8.5.3


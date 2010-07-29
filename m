Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53251 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754888Ab0G2WWg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 Jul 2010 18:22:36 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/5] nfsd: bypass readahead cache when have struct file
Date: Thu, 29 Jul 2010 18:21:20 -0400
Message-Id: <1280442084-17867-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1280442084-17867-1-git-send-email-bfields@redhat.com>
References: <1280442084-17867-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The readahead cache compensates for the fact that the NFS server
currently does an open and close on every IO operation in the NFSv2 and
NFSv3 case.

In the NFSv4 case we have long-lived struct files associated with client
opens, so there's no need for this.  In fact, concurrent IO's using
trying to modify the same file->f_ra may cause problems.

So, don't bother with the readahead cache in that case.

Note eventually we'll likely do this in the v2/v3 case as well by
keeping a cache of struct files instead of struct file_ra_state's.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/vfs.c |   62 ++++++++++++++++++++++++++++++++++----------------------
 1 files changed, 38 insertions(+), 24 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 5ca984b..31d32ae 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -904,7 +904,6 @@ nfsd_vfs_read(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
               loff_t offset, struct kvec *vec, int vlen, unsigned long *count)
 {
 	struct inode *inode;
-	struct raparms	*ra;
 	mm_segment_t	oldfs;
 	__be32		err;
 	int		host_err;
@@ -915,12 +914,6 @@ nfsd_vfs_read(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 	if (svc_msnfs(fhp) && !lock_may_read(inode, offset, *count))
 		goto out;
 
-	/* Get readahead parameters */
-	ra = nfsd_get_raparms(inode->i_sb->s_dev, inode->i_ino);
-
-	if (ra && ra->p_set)
-		file->f_ra = ra->p_ra;
-
 	if (file->f_op->splice_read && rqstp->rq_splice_ok) {
 		struct splice_desc sd = {
 			.len		= 0,
@@ -938,16 +931,6 @@ nfsd_vfs_read(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 		set_fs(oldfs);
 	}
 
-	/* Write back readahead params */
-	if (ra) {
-		struct raparm_hbucket *rab = &raparm_hash[ra->p_hindex];
-		spin_lock(&rab->pb_lock);
-		ra->p_ra = file->f_ra;
-		ra->p_set = 1;
-		ra->p_count--;
-		spin_unlock(&rab->pb_lock);
-	}
-
 	if (host_err >= 0) {
 		nfsdstats.io_read += host_err;
 		*count = host_err;
@@ -1082,6 +1065,42 @@ out:
 	return err;
 }
 
+static __be32 nfsd_open_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
+	loff_t offset, struct kvec *vec, int vlen, unsigned long *count)
+{
+	struct file *file;
+	struct inode *inode;
+	struct raparms	*ra;
+	__be32 err;
+
+	err = nfsd_open(rqstp, fhp, S_IFREG, NFSD_MAY_READ, &file);
+	if (err)
+		return err;
+
+	inode = file->f_path.dentry->d_inode;
+
+	/* Get readahead parameters */
+	ra = nfsd_get_raparms(inode->i_sb->s_dev, inode->i_ino);
+
+	if (ra && ra->p_set)
+		file->f_ra = ra->p_ra;
+
+	err = nfsd_vfs_read(rqstp, fhp, file, offset, vec, vlen, count);
+
+	/* Write back readahead params */
+	if (ra) {
+		struct raparm_hbucket *rab = &raparm_hash[ra->p_hindex];
+		spin_lock(&rab->pb_lock);
+		ra->p_ra = file->f_ra;
+		ra->p_set = 1;
+		ra->p_count--;
+		spin_unlock(&rab->pb_lock);
+	}
+
+	nfsd_close(file);
+	return err;
+}
+
 /*
  * Read data from a file. count must contain the requested read count
  * on entry. On return, *count contains the number of bytes actually read.
@@ -1100,13 +1119,8 @@ nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 		if (err)
 			goto out;
 		err = nfsd_vfs_read(rqstp, fhp, file, offset, vec, vlen, count);
-	} else {
-		err = nfsd_open(rqstp, fhp, S_IFREG, NFSD_MAY_READ, &file);
-		if (err)
-			goto out;
-		err = nfsd_vfs_read(rqstp, fhp, file, offset, vec, vlen, count);
-		nfsd_close(file);
-	}
+	} else
+		err = nfsd_open_read(rqstp, fhp, offset, vec, vlen, count);
 out:
 	return err;
 }
-- 
1.7.0.4


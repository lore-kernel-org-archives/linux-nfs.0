Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34440 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966528Ab2JZVHA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Oct 2012 17:07:00 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Cc: Peter Staubach <pstaubach@exagrid.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/2] nfsd: use vfs_fsync_range(), not O_SYNC, for stable writes
Date: Fri, 26 Oct 2012 17:06:57 -0400
Message-Id: <1351285617-20450-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1351285617-20450-1-git-send-email-bfields@redhat.com>
References: <1351285617-20450-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

NFSv4 shares the same struct file across multiple writes.  (And we'd
like NFSv2 and NFSv3 to do that as well some day.)

So setting O_SYNC on the struct file as a way to request a synchronous
write doesn't work.

Instead, do a vfs_fsync_range() in that case.

Reported-by: Peter Staubach <pstaubach@exagrid.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/vfs.c |   13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index ed3eb59..b584205 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1024,11 +1024,6 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 
 	if (!EX_ISSYNC(exp))
 		stable = 0;
-	if (stable && !use_wgather) {
-		spin_lock(&file->f_lock);
-		file->f_flags |= O_SYNC;
-		spin_unlock(&file->f_lock);
-	}
 
 	/* Write the data. */
 	oldfs = get_fs(); set_fs(KERNEL_DS);
@@ -1044,8 +1039,12 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 	if (inode->i_mode & (S_ISUID | S_ISGID))
 		kill_suid(dentry);
 
-	if (stable && use_wgather)
-		host_err = wait_for_concurrent_writes(file);
+	if (stable) {
+		if (use_wgather)
+			host_err = wait_for_concurrent_writes(file);
+		else
+			host_err = vfs_fsync_range(file, offset, offset+*cnt, 0);
+	}
 
 out_nfserr:
 	dprintk("nfsd: write complete host_err=%d\n", host_err);
-- 
1.7.9.5


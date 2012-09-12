Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:40792 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750737Ab2ILTIp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Sep 2012 15:08:45 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] NFS: Write the entire file if a server reboot occurs during fsync()
Date: Wed, 12 Sep 2012 15:08:37 -0400
Message-Id: <1347476917-34642-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1347476917-34642-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1347476917-34642-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is to ensure that we don't clear the NFS_CONTEXT_RESEND_WRITES
flag while there are still writes that haven't been resent.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/file.c     | 7 +++++++
 fs/nfs/nfs4file.c | 7 +++++++
 2 files changed, 14 insertions(+)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index cc9b566..c814666 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -301,6 +301,13 @@ nfs_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 		mutex_lock(&inode->i_mutex);
 		ret = nfs_file_fsync_commit(file, start, end, datasync);
 		mutex_unlock(&inode->i_mutex);
+		/*
+		 * If nfs_file_fsync_commit detected a server reboot, then
+		 * resend all dirty pages that might have been covered by
+		 * the NFS_CONTEXT_RESEND_WRITES flag
+		 */
+		start = 0;
+		end = LLONG_MAX;
 	} while (ret == -EAGAIN);
 
 	return ret;
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index eef1b38..afddd66 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -105,6 +105,13 @@ nfs4_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 			/* application has asked for meta-data sync */
 			ret = pnfs_layoutcommit_inode(inode, true);
 		mutex_unlock(&inode->i_mutex);
+		/*
+		 * If nfs_file_fsync_commit detected a server reboot, then
+		 * resend all dirty pages that might have been covered by
+		 * the NFS_CONTEXT_RESEND_WRITES flag
+		 */
+		start = 0;
+		end = LLONG_MAX;
 	} while (ret == -EAGAIN);
 
 	return ret;
-- 
1.7.11.4


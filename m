Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:53156 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757238Ab1BKPms (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Feb 2011 10:42:48 -0500
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 4/4] NFS: change nfs_writeback_done to return void
Date: Fri, 11 Feb 2011 10:42:38 -0500
Message-Id: <1297438958-24861-5-git-send-email-iisaman@netapp.com>
In-Reply-To: <1297438958-24861-1-git-send-email-iisaman@netapp.com>
References: <1297438958-24861-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The return values are not used by any callers.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/write.c         |    8 ++++----
 include/linux/nfs_fs.h |    2 +-
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index c8278f4..897d115 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1132,7 +1132,7 @@ static const struct rpc_call_ops nfs_write_full_ops = {
 /*
  * This function is called when the WRITE call is complete.
  */
-int nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
+void nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 {
 	struct nfs_writeargs	*argp = &data->args;
 	struct nfs_writeres	*resp = &data->res;
@@ -1151,7 +1151,7 @@ int nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 	 */
 	status = NFS_PROTO(data->inode)->write_done(task, data);
 	if (status != 0)
-		return status;
+		return;
 	nfs_add_stats(data->inode, NFSIOS_SERVERWRITTENBYTES, resp->count);
 
 #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
@@ -1196,7 +1196,7 @@ int nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 				argp->stable = NFS_FILE_SYNC;
 			}
 			nfs_restart_rpc(task, server->nfs_client);
-			return -EAGAIN;
+			return;
 		}
 		if (time_before(complain, jiffies)) {
 			printk(KERN_WARNING
@@ -1207,7 +1207,7 @@ int nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 		/* Can't do anything about it except throw an error. */
 		task->tk_status = -EIO;
 	}
-	return 0;
+	return;
 }
 
 
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 6023efa..f88522b 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -501,7 +501,7 @@ extern int  nfs_writepage(struct page *page, struct writeback_control *wbc);
 extern int  nfs_writepages(struct address_space *, struct writeback_control *);
 extern int  nfs_flush_incompatible(struct file *file, struct page *page);
 extern int  nfs_updatepage(struct file *, struct page *, unsigned int, unsigned int);
-extern int nfs_writeback_done(struct rpc_task *, struct nfs_write_data *);
+extern void nfs_writeback_done(struct rpc_task *, struct nfs_write_data *);
 
 /*
  * Try to write back everything synchronously (but check the
-- 
1.7.2.1


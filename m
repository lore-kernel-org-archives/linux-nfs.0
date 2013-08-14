Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:65511 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751019Ab3HNP7Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Aug 2013 11:59:24 -0400
From: <andros@netapp.com>
To: <trond.myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 5 2/5] NFS: Warn when attempting a buffered write or commit with an expired credential
Date: Wed, 14 Aug 2013 11:59:14 -0400
Message-ID: <1376495957-7482-3-git-send-email-andros@netapp.com>
In-Reply-To: <1376495957-7482-1-git-send-email-andros@netapp.com>
References: <1376495957-7482-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/write.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index f1bdb72..7b7d360 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1330,6 +1330,14 @@ void nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 	dprintk("NFS: %5u nfs_writeback_done (status %d)\n",
 		task->tk_pid, task->tk_status);
 
+	if (task->tk_status == -EKEYEXPIRED)
+		pr_warn_ratelimited("NFS:        write attempt with expired "
+			"credential req %s/%lld, %u bytes @ offset %llu\n",
+			inode->i_sb->s_id,
+			(long long)NFS_FILEID(inode),
+			data->args.count,
+			(unsigned long long)data->args.offset);
+
 	/*
 	 * ->write_done will attempt to use post-op attributes to detect
 	 * conflicting writes by other clients.  A strict interpretation
@@ -1556,6 +1564,9 @@ static void nfs_commit_done(struct rpc_task *task, void *calldata)
 
         dprintk("NFS: %5u nfs_commit_done (status %d)\n",
                                 task->tk_pid, task->tk_status);
+	if (task->tk_status == -EKEYEXPIRED)
+		pr_warn_ratelimited("NFS:       commit attempt with expired "
+				"credential\n");
 
 	/* Call the NFS version-specific code */
 	NFS_PROTO(data->inode)->commit_done(task, data);
-- 
1.8.3.1


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:41089 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759348Ab3GRTfn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Jul 2013 15:35:43 -0400
From: <andros@netapp.com>
To: <trond.myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 4 2/5] NFS: Warn when attempting a buffered write or commit with an expired credential
Date: Thu, 18 Jul 2013 15:35:27 -0400
Message-ID: <1374176130-11657-3-git-send-email-andros@netapp.com>
In-Reply-To: <1374176130-11657-1-git-send-email-andros@netapp.com>
References: <1374176130-11657-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/write.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index f1bdb72..724c845 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1330,6 +1330,14 @@ void nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 	dprintk("NFS: %5u nfs_writeback_done (status %d)\n",
 		task->tk_pid, task->tk_status);
 
+	if (task->tk_status == -EKEYEXPIRED)
+		pr_warn("NFS:	write attempt with expired credential "
+			"req %s/%lld, %u bytes @ offset %llu\n",
+			inode->i_sb->s_id,
+			(long long)NFS_FILEID(inode),
+			data->args.count,
+			(unsigned long long)data->args.offset);
+
 	/*
 	 * ->write_done will attempt to use post-op attributes to detect
 	 * conflicting writes by other clients.  A strict interpretation
@@ -1556,6 +1564,8 @@ static void nfs_commit_done(struct rpc_task *task, void *calldata)
 
         dprintk("NFS: %5u nfs_commit_done (status %d)\n",
                                 task->tk_pid, task->tk_status);
+	if (task->tk_status == -EKEYEXPIRED)
+		pr_warn("NFS: commit attempt with expired credential\n");
 
 	/* Call the NFS version-specific code */
 	NFS_PROTO(data->inode)->commit_done(task, data);
-- 
1.8.3.1


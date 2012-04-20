Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:28519 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757449Ab2DTSsK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Apr 2012 14:48:10 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH v3 08/25] NFS: dprintks in directio code were referencing task after put
Date: Fri, 20 Apr 2012 14:47:40 -0400
Message-Id: <1334947677-28864-9-git-send-email-iisaman@netapp.com>
In-Reply-To: <1334947677-28864-1-git-send-email-iisaman@netapp.com>
References: <1334947677-28864-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/direct.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 5897dfe..fb7fbaa 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -357,15 +357,15 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_direct_req *dreq,
 		task = rpc_run_task(&task_setup_data);
 		if (IS_ERR(task))
 			break;
-		rpc_put_task(task);
 
 		dprintk("NFS: %5u initiated direct read call "
 			"(req %s/%Ld, %zu bytes @ offset %Lu)\n",
-				data->task.tk_pid,
+				task->tk_pid,
 				inode->i_sb->s_id,
 				(long long)NFS_FILEID(inode),
 				bytes,
 				(unsigned long long)data->args.offset);
+		rpc_put_task(task);
 
 		started += bytes;
 		user_addr += bytes;
@@ -784,15 +784,15 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_direct_req *dreq,
 		task = rpc_run_task(&task_setup_data);
 		if (IS_ERR(task))
 			break;
-		rpc_put_task(task);
 
 		dprintk("NFS: %5u initiated direct write call "
 			"(req %s/%Ld, %zu bytes @ offset %Lu)\n",
-				data->task.tk_pid,
+				task->tk_pid,
 				inode->i_sb->s_id,
 				(long long)NFS_FILEID(inode),
 				bytes,
 				(unsigned long long)data->args.offset);
+		rpc_put_task(task);
 
 		started += bytes;
 		user_addr += bytes;
-- 
1.7.2.1


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:34103 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750725AbbGAEAU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Jul 2015 00:00:20 -0400
Received: by pdbep18 with SMTP id ep18so17825732pdb.1
        for <linux-nfs@vger.kernel.org>; Tue, 30 Jun 2015 21:00:19 -0700 (PDT)
Message-ID: <559365CD.5040207@gmail.com>
Date: Wed, 01 Jul 2015 12:00:13 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH 8/8] nfs: Remove invalid tk_pid from debug message
References: <5593648D.7020804@gmail.com>
In-Reply-To: <5593648D.7020804@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Before rpc_run_task(), tk_pid is uninitiated as 0 always.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/nfs4proc.c | 5 ++---
 fs/nfs/pagelist.c | 3 +--
 fs/nfs/write.c    | 2 +-
 3 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f1e0843..c3bb09f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -8063,9 +8063,8 @@ nfs4_proc_layoutcommit(struct nfs4_layoutcommit_data *data, bool sync)
 	struct rpc_task *task;
 	int status = 0;
 
-	dprintk("NFS: %4d initiating layoutcommit call. sync %d "
-		"lbw: %llu inode %lu\n",
-		data->task.tk_pid, sync,
+	dprintk("NFS: initiating layoutcommit call. sync %d "
+		"lbw: %llu inode %lu\n", sync,
 		data->args.lastbytewritten,
 		data->args.inode->i_ino);
 
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 282b393..776f8f8 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -636,9 +636,8 @@ int nfs_initiate_pgio(struct rpc_clnt *clnt, struct nfs_pgio_header *hdr,
 
 	hdr->rw_ops->rw_initiate(hdr, &msg, rpc_ops, &task_setup_data, how);
 
-	dprintk("NFS: %5u initiated pgio call "
+	dprintk("NFS: initiated pgio call "
 		"(req %s/%llu, %u bytes @ offset %llu)\n",
-		hdr->task.tk_pid,
 		hdr->inode->i_sb->s_id,
 		(unsigned long long)NFS_FILEID(hdr->inode),
 		hdr->args.count,
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index e6c2625..9354980 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1556,7 +1556,7 @@ int nfs_initiate_commit(struct rpc_clnt *clnt, struct nfs_commit_data *data,
 	/* Set up the initial task struct.  */
 	nfs_ops->commit_setup(data, &msg);
 
-	dprintk("NFS: %5u initiated commit call\n", data->task.tk_pid);
+	dprintk("NFS: initiated commit call\n");
 
 	nfs4_state_protect(NFS_SERVER(data->inode)->nfs_client,
 		NFS_SP4_MACH_CRED_COMMIT, &task_setup_data.rpc_client, &msg);
-- 
2.4.3


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f177.google.com ([209.85.213.177]:37312 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751079AbbBEWhP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Feb 2015 17:37:15 -0500
Received: by mail-ig0-f177.google.com with SMTP id z20so2352514igj.4
        for <linux-nfs@vger.kernel.org>; Thu, 05 Feb 2015 14:37:14 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH 1/5] NFSv4: Ensure we reference the inode for return-on-close in delegreturn
Date: Thu,  5 Feb 2015 17:37:07 -0500
Message-Id: <1423175831-54558-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we have to do a return-on-close in the delegreturn code, then
we must ensure that the inode and super block remain referenced.

Cc: Peng Tao <tao.peng@primarydata.com>
Cc: stable@vger.kernel.org # 3.17.x
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 19 ++++++++++++++-----
 1 file changed, 14 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index cd4295d84d54..b803c1d363e7 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5175,9 +5175,16 @@ static void nfs4_delegreturn_done(struct rpc_task *task, void *calldata)
 static void nfs4_delegreturn_release(void *calldata)
 {
 	struct nfs4_delegreturndata *data = calldata;
+	struct inode *inode = data->inode;
+
+	if (inode) {
+		struct super_block *sb = inode->i_sb;
 
-	if (data->roc)
-		pnfs_roc_release(data->inode);
+		if (data->roc)
+			pnfs_roc_release(inode);
+		iput(inode);
+		nfs_sb_deactive(sb);
+	}
 	kfree(calldata);
 }
 
@@ -5234,9 +5241,11 @@ static int _nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, co
 	nfs_fattr_init(data->res.fattr);
 	data->timestamp = jiffies;
 	data->rpc_status = 0;
-	data->inode = inode;
-	data->roc = list_empty(&NFS_I(inode)->open_files) ?
-		    pnfs_roc(inode) : false;
+	data->inode = igrab(inode);
+	if (data->inode) {
+		nfs_sb_active(inode->i_sb);
+		data->roc = nfs4_roc(inode);
+	}
 
 	task_setup_data.callback_data = data;
 	msg.rpc_argp = &data->args;
-- 
2.1.0


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f41.google.com ([209.85.220.41]:59979 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750884AbaGCFFw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jul 2014 01:05:52 -0400
Received: by mail-pa0-f41.google.com with SMTP id fb1so13792971pad.28
        for <linux-nfs@vger.kernel.org>; Wed, 02 Jul 2014 22:05:52 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH 3/3] nfs41: layout return on close in delegation return
Date: Thu,  3 Jul 2014 13:05:02 +0800
Message-Id: <1404363902-12943-4-git-send-email-tao.peng@primarydata.com>
In-Reply-To: <1404363902-12943-3-git-send-email-tao.peng@primarydata.com>
References: <1404363902-12943-1-git-send-email-tao.peng@primarydata.com>
 <1404363902-12943-2-git-send-email-tao.peng@primarydata.com>
 <1404363902-12943-3-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If file is not opened by anyone, we do layout return on close
in delegation return.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/nfs4proc.c | 17 ++++++++++++++++-
 1 file changed, 16 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 81c0d2e..70a623c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5022,6 +5022,9 @@ struct nfs4_delegreturndata {
 	unsigned long timestamp;
 	struct nfs_fattr fattr;
 	int rpc_status;
+	struct inode *inode;
+	bool roc;
+	u32 roc_barrier;
 };
 
 static void nfs4_delegreturn_done(struct rpc_task *task, void *calldata)
@@ -5035,7 +5038,6 @@ static void nfs4_delegreturn_done(struct rpc_task *task, void *calldata)
 	switch (task->tk_status) {
 	case 0:
 		renew_lease(data->res.server, data->timestamp);
-		break;
 	case -NFS4ERR_ADMIN_REVOKED:
 	case -NFS4ERR_DELEG_REVOKED:
 	case -NFS4ERR_BAD_STATEID:
@@ -5043,6 +5045,8 @@ static void nfs4_delegreturn_done(struct rpc_task *task, void *calldata)
 	case -NFS4ERR_STALE_STATEID:
 	case -NFS4ERR_EXPIRED:
 		task->tk_status = 0;
+		if (data->roc)
+			pnfs_roc_set_barrier(data->inode, data->roc_barrier);
 		break;
 	default:
 		if (nfs4_async_handle_error(task, data->res.server, NULL) ==
@@ -5056,6 +5060,10 @@ static void nfs4_delegreturn_done(struct rpc_task *task, void *calldata)
 
 static void nfs4_delegreturn_release(void *calldata)
 {
+	struct nfs4_delegreturndata *data = calldata;
+
+	if (data->roc)
+		pnfs_roc_release(data->inode);
 	kfree(calldata);
 }
 
@@ -5065,6 +5073,10 @@ static void nfs4_delegreturn_prepare(struct rpc_task *task, void *data)
 
 	d_data = (struct nfs4_delegreturndata *)data;
 
+	if (d_data->roc &&
+	    pnfs_roc_drain(d_data->inode, &d_data->roc_barrier, task))
+		return;
+
 	nfs4_setup_sequence(d_data->res.server,
 			&d_data->args.seq_args,
 			&d_data->res.seq_res,
@@ -5108,6 +5120,9 @@ static int _nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, co
 	nfs_fattr_init(data->res.fattr);
 	data->timestamp = jiffies;
 	data->rpc_status = 0;
+	data->inode = inode;
+	data->roc = list_empty(&NFS_I(inode)->open_files) ?
+		    pnfs_roc(inode) : false;
 
 	task_setup_data.callback_data = data;
 	msg.rpc_argp = &data->args;
-- 
1.9.1


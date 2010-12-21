Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:51916 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754388Ab0LUAkY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Dec 2010 19:40:24 -0500
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 1/1] nfs: change end of line commas to semicolons
Date: Mon, 20 Dec 2010 19:39:58 -0500
Message-Id: <1292891998-10153-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Fix a copy-paste error from a previous code reorg.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 4435e5e..e1d82b5 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1984,8 +1984,8 @@ int nfs4_do_close(struct path *path, struct nfs4_state *state, gfp_t gfp_mask, i
 	path_get(path);
 	calldata->path = *path;
 
-	msg.rpc_argp = &calldata->arg,
-	msg.rpc_resp = &calldata->res,
+	msg.rpc_argp = &calldata->arg;
+	msg.rpc_resp = &calldata->res;
 	task_setup_data.callback_data = calldata;
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
@@ -3908,8 +3908,8 @@ static struct rpc_task *nfs4_do_unlck(struct file_lock *fl,
 		return ERR_PTR(-ENOMEM);
 	}
 
-	msg.rpc_argp = &data->arg,
-	msg.rpc_resp = &data->res,
+	msg.rpc_argp = &data->arg;
+	msg.rpc_resp = &data->res;
 	task_setup_data.callback_data = data;
 	return rpc_run_task(&task_setup_data);
 }
@@ -4145,8 +4145,8 @@ static int _nfs4_do_setlk(struct nfs4_state *state, int cmd, struct file_lock *f
 			data->arg.reclaim = NFS_LOCK_RECLAIM;
 		task_setup_data.callback_ops = &nfs4_recover_lock_ops;
 	}
-	msg.rpc_argp = &data->arg,
-	msg.rpc_resp = &data->res,
+	msg.rpc_argp = &data->arg;
+	msg.rpc_resp = &data->res;
 	task_setup_data.callback_data = data;
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
-- 
1.7.2.1


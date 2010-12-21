Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:27534 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757288Ab0LUAwX convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Dec 2010 19:52:23 -0500
Received: from svlrsexc1-prd.hq.netapp.com (svlrsexc1-prd.hq.netapp.com [10.57.115.30])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oBL0q132005542
	for <linux-nfs@vger.kernel.org>; Mon, 20 Dec 2010 16:52:01 -0800 (PST)
Subject: Re: [PATCH 1/1] nfs: change end of line commas to semicolons
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Fred Isaman <iisaman@netapp.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <1292891998-10153-1-git-send-email-iisaman@netapp.com>
References: <1292891998-10153-1-git-send-email-iisaman@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 20 Dec 2010 19:47:13 -0500
Message-ID: <1292892433.7744.36.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2010-12-20 at 19:39 -0500, Fred Isaman wrote:
> Fix a copy-paste error from a previous code reorg.
> 
> Signed-off-by: Fred Isaman <iisaman@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>

Yes. I'm aware of those bugs, and have already committed the following
patch:

-------------------------------------------------------------------------------
NFSv4: Convert a few commas into semicolons...

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4proc.c |   16 ++++++++--------
 fs/nfs/unlink.c   |    2 +-
 2 files changed, 9 insertions(+), 9 deletions(-)


diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index a742433..aa29046 100644
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
@@ -3663,8 +3663,8 @@ static int _nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, co
 	data->rpc_status = 0;
 
 	task_setup_data.callback_data = data;
-	msg.rpc_argp = &data->args,
-	msg.rpc_resp = &data->res,
+	msg.rpc_argp = &data->args;
+	msg.rpc_resp = &data->res;
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
@@ -3909,8 +3909,8 @@ static struct rpc_task *nfs4_do_unlck(struct file_lock *fl,
 		return ERR_PTR(-ENOMEM);
 	}
 
-	msg.rpc_argp = &data->arg,
-	msg.rpc_resp = &data->res,
+	msg.rpc_argp = &data->arg;
+	msg.rpc_resp = &data->res;
 	task_setup_data.callback_data = data;
 	return rpc_run_task(&task_setup_data);
 }
@@ -4147,8 +4147,8 @@ static int _nfs4_do_setlk(struct nfs4_state *state, int cmd, struct file_lock *f
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
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 7bdec85..3bf1e53 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -429,7 +429,7 @@ nfs_async_rename(struct inode *old_dir, struct inode *new_dir,
 	data = kzalloc(sizeof(*data), GFP_KERNEL);
 	if (data == NULL)
 		return ERR_PTR(-ENOMEM);
-	task_setup_data.callback_data = data,
+	task_setup_data.callback_data = data;
 
 	data->cred = rpc_lookup_cred();
 	if (IS_ERR(data->cred)) {


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:9112 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751589Ab0JAQDm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Oct 2010 12:03:42 -0400
Received: from localhost.localdomain (vpn2ntap-420885.hq.netapp.com [10.58.51.27])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o91G3Ueo008238
	for <linux-nfs@vger.kernel.org>; Fri, 1 Oct 2010 09:03:41 -0700 (PDT)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/7] nfs: change end of line commas to semicolons
Date: Fri,  1 Oct 2010 12:02:48 -0400
Message-Id: <1285948971-2048-5-git-send-email-iisaman@netapp.com>
In-Reply-To: <1285948971-2048-1-git-send-email-iisaman@netapp.com>
References: <1285948971-2048-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Fix a copy-paste error from a previous code reorg.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4proc.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 61a110d..aad6fdc 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1983,8 +1983,8 @@ int nfs4_do_close(struct path *path, struct nfs4_state *state, gfp_t gfp_mask, i
 	path_get(path);
 	calldata->path = *path;
 
-	msg.rpc_argp = &calldata->arg,
-	msg.rpc_resp = &calldata->res,
+	msg.rpc_argp = &calldata->arg;
+	msg.rpc_resp = &calldata->res;
 	task_setup_data.callback_data = calldata;
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
@@ -4048,8 +4048,8 @@ static struct rpc_task *nfs4_do_unlck(struct file_lock *fl,
 		return ERR_PTR(-ENOMEM);
 	}
 
-	msg.rpc_argp = &data->arg,
-	msg.rpc_resp = &data->res,
+	msg.rpc_argp = &data->arg;
+	msg.rpc_resp = &data->res;
 	task_setup_data.callback_data = data;
 	return rpc_run_task(&task_setup_data);
 }
@@ -4286,8 +4286,8 @@ static int _nfs4_do_setlk(struct nfs4_state *state, int cmd, struct file_lock *f
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


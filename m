Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:36008 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752332AbdCMOgY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 13 Mar 2017 10:36:24 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 1/1] NFS prevent double free in async nfs4_exchange_id
Date: Mon, 13 Mar 2017 10:36:19 -0400
Message-ID: <20170313143619.39590-1-kolga@netapp.com>
In-Reply-To: <1489247359.3260.7.camel@primarydata.com>
References: <1489247359.3260.7.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since rpc_task is async, the release function should be called which
will free the impl_id, scope, and owner.

Trond pointed at 2 more problems:
-- use of client pointer after free in the nfs4_exchangeid_release() function
-- cl_count mismatch if rpc_run_task() isn't run

Fixes: 8d89bd70bc9 ("NFS setup async exchange_id")
Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs4proc.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 59be0f7..1a65af2 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7426,11 +7426,11 @@ static void nfs4_exchange_id_release(void *data)
 	struct nfs41_exchange_id_data *cdata =
 					(struct nfs41_exchange_id_data *)data;
 
-	nfs_put_client(cdata->args.client);
 	if (cdata->xprt) {
 		xprt_put(cdata->xprt);
 		rpc_clnt_xprt_switch_put(cdata->args.client->cl_rpcclient);
 	}
+	nfs_put_client(cdata->args.client);
 	kfree(cdata->res.impl_id);
 	kfree(cdata->res.server_scope);
 	kfree(cdata->res.server_owner);
@@ -7537,10 +7537,8 @@ static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
 	task_setup_data.callback_data = calldata;
 
 	task = rpc_run_task(&task_setup_data);
-	if (IS_ERR(task)) {
-	status = PTR_ERR(task);
-		goto out_impl_id;
-	}
+	if (IS_ERR(task))
+		return PTR_ERR(task);
 
 	if (!xprt) {
 		status = rpc_wait_for_completion_task(task);
@@ -7568,6 +7566,7 @@ static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
 	kfree(calldata->res.server_owner);
 out_calldata:
 	kfree(calldata);
+	nfs_put_client(clp);
 	goto out;
 }
 
-- 
1.8.3.1


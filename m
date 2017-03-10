Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:56761 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933908AbdCJTPp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 10 Mar 2017 14:15:45 -0500
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] NFS prevent double free in async nfs4_exchange_id
Date: Fri, 10 Mar 2017 14:15:41 -0500
Message-ID: <20170310191541.38007-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since rpc_task is async, the release function should be called which
will free the impl_id, scope, and owner.

Fixes: 8d89bd70bc9 ("NFS setup async exchange_id")
Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs4proc.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 59be0f7..b77cb6f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
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
-- 
1.8.3.1


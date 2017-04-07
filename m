Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:19461 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933216AbdDGSQI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Apr 2017 14:16:08 -0400
From: <Anna.Schumaker@Netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 29/34] NFS: Clean up nfs4_proc_get_lease_time()
Date: Fri, 7 Apr 2017 14:15:23 -0400
Message-ID: <20170407181528.2832-30-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
References: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs4proc.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index a3808826b655..dda19a35ad9e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7751,17 +7751,13 @@ int nfs4_proc_get_lease_time(struct nfs_client *clp, struct nfs_fsinfo *fsinfo)
 
 	nfs4_init_sequence(&args.la_seq_args, &res.lr_seq_res, 0);
 	nfs4_set_sequence_privileged(&args.la_seq_args);
-	dprintk("--> %s\n", __func__);
 	task = rpc_run_task(&task_setup);
 
 	if (IS_ERR(task))
-		status = PTR_ERR(task);
-	else {
-		status = task->tk_status;
-		rpc_put_task(task);
-	}
-	dprintk("<-- %s return %d\n", __func__, status);
+		return PTR_ERR(task);
 
+	status = task->tk_status;
+	rpc_put_task(task);
 	return status;
 }
 
-- 
2.12.2


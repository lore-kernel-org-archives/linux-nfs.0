Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:26541 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754489AbdDGSQE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Apr 2017 14:16:04 -0400
From: <Anna.Schumaker@Netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 28/34] NFS: Clean up _nfs4_proc_exchange_id()
Date: Fri, 7 Apr 2017 14:15:22 -0400
Message-ID: <20170407181528.2832-29-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
References: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs4proc.c | 18 +++---------------
 1 file changed, 3 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 184d57a5098d..a3808826b655 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7453,15 +7453,14 @@ static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
 	};
 	struct nfs41_exchange_id_data *calldata;
 	struct rpc_task *task;
-	int status = -EIO;
+	int status;
 
 	if (!atomic_inc_not_zero(&clp->cl_count))
-		goto out;
+		return -EIO;
 
-	status = -ENOMEM;
 	calldata = kzalloc(sizeof(*calldata), GFP_NOFS);
 	if (!calldata)
-		goto out;
+		return -ENOMEM;
 
 	if (!xprt)
 		nfs4_init_boot_verifier(clp, &verifier);
@@ -7470,10 +7469,6 @@ static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
 	if (status)
 		goto out_calldata;
 
-	dprintk("NFS call  exchange_id auth=%s, '%s'\n",
-		clp->cl_rpcclient->cl_auth->au_ops->au_name,
-		clp->cl_owner_id);
-
 	calldata->res.server_owner = kzalloc(sizeof(struct nfs41_server_owner),
 						GFP_NOFS);
 	status = -ENOMEM;
@@ -7539,13 +7534,6 @@ static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
 
 	rpc_put_task(task);
 out:
-	if (clp->cl_implid != NULL)
-		dprintk("NFS reply exchange_id: Server Implementation ID: "
-			"domain: %s, name: %s, date: %llu,%u\n",
-			clp->cl_implid->domain, clp->cl_implid->name,
-			clp->cl_implid->date.seconds,
-			clp->cl_implid->date.nseconds);
-	dprintk("NFS reply exchange_id: %d\n", status);
 	return status;
 
 out_impl_id:
-- 
2.12.2


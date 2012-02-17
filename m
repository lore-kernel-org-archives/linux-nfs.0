Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:27851 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751671Ab2BQUUl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Feb 2012 15:20:41 -0500
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 2/3] NFSv4: fix server_scope memory leak
Date: Fri, 17 Feb 2012 15:20:25 -0500
Message-Id: <1329510026-30403-2-git-send-email-dros@netapp.com>
In-Reply-To: <1329510026-30403-1-git-send-email-dros@netapp.com>
References: <1329510026-30403-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

server_scope would never be freed if nfs4_check_cl_exchange_flags() returned
non-zero

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
This should be pushed to stable@vger.kernel.org

 fs/nfs/nfs4proc.c |   15 +++++++++------
 1 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 87c584d..20c3bb0 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4945,8 +4945,10 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 				clp->cl_rpcclient->cl_auth->au_flavor);
 
 	res.server_scope = kzalloc(sizeof(struct server_scope), GFP_KERNEL);
-	if (unlikely(!res.server_scope))
-		return -ENOMEM;
+	if (unlikely(!res.server_scope)) {
+		status = -ENOMEM;
+		goto out;
+	}
 
 	status = rpc_call_sync(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
 	if (!status)
@@ -4963,12 +4965,13 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 			clp->server_scope = NULL;
 		}
 
-		if (!clp->server_scope)
+		if (!clp->server_scope) {
 			clp->server_scope = res.server_scope;
-		else
-			kfree(res.server_scope);
+			goto out;
+		}
 	}
-
+	kfree(res.server_scope);
+out:
 	dprintk("<-- %s status= %d\n", __func__, status);
 	return status;
 }
-- 
1.7.4.4


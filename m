Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33234 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753074AbbGADzC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Jun 2015 23:55:02 -0400
Received: by pacws9 with SMTP id ws9so16149700pac.0
        for <linux-nfs@vger.kernel.org>; Tue, 30 Jun 2015 20:55:02 -0700 (PDT)
Message-ID: <5593648D.7020804@gmail.com>
Date: Wed, 01 Jul 2015 11:54:53 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
Subject: [PATCH 1/8] nfs: Fix a memory leak when meeting an unsupported state
 protect
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/nfs4proc.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 55e1e3a..f1e0843 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6885,7 +6885,7 @@ static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
 		/* unsupported! */
 		WARN_ON_ONCE(1);
 		status = -EINVAL;
-		goto out_server_scope;
+		goto out_impl_id;
 	}
 
 	status = rpc_call_sync(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
@@ -6913,6 +6913,7 @@ static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
 		/* use the most recent implementation id */
 		kfree(clp->cl_implid);
 		clp->cl_implid = res.impl_id;
+		res.impl_id = NULL;
 
 		if (clp->cl_serverscope != NULL &&
 		    !nfs41_same_server_scope(clp->cl_serverscope,
@@ -6926,15 +6927,16 @@ static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
 
 		if (clp->cl_serverscope == NULL) {
 			clp->cl_serverscope = res.server_scope;
-			goto out;
+			res.server_scope = NULL;
 		}
-	} else
-		kfree(res.impl_id);
+	}
 
-out_server_owner:
-	kfree(res.server_owner);
+out_impl_id:
+	kfree(res.impl_id);
 out_server_scope:
 	kfree(res.server_scope);
+out_server_owner:
+	kfree(res.server_owner);
 out:
 	if (clp->cl_implid != NULL)
 		dprintk("NFS reply exchange_id: Server Implementation ID: "
-- 
2.4.3


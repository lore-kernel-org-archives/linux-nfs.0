Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:58254 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755790Ab3GVQmP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Jul 2013 12:42:15 -0400
From: <andros@netapp.com>
To: <trond.myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/4] NFSv4.1 Use the mount point rpc_clnt for layoutreturn
Date: Mon, 22 Jul 2013 12:42:05 -0400
Message-ID: <1374511328-49579-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Should not use the clientid maintenance rpc_clnt.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index cf11799..7a846b6 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6876,7 +6876,7 @@ int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp)
 		.rpc_cred = lrp->cred,
 	};
 	struct rpc_task_setup task_setup_data = {
-		.rpc_client = lrp->clp->cl_rpcclient,
+		.rpc_client = NFS_SERVER(lrp->args.inode)->client,
 		.rpc_message = &msg,
 		.callback_ops = &nfs4_layoutreturn_call_ops,
 		.callback_data = lrp,
-- 
1.8.3.1


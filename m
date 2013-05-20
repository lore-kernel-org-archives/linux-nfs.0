Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:9896 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755487Ab3ETRRl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 May 2013 13:17:41 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/6] NFSv4.1: Ensure that layoutreturn uses the correct credential
Date: Mon, 20 May 2013 13:17:03 -0400
Message-Id: <1369070227-40671-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1369070227-40671-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1369070227-40671-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We need to use the same credential as was used for the layoutget
and/or layoutcommit operations.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c | 1 +
 fs/nfs/pnfs.c     | 1 +
 2 files changed, 2 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index a05397b..2956973 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6452,6 +6452,7 @@ int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp)
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_LAYOUTRETURN],
 		.rpc_argp = &lrp->args,
 		.rpc_resp = &lrp->res,
+		.rpc_cred = lrp->cred,
 	};
 	struct rpc_task_setup task_setup_data = {
 		.rpc_client = lrp->clp->cl_rpcclient,
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 2f86115..89ca75f 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -861,6 +861,7 @@ _pnfs_return_layout(struct inode *ino)
 	lrp->args.inode = ino;
 	lrp->args.layout = lo;
 	lrp->clp = NFS_SERVER(ino)->nfs_client;
+	lrp->cred = lo->plh_lc_cred;
 
 	status = nfs4_proc_layoutreturn(lrp);
 out:
-- 
1.8.1.4


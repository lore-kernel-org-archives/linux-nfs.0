Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:9896 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757519Ab3ETRRg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 May 2013 13:17:36 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/6] NFSv4.1: Ensure that layoutget is called using the layout credential
Date: Mon, 20 May 2013 13:17:02 -0400
Message-Id: <1369070227-40671-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that we use the same credential for layoutget, layoutcommit and
layoutreturn.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c       | 1 +
 fs/nfs/pnfs.c           | 1 +
 include/linux/nfs_xdr.h | 1 +
 3 files changed, 3 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8fbc100..a05397b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6348,6 +6348,7 @@ nfs4_proc_layoutget(struct nfs4_layoutget *lgp, gfp_t gfp_flags)
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_LAYOUTGET],
 		.rpc_argp = &lgp->args,
 		.rpc_resp = &lgp->res,
+		.rpc_cred = lgp->cred,
 	};
 	struct rpc_task_setup task_setup_data = {
 		.rpc_client = server->client,
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index c5bd758e..2f86115 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -766,6 +766,7 @@ send_layoutget(struct pnfs_layout_hdr *lo,
 	lgp->args.inode = ino;
 	lgp->args.ctx = get_nfs_open_context(ctx);
 	lgp->gfp_flags = gfp_flags;
+	lgp->cred = lo->plh_lc_cred;
 
 	/* Synchronously retrieve layout information from server and
 	 * store in lseg.
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 104b62f..32c95d6 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -246,6 +246,7 @@ struct nfs4_layoutget_res {
 struct nfs4_layoutget {
 	struct nfs4_layoutget_args args;
 	struct nfs4_layoutget_res res;
+	struct rpc_cred *cred;
 	gfp_t gfp_flags;
 };
 
-- 
1.8.1.4


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33429 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756715AbeFOWnA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Jun 2018 18:43:00 -0400
Received: by mail-io0-f194.google.com with SMTP id d185-v6so12089403ioe.0
        for <linux-nfs@vger.kernel.org>; Fri, 15 Jun 2018 15:43:00 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (50-124-245-47.alma.mi.frontiernet.net. [50.124.245.47])
        by smtp.gmail.com with ESMTPSA id b100-v6sm1498214itd.16.2018.06.15.15.42.58
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 15 Jun 2018 15:42:58 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] pNFS: Don't send layoutreturn if the layout is already invalid
Date: Fri, 15 Jun 2018 18:42:34 -0400
Message-Id: <20180615224234.62723-2-trond.myklebust@hammerspace.com>
In-Reply-To: <20180615224234.62723-1-trond.myklebust@hammerspace.com>
References: <20180615224234.62723-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the layout was invalidated due to a reboot, then don't try to send
a layoutreturn for it.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs4proc.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 2c8c2696415e..6dd146885da9 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3294,6 +3294,7 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 	struct nfs4_closedata *calldata = data;
 	struct nfs4_state *state = calldata->state;
 	struct inode *inode = calldata->inode;
+	struct pnfs_layout_hdr *lo;
 	bool is_rdonly, is_wronly, is_rdwr;
 	int call_close = 0;
 
@@ -3337,6 +3338,12 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 		goto out_wait;
 	}
 
+	lo = calldata->arg.lr_args ? calldata->arg.lr_args->layout : NULL;
+	if (lo && !pnfs_layout_is_valid(lo)) {
+		calldata->arg.lr_args = NULL;
+		calldata->res.lr_res = NULL;
+	}
+
 	if (calldata->arg.fmode == 0)
 		task->tk_msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_CLOSE];
 
@@ -5972,12 +5979,19 @@ static void nfs4_delegreturn_release(void *calldata)
 static void nfs4_delegreturn_prepare(struct rpc_task *task, void *data)
 {
 	struct nfs4_delegreturndata *d_data;
+	struct pnfs_layout_hdr *lo;
 
 	d_data = (struct nfs4_delegreturndata *)data;
 
 	if (!d_data->lr.roc && nfs4_wait_on_layoutreturn(d_data->inode, task))
 		return;
 
+	lo = d_data->args.lr_args ? d_data->args.lr_args->layout : NULL;
+	if (lo && !pnfs_layout_is_valid(lo)) {
+		d_data->args.lr_args = NULL;
+		d_data->res.lr_res = NULL;
+	}
+
 	nfs4_setup_sequence(d_data->res.server->nfs_client,
 			&d_data->args.seq_args,
 			&d_data->res.seq_res,
@@ -8820,6 +8834,8 @@ nfs4_layoutreturn_prepare(struct rpc_task *task, void *calldata)
 			&lrp->args.seq_args,
 			&lrp->res.seq_res,
 			task);
+	if (!pnfs_layout_is_valid(lrp->args.layout))
+		rpc_exit(task, 0);
 }
 
 static void nfs4_layoutreturn_done(struct rpc_task *task, void *calldata)
-- 
2.17.1


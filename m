Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:33257 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756519AbeFOWm7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Jun 2018 18:42:59 -0400
Received: by mail-it0-f68.google.com with SMTP id k17-v6so6346618ita.0
        for <linux-nfs@vger.kernel.org>; Fri, 15 Jun 2018 15:42:59 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (50-124-245-47.alma.mi.frontiernet.net. [50.124.245.47])
        by smtp.gmail.com with ESMTPSA id b100-v6sm1498214itd.16.2018.06.15.15.42.56
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 15 Jun 2018 15:42:57 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] pNFS: Always free the session slot on error in nfs4_layoutget_handle_exception
Date: Fri, 15 Jun 2018 18:42:33 -0400
Message-Id: <20180615224234.62723-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Right now, we can call nfs_commit_inode() while holding the session slot,
which could lead to NFSv4 deadlocks. Ensure we only keep the slot if
the server returned a layout that we have to process.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs4proc.c | 17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ed45090e4df6..2c8c2696415e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -8650,6 +8650,8 @@ nfs4_layoutget_handle_exception(struct rpc_task *task,
 
 	dprintk("--> %s tk_status => %d\n", __func__, -task->tk_status);
 
+	nfs4_sequence_free_slot(&lgp->res.seq_res);
+
 	switch (nfs4err) {
 	case 0:
 		goto out;
@@ -8714,7 +8716,6 @@ nfs4_layoutget_handle_exception(struct rpc_task *task,
 		goto out;
 	}
 
-	nfs4_sequence_free_slot(&lgp->res.seq_res);
 	err = nfs4_handle_exception(server, nfs4err, exception);
 	if (!status) {
 		if (exception->retry)
@@ -8786,20 +8787,22 @@ nfs4_proc_layoutget(struct nfs4_layoutget *lgp, long *timeout)
 	if (IS_ERR(task))
 		return ERR_CAST(task);
 	status = rpc_wait_for_completion_task(task);
-	if (status == 0) {
+	if (status != 0)
+		goto out;
+
+	/* if layoutp->len is 0, nfs4_layoutget_prepare called rpc_exit */
+	if (task->tk_status < 0 || lgp->res.layoutp->len == 0) {
 		status = nfs4_layoutget_handle_exception(task, lgp, &exception);
 		*timeout = exception.timeout;
-	}
-
+	} else
+		lseg = pnfs_layout_process(lgp);
+out:
 	trace_nfs4_layoutget(lgp->args.ctx,
 			&lgp->args.range,
 			&lgp->res.range,
 			&lgp->res.stateid,
 			status);
 
-	/* if layoutp->len is 0, nfs4_layoutget_prepare called rpc_exit */
-	if (status == 0 && lgp->res.layoutp->len)
-		lseg = pnfs_layout_process(lgp);
 	rpc_put_task(task);
 	dprintk("<-- %s status=%d\n", __func__, status);
 	if (status)
-- 
2.17.1


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:36487 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752007AbaCDRbW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Mar 2014 12:31:22 -0500
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH 4/4] NFSv4.1 Fail data server I/O if stateid represents a lost lock
Date: Tue, 4 Mar 2014 12:31:09 -0500
Message-ID: <1393954269-3974-5-git-send-email-andros@netapp.com>
In-Reply-To: <1393954269-3974-1-git-send-email-andros@netapp.com>
References: <1393954269-3974-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 12c8132..66da1e4 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -324,8 +324,9 @@ static void filelayout_read_prepare(struct rpc_task *task, void *data)
 			&rdata->res.seq_res,
 			task))
 		return;
-	nfs4_set_rw_stateid(&rdata->args.stateid, rdata->args.context,
-			rdata->args.lock_context, FMODE_READ);
+	if (nfs4_set_rw_stateid(&rdata->args.stateid, rdata->args.context,
+			rdata->args.lock_context, FMODE_READ) == -EIO)
+		rpc_exit(task, -EIO); /* lost lock, terminate I/O */
 }
 
 static void filelayout_read_call_done(struct rpc_task *task, void *data)
@@ -435,8 +436,9 @@ static void filelayout_write_prepare(struct rpc_task *task, void *data)
 			&wdata->res.seq_res,
 			task))
 		return;
-	nfs4_set_rw_stateid(&wdata->args.stateid, wdata->args.context,
-			wdata->args.lock_context, FMODE_WRITE);
+	if (nfs4_set_rw_stateid(&wdata->args.stateid, wdata->args.context,
+			wdata->args.lock_context, FMODE_WRITE))
+		rpc_exit(task, -EIO); /* lost lock, terminate I/O */
 }
 
 static void filelayout_write_call_done(struct rpc_task *task, void *data)
-- 
1.8.3.1


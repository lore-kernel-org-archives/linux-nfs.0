Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f175.google.com ([209.85.213.175]:41458 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753269AbaCDTFs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Mar 2014 14:05:48 -0500
Received: by mail-ig0-f175.google.com with SMTP id ur14so5919146igb.2
        for <linux-nfs@vger.kernel.org>; Tue, 04 Mar 2014 11:05:48 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Andy Adamson <andros@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/3] NFSv4.1 Fail data server I/O if stateid represents a lost lock
Date: Tue,  4 Mar 2014 14:05:42 -0500
Message-Id: <1393959943-9919-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1393959943-9919-2-git-send-email-trond.myklebust@primarydata.com>
References: <1393954269-3974-1-git-send-email-andros@netapp.com>
 <1393959943-9919-1-git-send-email-trond.myklebust@primarydata.com>
 <1393959943-9919-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
Link: http://lkml.kernel.org/r/1393954269-3974-1-git-send-email-andros@netapp.com
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4filelayout.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 12c8132ad408..b9a35c05b60f 100644
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
+			wdata->args.lock_context, FMODE_WRITE) == -EIO)
+		rpc_exit(task, -EIO); /* lost lock, terminate I/O */
 }
 
 static void filelayout_write_call_done(struct rpc_task *task, void *data)
-- 
1.8.5.3


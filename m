Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:35294 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726889AbeIQSbP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Sep 2018 14:31:15 -0400
Received: by mail-qt0-f193.google.com with SMTP id j7-v6so15155481qtp.2
        for <linux-nfs@vger.kernel.org>; Mon, 17 Sep 2018 06:04:00 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain ([66.187.232.65])
        by smtp.gmail.com with ESMTPSA id q1-v6sm10499607qkl.31.2018.09.17.06.03.58
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Sep 2018 06:03:58 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 02/44] SUNRPC: If there is no reply expected, bail early from call_decode
Date: Mon, 17 Sep 2018 09:02:53 -0400
Message-Id: <20180917130335.112832-3-trond.myklebust@hammerspace.com>
In-Reply-To: <20180917130335.112832-2-trond.myklebust@hammerspace.com>
References: <20180917130335.112832-1-trond.myklebust@hammerspace.com>
 <20180917130335.112832-2-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/clnt.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index bc9d020bf71f..4f1ec8013332 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2260,6 +2260,11 @@ call_decode(struct rpc_task *task)
 
 	dprint_status(task);
 
+	if (!decode) {
+		task->tk_action = rpc_exit_task;
+		return;
+	}
+
 	if (task->tk_flags & RPC_CALL_MAJORSEEN) {
 		if (clnt->cl_chatty) {
 			printk(KERN_NOTICE "%s: server %s OK\n",
@@ -2297,13 +2302,11 @@ call_decode(struct rpc_task *task)
 			goto out_retry;
 		return;
 	}
-
 	task->tk_action = rpc_exit_task;
 
-	if (decode) {
-		task->tk_status = rpcauth_unwrap_resp(task, decode, req, p,
-						      task->tk_msg.rpc_resp);
-	}
+	task->tk_status = rpcauth_unwrap_resp(task, decode, req, p,
+					      task->tk_msg.rpc_resp);
+
 	dprintk("RPC: %5u call_decode result %d\n", task->tk_pid,
 			task->tk_status);
 	return;
-- 
2.17.1

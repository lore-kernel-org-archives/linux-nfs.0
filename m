Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:38753 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726314AbeICTul (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Sep 2018 15:50:41 -0400
Received: by mail-io0-f195.google.com with SMTP id y3-v6so691189ioc.5
        for <linux-nfs@vger.kernel.org>; Mon, 03 Sep 2018 08:30:01 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id c25-v6sm7040027iob.30.2018.09.03.08.30.00
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Sep 2018 08:30:00 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 02/27] SUNRPC: If there is no reply expected, bail early from call_decode
Date: Mon,  3 Sep 2018 11:29:11 -0400
Message-Id: <20180903152936.24325-3-trond.myklebust@hammerspace.com>
In-Reply-To: <20180903152936.24325-2-trond.myklebust@hammerspace.com>
References: <20180903152936.24325-1-trond.myklebust@hammerspace.com>
 <20180903152936.24325-2-trond.myklebust@hammerspace.com>
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

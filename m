Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f181.google.com ([209.85.216.181]:36252 "EHLO
        mail-qt0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728299AbeIQSbs (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Sep 2018 14:31:48 -0400
Received: by mail-qt0-f181.google.com with SMTP id t5-v6so15140801qtn.3
        for <linux-nfs@vger.kernel.org>; Mon, 17 Sep 2018 06:04:33 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain ([66.187.232.65])
        by smtp.gmail.com with ESMTPSA id q1-v6sm10499607qkl.31.2018.09.17.06.04.30
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Sep 2018 06:04:31 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 30/44] SUNRPC: Allow soft RPC calls to time out when waiting for the XPRT_LOCK
Date: Mon, 17 Sep 2018 09:03:21 -0400
Message-Id: <20180917130335.112832-31-trond.myklebust@hammerspace.com>
In-Reply-To: <20180917130335.112832-30-trond.myklebust@hammerspace.com>
References: <20180917130335.112832-1-trond.myklebust@hammerspace.com>
 <20180917130335.112832-2-trond.myklebust@hammerspace.com>
 <20180917130335.112832-3-trond.myklebust@hammerspace.com>
 <20180917130335.112832-4-trond.myklebust@hammerspace.com>
 <20180917130335.112832-5-trond.myklebust@hammerspace.com>
 <20180917130335.112832-6-trond.myklebust@hammerspace.com>
 <20180917130335.112832-7-trond.myklebust@hammerspace.com>
 <20180917130335.112832-8-trond.myklebust@hammerspace.com>
 <20180917130335.112832-9-trond.myklebust@hammerspace.com>
 <20180917130335.112832-10-trond.myklebust@hammerspace.com>
 <20180917130335.112832-11-trond.myklebust@hammerspace.com>
 <20180917130335.112832-12-trond.myklebust@hammerspace.com>
 <20180917130335.112832-13-trond.myklebust@hammerspace.com>
 <20180917130335.112832-14-trond.myklebust@hammerspace.com>
 <20180917130335.112832-15-trond.myklebust@hammerspace.com>
 <20180917130335.112832-16-trond.myklebust@hammerspace.com>
 <20180917130335.112832-17-trond.myklebust@hammerspace.com>
 <20180917130335.112832-18-trond.myklebust@hammerspace.com>
 <20180917130335.112832-19-trond.myklebust@hammerspace.com>
 <20180917130335.112832-20-trond.myklebust@hammerspace.com>
 <20180917130335.112832-21-trond.myklebust@hammerspace.com>
 <20180917130335.112832-22-trond.myklebust@hammerspace.com>
 <20180917130335.112832-23-trond.myklebust@hammerspace.com>
 <20180917130335.112832-24-trond.myklebust@hammerspace.com>
 <20180917130335.112832-25-trond.myklebust@hammerspace.com>
 <20180917130335.112832-26-trond.myklebust@hammerspace.com>
 <20180917130335.112832-27-trond.myklebust@hammerspace.com>
 <20180917130335.112832-28-trond.myklebust@hammerspace.com>
 <20180917130335.112832-29-trond.myklebust@hammerspace.com>
 <20180917130335.112832-30-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This no longer causes them to lose their place in the transmission queue.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/xprt.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index ae1109c7b9b4..a523e59a074e 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -195,7 +195,7 @@ int xprt_reserve_xprt(struct rpc_xprt *xprt, struct rpc_task *task)
 out_sleep:
 	dprintk("RPC: %5u failed to lock transport %p\n",
 			task->tk_pid, xprt);
-	task->tk_timeout = 0;
+	task->tk_timeout = RPC_IS_SOFT(task) ? req->rq_timeout : 0;
 	task->tk_status = -EAGAIN;
 	if (req == NULL)
 		priority = RPC_PRIORITY_LOW;
@@ -274,7 +274,7 @@ int xprt_reserve_xprt_cong(struct rpc_xprt *xprt, struct rpc_task *task)
 	xprt_clear_locked(xprt);
 out_sleep:
 	dprintk("RPC: %5u failed to lock transport %p\n", task->tk_pid, xprt);
-	task->tk_timeout = 0;
+	task->tk_timeout = RPC_IS_SOFT(task) ? req->rq_timeout : 0;
 	task->tk_status = -EAGAIN;
 	if (req == NULL)
 		priority = RPC_PRIORITY_LOW;
-- 
2.17.1

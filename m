Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:42345 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728229AbeIQSbn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Sep 2018 14:31:43 -0400
Received: by mail-qt0-f193.google.com with SMTP id z8-v6so15110760qto.9
        for <linux-nfs@vger.kernel.org>; Mon, 17 Sep 2018 06:04:27 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain ([66.187.232.65])
        by smtp.gmail.com with ESMTPSA id q1-v6sm10499607qkl.31.2018.09.17.06.04.25
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Sep 2018 06:04:26 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 25/44] SUNRPC: Move RPC retransmission stat counter to xprt_transmit()
Date: Mon, 17 Sep 2018 09:03:16 -0400
Message-Id: <20180917130335.112832-26-trond.myklebust@hammerspace.com>
In-Reply-To: <20180917130335.112832-25-trond.myklebust@hammerspace.com>
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
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/clnt.c |  6 ------
 net/sunrpc/xprt.c | 19 ++++++++++++-------
 2 files changed, 12 insertions(+), 13 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 4ca23a6607ba..8dc3d33827c4 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1962,8 +1962,6 @@ call_connect_status(struct rpc_task *task)
 static void
 call_transmit(struct rpc_task *task)
 {
-	int is_retrans = RPC_WAS_SENT(task);
-
 	dprint_status(task);
 
 	task->tk_action = call_transmit_status;
@@ -1973,10 +1971,6 @@ call_transmit(struct rpc_task *task)
 	if (!xprt_prepare_transmit(task))
 		return;
 	xprt_transmit(task);
-	if (task->tk_status < 0)
-		return;
-	if (is_retrans)
-		task->tk_client->cl_stats->rpcretrans++;
 }
 
 /*
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 385ee9f64353..35f5df367591 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -191,8 +191,6 @@ int xprt_reserve_xprt(struct rpc_xprt *xprt, struct rpc_task *task)
 		goto out_sleep;
 	}
 	xprt->snd_task = task;
-	if (req != NULL)
-		req->rq_ntrans++;
 
 	return 1;
 
@@ -247,7 +245,6 @@ int xprt_reserve_xprt_cong(struct rpc_xprt *xprt, struct rpc_task *task)
 	}
 	if (__xprt_get_cong(xprt, task)) {
 		xprt->snd_task = task;
-		req->rq_ntrans++;
 		return 1;
 	}
 	xprt_clear_locked(xprt);
@@ -281,12 +278,8 @@ static inline int xprt_lock_write(struct rpc_xprt *xprt, struct rpc_task *task)
 static bool __xprt_lock_write_func(struct rpc_task *task, void *data)
 {
 	struct rpc_xprt *xprt = data;
-	struct rpc_rqst *req;
 
-	req = task->tk_rqstp;
 	xprt->snd_task = task;
-	if (req)
-		req->rq_ntrans++;
 	return true;
 }
 
@@ -1152,6 +1145,7 @@ void xprt_transmit(struct rpc_task *task)
 	struct rpc_rqst	*req = task->tk_rqstp;
 	struct rpc_xprt	*xprt = req->rq_xprt;
 	unsigned int connect_cookie;
+	int is_retrans = RPC_WAS_SENT(task);
 	int status;
 
 	dprintk("RPC: %5u xprt_transmit(%u)\n", task->tk_pid, req->rq_slen);
@@ -1166,14 +1160,25 @@ void xprt_transmit(struct rpc_task *task)
 		}
 	}
 
+	/*
+	 * Update req->rq_ntrans before transmitting to avoid races with
+	 * xprt_update_rtt(), which needs to know that it is recording a
+	 * reply to the first transmission.
+	 */
+	req->rq_ntrans++;
+
 	connect_cookie = xprt->connect_cookie;
 	status = xprt->ops->send_request(req, task);
 	trace_xprt_transmit(xprt, req->rq_xid, status);
 	if (status != 0) {
+		req->rq_ntrans--;
 		task->tk_status = status;
 		return;
 	}
 
+	if (is_retrans)
+		task->tk_client->cl_stats->rpcretrans++;
+
 	xprt_inject_disconnect(xprt);
 
 	dprintk("RPC: %5u xmit complete\n", task->tk_pid);
-- 
2.17.1

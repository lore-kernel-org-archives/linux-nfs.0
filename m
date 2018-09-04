Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:36063 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725825AbeIEBdU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Sep 2018 21:33:20 -0400
Received: by mail-io0-f196.google.com with SMTP id q5-v6so4239093iop.3
        for <linux-nfs@vger.kernel.org>; Tue, 04 Sep 2018 14:06:28 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id t64-v6sm172860ita.13.2018.09.04.14.06.27
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Sep 2018 14:06:27 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 23/34] SUNRPC: Move RPC retransmission stat counter to xprt_transmit()
Date: Tue,  4 Sep 2018 17:05:38 -0400
Message-Id: <20180904210549.81673-24-trond.myklebust@hammerspace.com>
In-Reply-To: <20180904210549.81673-23-trond.myklebust@hammerspace.com>
References: <20180904210549.81673-1-trond.myklebust@hammerspace.com>
 <20180904210549.81673-2-trond.myklebust@hammerspace.com>
 <20180904210549.81673-3-trond.myklebust@hammerspace.com>
 <20180904210549.81673-4-trond.myklebust@hammerspace.com>
 <20180904210549.81673-5-trond.myklebust@hammerspace.com>
 <20180904210549.81673-6-trond.myklebust@hammerspace.com>
 <20180904210549.81673-7-trond.myklebust@hammerspace.com>
 <20180904210549.81673-8-trond.myklebust@hammerspace.com>
 <20180904210549.81673-9-trond.myklebust@hammerspace.com>
 <20180904210549.81673-10-trond.myklebust@hammerspace.com>
 <20180904210549.81673-11-trond.myklebust@hammerspace.com>
 <20180904210549.81673-12-trond.myklebust@hammerspace.com>
 <20180904210549.81673-13-trond.myklebust@hammerspace.com>
 <20180904210549.81673-14-trond.myklebust@hammerspace.com>
 <20180904210549.81673-15-trond.myklebust@hammerspace.com>
 <20180904210549.81673-16-trond.myklebust@hammerspace.com>
 <20180904210549.81673-17-trond.myklebust@hammerspace.com>
 <20180904210549.81673-18-trond.myklebust@hammerspace.com>
 <20180904210549.81673-19-trond.myklebust@hammerspace.com>
 <20180904210549.81673-20-trond.myklebust@hammerspace.com>
 <20180904210549.81673-21-trond.myklebust@hammerspace.com>
 <20180904210549.81673-22-trond.myklebust@hammerspace.com>
 <20180904210549.81673-23-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/clnt.c |  6 ------
 net/sunrpc/xprt.c | 13 ++++++-------
 2 files changed, 6 insertions(+), 13 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 032b7042adb6..21713bed812a 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1967,8 +1967,6 @@ call_connect_status(struct rpc_task *task)
 static void
 call_transmit(struct rpc_task *task)
 {
-	int is_retrans = RPC_WAS_SENT(task);
-
 	dprint_status(task);
 
 	task->tk_action = call_transmit_status;
@@ -1979,10 +1977,6 @@ call_transmit(struct rpc_task *task)
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
index f1301d391399..e2f5b4668a66 100644
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
 
@@ -1126,6 +1119,7 @@ void xprt_transmit(struct rpc_task *task)
 	struct rpc_rqst	*req = task->tk_rqstp;
 	struct rpc_xprt	*xprt = req->rq_xprt;
 	unsigned int connect_cookie;
+	int is_retrans = RPC_WAS_SENT(task);
 	int status;
 
 	dprintk("RPC: %5u xprt_transmit(%u)\n", task->tk_pid, req->rq_slen);
@@ -1140,6 +1134,8 @@ void xprt_transmit(struct rpc_task *task)
 		}
 	}
 
+	req->rq_ntrans++;
+
 	connect_cookie = xprt->connect_cookie;
 	status = xprt->ops->send_request(req, task);
 	trace_xprt_transmit(xprt, req->rq_xid, status);
@@ -1148,6 +1144,9 @@ void xprt_transmit(struct rpc_task *task)
 		return;
 	}
 
+	if (is_retrans)
+		task->tk_client->cl_stats->rpcretrans++;
+
 	xprt_inject_disconnect(xprt);
 
 	dprintk("RPC: %5u xmit complete\n", task->tk_pid);
-- 
2.17.1

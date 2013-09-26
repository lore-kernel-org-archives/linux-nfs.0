Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:18807 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754645Ab3IZVpY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Sep 2013 17:45:24 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH 7/7] SUNRPC: Fix RPC call retransmission statistics
Date: Thu, 26 Sep 2013 17:45:06 -0400
Message-ID: <1380231907-13733-8-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1380231907-13733-7-git-send-email-Trond.Myklebust@netapp.com>
References: <1380231907-13733-1-git-send-email-Trond.Myklebust@netapp.com>
 <1380231907-13733-2-git-send-email-Trond.Myklebust@netapp.com>
 <1380231907-13733-3-git-send-email-Trond.Myklebust@netapp.com>
 <1380231907-13733-4-git-send-email-Trond.Myklebust@netapp.com>
 <1380231907-13733-5-git-send-email-Trond.Myklebust@netapp.com>
 <1380231907-13733-6-git-send-email-Trond.Myklebust@netapp.com>
 <1380231907-13733-7-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A retransmit should be when you successfully transmit an RPC call to
the server a second time.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/clnt.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index b585250..46d061f 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1719,6 +1719,8 @@ call_connect_status(struct rpc_task *task)
 static void
 call_transmit(struct rpc_task *task)
 {
+	bool is_retrans = (task->tk_flags & RPC_TASK_SENT) != 0;
+
 	dprint_status(task);
 
 	task->tk_action = call_status;
@@ -1743,6 +1745,8 @@ call_transmit(struct rpc_task *task)
 	xprt_transmit(task);
 	if (task->tk_status < 0)
 		return;
+	if (is_retrans)
+		task->tk_client->cl_stats->rpcretrans++;
 	/*
 	 * On success, ensure that we call xprt_end_transmit() before sleeping
 	 * in order to allow access to the socket to other RPC requests.
@@ -1983,7 +1987,6 @@ call_timeout(struct rpc_task *task)
 	rpcauth_invalcred(task);
 
 retry:
-	clnt->cl_stats->rpcretrans++;
 	task->tk_action = call_bind;
 	task->tk_status = 0;
 }
@@ -2026,7 +2029,6 @@ call_decode(struct rpc_task *task)
 	if (req->rq_rcv_buf.len < 12) {
 		if (!RPC_IS_SOFT(task)) {
 			task->tk_action = call_bind;
-			clnt->cl_stats->rpcretrans++;
 			goto out_retry;
 		}
 		dprintk("RPC:       %s: too small RPC reply size (%d bytes)\n",
-- 
1.8.3.1


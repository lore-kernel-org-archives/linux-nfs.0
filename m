Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:18807 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754643Ab3IZVpZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Sep 2013 17:45:25 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH] SUNRPC: call_connect_status should recheck bind and connect status on error
Date: Thu, 26 Sep 2013 17:45:07 -0400
Message-ID: <1380231907-13733-9-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1380231907-13733-8-git-send-email-Trond.Myklebust@netapp.com>
References: <1380231907-13733-1-git-send-email-Trond.Myklebust@netapp.com>
 <1380231907-13733-2-git-send-email-Trond.Myklebust@netapp.com>
 <1380231907-13733-3-git-send-email-Trond.Myklebust@netapp.com>
 <1380231907-13733-4-git-send-email-Trond.Myklebust@netapp.com>
 <1380231907-13733-5-git-send-email-Trond.Myklebust@netapp.com>
 <1380231907-13733-6-git-send-email-Trond.Myklebust@netapp.com>
 <1380231907-13733-7-git-send-email-Trond.Myklebust@netapp.com>
 <1380231907-13733-8-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, we go directly to call_transmit which sends us to call_status
on error. If we know that the connect attempt failed, we should rather
just jump straight back to call_bind and/or call_transmit

Also ensure that EAGAIN checks for a timeout event.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/clnt.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 46d061f..6ebf74c 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1692,20 +1692,23 @@ call_connect_status(struct rpc_task *task)
 	dprint_status(task);
 
 	trace_rpc_connect_status(task, status);
+	task->tk_status = 0;
 	switch (status) {
 		/* if soft mounted, test if we've timed out */
+	case -EAGAIN:
 	case -ETIMEDOUT:
 		task->tk_action = call_timeout;
 		return;
 	case -ECONNREFUSED:
 	case -ECONNRESET:
 	case -ENETUNREACH:
+		/* retry with existing socket, after a delay */
+		rpc_delay(task, 3*HZ);
 		if (RPC_IS_SOFTCONN(task))
 			break;
-		/* retry with existing socket, after a delay */
+		task->tk_action = call_bind;
+		return;
 	case 0:
-	case -EAGAIN:
-		task->tk_status = 0;
 		clnt->cl_stats->netreconn++;
 		task->tk_action = call_transmit;
 		return;
-- 
1.8.3.1


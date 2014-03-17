Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f182.google.com ([209.85.223.182]:56701 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750920AbaCQSku (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Mar 2014 14:40:50 -0400
Received: by mail-ie0-f182.google.com with SMTP id y20so5932573ier.13
        for <linux-nfs@vger.kernel.org>; Mon, 17 Mar 2014 11:40:50 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] SUNRPC: Ensure that call_connect times out correctly
Date: Mon, 17 Mar 2014 14:40:44 -0400
Message-Id: <1395081645-11906-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When the server is unavailable due to a networking error, etc, we want
the RPC client to respect the timeout delays when attempting to reconnect.

Fixes: 561ec1603171 (SUNRPC: call_connect_status should recheck bind..)
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/clnt.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 0edada973434..f22d3a115fda 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1798,10 +1798,6 @@ call_connect_status(struct rpc_task *task)
 	trace_rpc_connect_status(task, status);
 	task->tk_status = 0;
 	switch (status) {
-		/* if soft mounted, test if we've timed out */
-	case -ETIMEDOUT:
-		task->tk_action = call_timeout;
-		return;
 	case -ECONNREFUSED:
 	case -ECONNRESET:
 	case -ECONNABORTED:
@@ -1812,7 +1808,9 @@ call_connect_status(struct rpc_task *task)
 		if (RPC_IS_SOFTCONN(task))
 			break;
 	case -EAGAIN:
-		task->tk_action = call_bind;
+	case -ETIMEDOUT:
+		/* Check if we've timed out before looping back to call_bind */
+		task->tk_action = call_timeout;
 		return;
 	case 0:
 		clnt->cl_stats->netreconn++;
-- 
1.8.5.3


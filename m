From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 7/7] SUNRPC: Remove obsolete messages during transport connect
Date: Wed, 11 Jun 2008 17:56:13 -0400
Message-ID: <20080611215612.7068.32804.stgit@ellison.1015granger.net>
References: <20080611215018.7068.71737.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:34543 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753058AbYFKV5t (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Jun 2008 17:57:49 -0400
In-Reply-To: <20080611215018.7068.71737.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Recent changes to the RPC client's transport connect logic make connect
status values ECONNREFUSED and ECONNRESET impossible.

Clean up xprt_connect_status() to account for these changes.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprt.c |    8 +-------
 1 files changed, 1 insertions(+), 7 deletions(-)


diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index cbaefd8..99a52aa 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -690,7 +690,7 @@ static void xprt_connect_status(struct rpc_task *task)
 {
 	struct rpc_xprt	*xprt = task->tk_xprt;
 
-	if (task->tk_status >= 0) {
+	if (task->tk_status == 0) {
 		xprt->stat.connect_count++;
 		xprt->stat.connect_time += (long)jiffies - xprt->stat.connect_start;
 		dprintk("RPC: %5u xprt_connect_status: connection established\n",
@@ -699,12 +699,6 @@ static void xprt_connect_status(struct rpc_task *task)
 	}
 
 	switch (task->tk_status) {
-	case -ECONNREFUSED:
-	case -ECONNRESET:
-		dprintk("RPC: %5u xprt_connect_status: server %s refused "
-				"connection\n", task->tk_pid,
-				task->tk_client->cl_server);
-		break;
 	case -ENOTCONN:
 		dprintk("RPC: %5u xprt_connect_status: connection broken\n",
 				task->tk_pid);


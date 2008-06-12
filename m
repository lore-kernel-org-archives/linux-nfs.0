From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 22/37] SUNRPC: Remove obsolete messages during transport
	connect
Date: Thu, 12 Jun 2008 15:22:01 -0400
Message-ID: <20080612192201.24528.25194.stgit@localhost.localdomain>
References: <20080612192159.24528.43756.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:40624 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755084AbYFLTeG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jun 2008 15:34:06 -0400
In-Reply-To: <20080612192159.24528.43756.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Recent changes to the RPC client's transport connect logic make connect
status values ECONNREFUSED and ECONNRESET impossible.

Clean up xprt_connect_status() to account for these changes.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/xprt.c |    8 +-------
 1 files changed, 1 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index e1770f7..67996bd 100644
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


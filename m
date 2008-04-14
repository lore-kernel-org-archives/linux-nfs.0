From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 11/24] SUNRPC: Remove obsolete messages during transport
	connect
Date: Mon, 14 Apr 2008 12:28:00 -0400
Message-ID: <20080414162759.12741.15903.stgit@manray.1015granger.net>
References: <20080414162108.12741.73233.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu, trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]:40586 "EHLO
	flpi195.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755730AbYDNRBL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Apr 2008 13:01:11 -0400
In-Reply-To: <20080414162108.12741.73233.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
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
index d5553b8..4b1dca0 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -664,7 +664,7 @@ static void xprt_connect_status(struct rpc_task *task)
 {
 	struct rpc_xprt	*xprt = task->tk_xprt;
 
-	if (task->tk_status >= 0) {
+	if (task->tk_status == 0) {
 		xprt->stat.connect_count++;
 		xprt->stat.connect_time += (long)jiffies - xprt->stat.connect_start;
 		dprintk("RPC: %5u xprt_connect_status: connection established\n",
@@ -673,12 +673,6 @@ static void xprt_connect_status(struct rpc_task *task)
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


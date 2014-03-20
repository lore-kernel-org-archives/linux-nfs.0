Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:8132 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756777AbaCTPXI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Mar 2014 11:23:08 -0400
From: Steve Dickson <steved@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] SUNRPC: Ensure call_connect_status() deals correctly with SOFTCONN tasks
Date: Thu, 20 Mar 2014 11:23:03 -0400
Message-Id: <1395328983-20477-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Don't schedule an rpc_delay before checking to see if the task
is a SOFTCON because the tk_callback from the delay (__rpc_atrun)
clears the task status before the rpc_exit_task can be run.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 net/sunrpc/clnt.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index cea1308..cb76099 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1802,10 +1802,10 @@ call_connect_status(struct rpc_task *task)
 	case -ECONNABORTED:
 	case -ENETUNREACH:
 	case -EHOSTUNREACH:
-		/* retry with existing socket, after a delay */
-		rpc_delay(task, 3*HZ);
 		if (RPC_IS_SOFTCONN(task))
 			break;
+		/* retry with existing socket, after a delay */
+		rpc_delay(task, 3*HZ);
 	case -EAGAIN:
 		/* Check for timeouts before looping back to call_bind */
 	case -ETIMEDOUT:
-- 
1.7.1


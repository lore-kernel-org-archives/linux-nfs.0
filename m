Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:11195 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754046Ab1DTXuX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Apr 2011 19:50:23 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/3] SUNRPC: Allow RPC calls to return ETIMEDOUT instead of EIO
Date: Wed, 20 Apr 2011 16:50:04 -0700
Message-Id: <1303343405-5021-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1303343405-5021-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1303343405-5021-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

On occasion, it is useful for the NFS layer to distinguish between
soft timeouts and other EIO errors due to (say) encoding errors,
or authentication errors.

The following patch ensures that the default behaviour of the RPC
layer remains to return EIO on soft timeouts (until we have
audited all the callers).

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 include/linux/sunrpc/sched.h |    3 ++-
 net/sunrpc/clnt.c            |    5 ++++-
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 3b94f80..f73c482 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -128,12 +128,13 @@ struct rpc_task_setup {
 #define RPC_TASK_SOFT		0x0200		/* Use soft timeouts */
 #define RPC_TASK_SOFTCONN	0x0400		/* Fail if can't connect */
 #define RPC_TASK_SENT		0x0800		/* message was sent */
+#define RPC_TASK_TIMEOUT	0x1000		/* fail with ETIMEDOUT on timeout */
 
 #define RPC_IS_ASYNC(t)		((t)->tk_flags & RPC_TASK_ASYNC)
 #define RPC_IS_SWAPPER(t)	((t)->tk_flags & RPC_TASK_SWAPPER)
 #define RPC_DO_ROOTOVERRIDE(t)	((t)->tk_flags & RPC_TASK_ROOTCREDS)
 #define RPC_ASSASSINATED(t)	((t)->tk_flags & RPC_TASK_KILLED)
-#define RPC_IS_SOFT(t)		((t)->tk_flags & RPC_TASK_SOFT)
+#define RPC_IS_SOFT(t)		((t)->tk_flags & (RPC_TASK_SOFT|RPC_TASK_TIMEOUT))
 #define RPC_IS_SOFTCONN(t)	((t)->tk_flags & RPC_TASK_SOFTCONN)
 #define RPC_WAS_SENT(t)		((t)->tk_flags & RPC_TASK_SENT)
 
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index e7a96e4..8d83f9d 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1508,7 +1508,10 @@ call_timeout(struct rpc_task *task)
 		if (clnt->cl_chatty)
 			printk(KERN_NOTICE "%s: server %s not responding, timed out\n",
 				clnt->cl_protname, clnt->cl_server);
-		rpc_exit(task, -EIO);
+		if (task->tk_flags & RPC_TASK_TIMEOUT)
+			rpc_exit(task, -ETIMEDOUT);
+		else
+			rpc_exit(task, -EIO);
 		return;
 	}
 
-- 
1.7.4.4


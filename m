From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/7] SUNRPC: introduce new rpc_task flag that fails requests
	on xprt disconnect
Date: Mon, 30 Jun 2008 18:39:15 -0400
Message-ID: <20080630223914.24534.30307.stgit@ellison.1015granger.net>
References: <20080630223646.24534.74654.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:11379 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764328AbYF3Wjz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2008 18:39:55 -0400
In-Reply-To: <20080630223646.24534.74654.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Introduce a new RPC client capability that allows RPC consumers to specify
that if a connection cannot be established to the remote RPC service, a
submitted request should fail immediately.

Useful for in-kernel RPC applications that want to connect and do just one
or a handful of idempotent requests, but don't want any long waits if the
remote service is not available.

No, Tom, I'm not going to call it "squishy."  :-)

Note that because the UDP transport uses an unconnected socket, this new
flag is a no-op for UDP.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/sched.h |    2 ++
 net/sunrpc/clnt.c            |    2 ++
 2 files changed, 4 insertions(+), 0 deletions(-)


diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 64981a2..dcbdb60 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -130,12 +130,14 @@ struct rpc_task_setup {
 #define RPC_TASK_DYNAMIC	0x0080		/* task was kmalloc'ed */
 #define RPC_TASK_KILLED		0x0100		/* task was killed */
 #define RPC_TASK_SOFT		0x0200		/* Use soft timeouts */
+#define RPC_TASK_ONESHOT	0x0400		/* fail if can't connect */
 
 #define RPC_IS_ASYNC(t)		((t)->tk_flags & RPC_TASK_ASYNC)
 #define RPC_IS_SWAPPER(t)	((t)->tk_flags & RPC_TASK_SWAPPER)
 #define RPC_DO_ROOTOVERRIDE(t)	((t)->tk_flags & RPC_TASK_ROOTCREDS)
 #define RPC_ASSASSINATED(t)	((t)->tk_flags & RPC_TASK_KILLED)
 #define RPC_IS_SOFT(t)		((t)->tk_flags & RPC_TASK_SOFT)
+#define RPC_IS_ONESHOT(t)	((t)->tk_flags & RPC_TASK_ONESHOT)
 
 #define RPC_TASK_RUNNING	0
 #define RPC_TASK_QUEUED		1
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 09631f6..171d53c 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1029,6 +1029,8 @@ call_connect_status(struct rpc_task *task)
 
 	switch (status) {
 	case -ENOTCONN:
+		if (RPC_IS_ONESHOT(task))
+			break;
 	case -EAGAIN:
 		task->tk_action = call_bind;
 		if (!RPC_IS_SOFT(task))


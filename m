From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 18/24] SUNRPC: introduce new task flag that fails requests on
	xprt disconnect
Date: Mon, 14 Apr 2008 12:28:51 -0400
Message-ID: <20080414162851.12741.91455.stgit@manray.1015granger.net>
References: <20080414162108.12741.73233.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu, trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:52778 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758304AbYDNQ3I (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Apr 2008 12:29:08 -0400
In-Reply-To: <20080414162108.12741.73233.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
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
flag is a no-op.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/sched.h |    2 ++
 net/sunrpc/clnt.c            |    2 ++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 7190d7a..54d0f3e 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -137,6 +137,7 @@ struct rpc_task_setup {
 #define RPC_TASK_DYNAMIC	0x0080		/* task was kmalloc'ed */
 #define RPC_TASK_KILLED		0x0100		/* task was killed */
 #define RPC_TASK_SOFT		0x0200		/* Use soft timeouts */
+#define RPC_TASK_ONESHOT	0x0400		/* fail if can't connect */
 
 #define RPC_IS_ASYNC(t)		((t)->tk_flags & RPC_TASK_ASYNC)
 #define RPC_IS_SWAPPER(t)	((t)->tk_flags & RPC_TASK_SWAPPER)
@@ -144,6 +145,7 @@ struct rpc_task_setup {
 #define RPC_ASSASSINATED(t)	((t)->tk_flags & RPC_TASK_KILLED)
 #define RPC_DO_CALLBACK(t)	((t)->tk_callback != NULL)
 #define RPC_IS_SOFT(t)		((t)->tk_flags & RPC_TASK_SOFT)
+#define RPC_IS_ONESHOT(t)	((t)->tk_flags & RPC_TASK_ONESHOT)
 
 #define RPC_TASK_RUNNING	0
 #define RPC_TASK_QUEUED		1
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index dd39a39..a8bb701 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1016,6 +1016,8 @@ call_connect_status(struct rpc_task *task)
 
 	switch (status) {
 	case -ENOTCONN:
+		if (RPC_IS_ONESHOT(task))
+			break;
 	case -EAGAIN:
 		task->tk_action = call_bind;
 		if (!RPC_IS_SOFT(task))


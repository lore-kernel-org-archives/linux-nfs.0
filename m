Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:49515 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751684Ab1DRT5f (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Apr 2011 15:57:35 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 2/2] Don't update sequence number if rpc_task is not sent
Date: Mon, 18 Apr 2011 15:57:32 -0400
Message-Id: <1303156652-5929-2-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1303156652-5929-1-git-send-email-bjschuma@netapp.com>
References: <1303156652-5929-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Bryan Schumaker <bjschuma@netapp.com>

If we fail to contact the gss upcall program, then no message will
be sent to the server.  The client still updated the sequence number,
however, and this lead to NFS4ERR_SEQ_MISMATCH for the next several
RPC calls.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>

---
 fs/nfs/nfs4proc.c            |    4 ++--
 include/linux/sunrpc/sched.h |    2 ++
 net/sunrpc/xprt.c            |    1 +
 3 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 152e0eb..869caf5 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -444,8 +444,8 @@ static int nfs41_sequence_done(struct rpc_task *task, struct nfs4_sequence_res *
 	if (res->sr_status == 1)
 		res->sr_status = NFS_OK;
 
-	/* -ERESTARTSYS can result in skipping nfs41_sequence_setup */
-	if (!res->sr_slot)
+	/* don't increment the sequence number if the task wasn't sent */
+	if (!RPC_WAS_SENT(task))
 		goto out;
 
 	/* Check the SEQUENCE operation status */
diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index d81db80..3b94f80 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -127,6 +127,7 @@ struct rpc_task_setup {
 #define RPC_TASK_KILLED		0x0100		/* task was killed */
 #define RPC_TASK_SOFT		0x0200		/* Use soft timeouts */
 #define RPC_TASK_SOFTCONN	0x0400		/* Fail if can't connect */
+#define RPC_TASK_SENT		0x0800		/* message was sent */
 
 #define RPC_IS_ASYNC(t)		((t)->tk_flags & RPC_TASK_ASYNC)
 #define RPC_IS_SWAPPER(t)	((t)->tk_flags & RPC_TASK_SWAPPER)
@@ -134,6 +135,7 @@ struct rpc_task_setup {
 #define RPC_ASSASSINATED(t)	((t)->tk_flags & RPC_TASK_KILLED)
 #define RPC_IS_SOFT(t)		((t)->tk_flags & RPC_TASK_SOFT)
 #define RPC_IS_SOFTCONN(t)	((t)->tk_flags & RPC_TASK_SOFTCONN)
+#define RPC_WAS_SENT(t)		((t)->tk_flags & RPC_TASK_SENT)
 
 #define RPC_TASK_RUNNING	0
 #define RPC_TASK_QUEUED		1
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 9494c37..ce5eb68 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -906,6 +906,7 @@ void xprt_transmit(struct rpc_task *task)
 	}
 
 	dprintk("RPC: %5u xmit complete\n", task->tk_pid);
+	task->tk_flags |= RPC_TASK_SENT;
 	spin_lock_bh(&xprt->transport_lock);
 
 	xprt->ops->set_retrans_timeout(task);
-- 
1.7.4.4


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:50703 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751143Ab0IGXEN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Sep 2010 19:04:13 -0400
Date: Tue, 7 Sep 2010 19:03:24 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: cleanup state-machine ordering
Message-ID: <20100907230323.GC24707@fieldses.org>
References: <20100828170953.GB5104@fieldses.org>
 <20100830175728.GA18764@fieldses.org>
 <20100907050142.GA14584@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100907050142.GA14584@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: J. Bruce Fields <bfields@redhat.com>

This is just a minor cleanup: net/sunrpc/clnt.c clarifies the rpc client
state machine by commenting each state and by laying out the functions
implementing each state in the order that each state is normally
executed (in the absence of errors).

The previous patch "Fix null dereference in call_allocate" changed the
order of the states.  Move the functions and update the comments to
reflect the change.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/clnt.c |   84 ++++++++++++++++++++++++++--------------------------
 1 files changed, 42 insertions(+), 42 deletions(-)

On Tue, Sep 07, 2010 at 01:01:42AM -0400, J. Bruce Fields wrote:
> If this is actually the right approach, then we should probably also
> reorder these functions and fix the comments to reflect the new
> state-machine order.

Here you go.  Trivial cut-and-paste, but compile-tested only.--b.

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 657aac6..68e653f 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -966,7 +966,48 @@ call_reserveresult(struct rpc_task *task)
 }
 
 /*
- * 2.	Allocate the buffer. For details, see sched.c:rpc_malloc.
+ * 2.	Bind and/or refresh the credentials
+ */
+static void
+call_refresh(struct rpc_task *task)
+{
+	dprint_status(task);
+
+	task->tk_action = call_refreshresult;
+	task->tk_status = 0;
+	task->tk_client->cl_stats->rpcauthrefresh++;
+	rpcauth_refreshcred(task);
+}
+
+/*
+ * 2a.	Process the results of a credential refresh
+ */
+static void
+call_refreshresult(struct rpc_task *task)
+{
+	int status = task->tk_status;
+
+	dprint_status(task);
+
+	task->tk_status = 0;
+	task->tk_action = call_allocate;
+	if (status >= 0 && rpcauth_uptodatecred(task))
+		return;
+	switch (status) {
+	case -EACCES:
+		rpc_exit(task, -EACCES);
+		return;
+	case -ENOMEM:
+		rpc_exit(task, -ENOMEM);
+		return;
+	case -ETIMEDOUT:
+		rpc_delay(task, 3*HZ);
+	}
+	task->tk_action = call_refresh;
+}
+
+/*
+ * 2b.	Allocate the buffer. For details, see sched.c:rpc_malloc.
  *	(Note: buffer memory is freed in xprt_release).
  */
 static void
@@ -1017,47 +1058,6 @@ call_allocate(struct rpc_task *task)
 	rpc_exit(task, -ERESTARTSYS);
 }
 
-/*
- * 2a.	Bind and/or refresh the credentials
- */
-static void
-call_refresh(struct rpc_task *task)
-{
-	dprint_status(task);
-
-	task->tk_action = call_refreshresult;
-	task->tk_status = 0;
-	task->tk_client->cl_stats->rpcauthrefresh++;
-	rpcauth_refreshcred(task);
-}
-
-/*
- * 2b.	Process the results of a credential refresh
- */
-static void
-call_refreshresult(struct rpc_task *task)
-{
-	int status = task->tk_status;
-
-	dprint_status(task);
-
-	task->tk_status = 0;
-	task->tk_action = call_allocate;
-	if (status >= 0 && rpcauth_uptodatecred(task))
-		return;
-	switch (status) {
-	case -EACCES:
-		rpc_exit(task, -EACCES);
-		return;
-	case -ENOMEM:
-		rpc_exit(task, -ENOMEM);
-		return;
-	case -ETIMEDOUT:
-		rpc_delay(task, 3*HZ);
-	}
-	task->tk_action = call_refresh;
-}
-
 static inline int
 rpc_task_need_encode(struct rpc_task *task)
 {
-- 
1.7.0.4


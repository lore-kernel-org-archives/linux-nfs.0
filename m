Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:43388 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753449AbdKNXGh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Nov 2017 18:06:37 -0500
Received: by mail-io0-f195.google.com with SMTP id 134so26208328ioo.0
        for <linux-nfs@vger.kernel.org>; Tue, 14 Nov 2017 15:06:36 -0800 (PST)
From: Joshua Watt <jpewhacker@gmail.com>
To: NeilBrown <neilb@suse.com>, Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J . Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
        David Howells <dhowells@redhat.com>,
        Joshua Watt <JPEWhacker@gmail.com>
Subject: [RFC v3 1/7] SUNRPC: Add flag to kill new tasks
Date: Tue, 14 Nov 2017 17:06:25 -0600
Message-Id: <20171114230631.14682-2-JPEWhacker@gmail.com>
In-Reply-To: <20171114230631.14682-1-JPEWhacker@gmail.com>
References: <20171114230631.14682-1-JPEWhacker@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The flag causes any new tasks that are queued to exit immediately with
-EIO instead of executing. This will allow clients (particularly NFS) to
prevents these task from delaying shutdown of the RPC session longer
than necessary.

Signed-off-by: Joshua Watt <JPEWhacker@gmail.com>
---
 include/linux/sunrpc/clnt.h | 1 +
 net/sunrpc/clnt.c           | 4 +---
 net/sunrpc/sched.c          | 3 +++
 3 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 71c237e8240e..94f4e464de1b 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -54,6 +54,7 @@ struct rpc_clnt {
 				cl_noretranstimeo: 1,/* No retransmit timeouts */
 				cl_autobind : 1,/* use getport() */
 				cl_chatty   : 1;/* be verbose */
+	bool			cl_kill_new_tasks;	/* Kill all new tasks */
 
 	struct rpc_rtt *	cl_rtt;		/* RTO estimator data */
 	const struct rpc_timeout *cl_timeout;	/* Timeout strategy */
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index df4ecb042ebe..ab6b7c59a117 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -626,6 +626,7 @@ static struct rpc_clnt *__rpc_clone_client(struct rpc_create_args *args,
 	new->cl_noretranstimeo = clnt->cl_noretranstimeo;
 	new->cl_discrtry = clnt->cl_discrtry;
 	new->cl_chatty = clnt->cl_chatty;
+	new->cl_kill_new_tasks = clnt->cl_kill_new_tasks;
 	return new;
 
 out_err:
@@ -818,9 +819,6 @@ void rpc_killall_tasks(struct rpc_clnt *clnt)
 {
 	struct rpc_task	*rovr;
 
-
-	if (list_empty(&clnt->cl_tasks))
-		return;
 	dprintk("RPC:       killing all tasks for client %p\n", clnt);
 	/*
 	 * Spin lock all_tasks to prevent changes...
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 0cc83839c13c..2c9fe5c0319b 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -748,6 +748,9 @@ static void __rpc_execute(struct rpc_task *task)
 	dprintk("RPC: %5u __rpc_execute flags=0x%x\n",
 			task->tk_pid, task->tk_flags);
 
+	if (task->tk_client->cl_kill_new_tasks)
+		rpc_exit(task, -EIO);
+
 	WARN_ON_ONCE(RPC_IS_QUEUED(task));
 	if (RPC_IS_QUEUED(task))
 		return;
-- 
2.13.6


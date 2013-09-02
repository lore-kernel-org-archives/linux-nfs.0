Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:37320 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755681Ab3IBSRF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Sep 2013 14:17:05 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
CC: <andros@netapp.com>
Subject: [PATCH v3 01/17] SUNRPC: Deprecate rpc_client->cl_protname
Date: Mon, 2 Sep 2013 14:16:44 -0400
Message-ID: <1378145820-29990-1-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It just duplicates the cl_program->name, and is not used in any fast
paths where the extra dereference will cause a hit.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/clnt.c     | 18 +++++++++---------
 net/sunrpc/rpc_pipe.c |  2 +-
 net/sunrpc/stats.c    |  2 +-
 3 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 74f6a70..e862f8c 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -629,7 +629,7 @@ void rpc_shutdown_client(struct rpc_clnt *clnt)
 	might_sleep();
 
 	dprintk_rcu("RPC:       shutting down %s client for %s\n",
-			clnt->cl_protname,
+			clnt->cl_program->name,
 			rcu_dereference(clnt->cl_xprt)->servername);
 
 	while (!list_empty(&clnt->cl_tasks)) {
@@ -649,7 +649,7 @@ static void
 rpc_free_client(struct rpc_clnt *clnt)
 {
 	dprintk_rcu("RPC:       destroying %s client for %s\n",
-			clnt->cl_protname,
+			clnt->cl_program->name,
 			rcu_dereference(clnt->cl_xprt)->servername);
 	if (clnt->cl_parent != clnt)
 		rpc_release_client(clnt->cl_parent);
@@ -1299,7 +1299,7 @@ call_start(struct rpc_task *task)
 	struct rpc_clnt	*clnt = task->tk_client;
 
 	dprintk("RPC: %5u call_start %s%d proc %s (%s)\n", task->tk_pid,
-			clnt->cl_protname, clnt->cl_vers,
+			clnt->cl_program->name, clnt->cl_vers,
 			rpc_proc_name(task),
 			(RPC_IS_ASYNC(task) ? "async" : "sync"));
 
@@ -1908,7 +1908,7 @@ call_status(struct rpc_task *task)
 	default:
 		if (clnt->cl_chatty)
 			printk("%s: RPC call returned error %d\n",
-			       clnt->cl_protname, -status);
+			       clnt->cl_program->name, -status);
 		rpc_exit(task, status);
 	}
 }
@@ -1939,7 +1939,7 @@ call_timeout(struct rpc_task *task)
 		if (clnt->cl_chatty) {
 			rcu_read_lock();
 			printk(KERN_NOTICE "%s: server %s not responding, timed out\n",
-				clnt->cl_protname,
+				clnt->cl_program->name,
 				rcu_dereference(clnt->cl_xprt)->servername);
 			rcu_read_unlock();
 		}
@@ -1955,7 +1955,7 @@ call_timeout(struct rpc_task *task)
 		if (clnt->cl_chatty) {
 			rcu_read_lock();
 			printk(KERN_NOTICE "%s: server %s not responding, still trying\n",
-			clnt->cl_protname,
+			clnt->cl_program->name,
 			rcu_dereference(clnt->cl_xprt)->servername);
 			rcu_read_unlock();
 		}
@@ -1990,7 +1990,7 @@ call_decode(struct rpc_task *task)
 		if (clnt->cl_chatty) {
 			rcu_read_lock();
 			printk(KERN_NOTICE "%s: server %s OK\n",
-				clnt->cl_protname,
+				clnt->cl_program->name,
 				rcu_dereference(clnt->cl_xprt)->servername);
 			rcu_read_unlock();
 		}
@@ -2015,7 +2015,7 @@ call_decode(struct rpc_task *task)
 			goto out_retry;
 		}
 		dprintk("RPC:       %s: too small RPC reply size (%d bytes)\n",
-				clnt->cl_protname, task->tk_status);
+				clnt->cl_program->name, task->tk_status);
 		task->tk_action = call_timeout;
 		goto out_retry;
 	}
@@ -2287,7 +2287,7 @@ static void rpc_show_task(const struct rpc_clnt *clnt,
 	printk(KERN_INFO "%5u %04x %6d %8p %8p %8ld %8p %sv%u %s a:%ps q:%s\n",
 		task->tk_pid, task->tk_flags, task->tk_status,
 		clnt, task->tk_rqstp, task->tk_timeout, task->tk_ops,
-		clnt->cl_protname, clnt->cl_vers, rpc_proc_name(task),
+		clnt->cl_program->name, clnt->cl_vers, rpc_proc_name(task),
 		task->tk_action, rpc_waitq);
 }
 
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 017aedc..b36bfb9 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -409,7 +409,7 @@ rpc_show_info(struct seq_file *m, void *v)
 	rcu_read_lock();
 	seq_printf(m, "RPC server: %s\n",
 			rcu_dereference(clnt->cl_xprt)->servername);
-	seq_printf(m, "service: %s (%d) version %d\n", clnt->cl_protname,
+	seq_printf(m, "service: %s (%d) version %d\n", clnt->cl_program->name,
 			clnt->cl_prog, clnt->cl_vers);
 	seq_printf(m, "address: %s\n", rpc_peeraddr2str(clnt, RPC_DISPLAY_ADDR));
 	seq_printf(m, "protocol: %s\n", rpc_peeraddr2str(clnt, RPC_DISPLAY_PROTO));
diff --git a/net/sunrpc/stats.c b/net/sunrpc/stats.c
index 21b75cb..5453049 100644
--- a/net/sunrpc/stats.c
+++ b/net/sunrpc/stats.c
@@ -188,7 +188,7 @@ void rpc_print_iostats(struct seq_file *seq, struct rpc_clnt *clnt)
 
 	seq_printf(seq, "\tRPC iostats version: %s  ", RPC_IOSTATS_VERS);
 	seq_printf(seq, "p/v: %u/%u (%s)\n",
-			clnt->cl_prog, clnt->cl_vers, clnt->cl_protname);
+			clnt->cl_prog, clnt->cl_vers, clnt->cl_program->name);
 
 	rcu_read_lock();
 	xprt = rcu_dereference(clnt->cl_xprt);
-- 
1.8.3.1


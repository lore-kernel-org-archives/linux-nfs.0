Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:63470 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752343AbcEKTIy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 May 2016 15:08:54 -0400
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <bfields@fieldses.org>, <chuck.lever@oracle.com>,
        <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 4 06/10] SUNRPC add flag to rpc_task_release_client
Date: Wed, 11 May 2016 15:08:21 -0400
Message-ID: <1462993705-14673-7-git-send-email-andros@netapp.com>
In-Reply-To: <1462993705-14673-1-git-send-email-andros@netapp.com>
References: <1462993705-14673-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Want to specify which rpc_xprt to use in rpc_run_task.

Don't pass in an rpc_xprt in rpc_init_task just to have it not used as it
is removed in rpc_task_release_client.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/sunrpc/clnt.h | 2 +-
 net/sunrpc/clnt.c           | 6 +++---
 net/sunrpc/sched.c          | 2 +-
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 9a7ddba..b2c5b75 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -150,7 +150,7 @@ int		rpc_switch_client_transport(struct rpc_clnt *,
 
 void		rpc_shutdown_client(struct rpc_clnt *);
 void		rpc_release_client(struct rpc_clnt *);
-void		rpc_task_release_client(struct rpc_task *);
+void		rpc_task_release_client(struct rpc_task *, int);
 
 int		rpcb_create_local(struct net *);
 void		rpcb_put_local(struct net *);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 7e0c9bf..e157d09 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -942,7 +942,7 @@ out:
 }
 EXPORT_SYMBOL_GPL(rpc_bind_new_program);
 
-void rpc_task_release_client(struct rpc_task *task)
+void rpc_task_release_client(struct rpc_task *task, int rm_xprt)
 {
 	struct rpc_clnt *clnt = task->tk_client;
 	struct rpc_xprt *xprt = task->tk_xprt;
@@ -957,7 +957,7 @@ void rpc_task_release_client(struct rpc_task *task)
 		rpc_release_client(clnt);
 	}
 
-	if (xprt != NULL) {
+	if (rm_xprt && xprt) {
 		task->tk_xprt = NULL;
 
 		xprt_put(xprt);
@@ -969,7 +969,7 @@ void rpc_task_set_client(struct rpc_task *task, struct rpc_clnt *clnt)
 {
 
 	if (clnt != NULL) {
-		rpc_task_release_client(task);
+		rpc_task_release_client(task, 0);
 		if (task->tk_xprt == NULL)
 			task->tk_xprt = xprt_iter_get_next(&clnt->cl_xpi);
 		task->tk_client = clnt;
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index fcfd48d..0dacd9c 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -993,7 +993,7 @@ static void rpc_release_resources_task(struct rpc_task *task)
 		put_rpccred(task->tk_msg.rpc_cred);
 		task->tk_msg.rpc_cred = NULL;
 	}
-	rpc_task_release_client(task);
+	rpc_task_release_client(task, 1);
 }
 
 static void rpc_final_put_task(struct rpc_task *task,
-- 
1.8.3.1


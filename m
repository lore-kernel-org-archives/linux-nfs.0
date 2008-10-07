From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 26/30] SUNRPC: Fix autobind on cloned rpc clients
Date: Tue, 07 Oct 2008 18:19:54 -0400
Message-ID: <20081007221954.20945.44434.stgit@localhost.localdomain>
References: <20081007221952.20945.69529.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:35670 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756332AbYJGWcx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Oct 2008 18:32:53 -0400
Received: from sacexrs02.hq.netapp.com (sacexrs02.hq.netapp.com [10.99.190.106])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m97MWi0j025764
	for <linux-nfs@vger.kernel.org>; Tue, 7 Oct 2008 15:32:49 -0700 (PDT)
In-Reply-To: <20081007221952.20945.69529.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Despite the fact that cloned rpc clients won't have the cl_autobind flag
set, they may still find themselves calling rpcb_getport_async(). For this
to happen, it suffices for a _parent_ rpc_clnt to use autobinding, in which
case any clone may find itself triggering the !xprt_bound() case in
call_bind().

The correct fix for this is to walk back up the tree of cloned rpc clients,
in order to find the parent that 'owns' the transport, either because it
has clnt->cl_autobind set, or because it originally created the
transport...

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/rpcb_clnt.c |   36 +++++++++++++++++++++++++++++-------
 1 files changed, 29 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 24db2b4..172935b 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -469,6 +469,28 @@ static struct rpc_task *rpcb_call_async(struct rpc_clnt *rpcb_clnt, struct rpcbi
 	return rpc_run_task(&task_setup_data);
 }
 
+/*
+ * In the case where rpc clients have been cloned, we want to make
+ * sure that we use the program number/version etc of the actual
+ * owner of the xprt. To do so, we walk back up the tree of parents
+ * to find whoever created the transport and/or whoever has the
+ * autobind flag set.
+ */
+static struct rpc_clnt *rpcb_find_transport_owner(struct rpc_clnt *clnt)
+{
+	struct rpc_clnt *parent = clnt->cl_parent;
+
+	while (parent != clnt) {
+		if (parent->cl_xprt != clnt->cl_xprt)
+			break;
+		if (clnt->cl_autobind)
+			break;
+		clnt = parent;
+		parent = parent->cl_parent;
+	}
+	return clnt;
+}
+
 /**
  * rpcb_getport_async - obtain the port for a given RPC service on a given host
  * @task: task that is waiting for portmapper request
@@ -478,10 +500,10 @@ static struct rpc_task *rpcb_call_async(struct rpc_clnt *rpcb_clnt, struct rpcbi
  */
 void rpcb_getport_async(struct rpc_task *task)
 {
-	struct rpc_clnt *clnt = task->tk_client;
+	struct rpc_clnt *clnt;
 	struct rpc_procinfo *proc;
 	u32 bind_version;
-	struct rpc_xprt *xprt = task->tk_xprt;
+	struct rpc_xprt *xprt;
 	struct rpc_clnt	*rpcb_clnt;
 	static struct rpcbind_args *map;
 	struct rpc_task	*child;
@@ -490,13 +512,13 @@ void rpcb_getport_async(struct rpc_task *task)
 	size_t salen;
 	int status;
 
+	clnt = rpcb_find_transport_owner(task->tk_client);
+	xprt = clnt->cl_xprt;
+
 	dprintk("RPC: %5u %s(%s, %u, %u, %d)\n",
 		task->tk_pid, __func__,
 		clnt->cl_server, clnt->cl_prog, clnt->cl_vers, xprt->prot);
 
-	/* Autobind on cloned rpc clients is discouraged */
-	BUG_ON(clnt->cl_parent != clnt);
-
 	/* Put self on the wait queue to ensure we get notified if
 	 * some other task is already attempting to bind the port */
 	rpc_sleep_on(&xprt->binding, task, NULL);
@@ -578,9 +600,9 @@ void rpcb_getport_async(struct rpc_task *task)
 			task->tk_pid, __func__);
 		return;
 	}
-	rpc_put_task(child);
 
-	task->tk_xprt->stat.bind_count++;
+	xprt->stat.bind_count++;
+	rpc_put_task(child);
 	return;
 
 bailout_nofree:


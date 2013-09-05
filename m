Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:55126 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762253Ab3IEC7B (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Sep 2013 22:59:01 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/3] SUNRPC: Add an identifier for struct rpc_clnt
Date: Wed, 4 Sep 2013 22:58:39 -0400
Message-ID: <1378349920-31206-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1378349920-31206-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1378349920-31206-1-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add an identifier in order to aid debugging.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 include/linux/sunrpc/clnt.h |  1 +
 net/sunrpc/clnt.c           | 25 +++++++++++++++++++++++++
 2 files changed, 26 insertions(+)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 76c0bf6..6740801 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -33,6 +33,7 @@ struct rpc_inode;
  */
 struct rpc_clnt {
 	atomic_t		cl_count;	/* Number of references */
+	unsigned int		cl_clid;	/* client id */
 	struct list_head	cl_clients;	/* Global list of clients */
 	struct list_head	cl_tasks;	/* List of tasks */
 	spinlock_t		cl_lock;	/* spinlock */
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 0cd5b6d5..0a79069 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -313,6 +313,24 @@ out:
 	return err;
 }
 
+static DEFINE_IDA(rpc_clids);
+
+static int rpc_alloc_clid(struct rpc_clnt *clnt)
+{
+	int clid;
+
+	clid = ida_simple_get(&rpc_clids, 0, 0, GFP_KERNEL);
+	if (clid < 0)
+		return clid;
+	clnt->cl_clid = clid;
+	return 0;
+}
+
+static void rpc_free_clid(struct rpc_clnt *clnt)
+{
+	ida_simple_remove(&rpc_clids, clnt->cl_clid);
+}
+
 static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args,
 		struct rpc_xprt *xprt,
 		struct rpc_clnt *parent)
@@ -343,6 +361,10 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args,
 		goto out_err;
 	clnt->cl_parent = parent ? : clnt;
 
+	err = rpc_alloc_clid(clnt);
+	if (err)
+		goto out_no_clid;
+
 	rcu_assign_pointer(clnt->cl_xprt, xprt);
 	clnt->cl_procinfo = version->procs;
 	clnt->cl_maxproc  = version->nrprocs;
@@ -386,6 +408,8 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args,
 out_no_path:
 	rpc_free_iostats(clnt->cl_metrics);
 out_no_stats:
+	rpc_free_clid(clnt);
+out_no_clid:
 	kfree(clnt);
 out_err:
 	rpciod_down();
@@ -646,6 +670,7 @@ rpc_free_client(struct rpc_clnt *clnt)
 	clnt->cl_metrics = NULL;
 	xprt_put(rcu_dereference_raw(clnt->cl_xprt));
 	rpciod_down();
+	rpc_free_clid(clnt);
 	kfree(clnt);
 }
 
-- 
1.8.3.1


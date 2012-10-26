Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:30504 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759012Ab2JZTGw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Oct 2012 15:06:52 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 2/2] SUNRPC: add WARN_ON_ONCE for potential deadlock
Date: Fri, 26 Oct 2012 15:06:47 -0400
Message-Id: <1351278407-13804-2-git-send-email-dros@netapp.com>
In-Reply-To: <1351278407-13804-1-git-send-email-dros@netapp.com>
References: <1351278407-13804-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

rpc_shutdown_client should never be called from a workqueue context.
If it is, it could deadlock looping forever trying to kill tasks that are
assigned to the same kworker thread (and will never run rpc_exit_task).

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 net/sunrpc/clnt.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index cdc7564..d2737c2 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -607,6 +607,12 @@ EXPORT_SYMBOL_GPL(rpc_killall_tasks);
  */
 void rpc_shutdown_client(struct rpc_clnt *clnt)
 {
+	/*
+	 * To avoid deadlock, never call rpc_shutdown_client from a
+	 * workqueue context!
+	 */
+	WARN_ON_ONCE(current->flags & PF_WQ_WORKER);
+
 	dprintk_rcu("RPC:       shutting down %s client for %s\n",
 			clnt->cl_protname,
 			rcu_dereference(clnt->cl_xprt)->servername);
-- 
1.7.9.6 (Apple Git-31.1)


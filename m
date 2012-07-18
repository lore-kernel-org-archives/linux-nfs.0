Return-Path: linux-nfs-owner@vger.kernel.org
Received: from perches-mx.perches.com ([206.117.179.246]:57554 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753213Ab2GRSRM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Jul 2012 14:17:12 -0400
Message-ID: <1342635431.9551.41.camel@joe2Laptop>
Subject: [PATCH] sunrpc: clnt: Add missing braces
From: Joe Perches <joe@perches.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>
Cc: "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Wed, 18 Jul 2012 11:17:11 -0700
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a missing set of braces that commit 4e0038b6b24
("SUNRPC: Move clnt->cl_server into struct rpc_xprt")
forgot.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/sunrpc/clnt.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index f56f045..aaf70aa 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1844,12 +1844,13 @@ call_timeout(struct rpc_task *task)
 		return;
 	}
 	if (RPC_IS_SOFT(task)) {
-		if (clnt->cl_chatty)
+		if (clnt->cl_chatty) {
 			rcu_read_lock();
 			printk(KERN_NOTICE "%s: server %s not responding, timed out\n",
 				clnt->cl_protname,
 				rcu_dereference(clnt->cl_xprt)->servername);
 			rcu_read_unlock();
+		}
 		if (task->tk_flags & RPC_TASK_TIMEOUT)
 			rpc_exit(task, -ETIMEDOUT);
 		else



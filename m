Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:47501 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754461Ab2KAUEk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Nov 2012 16:04:40 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH] SUNRPC: remove BUG_ON from rpc_call_sync
Date: Thu,  1 Nov 2012 16:04:40 -0400
Message-Id: <1351800280-42641-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use WARN_ON_ONCE instead of calling BUG_ON and return -EINVAL when
RPC_TASK_ASYNC flag is passed to rpc_call_sync.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 net/sunrpc/clnt.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index e184bd4..c69e199 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -840,7 +840,12 @@ int rpc_call_sync(struct rpc_clnt *clnt, const struct rpc_message *msg, int flag
 	};
 	int status;
 
-	BUG_ON(flags & RPC_TASK_ASYNC);
+	WARN_ON_ONCE(flags & RPC_TASK_ASYNC);
+	if (flags & RPC_TASK_ASYNC) {
+		rpc_release_calldata(task_setup_data.callback_ops,
+			task_setup_data.callback_data);
+		return -EINVAL;
+	}
 
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
-- 
1.7.9.6 (Apple Git-31.1)


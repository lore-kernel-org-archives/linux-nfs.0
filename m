Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:51770 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757166Ab2JWOxh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Oct 2012 10:53:37 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 05/25] SUNRPC: remove BUG_ON from rpc_call_sync
Date: Tue, 23 Oct 2012 10:43:29 -0400
Message-Id: <1351003429-18887-6-git-send-email-dros@netapp.com>
In-Reply-To: <1351003429-18887-1-git-send-email-dros@netapp.com>
References: <1351003429-18887-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Return -EINVAL instead of calling BUG_ON() when RPC_TASK_ASYNC flag is passed
to rpc_call_sync().

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 net/sunrpc/clnt.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index dd16e52..0c0035f 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -839,7 +839,11 @@ int rpc_call_sync(struct rpc_clnt *clnt, const struct rpc_message *msg, int flag
 	};
 	int status;
 
-	BUG_ON(flags & RPC_TASK_ASYNC);
+	if (flags & RPC_TASK_ASYNC) {
+		rpc_release_calldata(task_setup_data.callback_ops,
+			task_setup_data.callback_data);
+		return -EINVAL;
+	}
 
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
-- 
1.7.9.6 (Apple Git-31.1)


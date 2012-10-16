Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:15883 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754869Ab2JPQa7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Oct 2012 12:30:59 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 05/25] SUNRPC: remove BUG_ON() from rpc_call_sync()
Date: Tue, 16 Oct 2012 12:30:23 -0400
Message-Id: <1350405043-39316-5-git-send-email-dros@netapp.com>
In-Reply-To: <1350405043-39316-1-git-send-email-dros@netapp.com>
References: <1350405043-39316-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Return -EINVAL instead of calling BUG_ON() when RPC_TASK_ASYNC flag is passed
to rpc_call_sync().

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 net/sunrpc/clnt.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 76d1730..a8a6bcf 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -839,7 +839,8 @@ int rpc_call_sync(struct rpc_clnt *clnt, const struct rpc_message *msg, int flag
 	};
 	int status;
 
-	BUG_ON(flags & RPC_TASK_ASYNC);
+	if (flags & RPC_TASK_ASYNC)
+		return -EINVAL;
 
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
-- 
1.7.9.6 (Apple Git-31.1)


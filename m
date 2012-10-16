Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:15992 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754841Ab2JPQbk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Oct 2012 12:31:40 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 25/25] SUNRPC: remove BUG_ON() in rpc_release_task()
Date: Tue, 16 Oct 2012 12:30:43 -0400
Message-Id: <1350405043-39316-25-git-send-email-dros@netapp.com>
In-Reply-To: <1350405043-39316-1-git-send-email-dros@netapp.com>
References: <1350405043-39316-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace BUG_ON() with WARN_ON_ONCE().

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 net/sunrpc/sched.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 2d72af1..d8b9921 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -993,7 +993,7 @@ static void rpc_release_task(struct rpc_task *task)
 {
 	dprintk("RPC: %5u release task\n", task->tk_pid);
 
-	BUG_ON (RPC_IS_QUEUED(task));
+	WARN_ON_ONCE(RPC_IS_QUEUED(task));
 
 	rpc_release_resources_task(task);
 
-- 
1.7.9.6 (Apple Git-31.1)


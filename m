Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:15883 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754869Ab2JPQa5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Oct 2012 12:30:57 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 03/25] SUNRPC: remove BUG_ON() from rpc_run_bc_task
Date: Tue, 16 Oct 2012 12:30:21 -0400
Message-Id: <1350405043-39316-3-git-send-email-dros@netapp.com>
In-Reply-To: <1350405043-39316-1-git-send-email-dros@netapp.com>
References: <1350405043-39316-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace BUG_ON() with WARN_ON_ONCE() - rpc_run_bc_task calls rpc_init_task()
then increments the tk_count, so this is a simple sanity check that
if hit once would hit every time this code path is executed.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 net/sunrpc/clnt.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index eacdb15..fe8a133 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -915,7 +915,7 @@ struct rpc_task *rpc_run_bc_task(struct rpc_rqst *req,
 
 	task->tk_action = call_bc_transmit;
 	atomic_inc(&task->tk_count);
-	BUG_ON(atomic_read(&task->tk_count) != 2);
+	WARN_ON_ONCE(atomic_read(&task->tk_count) != 2);
 	rpc_execute(task);
 
 out:
-- 
1.7.9.6 (Apple Git-31.1)


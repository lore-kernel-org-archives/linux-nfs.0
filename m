Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:15883 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754869Ab2JPQbC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Oct 2012 12:31:02 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 07/25] SUNRPC: remove BUG_ON() from call_bc_transmit()
Date: Tue, 16 Oct 2012 12:30:25 -0400
Message-Id: <1350405043-39316-7-git-send-email-dros@netapp.com>
In-Reply-To: <1350405043-39316-1-git-send-email-dros@netapp.com>
References: <1350405043-39316-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace BUG_ON() with WARN_ON_ONCE() and handle error condition by
calling rpc_exit().

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 net/sunrpc/clnt.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index ced0f36..bff6438 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1750,7 +1750,12 @@ call_bc_transmit(struct rpc_task *task)
 {
 	struct rpc_rqst *req = task->tk_rqstp;
 
-	BUG_ON(task->tk_status != 0);
+	WARN_ON_ONCE(task->tk_status != 0);
+	if (task->tk_status != 0) {
+		rpc_exit(task, task->tk_status);
+		return;
+	}
+
 	task->tk_status = xprt_prepare_transmit(task);
 	if (task->tk_status == -EAGAIN) {
 		/*
-- 
1.7.9.6 (Apple Git-31.1)


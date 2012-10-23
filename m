Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:14548 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932291Ab2JWOxb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Oct 2012 10:53:31 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 07/25] SUNRPC: remove BUG_ON from call_bc_transmit
Date: Tue, 23 Oct 2012 10:43:31 -0400
Message-Id: <1351003429-18887-8-git-send-email-dros@netapp.com>
In-Reply-To: <1351003429-18887-1-git-send-email-dros@netapp.com>
References: <1351003429-18887-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove redundant BUG_ON().

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 net/sunrpc/clnt.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index b65c285..b48bfcf 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1748,7 +1748,6 @@ call_bc_transmit(struct rpc_task *task)
 {
 	struct rpc_rqst *req = task->tk_rqstp;
 
-	BUG_ON(task->tk_status != 0);
 	task->tk_status = xprt_prepare_transmit(task);
 	if (task->tk_status == -EAGAIN) {
 		/*
-- 
1.7.9.6 (Apple Git-31.1)


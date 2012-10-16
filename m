Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:15883 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754869Ab2JPQa6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Oct 2012 12:30:58 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 04/25] SUNRPC: remove BUG_ON() from call_transmit()
Date: Tue, 16 Oct 2012 12:30:22 -0400
Message-Id: <1350405043-39316-4-git-send-email-dros@netapp.com>
In-Reply-To: <1350405043-39316-1-git-send-email-dros@netapp.com>
References: <1350405043-39316-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace BUG_ON() with WARN_ON_ONCE() and if the error condition is true
attempt to gracefully recover by calling rpc_exit().

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 net/sunrpc/clnt.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index fe8a133..76d1730 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1661,7 +1661,11 @@ call_transmit(struct rpc_task *task)
 	task->tk_action = call_transmit_status;
 	/* Encode here so that rpcsec_gss can use correct sequence number. */
 	if (rpc_task_need_encode(task)) {
-		BUG_ON(task->tk_rqstp->rq_bytes_sent != 0);
+		WARN_ON(task->tk_rqstp->rq_bytes_sent != 0);
+		if (task->tk_rqstp->rq_bytes_sent != 0) {
+			rpc_exit(task, -EINVAL);
+			return;
+		}
 		rpc_xdr_encode(task);
 		/* Did the encode result in an error condition? */
 		if (task->tk_status != 0) {
-- 
1.7.9.6 (Apple Git-31.1)


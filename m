Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:15883 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754869Ab2JPQbB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Oct 2012 12:31:01 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 06/25] SUNRPC: remove BUG_ON() from call_bc_transmit()
Date: Tue, 16 Oct 2012 12:30:24 -0400
Message-Id: <1350405043-39316-6-git-send-email-dros@netapp.com>
In-Reply-To: <1350405043-39316-1-git-send-email-dros@netapp.com>
References: <1350405043-39316-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace BUG_ON() with WARN_ON_ONCE().

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 net/sunrpc/clnt.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index a8a6bcf..ced0f36 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1797,7 +1797,7 @@ call_bc_transmit(struct rpc_task *task)
 		 * We were unable to reply and will have to drop the
 		 * request.  The server should reconnect and retransmit.
 		 */
-		BUG_ON(task->tk_status == -EAGAIN);
+		WARN_ON_ONCE(task->tk_status == -EAGAIN);
 		printk(KERN_NOTICE "RPC: Could not send backchannel reply "
 			"error: %d\n", task->tk_status);
 		break;
-- 
1.7.9.6 (Apple Git-31.1)


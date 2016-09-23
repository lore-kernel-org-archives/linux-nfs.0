Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from atlantic540.startdedicated.de ([188.138.9.77]:47918 "EHLO
        atlantic540.startdedicated.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S934439AbcIWImL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Sep 2016 04:42:11 -0400
From: Daniel Wagner <wagi@monom.org>
To: linux-nfs@vger.kernel.org
Cc: linux-kernel@vger.kernel.org,
        Daniel Wagner <daniel.wagner@bmw-carit.de>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Chuck Lever <chuck.lever@oracle.com>, netdev@vger.kernel.org
Subject: [PATCH] xprtrdma: use complete() instead complete_all()
Date: Fri, 23 Sep 2016 10:41:57 +0200
Message-Id: <1474620117-8749-1-git-send-email-wagi@monom.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Daniel Wagner <daniel.wagner@bmw-carit.de>

There is only one waiter for the completion, therefore there
is no need to use complete_all(). Let's make that clear by
using complete() instead of complete_all().

The usage pattern of the completion is:

waiter context                          waker context

frwr_op_unmap_sync()
  reinit_completion()
  ib_post_send()
  wait_for_completion()

					frwr_wc_localinv_wake()
					  complete()

Signed-off-by: Daniel Wagner <daniel.wagner@bmw-carit.de>
Cc: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Cc: netdev@vger.kernel.org
---
 net/sunrpc/xprtrdma/frwr_ops.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 892b5e1..4a24f0e 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -329,7 +329,7 @@ frwr_wc_localinv_wake(struct ib_cq *cq, struct ib_wc *wc)
 	frmr = container_of(cqe, struct rpcrdma_frmr, fr_cqe);
 	if (wc->status != IB_WC_SUCCESS)
 		__frwr_sendcompletion_flush(wc, frmr, "localinv");
-	complete_all(&frmr->fr_linv_done);
+	complete(&frmr->fr_linv_done);
 }
 
 /* Post a REG_MR Work Request to register a memory region
-- 
2.7.4

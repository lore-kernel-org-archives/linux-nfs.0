Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:54716 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751666AbeCTVFM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Mar 2018 17:05:12 -0400
Subject: [PATCH 1/3] svcrdma: Use pr_err to report Receive errors
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 20 Mar 2018 17:05:09 -0400
Message-ID: <20180320210509.13273.63575.stgit@klimt.1015granger.net>
In-Reply-To: <20180320210219.13273.89049.stgit@klimt.1015granger.net>
References: <20180320210219.13273.89049.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Other completion handlers use pr_err, not pr_warn.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_transport.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 08fa7de..8da637a 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -331,9 +331,9 @@ static void svc_rdma_wc_receive(struct ib_cq *cq, struct ib_wc *wc)
 
 flushed:
 	if (wc->status != IB_WC_WR_FLUSH_ERR)
-		pr_warn("svcrdma: receive: %s (%u/0x%x)\n",
-			ib_wc_status_msg(wc->status),
-			wc->status, wc->vendor_err);
+		pr_err("svcrdma: Recv: %s (%u/0x%x)\n",
+		       ib_wc_status_msg(wc->status),
+		       wc->status, wc->vendor_err);
 	set_bit(XPT_CLOSE, &xprt->sc_xprt.xpt_flags);
 	svc_rdma_put_context(ctxt, 1);
 


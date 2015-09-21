Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:40649 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756546AbbIURYf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Sep 2015 13:24:35 -0400
From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH 3/3] xprtrdma: don't log warnings for flushed completions
To: trond.myklebust@primarydata.com, bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date: Mon, 21 Sep 2015 12:24:34 -0500
Message-ID: <20150921172434.9761.97255.stgit@build2.ogc.int>
In-Reply-To: <20150921172423.9761.92399.stgit@build2.ogc.int>
References: <20150921172423.9761.92399.stgit@build2.ogc.int>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Unsignaled send WRs can get flushed as part of normal unmount, so don't
log them as warnings.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 net/sunrpc/xprtrdma/frwr_ops.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index d6653f5..f1868ba 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -257,8 +257,11 @@ frwr_sendcompletion(struct ib_wc *wc)
 
 	/* WARNING: Only wr_id and status are reliable at this point */
 	r = (struct rpcrdma_mw *)(unsigned long)wc->wr_id;
-	pr_warn("RPC:       %s: frmr %p flushed, status %s (%d)\n",
-		__func__, r, ib_wc_status_msg(wc->status), wc->status);
+	if (wc->status == IB_WC_WR_FLUSH_ERR)
+		dprintk("RPC:       %s: frmr %p flushed\n", __func__, r);
+	else
+		pr_warn("RPC:       %s: frmr %p error, status %s (%d)\n",
+			__func__, r, ib_wc_status_msg(wc->status), wc->status);
 	r->r.frmr.fr_state = FRMR_IS_STALE;
 }
 


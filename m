Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:47023 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754777AbbGTRAn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Jul 2015 13:00:43 -0400
From: Sagi Grimberg <sagig@mellanox.com>
To: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH RFC] svcrdma: Fix possible over population fast_reg_page_list
Date: Mon, 20 Jul 2015 20:00:14 +0300
Message-Id: <1437411614-29722-1-git-send-email-sagig@mellanox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When accounting the needed_pages, we need to look into
the page_list->max_page_list_len and not the global
context xprt->sc_frmr_pg_list_len.

Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
---
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index 2e1348b..b19ffd3 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -244,7 +244,8 @@ int rdma_read_chunk_frmr(struct svcxprt_rdma *xprt,
 
 	ctxt->direction = DMA_FROM_DEVICE;
 	ctxt->frmr = frmr;
-	pages_needed = min_t(int, pages_needed, xprt->sc_frmr_pg_list_len);
+	pages_needed = min_t(int, pages_needed,
+			     frmr->page_list->max_page_list_len);
 	read = min_t(int, pages_needed << PAGE_SHIFT, rs_length);
 
 	frmr->kva = page_address(rqstp->rq_arg.pages[pg_no]);
-- 
1.7.1


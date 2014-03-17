Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f48.google.com ([209.85.216.48]:53487 "EHLO
	mail-qa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751097AbaCQRKP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Mar 2014 13:10:15 -0400
Received: by mail-qa0-f48.google.com with SMTP id m5so5563817qaj.21
        for <linux-nfs@vger.kernel.org>; Mon, 17 Mar 2014 10:10:14 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: tom@opengridcomputing.com, linux-nfs@vger.kernel.org
Subject: [PATCH v2] svcrdma: fix offset calculation for non-page aligned sge entries
Date: Mon, 17 Mar 2014 13:10:05 -0400
Message-Id: <1395076205-26658-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The xdr_off value in dma_map_xdr gets passed to ib_dma_map_page as the
offset into the page to be mapped. This calculation does not correctly
take into account the case where the data starts at some offset into
the page. Increment the xdr_off by the page_base to ensure that it is
respected.

Cc: Tom Tucker <tom@opengridcomputing.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 net/sunrpc/xprtrdma/svc_rdma_sendto.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index c1d124dc772b..5f14609b6336 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -265,6 +265,7 @@ static dma_addr_t dma_map_xdr(struct svcxprt_rdma *xprt,
 		xdr_off -= xdr->head[0].iov_len;
 		if (xdr_off < xdr->page_len) {
 			/* This offset is in the page list */
+			xdr_off += xdr->page_base;
 			page = xdr->pages[xdr_off >> PAGE_SHIFT];
 			xdr_off &= ~PAGE_MASK;
 		} else {
-- 
1.8.5.3


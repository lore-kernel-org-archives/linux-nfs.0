Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:50741 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752013AbbI1VqH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Sep 2015 17:46:07 -0400
From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH RESEND] svcrdma: handle rdma read with a non-zero initial page
	offset
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date: Mon, 28 Sep 2015 16:46:06 -0500
Message-ID: <20150928214605.17900.50257.stgit@build2.ogc.int>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The server rdma_read_chunk_lcl() and rdma_read_chunk_frmr() functions
were not taking into account the initial page_offset when determining
the rdma read length.  This resulted in a read who's starting address
and length exceeded the base/bounds of the frmr.

Most work loads don't tickle this bug apparently, but one test hit it
every time: building the linux kernel on a 16 core node with 'make -j
16 O=/mnt/0' where /mnt/0 is a ramdisk mounted via NFSRDMA.

This bug seems to only be tripped with devices having small fastreg page
list depths.  I didn't see it with mlx4, for instance.

Fixes: 0bf4828983df ('svcrdma: refactor marshalling logic')
Signed-off-by: Steve Wise <swise@opengridcomputing.com>
Tested-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index cb51742..5f6ca47 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -136,7 +136,8 @@ int rdma_read_chunk_lcl(struct svcxprt_rdma *xprt,
 	ctxt->direction = DMA_FROM_DEVICE;
 	ctxt->read_hdr = head;
 	pages_needed = min_t(int, pages_needed, xprt->sc_max_sge_rd);
-	read = min_t(int, pages_needed << PAGE_SHIFT, rs_length);
+	read = min_t(int, (pages_needed << PAGE_SHIFT) - *page_offset,
+		     rs_length);
 
 	for (pno = 0; pno < pages_needed; pno++) {
 		int len = min_t(int, rs_length, PAGE_SIZE - pg_off);
@@ -235,7 +236,8 @@ int rdma_read_chunk_frmr(struct svcxprt_rdma *xprt,
 	ctxt->direction = DMA_FROM_DEVICE;
 	ctxt->frmr = frmr;
 	pages_needed = min_t(int, pages_needed, xprt->sc_frmr_pg_list_len);
-	read = min_t(int, pages_needed << PAGE_SHIFT, rs_length);
+	read = min_t(int, (pages_needed << PAGE_SHIFT) - *page_offset,
+		     rs_length);
 
 	frmr->kva = page_address(rqstp->rq_arg.pages[pg_no]);
 	frmr->direction = DMA_FROM_DEVICE;


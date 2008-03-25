From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH] SVCRDMA: Check num_sge when setting LAST_CTXT bit
Date: Tue, 25 Mar 2008 11:14:02 -0500
Message-ID: <1206461642.19529.30.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs <linux-nfs@vger.kernel.org>,
	Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>,
	James Lentini <jlentini@netapp.com>,
	"Talpey, Thomas" <Thomas.Talpey@netapp.com>,
	Steve Wise <swise@chelsio.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:45431 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756203AbYCYQMf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Mar 2008 12:12:35 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

    SVCRDMA: Check num_sge when setting LAST_CTXT bit
    
    The RDMACTXT_F_LAST_CTXT bit was getting set incorrectly
    when the last chunk in the read-list spanned multiple pages. This
    resulted in a kernel panic when the wrong context was used to
    build the RPC iovec page list.
    
    RDMA_READ is used to fetch RPC data from the client for
    NFS_WRITE requests. A scatter-gather is used to map the
    advertised client side buffer to the server-side iovec and
    associated page list.
    
    WR contexts are used to convey which scatter-gather entries are
    handled by each WR. When the write data is large, a single RPC may
    require multiple RDMA_READ requests so the contexts for a single RPC
    are chained together in a linked list. The last context in this list
    is marked with a bit RDMACTXT_F_LAST_CTXT so that when this WR completes,
    the CQ handler code can enqueue the RPC for processing.
    
    The code in rdma_read_xdr was setting this bit on the last two
    contexts on this list when the last read-list chunk spanned multiple
    pages. This caused the svc_rdma_recvfrom logic to incorrectly build
    the RPC and caused the kernel to crash because the second-to-last
    context doesn't contain the iovec page list.
    
    Modified the condition that sets this bit so that it correctly detects
    the last context for the RPC.
    
    Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
    Tested-by: Roland Dreier <rolandd-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
---

Bruce, this should be queued for 2.6.25 if possible.

 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |   21 +++++++++++----------
 1 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index 301f619..85788e7 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -326,15 +326,6 @@ next_sge:
 		ctxt->direction = DMA_FROM_DEVICE;
 		clear_bit(RDMACTXT_F_READ_DONE, &ctxt->flags);
 		clear_bit(RDMACTXT_F_LAST_CTXT, &ctxt->flags);
-		if ((ch+1)->rc_discrim == 0) {
-			/*
-			 * Checked in sq_cq_reap to see if we need to
-			 * be enqueued
-			 */
-			set_bit(RDMACTXT_F_LAST_CTXT, &ctxt->flags);
-			ctxt->next = hdr_ctxt;
-			hdr_ctxt->next = head;
-		}
 
 		/* Prepare READ WR */
 		memset(&read_wr, 0, sizeof read_wr);
@@ -352,7 +343,17 @@ next_sge:
 		rdma_set_ctxt_sge(ctxt, &sge[ch_sge_ary[ch_no].start],
 				  &sgl_offset,
 				  read_wr.num_sge);
-
+		if (((ch+1)->rc_discrim == 0) &&
+		    (read_wr.num_sge == ch_sge_ary[ch_no].count)) {
+			/*
+			 * Mark the last RDMA_READ with a bit to
+			 * indicate all RPC data has been fetched from
+			 * the client and the RPC needs to be enqueued.
+			 */
+			set_bit(RDMACTXT_F_LAST_CTXT, &ctxt->flags);
+			ctxt->next = hdr_ctxt;
+			hdr_ctxt->next = head;
+		}
 		/* Post the read */
 		err = svc_rdma_send(xprt, &read_wr);
 		if (err) {


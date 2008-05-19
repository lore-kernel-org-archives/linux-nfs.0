From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH] svcrdma: Remove unused wait q from svcrdma_xprt structure
Date: Mon, 19 May 2008 11:42:35 -0500
Message-ID: <1211215355.31725.40.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs <linux-nfs@vger.kernel.org>
To: Bruce Fields <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:43801 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759474AbYESQjG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 May 2008 12:39:06 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

   
The sc_read_wait queue head is no longer used. Remove it.
    
Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---
 include/linux/sunrpc/svc_rdma.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 0a9c431..e01cd2c 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -94,7 +94,6 @@ struct svcxprt_rdma {
 	struct rdma_cm_id    *sc_cm_id;		/* RDMA connection id */
 	struct list_head     sc_accept_q;	/* Conn. waiting accept */
 	int		     sc_ord;		/* RDMA read limit */
-	wait_queue_head_t    sc_read_wait;
 	int                  sc_max_sge;
 
 	int                  sc_sq_depth;	/* Depth of SQ */


From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH] SVCRDMA: Add check for XPT_CLOSE in svc_rdma_send
Date: Tue, 11 Mar 2008 12:44:27 -0500
Message-ID: <1205257467.4795.3.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:55573 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752534AbYCKReD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Mar 2008 13:34:03 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

SVCRDMA: Add check for XPT_CLOSE in svc_rdma_send
    
The svcrdma transport can crash if a send is waiting for an
empty SQ slot and the connection is closed due to an asynchronous error.
The crash is caused when svc_rdma_send attempts to send on a deleted
QP.
    
Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

This is not a critical fix for 2.6.25, but part of a general clean up of the error paths.

 net/sunrpc/xprtrdma/svc_rdma_transport.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 16fd3f6..af408fc 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -1036,6 +1036,8 @@ int svc_rdma_send(struct svcxprt_rdma *xprt, struct ib_send_wr *wr)
 			wait_event(xprt->sc_send_wait,
 				   atomic_read(&xprt->sc_sq_count) <
 				   xprt->sc_sq_depth);
+			if (test_bit(XPT_CLOSE, &xprt->sc_xprt.xpt_flags))
+				return 0;
 			continue;
 		}
 		/* Bumped used SQ WR count and post */


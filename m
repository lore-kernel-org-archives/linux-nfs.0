From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH 10/12] svcrdma: Fix IRD/ORD polarity
Date: Fri,  3 Oct 2008 16:33:47 -0500
Message-ID: <1223069629-5267-11-git-send-email-tom@opengridcomputing.com>
References: <1223069629-5267-1-git-send-email-tom@opengridcomputing.com>
 <1223069629-5267-2-git-send-email-tom@opengridcomputing.com>
 <1223069629-5267-3-git-send-email-tom@opengridcomputing.com>
 <1223069629-5267-4-git-send-email-tom@opengridcomputing.com>
 <1223069629-5267-5-git-send-email-tom@opengridcomputing.com>
 <1223069629-5267-6-git-send-email-tom@opengridcomputing.com>
 <1223069629-5267-7-git-send-email-tom@opengridcomputing.com>
 <1223069629-5267-8-git-send-email-tom@opengridcomputing.com>
 <1223069629-5267-9-git-send-email-tom@opengridcomputing.com>
 <1223069629-5267-10-git-send-email-tom@opengridcomputing.com>
Cc: thomas.talpey@netapp.com, linux-nfs@vger.kernel.org,
	Tom Tucker <tom@opengridcomputing.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:40991 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753428AbYJCVdv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Oct 2008 17:33:51 -0400
In-Reply-To: <1223069629-5267-10-git-send-email-tom@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The inititator/responder resources in the event have been swapped. They
no represent what the local peer would set their values to in order to
match the peer. Note that iWARP does not exchange these on the wire and
the provider is simply putting in the local device max.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>

---
 net/sunrpc/xprtrdma/svc_rdma_transport.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 36e2cc4..bd17023 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -598,7 +598,7 @@ static int rdma_listen_handler(struct rdma_cm_id *cma_id,
 		dprintk("svcrdma: Connect request on cma_id=%p, xprt = %p, "
 			"event=%d\n", cma_id, cma_id->context, event->event);
 		handle_connect_req(cma_id,
-				   event->param.conn.responder_resources);
+				   event->param.conn.initiator_depth);
 		break;
 
 	case RDMA_CM_EVENT_ESTABLISHED:

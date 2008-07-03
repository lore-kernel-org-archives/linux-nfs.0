From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH 08/11] svcrdma: Limit ORD based on client's advertised IRD
Date: Wed,  2 Jul 2008 21:27:40 -0500
Message-ID: <1215052063-7330-9-git-send-email-tom@opengridcomputing.com>
References: <1215052063-7330-1-git-send-email-tom@opengridcomputing.com>
 <1215052063-7330-2-git-send-email-tom@opengridcomputing.com>
 <1215052063-7330-3-git-send-email-tom@opengridcomputing.com>
 <1215052063-7330-4-git-send-email-tom@opengridcomputing.com>
 <1215052063-7330-5-git-send-email-tom@opengridcomputing.com>
 <1215052063-7330-6-git-send-email-tom@opengridcomputing.com>
 <1215052063-7330-7-git-send-email-tom@opengridcomputing.com>
 <1215052063-7330-8-git-send-email-tom@opengridcomputing.com>
Cc: linux-nfs@vger.kernel.org, Tom Tucker <tom@opengridcomputing.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:48839 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753402AbYGCC1p (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Jul 2008 22:27:45 -0400
In-Reply-To: <1215052063-7330-8-git-send-email-tom@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When adapters have differing IRD limits, the RDMA transport will fail to
connect properly. The RDMA transport should use the client's advertised
inbound read limit when computing its outbound read limit. For iWARP
transports, there is currently no standard for exchanging IRD/ORD
during connection establishment so the 'responder_resources' field in the
connect event is the local device's limit. The RDMA transport can be
configured to use a smaller ORD by writing the desired number to the
/proc/sys/sunrpc/svc_rdma/max_outbound_read_requests file.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>

---
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   16 ++++++++++++----
 1 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 7647789..80104f4 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -606,7 +606,7 @@ int svc_rdma_post_recv(struct svcxprt_rdma *xprt)
  * will call the recvfrom method on the listen xprt which will accept the new
  * connection.
  */
-static void handle_connect_req(struct rdma_cm_id *new_cma_id)
+static void handle_connect_req(struct rdma_cm_id *new_cma_id, size_t client_ird)
 {
 	struct svcxprt_rdma *listen_xprt = new_cma_id->context;
 	struct svcxprt_rdma *newxprt;
@@ -623,6 +623,9 @@ static void handle_connect_req(struct rdma_cm_id *new_cma_id)
 	dprintk("svcrdma: Creating newxprt=%p, cm_id=%p, listenxprt=%p\n",
 		newxprt, newxprt->sc_cm_id, listen_xprt);
 
+	/* Save client advertised inbound read limit for use later in accept. */
+	newxprt->sc_ord = client_ird;
+
 	/* Set the local and remote addresses in the transport */
 	sa = (struct sockaddr *)&newxprt->sc_cm_id->route.addr.dst_addr;
 	svc_xprt_set_remote(&newxprt->sc_xprt, sa, svc_addr_len(sa));
@@ -659,7 +662,8 @@ static int rdma_listen_handler(struct rdma_cm_id *cma_id,
 	case RDMA_CM_EVENT_CONNECT_REQUEST:
 		dprintk("svcrdma: Connect request on cma_id=%p, xprt = %p, "
 			"event=%d\n", cma_id, cma_id->context, event->event);
-		handle_connect_req(cma_id);
+		handle_connect_req(cma_id,
+				   event->param.conn.responder_resources);
 		break;
 
 	case RDMA_CM_EVENT_ESTABLISHED:
@@ -833,8 +837,12 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 				   (size_t)svcrdma_max_requests);
 	newxprt->sc_sq_depth = RPCRDMA_SQ_DEPTH_MULT * newxprt->sc_max_requests;
 
-	newxprt->sc_ord =  min((size_t)devattr.max_qp_rd_atom,
-			       (size_t)svcrdma_ord);
+	/*
+	 * Limit ORD based on client limit, local device limit, and
+	 * configured svcrdma limit.
+	 */
+	newxprt->sc_ord = min_t(size_t, devattr.max_qp_rd_atom, newxprt->sc_ord);
+	newxprt->sc_ord = min_t(size_t,	svcrdma_ord, newxprt->sc_ord);
 
 	newxprt->sc_pd = ib_alloc_pd(newxprt->sc_cm_id->device);
 	if (IS_ERR(newxprt->sc_pd)) {

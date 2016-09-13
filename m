Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35962 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758087AbcIMOxR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Sep 2016 10:53:17 -0400
Subject: [PATCH v3 5/6] svcrdma: Server-side support for
 rpcrdma_connect_private
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 13 Sep 2016 10:53:15 -0400
Message-ID: <20160913145315.5733.2891.stgit@klimt.1015granger.net>
In-Reply-To: <20160913144246.5733.66229.stgit@klimt.1015granger.net>
References: <20160913144246.5733.66229.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Prepare to receive an RDMA-CM private message when handling a new
connection attempt, and send a similar message as part of connection
acceptance.

Both sides can communicate their various implementation limits.
Implementations that don't support this sideband protocol ignore it.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Sagi Grimberg <sagi@grimberg.me>
---
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   34 ++++++++++++++++++++++++++----
 1 file changed, 30 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 924271c..f51e98a 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -648,6 +648,21 @@ int svc_rdma_repost_recv(struct svcxprt_rdma *xprt, gfp_t flags)
 	return ret;
 }
 
+static void
+svc_rdma_parse_connect_private(struct svcxprt_rdma *newxprt,
+			       struct rdma_conn_param *param)
+{
+	const struct rpcrdma_connect_private *pmsg = param->private_data;
+
+	if (pmsg &&
+	    pmsg->cp_magic == rpcrdma_cmp_magic &&
+	    pmsg->cp_version == RPCRDMA_CMP_VERSION) {
+		dprintk("svcrdma: client send_size %u, recv_size %u\n",
+			rpcrdma_decode_buffer_size(pmsg->cp_send_size),
+			rpcrdma_decode_buffer_size(pmsg->cp_recv_size));
+	}
+}
+
 /*
  * This function handles the CONNECT_REQUEST event on a listening
  * endpoint. It is passed the cma_id for the _new_ connection. The context in
@@ -659,7 +674,8 @@ int svc_rdma_repost_recv(struct svcxprt_rdma *xprt, gfp_t flags)
  * will call the recvfrom method on the listen xprt which will accept the new
  * connection.
  */
-static void handle_connect_req(struct rdma_cm_id *new_cma_id, size_t client_ird)
+static void handle_connect_req(struct rdma_cm_id *new_cma_id,
+			       struct rdma_conn_param *param)
 {
 	struct svcxprt_rdma *listen_xprt = new_cma_id->context;
 	struct svcxprt_rdma *newxprt;
@@ -675,9 +691,10 @@ static void handle_connect_req(struct rdma_cm_id *new_cma_id, size_t client_ird)
 	new_cma_id->context = newxprt;
 	dprintk("svcrdma: Creating newxprt=%p, cm_id=%p, listenxprt=%p\n",
 		newxprt, newxprt->sc_cm_id, listen_xprt);
+	svc_rdma_parse_connect_private(newxprt, param);
 
 	/* Save client advertised inbound read limit for use later in accept. */
-	newxprt->sc_ord = client_ird;
+	newxprt->sc_ord = param->initiator_depth;
 
 	/* Set the local and remote addresses in the transport */
 	sa = (struct sockaddr *)&newxprt->sc_cm_id->route.addr.dst_addr;
@@ -712,8 +729,7 @@ static int rdma_listen_handler(struct rdma_cm_id *cma_id,
 		dprintk("svcrdma: Connect request on cma_id=%p, xprt = %p, "
 			"event = %s (%d)\n", cma_id, cma_id->context,
 			rdma_event_msg(event->event), event->event);
-		handle_connect_req(cma_id,
-				   event->param.conn.initiator_depth);
+		handle_connect_req(cma_id, &event->param.conn);
 		break;
 
 	case RDMA_CM_EVENT_ESTABLISHED:
@@ -947,6 +963,7 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 	struct svcxprt_rdma *listen_rdma;
 	struct svcxprt_rdma *newxprt = NULL;
 	struct rdma_conn_param conn_param;
+	struct rpcrdma_connect_private pmsg;
 	struct ib_qp_init_attr qp_attr;
 	struct ib_device *dev;
 	unsigned int i;
@@ -1100,11 +1117,20 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 	/* Swap out the handler */
 	newxprt->sc_cm_id->event_handler = rdma_cma_handler;
 
+	/* Construct RDMA-CM private message */
+	pmsg.cp_magic = rpcrdma_cmp_magic;
+	pmsg.cp_version = RPCRDMA_CMP_VERSION;
+	pmsg.cp_flags = 0;
+	pmsg.cp_send_size = pmsg.cp_recv_size =
+		rpcrdma_encode_buffer_size(newxprt->sc_max_req_size);
+
 	/* Accept Connection */
 	set_bit(RDMAXPRT_CONN_PENDING, &newxprt->sc_flags);
 	memset(&conn_param, 0, sizeof conn_param);
 	conn_param.responder_resources = 0;
 	conn_param.initiator_depth = newxprt->sc_ord;
+	conn_param.private_data = &pmsg;
+	conn_param.private_data_len = sizeof(pmsg);
 	ret = rdma_accept(newxprt->sc_cm_id, &conn_param);
 	if (ret) {
 		dprintk("svcrdma: failed to accept new connection, ret=%d\n",


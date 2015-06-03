Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:43412 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754953AbbFCSkQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Jun 2015 14:40:16 -0400
Message-ID: <556F4A0C.2030804@oracle.com>
Date: Wed, 03 Jun 2015 11:40:12 -0700
From: Shirley Ma <shirley.ma@oracle.com>
MIME-Version: 1.0
To: "'Tom Tucker'" <tom@opengridcomputing.com>,
        Chuck Lever <Chuck.Lever@oracle.com>,
        Steve Wise <swise@opengridcomputing.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH RFC] NFS/RDMA Release resources in svcrdma when device is
 removed
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When removing underlying RDMA device, the rmmod will hang forever if there
are any outstanding NFS/RDMA client mounts. The outstanding NFS/RDMA counts 
could also prevent the server from shutting down. Further debugging shows 
that the existing connections are not teared down and resource are not 
released when receiving RDMA_CM_EVENT_DEVICE_REMOVAL event. It seems the 
original code missing svc_xprt_put() in RDMA_CM_EVENT_REMOVAL event handler 
thus svc_xprt_free is never invoked to release the existing connection resources.

The patch has been passed removing, adding device back and forth without 
stopping NFS/RDMA service. This will also allow a device to be unplugged 
and swapped out without shutting down NFS service.

Signed-off-by: Shirley Ma <shirley.ma@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_transport.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index f609c1c..2b82569 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -673,6 +673,7 @@ static int rdma_cma_handler(struct rdma_cm_id *cma_id,
 		if (xprt) {
 			set_bit(XPT_CLOSE, &xprt->xpt_flags);
 			svc_xprt_enqueue(xprt);
+			svc_xprt_put(xprt);
 		}
 		break;
 	default:

Shirley

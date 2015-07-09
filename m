Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f169.google.com ([209.85.220.169]:33204 "EHLO
	mail-qk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754627AbbGIUpM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jul 2015 16:45:12 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v1 1/5] NFS/RDMA Release resources in svcrdma when device is
	removed
To: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date: Thu, 09 Jul 2015 16:45:08 -0400
Message-ID: <20150709204508.8481.29228.stgit@klimt.1015granger.net>
In-Reply-To: <20150709204230.8481.45457.stgit@klimt.1015granger.net>
References: <20150709204230.8481.45457.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Shirley Ma <shirley.ma@oracle.com>

When removing underlying RDMA device, the rmmod will hang forever if there
are any outstanding NFS/RDMA client mounts. The outstanding NFS/RDMA counts
could also prevent the server from shutting down. Further debugging shows
that the existing connections are not teared down and resource are not
released when receiving RDMA_CM_EVENT_DEVICE_REMOVAL event. It seems the
original code missing svc_xprt_put() in RDMA_CM_EVENT_REMOVAL event handler
thus svc_xprt_free is never invoked to release the existing connection
resources.

The patch has been passed removing, adding device back and forth without
stopping NFS/RDMA service. This will also allow a device to be unplugged
and swapped out without shutting down NFS service.

BugLink: https://bugzilla.linux-nfs.org/show_bug.cgi?id=252
Signed-off-by: Shirley Ma <shirley.ma@oracle.com>
Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtrdma/svc_rdma_transport.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 6b36279..f4b9732 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -659,6 +659,7 @@ static int rdma_cma_handler(struct rdma_cm_id *cma_id,
 		if (xprt) {
 			set_bit(XPT_CLOSE, &xprt->xpt_flags);
 			svc_xprt_enqueue(xprt);
+			svc_xprt_put(xprt);
 		}
 		break;
 	default:


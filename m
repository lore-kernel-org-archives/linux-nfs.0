Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:39224 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727940AbeIJUEi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Sep 2018 16:04:38 -0400
Subject: [PATCH v1 13/22] xprtrdma: Re-organize the switch() in
 rpcrdma_conn_upcall
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 10 Sep 2018 11:10:04 -0400
Message-ID: <20180910151004.10564.66689.stgit@manet.1015granger.net>
In-Reply-To: <20180910150040.10564.97487.stgit@manet.1015granger.net>
References: <20180910150040.10564.97487.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Eliminate the FALLTHROUGH into the default arm to make the
switch easier to read.

Also, as long as I'm here, do not display the memory address of the
target rpcrdma_ep. A hashed memory address is of marginal use here.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |   17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 422d3db..c60172f 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -243,15 +243,15 @@
 	case RDMA_CM_EVENT_ROUTE_RESOLVED:
 		ia->ri_async_rc = 0;
 		complete(&ia->ri_done);
-		break;
+		return 0;
 	case RDMA_CM_EVENT_ADDR_ERROR:
 		ia->ri_async_rc = -EPROTO;
 		complete(&ia->ri_done);
-		break;
+		return 0;
 	case RDMA_CM_EVENT_ROUTE_ERROR:
 		ia->ri_async_rc = -ENETUNREACH;
 		complete(&ia->ri_done);
-		break;
+		return 0;
 	case RDMA_CM_EVENT_DEVICE_REMOVAL:
 #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
 		pr_info("rpcrdma: removing device %s for %s:%s\n",
@@ -292,16 +292,15 @@
 connected:
 		rpcrdma_conn_func(ep);
 		wake_up_all(&ep->rep_connect_wait);
-		/*FALLTHROUGH*/
+		break;
 	default:
-		dprintk("RPC:       %s: %s:%s on %s/%s (ep 0x%p): %s\n",
-			__func__,
-			rpcrdma_addrstr(r_xprt), rpcrdma_portstr(r_xprt),
-			ia->ri_device->name, ia->ri_ops->ro_displayname,
-			ep, rdma_event_msg(event->event));
 		break;
 	}
 
+	dprintk("RPC:       %s: %s:%s on %s/%s: %s\n", __func__,
+		rpcrdma_addrstr(r_xprt), rpcrdma_portstr(r_xprt),
+		ia->ri_device->name, ia->ri_ops->ro_displayname,
+		rdma_event_msg(event->event));
 	return 0;
 }
 

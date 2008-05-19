From: Peter Leckie <pleckie@sgi.com>
Subject: Re: [PATCH 03/04]  NFS/RDMA client stall patches
Date: Mon, 19 May 2008 13:51:26 +1000
Message-ID: <4830F93E.4020403@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: talpey@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.171.29]:35662 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755373AbYESDtS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 18 May 2008 23:49:18 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch changes rpcrdma_conn_func() to directly call 
xprt_disconnect() instead of directly waking the pending
task queue. It's also changes to more closely match the
tcp equivalent function.

Signed-off-by: Peter Leckie <pleckie-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Reviewed-by: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
X-Sgi-Pv: 970244
 <http://bugworks/query.cgi/970244>---
Index: linux-2.6.25.3/net/sunrpc/xprtrdma/rpc_rdma.c
===================================================================
--- linux-2.6.25.3.orig/net/sunrpc/xprtrdma/rpc_rdma.c
+++ linux-2.6.25.3/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -680,15 +680,13 @@ rpcrdma_conn_func(struct rpcrdma_ep *ep)
 {
        struct rpc_xprt *xprt = ep->rep_xprt;

-       spin_lock_bh(&xprt->transport_lock);
        if (ep->rep_connected > 0) {
+               spin_lock_bh(&xprt->transport_lock);
                if (!xprt_test_and_set_connected(xprt))
                        xprt_wake_pending_tasks(xprt, 0);
-       } else {
-               if (xprt_test_and_clear_connected(xprt))
-                       xprt_wake_pending_tasks(xprt, ep->rep_connected);
-       }
-       spin_unlock_bh(&xprt->transport_lock);
+               spin_unlock_bh(&xprt->transport_lock);
+       } else
+               xprt_disconnect(xprt);
 }

 /*


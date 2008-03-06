From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: nfs4 over rdma transport oops
Date: Thu, 06 Mar 2008 15:04:33 -0500
Message-ID: <EXNANE0169aZbLAX3cf0000004e@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:58664 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754602AbYCFUFF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Mar 2008 15:05:05 -0500
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m26K53Iw015409
	for <linux-nfs@vger.kernel.org>; Thu, 6 Mar 2008 12:05:04 -0800 (PST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond - the following patch worked to correct the oops in RPC/RDMA
on Shirish P's PPC machine. Can it be included in 2.6.25?

Tom.

------ 

Author: Tom Talpey <tmt@netapp.com>
Date:   Wed Feb 27 15:04:26 2008 -0500

    Prevent an RPC oops when freeing a dynamically allocated RDMA
    buffer, used in certain special-case large metadata operations.

    Signed-off-by: Tom Talpey <tmt@netapp.com>
    Signed-off-by: James Lentini <jlentini@netapp.com>

Index: linux-2.6.25-rc3/net/sunrpc/xprtrdma/transport.c
===================================================================
--- linux-2.6.25-rc3.orig/net/sunrpc/xprtrdma/transport.c
+++ linux-2.6.25-rc3/net/sunrpc/xprtrdma/transport.c
@@ -610,7 +610,11 @@
 		return;
 
 	req = container_of(buffer, struct rpcrdma_req, rl_xdr_buf[0]);
-	r_xprt = container_of(req->rl_buffer, struct rpcrdma_xprt, rx_buf);
+	if (req->rl_iov.length == 0) {	/* see allocate above */
+		r_xprt = container_of(((struct rpcrdma_req *) req->rl_buffer)->rl_buffer, 
+				      struct rpcrdma_xprt, rx_buf);
+	} else
+		r_xprt = container_of(req->rl_buffer, struct rpcrdma_xprt, rx_buf);
 	rep = req->rl_reply;
 
 	dprintk("RPC:       %s: called on 0x%p%s\n",


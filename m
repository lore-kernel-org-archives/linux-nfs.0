From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: nfs4 over rdma transport oops
Date: Wed, 27 Feb 2008 16:51:09 -0500
Message-ID: <EXNANE01nwpGR881Np7000000e3@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org
To: "Shirish Pargaonkar" <shirishpargaonkar@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:4848 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754845AbYB0VwD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Feb 2008 16:52:03 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Shirish, can you try the following patch and see if it allows you to
avoid increasing the inline read/write sizes?

The problem is that in the case where RPC large-metadata operations
overflow the buffer, the reallocated req->rl_buffer pointer is overloaded
to hold the pointer to the old rpcrdma_req, since we had to reallocate it.
So the container_of() calculation in xprt_rdma_free() backs up to garbage
not an r_xprt. Then, the switch(ia_memreg_strategy) in the deregistration
code looks at garbage and decides to ib_dereg_mr. Oops.

The better fix is a little more involved (remove the overloading), but this
one should nail the issue. Let us know! If it works, we can submit it to
Trond for inclusion asap.

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


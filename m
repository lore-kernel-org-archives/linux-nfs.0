Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:40966 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752058Ab0DLQLp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Apr 2010 12:11:45 -0400
Date: Mon, 12 Apr 2010 12:11:39 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, Tom Tucker <tom@ogc.us>
Subject: bugfix for 2.6.34
Message-ID: <20100412161139.GN17992@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Could you pull the following bugfix for 2.6.34?

  git://linux-nfs.org/~bfields/linux.git for-2.6.34

This fixes an rdma regression.  Thanks!

--b.

commit bade732a2848e640482c1e99629a90e085d574dd
Author: Tom Tucker <tom@ogc.us>
Date:   Sat Apr 3 08:27:29 2010 -0500

    svcrdma: RDMA support not yet compatible with RPC6
    
    RPC6 requires that it be possible to create endpoints that listen
    exclusively for IPv4 or IPv6 connection requests. This is not currently
    supported by the RDMA API.
    
    This fixes a server RDMA regression introduced by 37498292a "NFSD:
    Create PF_INET6 listener in write_ports".
    
    Signed-off-by: Tom Tucker<tom@opengridcomputing.com>
    Tested-by: Steve Wise <swise@opengridcomputing.com>
    Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 3fa5751..4e6bbf9 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -678,7 +678,10 @@ static struct svc_xprt *svc_rdma_create(struct svc_serv *serv,
 	int ret;
 
 	dprintk("svcrdma: Creating RDMA socket\n");
-
+	if (sa->sa_family != AF_INET) {
+		dprintk("svcrdma: Address family %d is not supported.\n", sa->sa_family);
+		return ERR_PTR(-EAFNOSUPPORT);
+	}
 	cma_xprt = rdma_create_xprt(serv, 1);
 	if (!cma_xprt)
 		return ERR_PTR(-ENOMEM);

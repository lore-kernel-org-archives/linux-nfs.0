Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:34485 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751868Ab0DCN1b (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 3 Apr 2010 09:27:31 -0400
Message-ID: <4BB74241.4060308@ogc.us>
Date: Sat, 03 Apr 2010 08:27:29 -0500
From: Tom Tucker <tom@ogc.us>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Chuck Lever <chuck.lever@oracle.com>,
        Steve Wise <swise@opengridcomputing.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-rdma@vger.kernel.org
Subject: [PATCH] svcrdma: RDMA support not yet compatible with RPC6
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

RPC6 requires that it be possible to create endpoints that listen
exclusively for IPv4 or IPv6 connection requests. This is not currently
supported by the RDMA API.

Signed-off-by: Tom Tucker<tom@opengridcomputing.com>
Tested-by: Steve Wise<swise@opengridcomputing.com>
---

  net/sunrpc/xprtrdma/svc_rdma_transport.c |    5 ++++-
  1 files changed, 4 insertions(+), 1 deletions(-)

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


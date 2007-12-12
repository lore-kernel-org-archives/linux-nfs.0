From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH 7/7] rdma: makefile
Date: Wed, 12 Dec 2007 16:13:30 -0600
Message-ID: <20071212221329.12650.56868.stgit@dell3.ogc.int>
References: <20071212221314.12650.69032.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:50861 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751568AbXLLWNa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Dec 2007 17:13:30 -0500
In-Reply-To: <20071212221314.12650.69032.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Add the svcrdma module to the xprtrdma makefile.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 net/sunrpc/xprtrdma/Makefile |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/xprtrdma/Makefile b/net/sunrpc/xprtrdma/Makefile
index 264f0fe..5a8f268 100644
--- a/net/sunrpc/xprtrdma/Makefile
+++ b/net/sunrpc/xprtrdma/Makefile
@@ -1,3 +1,8 @@
 obj-$(CONFIG_SUNRPC_XPRT_RDMA) += xprtrdma.o
 
 xprtrdma-y := transport.o rpc_rdma.o verbs.o
+
+obj-$(CONFIG_SUNRPC_XPRT_RDMA) += svcrdma.o
+
+svcrdma-y := svc_rdma.o svc_rdma_transport.o \
+	svc_rdma_marshal.o svc_rdma_sendto.o svc_rdma_recvfrom.o

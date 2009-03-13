From: Tom Talpey <tmtalpey@gmail.com>
Subject: [PATCH] SVCRDMA: fix recent printk format warnings.
Date: Thu, 12 Mar 2009 22:21:21 -0400
Message-ID: <20090313022121.11621.33521.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from qmta04.westchester.pa.mail.comcast.net ([76.96.62.40]:52695
	"EHLO QMTA04.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751867AbZCMCVY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Mar 2009 22:21:24 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

printk formats in prior commit were reversed/incorrect.
Compiled without warning on x86 and x86_64, but detected on ppc.

Signed-off-by: Tom Talpey <tmtalpey@gmail.com>
---

 net/sunrpc/xprtrdma/svc_rdma_sendto.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index d0bea98..6c26a67 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -235,7 +235,7 @@ static int map_xdr(struct svcxprt_rdma *xprt,
 	}
 
 	dprintk("svcrdma: map_xdr: sge_no %d page_no %d "
-		"page_base %zd page_len %zd head_len %d tail_len %d\n",
+		"page_base %u page_len %u head_len %zu tail_len %zu\n",
 		sge_no, page_no, xdr->page_base, xdr->page_len,
 		xdr->head[0].iov_len, xdr->tail[0].iov_len);
 


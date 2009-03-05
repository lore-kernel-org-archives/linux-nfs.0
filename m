From: Tom Talpey <tmtalpey@gmail.com>
Subject: [PATCH 1/4] SVCRDMA: remove faulty assertions in rpc/rdma chunk
	validation.
Date: Thu, 05 Mar 2009 16:17:47 -0500
Message-ID: <20090305211747.6517.14591.stgit@localhost.localdomain>
References: <20090305210738.6517.67862.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org, Tom Talpey <tmtalpey@gmail.com>,
	Tom Tucker <tom@opengridcomputing.com>
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from qmta07.westchester.pa.mail.comcast.net ([76.96.62.64]:45340
	"EHLO QMTA07.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752757AbZCEVRu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Mar 2009 16:17:50 -0500
In-Reply-To: <20090305210738.6517.67862.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Certain client-provided RPCRDMA chunk alignments result in an
additional scatter/gather entry, which triggered nfs/rdma server
assertions incorrectly. OpenSolaris nfs/rdma client connectathon
testing was blocked by these in the special/locking section.

Signed-off-by: Tom Talpey <tmtalpey@gmail.com>
Cc: Tom Tucker <tom@opengridcomputing.com>
---

 net/sunrpc/xprtrdma/svc_rdma_sendto.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index a3334e3..d0bea98 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -191,7 +191,6 @@ static int map_xdr(struct svcxprt_rdma *xprt,
 		   struct xdr_buf *xdr,
 		   struct svc_rdma_req_map *vec)
 {
-	int sge_max = (xdr->len+PAGE_SIZE-1) / PAGE_SIZE + 3;
 	int sge_no;
 	u32 sge_bytes;
 	u32 page_bytes;
@@ -235,7 +234,11 @@ static int map_xdr(struct svcxprt_rdma *xprt,
 		sge_no++;
 	}
 
-	BUG_ON(sge_no > sge_max);
+	dprintk("svcrdma: map_xdr: sge_no %d page_no %d "
+		"page_base %zd page_len %zd head_len %d tail_len %d\n",
+		sge_no, page_no, xdr->page_base, xdr->page_len,
+		xdr->head[0].iov_len, xdr->tail[0].iov_len);
+
 	vec->count = sge_no;
 	return 0;
 }
@@ -579,7 +582,6 @@ static int send_reply(struct svcxprt_rdma *rdma,
 			ctxt->sge[page_no+1].length = 0;
 	}
 	BUG_ON(sge_no > rdma->sc_max_sge);
-	BUG_ON(sge_no > ctxt->count);
 	memset(&send_wr, 0, sizeof send_wr);
 	ctxt->wr_op = IB_WR_SEND;
 	send_wr.wr_id = (unsigned long)ctxt;


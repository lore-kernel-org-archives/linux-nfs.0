From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 15/30] SVCRDMA: remove faulty assertions in rpc/rdma chunk
 validation.
Date: Wed, 11 Mar 2009 14:41:08 -0400
Message-ID: <20090311184108.5578.80559.stgit@heimdal.trondhjem.org>
References: <20090311184105.5578.22131.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Tom Talpey <tmtalpey@gmail.com>,
	Tom Tucker <tom@opengridcomputing.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:43206 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754192AbZCKSoG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Mar 2009 14:44:06 -0400
In-Reply-To: <20090311184105.5578.22131.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tom Talpey <tmtalpey@gmail.com>

Certain client-provided RPCRDMA chunk alignments result in an
additional scatter/gather entry, which triggered nfs/rdma server
assertions incorrectly. OpenSolaris nfs/rdma client connectathon
testing was blocked by these in the special/locking section.

Signed-off-by: Tom Talpey <tmtalpey@gmail.com>
Cc: Tom Tucker <tom@opengridcomputing.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
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


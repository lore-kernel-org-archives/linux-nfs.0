From: Tom Talpey <talpey@netapp.com>
Subject: [PATCH 09/15] RPC/RDMA: adhere to protocol for unpadded client
	trailing write chunks.
Date: Wed, 08 Oct 2008 11:48:25 -0400
Message-ID: <20081008154825.1336.79549.stgit@tmt3.nane.netapp.com>
References: <20081008154506.1336.59892.stgit@tmt3.nane.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [216.240.26.4] ([216.240.26.4]:44118 "EHLO tmt3.nane.netapp.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754597AbYJHQWU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Oct 2008 12:22:20 -0400
Received: from tmt3.nane.netapp.com (localhost.localdomain [127.0.0.1])
	by tmt3.nane.netapp.com (8.14.2/8.14.2) with ESMTP id m98FmPHE001529
	for <linux-nfs@vger.kernel.org>; Wed, 8 Oct 2008 11:48:25 -0400
In-Reply-To: <20081008154506.1336.59892.stgit-pfX4bTJKMULWwzOYslWYilaTQe2KTcn/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The RPC/RDMA protocol allows clients and servers to avoid RDMA
operations for data which is purely the result of XDR padding.
On the client, automatically insert the necessary padding for
such server replies, and optionally don't marshal such chunks.

Signed-off-by: Tom Talpey <talpey@netapp.com>
---

 net/sunrpc/xprtrdma/rpc_rdma.c  |   22 ++++++++++++++++++++--
 net/sunrpc/xprtrdma/transport.c |    9 +++++++++
 2 files changed, 29 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 721dae7..c4b8011 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -118,6 +118,11 @@ rpcrdma_convert_iovs(struct xdr_buf *xdrbuf, unsigned int pos,
 	}
 
 	if (xdrbuf->tail[0].iov_len) {
+		/* the rpcrdma protocol allows us to omit any trailing
+		 * xdr pad bytes, saving the server an RDMA operation. */
+		extern int xprt_rdma_pad_optimize; /* 0 == old server compat */
+		if (xdrbuf->tail[0].iov_len < 4 && xprt_rdma_pad_optimize)
+			return n;
 		if (n == nsegs)
 			return 0;
 		seg[n].mr_page = NULL;
@@ -594,7 +599,7 @@ rpcrdma_count_chunks(struct rpcrdma_rep *rep, unsigned int max, int wrchunk, __b
  * Scatter inline received data back into provided iov's.
  */
 static void
-rpcrdma_inline_fixup(struct rpc_rqst *rqst, char *srcp, int copy_len)
+rpcrdma_inline_fixup(struct rpc_rqst *rqst, char *srcp, int copy_len, int pad)
 {
 	int i, npages, curlen, olen;
 	char *destp;
@@ -660,6 +665,13 @@ rpcrdma_inline_fixup(struct rpc_rqst *rqst, char *srcp, int copy_len)
 	} else
 		rqst->rq_rcv_buf.tail[0].iov_len = 0;
 
+	if (pad) {
+		/* implicit padding on terminal chunk */
+		unsigned char *p = rqst->rq_rcv_buf.tail[0].iov_base;
+		while (pad--)
+			p[rqst->rq_rcv_buf.tail[0].iov_len++] = 0;
+	}
+
 	if (copy_len)
 		dprintk("RPC:       %s: %d bytes in"
 			" %d extra segments (%d lost)\n",
@@ -794,14 +806,20 @@ repost:
 			    ((unsigned char *)iptr - (unsigned char *)headerp);
 			status = rep->rr_len + rdmalen;
 			r_xprt->rx_stats.total_rdma_reply += rdmalen;
+			/* special case - last chunk may omit padding */
+			if (rdmalen &= 3) {
+				rdmalen = 4 - rdmalen;
+				status += rdmalen;
+			}
 		} else {
 			/* else ordinary inline */
+			rdmalen = 0;
 			iptr = (__be32 *)((unsigned char *)headerp + 28);
 			rep->rr_len -= 28; /*sizeof *headerp;*/
 			status = rep->rr_len;
 		}
 		/* Fix up the rpc results for upper layer */
-		rpcrdma_inline_fixup(rqst, (char *)iptr, rep->rr_len);
+		rpcrdma_inline_fixup(rqst, (char *)iptr, rep->rr_len, rdmalen);
 		break;
 
 	case __constant_htonl(RDMA_NOMSG):
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index ec6d1e7..c7d2380 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -71,6 +71,7 @@ static unsigned int xprt_rdma_max_inline_read = RPCRDMA_DEF_INLINE;
 static unsigned int xprt_rdma_max_inline_write = RPCRDMA_DEF_INLINE;
 static unsigned int xprt_rdma_inline_write_padding;
 static unsigned int xprt_rdma_memreg_strategy = RPCRDMA_FRMR;
+                int xprt_rdma_pad_optimize = 0;
 
 #ifdef RPC_DEBUG
 
@@ -136,6 +137,14 @@ static ctl_table xr_tunables_table[] = {
 		.extra2		= &max_memreg,
 	},
 	{
+		.ctl_name       = CTL_UNNUMBERED,
+		.procname	= "rdma_pad_optimize",
+		.data		= &xprt_rdma_pad_optimize,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
+	{
 		.ctl_name = 0,
 	},
 };


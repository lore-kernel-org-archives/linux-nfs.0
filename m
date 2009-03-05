From: Tom Talpey <tmtalpey@gmail.com>
Subject: [PATCH 2/4] XPRTRDMA: correct an rpc/rdma inline send marshaling error
Date: Thu, 05 Mar 2009 16:17:53 -0500
Message-ID: <20090305211753.6517.94091.stgit@localhost.localdomain>
References: <20090305210738.6517.67862.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org, Tom Talpey <tmtalpey@gmail.com>
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from qmta06.westchester.pa.mail.comcast.net ([76.96.62.56]:52484
	"EHLO QMTA06.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751903AbZCEVR4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Mar 2009 16:17:56 -0500
In-Reply-To: <20090305210738.6517.67862.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Certain client rpc's which contain both lengthy page-contained
metadata and a non-empty xdr_tail buffer require careful handling
to avoid overlapped memory copying. Rearranging of existing rpcrdma
marshaling code avoids it; this fixes an NFSv4 symlink creation error
detected with connectathon basic/test8 to multiple servers.

Signed-off-by: Tom Talpey <tmtalpey@gmail.com>
---

 net/sunrpc/xprtrdma/rpc_rdma.c |   26 ++++++++++++++------------
 1 files changed, 14 insertions(+), 12 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 14106d2..e5e28d1 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -310,6 +310,19 @@ rpcrdma_inline_pullup(struct rpc_rqst *rqst, int pad)
 		__func__, pad, destp, rqst->rq_slen, curlen);
 
 	copy_len = rqst->rq_snd_buf.page_len;
+
+	if (rqst->rq_snd_buf.tail[0].iov_len) {
+		curlen = rqst->rq_snd_buf.tail[0].iov_len;
+		if (destp + copy_len != rqst->rq_snd_buf.tail[0].iov_base) {
+			memmove(destp + copy_len,
+				rqst->rq_snd_buf.tail[0].iov_base, curlen);
+			r_xprt->rx_stats.pullup_copy_count += curlen;
+		}
+		dprintk("RPC:       %s: tail destp 0x%p len %d\n",
+			__func__, destp + copy_len, curlen);
+		rqst->rq_svec[0].iov_len += curlen;
+	}
+
 	r_xprt->rx_stats.pullup_copy_count += copy_len;
 	npages = PAGE_ALIGN(rqst->rq_snd_buf.page_base+copy_len) >> PAGE_SHIFT;
 	for (i = 0; copy_len && i < npages; i++) {
@@ -332,17 +345,6 @@ rpcrdma_inline_pullup(struct rpc_rqst *rqst, int pad)
 		destp += curlen;
 		copy_len -= curlen;
 	}
-	if (rqst->rq_snd_buf.tail[0].iov_len) {
-		curlen = rqst->rq_snd_buf.tail[0].iov_len;
-		if (destp != rqst->rq_snd_buf.tail[0].iov_base) {
-			memcpy(destp,
-				rqst->rq_snd_buf.tail[0].iov_base, curlen);
-			r_xprt->rx_stats.pullup_copy_count += curlen;
-		}
-		dprintk("RPC:       %s: tail destp 0x%p len %d curlen %d\n",
-			__func__, destp, copy_len, curlen);
-		rqst->rq_svec[0].iov_len += curlen;
-	}
 	/* header now contains entire send message */
 	return pad;
 }
@@ -656,7 +658,7 @@ rpcrdma_inline_fixup(struct rpc_rqst *rqst, char *srcp, int copy_len, int pad)
 		if (curlen > rqst->rq_rcv_buf.tail[0].iov_len)
 			curlen = rqst->rq_rcv_buf.tail[0].iov_len;
 		if (rqst->rq_rcv_buf.tail[0].iov_base != srcp)
-			memcpy(rqst->rq_rcv_buf.tail[0].iov_base, srcp, curlen);
+			memmove(rqst->rq_rcv_buf.tail[0].iov_base, srcp, curlen);
 		dprintk("RPC:       %s: tail srcp 0x%p len %d curlen %d\n",
 			__func__, srcp, copy_len, curlen);
 		rqst->rq_rcv_buf.tail[0].iov_len = curlen;


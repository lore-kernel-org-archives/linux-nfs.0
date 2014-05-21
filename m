Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:41792 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753430AbaEUWP2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 May 2014 18:15:28 -0400
Message-ID: <537D2578.7090401@oracle.com>
Date: Wed, 21 May 2014 15:15:20 -0700
From: Shirley Ma <shirley.ma@oracle.com>
MIME-Version: 1.0
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/1] xprtrdma: Allocate missing pagelist
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch is for 3.15-rc5. Please review it.

GETACL relies on transport layer to alloc memory for reply buffer.
However xprtrdma assumes that the reply buffer (pagelist) has been
pre-allocated in upper layer. This problem was reported by IOL OFA lab
test on PPC.

Signed-off-by: Shirley Ma <shirley.ma@oracle.com>
Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: Edward Mossman <emossman@iol.unh.edu>
---

 net/sunrpc/xprtrdma/rpc_rdma.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 96ead52..748b771 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -102,6 +102,12 @@ rpcrdma_convert_iovs(struct xdr_buf *xdrbuf, unsigned int pos,
 	page_base = xdrbuf->page_base & ~PAGE_MASK;
 	p = 0;
 	while (len && n < nsegs) {
+		if (!ppages[p]) {
+			/* alloc the pagelist for receiving buffer */
+			ppages[p] = alloc_page(GFP_ATOMIC);
+			if (!ppages[p])
+				return 0;
+		}
 		seg[n].mr_page = ppages[p];
 		seg[n].mr_offset = (void *)(unsigned long) page_base;
 		seg[n].mr_len = min_t(u32, PAGE_SIZE - page_base, len);


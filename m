Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f175.google.com ([209.85.223.175]:34103 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932144AbaE1Oe0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 May 2014 10:34:26 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v5 18/24] xprtrdma: Allocate missing pagelist
To: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Cc: Anna.Schumaker@netapp.com
Date: Wed, 28 May 2014 10:34:24 -0400
Message-ID: <20140528143424.23214.59578.stgit@manet.1015granger.net>
In-Reply-To: <20140528142521.23214.39655.stgit@manet.1015granger.net>
References: <20140528142521.23214.39655.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Shirley Ma <shirley.ma@oracle.com>

GETACL relies on transport layer to alloc memory for reply buffer.
However xprtrdma assumes that the reply buffer (pagelist) has been
pre-allocated in upper layer. This problem was reported by IOL OFA lab
test on PPC.

Signed-off-by: Shirley Ma <shirley.ma@oracle.com>
Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: Edward Mossman <emossman@iol.unh.edu>
---

 net/sunrpc/xprtrdma/rpc_rdma.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 436d229..dc4a826 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -99,6 +99,12 @@ rpcrdma_convert_iovs(struct xdr_buf *xdrbuf, unsigned int pos,
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


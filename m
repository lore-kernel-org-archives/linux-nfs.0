Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:34810 "EHLO
	mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751920AbcAGTtr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jan 2016 14:49:47 -0500
Subject: [PATCH v5 07/10] svcrdma: Remove last two __GFP_NOFAIL call sites
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org, dledford@redhat.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 07 Jan 2016 14:49:45 -0500
Message-ID: <20160107194945.2662.92723.stgit@klimt.1015granger.net>
In-Reply-To: <20160107194251.2662.88158.stgit@klimt.1015granger.net>
References: <20160107194251.2662.88158.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up.

These functions can otherwise fail, so check for page allocation
failures too.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Acked-by: Bruce Fields <bfields@fieldses.org>
---
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    |    5 ++++-
 net/sunrpc/xprtrdma/svc_rdma_transport.c |    4 +++-
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index aeaec7a..de7df7b 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -598,7 +598,10 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
 	inline_bytes = rqstp->rq_res.len;
 
 	/* Create the RDMA response header */
-	res_page = alloc_page(GFP_KERNEL | __GFP_NOFAIL);
+	ret = -ENOMEM;
+	res_page = alloc_page(GFP_KERNEL);
+	if (!res_page)
+		goto err0;
 	rdma_resp = page_address(res_page);
 	reply_ary = svc_rdma_get_reply_array(rdma_argp);
 	if (reply_ary)
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 20fc095..8b3ee04 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -1445,7 +1445,9 @@ void svc_rdma_send_error(struct svcxprt_rdma *xprt, struct rpcrdma_msg *rmsgp,
 	int length;
 	int ret;
 
-	p = alloc_page(GFP_KERNEL | __GFP_NOFAIL);
+	p = alloc_page(GFP_KERNEL);
+	if (!p)
+		return;
 	va = page_address(p);
 
 	/* XDR encode error */


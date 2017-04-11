Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:34856 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752757AbdDKRXt (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Apr 2017 13:23:49 -0400
Subject: [PATCH v3 10/13] xprtrdma: Annotate receive workqueue
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 11 Apr 2017 13:23:43 -0400
Message-ID: <20170411172343.11300.39507.stgit@manet.1015granger.net>
In-Reply-To: <20170411171820.11300.55637.stgit@manet.1015granger.net>
References: <20170411171820.11300.55637.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Micro-optimize the receive workqueue by marking it's anchor "read-
mostly."

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index d7c1600..3dbce9a 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -73,7 +73,7 @@
 static void rpcrdma_destroy_mrs(struct rpcrdma_buffer *buf);
 static void rpcrdma_dma_unmap_regbuf(struct rpcrdma_regbuf *rb);
 
-static struct workqueue_struct *rpcrdma_receive_wq;
+static struct workqueue_struct *rpcrdma_receive_wq __read_mostly;
 
 int
 rpcrdma_alloc_wq(void)


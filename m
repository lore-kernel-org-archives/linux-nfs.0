Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33622 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933065AbdCJQF6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Mar 2017 11:05:58 -0500
Subject: [PATCH v1 01/11] xprtrdma: Annotate receive workqueue
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 10 Mar 2017 11:05:56 -0500
Message-ID: <20170310160556.6314.89100.stgit@manet.1015granger.net>
In-Reply-To: <20170310154131.6314.35201.stgit@manet.1015granger.net>
References: <20170310154131.6314.35201.stgit@manet.1015granger.net>
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
index 81cd31a..8448f89 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -70,7 +70,7 @@
  * internal functions
  */
 
-static struct workqueue_struct *rpcrdma_receive_wq;
+static struct workqueue_struct *rpcrdma_receive_wq __read_mostly;
 
 int
 rpcrdma_alloc_wq(void)


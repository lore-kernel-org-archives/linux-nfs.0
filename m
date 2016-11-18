Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:33777 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753125AbcKRPAL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Nov 2016 10:00:11 -0500
Subject: [PATCH v2 09/12] xprtrdma: Squelch "max send,
 max recv" messages at connect time
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 18 Nov 2016 10:00:08 -0500
Message-ID: <20161118150008.10592.96160.stgit@manet.1015granger.net>
In-Reply-To: <20161118145547.10592.66470.stgit@manet.1015granger.net>
References: <20161118145547.10592.66470.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: This message was intended to be a dprintk, as it is on the
server-side.

Fixes: 87cfb9a0c85c ('xprtrdma: Client-side support for ...')
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index cbb1885..9f66fd8 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -223,8 +223,8 @@
 		cdata->inline_rsize = rsize;
 	if (wsize < cdata->inline_wsize)
 		cdata->inline_wsize = wsize;
-	pr_info("rpcrdma: max send %u, max recv %u\n",
-		cdata->inline_wsize, cdata->inline_rsize);
+	dprintk("RPC:       %s: max send %u, max recv %u\n",
+		__func__, cdata->inline_wsize, cdata->inline_rsize);
 	rpcrdma_set_max_header_sizes(r_xprt);
 }
 


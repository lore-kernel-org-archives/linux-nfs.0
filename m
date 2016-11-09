Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33234 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752325AbcKITGJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Nov 2016 14:06:09 -0500
Subject: [PATCH v1 09/14] xprtrdma: Shorten QP access error message
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 09 Nov 2016 14:06:03 -0500
Message-ID: <20161109190603.15007.14913.stgit@manet.1015granger.net>
In-Reply-To: <20161109184735.15007.96507.stgit@manet.1015granger.net>
References: <20161109184735.15007.96507.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: The convention for this type of warning message is not to
show the function name or "RPC:       ".

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 9f66fd8..11d0774 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -103,9 +103,9 @@
 {
 	struct rpcrdma_ep *ep = context;
 
-	pr_err("RPC:       %s: %s on device %s ep %p\n",
-	       __func__, ib_event_msg(event->event),
-		event->device->name, context);
+	pr_err("rpcrdma: %s on device %s ep %p\n",
+	       ib_event_msg(event->event), event->device->name, context);
+
 	if (ep->rep_connected == 1) {
 		ep->rep_connected = -EIO;
 		rpcrdma_conn_func(ep);


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it1-f194.google.com ([209.85.166.194]:50459 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726321AbeJBBFY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Oct 2018 21:05:24 -0400
Subject: [PATCH v2 14/20] xprtrdma: Remove memory address of "ep" from an
 error message
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 01 Oct 2018 14:26:19 -0400
Message-ID: <20181001182618.18578.35065.stgit@manet.1015granger.net>
In-Reply-To: <20181001182005.18578.57544.stgit@manet.1015granger.net>
References: <20181001182005.18578.57544.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Replace the hashed memory address of the target rpcrdma_ep
with the server's IP address and port. The server address is more
useful in an administrative error message.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index b62260a..9e04453 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -143,8 +143,9 @@
 						   rx_ep);
 
 	trace_xprtrdma_qp_event(r_xprt, event);
-	pr_err("rpcrdma: %s on device %s ep %p\n",
-	       ib_event_msg(event->event), event->device->name, context);
+	pr_err("rpcrdma: %s on device %s connected to %s:%s\n",
+	       ib_event_msg(event->event), event->device->name,
+	       rpcrdma_addrstr(r_xprt), rpcrdma_portstr(r_xprt));
 
 	if (ep->rep_connected == 1) {
 		ep->rep_connected = -EIO;

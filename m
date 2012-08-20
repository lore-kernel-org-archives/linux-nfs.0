Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54361 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755525Ab2HTVwM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Aug 2012 17:52:12 -0400
Date: Mon, 20 Aug 2012 17:52:10 -0400
To: linux-nfs@vger.kernel.org
Cc: NeilBrown <neilb@suse.de>, Malahal Naineni <malahal@us.ibm.com>
Subject: [PATCH] svcrpc: sends on closed socket should stop immediately
Message-ID: <20120820215210.GJ5779@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

svc_tcp_sendto sets XPT_CLOSE if we fail to transmit the entire reply.
However, the XPT_CLOSE won't be acted on immediately.  Meanwhile other
threads could send further replies before the socket is really shut
down.  This can manifest as data corruption: for example, if a truncated
read reply is followed by another rpc reply, that second reply will look
to the client like further read data.

Symptoms were data corruption preceded by svc_tcp_sendto logging
something like

	kernel: rpc-srv/tcp: nfsd: sent only 963696 when sending 1048708 bytes - shutting down socket

Cc: stable@vger.kernel.org
Reported-by: Malahal Naineni <malahal@us.ibm.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/svc_xprt.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Can anyone see a reason *not* to fail the send on a socket marked with
XPT_CLOSE?

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 88f2bf6..0d693a8 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -794,7 +794,8 @@ int svc_send(struct svc_rqst *rqstp)
 
 	/* Grab mutex to serialize outgoing data. */
 	mutex_lock(&xprt->xpt_mutex);
-	if (test_bit(XPT_DEAD, &xprt->xpt_flags))
+	if (test_bit(XPT_DEAD, &xprt->xpt_flags)
+			|| test_bit(XPT_CLOSE, &xprt->xpt_flags))
 		len = -ENOTCONN;
 	else
 		len = xprt->xpt_ops->xpo_sendto(rqstp);
-- 
1.7.9.5


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f173.google.com ([209.85.223.173]:42573 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933229AbbBIRTB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Feb 2015 12:19:01 -0500
Received: by iery20 with SMTP id y20so9664473ier.9
        for <linux-nfs@vger.kernel.org>; Mon, 09 Feb 2015 09:19:00 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 10/14] SUNRPC: Ensure xs_tcp_shutdown() requests a full close of the connection
Date: Mon,  9 Feb 2015 12:18:40 -0500
Message-Id: <1423502324-25981-11-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1423502324-25981-10-git-send-email-trond.myklebust@primarydata.com>
References: <1423502324-25981-1-git-send-email-trond.myklebust@primarydata.com>
 <1423502324-25981-2-git-send-email-trond.myklebust@primarydata.com>
 <1423502324-25981-3-git-send-email-trond.myklebust@primarydata.com>
 <1423502324-25981-4-git-send-email-trond.myklebust@primarydata.com>
 <1423502324-25981-5-git-send-email-trond.myklebust@primarydata.com>
 <1423502324-25981-6-git-send-email-trond.myklebust@primarydata.com>
 <1423502324-25981-7-git-send-email-trond.myklebust@primarydata.com>
 <1423502324-25981-8-git-send-email-trond.myklebust@primarydata.com>
 <1423502324-25981-9-git-send-email-trond.myklebust@primarydata.com>
 <1423502324-25981-10-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The previous behaviour left the connection half-open in order to try
to scrape the last replies from the socket. Now that we have more reliable
reconnection, change the behaviour to close down the socket faster.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/xprtsock.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 2f8db3499a17..3d83cbd32ef2 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -627,7 +627,7 @@ process_status:
  * @xprt: transport
  *
  * Initiates a graceful shutdown of the TCP socket by calling the
- * equivalent of shutdown(SHUT_WR);
+ * equivalent of shutdown(SHUT_RDWR);
  */
 static void xs_tcp_shutdown(struct rpc_xprt *xprt)
 {
@@ -635,7 +635,7 @@ static void xs_tcp_shutdown(struct rpc_xprt *xprt)
 	struct socket *sock = transport->sock;
 
 	if (sock != NULL) {
-		kernel_sock_shutdown(sock, SHUT_WR);
+		kernel_sock_shutdown(sock, SHUT_RDWR);
 		trace_rpc_socket_shutdown(xprt, sock);
 	}
 }
-- 
2.1.0


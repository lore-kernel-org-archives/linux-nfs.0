Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f172.google.com ([209.85.223.172]:44411 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933715AbbBIWs1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Feb 2015 17:48:27 -0500
Received: by iecrl12 with SMTP id rl12so20410213iec.11
        for <linux-nfs@vger.kernel.org>; Mon, 09 Feb 2015 14:48:26 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 10/15] SUNRPC: Ensure xs_tcp_shutdown() requests a full close of the connection
Date: Mon,  9 Feb 2015 17:48:06 -0500
Message-Id: <1423522091-35365-11-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1423522091-35365-10-git-send-email-trond.myklebust@primarydata.com>
References: <1423522091-35365-1-git-send-email-trond.myklebust@primarydata.com>
 <1423522091-35365-2-git-send-email-trond.myklebust@primarydata.com>
 <1423522091-35365-3-git-send-email-trond.myklebust@primarydata.com>
 <1423522091-35365-4-git-send-email-trond.myklebust@primarydata.com>
 <1423522091-35365-5-git-send-email-trond.myklebust@primarydata.com>
 <1423522091-35365-6-git-send-email-trond.myklebust@primarydata.com>
 <1423522091-35365-7-git-send-email-trond.myklebust@primarydata.com>
 <1423522091-35365-8-git-send-email-trond.myklebust@primarydata.com>
 <1423522091-35365-9-git-send-email-trond.myklebust@primarydata.com>
 <1423522091-35365-10-git-send-email-trond.myklebust@primarydata.com>
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


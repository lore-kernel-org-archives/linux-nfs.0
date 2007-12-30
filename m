From: Tom Tucker <tom@opengridcomputing.com>
Subject: SUNRPC Crash Fix
Date: Sun, 30 Dec 2007 10:07:17 -0600
Message-ID: <1199030837.31051.8.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs <linux-nfs@vger.kernel.org>
To: Le Rouzic <aime.le-rouzic@bull.net>,
	Bruce Fields <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:56505 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753741AbXL3QBO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 30 Dec 2007 11:01:14 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bruce/Aime:

Here is what I believe to be the fix for the crashes/svc_xprt BUG_ON
that people are seeing. It would be great if those who have seen this
problem could apply this patch and see if it resolves their problem. 

The common code calls svc_xprt_received on behalf of the transport.
Since the provider was calling it as well, this resulted in clearing the
busy bit/resetting xpt_pool when the BUSY bit wasn't held. 

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 4628881..4d39db1 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1272,7 +1272,6 @@ static struct svc_xprt *svc_create_socket(struct svc_serv *serv,
 
 	if ((svsk = svc_setup_socket(serv, sock, &error, flags)) != NULL) {
 		svc_xprt_set_local(&svsk->sk_xprt, newsin, newlen);
-		svc_xprt_received(&svsk->sk_xprt);
 		return (struct svc_xprt *)svsk;
 	}
 


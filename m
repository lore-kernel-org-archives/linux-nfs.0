Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:33745 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751808AbcHAUIj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Aug 2016 16:08:39 -0400
Received: by mail-io0-f196.google.com with SMTP id y195so14673803iod.0
        for <linux-nfs@vger.kernel.org>; Mon, 01 Aug 2016 13:07:40 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: Handle EADDRNOTAVAIL on connection failures
Date: Mon,  1 Aug 2016 15:08:28 -0400
Message-Id: <1470078508-52608-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the connect attempt immediately fails with an EADDRNOTAVAIL error, then
that means our choice of source port number was bad.
This error is expected when we set the SO_REUSEPORT socket option and we
have 2 sockets sharing the same source and destination address and port
combinations.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Fixes: 402e23b4ed9ed ("SUNRPC: Fix stupid typo in xs_sock_set_reuseport")
Cc: stable@vger.kernel.org # v4.0+
---
 net/sunrpc/xprtsock.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 111767ab124a..c6b1d48c4319 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2295,6 +2295,10 @@ static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 		/* SYN_SENT! */
 		if (xprt->reestablish_timeout < XS_TCP_INIT_REEST_TO)
 			xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;
+		break;
+	case -EADDRNOTAVAIL:
+		/* Source port number is unavailable. Try a new one! */
+		transport->srcport = 0;
 	}
 out:
 	return ret;
-- 
2.7.4


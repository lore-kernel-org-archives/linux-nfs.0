Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:5293 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754220Ab3IZVpd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Sep 2013 17:45:33 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/7] SUNRPC: Only update the TCP connect cookie on a successful connect
Date: Thu, 26 Sep 2013 17:45:01 -0400
Message-ID: <1380231907-13733-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1380231907-13733-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1380231907-13733-1-git-send-email-Trond.Myklebust@netapp.com>
 <1380231907-13733-2-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/xprtsock.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 208a763..9928ba1 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1511,6 +1511,7 @@ static void xs_tcp_state_change(struct sock *sk)
 			transport->tcp_copied = 0;
 			transport->tcp_flags =
 				TCP_RCV_COPY_FRAGHDR | TCP_RCV_COPY_XID;
+			xprt->connect_cookie++;
 
 			xprt_wake_pending_tasks(xprt, -EAGAIN);
 		}
@@ -2164,7 +2165,6 @@ static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 	case 0:
 	case -EINPROGRESS:
 		/* SYN_SENT! */
-		xprt->connect_cookie++;
 		if (xprt->reestablish_timeout < XS_TCP_INIT_REEST_TO)
 			xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;
 	}
-- 
1.8.3.1


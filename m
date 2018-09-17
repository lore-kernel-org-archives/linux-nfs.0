Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:41411 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728095AbeIQSbU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Sep 2018 14:31:20 -0400
Received: by mail-qt0-f193.google.com with SMTP id t39-v6so15113130qtc.8
        for <linux-nfs@vger.kernel.org>; Mon, 17 Sep 2018 06:04:05 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain ([66.187.232.65])
        by smtp.gmail.com with ESMTPSA id q1-v6sm10499607qkl.31.2018.09.17.06.04.03
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Sep 2018 06:04:03 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 07/44] SUNRPC: Move reset of TCP state variables into the reconnect code
Date: Mon, 17 Sep 2018 09:02:58 -0400
Message-Id: <20180917130335.112832-8-trond.myklebust@hammerspace.com>
In-Reply-To: <20180917130335.112832-7-trond.myklebust@hammerspace.com>
References: <20180917130335.112832-1-trond.myklebust@hammerspace.com>
 <20180917130335.112832-2-trond.myklebust@hammerspace.com>
 <20180917130335.112832-3-trond.myklebust@hammerspace.com>
 <20180917130335.112832-4-trond.myklebust@hammerspace.com>
 <20180917130335.112832-5-trond.myklebust@hammerspace.com>
 <20180917130335.112832-6-trond.myklebust@hammerspace.com>
 <20180917130335.112832-7-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Rather than resetting state variables in socket state_change() callback,
do it in the sunrpc TCP connect function itself.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/xprtsock.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index cd7d093721ae..ec1e3f93e707 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1600,13 +1600,6 @@ static void xs_tcp_state_change(struct sock *sk)
 	case TCP_ESTABLISHED:
 		spin_lock(&xprt->transport_lock);
 		if (!xprt_test_and_set_connected(xprt)) {
-
-			/* Reset TCP record info */
-			transport->recv.offset = 0;
-			transport->recv.len = 0;
-			transport->recv.copied = 0;
-			transport->recv.flags =
-				TCP_RCV_COPY_FRAGHDR | TCP_RCV_COPY_XID;
 			xprt->connect_cookie++;
 			clear_bit(XPRT_SOCK_CONNECTING, &transport->sock_state);
 			xprt_clear_connecting(xprt);
@@ -2386,6 +2379,12 @@ static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 
 	xs_set_memalloc(xprt);
 
+	/* Reset TCP record info */
+	transport->recv.offset = 0;
+	transport->recv.len = 0;
+	transport->recv.copied = 0;
+	transport->recv.flags = TCP_RCV_COPY_FRAGHDR | TCP_RCV_COPY_XID;
+
 	/* Tell the socket layer to start connecting... */
 	xprt->stat.connect_count++;
 	xprt->stat.connect_start = jiffies;
-- 
2.17.1

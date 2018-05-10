Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-fw-4101.amazon.com ([72.21.198.25]:44275 "EHLO
        smtp-fw-4101.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750758AbeEJGM5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 10 May 2018 02:12:57 -0400
From: Vallish Vaidyeshwara <vallish@amazon.com>
To: <trond.myklebust@primarydata.com>, <anna.schumaker@netapp.com>,
        <jlayton@kernel.org>, <bfields@fieldses.org>,
        <linux-nfs@vger.kernel.org>
CC: <jsstraus@amazon.com>
Subject: [PATCH 2/2] SUNRPC: Reconnect with new port on server initiated connection termination
Date: Thu, 10 May 2018 06:12:54 +0000
Message-ID: <1525932774-98736-3-git-send-email-vallish@amazon.com>
In-Reply-To: <1525932774-98736-1-git-send-email-vallish@amazon.com>
References: <1525932774-98736-1-git-send-email-vallish@amazon.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Server initiated socket close can corrupt connection state tracking
table in conjunction with other network middle boxes. In situations
like these, client connection hangs till connection state tracking
table entries age out and get purged. Client reconnection with a new
port in such a situation will avoid connection hang.

Reviewed-by: Jacob Strauss <jsstraus@amazon.com>
Reviewed-by: Alakesh Haloi <alakeshh@amazon.com>
Signed-off-by: Vallish Vaidyeshwara <vallish@amazon.com>
---
 net/sunrpc/xprtsock.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 5bf75b3..d293c8d 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1629,6 +1629,8 @@ static void xs_tcp_state_change(struct sock *sk)
 		/* The server initiated a shutdown of the socket */
 		xprt->connect_cookie++;
 		clear_bit(XPRT_CONNECTED, &xprt->state);
+		/* Server sent FIN, reconnect with a new port */
+		transport->srcport = 0;
 		xs_tcp_force_close(xprt);
 		/* fall through */
 	case TCP_CLOSING:
@@ -1650,6 +1652,9 @@ static void xs_tcp_state_change(struct sock *sk)
 					&transport->sock_state))
 			xprt_clear_connecting(xprt);
 		clear_bit(XPRT_CLOSING, &xprt->state);
+		/* Server sent RST, reconnect with a new port */
+		if (sk->sk_err == ECONNRESET)
+			transport->srcport = 0;
 		if (sk->sk_err)
 			xprt_wake_pending_tasks(xprt, -sk->sk_err);
 		/* Trigger the socket release */
-- 
2.7.3.AMZN


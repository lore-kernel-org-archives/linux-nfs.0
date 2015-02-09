Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f169.google.com ([209.85.223.169]:44416 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933756AbbBIWs2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Feb 2015 17:48:28 -0500
Received: by iecrl12 with SMTP id rl12so20410317iec.11
        for <linux-nfs@vger.kernel.org>; Mon, 09 Feb 2015 14:48:27 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 11/15] SUNRPC: Make xs_tcp_close() do a socket shutdown rather than a sock_release
Date: Mon,  9 Feb 2015 17:48:07 -0500
Message-Id: <1423522091-35365-12-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1423522091-35365-11-git-send-email-trond.myklebust@primarydata.com>
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
 <1423522091-35365-11-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use of socket shutdown() means that we monitor the shutdown process
through the xs_tcp_state_change() callback, so it is preferable to
a full close in all cases unless we're destroying the transport.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/xprtsock.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 3d83cbd32ef2..0279e8ffb14a 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -857,10 +857,7 @@ static void xs_close(struct rpc_xprt *xprt)
 
 static void xs_tcp_close(struct rpc_xprt *xprt)
 {
-	if (test_and_clear_bit(XPRT_CONNECTION_CLOSE, &xprt->state))
-		xs_close(xprt);
-	else
-		xs_tcp_shutdown(xprt);
+	xs_tcp_shutdown(xprt);
 }
 
 static void xs_xprt_free(struct rpc_xprt *xprt)
@@ -1033,7 +1030,6 @@ static void xs_udp_data_ready(struct sock *sk)
  */
 static void xs_tcp_force_close(struct rpc_xprt *xprt)
 {
-	set_bit(XPRT_CONNECTION_CLOSE, &xprt->state);
 	xprt_force_disconnect(xprt);
 }
 
-- 
2.1.0


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f172.google.com ([209.85.223.172]:39960 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933511AbbBIRTC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Feb 2015 12:19:02 -0500
Received: by iecrp18 with SMTP id rp18so11692149iec.7
        for <linux-nfs@vger.kernel.org>; Mon, 09 Feb 2015 09:19:01 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 11/14] SUNRPC: Make xs_tcp_close() do a socket shutdown rather than a sock_release
Date: Mon,  9 Feb 2015 12:18:41 -0500
Message-Id: <1423502324-25981-12-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1423502324-25981-11-git-send-email-trond.myklebust@primarydata.com>
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
 <1423502324-25981-11-git-send-email-trond.myklebust@primarydata.com>
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


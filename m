Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34258 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752293AbbH2UjE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 29 Aug 2015 16:39:04 -0400
Received: by pabzx8 with SMTP id zx8so96734031pab.1
        for <linux-nfs@vger.kernel.org>; Sat, 29 Aug 2015 13:39:03 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: xs_reset_transport must mark the connection as disconnected
Date: Sat, 29 Aug 2015 13:39:01 -0700
Message-Id: <1440880741-6670-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In case the reconnection attempt fails.

Cc: stable@vger.kernel.org
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/xprtsock.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 3dd7c7951254..e738ceb6b2ed 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -829,6 +829,7 @@ static void xs_reset_transport(struct sock_xprt *transport)
 	sk->sk_user_data = NULL;
 
 	xs_restore_old_callbacks(transport, sk);
+	xprt_clear_connected(xprt);
 	write_unlock_bh(&sk->sk_callback_lock);
 	xs_sock_reset_connection_flags(xprt);
 
-- 
2.4.3


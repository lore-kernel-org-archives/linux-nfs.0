Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33893 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750793AbbH3UI7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 30 Aug 2015 16:08:59 -0400
Received: by pabzx8 with SMTP id zx8so115721761pab.1
        for <linux-nfs@vger.kernel.org>; Sun, 30 Aug 2015 13:08:58 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: Prevent SYN+SYNACK+RST storms
Date: Sun, 30 Aug 2015 13:08:56 -0700
Message-Id: <1440965336-11411-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a shutdown() call before we release the socket in order to ensure the
reset is sent before we try to reconnect.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/xprtsock.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 214ca9dfb14e..7be90bc1a7c2 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -822,6 +822,8 @@ static void xs_reset_transport(struct sock_xprt *transport)
 	if (atomic_read(&transport->xprt.swapper))
 		sk_clear_memalloc(sk);
 
+	kernel_sock_shutdown(sock, SHUT_RDWR);
+
 	write_lock_bh(&sk->sk_callback_lock);
 	transport->inet = NULL;
 	transport->sock = NULL;
-- 
2.4.3


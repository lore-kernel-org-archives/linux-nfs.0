Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:35806 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752396AbdIRLVW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Sep 2017 07:21:22 -0400
From: Colin King <colin.king@canonical.com>
To: "J . Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "David S . Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org
Subject: [PATCH] sunrpc: remove redundant initialization of sock
Date: Mon, 18 Sep 2017 12:21:14 +0100
Message-Id: <20170918112114.29429-1-colin.king@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

sock is being initialized and then being almost immediately updated
hence the initialized value is not being used and is redundant. Remove
the initialization. Cleans up clang warning:

warning: Value stored to 'sock' during its initialization is never read

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 net/sunrpc/xprtsock.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 9b5de31aa429..c1841f234a71 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2203,7 +2203,7 @@ static void xs_udp_setup_socket(struct work_struct *work)
 	struct sock_xprt *transport =
 		container_of(work, struct sock_xprt, connect_worker.work);
 	struct rpc_xprt *xprt = &transport->xprt;
-	struct socket *sock = transport->sock;
+	struct socket *sock;
 	int status = -EIO;
 
 	sock = xs_create_sock(xprt, transport,
-- 
2.14.1


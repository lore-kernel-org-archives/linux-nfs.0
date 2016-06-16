Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.135]:54889 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754709AbcFPN4B (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Jun 2016 09:56:01 -0400
From: Arnd Bergmann <arnd@arndb.de>
To: netdev@vger.kernel.org
Cc: Arnd Bergmann <arnd@arndb.de>, "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH 8/8] sunrpc: fix old-style declaration
Date: Thu, 16 Jun 2016 15:57:13 +0200
Message-Id: <20160616135726.3313647-1-arnd@arndb.de>
In-Reply-To: <20160616135020.3154461-1-arnd@arndb.de>
References: <20160616135020.3154461-1-arnd@arndb.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Modern C standards expect the 'static' keyword to come before the return
type in a declaration, and we get a warning for this with "make W=1":

net/sunrpc/clnt.c:2580:1: error: 'static' is not at beginning of declaration [-Werror=old-style-declaration]

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 net/sunrpc/clnt.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 2808d550d273..cb49898a5a58 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2577,7 +2577,7 @@ static void rpc_cb_add_xprt_release(void *calldata)
 	kfree(data);
 }
 
-const static struct rpc_call_ops rpc_cb_add_xprt_call_ops = {
+static const struct rpc_call_ops rpc_cb_add_xprt_call_ops = {
 	.rpc_call_done = rpc_cb_add_xprt_done,
 	.rpc_release = rpc_cb_add_xprt_release,
 };
-- 
2.9.0


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45492 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751177AbbLBGR7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Dec 2015 01:17:59 -0500
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH] SUNRPC: drop unused xs_reclassify_socketX() helpers
Date: Wed,  2 Dec 2015 14:17:52 +0800
Message-Id: <1449037072-21642-1-git-send-email-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

xs_reclassify_socket4() and friends used to be called directly.
xs_reclassify_socket() is called instead nowadays.

The xs_reclassify_socketX() helper functions are empty when
CONFIG_DEBUG_LOCK_ALLOC is not defined.  Drop them since they have no
callers.

Note that AF_LOCAL still calls xs_reclassify_socketu() directly but is
easily converted to generic xs_reclassify_socket().

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 net/sunrpc/xprtsock.c | 14 +-------------
 1 file changed, 1 insertion(+), 13 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 1d1a704..dd367d4 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1907,18 +1907,6 @@ static inline void xs_reclassify_socket(int family, struct socket *sock)
 	}
 }
 #else
-static inline void xs_reclassify_socketu(struct socket *sock)
-{
-}
-
-static inline void xs_reclassify_socket4(struct socket *sock)
-{
-}
-
-static inline void xs_reclassify_socket6(struct socket *sock)
-{
-}
-
 static inline void xs_reclassify_socket(int family, struct socket *sock)
 {
 }
@@ -2008,7 +1996,7 @@ static int xs_local_setup_socket(struct sock_xprt *transport)
 			"transport socket (%d).\n", -status);
 		goto out;
 	}
-	xs_reclassify_socketu(sock);
+	xs_reclassify_socket(AF_LOCAL, sock);
 
 	dprintk("RPC:       worker connecting xprt %p via AF_LOCAL to %s\n",
 			xprt, xprt->address_strings[RPC_DISPLAY_ADDR]);
-- 
2.5.0


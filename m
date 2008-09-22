From: akpm@linux-foundation.org
Subject: [patch 2/3] sunrpc: do not pin sunrpc module in the memory
Date: Mon, 22 Sep 2008 14:54:34 -0700
Message-ID: <200809222154.m8MLsYW4032098@imap1.linux-foundation.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
	akpm@linux-foundation.org, den@openvz.org, chuck.lever@oracle.com,
	davem@davemloft.net
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:41687 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753791AbYIVVze (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Sep 2008 17:55:34 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>

Basically, try_module_get here are pretty useless. Any other module using
this API will pin sunrpc in memory due using exported symbols.

Signed-off-by: Denis V. Lunev <den@openvz.org>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Chuck Lever <chuck.lever@oracle.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/sunrpc/xprt.c |   12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff -puN net/sunrpc/xprt.c~sunrpc-do-not-pin-sunrpc-module-in-the-memory net/sunrpc/xprt.c
--- a/net/sunrpc/xprt.c~sunrpc-do-not-pin-sunrpc-module-in-the-memory
+++ a/net/sunrpc/xprt.c
@@ -108,13 +108,10 @@ int xprt_register_transport(struct xprt_
 			goto out;
 	}
 
-	result = -EINVAL;
-	if (try_module_get(THIS_MODULE)) {
-		list_add_tail(&transport->list, &xprt_list);
-		printk(KERN_INFO "RPC: Registered %s transport module.\n",
-			transport->name);
-		result = 0;
-	}
+	list_add_tail(&transport->list, &xprt_list);
+	printk(KERN_INFO "RPC: Registered %s transport module.\n",
+	       transport->name);
+	result = 0;
 
 out:
 	spin_unlock(&xprt_list_lock);
@@ -143,7 +140,6 @@ int xprt_unregister_transport(struct xpr
 				"RPC: Unregistered %s transport module.\n",
 				transport->name);
 			list_del_init(&transport->list);
-			module_put(THIS_MODULE);
 			goto out;
 		}
 	}
_

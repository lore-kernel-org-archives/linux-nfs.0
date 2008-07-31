From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 1/1] sunrpc: do not pin sunrpc module in the memory
Date: Thu, 31 Jul 2008 09:53:56 +0400
Message-ID: <1217483636-2574-1-git-send-email-den@openvz.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, "Denis V. Lunev" <den@openvz.org>
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:21904 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752367AbYGaFxh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 31 Jul 2008 01:53:37 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Basically, try_module_get here are pretty useless. Any other module using
this API will pin sunrpc in memory due using exported symbols.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/sunrpc/xprt.c |   12 ++++--------
 1 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 99a52aa..29e401b 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -108,13 +108,10 @@ int xprt_register_transport(struct xprt_class *transport)
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
@@ -143,7 +140,6 @@ int xprt_unregister_transport(struct xprt_class *transport)
 				"RPC: Unregistered %s transport module.\n",
 				transport->name);
 			list_del_init(&transport->list);
-			module_put(THIS_MODULE);
 			goto out;
 		}
 	}
-- 
1.5.4.5


From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 15/30] sunrpc: do not pin sunrpc module in the memory
Date: Tue, 07 Oct 2008 18:19:53 -0400
Message-ID: <20081007221953.20945.77951.stgit@localhost.localdomain>
References: <20081007221952.20945.69529.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: "Denis V. Lunev" <den@openvz.org>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52974 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756032AbYJGWcs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Oct 2008 18:32:48 -0400
In-Reply-To: <20081007221952.20945.69529.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Denis V. Lunev <den@openvz.org>

Basically, try_module_get here are pretty useless. Any other module using
this API will pin sunrpc in memory due using exported symbols.

Signed-off-by: Denis V. Lunev <den@openvz.org>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
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


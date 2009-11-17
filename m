From: akpm@linux-foundation.org
Subject: [patch 1/1] sunrpc: use formatting of module name in SUNRPC
Date: Tue, 17 Nov 2009 14:46:57 -0800
Message-ID: <200911172246.nAHMkvuI004689@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Cc: linux-nfs@vger.kernel.org, akpm@linux-foundation.org,
	raa.lkml@gmail.com, Trond.Myklebust@netapp.com, cel@citi.umich.edu,
	davem@davemloft.net, tmtalpey@gmail.com
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:50540 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756590AbZKQWrw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Nov 2009 17:47:52 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Alex Riesen <raa.lkml@gmail.com>

gcc-4.3.3 produces the warning:
  "format not a string literal and no format arguments"

Signed-off-by: Alex Riesen <raa.lkml@gmail.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Chuck Lever <cel@citi.umich.edu>
Cc: David S. Miller <davem@davemloft.net>
Acked-by: Tom Talpey <tmtalpey@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/sunrpc/xprt.c |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff -puN net/sunrpc/xprt.c~sunrpc-use-formatting-of-module-name-in-sunrpc net/sunrpc/xprt.c
--- a/net/sunrpc/xprt.c~sunrpc-use-formatting-of-module-name-in-sunrpc
+++ a/net/sunrpc/xprt.c
@@ -165,7 +165,6 @@ EXPORT_SYMBOL_GPL(xprt_unregister_transp
 int xprt_load_transport(const char *transport_name)
 {
 	struct xprt_class *t;
-	char module_name[sizeof t->name + 5];
 	int result;
 
 	result = 0;
@@ -177,9 +176,7 @@ int xprt_load_transport(const char *tran
 		}
 	}
 	spin_unlock(&xprt_list_lock);
-	strcpy(module_name, "xprt");
-	strncat(module_name, transport_name, sizeof t->name);
-	result = request_module(module_name);
+	result = request_module("xprt%s", transport_name);
 out:
 	return result;
 }
_

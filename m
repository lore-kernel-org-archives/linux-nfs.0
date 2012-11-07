Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:54212 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753693Ab2KGBI5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Nov 2012 20:08:57 -0500
Message-ID: <5099B49F.5070701@infradead.org>
Date: Tue, 06 Nov 2012 17:08:47 -0800
From: Randy Dunlap <rdunlap@infradead.org>
MIME-Version: 1.0
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: [PATCH] sunrpc: fix clnt.c kernel-doc warning
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Randy Dunlap <rdunlap@infradead.org>

Fix new kernel-doc warnings in clnt.c:

Warning(net/sunrpc/clnt.c:561): No description found for parameter 'flavor'
Warning(net/sunrpc/clnt.c:561): Excess function parameter 'auth' description in 'rpc_clone_client_set_auth'

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
Cc:	Trond Myklebust <Trond.Myklebust@netapp.com>
Cc:	"J. Bruce Fields" <bfields@fieldses.org>
Cc:	linux-nfs@vger.kernel.org
---
 net/sunrpc/clnt.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- lnx-37-rc4.orig/net/sunrpc/clnt.c
+++ lnx-37-rc4/net/sunrpc/clnt.c
@@ -552,7 +552,7 @@ EXPORT_SYMBOL_GPL(rpc_clone_client);
  * rpc_clone_client_set_auth - Clone an RPC client structure and set its auth
  *
  * @clnt: RPC client whose parameters are copied
- * @auth: security flavor for new client
+ * @flavor: security flavor for new client
  *
  * Returns a fresh RPC client or an ERR_PTR.
  */

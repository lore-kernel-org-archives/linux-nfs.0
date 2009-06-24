From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] sunrpc: fix missing kernel-doc
Date: Wed, 24 Jun 2009 10:53:07 -0700
Message-ID: <4A426803.4050807@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	David Miller <davem@davemloft.net>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:22095 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752051AbZFXRxW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Jun 2009 13:53:22 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix sunrpc kernel-doc warnings:

Warning(net/sunrpc/clnt.c:629): No description found for parameter 'req'
Warning(net/sunrpc/clnt.c:629): No description found for parameter 'tk_ops'
Warning(net/sunrpc/clnt.c:629): Excess function parameter 'ops' description in 'rpc_run_bc_task'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 net/sunrpc/clnt.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- linux-2.6.30-git22.orig/net/sunrpc/clnt.c
+++ linux-2.6.30-git22/net/sunrpc/clnt.c
@@ -622,7 +622,8 @@ EXPORT_SYMBOL_GPL(rpc_call_async);
 /**
  * rpc_run_bc_task - Allocate a new RPC task for backchannel use, then run
  * rpc_execute against it
- * @ops: RPC call ops
+ * @req: the RPC request
+ * @tk_ops: RPC call ops
  */
 struct rpc_task *rpc_run_bc_task(struct rpc_rqst *req,
 					const struct rpc_call_ops *tk_ops)



-- 
~Randy
LPC 2009, Sept. 23-25, Portland, Oregon
http://linuxplumbersconf.org/2009/

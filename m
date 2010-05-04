From: Johannes Weiner <jw-QdrG9jWwCLEAvxtiuMwx3w@public.gmane.org>
Subject: [patch] sunrpc: add missing return statement
Date: Tue, 4 May 2010 13:59:57 +0200
Message-ID: <20100504115759.266396633@emlix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexandros Batsakis <batsakis@netapp.com>,
	linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.emlix.com ([193.175.82.87]:34297 "EHLO mx1.emlix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752137Ab0EDMJ0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 May 2010 08:09:26 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

f300bab "nfsd41: sunrpc: add new xprt class for nfsv4.1 backchannel"
introduced an error case branch that lacks an actual `return' keyword
before the return value.  Add it.

Signed-off-by: Johannes Weiner <jw-QdrG9jWwCLEAvxtiuMwx3w@public.gmane.org>
Cc: Alexandros Batsakis <batsakis@netapp.com>
---
 net/sunrpc/xprtsock.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2444,7 +2444,7 @@ static struct rpc_xprt *xs_setup_bc_tcp(
 	struct svc_sock *bc_sock;
 
 	if (!args->bc_xprt)
-		ERR_PTR(-EINVAL);
+		return ERR_PTR(-EINVAL);
 
 	xprt = xs_setup_xprt(args, xprt_tcp_slot_table_entries);
 	if (IS_ERR(xprt))

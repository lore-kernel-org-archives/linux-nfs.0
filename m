From: Jani Nikula <ext-jani.1.nikula@nokia.com>
Subject: [PATCH] sunrpc: fix error path - actually return ERR_PTR() on error
Date: Fri, 12 Mar 2010 15:48:24 +0200
Message-ID: <1268401704-9034-1-git-send-email-ext-jani.1.nikula@nokia.com>
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, ext-jani.1.nikula@nokia.com
To: Trond.Myklebust@netapp.com, bfields@fieldses.org, neilb@suse.de,
	davem@davemloft.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:42932 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757495Ab0CLNtC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Mar 2010 08:49:02 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jani Nikula <ext-jani.1.nikula@nokia.com>

---

NOTE: I'm afraid I'm unable to test this; please consider this more a
bug report than a complete patch.
---
 net/sunrpc/xprtsock.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 7124129..5b83ff9 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2481,7 +2481,7 @@ static struct rpc_xprt *xs_setup_bc_tcp(struct xprt_create *args)
 	struct svc_sock *bc_sock;
 
 	if (!args->bc_xprt)
-		ERR_PTR(-EINVAL);
+		return ERR_PTR(-EINVAL);
 
 	xprt = xs_setup_xprt(args, xprt_tcp_slot_table_entries);
 	if (IS_ERR(xprt))
-- 
1.6.5.2


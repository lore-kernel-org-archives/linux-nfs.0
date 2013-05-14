Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35226 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758419Ab3ENVDn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 May 2013 17:03:43 -0400
Received: from bfields by fieldses.org with local (Exim 4.76)
	(envelope-from <bfields@fieldses.org>)
	id 1UcMNq-0004Kc-Kq
	for linux-nfs@vger.kernel.org; Tue, 14 May 2013 17:03:42 -0400
Date: Tue, 14 May 2013 17:03:42 -0400
To: linux-nfs@vger.kernel.org
Subject: [PATCH] sunrpc: server back channel needs no rpcbind method
Message-ID: <20130514210342.GJ1931@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

XPRT_BOUND is set on server backchannel xprts by xs_setup_bc_tcp()
(using xprt_set_bound()), and is never cleared, so ->rpcbind() will
never need to be called.

Reported-by: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/xprtsock.c |    1 -
 1 file changed, 1 deletion(-)

Trond pointed this out once, then the patch got lost for some reason.
Applying for 3.11.--b.

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index ffd5034..5d6b0da 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2534,7 +2534,6 @@ static struct rpc_xprt_ops bc_tcp_ops = {
 	.reserve_xprt		= xprt_reserve_xprt,
 	.release_xprt		= xprt_release_xprt,
 	.alloc_slot		= xprt_alloc_slot,
-	.rpcbind		= xs_local_rpcbind,
 	.buf_alloc		= bc_malloc,
 	.buf_free		= bc_free,
 	.send_request		= bc_send_request,
-- 
1.7.9.5


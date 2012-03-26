Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43459 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932614Ab2CZPkm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Mar 2012 11:40:42 -0400
Received: from bfields by fieldses.org with local (Exim 4.72)
	(envelope-from <bfields@fieldses.org>)
	id 1SCC2D-0006UG-Ra
	for linux-nfs@vger.kernel.org; Mon, 26 Mar 2012 11:40:41 -0400
Date: Mon, 26 Mar 2012 11:40:41 -0400
To: linux-nfs@vger.kernel.org
Subject: [PATCH] sunrpc: skip portmap calls on sessions backchannel
Message-ID: <20120326154041.GC22783@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Committing for 3.4.

(I noticed this while debugging the hang seen after applying jlayton's
patches.  It doesn't fix that, though.)

--b.

commit b3436278b5758647b942806c5da1c118a4e2540d
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Fri Mar 23 15:25:03 2012 -0400

    sunrpc: skip portmap calls on sessions backchannel
    
    There's obviously no point to doing portmap calls over the sessions
    backchannel.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 92bc518..890b03f 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2475,6 +2475,7 @@ static struct rpc_xprt_ops xs_tcp_ops = {
 static struct rpc_xprt_ops bc_tcp_ops = {
 	.reserve_xprt		= xprt_reserve_xprt,
 	.release_xprt		= xprt_release_xprt,
+	.rpcbind		= xs_local_rpcbind,
 	.buf_alloc		= bc_malloc,
 	.buf_free		= bc_free,
 	.send_request		= bc_send_request,

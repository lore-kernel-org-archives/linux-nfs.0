From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 01/85] sunrpc: get rid of rpc_rqst.rq_bufsize
Date: Mon, 10 Nov 2008 21:59:19 +0200
Message-ID: <1226347159-6561-1-git-send-email-bhalevy@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:60686 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750938AbYKJUSO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:18:14 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

rq_bufsize is not used.

Signed-off-by: Mike Sager <Mike.Sager@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/sunrpc/xprt.h |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 4d80a11..11fc71d 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -76,8 +76,7 @@ struct rpc_rqst {
 	struct list_head	rq_list;
 
 	__u32 *			rq_buffer;	/* XDR encode buffer */
-	size_t			rq_bufsize,
-				rq_callsize,
+	size_t			rq_callsize,
 				rq_rcvsize;
 
 	struct xdr_buf		rq_private_buf;		/* The receive buffer
-- 
1.6.0.2


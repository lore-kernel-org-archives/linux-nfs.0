Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:50229 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753125AbdEIJVV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 May 2017 05:21:21 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 24/32] sunrpc: remove kxdrproc_t
Date: Tue,  9 May 2017 11:20:02 +0200
Message-Id: <20170509092010.30752-25-hch@lst.de>
In-Reply-To: <20170509092010.30752-1-hch@lst.de>
References: <20170509092010.30752-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove the now unused typedef.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/sunrpc/xdr.h | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index ed0fbf0d8d0f..261b48a2701d 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -35,13 +35,6 @@ struct xdr_netobj {
 };
 
 /*
- * This is the legacy generic XDR function. rqstp is either a rpc_rqst
- * (client side) or svc_rqst pointer (server side).
- * Encode functions always assume there's enough room in the buffer.
- */
-typedef int	(*kxdrproc_t)(void *rqstp, __be32 *data, void *obj);
-
-/*
  * Basic structure for transmission/reception of a client XDR message.
  * Features a header (for a linear buffer containing RPC headers
  * and the data payload for short messages), and then an array of
-- 
2.11.0


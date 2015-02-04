Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f176.google.com ([209.85.213.176]:44292 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932593AbbBDV7f (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Feb 2015 16:59:35 -0500
Received: by mail-ig0-f176.google.com with SMTP id hl2so38108321igb.3
        for <linux-nfs@vger.kernel.org>; Wed, 04 Feb 2015 13:59:34 -0800 (PST)
Received: from manet.1015granger.net ([2604:8800:100:81fc:82ee:73ff:fe43:d64f])
        by mx.google.com with ESMTPSA id l6sm10187294igv.8.2015.02.04.13.59.33
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Feb 2015 13:59:33 -0800 (PST)
Subject: [PATCH] xprtrdma: Address sparse complaint in rpcr_to_rdmar()
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Wed, 04 Feb 2015 16:59:32 -0500
Message-ID: <20150204215801.20318.32174.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

With "make ARCH=x86_64 allmodconfig make C=1 CF=-D__CHECK_ENDIAN__":

linux-2.6/net/sunrpc/xprtrdma/xprt_rdma.h:273:30: warning: incorrect
  type in initializer (different base types)
linux-2.6/net/sunrpc/xprtrdma/xprt_rdma.h:273:30: expected restricted
  __be32 [usertype] *buffer
linux-2.6/net/sunrpc/xprtrdma/xprt_rdma.h:273:30:    got unsigned int
  [usertype] *rq_buffer

As far as I can tell this is a false positive.

Reported-by: kbuild-all@01.org
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtrdma/xprt_rdma.h |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index c9d2a02..d1b7039 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -270,9 +270,10 @@ struct rpcrdma_req {
 static inline struct rpcrdma_req *
 rpcr_to_rdmar(struct rpc_rqst *rqst)
 {
-	struct rpcrdma_regbuf *rb = container_of(rqst->rq_buffer,
-						 struct rpcrdma_regbuf,
-						 rg_base[0]);
+	void *buffer = rqst->rq_buffer;
+	struct rpcrdma_regbuf *rb;
+
+	rb = container_of(buffer, struct rpcrdma_regbuf, rg_base);
 	return rb->rg_owner;
 }
 


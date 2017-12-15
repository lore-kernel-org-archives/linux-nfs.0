Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:44912 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754713AbdLOB4T (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Dec 2017 20:56:19 -0500
Subject: [PATCH v1 03/16] xprtrdma: Eliminate unnecessary lock cycle in
 xprt_rdma_send_request
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 14 Dec 2017 20:56:18 -0500
Message-ID: <20171215015617.13776.817.stgit@manet.1015granger.net>
In-Reply-To: <20171215015403.13776.46706.stgit@manet.1015granger.net>
References: <20171215015403.13776.46706.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The rpcrdma_req is not shared yet, and its associated Send hasn't
been posted, thus RMW should be safe. There's no need for the
expense of a lock cycle here.

Fixes: 0ba6f37012db ("xprtrdma: Refactor rpcrdma_deferred_completion")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/transport.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 7f9b628..7db063f 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -735,7 +735,7 @@
 		goto drop_connection;
 	req->rl_connect_cookie = xprt->connect_cookie;
 
-	set_bit(RPCRDMA_REQ_F_PENDING, &req->rl_flags);
+	__set_bit(RPCRDMA_REQ_F_PENDING, &req->rl_flags);
 	if (rpcrdma_ep_post(&r_xprt->rx_ia, &r_xprt->rx_ep, req))
 		goto drop_connection;
 


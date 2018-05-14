Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:33944 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752109AbeENRUJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 14 May 2018 13:20:09 -0400
Received: by mail-it0-f66.google.com with SMTP id c5-v6so9168566itj.1
        for <linux-nfs@vger.kernel.org>; Mon, 14 May 2018 10:20:08 -0700 (PDT)
Subject: [PATCH] svcrdma: Fix incorrect return value/type in
 svc_rdma_post_recvs
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, dan.carpenter@oracle.com
Date: Mon, 14 May 2018 13:20:06 -0400
Message-ID: <20180514172006.2217.10418.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This crept in during the development process and wasn't caught
before I posted the "final" version.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Fixes: 0b2613c5883f ('svcrdma: Allocate recv_ctxt's on CPU ... ')
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index 09ce09b..841fca1 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -270,7 +270,7 @@ bool svc_rdma_post_recvs(struct svcxprt_rdma *rdma)
 	for (i = 0; i < rdma->sc_max_requests; i++) {
 		ctxt = svc_rdma_recv_ctxt_get(rdma);
 		if (!ctxt)
-			return -ENOMEM;
+			return false;
 		ctxt->rc_temp = true;
 		ret = __svc_rdma_post_recv(rdma, ctxt);
 		if (ret) {


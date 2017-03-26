Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:34720 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751510AbdCZX1i (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 26 Mar 2017 19:27:38 -0400
Received: by mail-it0-f68.google.com with SMTP id e75so1104238itd.1
        for <linux-nfs@vger.kernel.org>; Sun, 26 Mar 2017 16:27:37 -0700 (PDT)
Subject: [PATCH] svcrdma: set XPT_CONG_CTRL flag for bc xprt
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org, linux-nfs@vger.kernel.org
Date: Sun, 26 Mar 2017 19:27:35 -0400
Message-ID: <20170326231254.1319.26075.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Same change as Kinglong Mee's fix for the TCP backchannel service.

Fixes: 5283b03ee5cd ("nfs/nfsd/sunrpc: enforce transport...")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
Some (perhaps late) review comments on 5283b03ee5cd:

I have reservations about returning RPC_PROG_MISMATCH in this case.
RPC_PROG_UNAVAIL is more sensible. But the use of UDP with NFSv4 is
not an RPC-level error, thus reporting the problem here seems like a
layering violation.

I'm not sure why an explicit check is needed: if the server isn't
listening on UDP, wouldn't clients see a transport-level rejection
(like ECONNREFUSED)?

Are we certain that all client implementations (including
backchannel clients) will do something useful when presented with
such a rejection? At least in the backchannel case, the Linux server
had no idea what to do with RPC_PROG_MISMATCH on the backchannel.
The workload stopped dead, no error report anywhere.

 net/sunrpc/xprtrdma/svc_rdma_transport.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index c13a5c3..fc8f14c 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -127,6 +127,7 @@ static struct svc_xprt *svc_rdma_bc_create(struct svc_serv *serv,
 	xprt = &cma_xprt->sc_xprt;
 
 	svc_xprt_init(net, &svc_rdma_bc_class, xprt, serv);
+	set_bit(XPT_CONG_CTRL, &xprt->xpt_flags);
 	serv->sv_bc_xprt = xprt;
 
 	dprintk("svcrdma: %s(%p)\n", __func__, xprt);


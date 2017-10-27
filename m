Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:45432 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751736AbdJ0Qnz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Oct 2017 12:43:55 -0400
Subject: [PATCH 1/4] xprtrdma: Put Send CQ in IB_POLL_WORKQUEUE mode
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 27 Oct 2017 12:43:54 -0400
Message-ID: <20171027164354.10826.314.stgit@manet.1015granger.net>
In-Reply-To: <20171027164014.10826.10151.stgit@manet.1015granger.net>
References: <20171027164014.10826.10151.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Lift the Send and LocalInv completion handlers out of soft IRQ mode
to make room for other work. Also, move the Send CQ to a different
CPU than the CPU where the Receive CQ is running, for improved
scalability.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 22128a8..4cfa893 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -558,7 +558,7 @@
 
 	sendcq = ib_alloc_cq(ia->ri_device, NULL,
 			     ep->rep_attr.cap.max_send_wr + 1,
-			     0, IB_POLL_SOFTIRQ);
+			     1, IB_POLL_WORKQUEUE);
 	if (IS_ERR(sendcq)) {
 		rc = PTR_ERR(sendcq);
 		dprintk("RPC:       %s: failed to create send CQ: %i\n",


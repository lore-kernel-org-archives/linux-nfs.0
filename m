Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io1-f68.google.com ([209.85.166.68]:37717 "EHLO
        mail-io1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725975AbeJBAzA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Oct 2018 20:55:00 -0400
Subject: [PATCH v1 1/4] svcrdma: Reduce max_send_sges
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 01 Oct 2018 14:15:56 -0400
Message-ID: <20181001181556.2305.66320.stgit@klimt.1015granger.net>
In-Reply-To: <20181001181414.2305.94635.stgit@klimt.1015granger.net>
References: <20181001181414.2305.94635.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There's no need to request a large number of send SGEs because the
inline threshold already constrains the number of SGEs per Send.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 2848caf..2f7ec89 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -475,10 +475,12 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 
 	/* Qualify the transport resource defaults with the
 	 * capabilities of this particular device */
-	newxprt->sc_max_send_sges = dev->attrs.max_send_sge;
-	/* transport hdr, head iovec, one page list entry, tail iovec */
-	if (newxprt->sc_max_send_sges < 4) {
-		pr_err("svcrdma: too few Send SGEs available (%d)\n",
+	/* Transport header, head iovec, tail iovec */
+	newxprt->sc_max_send_sges = 3;
+	/* Add one SGE per page list entry */
+	newxprt->sc_max_send_sges += svcrdma_max_req_size / PAGE_SIZE;
+	if (newxprt->sc_max_send_sges > dev->attrs.max_send_sge) {
+		pr_err("svcrdma: too few Send SGEs available (%d needed)\n",
 		       newxprt->sc_max_send_sges);
 		goto errout;
 	}

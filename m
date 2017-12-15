Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:33895 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754661AbdLOB4D (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Dec 2017 20:56:03 -0500
Subject: [PATCH v1 01/16] xprtrdma: Fix buffer leak after transport set up
 failure
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 14 Dec 2017 20:56:01 -0500
Message-ID: <20171215015601.13776.43834.stgit@manet.1015granger.net>
In-Reply-To: <20171215015403.13776.46706.stgit@manet.1015granger.net>
References: <20171215015403.13776.46706.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This leak has been around forever, and is exceptionally rare.

EINVAL causes mount to fail with "an incorrect mount option was
specified" although it's not likely that one of the mount
options is incorrect. Instead, return ENODEV in this case, as this
appears to be an issue with system or device configuration rather
than a specific mount option.

Some obsolete comments are also removed.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/transport.c |   13 ++-----------
 1 file changed, 2 insertions(+), 11 deletions(-)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 6ee1ad8..7f9b628 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -414,20 +414,10 @@
 	if (rc)
 		goto out2;
 
-	/*
-	 * Allocate pre-registered send and receive buffers for headers and
-	 * any inline data. Also specify any padding which will be provided
-	 * from a preregistered zero buffer.
-	 */
 	rc = rpcrdma_buffer_create(new_xprt);
 	if (rc)
 		goto out3;
 
-	/*
-	 * Register a callback for connection events. This is necessary because
-	 * connection loss notification is async. We also catch connection loss
-	 * when reaping receives.
-	 */
 	INIT_DELAYED_WORK(&new_xprt->rx_connect_worker,
 			  xprt_rdma_connect_worker);
 
@@ -448,8 +438,9 @@
 	return xprt;
 
 out4:
+	rpcrdma_buffer_destroy(&new_xprt->rx_buf);
 	xprt_rdma_free_addresses(xprt);
-	rc = -EINVAL;
+	rc = -ENODEV;
 out3:
 	rpcrdma_ep_destroy(new_ep, &new_xprt->rx_ia);
 out2:


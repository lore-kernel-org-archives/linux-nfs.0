Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:36381 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751717AbdFHPx0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Jun 2017 11:53:26 -0400
Subject: [PATCH v2 13/13] xprtrdma: Fix documenting comments in frwr_ops.c
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 08 Jun 2017 11:53:24 -0400
Message-ID: <20170608155324.18945.10549.stgit@manet.1015granger.net>
In-Reply-To: <20170608154339.18945.5500.stgit@manet.1015granger.net>
References: <20170608154339.18945.5500.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up.

FASTREG and LOCAL_INV WRs are typically not signaled. localinv_wake
is used for the last LOCAL_INV WR in a chain, which is always
signaled. The documenting comments should reflect that.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/frwr_ops.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 8f63d38..6aea36a 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -277,7 +277,7 @@
 }
 
 /**
- * frwr_wc_fastreg - Invoked by RDMA provider for each polled FastReg WC
+ * frwr_wc_fastreg - Invoked by RDMA provider for a flushed FastReg WC
  * @cq:	completion queue (ignored)
  * @wc:	completed WR
  *
@@ -298,7 +298,7 @@
 }
 
 /**
- * frwr_wc_localinv - Invoked by RDMA provider for each polled LocalInv WC
+ * frwr_wc_localinv - Invoked by RDMA provider for a flushed LocalInv WC
  * @cq:	completion queue (ignored)
  * @wc:	completed WR
  *
@@ -319,7 +319,7 @@
 }
 
 /**
- * frwr_wc_localinv - Invoked by RDMA provider for each polled LocalInv WC
+ * frwr_wc_localinv_wake - Invoked by RDMA provider for a signaled LocalInv WC
  * @cq:	completion queue (ignored)
  * @wc:	completed WR
  *


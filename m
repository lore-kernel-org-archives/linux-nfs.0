Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:41209 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751527AbeEDTgJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 4 May 2018 15:36:09 -0400
Subject: [PATCH v1 19/19] xprtrdma: Remove transfertypes array
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 04 May 2018 15:36:08 -0400
Message-ID: <20180504193608.31688.80883.stgit@manet.1015granger.net>
In-Reply-To: <20180504192748.31688.3678.stgit@manet.1015granger.net>
References: <20180504192748.31688.3678.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: This array was used in a dprintk that was replaced by a
trace point in commit ab03eff58eb5 ("xprtrdma: Add trace points in
RPC Call transmit paths").

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c |    8 --------
 1 file changed, 8 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index a373d03..1c78516 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -55,14 +55,6 @@
 # define RPCDBG_FACILITY	RPCDBG_TRANS
 #endif
 
-static const char transfertypes[][12] = {
-	"inline",	/* no chunks */
-	"read list",	/* some argument via rdma read */
-	"*read list",	/* entire request via rdma read */
-	"write list",	/* some result via rdma write */
-	"reply chunk"	/* entire reply via rdma write */
-};
-
 /* Returns size of largest RPC-over-RDMA header in a Call message
  *
  * The largest Call header contains a full-size Read list and a


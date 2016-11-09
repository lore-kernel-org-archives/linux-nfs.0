Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:34236 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752325AbcKITGq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Nov 2016 14:06:46 -0500
Subject: [PATCH v1 14/14] xprtrdma: Update documenting comment
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 09 Nov 2016 14:06:44 -0500
Message-ID: <20161109190644.15007.90538.stgit@manet.1015granger.net>
In-Reply-To: <20161109184735.15007.96507.stgit@manet.1015granger.net>
References: <20161109184735.15007.96507.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: If reset fails, FRMRs are no longer abandoned, rather
they are released immediately. Update the comment to reflect this.

Fixes: 2ffc871a574d ('xprtrdma: Release orphaned MRs immediately')
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/frwr_ops.c |    4 ----
 1 file changed, 4 deletions(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 900dc40..47bed53 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -171,10 +171,6 @@
 }
 
 /* Reset of a single FRMR. Generate a fresh rkey by replacing the MR.
- *
- * There's no recovery if this fails. The FRMR is abandoned, but
- * remains in rb_all. It will be cleaned up when the transport is
- * destroyed.
  */
 static void
 frwr_op_recover_mr(struct rpcrdma_mw *mw)


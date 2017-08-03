Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:35931 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751933AbdHCSai (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Aug 2017 14:30:38 -0400
Received: by mail-io0-f196.google.com with SMTP id j32so1817916iod.3
        for <linux-nfs@vger.kernel.org>; Thu, 03 Aug 2017 11:30:38 -0700 (PDT)
Subject: [PATCH v1 5/7] xprtrdma: Remove opcode check in Receive completion
 handler
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Thu, 03 Aug 2017 14:30:36 -0400
Message-ID: <20170803183036.14672.51790.stgit@manet.1015granger.net>
In-Reply-To: <20170803182623.14672.77636.stgit@manet.1015granger.net>
References: <20170803182623.14672.77636.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: The opcode check is no longer necessary, because since
commit 2fa8f88d8892 ("xprtrdma: Use new CQ API for RPC-over-RDMA
client send CQs"), this completion handler is invoked only for
RECV work requests.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |    3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index f1b1c37..74dbba8 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -173,9 +173,6 @@
 		goto out_fail;
 
 	/* status == SUCCESS means all fields in wc are trustworthy */
-	if (wc->opcode != IB_WC_RECV)
-		return;
-
 	dprintk("RPC:       %s: rep %p opcode 'recv', length %u: success\n",
 		__func__, rep, wc->byte_len);
 


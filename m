Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:36673 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751325AbdCKUwu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 11 Mar 2017 15:52:50 -0500
Received: by mail-io0-f194.google.com with SMTP id 68so10078115ioh.3
        for <linux-nfs@vger.kernel.org>; Sat, 11 Mar 2017 12:52:49 -0800 (PST)
Subject: [PATCH] xprtrdma: Squelch kbuild sparse complaint
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Sat, 11 Mar 2017 15:52:47 -0500
Message-ID: <20170311205246.15791.28097.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

New complaint from kbuild for 4.9.y:

net/sunrpc/xprtrdma/verbs.c:489:19: sparse: incompatible types in
    comparison expression (different type sizes)

verbs.c:
489	max_sge = min(ia->ri_device->attrs.max_sge, RPCRDMA_MAX_SEND_SGES);

I can't reproduce this running sparse here. Likewise, "make W=1
net/sunrpc/xprtrdma/verbs.o" never indicated any issue.

A little poking suggests that because the range of its values is
small, gcc can make the actual width of RPCRDMA_MAX_SEND_SGES
smaller than the width of an unsigned integer.

Fixes: 16f906d66cd7 ("xprtrdma: Reduce required number of send SGEs")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: stable@kernel.org
---
 net/sunrpc/xprtrdma/verbs.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 81cd31a..3b332b3 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -503,7 +503,8 @@ static void rpcrdma_destroy_id(struct rdma_cm_id *id)
 	struct ib_cq *sendcq, *recvcq;
 	int rc;
 
-	max_sge = min(ia->ri_device->attrs.max_sge, RPCRDMA_MAX_SEND_SGES);
+	max_sge = min_t(unsigned int, ia->ri_device->attrs.max_sge,
+			RPCRDMA_MAX_SEND_SGES);
 	if (max_sge < RPCRDMA_MIN_SEND_SGES) {
 		pr_warn("rpcrdma: HCA provides only %d send SGEs\n", max_sge);
 		return -ENOMEM;


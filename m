Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:36833 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934322AbeB1Uau (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Feb 2018 15:30:50 -0500
Subject: [PATCH 5/8] xprtrdma: Reduce number of MRs created by
 rpcrdma_mrs_create
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 28 Feb 2018 15:30:49 -0500
Message-ID: <20180228203049.25968.62224.stgit@manet.1015granger.net>
In-Reply-To: <20180228202916.25968.21750.stgit@manet.1015granger.net>
References: <20180228202916.25968.21750.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Create fewer MRs on average. Many workloads don't need as many as
32 MRs, and the transport can now quickly restock the MR free list.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index d36c18f..ab86724 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1023,7 +1023,7 @@ void rpcrdma_sendctx_put_locked(struct rpcrdma_sendctx *sc)
 	LIST_HEAD(free);
 	LIST_HEAD(all);
 
-	for (count = 0; count < 32; count++) {
+	for (count = 0; count < 3; count++) {
 		struct rpcrdma_mr *mr;
 		int rc;
 


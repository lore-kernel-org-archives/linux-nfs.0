Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.opengridcomputing.com ([72.48.136.20]:57822 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755675AbaDPSfi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Apr 2014 14:35:38 -0400
From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH] xprtrdma: Set LOCAL_WRITE for memory regions with REMOTE_WRITE
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date: Wed, 16 Apr 2014 13:35:38 -0500
Message-ID: <20140416183538.23742.54560.stgit@build.ogc.int>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The commit below enforces the requirement that MRs with REMOTE_WRITE
must also have LOCAL_WRITE:

commit 1c636f801615bdfc9b1d46904e8258c7a025670b
Author: Eli Cohen <eli@dev.mellanox.co.il>
Date:   Thu Oct 31 15:26:32 2013 +0200

   IB/core: Encorce MR access rights rules on kernel consumers

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 net/sunrpc/xprtrdma/verbs.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 9b038e1..65ce677 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1637,7 +1637,8 @@ static int
 rpcrdma_register_default_external(struct rpcrdma_mr_seg *seg,
 			int *nsegs, int writing, struct rpcrdma_ia *ia)
 {
-	int mem_priv = (writing ? IB_ACCESS_REMOTE_WRITE :
+	int mem_priv = (writing ? IB_ACCESS_REMOTE_WRITE |
+				  IB_ACCESS_LOCAL_WRITE :
 				  IB_ACCESS_REMOTE_READ);
 	struct rpcrdma_mr_seg *seg1 = seg;
 	struct ib_phys_buf ipb[RPCRDMA_MAX_DATA_SEGS];


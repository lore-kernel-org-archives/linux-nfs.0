From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 2/2] SVCRDMA: Fix erroneous BUG_ON in send_write
Date: Tue, 11 Mar 2008 14:31:40 -0400
Message-ID: <1205260300-19127-3-git-send-email-bfields@citi.umich.edu>
References: <1205260300-19127-1-git-send-email-bfields@citi.umich.edu>
 <1205260300-19127-2-git-send-email-bfields@citi.umich.edu>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	Tom Tucker <tom@opengridcomputing.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:60199 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751185AbYCKSbm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Mar 2008 14:31:42 -0400
In-Reply-To: <1205260300-19127-2-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tom Tucker <tom@opengridcomputing.com>

The assertion that checks for sge context overflow is
incorrectly hard-coded to 32. This causes a kernel bug
check when using big-data mounts. Changed the BUG_ON to
use the computed value RPCSVC_MAXPAGES.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 net/sunrpc/xprtrdma/svc_rdma_sendto.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index 0598b22..981f190 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -156,7 +156,7 @@ static int send_write(struct svcxprt_rdma *xprt, struct svc_rqst *rqstp,
 	struct svc_rdma_op_ctxt *ctxt;
 	int ret = 0;
 
-	BUG_ON(sge_count >= 32);
+	BUG_ON(sge_count > RPCSVC_MAXPAGES);
 	dprintk("svcrdma: RDMA_WRITE rmr=%x, to=%llx, xdr_off=%d, "
 		"write_len=%d, xdr_sge=%p, sge_count=%d\n",
 		rmr, (unsigned long long)to, xdr_off,
-- 
1.5.4.rc2.60.gb2e62


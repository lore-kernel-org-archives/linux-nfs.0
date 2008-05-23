From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH] svcrdma: Add flush_scheduled_work to module exit function
Date: Fri, 23 May 2008 10:31:25 -0500
Message-ID: <1211556685.4114.14.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs <linux-nfs@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Bruce Fields <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:53390 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752135AbYEWP1g (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 May 2008 11:27:36 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

    
Make certain all transports pending free are flushed from the wq
before unloading the module.
    
    Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

Thanks to Andrew for pointing this out.

 net/sunrpc/xprtrdma/svc_rdma.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma.c b/net/sunrpc/xprtrdma/svc_rdma.c
index 88c0ca2..b370e5c 100644
--- a/net/sunrpc/xprtrdma/svc_rdma.c
+++ b/net/sunrpc/xprtrdma/svc_rdma.c
@@ -236,6 +236,7 @@ static ctl_table svcrdma_root_table[] = {
 void svc_rdma_cleanup(void)
 {
 	dprintk("SVCRDMA Module Removed, deregister RPC RDMA transport\n");
+	flush_scheduled_work();
 	if (svcrdma_table_header) {
 		unregister_sysctl_table(svcrdma_table_header);
 		svcrdma_table_header = NULL;


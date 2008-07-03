From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH 09/11] svcrdma: Add flush_scheduled_work to module exit function
Date: Wed,  2 Jul 2008 21:27:41 -0500
Message-ID: <1215052063-7330-10-git-send-email-tom@opengridcomputing.com>
References: <1215052063-7330-1-git-send-email-tom@opengridcomputing.com>
 <1215052063-7330-2-git-send-email-tom@opengridcomputing.com>
 <1215052063-7330-3-git-send-email-tom@opengridcomputing.com>
 <1215052063-7330-4-git-send-email-tom@opengridcomputing.com>
 <1215052063-7330-5-git-send-email-tom@opengridcomputing.com>
 <1215052063-7330-6-git-send-email-tom@opengridcomputing.com>
 <1215052063-7330-7-git-send-email-tom@opengridcomputing.com>
 <1215052063-7330-8-git-send-email-tom@opengridcomputing.com>
 <1215052063-7330-9-git-send-email-tom@opengridcomputing.com>
Cc: linux-nfs@vger.kernel.org, Tom Tucker <tom@opengridcomputing.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:48841 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753416AbYGCC1p (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Jul 2008 22:27:45 -0400
In-Reply-To: <1215052063-7330-9-git-send-email-tom@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make certain all transports pending free are flushed from the wq
before unloading the module.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>

---
 net/sunrpc/xprtrdma/svc_rdma.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma.c b/net/sunrpc/xprtrdma/svc_rdma.c
index 171f205..527acfd 100644
--- a/net/sunrpc/xprtrdma/svc_rdma.c
+++ b/net/sunrpc/xprtrdma/svc_rdma.c
@@ -239,6 +239,7 @@ static ctl_table svcrdma_root_table[] = {
 void svc_rdma_cleanup(void)
 {
 	dprintk("SVCRDMA Module Removed, deregister RPC RDMA transport\n");
+	flush_scheduled_work();
 	if (svcrdma_table_header) {
 		unregister_sysctl_table(svcrdma_table_header);
 		svcrdma_table_header = NULL;

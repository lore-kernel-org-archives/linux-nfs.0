From: andros@netapp.com
Subject: [PATCH 1/1] nfs41 do not allocate unused back channel pages
Date: Tue, 26 Jan 2010 20:49:49 -0500
Message-ID: <1264556989-7409-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:58384 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754650Ab0A1OEx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Jan 2010 09:04:53 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 net/sunrpc/svc.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 538ca43..c9991e8 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -506,6 +506,12 @@ svc_init_buffer(struct svc_rqst *rqstp, unsigned int size)
 {
 	unsigned int pages, arghi;
 
+#if defined(CONFIG_NFS_V4_1)
+	/* bc_xprt uses fore channel allocated buffers */
+	if (rqstp->rq_server->bc_xprt)
+		return 1;
+#endif /* CONFIG_NFS_V4_1 */
+
 	pages = size / PAGE_SIZE + 1; /* extra page as we hold both request and reply.
 				       * We assume one is at most one page
 				       */
-- 
1.6.6


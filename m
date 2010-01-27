From: andros@netapp.com
Subject: [PATCH 1/1] nfs41 do not allocate unused back channel pages
Date: Tue, 26 Jan 2010 21:24:04 -0500
Message-ID: <1264559044-23961-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:64629 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753083Ab0A1OjH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Jan 2010 09:39:07 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/sunrpc/svc.h |   12 ++++++++++++
 net/sunrpc/svc.c           |    4 ++++
 2 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 5a3085b..02329f4 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -281,6 +281,18 @@ struct svc_rqst {
 };
 
 /*
+ * Determine if a shared backchannel is in use
+ */
+static inline int svc_is_backchannel(const struct svc_rqst *rqstp)
+{
+#ifdef CONFIG_NFS_V4_1
+	if (rqstp->rq_server->bc_xprt)
+		return 1;
+#endif /* CONFIG_NFS_V4_1 */
+	return 0;
+}
+
+/*
  * Rigorous type checking on sockaddr type conversions
  */
 static inline struct sockaddr_in *svc_addr_in(const struct svc_rqst *rqst)
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 538ca43..6dcf8c9 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -506,6 +506,10 @@ svc_init_buffer(struct svc_rqst *rqstp, unsigned int size)
 {
 	unsigned int pages, arghi;
 
+	/* bc_xprt uses fore channel allocated buffers */
+	if (svc_is_backchannel(rqstp))
+		return 1;
+
 	pages = size / PAGE_SIZE + 1; /* extra page as we hold both request and reply.
 				       * We assume one is at most one page
 				       */
-- 
1.6.6


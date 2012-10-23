Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:14548 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754948Ab2JWOxf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Oct 2012 10:53:35 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 17/25] SUNRPC: remove BUG_ONs checking RPCSVC_MAXPAGES
Date: Tue, 23 Oct 2012 10:43:41 -0400
Message-Id: <1351003429-18887-18-git-send-email-dros@netapp.com>
In-Reply-To: <1351003429-18887-1-git-send-email-dros@netapp.com>
References: <1351003429-18887-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace two bounds checking BUG_ON() calls with WARN_ON_ONCE() and resetting
the requested size to RPCSVC_MAXPAGES.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 net/sunrpc/svc.c      |    4 +++-
 net/sunrpc/svc_xprt.c |    5 ++++-
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 664979b..3bf5a54 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -587,7 +587,9 @@ svc_init_buffer(struct svc_rqst *rqstp, unsigned int size, int node)
 				       * We assume one is at most one page
 				       */
 	arghi = 0;
-	BUG_ON(pages > RPCSVC_MAXPAGES);
+	WARN_ON_ONCE(pages > RPCSVC_MAXPAGES);
+	if (pages > RPCSVC_MAXPAGES)
+		pages = RPCSVC_MAXPAGES;
 	while (pages) {
 		struct page *p = alloc_pages_node(node, GFP_KERNEL, 0);
 		if (!p)
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index be89bb6..35fa74b 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -579,7 +579,10 @@ int svc_alloc_arg(struct svc_rqst *rqstp)
 
 	/* now allocate needed pages.  If we get a failure, sleep briefly */
 	pages = (serv->sv_max_mesg + PAGE_SIZE) / PAGE_SIZE;
-	BUG_ON(pages >= RPCSVC_MAXPAGES);
+	WARN_ON_ONCE(pages >= RPCSVC_MAXPAGES);
+	if (pages >= RPCSVC_MAXPAGES)
+		/* use as many pages as possible */
+		pages = RPCSVC_MAXPAGES - 1;
 	for (i = 0; i < pages ; i++)
 		while (rqstp->rq_pages[i] == NULL) {
 			struct page *p = alloc_page(GFP_KERNEL);
-- 
1.7.9.6 (Apple Git-31.1)


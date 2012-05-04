Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f174.google.com ([209.85.160.174]:37436 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751227Ab2EDPoS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 May 2012 11:44:18 -0400
Received: by ghrr11 with SMTP id r11so2894043ghr.19
        for <linux-nfs@vger.kernel.org>; Fri, 04 May 2012 08:44:18 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] sunrpc: do array overrun check in svc_recv before allocating pages
Date: Fri,  4 May 2012 11:44:12 -0400
Message-Id: <1336146252-8669-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There's little point in waiting until after we allocate all of the pages
to see if we're going to overrun the array. In the event that this
calculation is really off we could end up scribbling over a bunch of
memory and make it tougher to debug.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 net/sunrpc/svc_xprt.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 4bda09d..8195c6a 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -601,6 +601,7 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
 
 	/* now allocate needed pages.  If we get a failure, sleep briefly */
 	pages = (serv->sv_max_mesg + PAGE_SIZE) / PAGE_SIZE;
+	BUG_ON(pages >= RPCSVC_MAXPAGES);
 	for (i = 0; i < pages ; i++)
 		while (rqstp->rq_pages[i] == NULL) {
 			struct page *p = alloc_page(GFP_KERNEL);
@@ -615,7 +616,6 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
 			rqstp->rq_pages[i] = p;
 		}
 	rqstp->rq_pages[i++] = NULL; /* this might be seen in nfs_read_actor */
-	BUG_ON(pages >= RPCSVC_MAXPAGES);
 
 	/* Make arg->head point to first page and arg->pages point to rest */
 	arg = &rqstp->rq_arg;
-- 
1.7.7.6


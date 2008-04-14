From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/24] SUNRPC: Use unsigned loop and array index in
	svc_init_buffer()
Date: Mon, 14 Apr 2008 12:27:52 -0400
Message-ID: <20080414162752.12741.15628.stgit@manray.1015granger.net>
References: <20080414162108.12741.73233.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu, trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]:40214 "EHLO
	flpi195.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760464AbYDNRBE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Apr 2008 13:01:04 -0400
In-Reply-To: <20080414162108.12741.73233.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Suppress a harmless compiler warning.

Index rq_pages[] with an unsigned type.  Make "pages" unsigned as well,
as it never represents a value less than zero.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/svc.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index c1e763b..86a5b56 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -504,8 +504,7 @@ EXPORT_SYMBOL(svc_destroy);
 static int
 svc_init_buffer(struct svc_rqst *rqstp, unsigned int size)
 {
-	int pages;
-	int arghi;
+	unsigned int pages, arghi;
 
 	pages = size / PAGE_SIZE + 1; /* extra page as we hold both request and reply.
 				       * We assume one is at most one page
@@ -519,7 +518,7 @@ svc_init_buffer(struct svc_rqst *rqstp, unsigned int size)
 		rqstp->rq_pages[arghi++] = p;
 		pages--;
 	}
-	return ! pages;
+	return pages == 0;
 }
 
 /*


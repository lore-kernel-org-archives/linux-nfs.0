Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:35545 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751322AbdF3QD4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Jun 2017 12:03:56 -0400
Received: by mail-it0-f68.google.com with SMTP id v193so3936905itc.2
        for <linux-nfs@vger.kernel.org>; Fri, 30 Jun 2017 09:03:56 -0700 (PDT)
Subject: [PATCH v1] sunrpc: Allocate up to RPCSVC_MAXPAGES per svc_rqst
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Fri, 30 Jun 2017 12:03:54 -0400
Message-ID: <20170630160258.11995.10205.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

svcrdma needs 259 pages for 1MB NFSv4.0 READ requests:

 - 1 page for the transport header and head iovec
 - 256 pages for the data payload
 - 1 page for the trailing GETATTR request (since NFSD XDR decoding
   does not look for a tail iovec, the GETATTR is stuck at the end
   of the rqstp->rq_arg.pages list)
 - 1 page for building the reply xdr_buf

But RPCSVC_MAXPAGES is already 259 (on x86_64). The problem is that
svc_alloc_arg never allocates that many pages. To address this:

1. The final element of rq_pages always points to NULL. To
   accommodate up to 259 pages in rq_pages, add an extra element
   to rq_pages for the array termination sentinel.

2. Adjust the calculation of "pages" to match how RPCSVC_MAXPAGES
   is calculated, so it can go up to 259. Bruce noted that the
   calculation assumes sv_max_mesg is a multiple of PAGE_SIZE,
   which might not always be true. I didn't change this assumption.

3. Change the loop boundaries to allow 259 pages to be allocated.

Additional clean-up: WARN_ON_ONCE adds an extra conditional branch,
which is basically never taken. And there's no need to dump the
stack here because svc_alloc_arg has only one caller.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
Hi Bruce-

This is what I proposed yesterday evening. Instead of changing
the value of RPCSVC_MAXPAGES, ensure that svc_alloc_arg can
safely allocate that many pages.


 include/linux/sunrpc/svc.h |    2 +-
 net/sunrpc/svc_xprt.c      |   10 ++++++----
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 11cef5a..d741399 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -246,7 +246,7 @@ struct svc_rqst {
 	size_t			rq_xprt_hlen;	/* xprt header len */
 	struct xdr_buf		rq_arg;
 	struct xdr_buf		rq_res;
-	struct page *		rq_pages[RPCSVC_MAXPAGES];
+	struct page		*rq_pages[RPCSVC_MAXPAGES + 1];
 	struct page *		*rq_respages;	/* points into rq_pages */
 	struct page *		*rq_next_page; /* next reply page to use */
 	struct page *		*rq_page_end;  /* one past the last page */
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 7bfe1fb..d16a8b4 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -659,11 +659,13 @@ static int svc_alloc_arg(struct svc_rqst *rqstp)
 	int i;
 
 	/* now allocate needed pages.  If we get a failure, sleep briefly */
-	pages = (serv->sv_max_mesg + PAGE_SIZE) / PAGE_SIZE;
-	WARN_ON_ONCE(pages >= RPCSVC_MAXPAGES);
-	if (pages >= RPCSVC_MAXPAGES)
+	pages = (serv->sv_max_mesg + 2 * PAGE_SIZE) >> PAGE_SHIFT;
+	if (pages > RPCSVC_MAXPAGES) {
+		pr_warn_once("svc: warning: pages=%u > RPCSVC_MAXPAGES=%lu\n",
+			     pages, RPCSVC_MAXPAGES);
 		/* use as many pages as possible */
-		pages = RPCSVC_MAXPAGES - 1;
+		pages = RPCSVC_MAXPAGES;
+	}
 	for (i = 0; i < pages ; i++)
 		while (rqstp->rq_pages[i] == NULL) {
 			struct page *p = alloc_page(GFP_KERNEL);


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:32945 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750912AbdE3SPQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 30 May 2017 14:15:16 -0400
Subject: [PATCH v1 09/17] sunrpc: Allocate one more page per svc_rqst
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 30 May 2017 14:15:14 -0400
Message-ID: <20170530181514.2992.43204.stgit@klimt.1015granger.net>
In-Reply-To: <20170530175808.2992.60365.stgit@klimt.1015granger.net>
References: <20170530175808.2992.60365.stgit@klimt.1015granger.net>
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

Note that RPCSVC_MAXPAGES is defined as:

	((RPCSVC_MAXPAYLOAD+PAGE_SIZE-1)/PAGE_SIZE + 2 + 1)

I don't understand why the "+PAGE_SIZE-1" is in there, because
division will always round the result down to

	(RPCSVC_MAXPAYLOAD / PAGE_SIZE + 2 + 1)

Let's remove the "-1" to get 260 pages maximum.

Then svc_alloc_args() needs to ask for pages according to this
same formula, otherwise it will never allocate enough.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/svc.h |    3 +--
 net/sunrpc/svc_xprt.c      |    8 +++++---
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 9463102..682cd7c 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -176,8 +176,7 @@ static inline void svc_get(struct svc_serv *serv)
  * We using ->sendfile to return read data, we might need one extra page
  * if the request is not page-aligned.  So add another '1'.
  */
-#define RPCSVC_MAXPAGES		((RPCSVC_MAXPAYLOAD+PAGE_SIZE-1)/PAGE_SIZE \
-				+ 2 + 1)
+#define RPCSVC_MAXPAGES	((RPCSVC_MAXPAYLOAD + PAGE_SIZE) / PAGE_SIZE + 2 + 1)
 
 static inline u32 svc_getnl(struct kvec *iov)
 {
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 7bfe1fb..9bd484d 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -659,11 +659,13 @@ static int svc_alloc_arg(struct svc_rqst *rqstp)
 	int i;
 
 	/* now allocate needed pages.  If we get a failure, sleep briefly */
-	pages = (serv->sv_max_mesg + PAGE_SIZE) / PAGE_SIZE;
-	WARN_ON_ONCE(pages >= RPCSVC_MAXPAGES);
-	if (pages >= RPCSVC_MAXPAGES)
+	pages = (serv->sv_max_mesg + (2 * PAGE_SIZE)) >> PAGE_SHIFT;
+	if (pages >= RPCSVC_MAXPAGES) {
+		pr_warn_once("svc: warning: pages=%u >= RPCSVC_MAXPAGES=%lu\n",
+			     pages, RPCSVC_MAXPAGES);
 		/* use as many pages as possible */
 		pages = RPCSVC_MAXPAGES - 1;
+	}
 	for (i = 0; i < pages ; i++)
 		while (rqstp->rq_pages[i] == NULL) {
 			struct page *p = alloc_page(GFP_KERNEL);


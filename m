Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:34443 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753699AbdGLQKm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Jul 2017 12:10:42 -0400
Received: by mail-io0-f195.google.com with SMTP id f66so2386935iof.1
        for <linux-nfs@vger.kernel.org>; Wed, 12 Jul 2017 09:10:42 -0700 (PDT)
Subject: [PATCH] sunrpc: Remove NULL element at the end of rq_pages
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Wed, 12 Jul 2017 12:10:40 -0400
Message-ID: <20170712160657.24663.66681.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bruce points out that the NULL final element of rq_pages is unneeded
by nfs_read_actor. Remove it.

Thus the 260th element of rq_pages is also no longer needed.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
Hi Bruce-

I've been testing this one. No issues for NFSv4.0 on RDMA with
krb5i, but NFSv4.0 on TCP with krb5i encounters a problem. The
server log shows this message:

rpc-srv/tcp: nfsd: sent only 108 when sending 140 bytes - shutting down socket

And iozone stalls on the client. I haven't looked more closely.


 include/linux/sunrpc/svc.h |    2 +-
 net/sunrpc/svc_xprt.c      |    1 -
 2 files changed, 1 insertion(+), 2 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index d741399..5500544 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -246,7 +246,7 @@ struct svc_rqst {
 	size_t			rq_xprt_hlen;	/* xprt header len */
 	struct xdr_buf		rq_arg;
 	struct xdr_buf		rq_res;
-	struct page		*rq_pages[RPCSVC_MAXPAGES + 1];
+	struct page		*rq_pages[RPCSVC_MAXPAGES];
 	struct page *		*rq_respages;	/* points into rq_pages */
 	struct page *		*rq_next_page; /* next reply page to use */
 	struct page *		*rq_page_end;  /* one past the last page */
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index d16a8b4..b7efd16 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -680,7 +680,6 @@ static int svc_alloc_arg(struct svc_rqst *rqstp)
 			rqstp->rq_pages[i] = p;
 		}
 	rqstp->rq_page_end = &rqstp->rq_pages[i];
-	rqstp->rq_pages[i++] = NULL; /* this might be seen in nfs_read_actor */
 
 	/* Make arg->head point to first page and arg->pages point to rest */
 	arg = &rqstp->rq_arg;


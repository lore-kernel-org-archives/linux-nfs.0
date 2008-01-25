From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 082/100] svc: Add transport hdr size for defer/revisit
Date: Fri, 25 Jan 2008 18:17:02 -0500
Message-ID: <1201303040-7779-82-git-send-email-bfields@citi.umich.edu>
References: <20080125231521.GG25141@fieldses.org>
 <1201303040-7779-1-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-2-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-3-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-4-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-5-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-6-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-7-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-8-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-9-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-10-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-11-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-12-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-13-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-14-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-15-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-16-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-17-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-18-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-19-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-20-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-21-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-22-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-23-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-24-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-25-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-26-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-27-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-28-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-29-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-30-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-31-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-32-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-33-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-34-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-35-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-36-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-37-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-38-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-39-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-40-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-41-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-42-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-43-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-44-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-45-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-46-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-47-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-48-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-49-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-50-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-51-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-52-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-53-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-54-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-55-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-56-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-57-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-58-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-59-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-60-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-61-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-62-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-63-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-64-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-65-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-66-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-67-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-68-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-69-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-70-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-71-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-72-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-73-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-74-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-75-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-76-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-77-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-78-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-79-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-80-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-81-git-send-email-bfields@citi.umich.edu>
Cc: Tom Tucker <tom@opengridcomputing.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47532 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762140AbYAYXSW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:18:22 -0500
In-Reply-To: <1201303040-7779-81-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tom Tucker <tom@opengridcomputing.com>

Some transports have a header in front of the RPC header. The current
defer/revisit processing considers only the iov_len and arg_len to
determine how much to back up when saving the original request
to revisit. Add a field to the rqstp structure to save the size
of the transport header so svc_defer can correctly compute
the start of a request.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
Acked-by: Neil Brown <neilb@suse.de>
Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Greg Banks <gnb@sgi.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 include/linux/sunrpc/svc.h |    2 ++
 net/sunrpc/svc_xprt.c      |   36 +++++++++++++++++++++++++++---------
 net/sunrpc/svcsock.c       |    2 ++
 3 files changed, 31 insertions(+), 9 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 04eb20e..742ab46 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -217,6 +217,7 @@ struct svc_rqst {
 	void *			rq_xprt_ctxt;	/* transport specific context ptr */
 	struct svc_deferred_req*rq_deferred;	/* deferred request we are replaying */
 
+	size_t			rq_xprt_hlen;	/* xprt header len */
 	struct xdr_buf		rq_arg;
 	struct xdr_buf		rq_res;
 	struct page *		rq_pages[RPCSVC_MAXPAGES];
@@ -322,6 +323,7 @@ struct svc_deferred_req {
 	size_t			addrlen;
 	union svc_addr_u	daddr;	/* where reply must come from */
 	struct cache_deferred_req handle;
+	size_t			xprt_hlen;
 	int			argslen;
 	__be32			args[0];
 };
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 23165ae..000c7dc 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -29,7 +29,6 @@
 #include <linux/sunrpc/types.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/xdr.h>
-#include <linux/sunrpc/svcsock.h>
 #include <linux/sunrpc/stats.h>
 #include <linux/sunrpc/svc_xprt.h>
 
@@ -859,10 +858,18 @@ static void svc_revisit(struct cache_deferred_req *dreq, int too_many)
 	svc_xprt_put(xprt);
 }
 
+/*
+ * Save the request off for later processing. The request buffer looks
+ * like this:
+ *
+ * <xprt-header><rpc-header><rpc-pagelist><rpc-tail>
+ *
+ * This code can only handle requests that consist of an xprt-header
+ * and rpc-header.
+ */
 static struct cache_deferred_req *svc_defer(struct cache_req *req)
 {
 	struct svc_rqst *rqstp = container_of(req, struct svc_rqst, rq_chandle);
-	int size = sizeof(struct svc_deferred_req) + (rqstp->rq_arg.len);
 	struct svc_deferred_req *dr;
 
 	if (rqstp->rq_arg.page_len)
@@ -871,8 +878,10 @@ static struct cache_deferred_req *svc_defer(struct cache_req *req)
 		dr = rqstp->rq_deferred;
 		rqstp->rq_deferred = NULL;
 	} else {
-		int skip  = rqstp->rq_arg.len - rqstp->rq_arg.head[0].iov_len;
+		size_t skip;
+		size_t size;
 		/* FIXME maybe discard if size too large */
+		size = sizeof(struct svc_deferred_req) + rqstp->rq_arg.len;
 		dr = kmalloc(size, GFP_KERNEL);
 		if (dr == NULL)
 			return NULL;
@@ -883,8 +892,12 @@ static struct cache_deferred_req *svc_defer(struct cache_req *req)
 		dr->addrlen = rqstp->rq_addrlen;
 		dr->daddr = rqstp->rq_daddr;
 		dr->argslen = rqstp->rq_arg.len >> 2;
-		memcpy(dr->args, rqstp->rq_arg.head[0].iov_base-skip,
-		       dr->argslen<<2);
+		dr->xprt_hlen = rqstp->rq_xprt_hlen;
+
+		/* back up head to the start of the buffer and copy */
+		skip = rqstp->rq_arg.len - rqstp->rq_arg.head[0].iov_len;
+		memcpy(dr->args, rqstp->rq_arg.head[0].iov_base - skip,
+		       dr->argslen << 2);
 	}
 	svc_xprt_get(rqstp->rq_xprt);
 	dr->xprt = rqstp->rq_xprt;
@@ -900,16 +913,21 @@ static int svc_deferred_recv(struct svc_rqst *rqstp)
 {
 	struct svc_deferred_req *dr = rqstp->rq_deferred;
 
-	rqstp->rq_arg.head[0].iov_base = dr->args;
-	rqstp->rq_arg.head[0].iov_len = dr->argslen<<2;
+	/* setup iov_base past transport header */
+	rqstp->rq_arg.head[0].iov_base = dr->args + (dr->xprt_hlen>>2);
+	/* The iov_len does not include the transport header bytes */
+	rqstp->rq_arg.head[0].iov_len = (dr->argslen<<2) - dr->xprt_hlen;
 	rqstp->rq_arg.page_len = 0;
-	rqstp->rq_arg.len = dr->argslen<<2;
+	/* The rq_arg.len includes the transport header bytes */
+	rqstp->rq_arg.len     = dr->argslen<<2;
 	rqstp->rq_prot        = dr->prot;
 	memcpy(&rqstp->rq_addr, &dr->addr, dr->addrlen);
 	rqstp->rq_addrlen     = dr->addrlen;
+	/* Save off transport header len in case we get deferred again */
+	rqstp->rq_xprt_hlen   = dr->xprt_hlen;
 	rqstp->rq_daddr       = dr->daddr;
 	rqstp->rq_respages    = rqstp->rq_pages;
-	return dr->argslen<<2;
+	return (dr->argslen<<2) - dr->xprt_hlen;
 }
 
 
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 343a85b..1d3e5fc 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -315,6 +315,8 @@ static int svc_recvfrom(struct svc_rqst *rqstp, struct kvec *iov, int nr,
 	};
 	int len;
 
+	rqstp->rq_xprt_hlen = 0;
+
 	len = kernel_recvmsg(svsk->sk_sock, &msg, iov, nr, buflen,
 				msg.msg_flags);
 
-- 
1.5.4.rc2.60.gb2e62


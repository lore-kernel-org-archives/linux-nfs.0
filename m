From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,
	PATCH 1/4] svc: Fix skip computation in svc_defer and svc_revisit
Date: Fri, 19 Oct 2007 16:45:23 -0500
Message-ID: <20071019214523.31422.28978.stgit@dell3.ogc.int>
References: <20071019214058.31422.35615.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: bfields@fieldses.org, neilb@suse.de, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Iizen-0005vE-5M
	for nfs@lists.sourceforge.net; Fri, 19 Oct 2007 14:45:25 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Iizer-0008G5-Bq
	for nfs@lists.sourceforge.net; Fri, 19 Oct 2007 14:45:30 -0700
In-Reply-To: <20071019214058.31422.35615.stgit@dell3.ogc.int>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


The rq_arg.len includes the size of the transport header. The computations
assumed that it did not.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 net/sunrpc/svc_xprt.c |   16 +++++++---------
 1 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index b56bf05..13aacec 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -29,7 +29,6 @@ #include <asm/ioctls.h>
 #include <linux/sunrpc/types.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/xdr.h>
-#include <linux/sunrpc/svcsock.h>
 #include <linux/sunrpc/stats.h>
 #include <linux/sunrpc/svc_xprt.h>
 
@@ -162,7 +161,7 @@ EXPORT_SYMBOL_GPL(svc_xprt_init);
 
 static int svc_local_port(struct svc_xprt *xprt)
 {
-	int ret = 0;
+	int ret = -1;
 	switch (xprt->xpt_local.ss_family) {
 	case AF_INET:
 		ret = ntohs(((struct sockaddr_in *)
@@ -891,8 +890,7 @@ static struct cache_deferred_req *svc_de
 		int skip;
 		int size;
 		/* FIXME maybe discard if size too large */
-		size = sizeof(struct svc_deferred_req) + rqstp->rq_arg.len +
-			rqstp->rq_xprt_hlen;
+		size = sizeof(struct svc_deferred_req) + rqstp->rq_arg.len;
 		dr = kmalloc(size, GFP_KERNEL);
 		if (dr == NULL)
 			return NULL;
@@ -902,12 +900,12 @@ static struct cache_deferred_req *svc_de
 		memcpy(&dr->addr, &rqstp->rq_addr, rqstp->rq_addrlen);
 		dr->addrlen = rqstp->rq_addrlen;
 		dr->daddr = rqstp->rq_daddr;
-		dr->argslen = (rqstp->rq_arg.len + rqstp->rq_xprt_hlen) >> 2;
+		dr->argslen = rqstp->rq_arg.len>>2;
 		dr->xprt_hlen = rqstp->rq_xprt_hlen;
 
 		/* back up head to the start of the buffer and copy */
-		skip = (rqstp->rq_arg.len + rqstp->rq_xprt_hlen) -
-			rqstp->rq_arg.head[0].iov_len;
+		skip = rqstp->rq_arg.len - rqstp->rq_arg.head[0].iov_len;
+
 		memcpy(dr->args, rqstp->rq_arg.head[0].iov_base - skip,
 		       dr->argslen << 2);
 	}
@@ -930,8 +928,8 @@ static int svc_deferred_recv(struct svc_
 	/* The iov_len doesn't include the transport header bytes */
 	rqstp->rq_arg.head[0].iov_len = (dr->argslen<<2) - dr->xprt_hlen;
 	rqstp->rq_arg.page_len = 0;
-	/* The rq_arg len does not include the transport header bytes */
-	rqstp->rq_arg.len = (dr->argslen<<2) - dr->xprt_hlen;
+	/* The rq_arg len includes the transport header bytes */
+	rqstp->rq_arg.len     = dr->argslen<<2;
 	rqstp->rq_prot        = dr->prot;
 	memcpy(&rqstp->rq_addr, &dr->addr, dr->addrlen);
 	rqstp->rq_addrlen     = dr->addrlen;

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

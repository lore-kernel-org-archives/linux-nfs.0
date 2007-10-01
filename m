From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,
	PATCH 33/35] svc: Add transport hdr size for defer/revisit
Date: Mon, 01 Oct 2007 14:28:43 -0500
Message-ID: <20071001192843.3250.56799.stgit@dell3.ogc.int>
References: <20071001191426.3250.15371.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IcQwf-0005f8-0O
	for nfs@lists.sourceforge.net; Mon, 01 Oct 2007 12:28:45 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IcQwj-0001Dh-2c
	for nfs@lists.sourceforge.net; Mon, 01 Oct 2007 12:28:50 -0700
In-Reply-To: <20071001191426.3250.15371.stgit@dell3.ogc.int>
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


Some transports have a header in front of the RPC header. The current
defer/revisit processing considers only the iov_len and arg_len to 
determine how much to back up when saving the original request
to revisit. Add a field to the rqstp structure to save the size
of the transport header so svc_defer can correctly compute
the start of a request. 

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svc.h |    1 +
 net/sunrpc/svc_xprt.c      |   24 ++++++++++++++++++++----
 net/sunrpc/svcsock.c       |    3 +++
 3 files changed, 24 insertions(+), 4 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 04eb20e..ea07e3d 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -217,6 +217,7 @@ struct svc_rqst {
 	void *			rq_xprt_ctxt;	/* transport specific context ptr */
 	struct svc_deferred_req*rq_deferred;	/* deferred request we are replaying */
 
+	size_t			rq_xprt_hlen;	/* xprt header len */
 	struct xdr_buf		rq_arg;
 	struct xdr_buf		rq_res;
 	struct page *		rq_pages[RPCSVC_MAXPAGES];
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index f408626..6b99786 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -836,11 +836,19 @@ static void svc_revisit(struct cache_def
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
 static struct cache_deferred_req *
 svc_defer(struct cache_req *req)
 {
 	struct svc_rqst *rqstp = container_of(req, struct svc_rqst, rq_chandle);
-	int size = sizeof(struct svc_deferred_req) + (rqstp->rq_arg.len);
 	struct svc_deferred_req *dr;
 
 	if (rqstp->rq_arg.page_len)
@@ -849,8 +857,11 @@ svc_defer(struct cache_req *req)
 		dr = rqstp->rq_deferred;
 		rqstp->rq_deferred = NULL;
 	} else {
-		int skip  = rqstp->rq_arg.len - rqstp->rq_arg.head[0].iov_len;
+		int skip;
+		int size;
 		/* FIXME maybe discard if size too large */
+		size = sizeof(struct svc_deferred_req) + rqstp->rq_arg.len +
+			rqstp->rq_xprt_hlen;
 		dr = kmalloc(size, GFP_KERNEL);
 		if (dr == NULL)
 			return NULL;
@@ -860,8 +871,13 @@ svc_defer(struct cache_req *req)
 		memcpy(&dr->addr, &rqstp->rq_addr, rqstp->rq_addrlen);
 		dr->addrlen = rqstp->rq_addrlen;
 		dr->daddr = rqstp->rq_daddr;
-		dr->argslen = rqstp->rq_arg.len >> 2;
-		memcpy(dr->args, rqstp->rq_arg.head[0].iov_base-skip, dr->argslen<<2);
+		dr->argslen = (rqstp->rq_arg.len + rqstp->rq_xprt_hlen) >> 2;
+
+		/* back up head to the start of the buffer and copy */
+		skip = (rqstp->rq_arg.len + rqstp->rq_xprt_hlen) -
+			rqstp->rq_arg.head[0].iov_len;
+		memcpy(dr->args, rqstp->rq_arg.head[0].iov_base - skip,
+		       dr->argslen << 2);
 	}
 	svc_xprt_get(rqstp->rq_xprt);
 	dr->xprt = rqstp->rq_xprt;
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 40badd7..e170866 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -393,6 +393,9 @@ svc_recvfrom(struct svc_rqst *rqstp, str
 	};
 	int len;
 
+	/* TCP/UDP have no transport header */
+	rqstp->rq_xprt_hlen = 0;
+
 	len = kernel_recvmsg(svsk->sk_sock, &msg, iov, nr, buflen,
 				msg.msg_flags);
 

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH] svc: Add xprt header len to svc_deferred_req
Date: Tue, 09 Oct 2007 17:57:40 -0500
Message-ID: <20071009225740.26067.25488.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IfO1I-0002SV-7f
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 15:57:44 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IfO1M-0002JP-9a
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 15:57:48 -0700
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


A transport may have a header that precedes the RPC message. Save the
size of this header in the svc_deferred_req so that when the RPC
is revisited, the deferred recv function doesn't need to re-parse the 
header to determine it's length.

In addition, a misleading comment related to the transport header 
for TCP/UDP has been rewritten.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svc.h |    1 +
 net/sunrpc/svc_xprt.c      |    1 +
 net/sunrpc/svcsock.c       |    2 +-
 3 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index ea07e3d..f2ada2a 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -323,6 +323,7 @@ struct svc_deferred_req {
 	size_t			addrlen;
 	union svc_addr_u	daddr;	/* where reply must come from */
 	struct cache_deferred_req handle;
+	int			xprt_hlen;
 	int			argslen;
 	__be32			args[0];
 };
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 080ecf5..b580d4c 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -884,6 +884,7 @@ static struct cache_deferred_req *svc_de
 		dr->addrlen = rqstp->rq_addrlen;
 		dr->daddr = rqstp->rq_daddr;
 		dr->argslen = (rqstp->rq_arg.len + rqstp->rq_xprt_hlen) >> 2;
+		dr->xprt_hlen = rqstp->rq_xprt_hlen;
 
 		/* back up head to the start of the buffer and copy */
 		skip = (rqstp->rq_arg.len + rqstp->rq_xprt_hlen) -
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index ec834a7..7838b27 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -393,7 +393,7 @@ svc_recvfrom(struct svc_rqst *rqstp, str
 	};
 	int len;
 
-	/* TCP/UDP have no transport header */
+	/* UDP doesn't have a xprt header and TCP doesn't need to save it */
 	rqstp->rq_xprt_hlen = 0;
 
 	len = kernel_recvmsg(svsk->sk_sock, &msg, iov, nr, buflen,

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH] svc: Restore rq_xprt_hlen in svc_deferred_recv
Date: Fri, 12 Oct 2007 14:21:10 -0500
Message-ID: <20071012192110.25641.29211.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: bfields@fieldses.org, neilb@suse.de, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IgQ4N-0000wZ-96
	for nfs@lists.sourceforge.net; Fri, 12 Oct 2007 12:21:11 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IgQ4S-000299-DI
	for nfs@lists.sourceforge.net; Fri, 12 Oct 2007 12:21:16 -0700
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


Fixed a couple bugs in the deferral processing. This won't see significant
testing until I complete the rdma driver mods because tcp/udp always
set the xprt_hlen to zero.  The changes are as follows:

- Restore the length of the transport header in the rqstp structure
in case the request gets deferred again. 

- Update the iov_head and arg.len with xprt_hlen.

- Add comments that describe how xprt_hlen is used.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 net/sunrpc/svc_xprt.c |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index c823e66..b56bf05 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -925,16 +925,21 @@ static int svc_deferred_recv(struct svc_
 {
 	struct svc_deferred_req *dr = rqstp->rq_deferred;
 
-	rqstp->rq_arg.head[0].iov_base = dr->args;
-	rqstp->rq_arg.head[0].iov_len = dr->argslen<<2;
+	/* setup iov_base to point past the transport header */
+	rqstp->rq_arg.head[0].iov_base = dr->args + (dr->xprt_hlen>>2);
+	/* The iov_len doesn't include the transport header bytes */
+	rqstp->rq_arg.head[0].iov_len = (dr->argslen<<2) - dr->xprt_hlen;
 	rqstp->rq_arg.page_len = 0;
-	rqstp->rq_arg.len = dr->argslen<<2;
+	/* The rq_arg len does not include the transport header bytes */
+	rqstp->rq_arg.len = (dr->argslen<<2) - dr->xprt_hlen;
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
 
 

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

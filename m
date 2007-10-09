From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 2/7] svc: Rename xpo_release to xpo_release_rqst
Date: Tue, 09 Oct 2007 10:37:11 -0500
Message-ID: <20071009153711.18846.14825.stgit@dell3.ogc.int>
References: <20071009153539.18846.33780.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IfH8y-0005e0-RJ
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 08:37:13 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IfH93-00087Z-LZ
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 08:37:18 -0700
In-Reply-To: <20071009153539.18846.33780.stgit@dell3.ogc.int>
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


The xpo_release function removes resources that the transport has 
associated with a particular request. To avoid confusion with the 
xpo_detach and xpo_free functions, rename this function xpo_release_rqst.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svc_xprt.h |    2 +-
 net/sunrpc/svc_xprt.c           |    4 ++--
 net/sunrpc/svcsock.c            |    4 ++--
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 89bd5ff..a1a7d15 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -19,7 +19,7 @@ struct svc_xprt_ops {
 	int		(*xpo_recvfrom)(struct svc_rqst *);
 	void		(*xpo_prep_reply_hdr)(struct svc_rqst *);
 	int		(*xpo_sendto)(struct svc_rqst *);
-	void		(*xpo_release)(struct svc_rqst *);
+	void		(*xpo_release_rqst)(struct svc_rqst *);
 	void		(*xpo_detach)(struct svc_xprt *);
 	void		(*xpo_free)(struct svc_xprt *);
 };
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 16ffc73..807795f 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -381,7 +381,7 @@ svc_xprt_release(struct svc_rqst *rqstp)
 {
 	struct svc_xprt	*xprt = rqstp->rq_xprt;
 
-	rqstp->rq_xprt->xpt_ops->xpo_release(rqstp);
+	rqstp->rq_xprt->xpt_ops->xpo_release_rqst(rqstp);
 
 	svc_free_res_pages(rqstp);
 	rqstp->rq_res.page_len = 0;
@@ -683,7 +683,7 @@ svc_send(struct svc_rqst *rqstp)
 	}
 
 	/* release the receive skb before sending the reply */
-	rqstp->rq_xprt->xpt_ops->xpo_release(rqstp);
+	rqstp->rq_xprt->xpt_ops->xpo_release_rqst(rqstp);
 
 	/* calculate over-all length */
 	xb = & rqstp->rq_res;
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index e170866..f967c23 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -665,7 +665,7 @@ static struct svc_xprt_ops svc_udp_ops =
 	.xpo_create = svc_udp_create,
 	.xpo_recvfrom = svc_udp_recvfrom,
 	.xpo_sendto = svc_udp_sendto,
-	.xpo_release = svc_release_skb,
+	.xpo_release_rqst = svc_release_skb,
 	.xpo_detach = svc_sock_detach,
 	.xpo_free = svc_sock_free,
 	.xpo_prep_reply_hdr = svc_udp_prep_reply_hdr,
@@ -1091,7 +1091,7 @@ static struct svc_xprt_ops svc_tcp_ops =
 	.xpo_create = svc_tcp_create,
 	.xpo_recvfrom = svc_tcp_recvfrom,
 	.xpo_sendto = svc_tcp_sendto,
-	.xpo_release = svc_release_skb,
+	.xpo_release_rqst = svc_release_skb,
 	.xpo_detach = svc_sock_detach,
 	.xpo_free = svc_sock_free,
 	.xpo_prep_reply_hdr = svc_tcp_prep_reply_hdr,

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

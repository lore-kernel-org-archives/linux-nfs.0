From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC, PATCH 5/7] svc: Remove extraneous debug svc_send printk
Date: Tue, 09 Oct 2007 10:37:18 -0500
Message-ID: <20071009153718.18846.55296.stgit@dell3.ogc.int>
References: <20071009153539.18846.33780.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IfH9B-0005fY-Hr
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 08:37:25 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IfH99-00089l-JO
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 08:37:25 -0700
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


The svc_send function has a debug check and kern info printk 
for a null xprt pointers in the rqstp structure. Remove the 
printk.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 net/sunrpc/svc_xprt.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 76036af..323977a 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -678,11 +678,8 @@ svc_send(struct svc_rqst *rqstp)
 	int		len;
 	struct xdr_buf	*xb;
 
-	if ((xprt = rqstp->rq_xprt) == NULL) {
-		printk(KERN_WARNING "NULL transport pointer in %s:%d\n",
-				__FILE__, __LINE__);
+	if ((xprt = rqstp->rq_xprt) == NULL)
 		return -EFAULT;
-	}
 
 	/* release the receive skb before sending the reply */
 	rqstp->rq_xprt->xpt_ops->xpo_release_rqst(rqstp);

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

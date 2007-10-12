From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH] svc: bzero the xprt memory in svc_xprt_init
Date: Fri, 12 Oct 2007 14:00:48 -0500
Message-ID: <20071012190048.24784.44983.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: bfields@fieldses.org, neilb@suse.de, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IgPkf-0007FS-PJ
	for nfs@lists.sourceforge.net; Fri, 12 Oct 2007 12:00:52 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IgPkj-0003gH-TM
	for nfs@lists.sourceforge.net; Fri, 12 Oct 2007 12:00:55 -0700
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


The transport class driver is responsible for allocating the 
memory that contains svc_xprt. We don't know whether the driver
used kzalloc or kmalloc. Initialize the svc_xprt structure to
zeroes just in case.

Also changed the name of the svc_xprt ptr variable to xprt to
be consistent with the naming used everywhere else for the
transport ptr.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 net/sunrpc/svc_xprt.c |   21 +++++++++++----------
 1 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 56fcc7c..c823e66 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -144,18 +144,19 @@ EXPORT_SYMBOL_GPL(svc_xprt_put);
  * Called by transport drivers to initialize the transport independent
  * portion of the transport instance.
  */
-void svc_xprt_init(struct svc_xprt_class *xcl, struct svc_xprt *xpt,
+void svc_xprt_init(struct svc_xprt_class *xcl, struct svc_xprt *xprt,
 		   struct svc_serv *serv)
 {
-	xpt->xpt_class = xcl;
-	xpt->xpt_ops = xcl->xcl_ops;
-	kref_init(&xpt->xpt_ref);
-	xpt->xpt_server = serv;
-	INIT_LIST_HEAD(&xpt->xpt_list);
-	INIT_LIST_HEAD(&xpt->xpt_ready);
-	INIT_LIST_HEAD(&xpt->xpt_deferred);
-	mutex_init(&xpt->xpt_mutex);
-	spin_lock_init(&xpt->xpt_lock);
+	memset(xprt, 0, sizeof(*xprt));
+	xprt->xpt_class = xcl;
+	xprt->xpt_ops = xcl->xcl_ops;
+	kref_init(&xprt->xpt_ref);
+	xprt->xpt_server = serv;
+	INIT_LIST_HEAD(&xprt->xpt_list);
+	INIT_LIST_HEAD(&xprt->xpt_ready);
+	INIT_LIST_HEAD(&xprt->xpt_deferred);
+	mutex_init(&xprt->xpt_mutex);
+	spin_lock_init(&xprt->xpt_lock);
 }
 EXPORT_SYMBOL_GPL(svc_xprt_init);
 

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

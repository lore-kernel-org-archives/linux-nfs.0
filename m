From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,
	PATCH] svc: Don't call xpo_free until after releasing auth data
Date: Fri, 12 Oct 2007 13:58:32 -0500
Message-ID: <20071012185832.24685.35490.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: bfields@fieldses.org, neilb@suse.de, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IgPiU-000730-NH
	for nfs@lists.sourceforge.net; Fri, 12 Oct 2007 11:58:34 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IgPiY-0000d5-Q4
	for nfs@lists.sourceforge.net; Fri, 12 Oct 2007 11:58:40 -0700
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


The svc_xprt_free function is calling xpo_free and then using the xprt
pointer while attempting to free the cached auth data. Reverse the order
of these operations.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 net/sunrpc/svc_xprt.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index cbf80b0..56fcc7c 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -127,10 +127,10 @@ static void svc_xprt_free(struct kref *k
 		container_of(kref, struct svc_xprt, xpt_ref);
 	struct module *owner = xprt->xpt_class->xcl_owner;
 	BUG_ON(atomic_read(&kref->refcount));
-	xprt->xpt_ops->xpo_free(xprt);
 	if (test_bit(XPT_CACHE_AUTH, &xprt->xpt_flags)
 	    && xprt->xpt_auth_cache != NULL)
 		svcauth_unix_info_release(xprt->xpt_auth_cache);
+	xprt->xpt_ops->xpo_free(xprt);
 	module_put(owner);
 }
 

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

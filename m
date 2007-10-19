From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,
	PATCH 4/4] svc: Move svc_xprt_received call to follow addition of
	xprt to list
Date: Fri, 19 Oct 2007 16:45:30 -0500
Message-ID: <20071019214530.31422.4899.stgit@dell3.ogc.int>
References: <20071019214058.31422.35615.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: bfields@fieldses.org, neilb@suse.de, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Iizev-0005va-BQ
	for nfs@lists.sourceforge.net; Fri, 19 Oct 2007 14:45:33 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Iizez-0008I2-Kh
	for nfs@lists.sourceforge.net; Fri, 19 Oct 2007 14:45:38 -0700
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


The call to svc_xprt_received function should be called after the transport 
is completely initialized and added to the tempsocks list.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 net/sunrpc/svc_xprt.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 6b2c73c..bb007e7 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -615,7 +615,6 @@ int svc_recv(struct svc_rqst *rqstp, lon
 		struct svc_xprt *newxpt;
 		newxpt = xprt->xpt_ops->xpo_accept(xprt);
 		if (newxpt) {
-			svc_xprt_received(newxpt);
 			/*
 			 * We know this module_get will succeed because the
 			 * listener holds a reference too
@@ -634,6 +633,7 @@ int svc_recv(struct svc_rqst *rqstp, lon
 					  jiffies + svc_conn_age_period * HZ);
 			}
 			spin_unlock_bh(&serv->sv_lock);
+			svc_xprt_received(newxpt);
 		}
 		svc_xprt_received(xprt);
 	} else {

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

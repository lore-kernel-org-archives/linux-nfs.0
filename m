From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,
	PATCH 2/4] svc: svc_addsock needs to set the svc_xprt address
Date: Fri, 19 Oct 2007 16:45:26 -0500
Message-ID: <20071019214525.31422.35242.stgit@dell3.ogc.int>
References: <20071019214058.31422.35615.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: bfields@fieldses.org, neilb@suse.de, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Iizep-0005vQ-RL
	for nfs@lists.sourceforge.net; Fri, 19 Oct 2007 14:45:27 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Iizeu-0007lI-1Z
	for nfs@lists.sourceforge.net; Fri, 19 Oct 2007 14:45:33 -0700
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


The svc_addsock function needs to set the local address in the 
svc_xprt structure.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 net/sunrpc/svcsock.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index cc752b7..e1a27ee 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1249,6 +1249,11 @@ int svc_addsock(struct svc_serv *serv,
 	else {
 		svsk = svc_setup_socket(serv, so, &err, SVC_SOCK_DEFAULTS);
 		if (svsk) {
+			int salen;
+			(void)kernel_getsockname(svsk->sk_sock,
+						 (struct sockaddr *)
+						 &svsk->sk_xprt.xpt_local,
+						 &salen);
 			svc_xprt_received(&svsk->sk_xprt);
 			err = 0;
 		}

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

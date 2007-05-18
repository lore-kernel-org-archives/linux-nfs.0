From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,
	PATCH 8/15] knfds: map null socket to SOCK_STREAM in	svcauth_unix
Date: Fri, 18 May 2007 12:45:37 -0500
Message-ID: <1179510337.23385.121.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Tom Talpey <Thomas.Talpey@netapp.com>,
	Peter Leckie <pleckie@melbourne.sgi.com>, Greg Banks <gnb@sgi.com>
To: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hp6WL-0000uP-Nh
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 10:45:41 -0700
Received: from rrcs-71-42-183-126.sw.biz.rr.com ([71.42.183.126]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hp6WN-0008EQ-HQ
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 10:45:44 -0700
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


The ip_map_cached_put routine looks in the sk_sock structure to determine
the connection type. This change maps a null socket (RMDA transport) to 
SOCK_STREAM.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 net/sunrpc/svcauth_unix.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index 2bd23ea..4d6bba0 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -411,7 +411,7 @@ ip_map_cached_put(struct svc_rqst *rqstp
 	struct svc_sock *svsk = rqstp->rq_sock;
 
 	spin_lock_bh(&svsk->sk_defer_lock);
-	if (svsk->sk_sock->type == SOCK_STREAM &&
+	if ((svsk->sk_sock==NULL || svsk->sk_sock->type == SOCK_STREAM) &&
 	    svsk->sk_info_authunix == NULL) {
 		/* newly cached, keep the reference */
 		svsk->sk_info_authunix = ipm;


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Greg Banks <gnb@sgi.com>
Subject: [RFC,PATCH 6/14] knfsd: add svc_sock_is_connection
Date: Thu, 17 May 2007 05:23:40 +1000
Message-ID: <20070516192340.GL9626@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Thomas Talpey <Thomas.Talpey@netapp.com>,
	Peter Leckie <pleckie@melbourne.sgi.com>
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HoP66-0000TL-Im
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 12:23:42 -0700
Received: from netops-testserver-4-out.sgi.com ([192.48.171.29]
	helo=relay.sgi.com) by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1HoP69-0003a2-6Q
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 12:23:45 -0700
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


Add a svc_sock_is_connection() predicate to test whether a struct
svc_sock is a connected socket (currently this means TCP).  Also, fix
ip_map_cached_put() to detect whether the svc_sock is a connection
using the new predicate, instead of reaching into the svc_sock's
socket, because later the NFS/RDMA transport will not have a socket.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
Signed-off-by: Peter Leckie <pleckie@melbourne.sgi.com>
---

 include/linux/sunrpc/svcsock.h |    5 +++++
 net/sunrpc/svcauth_unix.c      |    2 +-
 2 files changed, 6 insertions(+), 1 deletion(-)

Index: linux/include/linux/sunrpc/svcsock.h
===================================================================
--- linux.orig/include/linux/sunrpc/svcsock.h	2007-05-17 01:28:41.131377156 +1000
+++ linux/include/linux/sunrpc/svcsock.h	2007-05-17 01:58:40.829117616 +1000
@@ -95,6 +95,11 @@ struct svc_sock {
 	int			sk_remotelen;	/* length of address */
 };
 
+static inline int svc_sock_is_connection(struct svc_sock *svsk)
+{
+	return (test_bit(SK_TEMP, &svsk->sk_flags));
+}
+
 /*
  * Function prototypes.
  */
Index: linux/net/sunrpc/svcauth_unix.c
===================================================================
--- linux.orig/net/sunrpc/svcauth_unix.c	2007-04-26 13:08:32.000000000 +1000
+++ linux/net/sunrpc/svcauth_unix.c	2007-05-17 01:58:40.865112934 +1000
@@ -411,7 +411,7 @@ ip_map_cached_put(struct svc_rqst *rqstp
 	struct svc_sock *svsk = rqstp->rq_sock;
 
 	spin_lock_bh(&svsk->sk_defer_lock);
-	if (svsk->sk_sock->type == SOCK_STREAM &&
+	if (svc_sock_is_connection(svsk) &&
 	    svsk->sk_info_authunix == NULL) {
 		/* newly cached, keep the reference */
 		svsk->sk_info_authunix = ipm;
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
Apparently, I'm Bedevere.  Which MPHG character are you?
I don't speak for SGI.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

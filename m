From: Greg Banks <gnb@sgi.com>
Subject: [RFC, PATCH 7/14] knfsd: export svc_sock_enqueue,
	svc_sock_received
Date: Thu, 17 May 2007 05:24:25 +1000
Message-ID: <20070516192425.GM9626@sgi.com>
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
	id 1HoP6p-0000be-9C
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 12:24:27 -0700
Received: from netops-testserver-4-out.sgi.com ([192.48.171.29]
	helo=relay.sgi.com) by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1HoP6r-0003qQ-SB
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 12:24:30 -0700
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


Export svc_sock_enqueue() and svc_sock_received() so they
can be used by sunrpc server transport implementations
(even future modular ones).

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
Signed-off-by: Peter Leckie <pleckie@melbourne.sgi.com>
---

 include/linux/sunrpc/svcsock.h |    2 ++
 net/sunrpc/sunrpc_syms.c       |    2 ++
 net/sunrpc/svcsock.c           |    4 ++--
 3 files changed, 6 insertions(+), 2 deletions(-)

Index: linux/include/linux/sunrpc/svcsock.h
===================================================================
--- linux.orig/include/linux/sunrpc/svcsock.h	2007-05-17 02:04:02.007208187 +1000
+++ linux/include/linux/sunrpc/svcsock.h	2007-05-17 02:39:51.367033242 +1000
@@ -114,6 +114,8 @@ int		svc_addsock(struct svc_serv *serv,
 			    int fd,
 			    char *name_return,
 			    int *proto);
+void		svc_sock_enqueue(struct svc_sock *svsk);
+void		svc_sock_received(struct svc_sock *svsk);
 
 /*
  * svc_makesock socket characteristics
Index: linux/net/sunrpc/sunrpc_syms.c
===================================================================
--- linux.orig/net/sunrpc/sunrpc_syms.c	2007-04-26 13:08:32.000000000 +1000
+++ linux/net/sunrpc/sunrpc_syms.c	2007-05-17 02:09:47.762054713 +1000
@@ -77,6 +77,8 @@ EXPORT_SYMBOL(svc_process);
 EXPORT_SYMBOL(svc_recv);
 EXPORT_SYMBOL(svc_wake_up);
 EXPORT_SYMBOL(svc_makesock);
+EXPORT_SYMBOL_GPL(svc_sock_enqueue);
+EXPORT_SYMBOL_GPL(svc_sock_received);
 EXPORT_SYMBOL(svc_reserve);
 EXPORT_SYMBOL(svc_auth_register);
 EXPORT_SYMBOL(auth_domain_lookup);
Index: linux/net/sunrpc/svcsock.c
===================================================================
--- linux.orig/net/sunrpc/svcsock.c	2007-05-17 01:28:25.221366963 +1000
+++ linux/net/sunrpc/svcsock.c	2007-05-17 02:40:30.597956980 +1000
@@ -208,7 +208,7 @@ svc_release_skb(struct svc_rqst *rqstp)
  * processes, wake 'em up.
  *
  */
-static void
+void
 svc_sock_enqueue(struct svc_sock *svsk)
 {
 	struct svc_serv	*serv = svsk->sk_server;
@@ -316,7 +316,7 @@ svc_sock_dequeue(struct svc_pool *pool)
  * Note: SK_DATA only gets cleared when a read-attempt finds
  * no (or insufficient) data.
  */
-static inline void
+void
 svc_sock_received(struct svc_sock *svsk)
 {
 	svsk->sk_pool = NULL;
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

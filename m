From: Greg Banks <gnb@sgi.com>
Subject: [RFC,PATCH 10/14] knfsd: add SK_LISTENER
Date: Thu, 17 May 2007 05:26:27 +1000
Message-ID: <20070516192627.GP9626@sgi.com>
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
	id 1HoP8m-0000p2-H7
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 12:26:28 -0700
Received: from netops-testserver-4-out.sgi.com ([192.48.171.29]
	helo=relay.sgi.com) by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1HoP8p-0004NF-6W
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 12:26:31 -0700
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


Use a new svc_sock flag SK_LISTENER which is permanently set on
listener sockets, use that to test for listeners in a way which
is not TCP-specific and does not assume the presence of a socket.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
---

 include/linux/sunrpc/svcsock.h |    1 +
 net/sunrpc/svcsock.c           |    3 ++-
 2 files changed, 3 insertions(+), 1 deletion(-)

Index: linux/include/linux/sunrpc/svcsock.h
===================================================================
--- linux.orig/include/linux/sunrpc/svcsock.h	2007-05-17 03:04:33.479451764 +1000
+++ linux/include/linux/sunrpc/svcsock.h	2007-05-17 03:04:37.023009680 +1000
@@ -72,6 +72,7 @@ struct svc_sock {
 #define	SK_DEFERRED	8			/* request on sk_deferred */
 #define	SK_OLD		9			/* used for temp socket aging mark+sweep */
 #define	SK_DETACHED	10			/* detached from tempsocks list */
+#define	SK_LISTENER	11			/* listener (e.g. TCP) socket */
 
 	atomic_t    	    	sk_reserved;	/* space on outq that is reserved */
 
Index: linux/net/sunrpc/svcsock.c
===================================================================
--- linux.orig/net/sunrpc/svcsock.c	2007-05-17 03:04:33.479451764 +1000
+++ linux/net/sunrpc/svcsock.c	2007-05-17 03:04:37.218985230 +1000
@@ -1399,6 +1399,7 @@ svc_tcp_init(struct svc_sock *svsk)
 	if (sk->sk_state == TCP_LISTEN) {
 		dprintk("setting up TCP socket for listening\n");
 		sk->sk_data_ready = svc_tcp_listen_data_ready;
+		set_bit(SK_LISTENER, &svsk->sk_flags);
 		svc_sock_set_connection_ready(svsk);
 	} else {
 		dprintk("setting up TCP socket for reading\n");
@@ -1546,7 +1547,7 @@ svc_recv(struct svc_rqst *rqstp, long ti
 	if (test_bit(SK_CLOSE, &svsk->sk_flags)) {
 		dprintk("svc_recv: found SK_CLOSE\n");
 		svc_delete_socket(svsk);
-	} else if (svsk->sk_sk->sk_state == TCP_LISTEN) {
+	} else if (test_bit(SK_LISTENER, &svsk->sk_flags)) {
 		svsk->sk_ops->sko_accept(svsk);
 		svc_sock_received(svsk);
 	} else {
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

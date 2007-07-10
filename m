From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 09/20] svc: Add SK_LISTENER sock flag
Date: Tue, 10 Jul 2007 00:34:39 -0500
Message-ID: <20070710053439.28979.57832.stgit@dell3.ogc.int>
References: <20070710052711.28979.70843.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I88Mz-00074g-Jo
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 22:34:41 -0700
Received: from rrcs-71-42-183-126.sw.biz.rr.com ([71.42.183.126]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I88N2-0003U0-JP
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 22:34:45 -0700
Received: from dell3.ogc.int (localhost [127.0.0.1])
	by smtp.opengridcomputing.com (Postfix) with ESMTP id 38E727C75F
	for <nfs@lists.sourceforge.net>; Tue, 10 Jul 2007 00:34:39 -0500 (CDT)
In-Reply-To: <20070710052711.28979.70843.stgit@dell3.ogc.int>
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
 net/sunrpc/svcsock.c           |    4 +++-
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index c4eb40c..a52c9fd 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -70,6 +70,7 @@ #define	SK_CHNGBUF	7			/* need to change
 #define	SK_DEFERRED	8			/* request on sk_deferred */
 #define	SK_OLD		9			/* used for temp socket aging mark+sweep */
 #define	SK_DETACHED	10			/* detached from tempsocks list */
+#define	SK_LISTENER	11			/* listener (e.g. TCP) socket */
 
 	atomic_t    	    	sk_reserved;	/* space on outq that is reserved */
 
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 2ef3013..59c6b35 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1368,6 +1368,8 @@ svc_tcp_init(struct svc_sock *svsk)
 	if (sk->sk_state == TCP_LISTEN) {
 		dprintk("setting up TCP socket for listening\n");
 		sk->sk_data_ready = svc_tcp_listen_data_ready;
+
+		set_bit(SK_LISTENER, &svsk->sk_flags);
 		set_bit(SK_CONN, &svsk->sk_flags);
 	} else {
 		dprintk("setting up TCP socket for reading\n");
@@ -1515,7 +1517,7 @@ svc_recv(struct svc_rqst *rqstp, long ti
 	if (test_bit(SK_CLOSE, &svsk->sk_flags)) {
 		dprintk("svc_recv: found SK_CLOSE\n");
 		svc_delete_socket(svsk);
-	} else if (svsk->sk_sk->sk_state == TCP_LISTEN) {
+	} else if (test_bit(SK_LISTENER, &svsk->sk_flags)) {
 		svsk->sk_ops->sko_accept(svsk);
 		svc_sock_received(svsk);
 	} else {

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

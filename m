From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: PATCH - SUNRPC 3 of 3 - Call svc_sock_setbufsize when socket created.
Date: Tue, 20 Aug 2002 14:26:43 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15713.50435.514970.377770@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17h0ba-00021l-00
	for <nfs@lists.sourceforge.net>; Mon, 19 Aug 2002 21:26:59 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.85] == wireless-085.wireless.cse.unsw.EDU.AU)
	(for <marcelo@conectiva.com.br>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Tue, 20 Aug 2002 14:26:45 +1000
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>



bufsiz is re-evaluated on recv if SK_CHNGBUF is set,
but recv wil never be reached if the buffers are too small.
So we have to set to to something vaguely reasonable
at init time.

This is only important if someone has set the NFS max message 
size to 32K or larger (standard value is 8K).

Also fix message printed when not enough queue space.


 ----------- Diffstat output ------------
 
 ./net/sunrpc/svcsock.c |   19 ++++++++++++++++++-
 1 files changed, 18 insertions(+), 1 deletion(-)

--- ./net/sunrpc/svcsock.c	2002/08/20 03:02:21	1.2
+++ ./net/sunrpc/svcsock.c	2002/08/20 03:10:50	1.4
@@ -139,7 +139,7 @@ svc_sock_enqueue(struct svc_sock *svsk)
 	    && !test_bit(SK_CLOSE, &svsk->sk_flags)
 	    && !test_bit(SK_CONN, &svsk->sk_flags)) {
 		/* Don't enqueue while not enough space for reply */
-		dprintk("svc: socket %p  no space, %d > %ld, not enqueued\n",
+		dprintk("svc: socket %p  no space, %d*2 > %ld, not enqueued\n",
 			svsk->sk_sk, svsk->sk_reserved+serv->sv_bufsz,
 			sock_wspace(svsk->sk_sk));
 		goto out_unlock;
@@ -572,6 +572,15 @@ svc_udp_init(struct svc_sock *svsk)
 	svsk->sk_sk->write_space = svc_write_space;
 	svsk->sk_recvfrom = svc_udp_recvfrom;
 	svsk->sk_sendto = svc_udp_sendto;
+
+	/* initialise setting must have enough space to
+	 * receive and respond to one request.  
+	 * svc_udp_recvfrom will re-adjust if necessary
+	 */
+	svc_sock_setbufsize(svsk->sk_sock,
+			    3 * svsk->sk_server->sv_bufsz,
+			    3 * svsk->sk_server->sv_bufsz);
+
 	set_bit(SK_CHNGBUF, &svsk->sk_flags);
 
 	return 0;
@@ -943,6 +952,14 @@ svc_tcp_init(struct svc_sock *svsk)
 		svsk->sk_reclen = 0;
 		svsk->sk_tcplen = 0;
 
+		/* initialise setting must have enough space to
+		 * receive and respond to one request.  
+		 * svc_tcp_recvfrom will re-adjust if necessary
+		 */
+		svc_sock_setbufsize(svsk->sk_sock,
+				    3 * svsk->sk_server->sv_bufsz,
+				    3 * svsk->sk_server->sv_bufsz);
+
 		set_bit(SK_CHNGBUF, &svsk->sk_flags);
 	}
 


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] 2 of 3 - call svc_sock_setbufsize when socket created.
Date: Thu, 22 Aug 2002 10:33:47 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E17hfv1-0004zh-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net,  Chuck Lever <cel@citi.umich.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17hfvF-00088w-00
	for <nfs@lists.sourceforge.net>; Wed, 21 Aug 2002 17:34:01 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>)
	(for <cel@citi.umich.edu>) By tone With Smtp ;
	Thu, 22 Aug 2002 10:33:52 +1000
To: Linus Torvalds <torvalds@transmeta.com>
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


### Comments for ChangeSet

bufsiz is re-evaluated on recv if SK_CHNGBUF is set,
but recv will never be reached if the buffers are too small.
So we have to set to to something vaguely reasonable
at init time.


 ----------- Diffstat output ------------
 ./net/sunrpc/svcsock.c |   16 ++++++++++++++++
 1 files changed, 16 insertions(+)

--- ./net/sunrpc/svcsock.c	2002/08/21 23:03:04	1.2
+++ ./net/sunrpc/svcsock.c	2002/08/21 23:04:58	1.3
@@ -574,6 +574,14 @@ svc_udp_init(struct svc_sock *svsk)
 	svsk->sk_recvfrom = svc_udp_recvfrom;
 	svsk->sk_sendto = svc_udp_sendto;
 
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
@@ -946,6 +954,14 @@ svc_tcp_init(struct svc_sock *svsk)
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

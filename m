From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: PATCH - SUNRPC 2 of 3 - Fix two problems with multiple concurrent nfs/tcp connects.
Date: Tue, 20 Aug 2002 14:25:41 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15713.50373.533039.466856@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17h0ac-0001yU-00
	for <nfs@lists.sourceforge.net>; Mon, 19 Aug 2002 21:25:58 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.85] == wireless-085.wireless.cse.unsw.EDU.AU)
	(for <marcelo@conectiva.com.br>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Tue, 20 Aug 2002 14:25:48 +1000
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



1/ connect requests would be get lost...
  As the comment at the top of svcsock.c says when discussing
  SK_CONN:
 *		after a set, svc_sock_enqueue must be called.	

  We didn't and so lost requests.

2/ set the max accept backlog to a more reasonable number to cope 
   with bursts of lots of requests. 




 ----------- Diffstat output ------------
 ./net/sunrpc/svcsock.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletion(-)

--- ./net/sunrpc/svcsock.c	2002/08/20 03:02:09	1.1
+++ ./net/sunrpc/svcsock.c	2002/08/20 03:02:21	1.2
@@ -677,6 +677,8 @@ svc_tcp_accept(struct svc_sock *svsk)
 		goto failed;		/* aborted connection or whatever */
 	}
 	set_bit(SK_CONN, &svsk->sk_flags);
+	svc_sock_enqueue(svsk);
+
 	slen = sizeof(sin);
 	err = ops->getname(newsock, (struct sockaddr *) &sin, &slen, 1);
 	if (err < 0) {
@@ -1219,7 +1221,7 @@ svc_create_socket(struct svc_serv *serv,
 	}
 
 	if (protocol == IPPROTO_TCP) {
-		if ((error = sock->ops->listen(sock, 5)) < 0)
+		if ((error = sock->ops->listen(sock, 64)) < 0)
 			goto bummer;
 	}
 


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

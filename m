From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] 1 of 3 - Fix two problems with multiple concurrent nfs/tcp connects.
Date: Thu, 22 Aug 2002 10:33:46 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E17hfv0-0004ze-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net,  Chuck Lever <cel@citi.umich.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17hfvN-0008Ab-00
	for <nfs@lists.sourceforge.net>; Wed, 21 Aug 2002 17:34:09 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>)
	(for <cel@citi.umich.edu>) By tone With Smtp ;
	Thu, 22 Aug 2002 10:33:51 +1000
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


These three patches fix some issues with SUNRPC caused by the
RPC over TCP patch set.  Thanks particularly to
    erik_habbinga@hp.com
for helping to find some of them.

### Comments for ChangeSet

1/ connect requests would be get lost...
  As the comment at the top of svcsock.c says when discussing
  SK_CONN:
 *		after a set, svc_sock_enqueue must be called.	

  We didn't and so lost conneciton requests.

2/ set the max accept backlog to a more reasonable number to cope 
   with bursts of lots of connection requests. 

 ----------- Diffstat output ------------
 ./net/sunrpc/svcsock.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletion(-)

--- ./net/sunrpc/svcsock.c	2002/08/21 23:02:39	1.1
+++ ./net/sunrpc/svcsock.c	2002/08/21 23:03:04	1.2
@@ -679,6 +679,8 @@ svc_tcp_accept(struct svc_sock *svsk)
 		goto failed;		/* aborted connection or whatever */
 	}
 	set_bit(SK_CONN, &svsk->sk_flags);
+	svc_sock_enqueue(svsk);
+
 	slen = sizeof(sin);
 	err = ops->getname(newsock, (struct sockaddr *) &sin, &slen, 1);
 	if (err < 0) {
@@ -1220,7 +1222,7 @@ svc_create_socket(struct svc_serv *serv,
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

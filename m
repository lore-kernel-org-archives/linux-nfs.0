From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: PATCH - kNFSd - More small fixes for TCP nfsd
Date: Fri, 30 Aug 2002 12:42:52 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15726.56236.831858.685392@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net,
   "HABBINGA,ERIK (HP-Loveland,ex1)" <erik_habbinga@hp.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17kbky-0002ME-00
	for <nfs@lists.sourceforge.net>; Thu, 29 Aug 2002 19:43:32 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <marcelo@conectiva.com.br>) (for <nfs@lists.sourceforge.net>)
	(for <erik_habbinga@hp.com>) By tone With Smtp ;
	Fri, 30 Aug 2002 12:43:00 +1000
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


sk_inuse should be bigger than "char" as we can
have more than 255 server threads.  Due to the way the count
is used, this is unlikely to actually cause a problem, but it
should nonetheless be fixed.

Also, two printk generate more noise than we would like,
so turn them into dprintk (debugging printk).



 ----------- Diffstat output ------------
 ./include/linux/sunrpc/svcsock.h |    2 +-
 ./net/sunrpc/svcsock.c           |   11 +++++------
 2 files changed, 6 insertions(+), 7 deletions(-)

--- ./include/linux/sunrpc/svcsock.h	2002/08/30 01:16:44	1.1
+++ ./include/linux/sunrpc/svcsock.h	2002/08/30 01:35:41	1.2
@@ -21,7 +21,7 @@ struct svc_sock {
 	struct sock *		sk_sk;		/* INET layer */
 
 	struct svc_serv *	sk_server;	/* service for this socket */
-	unsigned char		sk_inuse;	/* use count */
+	unsigned int		sk_inuse;	/* use count */
 	unsigned long		sk_flags;
 #define	SK_BUSY		0			/* enqueued/receiving */
 #define	SK_CONN		1			/* conn pending */
--- ./net/sunrpc/svcsock.c	2002/08/30 01:31:42	1.1
+++ ./net/sunrpc/svcsock.c	2002/08/30 01:35:41	1.2
@@ -702,11 +702,10 @@ svc_tcp_accept(struct svc_sock *svsk)
 	 * tell us anything. For now just warn about unpriv connections.
 	 */
 	if (ntohs(sin.sin_port) >= 1024) {
-		if (net_ratelimit())
-			printk(KERN_WARNING
-				   "%s: connect from unprivileged port: %u.%u.%u.%u:%d\n",
-				   serv->sv_name, 
-				   NIPQUAD(sin.sin_addr.s_addr), ntohs(sin.sin_port));
+		dprintk(KERN_WARNING
+			"%s: connect from unprivileged port: %u.%u.%u.%u:%d\n",
+			serv->sv_name, 
+			NIPQUAD(sin.sin_addr.s_addr), ntohs(sin.sin_port));
 	}
 
 	dprintk("%s: connect from %u.%u.%u.%u:%04x\n", serv->sv_name,
@@ -1286,7 +1285,7 @@ svc_delete_socket(struct svc_sock *svsk)
 		kfree(svsk);
 	} else {
 		spin_unlock_bh(&serv->sv_lock);
-		printk(KERN_NOTICE "svc: server socket destroy delayed\n");
+		dprintk(KERN_NOTICE "svc: server socket destroy delayed\n");
 		/* svsk->sk_server = NULL; */
 	}
 }


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: PATCH - kNFSd - More small fixes for TCP nfsd
Date: Fri, 30 Aug 2002 15:22:50 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15727.298.668705.558187@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17keFb-0005zz-00
	for <nfs@lists.sourceforge.net>; Thu, 29 Aug 2002 22:23:19 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Fri, 30 Aug 2002 15:22:56 +1000
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


sk_inuse should be bigger than "char" as we can
have more than 255 server threads.  Due to the way the count
is used, this is unlikely to actually cause a problem, but it
should nonetheless be fixed.

Also, two printk generate more noise than we would like,
so turn them into dprintk (debugging printk).

(already sent to Marcelo for 2.4.  This is 2.5 version)

 ----------- Diffstat output ------------
 ./include/linux/sunrpc/svcsock.h |    2 +-
 ./net/sunrpc/svcsock.c           |   11 +++++------
 2 files changed, 6 insertions(+), 7 deletions(-)

--- ./include/linux/sunrpc/svcsock.h	2002/08/30 02:44:25	1.1
+++ ./include/linux/sunrpc/svcsock.h	2002/08/30 02:45:20	1.2
@@ -21,7 +21,7 @@ struct svc_sock {
 	struct sock *		sk_sk;		/* INET layer */
 
 	struct svc_serv *	sk_server;	/* service for this socket */
-	unsigned char		sk_inuse;	/* use count */
+	unsigned int		sk_inuse;	/* use count */
 	unsigned long		sk_flags;
 #define	SK_BUSY		0			/* enqueued/receiving */
 #define	SK_CONN		1			/* conn pending */
--- ./net/sunrpc/svcsock.c	2002/08/30 02:44:26	1.1
+++ ./net/sunrpc/svcsock.c	2002/08/30 02:45:21	1.2
@@ -703,11 +703,10 @@ svc_tcp_accept(struct svc_sock *svsk)
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
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

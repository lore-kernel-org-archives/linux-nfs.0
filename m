From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] 3 of 3 - Fix error message printed when not enough queue space
Date: Thu, 22 Aug 2002 10:33:48 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E17hfv2-0004zl-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net,  Chuck Lever <cel@citi.umich.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17hfvJ-00089j-00
	for <nfs@lists.sourceforge.net>; Wed, 21 Aug 2002 17:34:05 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>)
	(for <cel@citi.umich.edu>) By tone With Smtp ;
	Thu, 22 Aug 2002 10:33:58 +1000
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


 ----------- Diffstat output ------------
 ./net/sunrpc/svcsock.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

--- ./net/sunrpc/svcsock.c	2002/08/21 23:04:58	1.3
+++ ./net/sunrpc/svcsock.c	2002/08/21 23:05:37	1.4
@@ -140,7 +140,7 @@ svc_sock_enqueue(struct svc_sock *svsk)
 	    && !test_bit(SK_CLOSE, &svsk->sk_flags)
 	    && !test_bit(SK_CONN, &svsk->sk_flags)) {
 		/* Don't enqueue while not enough space for reply */
-		dprintk("svc: socket %p  no space, %d > %ld, not enqueued\n",
+		dprintk("svc: socket %p  no space, %d*2 > %ld, not enqueued\n",
 			svsk->sk_sk, svsk->sk_reserved+serv->sv_bufsz,
 			sock_wspace(svsk->sk_sk));
 		goto out_unlock;


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

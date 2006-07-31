From: NeilBrown <neilb@suse.de>
Subject: [PATCH 005 of 11] knfsd: test and set SK_BUSY atomically
Date: Mon, 31 Jul 2006 10:42:08 +1000
Message-ID: <1060731004208.29231@suse.de>
References: <20060731103458.29040.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G7LrK-0003sO-9E
	for nfs@lists.sourceforge.net; Sun, 30 Jul 2006 17:42:14 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G7LrK-0001cU-4v
	for nfs@lists.sourceforge.net; Sun, 30 Jul 2006 17:42:14 -0700
To: Andrew Morton <akpm@osdl.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


From: Greg Banks <gnb@melbourne.sgi.com>

knfsd: The SK_BUSY bit in svc_sock->sk_flags ensures that we do not
attempt to enqueue a socket twice.  Currently, setting and clearing
the bit is protected by svc_serv->sv_lock.  As I intend to reduce the
data that the lock protects so it's not held when svc_sock_enqueue()
tests and sets SK_BUSY, that test and set needs to be atomic.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./net/sunrpc/svcsock.c |   20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff .prev/net/sunrpc/svcsock.c ./net/sunrpc/svcsock.c
--- .prev/net/sunrpc/svcsock.c	2006-07-31 10:00:44.000000000 +1000
+++ ./net/sunrpc/svcsock.c	2006-07-31 10:01:07.000000000 +1000
@@ -46,14 +46,13 @@
 
 /* SMP locking strategy:
  *
- * 	svc_serv->sv_lock protects most stuff for that service.
+ *	svc_serv->sv_lock protects most stuff for that service.
  *	svc_sock->sk_defer_lock protects the svc_sock->sk_deferred list
+ *	svc_sock->sk_flags.SK_BUSY prevents a svc_sock being enqueued multiply.
  *
  *	Some flags can be set to certain values at any time
  *	providing that certain rules are followed:
  *
- *	SK_BUSY  can be set to 0 at any time.  
- *		svc_sock_enqueue must be called afterwards
  *	SK_CONN, SK_DATA, can be set or cleared at any time.
  *		after a set, svc_sock_enqueue must be called.	
  *		after a clear, the socket must be read/accepted
@@ -170,8 +169,13 @@ svc_sock_enqueue(struct svc_sock *svsk)
 		goto out_unlock;
 	}
 
-	if (test_bit(SK_BUSY, &svsk->sk_flags)) {
-		/* Don't enqueue socket while daemon is receiving */
+	/* Mark socket as busy. It will remain in this state until the
+	 * server has processed all pending data and put the socket back
+	 * on the idle list.  We update SK_BUSY atomically because
+	 * it also guards against trying to enqueue the svc_sock twice.
+	 */
+	if (test_and_set_bit(SK_BUSY, &svsk->sk_flags)) {
+		/* Don't enqueue socket while already enqueued */
 		dprintk("svc: socket %p busy, not enqueued\n", svsk->sk_sk);
 		goto out_unlock;
 	}
@@ -185,15 +189,11 @@ svc_sock_enqueue(struct svc_sock *svsk)
 		dprintk("svc: socket %p  no space, %d*2 > %ld, not enqueued\n",
 			svsk->sk_sk, atomic_read(&svsk->sk_reserved)+serv->sv_bufsz,
 			svc_sock_wspace(svsk));
+		clear_bit(SK_BUSY, &svsk->sk_flags);
 		goto out_unlock;
 	}
 	clear_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
 
-	/* Mark socket as busy. It will remain in this state until the
-	 * server has processed all pending data and put the socket back
-	 * on the idle list.
-	 */
-	set_bit(SK_BUSY, &svsk->sk_flags);
 
 	if (!list_empty(&serv->sv_threads)) {
 		rqstp = list_entry(serv->sv_threads.next,

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

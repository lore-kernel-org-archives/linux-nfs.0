From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: PATCH - RPC/TCP 3 of 4 - Correct error message when rpc/tcp sent fails
Date: Tue, 13 Aug 2002 12:59:26 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15704.30222.363352.937187@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: minoura@valinux.co.jp (Minoura Makoto), Chuck Lever <cel@citi.umich.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17eRuj-0008OI-00
	for <nfs@lists.sourceforge.net>; Mon, 12 Aug 2002 20:00:09 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.85] == wireless-085.wireless.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <minoura@valinux.co.jp>)
	(for <cel@citi.umich.edu>) (for <nfs@lists.sourceforge.net>) By tone
	With Smtp ; Tue, 13 Aug 2002 12:59:28 +1000
To: Linus Torvalds <torvalds@transmeta.com>
cc: nfs@lists.sourceforge.net
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



Now that we actually do shutdown the socket, we should
say so instead of just saying that we should....


 ----------- Diffstat output ------------
 ./net/sunrpc/svcsock.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletion(-)

--- ./net/sunrpc/svcsock.c	2002/08/13 01:54:39	1.3
+++ ./net/sunrpc/svcsock.c	2002/08/13 01:57:46	1.4
@@ -911,8 +911,9 @@ svc_tcp_sendto(struct svc_rqst *rqstp)
 
 	sent = svc_sendto(rqstp, bufp->iov, bufp->nriov);
 	if (sent != bufp->len<<2) {
-		printk(KERN_NOTICE "rpc-srv/tcp: %s: sent only %d bytes of %d - should shutdown socket\n",
+		printk(KERN_NOTICE "rpc-srv/tcp: %s: %s %d when sending %d bytes - shutting down socket\n",
 		       rqstp->rq_sock->sk_server->sv_name,
+		       (sent<0)?"got error":"sent only",
 		       sent, bufp->len << 2);
 		svc_delete_socket(rqstp->rq_sock);
 		sent = -EAGAIN;


-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

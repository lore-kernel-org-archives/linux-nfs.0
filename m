From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 2 of 6 - Fix race in svcsock.c
Date: Wed, 12 Mar 2003 16:35:28 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E18sytk-0005Qu-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18sytt-0000Dh-00
	for <nfs@lists.sourceforge.net>; Tue, 11 Mar 2003 21:35:37 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Wed, 12 Mar 2003 16:35:28 +1100
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


### Comments for ChangeSet

From: Trond Myklebust <trond.myklebust@fys.uio.no>


knfsd needs to disable soft interrupts when calling
csum_partial_copy_to_xdr().

At the moment there's a nasty conflict between the RPC server and
client. The problem arises when you get to xdr_partial_copy_from_skb()
(and the kmap_atomic()); the RPC client can end up calling the same
function from a ->data_ready() soft interrupt, and corrupt any data
the knfsd process may have copied.

 ----------- Diffstat output ------------
 ./net/sunrpc/svcsock.c |    3 +++
 1 files changed, 3 insertions(+)

diff ./net/sunrpc/svcsock.c~current~ ./net/sunrpc/svcsock.c
--- ./net/sunrpc/svcsock.c~current~	2003-03-12 15:02:05.000000000 +1100
+++ ./net/sunrpc/svcsock.c	2003-03-12 15:02:05.000000000 +1100
@@ -577,12 +577,15 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 
 	if (skb_is_nonlinear(skb)) {
 		/* we have to copy */
+		local_bh_disable();
 		if (csum_partial_copy_to_xdr(&rqstp->rq_arg, skb)) {
+			local_bh_enable();
 			/* checksum error */
 			skb_free_datagram(svsk->sk_sk, skb);
 			svc_sock_received(svsk);
 			return 0;
 		}
+		local_bh_enable();
 		skb_free_datagram(svsk->sk_sk, skb); 
 	} else {
 		/* we can use it in-place */


-------------------------------------------------------
This SF.net email is sponsored by:Crypto Challenge is now open! 
Get cracking and register here for some mind boggling fun and 
the chance of winning an Apple iPod:
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0031en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 4 of 9] Delete an obsolete comment from nfsd rpc code
Date: Thu, 24 Jun 2004 14:46:51 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1BdM8R-0001Lk-Pm@notabene.cse.unsw.edu.au>
References: <20040624143710.5086.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BdM8k-00024A-Eh
	for nfs@lists.sourceforge.net; Wed, 23 Jun 2004 21:47:10 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BdM8k-0007DD-0E
	for nfs@lists.sourceforge.net; Wed, 23 Jun 2004 21:47:10 -0700
To: Andrew Morton <akpm@osdl.org>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>



Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>         
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./net/sunrpc/svcsock.c |    1 -
 1 files changed, 1 deletion(-)

diff ./net/sunrpc/svcsock.c~current~ ./net/sunrpc/svcsock.c
--- ./net/sunrpc/svcsock.c~current~	2004-06-23 14:37:06.000000000 +1000
+++ ./net/sunrpc/svcsock.c	2004-06-23 14:37:35.000000000 +1000
@@ -414,7 +414,6 @@ svc_sendto(struct svc_rqst *rqstp, struc
 	}
 	/* send tail */
 	if (xdr->tail[0].iov_len) {
-		/* The tail *will* be in respages[0]; */
 		result = sock->ops->sendpage(sock, rqstp->rq_respages[rqstp->rq_restailpage], 
 					     ((unsigned long)xdr->tail[0].iov_base)& (PAGE_SIZE-1),
 					     xdr->tail[0].iov_len, 0);


-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

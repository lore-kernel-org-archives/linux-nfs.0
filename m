From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 2 of 16] nlm: fix f_count leak
Date: Tue, 22 Mar 2005 16:42:01 +1100
Message-ID: <E1DDc9R-0002KC-9a@notabene.cse.unsw.edu.au>
References: <20050322163830.8762.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DDcA1-0006lj-Q8
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 21:42:37 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DDc9z-00059u-Je
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 21:42:37 -0800
To: Andrew Morton <akpm@osdl.org>
Sender: nfs-admin@lists.sourceforge.net
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


I can't see any reason for this file->f_count++.  Removing it fixes a bug
which leaves an exported filesystem busy if a callback for a lock held on that
filesystem ever failed.

Found by Terence Rokop.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/lockd/svclock.c |    1 -
 1 files changed, 1 deletion(-)

diff ./fs/lockd/svclock.c~current~ ./fs/lockd/svclock.c
--- ./fs/lockd/svclock.c~current~	2005-03-22 16:35:20.000000000 +1100
+++ ./fs/lockd/svclock.c	2005-03-22 16:36:34.000000000 +1100
@@ -641,7 +641,6 @@ nlmsvc_grant_reply(struct svc_rqst *rqst
 		} else {
 			/* Lock is now held by client, or has been rejected.
 			 * In both cases, the block should be removed. */
-			file->f_count++;
 			up(&file->f_sema);
 			if (status == NLM_LCK_GRANTED)
 				nlmsvc_delete_block(block, 0);


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

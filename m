From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 52 of 54] locks: remove unnecessary BUG()
Date: Tue, 08 Mar 2005 17:06:45 +1100
Message-ID: <E1D8Xrh-0001AB-Il@notabene.cse.unsw.edu.au>
References: <20050308165419.3842.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8Xrr-000282-AZ
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:55 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1D8Xrp-0007tT-EH
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:55 -0800
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


We get a NULL dereference here anyway, no need to BUG() explicitly.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/locks.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff ./fs/locks.c~current~ ./fs/locks.c
--- ./fs/locks.c~current~	2005-03-07 13:37:44.000000000 +1100
+++ ./fs/locks.c	2005-03-07 13:37:44.000000000 +1100
@@ -1172,10 +1172,8 @@ int __break_lease(struct inode *inode, u
 		if (fl->fl_type != future) {
 			fl->fl_type = future;
 			fl->fl_break_time = break_time;
-			if (fl->fl_lmops && fl->fl_lmops->fl_break)
-				fl->fl_lmops->fl_break(fl);
-			else    /* lease must have lmops break callback */
-				BUG();
+			/* lease must have lmops break callback */
+			fl->fl_lmops->fl_break(fl);
 		}
 	}
 


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 013 of 19] nfsd4: always update stateid on open
Date: Mon, 04 Jul 2005 11:01:44 +1000
Message-ID: <E1DpFLE-0007Gq-1g@notabene.cse.unsw.edu.au>
References: <20050704110022.27753.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.91] (helo=sc8-sf-mx1-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DpFLk-0001kG-Lz
	for nfs@lists.sourceforge.net; Sun, 03 Jul 2005 18:02:16 -0700
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx1-new.sourceforge.net with esmtp (Exim 4.44)
	id 1DpFLk-0006yq-62
	for nfs@lists.sourceforge.net; Sun, 03 Jul 2005 18:02:16 -0700
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


An OPEN from the same client/open stateowner requires a stateid update because
of the share/deny access update.

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |    1 +
 1 files changed, 1 insertion(+)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-07-04 10:57:53.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2005-07-04 10:57:53.000000000 +1000
@@ -1820,6 +1820,7 @@ nfsd4_process_open2(struct svc_rqst *rqs
 		status = nfs4_upgrade_open(rqstp, current_fh, stp, open);
 		if (status)
 			goto out;
+		update_stateid(&stp->st_stateid);
 	} else {
 		/* Stateid was not found, this is a new OPEN */
 		int flags = 0;


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

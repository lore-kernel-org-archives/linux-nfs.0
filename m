From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 004 of 19] nfsd4: prevent multiple unlinks of recovery directories
Date: Mon, 04 Jul 2005 11:01:43 +1000
Message-ID: <E1DpFLD-0007GF-0f@notabene.cse.unsw.edu.au>
References: <20050704110022.27753.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DpFLk-0001kF-Cx
	for nfs@lists.sourceforge.net; Sun, 03 Jul 2005 18:02:16 -0700
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DpFLg-0007TD-LH
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


Make sure we don't try to delete client recovery directories multiple times;
fixes some spurious error messages.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4recover.c |    1 +
 1 files changed, 1 insertion(+)

diff ./fs/nfsd/nfs4recover.c~current~ ./fs/nfsd/nfs4recover.c
--- ./fs/nfsd/nfs4recover.c~current~	2005-07-04 10:57:52.000000000 +1000
+++ ./fs/nfsd/nfs4recover.c	2005-07-04 10:57:52.000000000 +1000
@@ -316,6 +316,7 @@ nfsd4_remove_clid_dir(struct nfs4_client
 	if (!rec_dir_init || !clp->cl_firststate)
 		return;
 
+	clp->cl_firststate = 0;
 	nfs4_save_user(&uid, &gid);
 	status = nfsd4_unlink_clid_dir(clp->cl_recdir, HEXDIR_LEN-1);
 	nfs4_reset_user(uid, gid);


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

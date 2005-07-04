From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 001 of 19] nfsd4: reboot recovery fix
Date: Mon, 04 Jul 2005 11:01:41 +1000
Message-ID: <E1DpFLB-0007G4-E8@notabene.cse.unsw.edu.au>
References: <20050704110022.27753.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.91] (helo=sc8-sf-mx1-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DpFM8-0001l2-3x
	for nfs@lists.sourceforge.net; Sun, 03 Jul 2005 18:02:40 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1-new.sourceforge.net with esmtp (Exim 4.44)
	id 1DpFM6-00070n-Rw
	for nfs@lists.sourceforge.net; Sun, 03 Jul 2005 18:02:40 -0700
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


We need to remove the recovery directory here too.  (This chunk just got lost
somehow in the process of commuting the reboot recovery patches past the other
patches.)

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |    1 +
 1 files changed, 1 insertion(+)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-07-04 10:57:51.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2005-07-04 10:57:51.000000000 +1000
@@ -874,6 +874,7 @@ nfsd4_setclientid_confirm(struct svc_rqs
 			  * change request correctly. */
 			atomic_set(&conf->cl_callback.cb_set, 0);
 			gen_confirm(conf);
+			nfsd4_remove_clid_dir(unconf);
 			expire_client(unconf);
 			status = nfs_ok;
 


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

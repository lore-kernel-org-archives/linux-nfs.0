From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 9 of 18] remove incorrect stateid modification in nfsv4 open upgrade
Date: Fri, 24 Sep 2004 14:54:53 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1CAi6f-0000kO-Hm@notabene.cse.unsw.edu.au>
References: <20040924145130.2689.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CAi7C-00088u-CU
	for nfs@lists.sourceforge.net; Thu, 23 Sep 2004 21:55:26 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CAi7B-0006Bf-Si
	for nfs@lists.sourceforge.net; Thu, 23 Sep 2004 21:55:26 -0700
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



When we upgrade an open, we keep the same stateid and bump only the seqid.

Signed-off-by: Andy Adamson <andros@umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |    2 --
 1 files changed, 2 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-09-24 14:48:39.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2004-09-24 14:48:39.000000000 +1000
@@ -1332,8 +1332,6 @@ nfsd4_process_open2(struct svc_rqst *rqs
 		/* remember the open */
 		set_bit(open->op_share_access, &stp->st_access_bmap);
 		set_bit(open->op_share_deny, &stp->st_deny_bmap);
-		/* bump the stateid */
-		update_stateid(&stp->st_stateid);
 	}
 	dprintk("nfs4_process_open2: stateid=(%08x/%08x/%08x/%08x)\n\n",
 	            stp->st_stateid.si_boot, stp->st_stateid.si_stateownerid,


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

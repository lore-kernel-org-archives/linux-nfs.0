From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 17 of 18] nfsd4: fix putrootfh return
Date: Fri, 24 Sep 2004 14:54:54 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1CAi6g-0000l4-8R@notabene.cse.unsw.edu.au>
References: <20040924145130.2689.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CAi7o-0008E0-2p
	for nfs@lists.sourceforge.net; Thu, 23 Sep 2004 21:56:04 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CAi7n-0006Fc-Ci
	for nfs@lists.sourceforge.net; Thu, 23 Sep 2004 21:56:03 -0700
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



Thanks to Al Viro for noticing that putrootfh could return either a linux or an
nfs error.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4proc.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2004-09-24 14:48:38.000000000 +1000
+++ ./fs/nfsd/nfs4proc.c	2004-09-24 14:48:41.000000000 +1000
@@ -267,7 +267,7 @@ nfsd4_putrootfh(struct svc_rqst *rqstp, 
 	status = exp_pseudoroot(rqstp->rq_client, current_fh,
 			      &rqstp->rq_chandle);
 	if (!status)
-		status = nfsd_setuser(rqstp, current_fh->fh_export);
+		status = nfserrno(nfsd_setuser(rqstp, current_fh->fh_export));
 	return status;
 }
 


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

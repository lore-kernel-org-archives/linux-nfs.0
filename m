From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSdv4 - 9 of 10 - Set credentials properly when puutrootfh is used
Date: Thu, 08 Apr 2004 11:18:46 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1BBOBq-0001R2-MX@notabene.cse.unsw.edu.au>
References: <20040408111135.5397.patches@notabene>
Cc: nfs@lists.sourceforge.net,  "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BBOCM-0007ja-Oq
	for nfs@lists.sourceforge.net; Wed, 07 Apr 2004 18:19:18 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BBOCM-00023e-Dc
	for nfs@lists.sourceforge.net; Wed, 07 Apr 2004 18:19:18 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.241.7] == ppp2-007.ppp2.cse.unsw.EDU.AU) (auth-user neilb)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>)
	(for <bfields@fieldses.org>) By note With Smtp ;
	Thu, 8 Apr 2004 11:19:14 +1000
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


The credentials (uid/gid) of a process are set when a filehandle
is verified.  Nfsv4 allows requests without an explicit filehandle
(instead, an implicit 'root' filehandle) so we much make sure the
credentials are set for these requests too.

From: "J. Bruce Fields" <bfields@fieldses.org>

>From Andros: added a call to nfsd_setuser in nfsd4_putrootfh so that nfsd runs
as the rpc->cred user.

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4proc.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletion(-)

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2004-04-08 10:57:00.000000000 +1000
+++ ./fs/nfsd/nfs4proc.c	2004-04-08 10:57:10.000000000 +1000
@@ -194,9 +194,14 @@ nfsd4_putfh(struct svc_rqst *rqstp, stru
 static inline int
 nfsd4_putrootfh(struct svc_rqst *rqstp, struct svc_fh *current_fh)
 {
+	int status;
+
 	fh_put(current_fh);
-	return exp_pseudoroot(rqstp->rq_client, current_fh,
+	status = exp_pseudoroot(rqstp->rq_client, current_fh,
 			      &rqstp->rq_chandle);
+	if (!status)
+		status = nfsd_setuser(rqstp, current_fh->fh_export);
+	return status;
 }
 
 static inline int


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

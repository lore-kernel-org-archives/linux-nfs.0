From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 006 of 19] nfsd4: ERR_GRACE should bump seqid on open
Date: Mon, 04 Jul 2005 11:01:43 +1000
Message-ID: <E1DpFLD-0007GO-9A@notabene.cse.unsw.edu.au>
References: <20050704110022.27753.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DpFLh-0001jz-Eq
	for nfs@lists.sourceforge.net; Sun, 03 Jul 2005 18:02:13 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DpFLe-0007TB-Sd
	for nfs@lists.sourceforge.net; Sun, 03 Jul 2005 18:02:13 -0700
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


The GRACE and NOGRACE errors should bump the sequence id on open.  So we delay
the handling of these errors until nfsd4_process_open2, at which point we've
set the open owner, so the encode routine will be able to bump the sequence id.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4proc.c  |    6 ------
 ./fs/nfsd/nfs4state.c |    6 ++++++
 2 files changed, 6 insertions(+), 6 deletions(-)

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2005-07-04 10:57:52.000000000 +1000
+++ ./fs/nfsd/nfs4proc.c	2005-07-04 10:57:52.000000000 +1000
@@ -169,12 +169,6 @@ nfsd4_open(struct svc_rqst *rqstp, struc
 		(int)open->op_fname.len, open->op_fname.data,
 		open->op_stateowner);
 
-	if (nfs4_in_grace() && open->op_claim_type != NFS4_OPEN_CLAIM_PREVIOUS)
-		return nfserr_grace;
-
-	if (!nfs4_in_grace() && open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS)
-		return nfserr_no_grace;
-
 	/* This check required by spec. */
 	if (open->op_create && open->op_claim_type != NFS4_OPEN_CLAIM_NULL)
 		return nfserr_inval;

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-07-04 10:57:52.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2005-07-04 10:57:52.000000000 +1000
@@ -1790,6 +1790,12 @@ nfsd4_process_open2(struct svc_rqst *rqs
 	struct nfs4_delegation *dp = NULL;
 	int status;
 
+	if (nfs4_in_grace() && open->op_claim_type != NFS4_OPEN_CLAIM_PREVIOUS)
+		return nfserr_grace;
+
+	if (!nfs4_in_grace() && open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS)
+		return nfserr_no_grace;
+
 	status = nfserr_inval;
 	if (!TEST_ACCESS(open->op_share_access) || !TEST_DENY(open->op_share_deny))
 		goto out;


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

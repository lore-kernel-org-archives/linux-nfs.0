From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 19 of 54] nfsd4: simplify open_delegation 2
Date: Tue, 08 Mar 2005 17:06:43 +1100
Message-ID: <E1D8Xrf-000181-NZ@notabene.cse.unsw.edu.au>
References: <20050308165419.3842.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8XsH-0002Ay-70
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:07:21 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D8XsF-0005Gb-Gr
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:07:21 -0800
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



Simplify logic in nfs4_open_delegation, fix a small bug on allocation failure.

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-03-07 11:35:55.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2005-03-07 11:35:56.000000000 +1100
@@ -1664,20 +1664,21 @@ nfs4_open_delegation(struct svc_fh *fh, 
 	if (*flag == NFS4_OPEN_DELEGATE_NONE)
 		return;
 
-	/* set flag */
 	*flag = NFS4_OPEN_DELEGATE_NONE;
 	if (open->op_claim_type != NFS4_OPEN_CLAIM_NULL
 	     || !atomic_read(&cb->cb_set) || !sop->so_confirmed)
 		return;
 
-	if (!(open->op_share_access & NFS4_SHARE_ACCESS_WRITE))
-		*flag = NFS4_OPEN_DELEGATE_READ;
-
-	else if (!(open->op_share_access & NFS4_SHARE_ACCESS_READ))
+	if (open->op_share_access & NFS4_SHARE_ACCESS_WRITE)
 		*flag = NFS4_OPEN_DELEGATE_WRITE;
+	else
+		*flag = NFS4_OPEN_DELEGATE_READ;
 
-	if (!(dp = alloc_init_deleg(sop->so_client, stp->st_file, fh, *flag)))
+	dp = alloc_init_deleg(sop->so_client, stp->st_file, fh, *flag);
+	if (dp == NULL) {
+		*flag = NFS4_OPEN_DELEGATE_NONE;
 		return;
+	}
 	locks_init_lock(&fl);
 	fl.fl_lmops = &nfsd_lease_mng_ops;
 	fl.fl_flags = FL_LEASE;


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 16 of 54] nfsd4: don't release nfs4_file with associated delegations
Date: Tue, 08 Mar 2005 17:06:43 +1100
Message-ID: <E1D8Xrf-00017p-As@notabene.cse.unsw.edu.au>
References: <20050308165419.3842.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8Xrm-00026a-Us
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:50 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1D8Xrl-0007si-1l
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:50 -0800
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


Only release a struct nfs4_file if there are no associated delegations.

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-03-07 11:35:12.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2005-03-07 11:35:12.000000000 +1100
@@ -1791,7 +1791,7 @@ nfsd4_process_open2(struct svc_rqst *rqs
 	            stp->st_stateid.si_fileid, stp->st_stateid.si_generation);
 out:
 	/* take the opportunity to clean up unused state */
-	if (fp && list_empty(&fp->fi_perfile))
+	if (fp && list_empty(&fp->fi_perfile) && list_empty(&fp->fi_del_perfile))
 		release_file(fp);
 
 	/* CLAIM_PREVIOUS has different error returns */


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 13 of 54] nfsd4: miscellaneous open cleanup
Date: Tue, 08 Mar 2005 17:06:43 +1100
Message-ID: <E1D8Xrf-00017d-1j@notabene.cse.unsw.edu.au>
References: <20050308165419.3842.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8Xrq-00027n-Mt
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:54 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1D8Xrn-0007t9-7C
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:54 -0800
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



Minor trivial cleanup, mostly whitespace.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4proc.c  |    3 +--
 ./fs/nfsd/nfs4state.c |   19 +++++++++----------
 2 files changed, 10 insertions(+), 12 deletions(-)

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2005-03-07 11:35:11.000000000 +1100
+++ ./fs/nfsd/nfs4proc.c	2005-03-07 11:35:11.000000000 +1100
@@ -117,7 +117,6 @@ do_open_lookup(struct svc_rqst *rqstp, s
 
 		/* set reply cache */
 		fh_dup2(current_fh, &resfh);
-		/* XXXJBF: keep a saved svc_fh struct instead?? */
 		open->op_stateowner->so_replay.rp_openfh_len =
 			resfh.fh_handle.fh_size;
 		memcpy(open->op_stateowner->so_replay.rp_openfh,
@@ -153,7 +152,7 @@ do_open_fhandle(struct svc_rqst *rqstp, 
 		current_fh->fh_handle.fh_size);
 
 	open->op_truncate = (open->op_iattr.ia_valid & ATTR_SIZE) &&
-	!open->op_iattr.ia_size;
+		(open->op_iattr.ia_size == 0);
 
 	status = do_open_permission(rqstp, current_fh, open);
 

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-03-07 11:35:11.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2005-03-07 11:35:11.000000000 +1100
@@ -1465,18 +1465,17 @@ nfsd4_process_open1(struct nfsd4_open *o
 		/* check for replay */
 		if (open->op_seqid == sop->so_seqid){
 			if (!sop->so_replay.rp_buflen) {
-			/*
-			* The original OPEN failed in so spectacularly that we
-			* don't even have replay data saved!  Therefore, we
-			* have no choice but to continue processing
-			* this OPEN; presumably, we'll fail again for the same
-			* reason.
-			*/
-				dprintk("nfsd4_process_open1: replay with no replay cache\n");
+				/* The original OPEN failed so spectacularly
+				 * that we don't even have replay data saved!
+				 * Therefore, we have no choice but to continue
+				 * processing this OPEN; presumably, we'll
+				 * fail again for the same reason.
+				 */
+				dprintk("nfsd4_process_open1:"
+					" replay with no replay cache\n");
 				status = NFS_OK;
 				goto renew;
 			}
-			/* replay: indicate to calling function */
 			status = NFSERR_REPLAY_ME;
 			return status;
 		}
@@ -1488,7 +1487,7 @@ nfsd4_process_open1(struct nfsd4_open *o
 			status = nfserr_bad_seqid;
 			goto out;
 		}
-		/* If we get here, we received and OPEN for an unconfirmed
+		/* If we get here, we received an OPEN for an unconfirmed
 		 * nfs4_stateowner. 
 		 * Since the sequid's are different, purge the 
 		 * existing nfs4_stateowner, and instantiate a new one.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

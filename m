From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 14 of 54] nfsd4: miscellaneous open cleanup 2
Date: Tue, 08 Mar 2005 17:06:43 +1100
Message-ID: <E1D8Xrf-00017h-3U@notabene.cse.unsw.edu.au>
References: <20050308165419.3842.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8Xrk-00026O-OF
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:48 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D8Xrj-0005CG-Re
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:48 -0800
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



Replace sequence of if {... goto} 's by if-elseif's, other minor simplification
of logic.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   45 +++++++++++++++++++++------------------------
 1 files changed, 21 insertions(+), 24 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-03-07 11:35:11.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2005-03-07 11:35:11.000000000 +1100
@@ -1464,7 +1464,9 @@ nfsd4_process_open1(struct nfsd4_open *o
 		open->op_stateowner = sop;
 		/* check for replay */
 		if (open->op_seqid == sop->so_seqid){
-			if (!sop->so_replay.rp_buflen) {
+			if (sop->so_replay.rp_buflen)
+				return NFSERR_REPLAY_ME;
+			else {
 				/* The original OPEN failed so spectacularly
 				 * that we don't even have replay data saved!
 				 * Therefore, we have no choice but to continue
@@ -1476,37 +1478,32 @@ nfsd4_process_open1(struct nfsd4_open *o
 				status = NFS_OK;
 				goto renew;
 			}
-			status = NFSERR_REPLAY_ME;
-			return status;
-		}
-		if (sop->so_confirmed) {
+		} else if (sop->so_confirmed) {
 			if (open->op_seqid == sop->so_seqid + 1) { 
 				status = nfs_ok;
 				goto renew;
 			} 
 			status = nfserr_bad_seqid;
 			goto out;
+		} else {
+			/* If we get here, we received an OPEN for an
+			 * unconfirmed nfs4_stateowner. Since the seqid's are
+			 * different, purge the existing nfs4_stateowner, and
+			 * instantiate a new one.
+			 */
+			clp = sop->so_client;
+			release_stateowner(sop);
 		}
-		/* If we get here, we received an OPEN for an unconfirmed
-		 * nfs4_stateowner. 
-		 * Since the sequid's are different, purge the 
-		 * existing nfs4_stateowner, and instantiate a new one.
+	} else {
+		/* nfs4_stateowner not found.
+		 * Verify clientid and instantiate new nfs4_stateowner.
+		 * If verify fails this is presumably the result of the
+		 * client's lease expiring.
 		 */
-		clp = sop->so_client;
-		release_stateowner(sop);
-		goto instantiate_new_owner;
-	} 
-	/* nfs4_stateowner not found. 
-	* verify clientid and instantiate new nfs4_stateowner
-	* if verify fails this is presumably the result of the 
-	* client's lease expiring.
-	*
-	* XXX compare clp->cl_addr with rqstp addr? 
-	*/
-	status = nfserr_expired;
-	if (!verify_clientid(&clp, clientid))
-		goto out;
-instantiate_new_owner:
+		status = nfserr_expired;
+		if (!verify_clientid(&clp, clientid))
+			goto out;
+	}
 	status = nfserr_resource;
 	if (!(sop = alloc_init_open_stateowner(strhashval, clp, open))) 
 		goto out;


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

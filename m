From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 15 of 54] nfsd4: miscellaneous open cleanup 3
Date: Tue, 08 Mar 2005 17:06:43 +1100
Message-ID: <E1D8Xrf-00017l-51@notabene.cse.unsw.edu.au>
References: <20050308165419.3842.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8Xrn-00026v-G2
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:51 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D8Xrm-0005Ck-Vc
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:51 -0800
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



More minor logic cleanup.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   10 +++-------
 1 files changed, 3 insertions(+), 7 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-03-07 11:35:11.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2005-03-07 11:35:12.000000000 +1100
@@ -1455,9 +1455,8 @@ nfsd4_process_open1(struct nfsd4_open *o
 	if (!check_name(open->op_owner))
 		goto out;
 
-	status = nfserr_stale_clientid;
 	if (STALE_CLIENTID(&open->op_clientid))
-		return status;
+		return nfserr_stale_clientid;
 
 	strhashval = ownerstr_hashval(clientid->cl_id, open->op_owner);
 	if (find_openstateowner_str(strhashval, open, &sop)) {
@@ -1475,14 +1474,11 @@ nfsd4_process_open1(struct nfsd4_open *o
 				 */
 				dprintk("nfsd4_process_open1:"
 					" replay with no replay cache\n");
-				status = NFS_OK;
 				goto renew;
 			}
 		} else if (sop->so_confirmed) {
-			if (open->op_seqid == sop->so_seqid + 1) { 
-				status = nfs_ok;
+			if (open->op_seqid == sop->so_seqid + 1)
 				goto renew;
-			} 
 			status = nfserr_bad_seqid;
 			goto out;
 		} else {
@@ -1508,8 +1504,8 @@ nfsd4_process_open1(struct nfsd4_open *o
 	if (!(sop = alloc_init_open_stateowner(strhashval, clp, open))) 
 		goto out;
 	open->op_stateowner = sop;
-	status = nfs_ok;
 renew:
+	status = nfs_ok;
 	renew_client(sop->so_client);
 out:
 	if (status && open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS)


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

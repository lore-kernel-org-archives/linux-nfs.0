From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 14 of 16] nfsd4: remove trailing whitespace from nfs4proc.c
Date: Tue, 22 Mar 2005 16:42:02 +1100
Message-ID: <E1DDc9S-0002Ky-1r@notabene.cse.unsw.edu.au>
References: <20050322163830.8762.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DDcA1-0006lk-Q7
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 21:42:37 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DDcA0-0005gI-Iu
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 21:42:37 -0800
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


Trivial whitespace

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4proc.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2005-03-22 16:35:20.000000000 +1100
+++ ./fs/nfsd/nfs4proc.c	2005-03-22 16:36:36.000000000 +1100
@@ -200,8 +200,8 @@ nfsd4_open(struct svc_rqst *rqstp, struc
 	if (open->op_claim_type == NFS4_OPEN_CLAIM_NULL) {
 	/*
 	 * This block of code will (1) set CURRENT_FH to the file being opened,
-	 * creating it if necessary, (2) set open->op_cinfo, 
-	 * (3) set open->op_truncate if the file is to be truncated 
+	 * creating it if necessary, (2) set open->op_cinfo,
+	 * (3) set open->op_truncate if the file is to be truncated
 	 * after opening, (4) do permission checking.
 	 */
 		status = do_open_lookup(rqstp, current_fh, open);
@@ -573,8 +573,8 @@ nfsd4_setattr(struct svc_rqst *rqstp, st
 	status = nfs_ok;
 	if (setattr->sa_iattr.ia_valid & ATTR_SIZE) {
 		nfs4_lock_state();
-		if ((status = nfs4_preprocess_stateid_op(current_fh, 
-						&setattr->sa_stateid, 
+		if ((status = nfs4_preprocess_stateid_op(current_fh,
+						&setattr->sa_stateid,
 						CHECK_FH | WR_STATE, NULL))) {
 			dprintk("NFSD: nfsd4_setattr: couldn't process stateid!\n");
 			goto out_unlock;
@@ -609,7 +609,7 @@ nfsd4_write(struct svc_rqst *rqstp, stru
 		return nfserr_inval;
 
 	nfs4_lock_state();
-	if ((status = nfs4_preprocess_stateid_op(current_fh, stateid, 
+	if ((status = nfs4_preprocess_stateid_op(current_fh, stateid,
 					CHECK_FH | WR_STATE, &filp))) {
 		dprintk("NFSD: nfsd4_write: couldn't process stateid!\n");
 		goto out;


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

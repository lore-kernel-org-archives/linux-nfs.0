From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 15 of 16] nfsd4: fix open returns for other claim types
Date: Tue, 22 Mar 2005 16:42:02 +1100
Message-ID: <E1DDc9S-0002L2-3p@notabene.cse.unsw.edu.au>
References: <20050322163830.8762.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DDc9b-0006kZ-Pn
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 21:42:11 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DDc9a-00055v-WC
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 21:42:11 -0800
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


Switch on OPEN claim type instead of if-else. add remaining OPEN claim types.

Return nfserr_notsupp instead of nfserr_inval for valid claim types.

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4proc.c |   32 +++++++++++++++++++++-----------
 1 files changed, 21 insertions(+), 11 deletions(-)

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2005-03-22 16:36:36.000000000 +1100
+++ ./fs/nfsd/nfs4proc.c	2005-03-22 16:36:36.000000000 +1100
@@ -197,30 +197,40 @@ nfsd4_open(struct svc_rqst *rqstp, struc
 	}
 	if (status)
 		goto out;
-	if (open->op_claim_type == NFS4_OPEN_CLAIM_NULL) {
+	switch (open->op_claim_type) {
+		case NFS4_OPEN_CLAIM_NULL:
 	/*
 	 * This block of code will (1) set CURRENT_FH to the file being opened,
 	 * creating it if necessary, (2) set open->op_cinfo,
 	 * (3) set open->op_truncate if the file is to be truncated
 	 * after opening, (4) do permission checking.
 	 */
-		status = do_open_lookup(rqstp, current_fh, open);
-		if (status)
-			goto out;
-	} else if (open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS) {
+			status = do_open_lookup(rqstp, current_fh, open);
+			if (status)
+				goto out;
+			break;
+		case NFS4_OPEN_CLAIM_PREVIOUS:
 	/*
 	* The CURRENT_FH is already set to the file being opened. This
 	* block of code will (1) set open->op_cinfo, (2) set
 	* open->op_truncate if the file is to be truncated after opening,
 	* (3) do permission checking.
 	*/
-		status = do_open_fhandle(rqstp, current_fh, open);
-		if (status)
+			status = do_open_fhandle(rqstp, current_fh, open);
+			if (status)
+				goto out;
+			break;
+		case NFS4_OPEN_CLAIM_DELEGATE_CUR:
+             	case NFS4_OPEN_CLAIM_DELEGATE_PREV:
+			printk("NFSD: unsupported OPEN claim type %d\n",
+				open->op_claim_type);
+			status = nfserr_notsupp;
+			goto out;
+		default:
+			printk("NFSD: Invalid OPEN claim type %d\n",
+				open->op_claim_type);
+			status = nfserr_inval;
 			goto out;
-	} else {
-		printk("NFSD: unsupported OPEN claim type\n");
-		status = nfserr_inval;
-		goto out;
 	}
 	/*
 	 * nfsd4_process_open2() does the actual opening of the file.  If


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 007 of 16] nfsd4: add open state code for CLAIM_DELEGATE_CUR
Date: Fri, 08 Apr 2005 11:00:16 +1000
Message-ID: <E1DJhr6-0006dm-7T@notabene.cse.unsw.edu.au>
References: <20050408105936.25374.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DJikO-0006Tr-4F
	for nfs@lists.sourceforge.net; Thu, 07 Apr 2005 18:57:24 -0700
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DJikL-0004DP-UV
	for nfs@lists.sourceforge.net; Thu, 07 Apr 2005 18:57:22 -0700
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


State logic for OPEN with claim type CLAIM_DELEGATE_CUR, which the NFSv4
client uses to report local OPENs on a delegated file back to the NFSv4 server.

nfs4_check_deleg() performs input delegation stateid lookup and sanity check.

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   21 ++++++++++++++++-----
 1 files changed, 16 insertions(+), 5 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-04-08 10:39:52.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2005-04-08 10:41:30.000000000 +1000
@@ -1547,22 +1547,28 @@ find_delegation_file(struct nfs4_file *f
 	return NULL;
 }
 
-static void
+static int
 nfs4_check_deleg(struct nfs4_file *fp, struct nfsd4_open *open,
 		struct nfs4_delegation **dp)
 {
 	int flags;
-	int status;
+	int status = nfserr_bad_stateid;
 
 	*dp = find_delegation_file(fp, &open->op_delegate_stateid);
 	if (*dp == NULL)
-		return;
+		goto out;
 	flags = open->op_share_access == NFS4_SHARE_ACCESS_READ ?
 						RD_STATE : WR_STATE;
 	status = nfs4_check_delegmode(*dp, flags);
 	if (status)
 		*dp = NULL;
-	return;
+out:
+	if (open->op_claim_type != NFS4_OPEN_CLAIM_DELEGATE_CUR)
+		return nfs_ok;
+	if (status)
+		return status;
+	open->op_stateowner->so_confirmed = 1;
+	return nfs_ok;
 }
 
 static int
@@ -1760,8 +1766,13 @@ nfsd4_process_open2(struct svc_rqst *rqs
 	if (fp) {
 		if ((status = nfs4_check_open(fp, open, &stp)))
 			goto out;
-		nfs4_check_deleg(fp, open, &dp);
+		status = nfs4_check_deleg(fp, open, &dp);
+		if (status)
+			goto out;
 	} else {
+		status = nfserr_bad_stateid;
+		if (open->op_claim_type == NFS4_OPEN_CLAIM_DELEGATE_CUR)
+			goto out;
 		status = nfserr_resource;
 		fp = alloc_init_file(ino);
 		if (fp == NULL)


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 4 of 16] nfsd4: remove unneeded stateowner arguments
Date: Tue, 22 Mar 2005 16:42:01 +1100
Message-ID: <E1DDc9R-0002KK-EY@notabene.cse.unsw.edu.au>
References: <20050322163830.8762.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DDcA1-0006lg-DB
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 21:42:37 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DDcA0-0005gJ-KA
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


Remove the unneeded stateowner argument from nfs4_check_open() and
init_stateid.

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-03-22 16:36:34.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2005-03-22 16:36:35.000000000 +1100
@@ -1123,7 +1123,8 @@ release_stateowner(struct nfs4_stateowne
 }
 
 static inline void
-init_stateid(struct nfs4_stateid *stp, struct nfs4_file *fp, struct nfs4_stateowner *sop, struct nfsd4_open *open) {
+init_stateid(struct nfs4_stateid *stp, struct nfs4_file *fp, struct nfsd4_open *open) {
+	struct nfs4_stateowner *sop = open->op_stateowner;
 	unsigned int hashval = stateid_hashval(sop->so_id, fp->fi_id);
 
 	INIT_LIST_HEAD(&stp->st_hash);
@@ -1529,10 +1530,11 @@ out:
 }
 
 static int
-nfs4_check_open(struct nfs4_file *fp, struct nfs4_stateowner *sop, struct nfsd4_open *open, struct nfs4_stateid **stpp)
+nfs4_check_open(struct nfs4_file *fp, struct nfsd4_open *open, struct nfs4_stateid **stpp)
 {
 	struct nfs4_stateid *local;
 	int status = nfserr_share_denied;
+	struct nfs4_stateowner *sop = open->op_stateowner;
 
 	list_for_each_entry(local, &fp->fi_perfile, st_perfile) {
 		/* ignore lock owners */
@@ -1692,7 +1694,6 @@ out:
 int
 nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_open *open)
 {
-	struct nfs4_stateowner *sop = open->op_stateowner;
 	struct nfs4_file *fp = NULL;
 	struct inode *ino = current_fh->fh_dentry->d_inode;
 	struct nfs4_stateid *stp = NULL;
@@ -1708,7 +1709,7 @@ nfsd4_process_open2(struct svc_rqst *rqs
 	 */
 	fp = find_file(ino);
 	if (fp) {
-		if ((status = nfs4_check_open(fp, sop, open, &stp)))
+		if ((status = nfs4_check_open(fp, open, &stp)))
 			goto out;
 	} else {
 		status = nfserr_resource;
@@ -1735,7 +1736,7 @@ nfsd4_process_open2(struct svc_rqst *rqs
 			flags = MAY_READ;
 		if ((status = nfs4_new_open(rqstp, &stp, current_fh, flags)))
 			goto out;
-		init_stateid(stp, fp, sop, open);
+		init_stateid(stp, fp, open);
 		if (open->op_truncate) {
 			struct iattr iattr = {
 				.ia_valid = ATTR_SIZE,


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

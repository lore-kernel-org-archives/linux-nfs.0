From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 7 of 16] nfsd4: factor out common open_truncate code
Date: Tue, 22 Mar 2005 16:42:01 +1100
Message-ID: <E1DDc9R-0002KW-K0@notabene.cse.unsw.edu.au>
References: <20050322163830.8762.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DDcA1-0006lq-UA
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 21:42:37 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DDc9z-00059w-Oc
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


Factor out a bit of common code.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   46 +++++++++++++++++++++++-----------------------
 1 files changed, 23 insertions(+), 23 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-03-22 16:36:35.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2005-03-22 16:36:35.000000000 +1100
@@ -1575,6 +1575,21 @@ nfs4_new_open(struct svc_rqst *rqstp, st
 	return 0;
 }
 
+static inline int
+nfsd4_truncate(struct svc_rqst *rqstp, struct svc_fh *fh,
+		struct nfsd4_open *open)
+{
+	struct iattr iattr = {
+		.ia_valid = ATTR_SIZE,
+		.ia_size = 0,
+	};
+	if (!open->op_truncate)
+		return 0;
+	if (!(open->op_share_access & NFS4_SHARE_ACCESS_WRITE))
+		return -EINVAL;
+	return nfsd_setattr(rqstp, fh, &iattr, 0, (time_t)0);
+}
+
 static int
 nfs4_upgrade_open(struct svc_rqst *rqstp, struct svc_fh *cur_fh, struct nfs4_stateid *stp, struct nfsd4_open *open)
 {
@@ -1592,19 +1607,11 @@ nfs4_upgrade_open(struct svc_rqst *rqstp
 		status = get_write_access(inode);
 		if (status)
 			return nfserrno(status);
-		if (open->op_truncate) {
-			struct iattr iattr = {
-				.ia_valid = ATTR_SIZE,
-				.ia_size = 0,
-			};
-			status = nfsd_setattr(rqstp, cur_fh, &iattr, 0,
-					(time_t)0);
-			if (status) {
-				put_write_access(inode);
-				return status;
-			}
+		status = nfsd4_truncate(rqstp, cur_fh, open);
+		if (status) {
+			put_write_access(inode);
+			return status;
 		}
-
 		/* remember the open */
 		filp->f_mode = (filp->f_mode | FMODE_WRITE) & ~FMODE_READ;
 		set_bit(open->op_share_access, &stp->st_access_bmap);
@@ -1737,17 +1744,10 @@ nfsd4_process_open2(struct svc_rqst *rqs
 		if ((status = nfs4_new_open(rqstp, &stp, current_fh, flags)))
 			goto out;
 		init_stateid(stp, fp, open);
-		if (open->op_truncate) {
-			struct iattr iattr = {
-				.ia_valid = ATTR_SIZE,
-				.ia_size = 0,
-			};
-			status = nfsd_setattr(rqstp, current_fh, &iattr, 0,
-					(time_t)0);
-			if (status) {
-				release_stateid(stp, OPEN_STATE);
-				goto out;
-			}
+		status = nfsd4_truncate(rqstp, current_fh, open);
+		if (status) {
+			release_stateid(stp, OPEN_STATE);
+			goto out;
 		}
 	}
 	memcpy(&open->op_stateid, &stp->st_stateid, sizeof(stateid_t));


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

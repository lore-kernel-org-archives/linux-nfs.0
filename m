From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 8 of 16] nfsd4: fix failure to truncate on some opens
Date: Tue, 22 Mar 2005 16:42:01 +1100
Message-ID: <E1DDc9R-0002Ka-Lu@notabene.cse.unsw.edu.au>
References: <20050322163830.8762.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DDc9c-0006kl-Pc
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 21:42:12 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DDc9b-00056L-JC
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 21:42:12 -0800
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


An OPEN upgrade on a file already open for WRITE will not upgrade the OPEN,
but can still truncate the file.

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   29 +++++++++++++++--------------
 1 files changed, 15 insertions(+), 14 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-03-22 16:36:35.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2005-03-22 16:36:35.000000000 +1100
@@ -1602,21 +1602,22 @@ nfs4_upgrade_open(struct svc_rqst *rqstp
 	share_access = ~share_access;
 	share_access &= open->op_share_access;
 
-	/* update the struct file */
-	if (share_access & NFS4_SHARE_ACCESS_WRITE) {
-		status = get_write_access(inode);
-		if (status)
-			return nfserrno(status);
-		status = nfsd4_truncate(rqstp, cur_fh, open);
-		if (status) {
-			put_write_access(inode);
-			return status;
-		}
-		/* remember the open */
-		filp->f_mode = (filp->f_mode | FMODE_WRITE) & ~FMODE_READ;
-		set_bit(open->op_share_access, &stp->st_access_bmap);
-		set_bit(open->op_share_deny, &stp->st_deny_bmap);
+	if (!(share_access & NFS4_SHARE_ACCESS_WRITE))
+		return nfsd4_truncate(rqstp, cur_fh, open);
+
+	status = get_write_access(inode);
+	if (status)
+		return nfserrno(status);
+	status = nfsd4_truncate(rqstp, cur_fh, open);
+	if (status) {
+		put_write_access(inode);
+		return status;
 	}
+	/* remember the open */
+	filp->f_mode = (filp->f_mode | FMODE_WRITE) & ~FMODE_READ;
+	set_bit(open->op_share_access, &stp->st_access_bmap);
+	set_bit(open->op_share_deny, &stp->st_deny_bmap);
+
 	return nfs_ok;
 }
 


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

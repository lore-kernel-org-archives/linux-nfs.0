From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 41 of 54] nfsd4: remove st_vfs_file checks
Date: Tue, 08 Mar 2005 17:06:45 +1100
Message-ID: <E1D8Xrh-00019T-1y@notabene.cse.unsw.edu.au>
References: <20050308165419.3842.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8Xrr-000281-9m
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:55 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1D8Xrp-0007tS-Bg
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:55 -0800
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


The st_vfs_file field *must* be non-NULL as long as the stateid is in use, so
there's no point testing for it, unless we want to just BUG().  But since we'd
immediately hit a NULL dereference in every case, there's no need even for
that.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   13 +++++--------
 1 files changed, 5 insertions(+), 8 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-03-07 13:28:51.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2005-03-07 13:29:30.000000000 +1100
@@ -1171,7 +1171,7 @@ release_stateid(struct nfs4_stateid *stp
 	list_del_perfile++;
 	list_del(&stp->st_perfile);
 	list_del(&stp->st_perfilestate);
-	if ((stp->st_vfs_file) && (flags & OPEN_STATE)) {
+	if (flags & OPEN_STATE) {
 		list_for_each_entry(dp, &fp->fi_del_perfile, dl_del_perfile) {
 			if(cmp_clid(&dp->dl_client->cl_clientid,
 			    &stp->st_stateowner->so_client->cl_clientid)) {
@@ -1182,7 +1182,7 @@ release_stateid(struct nfs4_stateid *stp
 		release_stateid_lockowners(stp);
 		nfsd_close(stp->st_vfs_file);
 		vfsclose++;
-	} else if ((stp->st_vfs_file) && (flags & LOCK_STATE)) {
+	} else if (flags & LOCK_STATE) {
 		struct file *filp = stp->st_vfs_file;
 
 		locks_remove_posix(filp, (fl_owner_t) stp->st_stateowner);
@@ -1921,8 +1921,7 @@ find_openstateowner_id(u32 st_id, int fl
 static inline int
 nfs4_check_fh(struct svc_fh *fhp, struct nfs4_stateid *stp)
 {
-	return (stp->st_vfs_file == NULL ||
-		fhp->fh_dentry->d_inode != stp->st_vfs_file->f_dentry->d_inode);
+	return fhp->fh_dentry->d_inode != stp->st_vfs_file->f_dentry->d_inode;
 }
 
 static int
@@ -3015,10 +3014,8 @@ nfsd4_release_lockowner(struct svc_rqst 
 		status = nfserr_locks_held;
 		list_for_each_entry(stp, &local->so_perfilestate,
 				st_perfilestate) {
-			if (stp->st_vfs_file) {
-				if (check_for_locks(stp->st_vfs_file, local))
-					goto out;
-			}
+			if (check_for_locks(stp->st_vfs_file, local))
+				goto out;
 		}
 		/* no locks held by (lock) stateowner */
 		status = nfs_ok;


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

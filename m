From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 40 of 54] nfsd4: remove st_vfs_set
Date: Tue, 08 Mar 2005 17:06:44 +1100
Message-ID: <E1D8Xrg-00019P-RN@notabene.cse.unsw.edu.au>
References: <20050308165419.3842.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8Xrt-00028E-2N
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:57 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1D8Xrq-0007tq-VI
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:56 -0800
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



Note st_vfs_set is redundant; we can always just check whether st_vfs_file is
set.

Fix one inconsistency along the way: we were setting st_vfs_file to 0 in one
case without fput()'ing st_vfs_file.  It doesn't appear there was a need to do
either one in that case.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c        |   11 ++++-------
 ./include/linux/nfsd/state.h |    1 -
 2 files changed, 4 insertions(+), 8 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-03-07 13:27:24.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2005-03-07 13:28:51.000000000 +1100
@@ -1171,7 +1171,7 @@ release_stateid(struct nfs4_stateid *stp
 	list_del_perfile++;
 	list_del(&stp->st_perfile);
 	list_del(&stp->st_perfilestate);
-	if ((stp->st_vfs_set) && (flags & OPEN_STATE)) {
+	if ((stp->st_vfs_file) && (flags & OPEN_STATE)) {
 		list_for_each_entry(dp, &fp->fi_del_perfile, dl_del_perfile) {
 			if(cmp_clid(&dp->dl_client->cl_clientid,
 			    &stp->st_stateowner->so_client->cl_clientid)) {
@@ -1182,7 +1182,7 @@ release_stateid(struct nfs4_stateid *stp
 		release_stateid_lockowners(stp);
 		nfsd_close(stp->st_vfs_file);
 		vfsclose++;
-	} else if ((stp->st_vfs_set) && (flags & LOCK_STATE)) {
+	} else if ((stp->st_vfs_file) && (flags & LOCK_STATE)) {
 		struct file *filp = stp->st_vfs_file;
 
 		locks_remove_posix(filp, (fl_owner_t) stp->st_stateowner);
@@ -1586,7 +1586,6 @@ nfs4_new_open(struct svc_rqst *rqstp, st
 		return status;
 	}
 	vfsopen++;
-	stp->st_vfs_set = 1;
 	*stpp = stp;
 	return 0;
 }
@@ -1922,7 +1921,7 @@ find_openstateowner_id(u32 st_id, int fl
 static inline int
 nfs4_check_fh(struct svc_fh *fhp, struct nfs4_stateid *stp)
 {
-	return (stp->st_vfs_set == 0 ||
+	return (stp->st_vfs_file == NULL ||
 		fhp->fh_dentry->d_inode != stp->st_vfs_file->f_dentry->d_inode);
 }
 
@@ -2147,7 +2146,6 @@ nfs4_preprocess_seqid_op(struct svc_fh *
 
 	if ((flags & CHECK_FH) && nfs4_check_fh(current_fh, stp)) {
 		printk("NFSD: preprocess_seqid_op: fh-stateid mismatch!\n");
-		stp->st_vfs_set = 0;
 		goto out;
 	}
 
@@ -2611,7 +2609,6 @@ alloc_init_lock_stateid(struct nfs4_stat
 	stp->st_stateid.si_fileid = fp->fi_id;
 	stp->st_stateid.si_generation = 0;
 	stp->st_vfs_file = open_stp->st_vfs_file; /* FIXME refcount?? */
-	stp->st_vfs_set = open_stp->st_vfs_set;
 	stp->st_access_bmap = open_stp->st_access_bmap;
 	stp->st_deny_bmap = open_stp->st_deny_bmap;
 
@@ -3018,7 +3015,7 @@ nfsd4_release_lockowner(struct svc_rqst 
 		status = nfserr_locks_held;
 		list_for_each_entry(stp, &local->so_perfilestate,
 				st_perfilestate) {
-			if (stp->st_vfs_set) {
+			if (stp->st_vfs_file) {
 				if (check_for_locks(stp->st_vfs_file, local))
 					goto out;
 			}

diff ./include/linux/nfsd/state.h~current~ ./include/linux/nfsd/state.h
--- ./include/linux/nfsd/state.h~current~	2005-03-07 13:25:47.000000000 +1100
+++ ./include/linux/nfsd/state.h	2005-03-07 13:28:51.000000000 +1100
@@ -254,7 +254,6 @@ struct nfs4_stateid {
 	struct nfs4_file            * st_file;
 	stateid_t                     st_stateid;
 	struct file                 * st_vfs_file;
-	int                           st_vfs_set;
 	unsigned long                 st_access_bmap;
 	unsigned long                 st_deny_bmap;
 };


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 13 of 23] Delay nfsd_colse for delegations until reaping
Date: Fri, 17 Dec 2004 16:23:56 +1100
Message-ID: <E1CfAaq-0002eC-Jo@notabene.cse.unsw.edu.au>
References: <20041217162128.9968.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CfAc1-0005BH-6v
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 21:25:09 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CfAby-0006Au-O1
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 21:25:09 -0800
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


Because nfsd_close() can call locks_remove_flock() which removes leases,
delay nfsd_close() for delegations until the delegation is reaped.

Don't release an nfs4_file struct with delegations.

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   21 ++++++++++++++++++---
 1 files changed, 18 insertions(+), 3 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-12-15 12:05:08.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2004-12-15 13:18:49.000000000 +1100
@@ -977,7 +977,7 @@ release_all_files(void)
 		while (!list_empty(&file_hashtbl[i])) {
 			fp = list_entry(file_hashtbl[i].next, struct nfs4_file, fi_hash);
 			/* this should never be more than once... */
-			if (!list_empty(&fp->fi_perfile)) {
+			if (!list_empty(&fp->fi_perfile) || !list_empty(&fp->fi_del_perfile)) {
 				printk("ERROR: release_all_files: file %p is open, creating dangling state !!!\n",fp);
 			}
 			release_file(fp);
@@ -1112,14 +1112,29 @@ init_stateid(struct nfs4_stateid *stp, s
 	__set_bit(open->op_share_deny, &stp->st_deny_bmap);
 }
 
+/*
+* Because nfsd_close() can call locks_remove_flock() which removes leases,
+* delay nfsd_close() for delegations from the nfsd_open() clientid
+* until the delegation is reaped.
+*/
 static void
-release_stateid(struct nfs4_stateid *stp, int flags) {
+release_stateid(struct nfs4_stateid *stp, int flags)
+{
+	struct nfs4_delegation *dp;
+	struct nfs4_file *fp = stp->st_file;
 
 	list_del(&stp->st_hash);
 	list_del_perfile++;
 	list_del(&stp->st_perfile);
 	list_del(&stp->st_perfilestate);
 	if ((stp->st_vfs_set) && (flags & OPEN_STATE)) {
+		list_for_each_entry(dp, &fp->fi_del_perfile, dl_del_perfile) {
+			if(cmp_clid(&dp->dl_client->cl_clientid,
+			    &stp->st_stateowner->so_client->cl_clientid)) {
+				dp->dl_stp = stp;
+				return;
+			}
+		}
 		release_stateid_lockowner(stp);
 		nfsd_close(stp->st_vfs_file);
 		vfsclose++;
@@ -1168,7 +1183,7 @@ release_state_owner(struct nfs4_stateid 
 	if (sop->so_confirmed && list_empty(&sop->so_perfilestate))
 		move_to_close_lru(sop);
 	/* unused nfs4_file's are releseed. XXX slab cache? */
-	if (list_empty(&fp->fi_perfile)) {
+	if (list_empty(&fp->fi_perfile) && list_empty(&fp->fi_del_perfile)) {
 		release_file(fp);
 	}
 }


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 7 of 11 - nfsd-releaselkowner.patch
Date: Fri, 28 May 2004 14:37:31 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1BTZ7b-0008Ec-7A@notabene.cse.unsw.edu.au>
References: <20040528143518.31534.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BUkZp-0006vt-5t
	for nfs@lists.sourceforge.net; Mon, 31 May 2004 04:03:33 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BUkZo-0003Mw-2m
	for nfs@lists.sourceforge.net; Mon, 31 May 2004 04:03:32 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.172.124]) (auth-user neilb) (ident-user Debian-exim)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Fri, 28 May 2004 14:37:31 +1000
To: Andrew Morton <akpm@osdl.org>
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



Fix oops in release_lockowner.
We need to break out to two loops, not just one,
and if the loop finds nothing, 'local' won't be NULL.
So just put the body of the 'if' inside the loop.


From: Andy Adamson <andros@citi.umich.edu>
From: "J. Bruce Fields" <bfields@fieldses.org>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4state.c |   41 ++++++++++++++++++++---------------------
 1 files changed, 20 insertions(+), 21 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-05-28 14:20:00.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2004-05-28 14:22:40.000000000 +1000
@@ -2334,28 +2334,27 @@ nfsd4_release_lockowner(struct svc_rqst 
 
 	/* find the lockowner */
         status = nfs_ok;
-	for (i=0; i < LOCK_HASH_SIZE; i++) {
-		list_for_each_entry(local, &lock_ownerstr_hashtbl[i], so_strhash) {
-			if(cmp_owner_str(local, owner, clid))
-				break;
-		}
-	}
-	if (local) {
-		struct nfs4_stateid *stp;
-
-		/* check for any locks held by any stateid associated with the
-		 * (lock) stateowner */
-		status = nfserr_locks_held;
-		list_for_each_entry(stp, &local->so_perfilestate, st_perfilestate) {
-			if(stp->st_vfs_set) {
-				if (check_for_locks(&stp->st_vfs_file, local))
-					goto out;
+	for (i=0; i < LOCK_HASH_SIZE; i++)
+		list_for_each_entry(local, &lock_ownerstr_hashtbl[i], so_strhash)
+			if(cmp_owner_str(local, owner, clid)) {
+				struct nfs4_stateid *stp;
+
+				/* check for any locks held by any stateid 
+				 * associated with the (lock) stateowner */
+				status = nfserr_locks_held;
+				list_for_each_entry(stp, &local->so_perfilestate,
+						    st_perfilestate) {
+					if(stp->st_vfs_set) {
+						if (check_for_locks(&stp->st_vfs_file,
+								    local))
+							goto out;
+					}
+				}
+				/* no locks held by (lock) stateowner */
+				status = nfs_ok;
+				release_stateowner(local);
+				goto out;
 			}
-		}
-		/* no locks held by (lock) stateowner */
-		status = nfs_ok;
-		release_stateowner(local);
-	}
 out:
 	nfs4_unlock_state();
 	return status;


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

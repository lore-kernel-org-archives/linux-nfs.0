From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 3 of 9] Simplify nfsd4_release_lockowner
Date: Thu, 24 Jun 2004 14:46:51 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1BdM8R-0001Lh-PS@notabene.cse.unsw.edu.au>
References: <20040624143710.5086.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BdM8u-00025p-BQ
	for nfs@lists.sourceforge.net; Wed, 23 Jun 2004 21:47:20 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BdM8r-0007Ep-Q8
	for nfs@lists.sourceforge.net; Wed, 23 Jun 2004 21:47:17 -0700
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



Simplify nfsd4_release_lockowner a bit, factor out code that we need for
another patch.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>         
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   55 ++++++++++++++++++++++++++++++--------------------
 1 files changed, 33 insertions(+), 22 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-06-23 14:37:06.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2004-06-23 14:37:30.000000000 +1000
@@ -1850,6 +1850,21 @@ nfs4_set_lock_denied(struct file_lock *f
 		deny->ld_type = NFS4_WRITE_LT;
 }
 
+static struct nfs4_stateowner *
+find_lockstateowner(struct xdr_netobj *owner, clientid_t *clid)
+{
+	struct nfs4_stateowner *local = NULL;
+	int i;
+
+	for (i = 0; i < LOCK_HASH_SIZE; i++) {
+		list_for_each_entry(local, &lock_ownerid_hashtbl[i], so_idhash) {
+			if(!cmp_owner_str(local, owner, clid))
+				continue;
+			return local;
+		}
+	}
+	return NULL;
+}
 
 static int
 find_lockstateowner_str(unsigned int hashval, struct xdr_netobj *owner, clientid_t *clid, struct nfs4_stateowner **op) {
@@ -2315,7 +2330,7 @@ nfsd4_release_lockowner(struct svc_rqst 
 	clientid_t *clid = &rlockowner->rl_clientid;
 	struct nfs4_stateowner *local = NULL;
 	struct xdr_netobj *owner = &rlockowner->rl_owner;
-	int status, i;
+	int status;
 
 	dprintk("nfsd4_release_lockowner clientid: (%08x/%08x):\n",
 		clid->cl_boot, clid->cl_id);
@@ -2330,29 +2345,25 @@ nfsd4_release_lockowner(struct svc_rqst 
 
 	nfs4_lock_state();
 
-	/* find the lockowner */
         status = nfs_ok;
-	for (i=0; i < LOCK_HASH_SIZE; i++)
-		list_for_each_entry(local, &lock_ownerstr_hashtbl[i], so_strhash)
-			if(cmp_owner_str(local, owner, clid)) {
-				struct nfs4_stateid *stp;
-
-				/* check for any locks held by any stateid
-				 * associated with the (lock) stateowner */
-				status = nfserr_locks_held;
-				list_for_each_entry(stp, &local->so_perfilestate,
-						    st_perfilestate) {
-					if(stp->st_vfs_set) {
-						if (check_for_locks(&stp->st_vfs_file,
-								    local))
-							goto out;
-					}
-				}
-				/* no locks held by (lock) stateowner */
-				status = nfs_ok;
-				release_stateowner(local);
-				goto out;
+	local = find_lockstateowner(owner, clid);
+	if (local) {
+		struct nfs4_stateid *stp;
+
+		/* check for any locks held by any stateid
+		 * associated with the (lock) stateowner */
+		status = nfserr_locks_held;
+		list_for_each_entry(stp, &local->so_perfilestate,
+				st_perfilestate) {
+			if(stp->st_vfs_set) {
+				if (check_for_locks(&stp->st_vfs_file, local))
+					goto out;
 			}
+		}
+		/* no locks held by (lock) stateowner */
+		status = nfs_ok;
+		release_stateowner(local);
+	}
 out:
 	nfs4_unlock_state();
 	return status;


-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

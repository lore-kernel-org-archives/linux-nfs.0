From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] kNFSdv4 - 6 of 10 - Keep state to allow replays for 'close' to work.
Date: Thu, 8 Apr 2004 17:23:02 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040408212302.GA18744@fieldses.org>
References: <20040408111135.5397.patches@notabene> <E1BBOBq-0001Qt-Ka@notabene.cse.unsw.edu.au> <20040407234541.7f2bb6d3.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NeilBrown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BBgzT-0002Ij-2M
	for nfs@lists.sourceforge.net; Thu, 08 Apr 2004 14:23:15 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net
	([66.93.2.214] helo=pumpkin.fieldses.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BBgzS-0000F5-77
	for nfs@lists.sourceforge.net; Thu, 08 Apr 2004 14:23:14 -0700
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20040407234541.7f2bb6d3.akpm@osdl.org>
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

On Wed, Apr 07, 2004 at 11:45:41PM -0700, Andrew Morton wrote:
> NeilBrown <neilb@cse.unsw.edu.au> wrote:
> >
> > +	dprintk("NFSD: find_openstateowner_id %d\n", st_id);
> >  +	if (flags & CLOSE_STATE) {
> >  +		list_for_each_safe(pos, next, &close_lru) {
> >  +			local = list_entry(pos, struct nfs4_stateowner, 
> >  +			                    so_close_lru);
> >  +			if(local->so_id == st_id)
> >  +				return local;
> >  +		}
> >   	}
> 
> list_for_each() is adequate here.  list_for_each_safe() is only needed if
> you're removing things from the list inside the body of the loop.

Someone was very fond of list_for_each_safe().  The following (applies
on top of the above) removes all the list_for_each_safe()'s in
nfs4state.c except for the two that were actually needed.

> The locking in here is, err, a little coarse-grained?

Yeah, everything on the server that deals with nfsv4 open and locking
state takes a single big semaphore.  We should fix that some day.

--b.


 fs/nfsd/nfs4state.c |   70 +++++++++++++---------------------------------------
 1 files changed, 18 insertions(+), 52 deletions(-)

diff -puN fs/nfs/nfs4state.c~nfsd_list_cleanup fs/nfs/nfs4state.c
diff -puN fs/nfsd/nfs4state.c~nfsd_list_cleanup fs/nfsd/nfs4state.c
--- linux-2.6.5-rc2/fs/nfsd/nfs4state.c~nfsd_list_cleanup	2004-04-08 16:37:53.000000000 -0400
+++ linux-2.6.5-rc2-bfields/fs/nfsd/nfs4state.c	2004-04-08 16:38:30.000000000 -0400
@@ -380,7 +380,6 @@ nfsd4_setclientid(struct svc_rqst *rqstp
 	unsigned int 		strhashval;
 	struct nfs4_client *	conf, * unconf, * new, * clp;
 	int 			status;
-	struct list_head *pos, *next;
 	
 	status = nfserr_inval;
 	if (!check_name(clname))
@@ -395,8 +394,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp
 
 	conf = NULL;
 	nfs4_lock_state();
-	list_for_each_safe(pos, next, &conf_str_hashtbl[strhashval]) {
-		clp = list_entry(pos, struct nfs4_client, cl_strhash);
+	list_for_each_entry(clp, &conf_str_hashtbl[strhashval], cl_strhash) {
 		if (!cmp_name(&clp->cl_name, &clname))
 			continue;
 		/* 
@@ -426,8 +424,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp
 		break;
 	}
 	unconf = NULL;
-	list_for_each_safe(pos, next, &unconf_str_hashtbl[strhashval]) {
-		clp = list_entry(pos, struct nfs4_client, cl_strhash);
+	list_for_each_entry(clp, &unconf_str_hashtbl[strhashval], cl_strhash) {
 		if (!cmp_name(&clp->cl_name, &clname))
 			continue;
 		/* cl_name match from a previous SETCLIENTID operation */
@@ -553,7 +550,6 @@ nfsd4_setclientid_confirm(struct svc_rqs
 	struct nfs4_client *clp, *conf = NULL, *unconf = NULL;
 	nfs4_verifier confirm = setclientid_confirm->sc_confirm; 
 	clientid_t * clid = &setclientid_confirm->sc_clientid;
-	struct list_head *pos, *next;
 	int status;
 
 	status = nfserr_stale_clientid;
@@ -566,8 +562,7 @@ nfsd4_setclientid_confirm(struct svc_rqs
 
 	idhashval = clientid_hashval(clid->cl_id);
 	nfs4_lock_state();
-	list_for_each_safe(pos, next, &conf_id_hashtbl[idhashval]) {
-		clp = list_entry(pos, struct nfs4_client, cl_idhash);
+	list_for_each_entry(clp, &conf_id_hashtbl[idhashval], cl_idhash) {
 		if (!cmp_clid(&clp->cl_clientid, clid))
 			continue;
 
@@ -586,8 +581,7 @@ nfsd4_setclientid_confirm(struct svc_rqs
 		conf = clp;
 		break;
 	}
-	list_for_each_safe(pos, next, &unconf_id_hashtbl[idhashval]) {
-		clp = list_entry(pos, struct nfs4_client, cl_idhash);
+	list_for_each_entry(clp, &unconf_id_hashtbl[idhashval], cl_idhash) {
 		if (!cmp_clid(&clp->cl_clientid, clid))
 			continue;
 		status = nfserr_inval;
@@ -933,11 +927,9 @@ cmp_owner_str(struct nfs4_stateowner *so
 /* search ownerstr_hashtbl[] for owner */
 static int
 find_openstateowner_str(unsigned int hashval, struct nfsd4_open *open, struct nfs4_stateowner **op) {
-	struct list_head *pos, *next;
 	struct nfs4_stateowner *local = NULL;
 
-	list_for_each_safe(pos, next, &ownerstr_hashtbl[hashval]) {
-		local = list_entry(pos, struct nfs4_stateowner, so_strhash);
+	list_for_each_entry(local, &ownerstr_hashtbl[hashval], so_strhash) {
 		if(!cmp_owner_str(local, &open->op_owner, &open->op_clientid)) 
 			continue;
 		*op = local;
@@ -950,12 +942,10 @@ find_openstateowner_str(unsigned int has
 static int
 verify_clientid(struct nfs4_client **client, clientid_t *clid) {
 
-	struct list_head *pos, *next;
 	struct nfs4_client *clp;
 	unsigned int idhashval = clientid_hashval(clid->cl_id);
 
-	list_for_each_safe(pos, next, &conf_id_hashtbl[idhashval]) {
-		clp = list_entry(pos, struct nfs4_client, cl_idhash);
+	list_for_each_entry(clp, &conf_id_hashtbl[idhashval], cl_idhash) {
 		if (!cmp_clid(&clp->cl_clientid, clid))
 			continue;
 		*client = clp;
@@ -968,11 +958,9 @@ verify_clientid(struct nfs4_client **cli
 /* search file_hashtbl[] for file */
 static int
 find_file(unsigned int hashval, struct inode *ino, struct nfs4_file **fp) {
-	struct list_head *pos, *next;
 	struct nfs4_file *local = NULL;
 
-	list_for_each_safe(pos, next, &file_hashtbl[hashval]) {
-		local = list_entry(pos, struct nfs4_file, fi_hash);
+	list_for_each_entry(local, &file_hashtbl[hashval], fi_hash) {
 		if (local->fi_inode == ino) {
 			*fp = local;
 			return(1);
@@ -1028,15 +1016,13 @@ nfs4_share_conflict(struct svc_fh *curre
 	unsigned int fi_hashval;
 	struct nfs4_file *fp;
 	struct nfs4_stateid *stp;
-	struct list_head *pos, *next;
 
 	dprintk("NFSD: nfs4_share_conflict\n");
 
 	fi_hashval = file_hashval(ino);
 	if (find_file(fi_hashval, ino, &fp)) {
 	/* Search for conflicting share reservations */
-		list_for_each_safe(pos, next, &fp->fi_perfile) {
-			stp = list_entry(pos, struct nfs4_stateid, st_perfile);
+		list_for_each_entry(stp, &fp->fi_perfile, st_perfile) {
 			if (test_bit(deny_type, &stp->st_deny_bmap) ||
 			    test_bit(NFS4_SHARE_DENY_BOTH, &stp->st_deny_bmap))
 				return nfserr_share_denied;
@@ -1171,7 +1157,6 @@ nfsd4_process_open2(struct svc_rqst *rqs
 	struct nfs4_file *fp;
 	struct inode *ino;
 	unsigned int fi_hashval;
-	struct list_head *pos, *next;
 	struct nfs4_stateid *stq, *stp = NULL;
 	int status;
 
@@ -1190,8 +1175,7 @@ nfsd4_process_open2(struct svc_rqst *rqs
 	if (find_file(fi_hashval, ino, &fp)) {
 		/* Search for conflicting share reservations */
 		status = nfserr_share_denied;
-		list_for_each_safe(pos, next, &fp->fi_perfile) {
-		stq = list_entry(pos, struct nfs4_stateid, st_perfile);
+		list_for_each_entry(stq, &fp->fi_perfile, st_perfile) {
 			if(stq->st_stateowner == sop) {
 				stp = stq;
 				continue;
@@ -1291,7 +1275,6 @@ int 
 nfsd4_renew(clientid_t *clid)
 {
 	struct nfs4_client *clp;
-	struct list_head *pos, *next;
 	unsigned int idhashval;
 	int status;
 
@@ -1303,15 +1286,13 @@ nfsd4_renew(clientid_t *clid)
 		goto out;
 	status = nfs_ok;
 	idhashval = clientid_hashval(clid->cl_id);
-	list_for_each_safe(pos, next, &conf_id_hashtbl[idhashval]) {
-		clp = list_entry(pos, struct nfs4_client, cl_idhash);
+	list_for_each_entry(clp, &conf_id_hashtbl[idhashval], cl_idhash) {
 		if (!cmp_clid(&clp->cl_clientid, clid))
 			continue;
 		renew_client(clp);
 		goto out;
 	}
-	list_for_each_safe(pos, next, &unconf_id_hashtbl[idhashval]) {
-		clp = list_entry(pos, struct nfs4_client, cl_idhash);
+	list_for_each_entry(clp, &unconf_id_hashtbl[idhashval], cl_idhash) {
 		if (!cmp_clid(&clp->cl_clientid, clid))
 			continue;
 		renew_client(clp);
@@ -1387,14 +1368,11 @@ laundromat_main(void *not_used)
  */
 struct nfs4_stateowner *
 find_openstateowner_id(u32 st_id, int flags) {
-	struct list_head *pos, *next;
 	struct nfs4_stateowner *local = NULL;
 
 	dprintk("NFSD: find_openstateowner_id %d\n", st_id);
 	if (flags & CLOSE_STATE) {
-		list_for_each_safe(pos, next, &close_lru) {
-			local = list_entry(pos, struct nfs4_stateowner, 
-			                    so_close_lru);
+		list_for_each_entry(local, &close_lru, so_close_lru) {
 			if(local->so_id == st_id)
 				return local;
 		}
@@ -1767,7 +1745,6 @@ static struct list_head lockstateid_hash
 struct nfs4_stateid *
 find_stateid(stateid_t *stid, int flags)
 {
-	struct list_head *pos, *next;
 	struct nfs4_stateid *local = NULL;
 	u32 st_id = stid->si_stateownerid;
 	u32 f_id = stid->si_fileid;
@@ -1776,8 +1753,7 @@ find_stateid(stateid_t *stid, int flags)
 	dprintk("NFSD: find_stateid flags 0x%x\n",flags);
 	if ((flags & LOCK_STATE) || (flags & RDWR_STATE)) {
 		hashval = stateid_hashval(st_id, f_id);
-		list_for_each_safe(pos, next, &lockstateid_hashtbl[hashval]) {
-			local = list_entry(pos, struct nfs4_stateid, st_hash);
+		list_for_each_entry(local, &lockstateid_hashtbl[hashval], st_hash) {
 			if((local->st_stateid.si_stateownerid == st_id) &&
 			   (local->st_stateid.si_fileid == f_id))
 				return local;
@@ -1785,8 +1761,7 @@ find_stateid(stateid_t *stid, int flags)
 	} 
 	if ((flags & OPEN_STATE) || (flags & RDWR_STATE)) {
 		hashval = stateid_hashval(st_id, f_id);
-		list_for_each_safe(pos, next, &stateid_hashtbl[hashval]) {
-			local = list_entry(pos, struct nfs4_stateid, st_hash);
+		list_for_each_entry(local, &stateid_hashtbl[hashval], st_hash) {
 			if((local->st_stateid.si_stateownerid == st_id) &&
 			   (local->st_stateid.si_fileid == f_id))
 				return local;
@@ -1817,14 +1792,12 @@ nfs4_transform_lock_offset(struct file_l
 int
 nfs4_verify_lock_stateowner(struct nfs4_stateowner *sop, unsigned int hashval)
 {
-	struct list_head *pos, *next;
 	struct nfs4_stateowner *local = NULL;
 	int status = 0;
 			        
 	if (hashval >= LOCK_HASH_SIZE)
 		goto out;
-	list_for_each_safe(pos, next, &lock_ownerid_hashtbl[hashval]) {
-		local = list_entry(pos, struct nfs4_stateowner, so_idhash);
+	list_for_each_entry(local, &lock_ownerid_hashtbl[hashval], so_idhash) {
 		if (local == sop) {
 			status = 1;
 			goto out;
@@ -1855,11 +1828,9 @@ nfs4_set_lock_denied(struct file_lock *f
 
 static int
 find_lockstateowner_str(unsigned int hashval, struct xdr_netobj *owner, clientid_t *clid, struct nfs4_stateowner **op) {
-	struct list_head *pos, *next;
 	struct nfs4_stateowner *local = NULL;
 
-	list_for_each_safe(pos, next, &lock_ownerstr_hashtbl[hashval]) {
-		local = list_entry(pos, struct nfs4_stateowner, so_strhash);
+	list_for_each_entry(local, &lock_ownerstr_hashtbl[hashval], so_strhash) {
 		if(!cmp_owner_str(local, owner, clid)) 
 			continue;
 		*op = local;
@@ -2305,7 +2276,6 @@ int
 nfsd4_release_lockowner(struct svc_rqst *rqstp, struct nfsd4_release_lockowner *rlockowner)
 {
 	clientid_t *clid = &rlockowner->rl_clientid;
-	struct list_head *pos, *next;
 	struct nfs4_stateowner *local = NULL;
 	struct xdr_netobj *owner = &rlockowner->rl_owner;
 	int status, i;
@@ -2326,9 +2296,7 @@ nfsd4_release_lockowner(struct svc_rqst 
 	/* find the lockowner */
         status = nfs_ok;
 	for (i=0; i < LOCK_HASH_SIZE; i++) {
-		list_for_each_safe(pos, next, &lock_ownerstr_hashtbl[i]) {
-			local = list_entry(pos, struct nfs4_stateowner,
-						so_strhash);
+		list_for_each_entry(local, &lock_ownerstr_hashtbl[i], so_strhash) {
 			if(cmp_owner_str(local, owner, clid))
 				break;
 		}
@@ -2339,9 +2307,7 @@ nfsd4_release_lockowner(struct svc_rqst 
 		/* check for any locks held by any stateid associated with the
 		 * (lock) stateowner */
 		status = nfserr_locks_held;
-		list_for_each_safe(pos, next, &local->so_perfilestate) {
-			stp = list_entry(pos, struct nfs4_stateid,
-					                    st_perfilestate);
+		list_for_each_entry(stp, &local->so_perfilestate, st_perfilestate) {
 			if(stp->st_vfs_set) {
 				if (check_for_locks(&stp->st_vfs_file, local))
 					goto out;

_


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

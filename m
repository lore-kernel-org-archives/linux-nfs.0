From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 5 of 9] trivial cleanup of nfs4state.c
Date: Fri, 03 Sep 2004 12:34:26 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1C33uE-000432-BY@notabene.cse.unsw.edu.au>
References: <20040903122815.15453.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C33uP-00005B-9H
	for nfs@lists.sourceforge.net; Thu, 02 Sep 2004 19:34:37 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1C33uO-0007KV-0w
	for nfs@lists.sourceforge.net; Thu, 02 Sep 2004 19:34:37 -0700
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


Whitespace cleanup, fix one dprintk, remove superfluous casts of NULL.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   72 +++++++++++++++++++++++++-------------------------
 1 files changed, 36 insertions(+), 36 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-09-03 11:56:48.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2004-09-03 11:57:20.000000000 +1000
@@ -236,7 +236,7 @@ static struct nfs4_client *
 create_client(struct xdr_netobj name) {
 	struct nfs4_client *clp;
 
-	if(!(clp = alloc_client(name)))
+	if (!(clp = alloc_client(name)))
 		goto out;
 	INIT_LIST_HEAD(&clp->cl_idhash);
 	INIT_LIST_HEAD(&clp->cl_strhash);
@@ -268,7 +268,7 @@ copy_cred(struct svc_cred *target, struc
 
 static int
 cmp_name(struct xdr_netobj *n1, struct xdr_netobj *n2) {
-	if(!n1 || !n2)
+	if (!n1 || !n2)
 		return 0;
 	return((n1->len == n2->len) && !memcmp(n1->data, n2->data, n2->len));
 }
@@ -399,7 +399,7 @@ parse_ipv4(unsigned int addr_len, char *
 			return 0;
 		}
 		cbaddr |= (temp << shift);
-		if(shift > 0)
+		if (shift > 0)
 		shift -= 8;
 	}
 	*cbaddrp = cbaddr;
@@ -411,7 +411,7 @@ parse_ipv4(unsigned int addr_len, char *
 			return 0;
 		}
 		cbport |= (temp << shift);
-		if(shift > 0)
+		if (shift > 0)
 			shift -= 8;
 	}
 	*cbportp = cbport;
@@ -423,7 +423,7 @@ gen_callback(struct nfs4_client *clp, st
 {
 	struct nfs4_callback *cb = &clp->cl_callback;
 
-	if( !(parse_ipv4(se->se_callback_addr_len, se->se_callback_addr_val,
+	if ( !(parse_ipv4(se->se_callback_addr_len, se->se_callback_addr_val,
 		         &cb->cb_addr, &cb->cb_port))) {
 		printk(KERN_INFO "NFSD: BAD callback address. client will not receive delegations\n");
 		cb->cb_parsed = 0;
@@ -431,9 +431,9 @@ gen_callback(struct nfs4_client *clp, st
 	}
 	cb->cb_netid.len = se->se_callback_netid_len;
 	cb->cb_netid.data = se->se_callback_netid_val;
-        cb->cb_prog = se->se_callback_prog;
-        cb->cb_ident = se->se_callback_ident;
-        cb->cb_parsed = 1;
+	cb->cb_prog = se->se_callback_prog;
+	cb->cb_ident = se->se_callback_ident;
+	cb->cb_parsed = 1;
 }
 
 /*
@@ -812,7 +812,7 @@ alloc_init_file(unsigned int hashval, st
 		alloc_file++;
 		return fp;
 	}
-	return (struct nfs4_file *)NULL;
+	return NULL;
 }
 
 static void
@@ -825,7 +825,7 @@ release_all_files(void)
 		while (!list_empty(&file_hashtbl[i])) {
 			fp = list_entry(file_hashtbl[i].next, struct nfs4_file, fi_hash);
 			/* this should never be more than once... */
-			if(!list_empty(&fp->fi_perfile)) {
+			if (!list_empty(&fp->fi_perfile)) {
 				printk("ERROR: release_all_files: file %p is open, creating dangling state !!!\n",fp);
 			}
 			release_file(fp);
@@ -839,20 +839,20 @@ alloc_stateowner(struct xdr_netobj *owne
 	struct nfs4_stateowner *sop;
 
 	if ((sop = kmalloc(sizeof(struct nfs4_stateowner),GFP_KERNEL))) {
-		if((sop->so_owner.data = kmalloc(owner->len, GFP_KERNEL))) {
+		if ((sop->so_owner.data = kmalloc(owner->len, GFP_KERNEL))) {
 			memcpy(sop->so_owner.data, owner->data, owner->len);
 			sop->so_owner.len = owner->len;
 			return sop;
 		} 
 		kfree(sop);
 	}
-	return (struct nfs4_stateowner *)NULL;
+	return NULL;
 }
 
 /* should use a slab cache */
 static void
 free_stateowner(struct nfs4_stateowner *sop) {
-	if(sop) {
+	if (sop) {
 		kfree(sop->so_owner.data);
 		kfree(sop);
 		sop = NULL;
@@ -867,7 +867,7 @@ alloc_init_open_stateowner(unsigned int 
 	unsigned int idhashval;
 
 	if (!(sop = alloc_stateowner(&open->op_owner)))
-		return (struct nfs4_stateowner *)NULL;
+		return NULL;
 	idhashval = ownerid_hashval(current_ownerid);
 	INIT_LIST_HEAD(&sop->so_idhash);
 	INIT_LIST_HEAD(&sop->so_strhash);
@@ -921,7 +921,7 @@ release_stateowner(struct nfs4_stateowne
 	while (!list_empty(&sop->so_perfilestate)) {
 		stp = list_entry(sop->so_perfilestate.next, 
 			struct nfs4_stateid, st_perfilestate);
-		if(sop->so_is_open_owner)
+		if (sop->so_is_open_owner)
 			release_stateid(stp, OPEN_STATE);
 		else
 			release_stateid(stp, LOCK_STATE);
@@ -960,7 +960,7 @@ release_stateid(struct nfs4_stateid *stp
 	list_del_perfile++;
 	list_del(&stp->st_perfile);
 	list_del(&stp->st_perfilestate);
-	if((stp->st_vfs_set) && (flags & OPEN_STATE)) {
+	if ((stp->st_vfs_set) && (flags & OPEN_STATE)) {
 		release_stateid_lockowner(stp);
 		nfsd_close(stp->st_vfs_file);
 		vfsclose++;
@@ -991,8 +991,8 @@ move_to_close_lru(struct nfs4_stateowner
 	list_del_init(&sop->so_strhash);
 	list_del_init(&sop->so_perlockowner);
 
-        list_add_tail(&sop->so_close_lru, &close_lru);
-        sop->so_time = get_seconds();
+	list_add_tail(&sop->so_close_lru, &close_lru);
+	sop->so_time = get_seconds();
 }
 
 void
@@ -1030,7 +1030,7 @@ find_openstateowner_str(unsigned int has
 	struct nfs4_stateowner *local = NULL;
 
 	list_for_each_entry(local, &ownerstr_hashtbl[hashval], so_strhash) {
-		if(!cmp_owner_str(local, &open->op_owner, &open->op_clientid)) 
+		if (!cmp_owner_str(local, &open->op_owner, &open->op_clientid))
 			continue;
 		*op = local;
 		return(1);
@@ -1078,7 +1078,7 @@ set_access(unsigned int *access, unsigne
 
 	*access = 0;
 	for (i = 1; i < 4; i++) {
-		if(test_bit(i, &bmap))
+		if (test_bit(i, &bmap))
 			*access |= i;
 	}
 }
@@ -1089,7 +1089,7 @@ set_deny(unsigned int *deny, unsigned lo
 
 	*deny = 0;
 	for (i = 0; i < 4; i++) {
-		if(test_bit(i, &bmap))
+		if (test_bit(i, &bmap))
 			*deny |= i ;
 	}
 }
@@ -1278,7 +1278,7 @@ nfsd4_process_open2(struct svc_rqst *rqs
 		/* Search for conflicting share reservations */
 		status = nfserr_share_denied;
 		list_for_each_entry(stq, &fp->fi_perfile, st_perfile) {
-			if(stq->st_stateowner == sop) {
+			if (stq->st_stateowner == sop) {
 				stp = stq;
 				continue;
 			}
@@ -1484,7 +1484,7 @@ find_openstateowner_id(u32 st_id, int fl
 	dprintk("NFSD: find_openstateowner_id %d\n", st_id);
 	if (flags & CLOSE_STATE) {
 		list_for_each_entry(local, &close_lru, so_close_lru) {
-			if(local->so_id == st_id)
+			if (local->so_id == st_id)
 				return local;
 		}
 	}
@@ -1888,16 +1888,16 @@ find_stateid(stateid_t *stid, int flags)
 	if ((flags & LOCK_STATE) || (flags & RDWR_STATE)) {
 		hashval = stateid_hashval(st_id, f_id);
 		list_for_each_entry(local, &lockstateid_hashtbl[hashval], st_hash) {
-			if((local->st_stateid.si_stateownerid == st_id) &&
-			   (local->st_stateid.si_fileid == f_id))
+			if ((local->st_stateid.si_stateownerid == st_id) &&
+			    (local->st_stateid.si_fileid == f_id))
 				return local;
 		}
 	} 
 	if ((flags & OPEN_STATE) || (flags & RDWR_STATE)) {
 		hashval = stateid_hashval(st_id, f_id);
 		list_for_each_entry(local, &stateid_hashtbl[hashval], st_hash) {
-			if((local->st_stateid.si_stateownerid == st_id) &&
-			   (local->st_stateid.si_fileid == f_id))
+			if ((local->st_stateid.si_stateownerid == st_id) &&
+			    (local->st_stateid.si_fileid == f_id))
 				return local;
 		}
 	} else
@@ -1967,7 +1967,7 @@ find_lockstateowner(struct xdr_netobj *o
 
 	for (i = 0; i < LOCK_HASH_SIZE; i++) {
 		list_for_each_entry(local, &lock_ownerid_hashtbl[i], so_idhash) {
-			if(!cmp_owner_str(local, owner, clid))
+			if (!cmp_owner_str(local, owner, clid))
 				continue;
 			return local;
 		}
@@ -1980,7 +1980,7 @@ find_lockstateowner_str(unsigned int has
 	struct nfs4_stateowner *local = NULL;
 
 	list_for_each_entry(local, &lock_ownerstr_hashtbl[hashval], so_strhash) {
-		if(!cmp_owner_str(local, owner, clid)) 
+		if (!cmp_owner_str(local, owner, clid))
 			continue;
 		*op = local;
 		return(1);
@@ -2005,7 +2005,7 @@ alloc_init_lock_stateowner(unsigned int 
 	unsigned int idhashval;
 
 	if (!(sop = alloc_stateowner(&lock->lk_new_owner)))
-		return (struct nfs4_stateowner *)NULL;
+		return NULL;
 	idhashval = lockownerid_hashval(current_ownerid);
 	INIT_LIST_HEAD(&sop->so_idhash);
 	INIT_LIST_HEAD(&sop->so_strhash);
@@ -2068,7 +2068,7 @@ int
 check_lock_length(u64 offset, u64 length)
 {
 	return ((length == 0)  || ((length != ~(u64)0) &&
- 	     LOFF_OVERFLOW(offset, length)));
+	     LOFF_OVERFLOW(offset, length)));
 }
 
 /*
@@ -2210,7 +2210,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struc
 	status = posix_lock_file(filp, &file_lock);
 	if (file_lock.fl_ops && file_lock.fl_ops->fl_release_private)
 		file_lock.fl_ops->fl_release_private(&file_lock);
-	dprintk("NFSD: nfsd4_lock: posix_test_lock passed. posix_lock_file status %d\n",status);
+	dprintk("NFSD: nfsd4_lock: posix_lock_file status %d\n",status);
 	switch (-status) {
 	case 0: /* success! */
 		update_stateid(&lock_stp->st_stateid);
@@ -2459,7 +2459,7 @@ nfsd4_release_lockowner(struct svc_rqst 
 
 	nfs4_lock_state();
 
-        status = nfs_ok;
+	status = nfs_ok;
 	local = find_lockstateowner(owner, clid);
 	if (local) {
 		struct nfs4_stateid *stp;
@@ -2469,7 +2469,7 @@ nfsd4_release_lockowner(struct svc_rqst 
 		status = nfserr_locks_held;
 		list_for_each_entry(stp, &local->so_perfilestate,
 				st_perfilestate) {
-			if(stp->st_vfs_set) {
+			if (stp->st_vfs_set) {
 				if (check_for_locks(stp->st_vfs_file, local))
 					goto out;
 			}
@@ -2496,7 +2496,7 @@ alloc_reclaim(int namelen)
 		kfree(crp);
 		return NULL;
 	}
-       	return crp;
+	return crp;
 }
 
 /*
@@ -2566,7 +2566,7 @@ nfs4_find_reclaim_client(clientid_t *cli
 	strhashval = clientstr_hashval(client->cl_name.data,
 	                              client->cl_name.len);
 	list_for_each_entry(crp, &reclaim_str_hashtbl[strhashval], cr_strhash) {
-		if(cmp_name(&crp->cr_name, &client->cl_name)) {
+		if (cmp_name(&crp->cr_name, &client->cl_name)) {
 			return crp;
 		}
 	}


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

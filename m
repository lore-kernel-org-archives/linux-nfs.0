From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSdv4 - 6 of 10 - Keep state to allow replays for 'close' to work.
Date: Thu, 08 Apr 2004 11:18:46 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1BBOBq-0001Qt-Ka@notabene.cse.unsw.edu.au>
References: <20040408111135.5397.patches@notabene>
Cc: nfs@lists.sourceforge.net,  "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BBOCT-0007m0-6m
	for nfs@lists.sourceforge.net; Wed, 07 Apr 2004 18:19:25 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BBOCS-00024m-B2
	for nfs@lists.sourceforge.net; Wed, 07 Apr 2004 18:19:24 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.241.7] == ppp2-007.ppp2.cse.unsw.EDU.AU) (auth-user neilb)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>)
	(for <bfields@fieldses.org>) By note With Smtp ;
	Thu, 8 Apr 2004 11:19:18 +1000
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


From: "J. Bruce Fields" <bfields@fieldses.org>

>From Andros: Idea is to keep around a list of openowners recently released by
closes, and make sure they stay around long enough so that replays still work.

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4state.c        |   85 +++++++++++++++++++++++++++++++------------
 ./include/linux/nfsd/state.h |    6 +++
 2 files changed, 69 insertions(+), 22 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-04-08 10:56:23.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2004-04-08 10:56:23.000000000 +1000
@@ -136,12 +136,16 @@ static void release_file(struct nfs4_fil
  *
  * client_lru holds client queue ordered by nfs4_client.cl_time
  * for lease renewal.
+ *
+ * close_lru holds (open) stateowner queue ordered by nfs4_stateowner.so_time
+ * for last close replay.
  */
 static struct list_head	conf_id_hashtbl[CLIENT_HASH_SIZE];
 static struct list_head	conf_str_hashtbl[CLIENT_HASH_SIZE];
 static struct list_head	unconf_str_hashtbl[CLIENT_HASH_SIZE];
 static struct list_head	unconf_id_hashtbl[CLIENT_HASH_SIZE];
 static struct list_head client_lru;
+static struct list_head close_lru;
 
 static inline void
 renew_client(struct nfs4_client *clp)
@@ -774,6 +778,8 @@ alloc_init_open_stateowner(unsigned int 
 	INIT_LIST_HEAD(&sop->so_perclient);
 	INIT_LIST_HEAD(&sop->so_perfilestate);
 	INIT_LIST_HEAD(&sop->so_perlockowner);  /* not used */
+	INIT_LIST_HEAD(&sop->so_close_lru);
+	sop->so_time = 0;
 	list_add(&sop->so_idhash, &ownerid_hashtbl[idhashval]);
 	list_add(&sop->so_strhash, &ownerstr_hashtbl[strhashval]);
 	list_add(&sop->so_perclient, &clp->cl_perclient);
@@ -814,6 +820,7 @@ release_stateowner(struct nfs4_stateowne
 	list_del(&sop->so_strhash);
 	list_del(&sop->so_perclient);
 	list_del(&sop->so_perlockowner);
+	list_del(&sop->so_close_lru);
 	del_perclient++;
 	while (!list_empty(&sop->so_perfilestate)) {
 		stp = list_entry(sop->so_perfilestate.next, 
@@ -882,6 +889,19 @@ release_file(struct nfs4_file *fp)
 }	
 
 void
+move_to_close_lru(struct nfs4_stateowner *sop)
+{
+	dprintk("NFSD: move_to_close_lru nfs4_stateowner %p\n", sop);
+	/* remove stateowner from all other hash lists except perclient */
+	list_del_init(&sop->so_idhash);
+	list_del_init(&sop->so_strhash);
+	list_del_init(&sop->so_perlockowner);
+
+        list_add_tail(&sop->so_close_lru, &close_lru);
+        sop->so_time = get_seconds();
+}
+
+void
 release_state_owner(struct nfs4_stateid *stp, struct nfs4_stateowner **sopp,
 		int flag)
 {
@@ -890,16 +910,13 @@ release_state_owner(struct nfs4_stateid 
 
 	dprintk("NFSD: release_state_owner\n");
 	release_stateid(stp, flag);
-	/*
-	 * release unused nfs4_stateowners.
-	 * XXX will need to be placed  on an  open_stateid_lru list to be
+
+	/* place unused nfs4_stateowners on so_close_lru list to be
 	 * released by the laundromat service after the lease period
 	 * to enable us to handle CLOSE replay
 	 */
-	if (sop->so_confirmed && list_empty(&sop->so_perfilestate)) {
-		release_stateowner(sop);
-		*sopp = NULL;
-	}
+	if (sop->so_confirmed && list_empty(&sop->so_perfilestate))
+		move_to_close_lru(sop);
 	/* unused nfs4_file's are releseed. XXX slab cache? */
 	if (list_empty(&fp->fi_perfile)) {
 		release_file(fp);
@@ -1316,9 +1333,11 @@ time_t
 nfs4_laundromat(void)
 {
 	struct nfs4_client *clp;
+	struct nfs4_stateowner *sop;
 	struct list_head *pos, *next;
 	time_t cutoff = get_seconds() - NFSD_LEASE_TIME;
-	time_t t, return_val = NFSD_LEASE_TIME;
+	time_t t, clientid_val = NFSD_LEASE_TIME;
+	time_t u, close_val = NFSD_LEASE_TIME;
 
 	nfs4_lock_state();
 
@@ -1327,18 +1346,30 @@ nfs4_laundromat(void)
 		clp = list_entry(pos, struct nfs4_client, cl_lru);
 		if (time_after((unsigned long)clp->cl_time, (unsigned long)cutoff)) {
 			t = clp->cl_time - cutoff;
-			if (return_val > t)
-				return_val = t;
+			if (clientid_val > t)
+				clientid_val = t;
 			break;
 		}
 		dprintk("NFSD: purging unused client (clientid %08x)\n",
 			clp->cl_clientid.cl_id);
 		expire_client(clp);
 	}
-	if (return_val < NFSD_LAUNDROMAT_MINTIMEOUT)
-		return_val = NFSD_LAUNDROMAT_MINTIMEOUT;
+	list_for_each_safe(pos, next, &close_lru) {
+		sop = list_entry(pos, struct nfs4_stateowner, so_close_lru);
+		if (time_after((unsigned long)sop->so_time, (unsigned long)cutoff)) {
+			u = sop->so_time - cutoff;
+			if (close_val > u)
+				close_val = u;
+			break;
+		}
+		dprintk("NFSD: purging unused open stateowner (so_id %d)\n",
+			sop->so_id);
+		release_stateowner(sop);
+	}
+	if (clientid_val < NFSD_LAUNDROMAT_MINTIMEOUT)
+		clientid_val = NFSD_LAUNDROMAT_MINTIMEOUT;
 	nfs4_unlock_state();
-	return return_val;
+	return clientid_val;
 }
 
 void
@@ -1351,17 +1382,22 @@ laundromat_main(void *not_used)
 	schedule_delayed_work(&laundromat_work, t*HZ);
 }
 
-/* search ownerid_hashtbl[] for stateid owner (stateid->si_stateownerid) */
+/* search ownerid_hashtbl[] and close_lru for stateid owner 
+ * (stateid->si_stateownerid) 
+ */
 struct nfs4_stateowner *
-find_openstateowner_id(u32 st_id) {
+find_openstateowner_id(u32 st_id, int flags) {
 	struct list_head *pos, *next;
 	struct nfs4_stateowner *local = NULL;
-	unsigned int hashval = ownerid_hashval(st_id);
 
-	list_for_each_safe(pos, next, &ownerid_hashtbl[hashval]) {
-		local = list_entry(pos, struct nfs4_stateowner, so_idhash);
-		if(local->so_id == st_id)
-			return local;
+	dprintk("NFSD: find_openstateowner_id %d\n", st_id);
+	if (flags & CLOSE_STATE) {
+		list_for_each_safe(pos, next, &close_lru) {
+			local = list_entry(pos, struct nfs4_stateowner, 
+			                    so_close_lru);
+			if(local->so_id == st_id)
+				return local;
+		}
 	}
 	return NULL;
 }
@@ -1547,11 +1583,12 @@ no_nfs4_stateid:
 	* starting by trying to look up the stateowner.
 	* If stateowner is not found - stateid is bad.
 	*/
-	if (!(sop = find_openstateowner_id(stateid->si_stateownerid))) {
+	if (!(sop = find_openstateowner_id(stateid->si_stateownerid, flags))) {
 		printk("NFSD: preprocess_seqid_op: no stateowner or nfs4_stateid!\n");
 		status = nfserr_bad_stateid;
 		goto out;
 	}
+	*sopp = sop;
 
 check_replay:
 	if (seqid == sop->so_seqid) {
@@ -1690,9 +1727,10 @@ nfsd4_close(struct svc_rqst *rqstp, stru
 			current_fh->fh_dentry->d_name.name);
 
 	nfs4_lock_state();
+	/* check close_lru for replay */
 	if ((status = nfs4_preprocess_seqid_op(current_fh, close->cl_seqid, 
 					&close->cl_stateid, 
-					CHECK_FH | OPEN_STATE, 
+					CHECK_FH | OPEN_STATE | CLOSE_STATE, 
 					&close->cl_stateowner, &stp, NULL)))
 		goto out; 
 	/*
@@ -1854,6 +1892,8 @@ alloc_init_lock_stateowner(unsigned int 
 	INIT_LIST_HEAD(&sop->so_perclient);
 	INIT_LIST_HEAD(&sop->so_perfilestate);
 	INIT_LIST_HEAD(&sop->so_perlockowner);
+	INIT_LIST_HEAD(&sop->so_close_lru); /* not used */
+	sop->so_time = 0;
 	list_add(&sop->so_idhash, &lock_ownerid_hashtbl[idhashval]);
 	list_add(&sop->so_strhash, &lock_ownerstr_hashtbl[strhashval]);
 	list_add(&sop->so_perclient, &clp->cl_perclient);
@@ -2351,6 +2391,7 @@ nfs4_state_init(void)
 	memset(&zerostateid, 0, sizeof(stateid_t));
 	memset(&onestateid, ~0, sizeof(stateid_t));
 
+	INIT_LIST_HEAD(&close_lru);
 	INIT_LIST_HEAD(&client_lru);
 	init_MUTEX(&client_sema);
 	boot_time = get_seconds();

diff ./include/linux/nfsd/state.h~current~ ./include/linux/nfsd/state.h
--- ./include/linux/nfsd/state.h~current~	2004-04-08 10:56:23.000000000 +1000
+++ ./include/linux/nfsd/state.h	2004-04-08 10:56:23.000000000 +1000
@@ -132,6 +132,9 @@ struct nfs4_replay {
 *         release a stateowner.
 *    so_perlockowner: (open) nfs4_stateid->st_perlockowner entry - used when
 *         close is called to reap associated byte-range locks
+*    so_close_lru: (open) stateowner is placed on this list instead of being
+*         reaped (when so_perfilestate is empty) to hold the last close replay.
+*         reaped by laundramat thread after lease period.
 */
 struct nfs4_stateowner {
 	struct list_head        so_idhash;   /* hash by so_id */
@@ -139,6 +142,8 @@ struct nfs4_stateowner {
 	struct list_head        so_perclient; /* nfs4_client->cl_perclient */
 	struct list_head        so_perfilestate; /* list: nfs4_stateid */
 	struct list_head        so_perlockowner; /* nfs4_stateid->st_perlockowner */
+	struct list_head	so_close_lru; /* tail queue */
+	time_t			so_time; /* time of placement on so_close_lru */
 	int			so_is_open_owner; /* 1=openowner,0=lockowner */
 	u32                     so_id;
 	struct nfs4_client *    so_client;
@@ -194,6 +199,7 @@ struct nfs4_stateid {
 #define OPEN_STATE              0x00000004
 #define LOCK_STATE              0x00000008
 #define RDWR_STATE              0x00000010
+#define CLOSE_STATE             0x00000020
 
 #define seqid_mutating_err(err)                       \
 	(((err) != nfserr_stale_clientid) &&    \


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

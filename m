From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 9 of 54] nfsd4: reclaim cleanup
Date: Tue, 08 Mar 2005 17:06:42 +1100
Message-ID: <E1D8Xre-00017N-Nq@notabene.cse.unsw.edu.au>
References: <20050308165419.3842.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8Xrk-00026N-OI
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:48 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D8Xrj-0005CB-QW
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:48 -0800
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



Remove unnecessary fields in the nfs4_client_reclaim structure.  Initialize
reclaim_str_hashtbl_size and increment it inside of nfs4_client_to_reclaim.
Modify client_to_reclaim() in preparation for reboot recovery.

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c        |   38 +++++++++++++-------------------------
 ./include/linux/nfsd/state.h |    3 ---
 2 files changed, 13 insertions(+), 28 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-03-07 11:35:09.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2005-03-07 11:35:10.000000000 +1100
@@ -257,7 +257,7 @@ release_delegation(struct nfs4_delegatio
  * for last close replay.
  */
 static struct list_head	reclaim_str_hashtbl[CLIENT_HASH_SIZE];
-static int reclaim_str_hashtbl_size;
+static int reclaim_str_hashtbl_size = 0;
 static struct list_head	conf_id_hashtbl[CLIENT_HASH_SIZE];
 static struct list_head	conf_str_hashtbl[CLIENT_HASH_SIZE];
 static struct list_head	unconf_str_hashtbl[CLIENT_HASH_SIZE];
@@ -2207,17 +2207,6 @@ check_replay:
 	goto out;
 }
 
-/*
- * eventually, this will perform an upcall to the 'state daemon' as well as
- * set the cl_first_state field.
- */
-void
-first_state(struct nfs4_client *clp)
-{
-	if (!clp->cl_first_state)
-		clp->cl_first_state = get_seconds();
-}
-
 int
 nfsd4_open_confirm(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_open_confirm *oc)
 {
@@ -2250,8 +2239,6 @@ nfsd4_open_confirm(struct svc_rqst *rqst
 		         stp->st_stateid.si_stateownerid,
 		         stp->st_stateid.si_fileid,
 		         stp->st_stateid.si_generation);
-	status = nfs_ok;
-	first_state(sop->so_client);
 out:
 	if (oc->oc_stateowner)
 		nfs4_get_stateowner(oc->oc_stateowner);
@@ -3057,21 +3044,21 @@ alloc_reclaim(int namelen)
  * failure => all reset bets are off, nfserr_no_grace...
  */
 static int
-nfs4_client_to_reclaim(struct nfs4_client *clp)
+nfs4_client_to_reclaim(char *name, int namlen)
 {
 	unsigned int strhashval;
 	struct nfs4_client_reclaim *crp = NULL;
 
-	crp = alloc_reclaim(clp->cl_name.len);
+	dprintk("NFSD nfs4_client_to_reclaim NAME: %.*s\n", namlen, name);
+	crp = alloc_reclaim(namlen);
 	if (!crp)
 		return 0;
-	strhashval = clientstr_hashval(clp->cl_name.data, clp->cl_name.len);
+	strhashval = clientstr_hashval(name, namlen);
 	INIT_LIST_HEAD(&crp->cr_strhash);
 	list_add(&crp->cr_strhash, &reclaim_str_hashtbl[strhashval]);
-	memcpy(crp->cr_name.data, clp->cl_name.data, clp->cl_name.len);
-	crp->cr_name.len = clp->cl_name.len;
-	crp->cr_first_state = clp->cl_first_state;
-	crp->cr_expired = 0;
+	memcpy(crp->cr_name.data, name, namlen);
+	crp->cr_name.len = namlen;
+	reclaim_str_hashtbl_size++;
 	return 1;
 }
 
@@ -3116,6 +3103,9 @@ nfs4_find_reclaim_client(clientid_t *cli
 	if (!client)
 		return NULL;
 
+	dprintk("NFSD: nfs4_find_reclaim_client for %.*s\n",
+		            clp->cl_name.len, clp->cl_name.data);
+
 	/* find clp->cl_name in reclaim_str_hashtbl */
 	strhashval = clientstr_hashval(client->cl_name.data,
 	                              client->cl_name.len);
@@ -3137,8 +3127,6 @@ nfs4_check_open_reclaim(clientid_t *clid
 
 	if ((crp = nfs4_find_reclaim_client(clid)) == NULL)
 		return nfserr_reclaim_bad;
-	if (crp->cr_expired)
-		return nfserr_no_grace;
 	return nfs_ok;
 }
 
@@ -3332,11 +3320,11 @@ nfs4_reset_lease(time_t leasetime)
 	/* populate reclaim_str_hashtbl with current confirmed nfs4_clientid */
 	for (i = 0; i < CLIENT_HASH_SIZE; i++) {
 		list_for_each_entry(clp, &conf_id_hashtbl[i], cl_idhash) {
-			if (!nfs4_client_to_reclaim(clp)) {
+			if (!nfs4_client_to_reclaim(clp->cl_name.data,
+						clp->cl_name.len)) {
 				nfs4_release_reclaim();
 				goto init_state;
 			}
-			reclaim_str_hashtbl_size++;
 		}
 	}
 init_state:

diff ./include/linux/nfsd/state.h~current~ ./include/linux/nfsd/state.h
--- ./include/linux/nfsd/state.h~current~	2005-03-07 11:35:10.000000000 +1100
+++ ./include/linux/nfsd/state.h	2005-03-07 11:35:10.000000000 +1100
@@ -141,7 +141,6 @@ struct nfs4_client {
 	clientid_t		cl_clientid;	/* generated by server */
 	nfs4_verifier		cl_confirm;	/* generated by server */
 	struct nfs4_callback	cl_callback;    /* callback info */
-	time_t			cl_first_state; /* first state aquisition*/
 	atomic_t		cl_count;	/* ref count */
 };
 
@@ -153,8 +152,6 @@ struct nfs4_client {
 struct nfs4_client_reclaim {
 	struct list_head	cr_strhash;	/* hash by cr_name */
 	struct xdr_netobj 	cr_name; 	/* id generated by client */
-	time_t			cr_first_state; /* first state aquisition */
-	u32			cr_expired;     /* boolean: lease expired? */
 };
 
 static inline void


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

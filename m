From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 23 of 54] nfsd4: simplify clientid hash table searches
Date: Tue, 08 Mar 2005 17:06:43 +1100
Message-ID: <E1D8Xrf-00018H-Sb@notabene.cse.unsw.edu.au>
References: <20050308165419.3842.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8XsG-0002Aq-Ke
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:07:20 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1D8XsF-0007wV-MF
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:07:20 -0800
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


We repeat the same hash table searches in a bunch of places, and keep making
the mistake of assuming the variable iterating over the list will be NULL when
the search fails.  Some helper functions here simplify things a bit.

While we're at it, make move_to_confirmed take just a clp instead of making the
caller compute the hash.  This means we sometimes have to compute the hash
multiple times, but it's only an &, so no big deal.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   84 ++++++++++++++++++++++++++------------------------
 1 files changed, 45 insertions(+), 39 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-03-07 11:35:57.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2005-03-07 11:35:57.000000000 +1100
@@ -471,8 +471,9 @@ add_to_unconfirmed(struct nfs4_client *c
 }
 
 void
-move_to_confirmed(struct nfs4_client *clp, unsigned int idhashval)
+move_to_confirmed(struct nfs4_client *clp)
 {
+	unsigned int idhashval = clientid_hashval(clp->cl_clientid.cl_id);
 	unsigned int strhashval;
 
 	dprintk("NFSD: move_to_confirm nfs4_client %p\n", clp);
@@ -485,6 +486,31 @@ move_to_confirmed(struct nfs4_client *cl
 	renew_client(clp);
 }
 
+static struct nfs4_client *
+find_confirmed_client(clientid_t *clid)
+{
+	struct nfs4_client *clp;
+	unsigned int idhashval = clientid_hashval(clid->cl_id);
+
+	list_for_each_entry(clp, &conf_id_hashtbl[idhashval], cl_idhash) {
+		if (cmp_clid(&clp->cl_clientid, clid))
+			return clp;
+	}
+	return NULL;
+}
+
+static struct nfs4_client *
+find_unconfirmed_client(clientid_t *clid)
+{
+	struct nfs4_client *clp;
+	unsigned int idhashval = clientid_hashval(clid->cl_id);
+
+	list_for_each_entry(clp, &unconf_id_hashtbl[idhashval], cl_idhash) {
+		if (cmp_clid(&clp->cl_clientid, clid))
+			return clp;
+	}
+	return NULL;
+}
 
 /* a helper function for parse_callback */
 static int
@@ -793,7 +819,6 @@ int
 nfsd4_setclientid_confirm(struct svc_rqst *rqstp, struct nfsd4_setclientid_confirm *setclientid_confirm)
 {
 	u32 ip_addr = rqstp->rq_addr.sin_addr.s_addr;
-	unsigned int idhashval;
 	struct nfs4_client *clp, *conf = NULL, *unconf = NULL;
 	nfs4_verifier confirm = setclientid_confirm->sc_confirm; 
 	clientid_t * clid = &setclientid_confirm->sc_clientid;
@@ -806,12 +831,9 @@ nfsd4_setclientid_confirm(struct svc_rqs
 	 * We get here on a DRC miss.
 	 */
 
-	idhashval = clientid_hashval(clid->cl_id);
 	nfs4_lock_state();
-	list_for_each_entry(clp, &conf_id_hashtbl[idhashval], cl_idhash) {
-		if (!cmp_clid(&clp->cl_clientid, clid))
-			continue;
-
+	clp = find_confirmed_client(clid);
+	if (clp) {
 		status = nfserr_inval;
 		/* 
 		 * Found a record for this clientid. If the IP addresses
@@ -825,11 +847,9 @@ nfsd4_setclientid_confirm(struct svc_rqs
 			goto out;
 		}
 		conf = clp;
-		break;
 	}
-	list_for_each_entry(clp, &unconf_id_hashtbl[idhashval], cl_idhash) {
-		if (!cmp_clid(&clp->cl_clientid, clid))
-			continue;
+	clp = find_unconfirmed_client(clid);
+	if (clp) {
 		status = nfserr_inval;
 		if (clp->cl_addr != ip_addr) { 
 			printk("NFSD: setclientid: string in use by client"
@@ -838,7 +858,6 @@ nfsd4_setclientid_confirm(struct svc_rqs
 			goto out;
 		}
 		unconf = clp;
-		break;
 	}
 	/* CASE 1: 
 	* unconf record that matches input clientid and input confirm.
@@ -855,7 +874,7 @@ nfsd4_setclientid_confirm(struct svc_rqs
 		else {
 			expire_client(conf);
 			clp = unconf;
-			move_to_confirmed(unconf, idhashval);
+			move_to_confirmed(unconf);
 			status = nfs_ok;
 		}
 		goto out;
@@ -888,7 +907,7 @@ nfsd4_setclientid_confirm(struct svc_rqs
 		} else {
 			status = nfs_ok;
 			clp = unconf;
-			move_to_confirmed(unconf, idhashval);
+			move_to_confirmed(unconf);
 		}
 		goto out;
 	}
@@ -1233,11 +1252,9 @@ static int
 verify_clientid(struct nfs4_client **client, clientid_t *clid) {
 
 	struct nfs4_client *clp;
-	unsigned int idhashval = clientid_hashval(clid->cl_id);
 
-	list_for_each_entry(clp, &conf_id_hashtbl[idhashval], cl_idhash) {
-		if (!cmp_clid(&clp->cl_clientid, clid))
-			continue;
+	clp = find_confirmed_client(clid);
+	if (clp) {
 		*client = clp;
 		return 1;
 	}
@@ -1798,7 +1815,6 @@ int 
 nfsd4_renew(clientid_t *clid)
 {
 	struct nfs4_client *clp;
-	unsigned int idhashval;
 	int status;
 
 	nfs4_lock_state();
@@ -1808,18 +1824,15 @@ nfsd4_renew(clientid_t *clid)
 	if (STALE_CLIENTID(clid))
 		goto out;
 	status = nfs_ok;
-	idhashval = clientid_hashval(clid->cl_id);
-	list_for_each_entry(clp, &conf_id_hashtbl[idhashval], cl_idhash) {
-		if (!cmp_clid(&clp->cl_clientid, clid))
-			continue;
+	clp = find_confirmed_client(clid);
+	if (clp) {
 		renew_client(clp);
 		goto out;
 	}
-	list_for_each_entry(clp, &unconf_id_hashtbl[idhashval], cl_idhash) {
-		if (!cmp_clid(&clp->cl_clientid, clid))
-			continue;
+	clp = find_unconfirmed_client(clid);
+	if (clp) {
 		renew_client(clp);
-	goto out;
+		goto out;
 	}
 	/*
 	* Couldn't find an nfs4_client for this clientid.  
@@ -3100,30 +3113,23 @@ nfs4_release_reclaim(void)
 struct nfs4_client_reclaim *
 nfs4_find_reclaim_client(clientid_t *clid)
 {
-	unsigned int idhashval = clientid_hashval(clid->cl_id);
 	unsigned int strhashval;
-	struct nfs4_client *clp, *client = NULL;
+	struct nfs4_client *clp;
 	struct nfs4_client_reclaim *crp = NULL;
 
 
 	/* find clientid in conf_id_hashtbl */
-	list_for_each_entry(clp, &conf_id_hashtbl[idhashval], cl_idhash) {
-		if (cmp_clid(&clp->cl_clientid, clid)) {
-			client = clp;
-			break;
-		}
-	}
-	if (!client)
+	clp = find_confirmed_client(clid);
+	if (clp == NULL)
 		return NULL;
 
 	dprintk("NFSD: nfs4_find_reclaim_client for %.*s\n",
 		            clp->cl_name.len, clp->cl_name.data);
 
 	/* find clp->cl_name in reclaim_str_hashtbl */
-	strhashval = clientstr_hashval(client->cl_name.data,
-	                              client->cl_name.len);
+	strhashval = clientstr_hashval(clp->cl_name.data, clp->cl_name.len);
 	list_for_each_entry(crp, &reclaim_str_hashtbl[strhashval], cr_strhash) {
-		if (cmp_name(&crp->cr_name, &client->cl_name)) {
+		if (cmp_name(&crp->cr_name, &clp->cl_name)) {
 			return crp;
 		}
 	}


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

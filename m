From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 022 of 28] nfsd4: miscellaneous setclientid_confirm cleanup
Date: Thu, 02 Jun 2005 08:50:57 +1000
Message-ID: <E1Ddc37-0006io-Nh@notabene.cse.unsw.edu.au>
References: <20050602084410.25538.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ddc3N-0005wl-50
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:13 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Ddc3J-0002QY-K2
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:12 -0700
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


Minor cleanup, remove some unnecessary printk's.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   49 +++++++++++++++++--------------------------------
 1 files changed, 17 insertions(+), 32 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-05-31 14:21:05.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2005-05-31 14:21:05.000000000 +1000
@@ -834,7 +834,7 @@ int
 nfsd4_setclientid_confirm(struct svc_rqst *rqstp, struct nfsd4_setclientid_confirm *setclientid_confirm)
 {
 	u32 ip_addr = rqstp->rq_addr.sin_addr.s_addr;
-	struct nfs4_client *clp, *conf = NULL, *unconf = NULL;
+	struct nfs4_client *conf, *unconf;
 	nfs4_verifier confirm = setclientid_confirm->sc_confirm; 
 	clientid_t * clid = &setclientid_confirm->sc_clientid;
 	int status;
@@ -847,28 +847,16 @@ nfsd4_setclientid_confirm(struct svc_rqs
 	 */
 
 	nfs4_lock_state();
-	clp = find_confirmed_client(clid);
-	if (clp) {
-		status = nfserr_clid_inuse;
-		if (clp->cl_addr != ip_addr) { 
-			printk("NFSD: setclientid: string in use by client"
-			"(clientid %08x/%08x)\n",
-			clp->cl_clientid.cl_boot, clp->cl_clientid.cl_id);
-			goto out;
-		}
-		conf = clp;
-	}
-	clp = find_unconfirmed_client(clid);
-	if (clp) {
-		status = nfserr_clid_inuse;
-		if (clp->cl_addr != ip_addr) { 
-			printk("NFSD: setclientid: string in use by client"
-			"(clientid %08x/%08x)\n",
-			clp->cl_clientid.cl_boot, clp->cl_clientid.cl_id);
-			goto out;
-		}
-		unconf = clp;
-	}
+
+	conf = find_confirmed_client(clid);
+	unconf = find_unconfirmed_client(clid);
+
+	status = nfserr_clid_inuse;
+	if (conf && conf->cl_addr != ip_addr)
+		goto out;
+	if (unconf && unconf->cl_addr != ip_addr)
+		goto out;
+
 	if ((conf && unconf) && 
 	    (cmp_verf(&unconf->cl_confirm, &confirm)) &&
 	    (cmp_verf(&conf->cl_verifier, &unconf->cl_verifier)) &&
@@ -884,9 +872,8 @@ nfsd4_setclientid_confirm(struct svc_rqs
 		else {
 			/* XXX: We just turn off callbacks until we can handle
 			  * change request correctly. */
-			clp = conf;
-			clp->cl_callback.cb_parsed = 0;
-			gen_confirm(clp);
+			conf->cl_callback.cb_parsed = 0;
+			gen_confirm(conf);
 			expire_client(unconf);
 			status = nfs_ok;
 
@@ -901,12 +888,10 @@ nfsd4_setclientid_confirm(struct svc_rqs
 		 * unconf->cl_name or unconf->cl_verifier don't match the
 		 * conf record.
 		 */
-		if (!cmp_creds(&conf->cl_cred,&rqstp->rq_cred)) {
+		if (!cmp_creds(&conf->cl_cred,&rqstp->rq_cred))
 			status = nfserr_clid_inuse;
-		} else {
-			clp = conf;
+		else
 			status = nfs_ok;
-		}
 	} else if (!conf && unconf
 			&& cmp_verf(&unconf->cl_confirm, &confirm)) {
 		/* CASE 3:
@@ -924,8 +909,8 @@ nfsd4_setclientid_confirm(struct svc_rqs
 			if (conf) {
 				expire_client(conf);
 			}
-			clp = unconf;
 			move_to_confirmed(unconf);
+			conf = unconf;
 			status = nfs_ok;
 		}
 	} else if ((!conf || (conf && !cmp_verf(&conf->cl_confirm, &confirm)))
@@ -944,7 +929,7 @@ nfsd4_setclientid_confirm(struct svc_rqs
 	}
 out:
 	if (!status)
-		nfsd4_probe_callback(clp);
+		nfsd4_probe_callback(conf);
 	nfs4_unlock_state();
 	return status;
 }


-------------------------------------------------------
This SF.Net email is sponsored by Yahoo.
Introducing Yahoo! Search Developer Network - Create apps using Yahoo!
Search APIs Find out how you can build Yahoo! directly into your own
Applications - visit http://developer.yahoo.net/?fr=offad-ysdn-ostg-q22005
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 021 of 28] nfsd4: setclientid_confirm comments
Date: Thu, 02 Jun 2005 08:50:57 +1000
Message-ID: <E1Ddc37-0006il-MB@notabene.cse.unsw.edu.au>
References: <20050602084410.25538.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ddc3Y-0005yN-Cg
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:24 -0700
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Ddc3U-0002ST-Ot
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:24 -0700
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


Trivial whitespace and comment fixes.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   59 ++++++++++++++++++++++++--------------------------
 1 files changed, 29 insertions(+), 30 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-05-31 14:21:05.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2005-05-31 14:21:05.000000000 +1000
@@ -869,16 +869,16 @@ nfsd4_setclientid_confirm(struct svc_rqs
 		}
 		unconf = clp;
 	}
-	/* CASE 1: 
-	* unconf record that matches input clientid and input confirm.
-	* conf record that matches input clientid.
-	* conf  and unconf records match names, verifiers 
-	*/
 	if ((conf && unconf) && 
 	    (cmp_verf(&unconf->cl_confirm, &confirm)) &&
 	    (cmp_verf(&conf->cl_verifier, &unconf->cl_verifier)) &&
 	    (same_name(conf->cl_recdir,unconf->cl_recdir))  &&
 	    (!cmp_verf(&conf->cl_confirm, &unconf->cl_confirm))) {
+		/* CASE 1:
+		* unconf record that matches input clientid and input confirm.
+		* conf record that matches input clientid.
+		* conf and unconf records match names, verifiers
+		*/
 		if (!cmp_creds(&conf->cl_cred, &unconf->cl_cred)) 
 			status = nfserr_clid_inuse;
 		else {
@@ -891,29 +891,29 @@ nfsd4_setclientid_confirm(struct svc_rqs
 			status = nfs_ok;
 
 		}
-	} 
-	/* CASE 2:
-	 * conf record that matches input clientid.
-	 * if unconf record that matches input clientid, then unconf->cl_name
-	 * or unconf->cl_verifier don't match the conf record.
-	 */
-	else if ((conf && !unconf) ||
+	} else if ((conf && !unconf) ||
 	    ((conf && unconf) && 
 	     (!cmp_verf(&conf->cl_verifier, &unconf->cl_verifier) ||
 	      !same_name(conf->cl_recdir, unconf->cl_recdir)))) {
+		/* CASE 2:
+		 * conf record that matches input clientid.
+		 * if unconf record matches input clientid, then
+		 * unconf->cl_name or unconf->cl_verifier don't match the
+		 * conf record.
+		 */
 		if (!cmp_creds(&conf->cl_cred,&rqstp->rq_cred)) {
 			status = nfserr_clid_inuse;
 		} else {
 			clp = conf;
 			status = nfs_ok;
 		}
-	}
-	/* CASE 3:
-	 * conf record not found.
-	 * unconf record found. 
-	 * unconf->cl_confirm matches input confirm
-	 */ 
-	else if (!conf && unconf && cmp_verf(&unconf->cl_confirm, &confirm)) {
+	} else if (!conf && unconf
+			&& cmp_verf(&unconf->cl_confirm, &confirm)) {
+		/* CASE 3:
+		 * conf record not found.
+		 * unconf record found.
+		 * unconf->cl_confirm matches input confirm
+		 */
 		if (!cmp_creds(&unconf->cl_cred, &rqstp->rq_cred)) {
 			status = nfserr_clid_inuse;
 		} else {
@@ -928,18 +928,17 @@ nfsd4_setclientid_confirm(struct svc_rqs
 			move_to_confirmed(unconf);
 			status = nfs_ok;
 		}
-	}
-	/* CASE 4:
-	 * conf record not found, or if conf, then conf->cl_confirm does not
-	 * match input confirm.
-	 * unconf record not found, or if unconf, then unconf->cl_confirm 
-	 * does not match input confirm.
-	 */
-	else if ((!conf || (conf && !cmp_verf(&conf->cl_confirm, &confirm))) &&
-	    (!unconf || (unconf && !cmp_verf(&unconf->cl_confirm, &confirm)))) {
+	} else if ((!conf || (conf && !cmp_verf(&conf->cl_confirm, &confirm)))
+	    && (!unconf || (unconf && !cmp_verf(&unconf->cl_confirm,
+				    				&confirm)))) {
+		/* CASE 4:
+		 * conf record not found, or if conf, conf->cl_confirm does not
+		 * match input confirm.
+		 * unconf record not found, or if unconf, unconf->cl_confirm
+		 * does not match input confirm.
+		 */
 		status = nfserr_stale_clientid;
-	}
-	else {
+	} else {
 		/* check that we have hit one of the cases...*/
 		status = nfserr_clid_inuse;
 	}


-------------------------------------------------------
This SF.Net email is sponsored by Yahoo.
Introducing Yahoo! Search Developer Network - Create apps using Yahoo!
Search APIs Find out how you can build Yahoo! directly into your own
Applications - visit http://developer.yahoo.net/?fr=offad-ysdn-ostg-q22005
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

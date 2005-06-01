From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 020 of 28] nfsd4: setclientid_confirm gotoectomy
Date: Thu, 02 Jun 2005 08:50:57 +1000
Message-ID: <E1Ddc37-0006ii-KT@notabene.cse.unsw.edu.au>
References: <20050602084410.25538.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ddc3Q-0005xL-CV
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:16 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1Ddc3N-0005O2-8t
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:16 -0700
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


Change from "goto" to "else if" format in setclientid_confirm.

>From Fred Isaman
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   17 +++++++----------
 1 files changed, 7 insertions(+), 10 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-05-31 14:21:04.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2005-05-31 14:21:05.000000000 +1000
@@ -891,14 +891,13 @@ nfsd4_setclientid_confirm(struct svc_rqs
 			status = nfs_ok;
 
 		}
-		goto out;
 	} 
 	/* CASE 2:
 	 * conf record that matches input clientid.
 	 * if unconf record that matches input clientid, then unconf->cl_name
 	 * or unconf->cl_verifier don't match the conf record.
 	 */
-	if ((conf && !unconf) || 
+	else if ((conf && !unconf) ||
 	    ((conf && unconf) && 
 	     (!cmp_verf(&conf->cl_verifier, &unconf->cl_verifier) ||
 	      !same_name(conf->cl_recdir, unconf->cl_recdir)))) {
@@ -908,14 +907,13 @@ nfsd4_setclientid_confirm(struct svc_rqs
 			clp = conf;
 			status = nfs_ok;
 		}
-		goto out;
 	}
 	/* CASE 3:
 	 * conf record not found.
 	 * unconf record found. 
 	 * unconf->cl_confirm matches input confirm
 	 */ 
-	if (!conf && unconf && cmp_verf(&unconf->cl_confirm, &confirm)) {
+	else if (!conf && unconf && cmp_verf(&unconf->cl_confirm, &confirm)) {
 		if (!cmp_creds(&unconf->cl_cred, &rqstp->rq_cred)) {
 			status = nfserr_clid_inuse;
 		} else {
@@ -930,7 +928,6 @@ nfsd4_setclientid_confirm(struct svc_rqs
 			move_to_confirmed(unconf);
 			status = nfs_ok;
 		}
-		goto out;
 	}
 	/* CASE 4:
 	 * conf record not found, or if conf, then conf->cl_confirm does not
@@ -938,14 +935,14 @@ nfsd4_setclientid_confirm(struct svc_rqs
 	 * unconf record not found, or if unconf, then unconf->cl_confirm 
 	 * does not match input confirm.
 	 */
-	if ((!conf || (conf && !cmp_verf(&conf->cl_confirm, &confirm))) &&
+	else if ((!conf || (conf && !cmp_verf(&conf->cl_confirm, &confirm))) &&
 	    (!unconf || (unconf && !cmp_verf(&unconf->cl_confirm, &confirm)))) {
 		status = nfserr_stale_clientid;
-		goto out;
 	}
-	/* check that we have hit one of the cases...*/
-	status = nfserr_clid_inuse;
-	goto out;
+	else {
+		/* check that we have hit one of the cases...*/
+		status = nfserr_clid_inuse;
+	}
 out:
 	if (!status)
 		nfsd4_probe_callback(clp);


-------------------------------------------------------
This SF.Net email is sponsored by Yahoo.
Introducing Yahoo! Search Developer Network - Create apps using Yahoo!
Search APIs Find out how you can build Yahoo! directly into your own
Applications - visit http://developer.yahoo.net/?fr=offad-ysdn-ostg-q22005
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

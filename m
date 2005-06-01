From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 014 of 28] nfsd4: add find_{un}conf_by_str functions to simplify setclientid
Date: Thu, 02 Jun 2005 08:50:56 +1000
Message-ID: <E1Ddc36-0006iO-TB@notabene.cse.unsw.edu.au>
References: <20050602084410.25538.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ddc3H-0005vY-SC
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:07 -0700
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1Ddc3G-0005Mh-UL
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:07 -0700
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


Minor setclientid cleanup

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   49 +++++++++++++++++++++++++++++++------------------
 1 files changed, 31 insertions(+), 18 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-05-31 14:21:02.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2005-05-31 14:21:02.000000000 +1000
@@ -509,6 +509,30 @@ find_unconfirmed_client(clientid_t *clid
 	return NULL;
 }
 
+static struct nfs4_client *
+find_confirmed_client_by_str(const char *dname, unsigned int hashval)
+{
+	struct nfs4_client *clp;
+
+	list_for_each_entry(clp, &conf_str_hashtbl[hashval], cl_strhash) {
+		if (same_name(clp->cl_recdir, dname))
+			return clp;
+	}
+	return NULL;
+}
+
+static struct nfs4_client *
+find_unconfirmed_client_by_str(const char *dname, unsigned int hashval)
+{
+	struct nfs4_client *clp;
+
+	list_for_each_entry(clp, &unconf_str_hashtbl[hashval], cl_strhash) {
+		if (same_name(clp->cl_recdir, dname))
+			return clp;
+	}
+	return NULL;
+}
+
 /* a helper function for parse_callback */
 static int
 parse_octet(unsigned int *lenp, char **addrp)
@@ -647,7 +671,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp
 	};
 	nfs4_verifier		clverifier = setclid->se_verf;
 	unsigned int 		strhashval;
-	struct nfs4_client *	conf, * unconf, * new, * clp;
+	struct nfs4_client	*conf, *unconf, *new;
 	int 			status;
 	char                    dname[HEXDIR_LEN];
 	
@@ -666,35 +690,24 @@ nfsd4_setclientid(struct svc_rqst *rqstp
 
 	strhashval = clientstr_hashval(dname);
 
-	conf = NULL;
 	nfs4_lock_state();
-	list_for_each_entry(clp, &conf_str_hashtbl[strhashval], cl_strhash) {
-		if (!same_name(clp->cl_recdir, dname))
-			continue;
+	conf = find_confirmed_client_by_str(dname, strhashval);
+	if (conf) {
 		/* 
 		 * CASE 0:
 		 * clname match, confirmed, different principal
 		 * or different ip_address
 		 */
 		status = nfserr_clid_inuse;
-		if (!cmp_creds(&clp->cl_cred,&rqstp->rq_cred)
-				|| clp->cl_addr != ip_addr) {
+		if (!cmp_creds(&conf->cl_cred, &rqstp->rq_cred)
+				|| conf->cl_addr != ip_addr) {
 			printk("NFSD: setclientid: string in use by client"
 			"(clientid %08x/%08x)\n",
-			clp->cl_clientid.cl_boot, clp->cl_clientid.cl_id);
+			conf->cl_clientid.cl_boot, conf->cl_clientid.cl_id);
 			goto out;
 		}
-		conf = clp;
-		break;
-	}
-	unconf = NULL;
-	list_for_each_entry(clp, &unconf_str_hashtbl[strhashval], cl_strhash) {
-		if (!same_name(clp->cl_recdir, dname))
-			continue;
-		/* cl_name match from a previous SETCLIENTID operation */
-		unconf = clp;
-		break;
 	}
+	unconf = find_unconfirmed_client_by_str(dname, strhashval);
 	status = nfserr_resource;
 	if (!conf) {
 		/* 


-------------------------------------------------------
This SF.Net email is sponsored by Yahoo.
Introducing Yahoo! Search Developer Network - Create apps using Yahoo!
Search APIs Find out how you can build Yahoo! directly into your own
Applications - visit http://developer.yahoo.net/?fr=offad-ysdn-ostg-q22005
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

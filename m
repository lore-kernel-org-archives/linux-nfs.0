From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 018 of 28] nfsd4: fix setclientid_confirm cases
Date: Thu, 02 Jun 2005 08:50:57 +1000
Message-ID: <E1Ddc37-0006ic-HF@notabene.cse.unsw.edu.au>
References: <20050602084410.25538.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ddc3Q-0005xM-ER
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:16 -0700
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Ddc3O-0002RN-3y
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


Setclientid_confirm code confused states 1 and 3 (numbering from the
IMPLEMENTATION section of rfc3530, section 14.2.33). Fix this.

State 1 allows the client to change the callback channel on the fly.  We don't
implement this currently, so just turn off the callback channel in this case.

>From Fred Isaman
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   19 +++++++++++++++----
 1 files changed, 15 insertions(+), 4 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-05-31 14:21:03.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2005-05-31 14:21:04.000000000 +1000
@@ -887,10 +887,14 @@ nfsd4_setclientid_confirm(struct svc_rqs
 		if (!cmp_creds(&conf->cl_cred, &unconf->cl_cred)) 
 			status = nfserr_clid_inuse;
 		else {
-			expire_client(conf);
-			clp = unconf;
-			move_to_confirmed(unconf);
+			/* XXX: We just turn off callbacks until we can handle
+			  * change request correctly. */
+			clp = conf;
+			clp->cl_callback.cb_parsed = 0;
+			gen_confirm(clp);
+			expire_client(unconf);
 			status = nfs_ok;
+
 		}
 		goto out;
 	} 
@@ -920,9 +924,16 @@ nfsd4_setclientid_confirm(struct svc_rqs
 		if (!cmp_creds(&unconf->cl_cred, &rqstp->rq_cred)) {
 			status = nfserr_clid_inuse;
 		} else {
-			status = nfs_ok;
+			unsigned int hash =
+				clientstr_hashval(unconf->cl_recdir);
+			conf = find_confirmed_client_by_str(unconf->cl_recdir,
+									hash);
+			if (conf) {
+				expire_client(conf);
+			}
 			clp = unconf;
 			move_to_confirmed(unconf);
+			status = nfs_ok;
 		}
 		goto out;
 	}


-------------------------------------------------------
This SF.Net email is sponsored by Yahoo.
Introducing Yahoo! Search Developer Network - Create apps using Yahoo!
Search APIs Find out how you can build Yahoo! directly into your own
Applications - visit http://developer.yahoo.net/?fr=offad-ysdn-ostg-q22005
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

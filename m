From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 5 of 23] Probe the callback path upon a successful setclientid_confirm
Date: Fri, 17 Dec 2004 16:23:55 +1100
Message-ID: <E1CfAap-0002dg-M9@notabene.cse.unsw.edu.au>
References: <20041217162128.9968.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CfAbJ-00059G-H0
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 21:24:25 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CfAbI-00066k-U4
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 21:24:25 -0800
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


Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletion(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-12-15 11:49:34.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2004-12-15 11:55:28.000000000 +1100
@@ -724,6 +724,7 @@ nfsd4_setclientid_confirm(struct svc_rqs
 			status = nfserr_clid_inuse;
 		else {
 			expire_client(conf);
+			clp = unconf;
 			move_to_confirmed(unconf, idhashval);
 			status = nfs_ok;
 		}
@@ -741,6 +742,7 @@ nfsd4_setclientid_confirm(struct svc_rqs
 		if (!cmp_creds(&conf->cl_cred,&rqstp->rq_cred)) {
 			status = nfserr_clid_inuse;
 		} else {
+			clp = conf;
 			status = nfs_ok;
 		}
 		goto out;
@@ -755,6 +757,7 @@ nfsd4_setclientid_confirm(struct svc_rqs
 			status = nfserr_clid_inuse;
 		} else {
 			status = nfs_ok;
+			clp = unconf;
 			move_to_confirmed(unconf, idhashval);
 		}
 		goto out;
@@ -774,7 +777,8 @@ nfsd4_setclientid_confirm(struct svc_rqs
 	status = nfserr_inval;
 	goto out;
 out:
-	/* XXX if status == nfs_ok, probe callback path */
+	if (!status)
+		nfsd4_probe_callback(clp);
 	nfs4_unlock_state();
 	return status;
 }


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

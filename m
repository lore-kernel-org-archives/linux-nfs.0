From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 26 of 54] nfsd4: provide no_cb_path error on renew
Date: Tue, 08 Mar 2005 17:06:44 +1100
Message-ID: <E1D8Xrg-00018T-5F@notabene.cse.unsw.edu.au>
References: <20050308165419.3842.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8Xrp-00027U-4P
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:53 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1D8Xrn-0007tA-DH
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:53 -0800
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



If the client was given a delegation, but our callback path to the client has
since failed for some reason, then our only chance to inform the client of this
is to return the cb_path_down error next time the client attempts to renew its
state.

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c       |   20 ++++++++++----------
 ./include/linux/nfsd/nfsd.h |    1 +
 2 files changed, 11 insertions(+), 10 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-03-07 11:35:58.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2005-03-07 11:35:58.000000000 +1100
@@ -1809,19 +1809,19 @@ nfsd4_renew(clientid_t *clid)
 	status = nfserr_stale_clientid;
 	if (STALE_CLIENTID(clid))
 		goto out;
-	status = nfs_ok;
 	clp = find_confirmed_client(clid);
-	if (clp) {
-		renew_client(clp);
+	status = nfserr_expired;
+	if (clp == NULL) {
+		/* We assume the client took too long to RENEW. */
+		dprintk("nfsd4_renew: clientid not found!\n");
 		goto out;
 	}
-	/*
-	* Couldn't find an nfs4_client for this clientid.  
-	* Presumably this is because the client took too long to 
-	* RENEW, so return NFS4ERR_EXPIRED.
-	*/
-	dprintk("nfsd4_renew: clientid not found!\n");
-	status = nfserr_expired;
+	renew_client(clp);
+	status = nfserr_cb_path_down;
+	if (!list_empty(&clp->cl_del_perclnt)
+			&& !atomic_read(&clp->cl_callback.cb_set))
+		goto out;
+	status = nfs_ok;
 out:
 	nfs4_unlock_state();
 	return status;

diff ./include/linux/nfsd/nfsd.h~current~ ./include/linux/nfsd/nfsd.h
--- ./include/linux/nfsd/nfsd.h~current~	2005-03-07 11:35:11.000000000 +1100
+++ ./include/linux/nfsd/nfsd.h	2005-03-07 11:35:58.000000000 +1100
@@ -228,6 +228,7 @@ void		nfsd_lockd_shutdown(void);
 #define	nfserr_no_grace		__constant_htonl(NFSERR_NO_GRACE)
 #define	nfserr_reclaim_bad	__constant_htonl(NFSERR_RECLAIM_BAD)
 #define	nfserr_badname		__constant_htonl(NFSERR_BADNAME)
+#define	nfserr_cb_path_down	__constant_htonl(NFSERR_CB_PATH_DOWN)
 
 /* error codes for internal use */
 /* if a request fails due to kmalloc failure, it gets dropped.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

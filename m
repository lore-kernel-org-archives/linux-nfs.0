From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 25 of 54] nfsd4: don't allow unconfirmed renew
Date: Tue, 08 Mar 2005 17:06:43 +1100
Message-ID: <E1D8Xrf-00018P-VA@notabene.cse.unsw.edu.au>
References: <20050308165419.3842.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8XsK-0002BG-Os
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:07:24 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D8XsK-0005HE-8U
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:07:24 -0800
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


Don't bother searching for unconfirmed clients when handling RENEW; a client is
pretty sick if it's trying to renew state it hasn't even finished acquiring
yet.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |    5 -----
 1 files changed, 5 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-03-07 11:35:57.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2005-03-07 11:35:58.000000000 +1100
@@ -1815,11 +1815,6 @@ nfsd4_renew(clientid_t *clid)
 		renew_client(clp);
 		goto out;
 	}
-	clp = find_unconfirmed_client(clid);
-	if (clp) {
-		renew_client(clp);
-		goto out;
-	}
 	/*
 	* Couldn't find an nfs4_client for this clientid.  
 	* Presumably this is because the client took too long to 


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

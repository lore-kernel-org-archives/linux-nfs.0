From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 17 of 54] nfsd4: do callback replays by hand
Date: Tue, 08 Mar 2005 17:06:43 +1100
Message-ID: <E1D8Xrf-00017t-Gd@notabene.cse.unsw.edu.au>
References: <20050308165419.3842.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8XsE-0002An-IX
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:07:18 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D8XsD-0005GW-Pr
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:07:18 -0800
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


Turn off rpc layer timeout replay for the NFSv4 server callback client.
Rely on manual replay in nfs4_cb_recall_done instead.

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4callback.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff ./fs/nfsd/nfs4callback.c~current~ ./fs/nfsd/nfs4callback.c
--- ./fs/nfsd/nfs4callback.c~current~	2005-03-07 11:35:09.000000000 +1100
+++ ./fs/nfsd/nfs4callback.c	2005-03-07 11:35:49.000000000 +1100
@@ -402,7 +402,7 @@ nfsd4_probe_callback(struct nfs4_client 
 
 	/* Initialize timeout */
 	timeparms.to_initval = (NFSD_LEASE_TIME/4) * HZ;
-	timeparms.to_retries = 5;
+	timeparms.to_retries = 0;
 	timeparms.to_maxval = (NFSD_LEASE_TIME/2) * HZ;
 	timeparms.to_exponential = 1;
 
@@ -432,7 +432,7 @@ nfsd4_probe_callback(struct nfs4_client 
 		dprintk("NFSD: couldn't create callback client\n");
 		goto out_xprt;
 	}
-	clnt->cl_intr = 1;
+	clnt->cl_intr = 0;
 	clnt->cl_softrtry = 1;
 	clnt->cl_chatty = 1;
 
@@ -531,6 +531,7 @@ out:
 	return;
 
 retry:
+	dprintk("NFSD: nfs4_cb_recall_done RETRY\n");
 	atomic_inc(&dp->dl_recall_cnt);
 	/* sleep 2 seconds before retrying recall */
 	ssleep(2);


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

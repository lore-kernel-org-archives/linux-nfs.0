From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 50 of 54] nfsd4: fix delegation refcount leak
Date: Tue, 08 Mar 2005 17:06:45 +1100
Message-ID: <E1D8Xrh-0001A3-FC@notabene.cse.unsw.edu.au>
References: <20050308165419.3842.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8Xrr-00027z-4v
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:55 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1D8Xrp-0007tV-LG
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:54 -0800
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


It is the responsibility of the code that runs in the do_recall thread to
drop the reference to the delegation.  So if we fail to run that thread,
then we need to do it ourselves here.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |    1 +
 1 files changed, 1 insertion(+)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-03-07 13:34:56.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2005-03-07 13:37:15.000000000 +1100
@@ -1366,6 +1366,7 @@ void nfsd_break_deleg_cb(struct file_loc
 		printk(KERN_INFO "NFSD: Callback thread failed for "
 			"for client (clientid %08x/%08x)\n",
 			clp->cl_clientid.cl_boot, clp->cl_clientid.cl_id);
+		nfs4_put_delegation(dp);
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

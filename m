From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 001 of 16] nfsd: clear signals before exiting the nfsd() thread
Date: Fri, 08 Apr 2005 11:00:15 +1000
Message-ID: <E1DJhr5-0006dO-0p@notabene.cse.unsw.edu.au>
References: <20050408105936.25374.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DJikO-0006Ts-5F
	for nfs@lists.sourceforge.net; Thu, 07 Apr 2005 18:57:24 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DJikL-0004DF-8u
	for nfs@lists.sourceforge.net; Thu, 07 Apr 2005 18:57:23 -0700
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



Fixes the error "RPC: failed to contact portmap (errno -512)." when the
server later tries to unregister from the portmapper.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfssvc.c |    2 ++
 1 files changed, 2 insertions(+)

diff ./fs/nfsd/nfssvc.c~current~ ./fs/nfsd/nfssvc.c
--- ./fs/nfsd/nfssvc.c~current~	2005-04-08 10:31:12.000000000 +1000
+++ ./fs/nfsd/nfssvc.c	2005-04-08 10:33:13.000000000 +1000
@@ -259,6 +259,8 @@ nfsd(struct svc_rqst *rqstp)
 				break;
 		err = signo;
 	}
+	/* Clear signals before calling lockd_down() and svc_exit_thread() */
+	flush_signals(current);
 
 	lock_kernel();
 


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

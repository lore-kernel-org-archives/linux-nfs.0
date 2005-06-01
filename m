From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 001 of 28] lockd: flush signals on shutdown
Date: Thu, 02 Jun 2005 08:50:55 +1000
Message-ID: <E1Ddc35-0006hd-Tp@notabene.cse.unsw.edu.au>
References: <20050602084410.25538.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ddc3P-0005x2-54
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:15 -0700
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Ddc3N-0002RG-Oz
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:14 -0700
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


Silence another annoying "failed to contact portmap (errno -512)" on shutdown.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/lockd/svc.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletion(-)

diff ./fs/lockd/svc.c~current~ ./fs/lockd/svc.c
--- ./fs/lockd/svc.c~current~	2005-05-31 14:20:58.000000000 +1000
+++ ./fs/lockd/svc.c	2005-05-31 14:20:58.000000000 +1000
@@ -191,7 +191,9 @@ lockd(struct svc_rqst *rqstp)
 		printk(KERN_DEBUG
 			"lockd: new process, skipping host shutdown\n");
 	wake_up(&lockd_exit);
-		
+
+	flush_signals(current);
+
 	/* Exit the RPC thread */
 	svc_exit_thread(rqstp);
 


-------------------------------------------------------
This SF.Net email is sponsored by Yahoo.
Introducing Yahoo! Search Developer Network - Create apps using Yahoo!
Search APIs Find out how you can build Yahoo! directly into your own
Applications - visit http://developer.yahoo.net/?fr=offad-ysdn-ostg-q22005
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

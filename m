From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 8 of 8 - Unregister export caches in proper order
Date: Wed, 16 Oct 2002 16:03:16 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E181hH2-0000JV-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 181hHD-0002mp-00
	for <nfs@lists.sourceforge.net>; Tue, 15 Oct 2002 23:03:27 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.204] == wireless-204.wireless.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Wed, 16 Oct 2002 16:03:17 +1000
To: Linus Torvalds <torvalds@transmeta.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


### Comments for ChangeSet

As the expkey cache references entries in export cache,
it should be flushed first.
Also, the auth_unix caches should go last.


 ----------- Diffstat output ------------
 ./fs/nfsd/export.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

--- ./fs/nfsd/export.c	2002/10/16 04:47:02	1.3
+++ ./fs/nfsd/export.c	2002/10/16 05:37:43	1.4
@@ -1120,10 +1120,12 @@ nfsd_export_shutdown(void)
 	exp_writelock();
 
 	exp_unexport_all(NULL);
-	svcauth_unix_purge();
 
-	cache_unregister(&svc_export_cache);
-	cache_unregister(&svc_expkey_cache);
+	if (cache_unregister(&svc_expkey_cache))
+		printk(KERN_ERR "nfsd: failed to unregister expkey cache\n");
+	if (cache_unregister(&svc_export_cache))
+		printk(KERN_ERR "nfsd: failed to unregister export cache\n");
+	svcauth_unix_purge();
 
 	exp_writeunlock();
 	dprintk("nfsd: export shutdown complete.\n");


-------------------------------------------------------
This sf.net email is sponsored by: viaVerio will pay you up to
$1,000 for every account that you consolidate with us.
http://ad.doubleclick.net/clk;4749864;7604308;v?
http://www.viaverio.com/consolidator/osdn.cfm
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

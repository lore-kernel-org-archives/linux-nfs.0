From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 5 of 8 - minor knfsd cleanups
Date: Wed, 16 Oct 2002 16:03:15 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E181hH1-0000JH-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 181hHD-0002mq-00
	for <nfs@lists.sourceforge.net>; Tue, 15 Oct 2002 23:03:28 -0700
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


From: Christoph Hellwig <hch@sgi.com>

o don't define __NO_VERSION__ (no use in 2.4/2.5)
o don't include <linux/version.h>


 ----------- Diffstat output ------------
 ./fs/nfsd/nfs3proc.c |    1 -
 ./fs/nfsd/nfsctl.c   |    1 -
 ./fs/nfsd/nfsproc.c  |    1 -
 ./fs/nfsd/nfssvc.c   |    2 --
 ./fs/nfsd/stats.c    |    1 -
 ./fs/nfsd/vfs.c      |    2 --
 6 files changed, 8 deletions(-)

--- ./fs/nfsd/nfssvc.c	2002/10/16 04:45:56	1.2
+++ ./fs/nfsd/nfssvc.c	2002/10/16 04:47:13	1.3
@@ -8,7 +8,6 @@
  * Copyright (C) 1995, 1996, 1997 Olaf Kirch <okir@monad.swb.de>
  */
 
-#define __NO_VERSION__
 #include <linux/config.h>
 #include <linux/module.h>
 
@@ -17,7 +16,6 @@
 #include <linux/nfs.h>
 #include <linux/in.h>
 #include <linux/uio.h>
-#include <linux/version.h>
 #include <linux/unistd.h>
 #include <linux/slab.h>
 #include <linux/smp.h>
--- ./fs/nfsd/vfs.c	2002/10/16 04:47:11	1.1
+++ ./fs/nfsd/vfs.c	2002/10/16 04:47:13	1.2
@@ -16,7 +16,6 @@
  */
 
 #include <linux/config.h>
-#include <linux/version.h>
 #include <linux/string.h>
 #include <linux/time.h>
 #include <linux/errno.h>
@@ -30,7 +29,6 @@
 #include <linux/unistd.h>
 #include <linux/slab.h>
 #include <linux/in.h>
-#define __NO_VERSION__
 #include <linux/module.h>
 #include <linux/namei.h>
 
--- ./fs/nfsd/nfsproc.c	2002/10/16 04:45:56	1.2
+++ ./fs/nfsd/nfsproc.c	2002/10/16 04:47:13	1.3
@@ -16,7 +16,6 @@
 #include <linux/net.h>
 #include <linux/in.h>
 #include <linux/namei.h>
-#include <linux/version.h>
 #include <linux/unistd.h>
 #include <linux/slab.h>
 
--- ./fs/nfsd/nfs3proc.c	2002/10/16 04:45:56	1.2
+++ ./fs/nfsd/nfs3proc.c	2002/10/16 04:47:13	1.3
@@ -15,7 +15,6 @@
 #include <linux/fcntl.h>
 #include <linux/net.h>
 #include <linux/in.h>
-#include <linux/version.h>
 #include <linux/unistd.h>
 #include <linux/slab.h>
 #include <linux/major.h>
--- ./fs/nfsd/nfsctl.c	2002/10/16 04:47:11	1.1
+++ ./fs/nfsd/nfsctl.c	2002/10/16 04:47:13	1.2
@@ -8,7 +8,6 @@
 
 #include <linux/config.h>
 #include <linux/module.h>
-#include <linux/version.h>
 
 #include <linux/linkage.h>
 #include <linux/time.h>
--- ./fs/nfsd/stats.c	2002/10/16 04:47:11	1.1
+++ ./fs/nfsd/stats.c	2002/10/16 04:47:13	1.2
@@ -27,7 +27,6 @@
 #include <linux/time.h>
 #include <linux/proc_fs.h>
 #include <linux/stat.h>
-#define __NO_VERSION__
 #include <linux/module.h>
 
 #include <linux/sunrpc/svc.h>


-------------------------------------------------------
This sf.net email is sponsored by: viaVerio will pay you up to
$1,000 for every account that you consolidate with us.
http://ad.doubleclick.net/clk;4749864;7604308;v?
http://www.viaverio.com/consolidator/osdn.cfm
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: NeilBrown <neilb@suse.de>
Subject: [PATCH 006 of 8] knfsd: nfsd: remove unused header interface.h
Date: Thu, 21 Jun 2007 14:31:05 +1000
Message-ID: <1070621043105.1129@suse.de>
References: <20070621142604.727.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I1EK9-0005s8-PL
	for nfs@lists.sourceforge.net; Wed, 20 Jun 2007 21:31:13 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I1EKC-0002I8-LC
	for nfs@lists.sourceforge.net; Wed, 20 Jun 2007 21:31:17 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


From: "J. Bruce Fields" <bfields@fieldses.org>


It looks like Al Viro gutted this header file five years ago and it
hasn't been touched since.

Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfsctl.c               |    1 -
 ./include/linux/nfsd/interface.h |   13 -------------
 ./include/linux/nfsd/nfsd.h      |    1 -
 3 files changed, 15 deletions(-)

diff .prev/fs/nfsd/nfsctl.c ./fs/nfsd/nfsctl.c
--- .prev/fs/nfsd/nfsctl.c	2007-06-21 13:46:36.000000000 +1000
+++ ./fs/nfsd/nfsctl.c	2007-06-21 14:13:57.000000000 +1000
@@ -35,7 +35,6 @@
 #include <linux/nfsd/cache.h>
 #include <linux/nfsd/xdr.h>
 #include <linux/nfsd/syscall.h>
-#include <linux/nfsd/interface.h>
 
 #include <asm/uaccess.h>
 

diff .prev/include/linux/nfsd/interface.h ./include/linux/nfsd/interface.h
--- .prev/include/linux/nfsd/interface.h	2007-06-21 13:46:36.000000000 +1000
+++ ./include/linux/nfsd/interface.h	1970-01-01 10:00:00.000000000 +1000
@@ -1,13 +0,0 @@
-/*
- * include/linux/nfsd/interface.h
- *
- * defines interface between nfsd and other bits of
- * the kernel.  Particularly filesystems (eventually).
- *
- * Copyright (C) 2000 Neil Brown <neilb@cse.unsw.edu.au>
- */
-
-#ifndef LINUX_NFSD_INTERFACE_H
-#define LINUX_NFSD_INTERFACE_H
-
-#endif /* LINUX_NFSD_INTERFACE_H */

diff .prev/include/linux/nfsd/nfsd.h ./include/linux/nfsd/nfsd.h
--- .prev/include/linux/nfsd/nfsd.h	2007-06-21 13:46:36.000000000 +1000
+++ ./include/linux/nfsd/nfsd.h	2007-06-21 14:13:57.000000000 +1000
@@ -22,7 +22,6 @@
 #include <linux/nfsd/export.h>
 #include <linux/nfsd/auth.h>
 #include <linux/nfsd/stats.h>
-#include <linux/nfsd/interface.h>
 /*
  * nfsd version
  */

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

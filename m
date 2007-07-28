From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 13/23] umount.nfs: eliminate a nearly empty header
	file.
Date: Sat, 28 Jul 2007 17:50:14 -0400
Message-ID: <20070728215014.21871.95420.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IFGOm-0003eF-Mt
	for nfs@lists.sourceforge.net; Sun, 29 Jul 2007 14:34:00 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IFGOq-0005bg-D1
	for nfs@lists.sourceforge.net; Sun, 29 Jul 2007 14:34:04 -0700
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

Clean-up: move nfsumount() global declaration to nfs_mount.h, and remove
nfsumount.h.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/mount.c     |    1 -
 utils/mount/network.c   |    1 -
 utils/mount/nfs_mount.h |    3 ++-
 utils/mount/nfsmount.c  |    1 -
 utils/mount/nfsumount.c |    1 -
 utils/mount/nfsumount.h |    9 ---------
 6 files changed, 2 insertions(+), 14 deletions(-)

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index d80e5d7..b918b27 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -39,7 +39,6 @@
 
 #include "nfs_mount.h"
 #include "nfs4_mount.h"
-#include "nfsumount.h"
 #include "mount.h"
 #include "error.h"
 #include "network.h"
diff --git a/utils/mount/network.c b/utils/mount/network.c
index 12fc762..21cf4ef 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -38,7 +38,6 @@
 #include "xcommon.h"
 #include "mount.h"
 #include "nls.h"
-#include "nfsumount.h"
 #include "nfs_mount.h"
 #include "mount_constants.h"
 #include "network.h"
diff --git a/utils/mount/nfs_mount.h b/utils/mount/nfs_mount.h
index 279ff36..dcce370 100644
--- a/utils/mount/nfs_mount.h
+++ b/utils/mount/nfs_mount.h
@@ -80,6 +80,7 @@ struct nfs_mount_data {
 #define AUTH_GSS_SPKMP		390011
 #endif
 
-int nfsmount(const char *, const char *, int , char **, int);
+int	nfsmount(const char *, const char *, int , char **, int);
+int	nfsumount(int, char **);
 
 #endif /* _NFS_MOUNT_H */
diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
index 20509c7..f1d3885 100644
--- a/utils/mount/nfsmount.c
+++ b/utils/mount/nfsmount.c
@@ -59,7 +59,6 @@
 #include "conn.h"
 #include "xcommon.h"
 #include "mount.h"
-#include "nfsumount.h"
 #include "nfs_mount.h"
 #include "mount_constants.h"
 #include "nls.h"
diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
index 8e4207f..e67a204 100644
--- a/utils/mount/nfsumount.c
+++ b/utils/mount/nfsumount.c
@@ -33,7 +33,6 @@
 
 #include "mount_constants.h"
 #include "mount.h"
-#include "nfsumount.h"
 #include "error.h"
 #include "network.h"
 
diff --git a/utils/mount/nfsumount.h b/utils/mount/nfsumount.h
deleted file mode 100644
index 0d67d27..0000000
--- a/utils/mount/nfsumount.h
+++ /dev/null
@@ -1,9 +0,0 @@
-#ifndef _NFS_UMOUNT_H
-#define _NFS_UMOUNT_H
-
-#include "conn.h"
-#include "mount.h"
-
-int nfsumount(int, char **);
-
-#endif


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

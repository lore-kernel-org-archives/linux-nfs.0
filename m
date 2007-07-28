From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 21/23] libnfs.a: eliminate conn.c and conn.h
Date: Sat, 28 Jul 2007 17:50:55 -0400
Message-ID: <20070728215055.21871.90209.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IFGOm-0003dy-3k
	for nfs@lists.sourceforge.net; Sun, 29 Jul 2007 14:34:00 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IFGOp-0003uU-I4
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

conn.[ch] are now no longer needed.  Clean them out and delete them.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/include/Makefile.am |    1 -
 support/include/conn.h      |   32 --------------------------------
 support/nfs/Makefile.am     |    2 +-
 support/nfs/conn.c          |   21 ---------------------
 utils/mount/network.c       |    1 -
 utils/mount/network.h       |   21 ++++++++++++++++++++-
 utils/mount/nfs4mount.c     |    1 -
 utils/mount/nfsmount.c      |    1 -
 utils/mount/nfsumount.c     |    1 -
 9 files changed, 21 insertions(+), 60 deletions(-)

diff --git a/support/include/Makefile.am b/support/include/Makefile.am
index a99882c..69c4503 100644
--- a/support/include/Makefile.am
+++ b/support/include/Makefile.am
@@ -3,7 +3,6 @@
 SUBDIRS = nfs rpcsvc sys
 
 noinst_HEADERS = \
-	conn.h \
 	exportfs.h \
 	fstab.h \
 	ha-callout.h \
diff --git a/support/include/conn.h b/support/include/conn.h
deleted file mode 100644
index 2b1f07d..0000000
--- a/support/include/conn.h
+++ /dev/null
@@ -1,32 +0,0 @@
-/* 
- * conn.h -- Connection routines for NFS mount / umount code.
- *
- * 2006-06-06 Amit Gud <agud@redhat.com>
- * - Moved code snippets here from util-linux/mount
- */
-
-#ifndef _CONN_H
-#define _CONN_H
-
-#ifdef HAVE_RPCSVC_NFS_PROT_H
-#include <rpcsvc/nfs_prot.h>
-#else
-#include <linux/nfs.h>
-#define nfsstat nfs_stat
-#endif
-
-#include <rpc/pmap_prot.h>
-#include <rpc/clnt.h>
-
-typedef struct {
-	char **hostname;
-	struct sockaddr_in saddr;
-	struct pmap pmap;
-} clnt_addr_t;
-
-/* RPC call timeout values */
-static const struct timeval TIMEOUT = { 20, 0 };
-static const struct timeval RETRY_TIMEOUT = { 3, 0 };
-
-#endif /* _CONN_H */
-
diff --git a/support/nfs/Makefile.am b/support/nfs/Makefile.am
index 6006df6..82353a9 100644
--- a/support/nfs/Makefile.am
+++ b/support/nfs/Makefile.am
@@ -4,7 +4,7 @@ noinst_LIBRARIES = libnfs.a
 libnfs_a_SOURCES = exports.c rmtab.c xio.c rpcmisc.c rpcdispatch.c \
 		   xlog.c xcommon.c wildmat.c nfssvc.c nfsclient.c \
 		   nfsexport.c getfh.c nfsctl.c \
-		   svc_socket.c cacheio.c closeall.c conn.c fstab.c nfs_mntent.c
+		   svc_socket.c cacheio.c closeall.c fstab.c nfs_mntent.c
 
 MAINTAINERCLEANFILES = Makefile.in
 
diff --git a/support/nfs/conn.c b/support/nfs/conn.c
deleted file mode 100644
index db9185d..0000000
--- a/support/nfs/conn.c
+++ /dev/null
@@ -1,21 +0,0 @@
-/*
- * conn.c -- NFS client mount / umount connection code support functions
- *
- * 2006-06-06 Amit Gud <agud@redhat.com>
- * - Moved code snippets to nfs-utils/support/nfs from util-linux/mount/nfsmount.c
- *
- */
-
-#include "config.h"
-#include <errno.h>
-#include <unistd.h>
-#include <rpc/rpc.h>
-#include <rpc/pmap_prot.h>
-#include <rpc/pmap_clnt.h>
-#include <sys/socket.h>
-#include <sys/stat.h>
-#include <netinet/in.h>
-#include <arpa/inet.h>
-
-#include "conn.h"
-
diff --git a/utils/mount/network.c b/utils/mount/network.c
index af37ef6..efedf25 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -34,7 +34,6 @@
 #include <rpc/pmap_clnt.h>
 #include <sys/socket.h>
 
-#include "conn.h"
 #include "xcommon.h"
 #include "mount.h"
 #include "nls.h"
diff --git a/utils/mount/network.h b/utils/mount/network.h
index 0f24a32..2e4dbbc 100644
--- a/utils/mount/network.h
+++ b/utils/mount/network.h
@@ -21,12 +21,31 @@
  *
  */
 
-#include "conn.h"
+#include <rpc/pmap_prot.h>
+#include <rpc/clnt.h>
+
 #include "mount.h"
 
+#ifdef HAVE_RPCSVC_NFS_PROT_H
+#include <rpcsvc/nfs_prot.h>
+#else
+#include <linux/nfs.h>
+#define nfsstat nfs_stat
+#endif
+
 #define MNT_SENDBUFSIZE (2048U)
 #define MNT_RECVBUFSIZE (1024U)
 
+typedef struct {
+	char **hostname;
+	struct sockaddr_in saddr;
+	struct pmap pmap;
+} clnt_addr_t;
+
+/* RPC call timeout values */
+static const struct timeval TIMEOUT = { 20, 0 };
+static const struct timeval RETRY_TIMEOUT = { 3, 0 };
+
 int probe_bothports(clnt_addr_t *, clnt_addr_t *);
 int nfs_gethostbyname(const char *, struct sockaddr_in *);
 int nfs_call_umount(clnt_addr_t *, dirpath *);
diff --git a/utils/mount/nfs4mount.c b/utils/mount/nfs4mount.c
index de97bd6..a4e2dc3 100644
--- a/utils/mount/nfs4mount.c
+++ b/utils/mount/nfs4mount.c
@@ -39,7 +39,6 @@
 
 #include "pseudoflavors.h"
 #include "nls.h"
-#include "conn.h"
 #include "xcommon.h"
 
 #include "mount_constants.h"
diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
index f1d3885..e137fe5 100644
--- a/utils/mount/nfsmount.c
+++ b/utils/mount/nfsmount.c
@@ -56,7 +56,6 @@
 #include <paths.h>
 #include <syslog.h>
 
-#include "conn.h"
 #include "xcommon.h"
 #include "mount.h"
 #include "nfs_mount.h"
diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
index e67a204..c7ec84e 100644
--- a/utils/mount/nfsumount.c
+++ b/utils/mount/nfsumount.c
@@ -29,7 +29,6 @@
 #include "xcommon.h"
 #include "fstab.h"
 #include "nls.h"
-#include "conn.h"
 
 #include "mount_constants.h"
 #include "mount.h"


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

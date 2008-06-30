From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 6/7] mount command: move function to get kernel version to
	separate header
Date: Mon, 30 Jun 2008 13:10:41 -0400
Message-ID: <20080630171041.9905.95339.stgit@ellison.1015granger.net>
References: <20080630170420.9905.90111.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:51835 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753552AbYF3RLI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2008 13:11:08 -0400
In-Reply-To: <20080630170420.9905.90111.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Share the code that reports the version of the running kernel.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/Makefile.am |    2 +-
 utils/mount/mount.c     |   18 +----------------
 utils/mount/nfsmount.c  |    5 ++---
 utils/mount/version.h   |   51 +++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 55 insertions(+), 21 deletions(-)
 create mode 100644 utils/mount/version.h


diff --git a/utils/mount/Makefile.am b/utils/mount/Makefile.am
index 27a01de..5a94631 100644
--- a/utils/mount/Makefile.am
+++ b/utils/mount/Makefile.am
@@ -13,7 +13,7 @@ mount_nfs_SOURCES = mount.c error.c network.c fstab.c token.c parse_opt.c \
 		    nfsmount.c nfs4mount.c stropts.c\
 		    nfsumount.c \
 		    mount_constants.h error.h network.h fstab.h token.h parse_opt.h \
-		    nfs4_mount.h nfs_mount4.h stropts.h
+		    nfs4_mount.h nfs_mount4.h stropts.h version.h
 
 mount_nfs_LDADD = ../../support/nfs/libnfs.a \
 		  ../../support/export/libexport.a
diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index d7271a1..a7d5733 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -29,7 +29,6 @@
 #include <errno.h>
 #include <fcntl.h>
 #include <sys/mount.h>
-#include <sys/utsname.h>
 #include <getopt.h>
 #include <mntent.h>
 #include <pwd.h>
@@ -47,6 +46,7 @@
 #include "error.h"
 #include "network.h"
 #include "stropts.h"
+#include "version.h"
 
 char *progname;
 int nfs_mount_data_version;
@@ -146,22 +146,6 @@ static const struct opt_map opt_map[] = {
   { NULL,	0, 0, 0		}
 };
 
-#define MAKE_VERSION(p,q,r)	(65536 * (p) + 256 * (q) + (r))
-
-int linux_version_code(void)
-{
-	struct utsname my_utsname;
-	int p, q, r;
-
-	if (uname(&my_utsname) == 0) {
-		p = atoi(strtok(my_utsname.release, "."));
-		q = atoi(strtok(NULL, "."));
-		r = atoi(strtok(NULL, "."));
-		return MAKE_VERSION(p,q,r);
-	}
-	return 0;
-}
-
 /*
  * Choose the version of the nfs_mount_data structure that is appropriate
  * for the kernel that is doing the mount.
diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
index 6a04518..b343a1f 100644
--- a/utils/mount/nfsmount.c
+++ b/utils/mount/nfsmount.c
@@ -67,6 +67,7 @@
 #include "nls.h"
 #include "error.h"
 #include "network.h"
+#include "version.h"
 
 #ifndef NFS_PORT
 #define NFS_PORT 2049
@@ -95,8 +96,6 @@ extern char *progname;
 extern int verbose;
 extern int sloppy;
 
-extern int linux_version_code(void);
-
 static inline enum clnt_stat
 nfs3_mount(CLIENT *clnt, mnt3arg_t *mnt3arg, mnt3res_t *mnt3res)
 {
@@ -808,7 +807,7 @@ noauth_flavors:
 	 * to avoid problems with multihomed hosts.
 	 * --Swen
 	 */
-	if (linux_version_code() <= 0x01030a && fsock != -1
+	if (linux_version_code() <= MAKE_VERSION(1, 3, 10) && fsock != -1
 	    && connect(fsock, (struct sockaddr *) nfs_saddr,
 		       sizeof (*nfs_saddr)) < 0) {
 		perror(_("nfs connect"));
diff --git a/utils/mount/version.h b/utils/mount/version.h
new file mode 100644
index 0000000..46552a1
--- /dev/null
+++ b/utils/mount/version.h
@@ -0,0 +1,51 @@
+/*
+ * version.h -- get running kernel version
+ *
+ * Copyright (C) 2008 Oracle.  All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public
+ * License as published by the Free Software Foundation; either
+ * version 2 of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public
+ * License along with this program; if not, write to the
+ * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
+ * Boston, MA 021110-1307, USA.
+ *
+ */
+
+#ifndef _NFS_UTILS_MOUNT_VERSION_H
+#define _NFS_UTILS_MOUNT_VERSION_H
+
+#include <stdlib.h>
+#include <string.h>
+
+#include <sys/utsname.h>
+
+static inline unsigned int MAKE_VERSION(unsigned int p, unsigned int q,
+					unsigned int r)
+{
+	return (65536 * p) + (256 * q) + r;
+}
+
+static inline unsigned int linux_version_code(void)
+{
+	struct utsname my_utsname;
+	unsigned int p, q, r;
+
+	if (uname(&my_utsname))
+		return 0;
+
+	p = atoi(strtok(my_utsname.release, "."));
+	q = atoi(strtok(NULL, "."));
+	r = atoi(strtok(NULL, "."));
+	return MAKE_VERSION(p, q, r);
+}
+
+#endif	/* _NFS_UTILS_MOUNT_VERSION_H */


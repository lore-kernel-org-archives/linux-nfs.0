From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 01/11] nfs-utils: move nfssvc.c to nfsd dir and clean up linking of nfsd
Date: Mon,  8 Jun 2009 14:00:34 -0400
Message-ID: <1244484044-21355-2-git-send-email-jlayton@redhat.com>
References: <1244484044-21355-1-git-send-email-jlayton@redhat.com>
Cc: chuck.lever@oracle.com, steved@redhat.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:48142 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751292AbZFHSAy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Jun 2009 14:00:54 -0400
In-Reply-To: <1244484044-21355-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

rpc.nfsd is the only user of nfssvc.c, so we might as well move it
out of libnfs.a.

Also, don't link in libexport.a and libmisc.a, they aren't needed.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 support/include/nfslib.h             |    1 -
 support/nfs/Makefile.am              |    2 +-
 utils/nfsd/Makefile.am               |    6 ++----
 utils/nfsd/nfsd.c                    |    1 +
 {support/nfs => utils/nfsd}/nfssvc.c |    2 +-
 utils/nfsd/nfssvc.h                  |   24 ++++++++++++++++++++++++
 6 files changed, 29 insertions(+), 7 deletions(-)
 rename {support/nfs => utils/nfsd}/nfssvc.c (99%)
 create mode 100644 utils/nfsd/nfssvc.h

diff --git a/support/include/nfslib.h b/support/include/nfslib.h
index ae98650..537a31e 100644
--- a/support/include/nfslib.h
+++ b/support/include/nfslib.h
@@ -130,7 +130,6 @@ int			wildmat(char *text, char *pattern);
  * nfsd library functions.
  */
 int			nfsctl(int, struct nfsctl_arg *, union nfsctl_res *);
-int			nfssvc(int port, int nrservs, unsigned int versbits, int minorvers4, unsigned int portbits, char *haddr);
 int			nfsaddclient(struct nfsctl_client *clp);
 int			nfsdelclient(struct nfsctl_client *clp);
 int			nfsexport(struct nfsctl_export *exp);
diff --git a/support/nfs/Makefile.am b/support/nfs/Makefile.am
index 86f52a1..096f56d 100644
--- a/support/nfs/Makefile.am
+++ b/support/nfs/Makefile.am
@@ -2,7 +2,7 @@
 
 noinst_LIBRARIES = libnfs.a
 libnfs_a_SOURCES = exports.c rmtab.c xio.c rpcmisc.c rpcdispatch.c \
-		   xlog.c xcommon.c wildmat.c nfssvc.c nfsclient.c \
+		   xlog.c xcommon.c wildmat.c nfsclient.c \
 		   nfsexport.c getfh.c nfsctl.c rpc_socket.c getport.c \
 		   svc_socket.c cacheio.c closeall.c nfs_mntent.c
 
diff --git a/utils/nfsd/Makefile.am b/utils/nfsd/Makefile.am
index 445e3fd..c4c6fb0 100644
--- a/utils/nfsd/Makefile.am
+++ b/utils/nfsd/Makefile.am
@@ -7,10 +7,8 @@ RPCPREFIX	= rpc.
 KPREFIX		= @kprefix@
 sbin_PROGRAMS	= nfsd
 
-nfsd_SOURCES = nfsd.c
-nfsd_LDADD = ../../support/export/libexport.a \
-	     ../../support/nfs/libnfs.a \
-	     ../../support/misc/libmisc.a
+nfsd_SOURCES = nfsd.c nfssvc.c
+nfsd_LDADD = ../../support/nfs/libnfs.a
 
 MAINTAINERCLEANFILES = Makefile.in
 
diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index e3c0094..8563c5c 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -25,6 +25,7 @@
 #include <arpa/inet.h>
 
 #include "nfslib.h"
+#include "nfssvc.h"
 
 static void	usage(const char *);
 
diff --git a/support/nfs/nfssvc.c b/utils/nfsd/nfssvc.c
similarity index 99%
rename from support/nfs/nfssvc.c
rename to utils/nfsd/nfssvc.c
index 33c15a7..6c5289a 100644
--- a/support/nfs/nfssvc.c
+++ b/utils/nfsd/nfssvc.c
@@ -1,5 +1,5 @@
 /*
- * support/nfs/nfssvc.c
+ * utils/nfsd/nfssvc.c
  *
  * Run an NFS daemon.
  *
diff --git a/utils/nfsd/nfssvc.h b/utils/nfsd/nfssvc.h
new file mode 100644
index 0000000..e77ff94
--- /dev/null
+++ b/utils/nfsd/nfssvc.h
@@ -0,0 +1,24 @@
+/*
+ *   utils/nfsd/nfssvc.h -- nfs service control routines for rpc.nfsd
+ *
+ *   Copyright (c) 2009 Red Hat, Inc.
+ *   Author(s): Jeff Layton (jlayton@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License along
+ * with this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
+ *
+ */
+
+int	nfssvc(int port, int nrservs, unsigned int versbits, int minorvers4,
+	       unsigned int portbits, char *haddr);
-- 
1.6.0.6


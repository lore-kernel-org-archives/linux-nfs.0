Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:33348 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727154AbeHJXPt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 10 Aug 2018 19:15:49 -0400
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.rdu2.redhat.com [10.11.54.4])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 7BDE9401EF2E
        for <linux-nfs@vger.kernel.org>; Fri, 10 Aug 2018 20:44:21 +0000 (UTC)
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH 2/2] nfsd: track when the user explicitly requested version 4.0
Date: Fri, 10 Aug 2018 16:44:21 -0400
Message-Id: <20180810204421.21882-3-smayhew@redhat.com>
In-Reply-To: <20180810204421.21882-1-smayhew@redhat.com>
References: <20180810204421.21882-1-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since both 'rpc.nfsd -V4' and 'rpc.nfsd -V4.0' alter bit 0 in 'minorversset'
and 'minorvers', it's not possible to know whether the user explicitly
requested version 4.0 or not.  Add another variable 'force4dot0' to track
when the user explicitly requested version 4.0 so that we can write '4.0'
to /proc/fs/nfsd/versions on kernel versions 4.11 and higher.  On earlier
kernels, we'll still write '4' as in the past.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 utils/nfsd/nfsd.c   | 11 ++++++++++-
 utils/nfsd/nfssvc.c | 14 +++++++++-----
 utils/nfsd/nfssvc.h |  3 ++-
 3 files changed, 21 insertions(+), 7 deletions(-)

diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index bd86d11..6b57e2b 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -72,6 +72,7 @@ main(int argc, char **argv)
 	unsigned int protobits = NFSCTL_PROTODEFAULT;
 	int grace = -1;
 	int lease = -1;
+	int force4dot0 = 0;
 
 	progname = basename(argv[0]);
 	haddr = xmalloc(sizeof(char *));
@@ -124,10 +125,14 @@ main(int argc, char **argv)
 		if (!conf_get_bool("nfsd", tag, 1)) {
 			NFSCTL_MINORSET(minorversset, i);
 			NFSCTL_MINORUNSET(minorvers, i);
+			if (i == 0)
+				force4dot0 = 1;
 		}
 		if (conf_get_bool("nfsd", tag, 0)) {
 			NFSCTL_MINORSET(minorversset, i);
 			NFSCTL_MINORSET(minorvers, i);
+			if (i == 0)
+				force4dot0 = 1;
 		}
 	}
 
@@ -188,6 +193,8 @@ main(int argc, char **argv)
 					}
 					NFSCTL_MINORSET(minorversset, i);
 					NFSCTL_MINORUNSET(minorvers, i);
+					if (i == 0)
+						force4dot0 = 1;
 					if (minorvers != 0)
 						break;
 				} else {
@@ -215,6 +222,8 @@ main(int argc, char **argv)
 					}
 					NFSCTL_MINORSET(minorversset, i);
 					NFSCTL_MINORSET(minorvers, i);
+					if (i == 0)
+						force4dot0 = 1;
 				} else
 					minorvers = minorversset = minormask;
 				/* FALLTHRU */
@@ -331,7 +340,7 @@ main(int argc, char **argv)
 	 * Timeouts must also be set before ports are created else we get
 	 * EBUSY.
 	 */
-	nfssvc_setvers(versbits, minorvers, minorversset);
+	nfssvc_setvers(versbits, minorvers, minorversset, force4dot0);
 	if (grace > 0)
 		nfssvc_set_time("grace", grace);
 	if (lease  > 0)
diff --git a/utils/nfsd/nfssvc.c b/utils/nfsd/nfssvc.c
index 7923f5d..1e6ffd6 100644
--- a/utils/nfsd/nfssvc.c
+++ b/utils/nfsd/nfssvc.c
@@ -25,6 +25,7 @@
 #include "nfslib.h"
 #include "xlog.h"
 #include "nfssvc.h"
+#include "../mount/version.h"
 
 #ifndef NFSD_FS_DIR
 #define NFSD_FS_DIR	  "/proc/fs/nfsd"
@@ -369,16 +370,18 @@ out:
 
 static int
 nfssvc_print_vers(char *ptr, unsigned size, unsigned vers, unsigned minorvers,
-		int isset)
+		int isset, int force4dot0)
 {
 	char sign = isset ? '+' : '-';
 	if (minorvers == 0)
-		return snprintf(ptr, size, "%c%u ", sign, vers);
+		if (linux_version_code() < MAKE_VERSION(4, 11, 0) || !force4dot0)
+			return snprintf(ptr, size, "%c%u ", sign, vers);
 	return snprintf(ptr, size, "%c%u.%u ", sign, vers, minorvers);
 }
 
 void
-nfssvc_setvers(unsigned int ctlbits, unsigned int minorvers, unsigned int minorversset)
+nfssvc_setvers(unsigned int ctlbits, unsigned int minorvers, unsigned int minorversset,
+	       int force4dot0)
 {
 	int fd, n, off;
 
@@ -389,13 +392,14 @@ nfssvc_setvers(unsigned int ctlbits, unsigned int minorvers, unsigned int minorv
 
 	for (n = NFSD_MINVERS; n <= ((NFSD_MAXVERS < 3) ? NFSD_MAXVERS : 3); n++)
 		off += nfssvc_print_vers(&buf[off], sizeof(buf) - off,
-				n, 0, NFSCTL_VERISSET(ctlbits, n));
+				n, 0, NFSCTL_VERISSET(ctlbits, n), 0);
 
 	for (n = 0; n <= NFS4_MAXMINOR; n++) {
 		if (!NFSCTL_MINORISSET(minorversset, n))
 			continue;
 		off += nfssvc_print_vers(&buf[off], sizeof(buf) - off,
-				4, n, NFSCTL_MINORISSET(minorvers, n));
+				4, n, NFSCTL_MINORISSET(minorvers, n),
+				(n == 0) ? force4dot0 : 0);
 	}
 	if (!off--)
 		goto out;
diff --git a/utils/nfsd/nfssvc.h b/utils/nfsd/nfssvc.h
index 39ebf37..4d53af1 100644
--- a/utils/nfsd/nfssvc.h
+++ b/utils/nfsd/nfssvc.h
@@ -26,6 +26,7 @@ int	nfssvc_set_sockets(const unsigned int protobits,
 			   const char *host, const char *port);
 void	nfssvc_set_time(const char *type, const int seconds);
 int	nfssvc_set_rdmaport(const char *port);
-void	nfssvc_setvers(unsigned int ctlbits, unsigned int minorvers4, unsigned int minorvers4set);
+void	nfssvc_setvers(unsigned int ctlbits, unsigned int minorvers4,
+		       unsigned int minorvers4set, int force4dot0);
 int	nfssvc_threads(int nrservs);
 void	nfssvc_get_minormask(unsigned int *mask);
-- 
2.14.4

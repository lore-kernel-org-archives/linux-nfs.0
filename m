From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/4] mount command: Use nfs_pmap_getport() in probe_statd()
Date: Mon, 01 Dec 2008 13:48:40 -0500
Message-ID: <20081201184840.10436.3202.stgit@ingres.1015granger.net>
References: <20081201183616.10436.71066.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: steved@redhat.com, linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:42965 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750770AbYLAStG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Dec 2008 13:49:06 -0500
In-Reply-To: <20081201183616.10436.71066.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Repace the getport() and clnt_ping() calls in probe_statd() with their
new shared equivalents.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |   34 ++++++++++++++++------------------
 1 files changed, 16 insertions(+), 18 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 806344c..0ba7bdb 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -47,6 +47,7 @@
 #include "nls.h"
 #include "nfs_mount.h"
 #include "mount_constants.h"
+#include "nfsrpc.h"
 #include "network.h"
 
 /*
@@ -79,6 +80,11 @@ extern int nfs_mount_data_version;
 extern char *progname;
 extern int verbose;
 
+static const char *nfs_ns_pgmtbl[] = {
+	"status",
+	NULL,
+};
+
 static const unsigned long nfs_to_mnt[] = {
 	0,
 	0,
@@ -669,24 +675,16 @@ version_fixed:
 	return probe_mntport(mnt_server);
 }
 
-static int probe_statd(void)
+static int nfs_probe_statd(void)
 {
-	struct sockaddr_in addr;
-	unsigned short port;
-
-	memset(&addr, 0, sizeof(addr));
-	addr.sin_family = AF_INET;
-	addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
-	port = getport(&addr, 100024, 1, IPPROTO_UDP);
-
-	if (port == 0)
-		return 0;
-	addr.sin_port = htons(port);
-
-	if (clnt_ping(&addr, 100024, 1, IPPROTO_UDP, NULL) <= 0)
-		return 0;
+	struct sockaddr_in addr = {
+		.sin_family		= AF_INET,
+		.sin_addr.s_addr	= htonl(INADDR_LOOPBACK),
+	};
+	rpcprog_t program = nfs_getrpcbyname(NSMPROG, nfs_ns_pgmtbl);
 
-	return 1;
+	return nfs_getport_ping((struct sockaddr *)&addr, sizeof(addr),
+				program, (rpcvers_t)1, IPPROTO_UDP);
 }
 
 /**
@@ -700,7 +698,7 @@ int start_statd(void)
 	struct stat stb;
 #endif
 
-	if (probe_statd())
+	if (nfs_probe_statd())
 		return 1;
 
 #ifdef START_STATD
@@ -718,7 +716,7 @@ int start_statd(void)
 				waitpid(pid, NULL,0);
 				break;
 			}
-			if (probe_statd())
+			if (nfs_probe_statd())
 				return 1;
 		}
 	}


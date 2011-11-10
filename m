Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:17677 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753184Ab1KJU02 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Nov 2011 15:26:28 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id pAAKQSq1013214
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 10 Nov 2011 15:26:28 -0500
Received: from bighat.boston.devel.redhat.com (bighat.boston.devel.redhat.com [10.16.60.55])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id pAAKQPED022338
	for <linux-nfs@vger.kernel.org>; Thu, 10 Nov 2011 15:26:27 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/2] nfsidmap: Added -v flag
Date: Thu, 10 Nov 2011 15:26:25 -0500
Message-Id: <1320956785-18004-3-git-send-email-steved@redhat.com>
In-Reply-To: <1320956785-18004-1-git-send-email-steved@redhat.com>
References: <1320956785-18004-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To aid in debugging, the -v flag can now be specified
on the command to enable verbose logging in both
the nfsidmap command and libnfsidmap library routines.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/nfsidmap/nfsidmap.c   |   12 ++++++++++++
 utils/nfsidmap/nfsidmap.man |   15 ++++++++++++---
 2 files changed, 24 insertions(+), 3 deletions(-)

diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
index 134d9bc..d74189a 100644
--- a/utils/nfsidmap/nfsidmap.c
+++ b/utils/nfsidmap/nfsidmap.c
@@ -12,6 +12,7 @@
 #include <syslog.h>
 #include "xlog.h"
 
+int verbose = 0;
 /* gcc nfsidmap.c -o nfsidmap -l nfsidmap -l keyutils */
 
 #define MAX_ID_LEN   11
@@ -108,6 +109,12 @@ int main(int argc, char **argv)
 	xlog_syslog(1);
 	xlog_stderr(0);
 
+	if (argc > 1 && strcmp(argv[1], "-v") == 0) {
+		verbose = 1;
+		nfs4_set_debug(1, NULL);
+		argc--, argv++;
+	}
+
 	if (argc < 3) {
 		xlog_err("Bad arg count. Check /etc/request-key.conf");
 		return 1;
@@ -126,6 +133,11 @@ int main(int argc, char **argv)
 
 	key = strtol(argv[1], NULL, 10);
 
+	if (verbose) {
+		xlog_warn("key: %ld type: %s value: %s timeout %ld",
+			key, type, value, timeout);
+	}
+
 	if (strcmp(type, "uid") == 0)
 		rc = id_lookup(value, key, USER);
 	else if (strcmp(type, "gid") == 0)
diff --git a/utils/nfsidmap/nfsidmap.man b/utils/nfsidmap/nfsidmap.man
index 2381908..aa4d94b 100644
--- a/utils/nfsidmap/nfsidmap.man
+++ b/utils/nfsidmap/nfsidmap.man
@@ -5,6 +5,8 @@
 .TH nfsidmap 5 "1 October 2010"
 .SH NAME
 nfsidmap \- The NFS idmapper upcall program
+.SH SYNOPSIS
+.B "nfsidmap [-v] key user [timeout]"
 .SH DESCRIPTION
 The file
 .I /usr/sbin/nfsidmap
@@ -14,9 +16,16 @@ the upcall and cache the result.
 .I /usr/sbin/nfsidmap
 should only be called by request-key, and will perform the translation and
 initialize a key with the resulting information.
-.PP
-NFS_USE_NEW_IDMAPPER must be selected when configuring the kernel to use this
-feature.
+.SH OPTIONS
+.TP
+.B -v
+Enables verbose logging in both the
+.B nfsidmap
+binary and in the library routines
+that are used.
+.B Note,
+the -v flag has to be the first argument on the
+command to enable the logging.
 .SH CONFIGURING
 The file
 .I /etc/request-key.conf
-- 
1.7.6.4


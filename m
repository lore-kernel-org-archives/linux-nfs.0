Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 178.141.211.66.inaddr.G4.NET ([66.211.141.178]:37419 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753281Ab1KLPzs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 12 Nov 2011 10:55:48 -0500
Received: from tophat.home.4dicksons.org ([192.168.62.20] helo=tophat.home.4dicksons.org.home.4dicksons.org)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1RPFtL-0003Ia-Ue
	for linux-nfs@vger.kernel.org; Sat, 12 Nov 2011 10:53:16 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/2] nfsidmap: Added Error Logging
Date: Sat, 12 Nov 2011 10:55:45 -0500
Message-Id: <1321113346-10106-2-git-send-email-steved@redhat.com>
In-Reply-To: <1321113346-10106-1-git-send-email-steved@redhat.com>
References: <1321113346-10106-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since this binary is being called by the kernel, errors
need to be logged to the syslog for help in debugging problems.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/nfsidmap/Makefile.am |    2 +-
 utils/nfsidmap/nfsidmap.c  |   34 ++++++++++++++++++++++++++++++----
 2 files changed, 31 insertions(+), 5 deletions(-)

diff --git a/utils/nfsidmap/Makefile.am b/utils/nfsidmap/Makefile.am
index f837b91..037aa79 100644
--- a/utils/nfsidmap/Makefile.am
+++ b/utils/nfsidmap/Makefile.am
@@ -4,6 +4,6 @@ man8_MANS = nfsidmap.man
 
 sbin_PROGRAMS	= nfsidmap
 nfsidmap_SOURCES = nfsidmap.c
-nfsidmap_LDADD = -lnfsidmap -lkeyutils
+nfsidmap_LDADD = -lnfsidmap -lkeyutils ../../support/nfs/libnfs.a
 
 MAINTAINERCLEANFILES = Makefile.in
diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
index 2d87381..134d9bc 100644
--- a/utils/nfsidmap/nfsidmap.c
+++ b/utils/nfsidmap/nfsidmap.c
@@ -10,6 +10,7 @@
 #include <nfsidmap.h>
 
 #include <syslog.h>
+#include "xlog.h"
 
 /* gcc nfsidmap.c -o nfsidmap -l nfsidmap -l keyutils */
 
@@ -36,9 +37,15 @@ int id_lookup(char *name_at_domain, key_serial_t key, int type)
 		rc = nfs4_group_owner_to_gid(name_at_domain, &gid);
 		sprintf(id, "%u", gid);
 	}
+	if (rc < 0)
+		xlog_err("id_lookup: %s: failed: %m",
+			(type == USER ? "nfs4_owner_to_uid" : "nfs4_group_owner_to_gid"));
 
-	if (rc == 0)
+	if (rc == 0) {
 		rc = keyctl_instantiate(key, id, strlen(id) + 1, 0);
+		if (rc < 0)
+			xlog_err("id_lookup: keyctl_instantiate failed: %m");
+	}
 
 	return rc;
 }
@@ -57,6 +64,7 @@ int name_lookup(char *id, key_serial_t key, int type)
 	rc = nfs4_get_default_domain(NULL, domain, NFS4_MAX_DOMAIN_LEN);
 	if (rc != 0) {
 		rc = -1;
+		xlog_err("name_lookup: nfs4_get_default_domain failed: %m");
 		goto out;
 	}
 
@@ -67,10 +75,15 @@ int name_lookup(char *id, key_serial_t key, int type)
 		gid = atoi(id);
 		rc = nfs4_gid_to_name(gid, domain, name, IDMAP_NAMESZ);
 	}
+	if (rc < 0)
+		xlog_err("name_lookup: %s: failed: %m",
+			(type == USER ? "nfs4_uid_to_name" : "nfs4_gid_to_name"));
 
-	if (rc == 0)
+	if (rc == 0) {
 		rc = keyctl_instantiate(key, &name, strlen(name), 0);
-
+		if (rc < 0)
+			xlog_err("name_lookup: keyctl_instantiate failed: %m");
+	}
 out:
 	return rc;
 }
@@ -83,9 +96,22 @@ int main(int argc, char **argv)
 	int rc = 1;
 	int timeout = 600;
 	key_serial_t key;
+	char *progname;
+
+	/* Set the basename */
+	if ((progname = strrchr(argv[0], '/')) != NULL)
+		progname++;
+	else
+		progname = argv[0];
 
-	if (argc < 3)
+	xlog_open(progname);
+	xlog_syslog(1);
+	xlog_stderr(0);
+
+	if (argc < 3) {
+		xlog_err("Bad arg count. Check /etc/request-key.conf");
 		return 1;
+	}
 
 	arg = malloc(sizeof(char) * strlen(argv[2]) + 1);
 	strcpy(arg, argv[2]);
-- 
1.7.7


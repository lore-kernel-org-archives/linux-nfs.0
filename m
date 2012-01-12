Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 178.141.211.66.inaddr.G4.NET ([66.211.141.178]:49192 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755266Ab2ALUPt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Jan 2012 15:15:49 -0500
Received: from tophat.home.4dicksons.org ([192.168.62.20] helo=tophat.home.4dicksons.org.home.4dicksons.org)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1RlR0w-0004gy-OH
	for linux-nfs@vger.kernel.org; Thu, 12 Jan 2012 15:12:47 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH v2] nfsidmap: Purge the keyring when its full.
Date: Thu, 12 Jan 2012 15:15:14 -0500
Message-Id: <1326399314-31920-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When a key can not be added to a keyring because
the keyring is full or there is no memory for
the playload, keyctl_instantiate() will fail
and set the errno to -EDQUOT, -ENFILE or
-ENOMEM

When this happens, purge the keyring to
free things up and then try to re-add
the key.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/nfsidmap/nfsidmap.c |   24 +++++++++++++++++++++---
 1 files changed, 21 insertions(+), 3 deletions(-)

diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
index ce8cf3e..cf11551 100644
--- a/utils/nfsidmap/nfsidmap.c
+++ b/utils/nfsidmap/nfsidmap.c
@@ -3,6 +3,7 @@
 #include <stdio.h>
 #include <stdlib.h>
 #include <string.h>
+#include <errno.h>
 
 #include <pwd.h>
 #include <grp.h>
@@ -25,6 +26,7 @@ char *usage="Usage: %s [-v] [-c || [-u|-g|-r key] || [-t timeout] key desc]";
 #define DEFAULT_KEYRING "id_resolver"
 #endif
 
+static int keyring_clear(char *keyring);
 
 #define UIDKEYS 0x1
 #define GIDKEYS 0x2
@@ -52,6 +54,22 @@ int id_lookup(char *name_at_domain, key_serial_t key, int type)
 
 	if (rc == 0) {
 		rc = keyctl_instantiate(key, id, strlen(id) + 1, 0);
+		if (rc < 0) {
+			switch(rc) {
+			case -EDQUOT:
+			case -ENFILE:
+			case -ENOMEM:
+				/*
+			 	 * The keyring is full. Clear the keyring and try again
+			 	 */
+				rc = keyring_clear(DEFAULT_KEYRING);
+				if (rc == 0)
+					rc = keyctl_instantiate(key, id, strlen(id) + 1, 0);
+				break;
+			default:
+				break;
+			}
+		}
 		if (rc < 0)
 			xlog_err("id_lookup: keyctl_instantiate failed: %m");
 	}
@@ -105,7 +123,6 @@ static int keyring_clear(char *keyring)
 	char buf[BUFSIZ];
 	key_serial_t key;
 
-	xlog_syslog(0);
 	if (keyring == NULL)
 		keyring = DEFAULT_KEYRING;
 
@@ -172,7 +189,7 @@ static int key_revoke(char *keystr, int keymask)
 		if ((keymask & mask) == 0)
 			continue;
 
-		if (strncmp(ptr+4, keystr, strlen(keystr)) != NULL)
+		if (strncmp(ptr+4, keystr, strlen(keystr)) != 0)
 			continue;
 
 		if (verbose) {
@@ -255,6 +272,7 @@ int main(int argc, char **argv)
 		return rc;		
 	}
 	if (clearing) {
+		xlog_syslog(0);
 		rc = keyring_clear(DEFAULT_KEYRING);
 		return rc;		
 	}
@@ -280,7 +298,7 @@ int main(int argc, char **argv)
 	value = strtok(NULL, ":");
 
 	if (verbose) {
-		xlog_warn("key: %ld type: %s value: %s timeout %ld",
+		xlog_warn("key: 0x%lx type: %s value: %s timeout %ld",
 			key, type, value, timeout);
 	}
 
-- 
1.7.7.5


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 178.141.211.66.inaddr.G4.NET ([66.211.141.178]:42555 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751465Ab2ALRHi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Jan 2012 12:07:38 -0500
Received: from tophat.home.4dicksons.org ([192.168.62.20] helo=tophat.home.4dicksons.org.home.4dicksons.org)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1RlN0R-0004WI-3h
	for linux-nfs@vger.kernel.org; Thu, 12 Jan 2012 10:55:59 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH] nfsidmap: Purge the keyring when its full.
Date: Thu, 12 Jan 2012 10:58:19 -0500
Message-Id: <1326383899-4358-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When a key can not be added to a keyring because
the keyring is full, keyctl_instantiate() will fail
with the errno being set to -EDQUOT. To recover,
purge the keyring of all its keys and then try to
add the new key.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/nfsidmap/nfsidmap.c |   14 ++++++++++++--
 1 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
index ce8cf3e..470f9d4 100644
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
@@ -52,6 +54,14 @@ int id_lookup(char *name_at_domain, key_serial_t key, int type)
 
 	if (rc == 0) {
 		rc = keyctl_instantiate(key, id, strlen(id) + 1, 0);
+		if (rc < 0 && errno == -EDQUOT) {
+			/*
+			 * The keyring is full. Clear the keyring and try again
+			 */
+			rc = keyring_clear(DEFAULT_KEYRING);
+			if (rc == 0)
+				rc = keyctl_instantiate(key, id, strlen(id) + 1, 0);
+		}
 		if (rc < 0)
 			xlog_err("id_lookup: keyctl_instantiate failed: %m");
 	}
@@ -105,7 +115,6 @@ static int keyring_clear(char *keyring)
 	char buf[BUFSIZ];
 	key_serial_t key;
 
-	xlog_syslog(0);
 	if (keyring == NULL)
 		keyring = DEFAULT_KEYRING;
 
@@ -172,7 +181,7 @@ static int key_revoke(char *keystr, int keymask)
 		if ((keymask & mask) == 0)
 			continue;
 
-		if (strncmp(ptr+4, keystr, strlen(keystr)) != NULL)
+		if (strncmp(ptr+4, keystr, strlen(keystr)) != 0)
 			continue;
 
 		if (verbose) {
@@ -255,6 +264,7 @@ int main(int argc, char **argv)
 		return rc;		
 	}
 	if (clearing) {
+		xlog_syslog(0);
 		rc = keyring_clear(DEFAULT_KEYRING);
 		return rc;		
 	}
-- 
1.7.7.5


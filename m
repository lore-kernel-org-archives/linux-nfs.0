Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f41.google.com ([209.85.192.41]:34098 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752123AbbHEOqF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Aug 2015 10:46:05 -0400
Received: by qgeu79 with SMTP id u79so31359742qge.1
        for <linux-nfs@vger.kernel.org>; Wed, 05 Aug 2015 07:46:05 -0700 (PDT)
Subject: [PATCH v2 4/6] nfsidmap: Fix error handling in id_lookup()
From: Chuck Lever <chuck.lever@oracle.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 05 Aug 2015 10:46:03 -0400
Message-ID: <20150805144603.13266.44699.stgit@manet.1015granger.net>
In-Reply-To: <20150805143258.13266.92369.stgit@manet.1015granger.net>
References: <20150805143258.13266.92369.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As near as I can tell, the exit status of nfsidmap is supposed to be
zero (success) or one (failure).

The return value of id_lookup() becomes the exit status, so it
should return only zero or one.

The libnfsidmap calls return a signed integer, either 0 or negative
errno values. These have to be translated to an exit status.

libkeyutils calls return a signed long, either 0 or -1. These also
have to be translated to an exit status.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 utils/nfsidmap/nfsidmap.c |   41 ++++++++++++++++++++++-------------------
 1 file changed, 22 insertions(+), 19 deletions(-)

diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
index 65b5511..9468c08 100644
--- a/utils/nfsidmap/nfsidmap.c
+++ b/utils/nfsidmap/nfsidmap.c
@@ -186,7 +186,7 @@ static int list_keyring(const char *keyring)
 /*
  * Find either a user or group id based on the name@domain string
  */
-int id_lookup(char *name_at_domain, key_serial_t key, int type)
+static int id_lookup(char *name_at_domain, key_serial_t key, int type)
 {
 	char id[MAX_ID_LEN];
 	uid_t uid = 0;
@@ -200,30 +200,33 @@ int id_lookup(char *name_at_domain, key_serial_t key, int type)
 		rc = nfs4_group_owner_to_gid(name_at_domain, &gid);
 		sprintf(id, "%u", gid);
 	}
-	if (rc < 0)
+	if (rc < 0) {
 		xlog_errno(rc, "id_lookup: %s: failed: %m",
 			(type == USER ? "nfs4_owner_to_uid" : "nfs4_group_owner_to_gid"));
+		return EXIT_FAILURE;
+	}
 
-	if (rc == 0) {
-		rc = keyctl_instantiate(key, id, strlen(id) + 1, 0);
-		if (rc < 0) {
-			switch(rc) {
-			case -EDQUOT:
-			case -ENFILE:
-			case -ENOMEM:
-				/*
-			 	 * The keyring is full. Clear the keyring and try again
-			 	 */
-				rc = keyring_clear(DEFAULT_KEYRING);
-				if (rc == 0)
-					rc = keyctl_instantiate(key, id, strlen(id) + 1, 0);
-				break;
-			default:
+	rc = EXIT_SUCCESS;
+	if (keyctl_instantiate(key, id, strlen(id) + 1, 0)) {
+		switch (errno) {
+		case EDQUOT:
+		case ENFILE:
+		case ENOMEM:
+			/*
+			 * The keyring is full. Clear the keyring and try again
+			 */
+			rc = keyring_clear(DEFAULT_KEYRING);
+			if (rc)
 				break;
+			if (keyctl_instantiate(key, id, strlen(id) + 1, 0)) {
+				rc = EXIT_FAILURE;
+				xlog_err("id_lookup: keyctl_instantiate failed: %m");
 			}
+			break;
+		default:
+			rc = EXIT_FAILURE;
+			break;
 		}
-		if (rc < 0)
-			xlog_err("id_lookup: keyctl_instantiate failed: %m");
 	}
 
 	return rc;


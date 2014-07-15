Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:60248 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753313AbaGOPJv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jul 2014 11:09:51 -0400
From: Steve Dickson <steved@redhat.com>
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 11/15] key_call: Convert local debug() calls to LIBTIRPC_DEBUG() calls
Date: Tue, 15 Jul 2014 11:09:30 -0400
Message-Id: <1405436974-4161-12-git-send-email-steved@redhat.com>
In-Reply-To: <1405436974-4161-1-git-send-email-steved@redhat.com>
References: <1405436974-4161-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 src/key_call.c | 21 ++++++++-------------
 1 file changed, 8 insertions(+), 13 deletions(-)

diff --git a/src/key_call.c b/src/key_call.c
index 906b2f6..8b9f388 100644
--- a/src/key_call.c
+++ b/src/key_call.c
@@ -59,16 +59,11 @@
 #include <sys/wait.h>
 #include <sys/fcntl.h>
 
+#include "dump.h"
 
 #define	KEY_TIMEOUT	5	/* per-try timeout in seconds */
 #define	KEY_NRETRY	12	/* number of retries */
 
-#ifdef DEBUG
-#define	debug(msg)	(void) fprintf(stderr, "%s\n", msg);
-#else
-#define	debug(msg)
-#endif /* DEBUG */
-
 /*
  * Hack to allow the keyserver to use AUTH_DES (for authenticated
  * NIS+ calls, for example).  The only functions that get called
@@ -96,7 +91,7 @@ key_setsecret(secretkey)
 		return (-1);
 	}
 	if (status != KEY_SUCCESS) {
-		debug("set status is nonzero");
+		LIBTIRPC_DEBUG(1, ("key_setsecret: set status is nonzero"));
 		return (-1);
 	}
 	return (0);
@@ -144,7 +139,7 @@ key_encryptsession_pk(remotename, remotekey, deskey)
 		return (-1);
 	}
 	if (res.status != KEY_SUCCESS) {
-		debug("encrypt status is nonzero");
+		LIBTIRPC_DEBUG(1, ("key_encryptsession_pk: encrypt status is nonzero"));
 		return (-1);
 	}
 	*deskey = res.cryptkeyres_u.deskey;
@@ -168,7 +163,7 @@ key_decryptsession_pk(remotename, remotekey, deskey)
 		return (-1);
 	}
 	if (res.status != KEY_SUCCESS) {
-		debug("decrypt status is nonzero");
+		LIBTIRPC_DEBUG(1, ("key_decryptsession_pk: decrypt status is nonzero"));
 		return (-1);
 	}
 	*deskey = res.cryptkeyres_u.deskey;
@@ -190,7 +185,7 @@ key_encryptsession(remotename, deskey)
 		return (-1);
 	}
 	if (res.status != KEY_SUCCESS) {
-		debug("encrypt status is nonzero");
+		LIBTIRPC_DEBUG(1, ("key_encryptsession: encrypt status is nonzero"));
 		return (-1);
 	}
 	*deskey = res.cryptkeyres_u.deskey;
@@ -212,7 +207,7 @@ key_decryptsession(remotename, deskey)
 		return (-1);
 	}
 	if (res.status != KEY_SUCCESS) {
-		debug("decrypt status is nonzero");
+		LIBTIRPC_DEBUG(1, ("key_decryptsession: decrypt status is nonzero"));
 		return (-1);
 	}
 	*deskey = res.cryptkeyres_u.deskey;
@@ -243,7 +238,7 @@ struct key_netstarg *arg;
 	}
 
 	if (status != KEY_SUCCESS) {
-		debug("key_setnet status is nonzero");
+		LIBTIRPC_DEBUG(1, ("key_setnet: key_setnet status is nonzero"));
 		return (-1);
 	}
 	return (1);
@@ -262,7 +257,7 @@ key_get_conv(pkey, deskey)
 		return (-1);
 	}
 	if (res.status != KEY_SUCCESS) {
-		debug("get_conv status is nonzero");
+		LIBTIRPC_DEBUG(1, ("key_get_conv: get_conv status is nonzero"));
 		return (-1);
 	}
 	*deskey = res.cryptkeyres_u.deskey;
-- 
1.9.3


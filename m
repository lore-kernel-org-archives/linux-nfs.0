Return-Path: linux-nfs-owner@vger.kernel.org
Received: from vader.hardeman.nu ([95.142.160.32]:51263 "EHLO hardeman.nu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752696AbaLIFlF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Dec 2014 00:41:05 -0500
Subject: [PATCH 03/19] nfs-utils: gssd - simplify some option handling
From: David =?utf-8?b?SMOkcmRlbWFu?= <david@hardeman.nu>
To: linux-nfs@vger.kernel.org
Cc: SteveD@redhat.com
Date: Tue, 09 Dec 2014 06:40:55 +0100
Message-ID: <20141209054055.24756.45134.stgit@zeus.muc.hardeman.nu>
In-Reply-To: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
References: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Using PATH_MAX in modern code is almost always a bad idea. Simplify
the code and remove that arbitrary limitation at the same time.

Signed-off-by: David Härdeman <david@hardeman.nu>
---
 utils/gssd/gssd.c |   12 ++++--------
 utils/gssd/gssd.h |    4 ++--
 2 files changed, 6 insertions(+), 10 deletions(-)

diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index 5e580e7..6147d30 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -67,8 +67,8 @@
 #include "krb5_util.h"
 #include "nfslib.h"
 
-static char pipefs_dir[PATH_MAX] = GSSD_PIPEFS_DIR;
-char keytabfile[PATH_MAX] = GSSD_DEFAULT_KEYTAB_FILE;
+static char *pipefs_dir = GSSD_PIPEFS_DIR;
+char *keytabfile = GSSD_DEFAULT_KEYTAB_FILE;
 char ccachedir[PATH_MAX] = GSSD_DEFAULT_CRED_DIR ":" GSSD_USER_CRED_DIR;
 char *ccachesearch[GSSD_MAX_CCACHE_SEARCH + 1];
 int  use_memcache = 0;
@@ -341,14 +341,10 @@ main(int argc, char *argv[])
 				rpc_verbosity++;
 				break;
 			case 'p':
-				strncpy(pipefs_dir, optarg, sizeof(pipefs_dir));
-				if (pipefs_dir[sizeof(pipefs_dir)-1] != '\0')
-					errx(1, "pipefs path name too long");
+				pipefs_dir = optarg;
 				break;
 			case 'k':
-				strncpy(keytabfile, optarg, sizeof(keytabfile));
-				if (keytabfile[sizeof(keytabfile)-1] != '\0')
-					errx(1, "keytab path name too long");
+				keytabfile = optarg;
 				break;
 			case 'd':
 				strncpy(ccachedir, optarg, sizeof(ccachedir));
diff --git a/utils/gssd/gssd.h b/utils/gssd/gssd.h
index e16b187..4059544 100644
--- a/utils/gssd/gssd.h
+++ b/utils/gssd/gssd.h
@@ -58,8 +58,8 @@
  */
 enum {AUTHTYPE_KRB5, AUTHTYPE_LIPKEY};
 
-extern char			keytabfile[PATH_MAX];
-extern char			*ccachesearch[];
+extern char		       *keytabfile;
+extern char		       *ccachesearch[];
 extern int			use_memcache;
 extern int			root_uses_machine_creds;
 extern unsigned int 		context_timeout;


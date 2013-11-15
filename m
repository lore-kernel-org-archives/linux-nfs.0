Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qe0-f45.google.com ([209.85.128.45]:43670 "EHLO
	mail-qe0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753244Ab3KOTPj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Nov 2013 14:15:39 -0500
Received: by mail-qe0-f45.google.com with SMTP id 9so1461125qea.18
        for <linux-nfs@vger.kernel.org>; Fri, 15 Nov 2013 11:15:39 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] gssd: don't let parent exit until child has a chance to scan directory once
Date: Fri, 15 Nov 2013 14:15:31 -0500
Message-Id: <1384542931-18753-3-git-send-email-jlayton@redhat.com>
In-Reply-To: <1384542931-18753-1-git-send-email-jlayton@redhat.com>
References: <1384542931-18753-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

With some proposed kernel changes, it won't even attempt to upcall
sometimes if it doesn't appear that gssd is running. This means that
we have a theoretical race between gssd starting up at boot time and
the init process attempting to mount kerberized filesystems.

Fix this by switching gssd to use mydaemon() and having the child
only release the parent after it has processed the directory once.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/gssd/gssd.c           | 6 ++++--
 utils/gssd/gssd.h           | 1 +
 utils/gssd/gssd_main_loop.c | 4 ++++
 3 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index 8ee478b..fdad153 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -54,6 +54,7 @@
 #include "err_util.h"
 #include "gss_util.h"
 #include "krb5_util.h"
+#include "nfslib.h"
 
 char pipefs_dir[PATH_MAX] = GSSD_PIPEFS_DIR;
 char keytabfile[PATH_MAX] = GSSD_DEFAULT_KEYTAB_FILE;
@@ -63,6 +64,7 @@ int  use_memcache = 0;
 int  root_uses_machine_creds = 1;
 unsigned int  context_timeout = 0;
 char *preferred_realm = NULL;
+int pipefds[2] = { -1, -1 };
 
 void
 sig_die(int signal)
@@ -187,8 +189,8 @@ main(int argc, char *argv[])
 	if (gssd_check_mechs() != 0)
 		errx(1, "Problem with gssapi library");
 
-	if (!fg && daemon(0, 0) < 0)
-		errx(1, "fork");
+	if (!fg)
+		mydaemon(0, 0, pipefds);
 
 	signal(SIGINT, sig_die);
 	signal(SIGTERM, sig_die);
diff --git a/utils/gssd/gssd.h b/utils/gssd/gssd.h
index 86472a1..47995b7 100644
--- a/utils/gssd/gssd.h
+++ b/utils/gssd/gssd.h
@@ -67,6 +67,7 @@ extern int			use_memcache;
 extern int			root_uses_machine_creds;
 extern unsigned int 		context_timeout;
 extern char			*preferred_realm;
+extern int			pipefds[2];
 
 TAILQ_HEAD(clnt_list_head, clnt_info) clnt_list;
 
diff --git a/utils/gssd/gssd_main_loop.c b/utils/gssd/gssd_main_loop.c
index ccf7fe5..9970028 100644
--- a/utils/gssd/gssd_main_loop.c
+++ b/utils/gssd/gssd_main_loop.c
@@ -53,6 +53,7 @@
 
 #include "gssd.h"
 #include "err_util.h"
+#include "nfslib.h"
 
 extern struct pollfd *pollarray;
 extern unsigned long pollsize;
@@ -245,6 +246,9 @@ gssd_run()
 				/* Error msg is already printed */
 				exit(1);
 			}
+
+			/* release the parent after the initial dir scan */
+			release_parent(pipefds);
 		}
 		gssd_poll(pollarray, pollsize);
 	}
-- 
1.8.3.1


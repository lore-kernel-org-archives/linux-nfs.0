Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:62996 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753540AbbIUUup (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Sep 2015 16:50:45 -0400
From: <andros@netapp.com>
To: <steved@redhat.com>
CC: <jlayton@poochiereds.net>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH 4/4] GSSD: clean up machine credentials
Date: Mon, 21 Sep 2015 16:50:09 -0400
Message-ID: <1442868609-1812-5-git-send-email-andros@netapp.com>
In-Reply-To: <1442868609-1812-1-git-send-email-andros@netapp.com>
References: <1442868609-1812-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Since we no longer fork for uid 0, gssd_atexit() is only called when uid != 0,
and fails as permissions on the /tmp/krb5ccmachine_REALM file prohibit
the clean up of machine credentials (as it should).

Move the reaping of machine credentials back into a SIGINT sighandler so that
<Ctrl C> destroyes machine credentials.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 utils/gssd/gssd.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index 2a768ea..ebff860 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -729,10 +729,12 @@ found:
 }
 
 static void
-gssd_atexit(void)
+sig_die(int signal)
 {
 	if (root_uses_machine_creds)
 		gssd_destroy_krb5_machine_creds();
+	printerr(1, "exiting on signal %d\n", signal);
+	exit(0);
 }
 
 static void
@@ -892,17 +894,13 @@ main(int argc, char *argv[])
 		exit(EXIT_FAILURE);
 	}
 
-	if (atexit(gssd_atexit)) {
-		printerr(1, "ERROR: atexit failed: %s\n", strerror(errno));
-		exit(EXIT_FAILURE);
-	}
-
 	inotify_fd = inotify_init1(IN_NONBLOCK);
 	if (inotify_fd == -1) {
 		printerr(1, "ERROR: inotify_init1 failed: %s\n", strerror(errno));
 		exit(EXIT_FAILURE);
 	}
 
+	signal(SIGINT, sig_die);
 	signal_set(&sighup_ev, SIGHUP, gssd_scan_cb, NULL);
 	signal_add(&sighup_ev, NULL);
 	event_set(&inotify_ev, inotify_fd, EV_READ | EV_PERSIST, gssd_inotify_cb, NULL);
-- 
1.9.3 (Apple Git-50)


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from vader.hardeman.nu ([95.142.160.32]:51291 "EHLO hardeman.nu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751230AbaLIFmP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Dec 2014 00:42:15 -0500
Subject: [PATCH 17/19] nfs-utils: gssd - further shorten some pathnames
From: David =?utf-8?b?SMOkcmRlbWFu?= <david@hardeman.nu>
To: linux-nfs@vger.kernel.org
Cc: SteveD@redhat.com
Date: Tue, 09 Dec 2014 06:42:06 +0100
Message-ID: <20141209054206.24756.97.stgit@zeus.muc.hardeman.nu>
In-Reply-To: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
References: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Save some more memory by using relative pathnames.

Signed-off-by: David Härdeman <david@hardeman.nu>
---
 utils/gssd/gssd.c |   16 +++++++---------
 1 file changed, 7 insertions(+), 9 deletions(-)

diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index 4409ad6..b7a4950 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -95,8 +95,7 @@ struct topdir {
 	TAILQ_ENTRY(topdir) list;
 	TAILQ_HEAD(clnt_list_head, clnt_info) clnt_list;
 	int wd;
-	char *name;
-	char dirname[];
+	char name[];
 };
 
 /*
@@ -514,7 +513,7 @@ gssd_get_topdir(const char *name)
 		if (!strcmp(tdi->name, name))
 			return tdi;
 
-	tdi = malloc(sizeof(*tdi) + strlen(pipefs_path) + strlen(name) + 2);
+	tdi = malloc(sizeof(*tdi) + strlen(name) + 1);
 	if (!tdi) {
 		printerr(0, "ERROR: Couldn't allocate struct topdir\n");
 		return NULL;
@@ -522,14 +521,13 @@ gssd_get_topdir(const char *name)
 
 	tdi->wd = inotify_add_watch(inotify_fd, name, IN_CREATE | IN_DELETE);
 	if (tdi->wd < 0) {
-		printerr(0, "ERROR: inotify_add_watch failed for %s: %s\n",
-			 tdi->dirname, strerror(errno));
+		printerr(0, "ERROR: inotify_add_watch failed for top dir %s: %s\n",
+			 tdi->name, strerror(errno));
 		free(tdi);
 		return NULL;
 	}
 
-	sprintf(tdi->dirname, "%s/%s", pipefs_path, name);
-	tdi->name = tdi->dirname + strlen(pipefs_path) + 1;
+	strcpy(tdi->name, name);
 	TAILQ_INIT(&tdi->clnt_list);
 
 	TAILQ_INSERT_HEAD(&topdir_list, tdi, list);
@@ -552,14 +550,14 @@ gssd_scan_topdir(const char *name)
 	dfd = openat(pipefs_fd, tdi->name, O_RDONLY);
 	if (dfd < 0) {
 		printerr(0, "ERROR: can't openat %s: %s\n",
-			 tdi->dirname, strerror(errno));
+			 tdi->name, strerror(errno));
 		return;
 	}
 
 	dir = fdopendir(dfd);
 	if (!dir) {
 		printerr(0, "ERROR: can't fdopendir %s: %s\n",
-			 tdi->dirname, strerror(errno));
+			 tdi->name, strerror(errno));
 		return;
 	}
 


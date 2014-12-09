Return-Path: linux-nfs-owner@vger.kernel.org
Received: from vader.hardeman.nu ([95.142.160.32]:51294 "EHLO hardeman.nu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752655AbaLIFmU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Dec 2014 00:42:20 -0500
Subject: [PATCH 18/19] nfs-utils: gssd - improve inotify
From: David =?utf-8?b?SMOkcmRlbWFu?= <david@hardeman.nu>
To: linux-nfs@vger.kernel.org
Cc: SteveD@redhat.com
Date: Tue, 09 Dec 2014 06:42:11 +0100
Message-ID: <20141209054211.24756.86406.stgit@zeus.muc.hardeman.nu>
In-Reply-To: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
References: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make full use of inotify by not rescanning the whole tree on each change,
instead keep track of the inotify events and make sure that the minimum
work (scan/create/delete) clients is done in most cases. Still detect
anomalies and perform a full rescan in those cases.

Signed-off-by: David Härdeman <david@hardeman.nu>
---
 utils/gssd/gssd.c      |  167 +++++++++++++++++++++++++++++++++---------------
 utils/gssd/gssd_proc.c |    1 
 2 files changed, 116 insertions(+), 52 deletions(-)

diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index b7a4950..2a768ea 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -362,36 +362,18 @@ gssd_destroy_client(struct clnt_info *clp)
 static void gssd_scan(void);
 
 static void
-gssd_clnt_gssd_cb(int UNUSED(fd), short which, void *data)
+gssd_clnt_gssd_cb(int UNUSED(fd), short UNUSED(which), void *data)
 {
 	struct clnt_info *clp = data;
 
-	if (which != EV_READ) {
-		printerr(2, "Closing 'gssd' pipe %s\n", clp->relpath);
-		close(clp->gssd_fd);
-		clp->gssd_fd = -1;
-		event_del(&clp->gssd_ev);
-		gssd_scan();
-		return;
-	}
-
 	handle_gssd_upcall(clp);
 }
 
 static void
-gssd_clnt_krb5_cb(int UNUSED(fd), short which, void *data)
+gssd_clnt_krb5_cb(int UNUSED(fd), short UNUSED(which), void *data)
 {
 	struct clnt_info *clp = data;
 
-	if (which != EV_READ) {
-		printerr(2, "Closing 'krb5' pipe %s\n", clp->relpath);
-		close(clp->krb5_fd);
-		clp->krb5_fd = -1;
-		event_del(&clp->krb5_ev);
-		gssd_scan();
-		return;
-	}
-
 	handle_krb5_upcall(clp);
 }
 
@@ -437,17 +419,12 @@ out:
 }
 
 static int
-gssd_scan_clnt(struct topdir *tdi, const char *name)
+gssd_scan_clnt(struct clnt_info *clp)
 {
-	struct clnt_info *clp;
 	int clntfd;
 	bool gssd_was_closed;
 	bool krb5_was_closed;
 
-	clp = gssd_get_clnt(tdi, name);
-	if (!clp)
-		return -1;
-
 	gssd_was_closed = clp->gssd_fd < 0 ? true : false;
 	krb5_was_closed = clp->krb5_fd < 0 ? true : false;
 
@@ -459,24 +436,10 @@ gssd_scan_clnt(struct topdir *tdi, const char *name)
 	}
 
 	if (clp->gssd_fd == -1)
-		clp->gssd_fd = openat(clntfd, "gssd", O_RDWR);
+		clp->gssd_fd = openat(clntfd, "gssd", O_RDWR | O_NONBLOCK);
 
-	if (clp->gssd_fd == -1) {
-		if (clp->krb5_fd == -1)
-			clp->krb5_fd = openat(clntfd, "krb5", O_RDWR);
-
-		/* If we opened a gss-specific pipe, let's try opening
-		 * the new upcall pipe again. If we succeed, close
-		 * gss-specific pipe(s).
-		 */
-		if (clp->krb5_fd != -1) {
-			clp->gssd_fd = openat(clntfd, "gssd", O_RDWR);
-			if (clp->gssd_fd != -1) {
-				close(clp->krb5_fd);
-				clp->krb5_fd = -1;
-			}
-		}
-	}
+	if (clp->gssd_fd == -1 && clp->krb5_fd == -1)
+		clp->krb5_fd = openat(clntfd, "krb5", O_RDWR | O_NONBLOCK);
 
 	if (gssd_was_closed && clp->gssd_fd >= 0) {
 		event_set(&clp->gssd_ev, clp->gssd_fd, EV_READ | EV_PERSIST,
@@ -490,7 +453,7 @@ gssd_scan_clnt(struct topdir *tdi, const char *name)
 		event_add(&clp->krb5_ev, NULL);
 	}
 
-	if ((clp->krb5_fd == -1) && (clp->gssd_fd == -1))
+	if (clp->krb5_fd == -1 && clp->gssd_fd == -1)
 		/* not fatal, files might appear later */
 		goto out;
 
@@ -503,6 +466,17 @@ out:
 	return 0;
 }
 
+static int
+gssd_create_clnt(struct topdir *tdi, const char *name)
+{
+	struct clnt_info *clp;
+
+	clp = gssd_get_clnt(tdi, name);
+	if (!clp)
+		return -1;
+
+	return gssd_scan_clnt(clp);
+}
 
 static struct topdir *
 gssd_get_topdir(const char *name)
@@ -519,7 +493,7 @@ gssd_get_topdir(const char *name)
 		return NULL;
 	}
 
-	tdi->wd = inotify_add_watch(inotify_fd, name, IN_CREATE | IN_DELETE);
+	tdi->wd = inotify_add_watch(inotify_fd, name, IN_CREATE);
 	if (tdi->wd < 0) {
 		printerr(0, "ERROR: inotify_add_watch failed for top dir %s: %s\n",
 			 tdi->name, strerror(errno));
@@ -571,7 +545,7 @@ gssd_scan_topdir(const char *name)
 		if (strncmp(d->d_name, "clnt", strlen("clnt")))
 			continue;
 
-		gssd_scan_clnt(tdi, d->d_name);
+		gssd_create_clnt(tdi, d->d_name);
 	}
 
 	closedir(dir);
@@ -595,6 +569,7 @@ gssd_scan(void)
 {
 	struct dirent *d;
 
+	printerr(3, "doing a full rescan\n");
 	rewinddir(pipefs_dir);
 
 	while ((d = readdir(pipefs_dir))) {
@@ -619,10 +594,84 @@ gssd_scan_cb(int UNUSED(fd), short UNUSED(which), void *UNUSED(data))
 	gssd_scan();
 }
 
+static bool
+gssd_inotify_topdir(struct topdir *tdi, const struct inotify_event *ev)
+{
+	printerr(5, "inotify event for topdir (%s) - "
+		 "ev->wd (%d) ev->name (%s) ev->mask (0x%08x)\n",
+		 tdi->name, ev->wd, ev->len > 0 ? ev->name : "<?>", ev->mask);
+
+	if (ev->mask & IN_IGNORED) {
+		printerr(0, "ERROR: topdir disappeared!\n");
+		return false;
+	}
+
+	if (ev->len == 0)
+		return false;
+
+	if (ev->mask & IN_CREATE) {
+		if (!(ev->mask & IN_ISDIR))
+			return true;
+
+		if (strncmp(ev->name, "clnt", strlen("clnt")))
+			return true;
+
+		if (gssd_create_clnt(tdi, ev->name))
+			return false;
+
+		return true;
+	} 
+
+	return false;
+}
+
+static bool
+gssd_inotify_clnt(struct topdir *tdi, struct clnt_info *clp, const struct inotify_event *ev)
+{
+	printerr(5, "inotify event for clntdir (%s) - "
+		 "ev->wd (%d) ev->name (%s) ev->mask (0x%08x)\n",
+		 clp->relpath, ev->wd, ev->len > 0 ? ev->name : "<?>", ev->mask);
+
+	if (ev->mask & IN_IGNORED) {
+		TAILQ_REMOVE(&tdi->clnt_list, clp, list);
+		gssd_destroy_client(clp);
+		return true;
+	}
+
+	if (ev->len == 0)
+		return false;
+
+	if (ev->mask & IN_CREATE) {
+		if (!strcmp(ev->name, "gssd") ||
+		    !strcmp(ev->name, "krb5") ||
+		    !strcmp(ev->name, "info"))
+			if (gssd_scan_clnt(clp))
+				return false;
+
+		return true;
+
+	} else if (ev->mask & IN_DELETE) {
+		if (!strcmp(ev->name, "gssd") && clp->gssd_fd >= 0) {
+			close(clp->gssd_fd);
+			event_del(&clp->gssd_ev);
+			clp->gssd_fd = -1;
+
+		} else if (!strcmp(ev->name, "krb5") && clp->krb5_fd >= 0) {
+			close(clp->krb5_fd);
+			event_del(&clp->krb5_ev);
+			clp->krb5_fd = -1;
+		}
+
+		return true;
+	}
+
+	return false;
+}
+
 static void
 gssd_inotify_cb(int ifd, short UNUSED(which), void *UNUSED(data))
 {
-	bool rescan = true; /* unconditional rescan, for now */
+	bool rescan = false;
 	struct topdir *tdi;
 	struct clnt_info *clp;
 
@@ -646,18 +695,32 @@ gssd_inotify_cb(int ifd, short UNUSED(which), void *UNUSED(data))
 			if (ev->mask & IN_Q_OVERFLOW) {
 				printerr(0, "ERROR: inotify queue overflow\n");
 				rescan = true;
+				break;
 			}
 
-			/* NOTE: Set rescan if wd not found */
 			TAILQ_FOREACH(tdi, &topdir_list, list) {
-				if (tdi->wd == ev->wd)
-					break;
+				if (tdi->wd == ev->wd) {
+					if (!gssd_inotify_topdir(tdi, ev))
+						rescan = true;
+					goto found;
+				}
 
 				TAILQ_FOREACH(clp, &tdi->clnt_list, list) {
-					if (clp->wd == ev->wd)
-						break;
+					if (clp->wd == ev->wd) {
+						if (!gssd_inotify_clnt(tdi, clp, ev))
+							rescan = true;
+						goto found;
+					}
 				}
 			}
+
+found:
+			if (!tdi) {
+				printerr(1, "inotify event for unknown wd!!! - "
+					 "ev->wd (%d) ev->name (%s) ev->mask (0x%08x)\n",
+					 ev->wd, ev->len > 0 ? ev->name : "<?>", ev->mask);
+				rescan = true;
+			}
 		}
 	}
 
diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index c16f111..a5a46ef 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -9,6 +9,7 @@
   Copyright (c) 2002 Marius Aamodt Eriksen <marius@UMICH.EDU>.
   Copyright (c) 2002 Bruce Fields <bfields@UMICH.EDU>
   Copyright (c) 2004 Kevin Coffman <kwc@umich.edu>
+  Copyright (c) 2014 David Härdeman <david@hardeman.nu>
   All rights reserved, all wrongs reversed.
 
   Redistribution and use in source and binary forms, with or without


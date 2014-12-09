Return-Path: linux-nfs-owner@vger.kernel.org
Received: from vader.hardeman.nu ([95.142.160.32]:51289 "EHLO hardeman.nu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752655AbaLIFmK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Dec 2014 00:42:10 -0500
Subject: [PATCH 16/19] nfs-utils: gssd - change dnotify to inotify
From: David =?utf-8?b?SMOkcmRlbWFu?= <david@hardeman.nu>
To: linux-nfs@vger.kernel.org
Cc: SteveD@redhat.com
Date: Tue, 09 Dec 2014 06:42:00 +0100
Message-ID: <20141209054200.24756.33858.stgit@zeus.muc.hardeman.nu>
In-Reply-To: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
References: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is just the first step, replacing dnotify with an inotify
implementation that is not much better (still does a complete
rescan of the whole rpc_pipefs tree on each change).

Signed-off-by: David Härdeman <david@hardeman.nu>
---
 utils/gssd/gssd.c |  101 ++++++++++++++++++++++++++++++++++++++---------------
 utils/gssd/gssd.h |    2 +
 2 files changed, 73 insertions(+), 30 deletions(-)

diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index 78b836d..4409ad6 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -48,7 +48,7 @@
 #include <sys/socket.h>
 #include <sys/time.h>
 #include <sys/resource.h>
-#include <sys/poll.h>
+#include <sys/inotify.h>
 #include <rpc/rpc.h>
 #include <netinet/in.h>
 #include <arpa/inet.h>
@@ -75,6 +75,8 @@
 static char *pipefs_path = GSSD_PIPEFS_DIR;
 static DIR *pipefs_dir;
 static int pipefs_fd;
+static int inotify_fd;
+struct event inotify_ev;
 
 char *keytabfile = GSSD_DEFAULT_KEYTAB_FILE;
 char **ccachesearch;
@@ -92,7 +94,7 @@ TAILQ_HEAD(topdir_list_head, topdir) topdir_list;
 struct topdir {
 	TAILQ_ENTRY(topdir) list;
 	TAILQ_HEAD(clnt_list_head, clnt_info) clnt_list;
-	int fd;
+	int wd;
 	char *name;
 	char dirname[];
 };
@@ -350,9 +352,7 @@ gssd_destroy_client(struct clnt_info *clp)
 		event_del(&clp->gssd_ev);
 	}
 
-	if (clp->dir_fd >= 0)
-		close(clp->dir_fd);
-
+	inotify_rm_watch(inotify_fd, clp->wd);
 	free(clp->relpath);
 	free(clp->servicename);
 	free(clp->servername);
@@ -417,20 +417,16 @@ gssd_get_clnt(struct topdir *tdi, const char *name)
 		goto out;
 	}
 
-	clp->name = clp->relpath + strlen(tdi->name) + 1;
-	clp->krb5_fd = -1;
-	clp->gssd_fd = -1;
-	clp->dir_fd = -1;
-
-	if ((clp->dir_fd = open(clp->relpath, O_RDONLY)) == -1) {
-		if (errno != ENOENT)
-			printerr(0, "ERROR: can't open %s: %s\n",
-				 clp->relpath, strerror(errno));
+	clp->wd = inotify_add_watch(inotify_fd, clp->relpath, IN_CREATE | IN_DELETE);
+	if (clp->wd < 0) {
+		printerr(0, "ERROR: inotify_add_watch failed for %s: %s\n",
+			 clp->relpath, strerror(errno));
 		goto out;
 	}
 
-	fcntl(clp->dir_fd, F_SETSIG, DNOTIFY_SIGNAL);
-	fcntl(clp->dir_fd, F_NOTIFY, DN_CREATE | DN_DELETE | DN_MULTISHOT);
+	clp->name = clp->relpath + strlen(tdi->name) + 1;
+	clp->krb5_fd = -1;
+	clp->gssd_fd = -1;
 
 	TAILQ_INSERT_HEAD(&tdi->clnt_list, clp, list);
 	return clp;
@@ -524,20 +520,17 @@ gssd_get_topdir(const char *name)
 		return NULL;
 	}
 
-	sprintf(tdi->dirname, "%s/%s", pipefs_path, name);
-	tdi->name = tdi->dirname + strlen(pipefs_path) + 1;
-	TAILQ_INIT(&tdi->clnt_list);
-
-	tdi->fd = openat(pipefs_fd, name, O_RDONLY);
-	if (tdi->fd < 0) {
-		printerr(0, "ERROR: failed to open %s: %s\n",
+	tdi->wd = inotify_add_watch(inotify_fd, name, IN_CREATE | IN_DELETE);
+	if (tdi->wd < 0) {
+		printerr(0, "ERROR: inotify_add_watch failed for %s: %s\n",
 			 tdi->dirname, strerror(errno));
 		free(tdi);
 		return NULL;
 	}
 
-	fcntl(tdi->fd, F_SETSIG, DNOTIFY_SIGNAL);
-	fcntl(tdi->fd, F_NOTIFY, DN_CREATE|DN_DELETE|DN_MODIFY|DN_MULTISHOT);
+	sprintf(tdi->dirname, "%s/%s", pipefs_path, name);
+	tdi->name = tdi->dirname + strlen(pipefs_path) + 1;
+	TAILQ_INIT(&tdi->clnt_list);
 
 	TAILQ_INSERT_HEAD(&topdir_list, tdi, list);
 	return tdi;
@@ -623,11 +616,56 @@ gssd_scan(void)
 }
 
 static void
-gssd_scan_cb(int UNUSED(ifd), short UNUSED(which), void *UNUSED(data))
+gssd_scan_cb(int UNUSED(fd), short UNUSED(which), void *UNUSED(data))
 {
 	gssd_scan();
 }
 
+static void
+gssd_inotify_cb(int ifd, short UNUSED(which), void *UNUSED(data))
+{
+	bool rescan = true; /* unconditional rescan, for now */
+	struct topdir *tdi;
+	struct clnt_info *clp;
+
+	while (true) {
+		char buf[4096] __attribute__ ((aligned(__alignof__(struct inotify_event))));
+		const struct inotify_event *ev;
+		ssize_t len;
+		char *ptr;
+
+		len = read(ifd, buf, sizeof(buf));
+		if (len == -1 && errno == EINTR)
+			continue;
+
+		if (len <= 0)
+			break;
+
+		for (ptr = buf; ptr < buf + len;
+		     ptr += sizeof(struct inotify_event) + ev->len) {
+			ev = (const struct inotify_event *)ptr;
+
+			if (ev->mask & IN_Q_OVERFLOW) {
+				printerr(0, "ERROR: inotify queue overflow\n");
+				rescan = true;
+			}
+
+			/* NOTE: Set rescan if wd not found */
+			TAILQ_FOREACH(tdi, &topdir_list, list) {
+				if (tdi->wd == ev->wd)
+					break;
+
+				TAILQ_FOREACH(clp, &tdi->clnt_list, list) {
+					if (clp->wd == ev->wd)
+						break;
+				}
+			}
+		}
+	}
+
+	if (rescan)
+		gssd_scan();
+}
 
 static void
 gssd_atexit(void)
@@ -656,7 +694,6 @@ main(int argc, char *argv[])
 	char *progname;
 	char *ccachedir = NULL;
 	struct event sighup_ev;
-	struct event sigdnotify_ev;
 
 	while ((opt = getopt(argc, argv, "DfvrlmnMp:k:d:t:T:R:")) != -1) {
 		switch (opt) {
@@ -799,10 +836,16 @@ main(int argc, char *argv[])
 		exit(EXIT_FAILURE);
 	}
 
+	inotify_fd = inotify_init1(IN_NONBLOCK);
+	if (inotify_fd == -1) {
+		printerr(1, "ERROR: inotify_init1 failed: %s\n", strerror(errno));
+		exit(EXIT_FAILURE);
+	}
+
 	signal_set(&sighup_ev, SIGHUP, gssd_scan_cb, NULL);
 	signal_add(&sighup_ev, NULL);
-	signal_set(&sigdnotify_ev, DNOTIFY_SIGNAL, gssd_scan_cb, NULL);
-	signal_add(&sigdnotify_ev, NULL);
+	event_set(&inotify_ev, inotify_fd, EV_READ | EV_PERSIST, gssd_inotify_cb, NULL);
+	event_add(&inotify_ev, NULL);
 
 	TAILQ_INIT(&topdir_list);
 	gssd_scan();
diff --git a/utils/gssd/gssd.h b/utils/gssd/gssd.h
index 7792035..c6937c5 100644
--- a/utils/gssd/gssd.h
+++ b/utils/gssd/gssd.h
@@ -64,7 +64,7 @@ extern char			*preferred_realm;
 
 struct clnt_info {
 	TAILQ_ENTRY(clnt_info)	list;
-	int			dir_fd;
+	int			wd;
 	bool			scanned;
 	char			*name;
 	char			*relpath;


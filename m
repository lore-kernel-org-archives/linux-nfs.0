Return-Path: linux-nfs-owner@vger.kernel.org
Received: from vader.hardeman.nu ([95.142.160.32]:51279 "EHLO hardeman.nu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932100AbaLIFlp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Dec 2014 00:41:45 -0500
Subject: [PATCH 11/19] nfs-utils: gssd - keep the rpc_pipefs dir open
From: David =?utf-8?b?SMOkcmRlbWFu?= <david@hardeman.nu>
To: linux-nfs@vger.kernel.org
Cc: SteveD@redhat.com
Date: Tue, 09 Dec 2014 06:41:35 +0100
Message-ID: <20141209054135.24756.61210.stgit@zeus.muc.hardeman.nu>
In-Reply-To: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
References: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Keep the rpc_pipefs dir open and just do a rewind/rescan when
necessary.

Signed-off-by: David Härdeman <david@hardeman.nu>
---
 utils/gssd/gssd.c |   86 +++++++++++++++++++++++------------------------------
 1 file changed, 37 insertions(+), 49 deletions(-)

diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index d0eae16..d03df2c 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -72,7 +72,9 @@
 #include "krb5_util.h"
 #include "nfslib.h"
 
-static char *pipefs_dir = GSSD_PIPEFS_DIR;
+static char *pipefs_path = GSSD_PIPEFS_DIR;
+static DIR *pipefs_dir;
+
 char *keytabfile = GSSD_DEFAULT_KEYTAB_FILE;
 char **ccachesearch;
 int  use_memcache = 0;
@@ -87,6 +89,7 @@ struct topdir {
 	TAILQ_ENTRY(topdir) list;
 	TAILQ_HEAD(clnt_list_head, clnt_info) clnt_list;
 	int fd;
+	char *name;
 	char dirname[];
 };
 
@@ -550,7 +553,7 @@ find_client(struct topdir *tdi, const char *dirname)
 }
 
 static int
-process_pipedir(struct topdir *tdi)
+gssd_process_topdir(struct topdir *tdi)
 {
 	struct dirent **namelist;
 	int i, j;
@@ -576,40 +579,23 @@ process_pipedir(struct topdir *tdi)
 	return 0;
 }
 
-/* Used to read (and re-read) list of clients, set up poll array. */
-static void
-gssd_update_clients(void)
-{
-	int retval;
-	struct topdir *tdi;
-
-	TAILQ_FOREACH(tdi, &topdir_list, list) {
-		retval = process_pipedir(tdi);
-		if (retval)
-			printerr(1, "WARNING: error processing %s\n",
-				 tdi->dirname);
-
-	}
-}
-
-static void
-gssd_update_clients_cb(int UNUSED(ifd), short UNUSED(which), void *UNUSED(data))
-{
-	gssd_update_clients();
-}
-
 static int
-topdirs_add_entry(int pfd, const char *name)
+gssd_add_topdir(int pfd, const char *name)
 {
 	struct topdir *tdi;
 
-	tdi = malloc(sizeof(*tdi) + strlen(pipefs_dir) + strlen(name) + 2);
+	TAILQ_FOREACH(tdi, &topdir_list, list)
+		if (!strcmp(tdi->name, name))
+			return gssd_process_topdir(tdi);
+
+	tdi = malloc(sizeof(*tdi) + strlen(pipefs_path) + strlen(name) + 2);
 	if (!tdi) {
 		printerr(0, "ERROR: Couldn't allocate struct topdir\n");
 		return -1;
 	}
 
-	sprintf(tdi->dirname, "%s/%s", pipefs_dir, name);
+	sprintf(tdi->dirname, "%s/%s", pipefs_path, name);
+	tdi->name = tdi->dirname + strlen(pipefs_path) + 1;
 	TAILQ_INIT(&tdi->clnt_list);
 
 	tdi->fd = openat(pfd, name, O_RDONLY);
@@ -624,43 +610,39 @@ topdirs_add_entry(int pfd, const char *name)
 	fcntl(tdi->fd, F_NOTIFY, DN_CREATE|DN_DELETE|DN_MODIFY|DN_MULTISHOT);
 
 	TAILQ_INSERT_HEAD(&topdir_list, tdi, list);
-	return 0;
+	return gssd_process_topdir(tdi);
 }
 
 static void
-topdirs_init_list(void)
+gssd_update_clients(void)
 {
-	DIR *pipedir;
-	struct dirent *dent;
+	struct dirent *d;
 
-	TAILQ_INIT(&topdir_list);
+	rewinddir(pipefs_dir);
 
-	pipedir = opendir(".");
-	if (!pipedir) {
-		printerr(0, "ERROR: could not open rpc_pipefs directory: '%s'\n",
-			 strerror(errno));
-		exit(EXIT_FAILURE);
-	}
-
-	while ((dent = readdir(pipedir))) {
-		if (dent->d_type != DT_DIR)
+	while ((d = readdir(pipefs_dir))) {
+		if (d->d_type != DT_DIR)
 			continue;
 
-		if (dent->d_name[0] == '.')
+		if (d->d_name[0] == '.')
 			continue;
 
-		if (topdirs_add_entry(dirfd(pipedir), dent->d_name))
-			exit(EXIT_FAILURE);
+		gssd_add_topdir(dirfd(pipefs_dir), d->d_name);
 	}
 
 	if (TAILQ_EMPTY(&topdir_list)) {
 		printerr(0, "ERROR: the rpc_pipefs directory is empty!\n");
 		exit(EXIT_FAILURE);
 	}
+}
 
-	closedir(pipedir);
+static void
+gssd_update_clients_cb(int UNUSED(ifd), short UNUSED(which), void *UNUSED(data))
+{
+	gssd_update_clients();
 }
 
+
 static void
 gssd_atexit(void)
 {
@@ -711,7 +693,7 @@ main(int argc, char *argv[])
 				rpc_verbosity++;
 				break;
 			case 'p':
-				pipefs_dir = optarg;
+				pipefs_path = optarg;
 				break;
 			case 'k':
 				keytabfile = optarg;
@@ -814,8 +796,14 @@ main(int argc, char *argv[])
 
 	event_init();
 
-	if (chdir(pipefs_dir)) {
-		printerr(1, "ERROR: chdir(%s) failed: %s\n", pipefs_dir, strerror(errno));
+	pipefs_dir = opendir(pipefs_path);
+	if (!pipefs_dir) {
+		printerr(1, "ERROR: opendir(%s) failed: %s\n", pipefs_path, strerror(errno));
+		exit(EXIT_FAILURE);
+	}
+
+	if (fchdir(dirfd(pipefs_dir))) {
+		printerr(1, "ERROR: fchdir(%s) failed: %s\n", pipefs_path, strerror(errno));
 		exit(EXIT_FAILURE);
 	}
 
@@ -829,7 +817,7 @@ main(int argc, char *argv[])
 	signal_set(&sigdnotify_ev, DNOTIFY_SIGNAL, gssd_update_clients_cb, NULL);
 	signal_add(&sigdnotify_ev, NULL);
 
-	topdirs_init_list();
+	TAILQ_INIT(&topdir_list);
 	gssd_update_clients();
 	daemon_ready();
 


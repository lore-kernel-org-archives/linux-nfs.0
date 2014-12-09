Return-Path: linux-nfs-owner@vger.kernel.org
Received: from vader.hardeman.nu ([95.142.160.32]:51283 "EHLO hardeman.nu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750849AbaLIFlz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Dec 2014 00:41:55 -0500
Subject: [PATCH 13/19] nfs-utils: gssd - simplify topdir scanning
From: David =?utf-8?b?SMOkcmRlbWFu?= <david@hardeman.nu>
To: linux-nfs@vger.kernel.org
Cc: SteveD@redhat.com
Date: Tue, 09 Dec 2014 06:41:45 +0100
Message-ID: <20141209054145.24756.84280.stgit@zeus.muc.hardeman.nu>
In-Reply-To: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
References: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Simplify and refactor the code that does the topdir scanning, this
is in preparation for the inotify patches.

Signed-off-by: David Härdeman <david@hardeman.nu>
---
 utils/gssd/gssd.c |  172 +++++++++++++++++++++++++----------------------------
 utils/gssd/gssd.h |    1 
 2 files changed, 81 insertions(+), 92 deletions(-)

diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index fc0cbdc..9e48840 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -364,7 +364,7 @@ insert_new_clnt(struct topdir *tdi)
 	return clp;
 }
 
-static void gssd_update_clients(void);
+static void gssd_scan(void);
 
 static void
 gssd_clnt_gssd_cb(int UNUSED(fd), short which, void *data)
@@ -376,7 +376,7 @@ gssd_clnt_gssd_cb(int UNUSED(fd), short which, void *data)
 		close(clp->gssd_fd);
 		clp->gssd_fd = -1;
 		event_del(&clp->gssd_ev);
-		gssd_update_clients();
+		gssd_scan();
 		return;
 	}
 
@@ -393,7 +393,7 @@ gssd_clnt_krb5_cb(int UNUSED(fd), short which, void *data)
 		close(clp->krb5_fd);
 		clp->krb5_fd = -1;
 		event_del(&clp->krb5_ev);
-		gssd_update_clients();
+		gssd_scan();
 		return;
 	}
 
@@ -459,6 +459,7 @@ process_clnt_dir_files(struct clnt_info * clp)
 				  &clp->protocol, (struct sockaddr *) &clp->addr);
 	}
 
+	clp->scanned = true;
 	return 0;
 }
 
@@ -500,118 +501,105 @@ out:
 	}
 }
 
-/*
- * This is run after a DNOTIFY signal, and should clear up any
- * directories that are no longer around, and re-scan any existing
- * directories, since the DNOTIFY could have been in there.
- */
-static void
-update_old_clients(struct topdir *tdi, struct dirent **namelist, int size)
+static struct topdir *
+gssd_get_topdir(const char *name)
 {
-	struct clnt_info *clp;
-	void *saveprev;
-	int i;
-	bool stillhere;
-
-	TAILQ_FOREACH(clp, &tdi->clnt_list, list) {
-		stillhere = false;
+	struct topdir *tdi;
 
-		for (i = 0; i < size; i++) {
-			if (!strcmp(clp->name, namelist[i]->d_name)) {
-				stillhere = true;
-				break;
-			}
-		}
+	TAILQ_FOREACH(tdi, &topdir_list, list)
+		if (!strcmp(tdi->name, name))
+			return tdi;
 
-		if (!stillhere) {
-			printerr(2, "destroying client %s\n", clp->relpath);
-			saveprev = clp->list.tqe_prev;
-			TAILQ_REMOVE(&tdi->clnt_list, clp, list);
-			destroy_client(clp);
-			clp = saveprev;
-		}
+	tdi = malloc(sizeof(*tdi) + strlen(pipefs_path) + strlen(name) + 2);
+	if (!tdi) {
+		printerr(0, "ERROR: Couldn't allocate struct topdir\n");
+		return NULL;
 	}
 
-	TAILQ_FOREACH(clp, &tdi->clnt_list, list)
-		process_clnt_dir_files(clp);
-}
+	sprintf(tdi->dirname, "%s/%s", pipefs_path, name);
+	tdi->name = tdi->dirname + strlen(pipefs_path) + 1;
+	TAILQ_INIT(&tdi->clnt_list);
 
-/* Search for a client by directory name, return 1 if found, 0 otherwise */
-static bool
-find_client(struct topdir *tdi, const char *name)
-{
-	struct clnt_info *clp;
+	tdi->fd = openat(pipefs_fd, name, O_RDONLY);
+	if (tdi->fd < 0) {
+		printerr(0, "ERROR: failed to open %s: %s\n",
+			 tdi->dirname, strerror(errno));
+		free(tdi);
+		return NULL;
+	}
 
-	TAILQ_FOREACH(clp, &tdi->clnt_list, list)
-		if (!strcmp(clp->name, name))
-			return true;
+	fcntl(tdi->fd, F_SETSIG, DNOTIFY_SIGNAL);
+	fcntl(tdi->fd, F_NOTIFY, DN_CREATE|DN_DELETE|DN_MODIFY|DN_MULTISHOT);
 
-	return false;
+	TAILQ_INSERT_HEAD(&topdir_list, tdi, list);
+	return tdi;
 }
 
-static int
-gssd_process_topdir(struct topdir *tdi)
+static void
+gssd_scan_topdir(const char *name)
 {
-	struct dirent **namelist;
-	int i, j;
+	struct topdir *tdi;
+	int dfd;
+	DIR *dir;
+	struct clnt_info *clp;
+	struct dirent *d;
+
+	tdi = gssd_get_topdir(name);
+	if (!tdi)
+		return;
 
-	j = scandir(tdi->dirname, &namelist, NULL, alphasort);
-	if (j < 0) {
-		printerr(0, "ERROR: can't scandir %s: %s\n",
+	dfd = openat(pipefs_fd, tdi->name, O_RDONLY);
+	if (dfd < 0) {
+		printerr(0, "ERROR: can't openat %s: %s\n",
 			 tdi->dirname, strerror(errno));
-		return -1;
+		return;
 	}
 
-	update_old_clients(tdi, namelist, j);
-
-	for (i = 0; i < j; i++) {
-		if (!strncmp(namelist[i]->d_name, "clnt", 4)
-		    && !find_client(tdi, namelist[i]->d_name))
-			process_clnt_dir(tdi, namelist[i]->d_name);
-		free(namelist[i]);
+	dir = fdopendir(dfd);
+	if (!dir) {
+		printerr(0, "ERROR: can't fdopendir %s: %s\n",
+			 tdi->dirname, strerror(errno));
+		return;
 	}
 
-	free(namelist);
+	TAILQ_FOREACH(clp, &tdi->clnt_list, list)
+		clp->scanned = false;
 
-	return 0;
-}
+	while ((d = readdir(dir))) {
+		if (d->d_type != DT_DIR)
+			continue;
 
-static int
-gssd_add_topdir(int pfd, const char *name)
-{
-	struct topdir *tdi;
+		if (strncmp(d->d_name, "clnt", strlen("clnt")))
+			continue;
 
-	TAILQ_FOREACH(tdi, &topdir_list, list)
-		if (!strcmp(tdi->name, name))
-			return gssd_process_topdir(tdi);
+		TAILQ_FOREACH(clp, &tdi->clnt_list, list)
+			if (!strcmp(clp->name, d->d_name))
+				break;
 
-	tdi = malloc(sizeof(*tdi) + strlen(pipefs_path) + strlen(name) + 2);
-	if (!tdi) {
-		printerr(0, "ERROR: Couldn't allocate struct topdir\n");
-		return -1;
+		if (clp)
+			process_clnt_dir_files(clp);
+		else
+			process_clnt_dir(tdi, d->d_name);
 	}
 
-	sprintf(tdi->dirname, "%s/%s", pipefs_path, name);
-	tdi->name = tdi->dirname + strlen(pipefs_path) + 1;
-	TAILQ_INIT(&tdi->clnt_list);
+	closedir(dir);
 
-	tdi->fd = openat(pfd, name, O_RDONLY);
-	if (tdi->fd < 0) {
-		printerr(0, "ERROR: failed to open %s: %s\n",
-			 tdi->dirname, strerror(errno));
-		free(tdi);
-		return -1;
-	}
+	TAILQ_FOREACH(clp, &tdi->clnt_list, list) {
+		void *saveprev;
 
-	fcntl(tdi->fd, F_SETSIG, DNOTIFY_SIGNAL);
-	fcntl(tdi->fd, F_NOTIFY, DN_CREATE|DN_DELETE|DN_MODIFY|DN_MULTISHOT);
+		if (clp->scanned)
+			continue;
 
-	TAILQ_INSERT_HEAD(&topdir_list, tdi, list);
-	return gssd_process_topdir(tdi);
+		printerr(2, "destroying client %s\n", clp->relpath);
+		saveprev = clp->list.tqe_prev;
+		TAILQ_REMOVE(&tdi->clnt_list, clp, list);
+		destroy_client(clp);
+		clp = saveprev;
+	}
 }
 
 static void
-gssd_update_clients(void)
+gssd_scan(void)
 {
 	struct dirent *d;
 
@@ -624,7 +612,7 @@ gssd_update_clients(void)
 		if (d->d_name[0] == '.')
 			continue;
 
-		gssd_add_topdir(pipefs_fd, d->d_name);
+		gssd_scan_topdir(d->d_name);
 	}
 
 	if (TAILQ_EMPTY(&topdir_list)) {
@@ -634,9 +622,9 @@ gssd_update_clients(void)
 }
 
 static void
-gssd_update_clients_cb(int UNUSED(ifd), short UNUSED(which), void *UNUSED(data))
+gssd_scan_cb(int UNUSED(ifd), short UNUSED(which), void *UNUSED(data))
 {
-	gssd_update_clients();
+	gssd_scan();
 }
 
 
@@ -810,13 +798,13 @@ main(int argc, char *argv[])
 		exit(EXIT_FAILURE);
 	}
 
-	signal_set(&sighup_ev, SIGHUP, gssd_update_clients_cb, NULL);
+	signal_set(&sighup_ev, SIGHUP, gssd_scan_cb, NULL);
 	signal_add(&sighup_ev, NULL);
-	signal_set(&sigdnotify_ev, DNOTIFY_SIGNAL, gssd_update_clients_cb, NULL);
+	signal_set(&sigdnotify_ev, DNOTIFY_SIGNAL, gssd_scan_cb, NULL);
 	signal_add(&sigdnotify_ev, NULL);
 
 	TAILQ_INIT(&topdir_list);
-	gssd_update_clients();
+	gssd_scan();
 	daemon_ready();
 
 	event_dispatch();
diff --git a/utils/gssd/gssd.h b/utils/gssd/gssd.h
index e602d18..7792035 100644
--- a/utils/gssd/gssd.h
+++ b/utils/gssd/gssd.h
@@ -65,6 +65,7 @@ extern char			*preferred_realm;
 struct clnt_info {
 	TAILQ_ENTRY(clnt_info)	list;
 	int			dir_fd;
+	bool			scanned;
 	char			*name;
 	char			*relpath;
 	char			*servicename;


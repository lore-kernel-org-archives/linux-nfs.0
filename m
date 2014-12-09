Return-Path: linux-nfs-owner@vger.kernel.org
Received: from vader.hardeman.nu ([95.142.160.32]:51282 "EHLO hardeman.nu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750849AbaLIFlu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Dec 2014 00:41:50 -0500
Subject: [PATCH 12/19] nfs-utils: gssd - use more relative paths
From: David =?utf-8?b?SMOkcmRlbWFu?= <david@hardeman.nu>
To: linux-nfs@vger.kernel.org
Cc: SteveD@redhat.com
Date: Tue, 09 Dec 2014 06:41:40 +0100
Message-ID: <20141209054140.24756.85225.stgit@zeus.muc.hardeman.nu>
In-Reply-To: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
References: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Using more relative paths saves memory and lets us get rid of more
PATH_MAX fixed arrays.

Signed-off-by: David Härdeman <david@hardeman.nu>
---
 utils/gssd/gssd.c      |   74 +++++++++++++++++++++++-------------------------
 utils/gssd/gssd.h      |    3 +-
 utils/gssd/gssd_proc.c |    4 +--
 3 files changed, 40 insertions(+), 41 deletions(-)

diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index d03df2c..fc0cbdc 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -74,6 +74,7 @@
 
 static char *pipefs_path = GSSD_PIPEFS_DIR;
 static DIR *pipefs_dir;
+static int pipefs_fd;
 
 char *keytabfile = GSSD_DEFAULT_KEYTAB_FILE;
 char **ccachesearch;
@@ -336,7 +337,7 @@ destroy_client(struct clnt_info *clp)
 	if (clp->dir_fd >= 0)
 		close(clp->dir_fd);
 
-	free(clp->dirname);
+	free(clp->relpath);
 	free(clp->servicename);
 	free(clp->servername);
 	free(clp->protocol);
@@ -371,7 +372,7 @@ gssd_clnt_gssd_cb(int UNUSED(fd), short which, void *data)
 	struct clnt_info *clp = data;
 
 	if (which != EV_READ) {
-		printerr(2, "Closing 'gssd' pipe for %s\n", clp->dirname);
+		printerr(2, "Closing 'gssd' pipe %s\n", clp->relpath);
 		close(clp->gssd_fd);
 		clp->gssd_fd = -1;
 		event_del(&clp->gssd_ev);
@@ -388,7 +389,7 @@ gssd_clnt_krb5_cb(int UNUSED(fd), short which, void *data)
 	struct clnt_info *clp = data;
 
 	if (which != EV_READ) {
-		printerr(2, "Closing 'krb5' pipe for %s\n", clp->dirname);
+		printerr(2, "Closing 'krb5' pipe %s\n", clp->relpath);
 		close(clp->krb5_fd);
 		clp->krb5_fd = -1;
 		event_del(&clp->krb5_ev);
@@ -402,34 +403,32 @@ gssd_clnt_krb5_cb(int UNUSED(fd), short which, void *data)
 static int
 process_clnt_dir_files(struct clnt_info * clp)
 {
-	char	name[PATH_MAX];
-	char	gname[PATH_MAX];
+	char name[strlen(clp->relpath) + strlen("/krb5") + 1];
+	char gname[strlen(clp->relpath) + strlen("/gssd") + 1];
 	bool gssd_was_closed;
 	bool krb5_was_closed;
 
 	gssd_was_closed = clp->gssd_fd < 0 ? true : false;
 	krb5_was_closed = clp->krb5_fd < 0 ? true : false;
 
-	if (clp->gssd_fd == -1) {
-		snprintf(gname, sizeof(gname), "%s/gssd", clp->dirname);
-		clp->gssd_fd = open(gname, O_RDWR);
-	}
+	sprintf(gname, "%s/gssd", clp->relpath);
+	sprintf(name, "%s/krb5", clp->relpath);
+
+	if (clp->gssd_fd == -1)
+		clp->gssd_fd = openat(pipefs_fd, gname, O_RDWR);
 
 	if (clp->gssd_fd == -1) {
-		if (clp->krb5_fd == -1) {
-			snprintf(name, sizeof(name), "%s/krb5", clp->dirname);
-			clp->krb5_fd = open(name, O_RDWR);
-		}
+		if (clp->krb5_fd == -1)
+			clp->krb5_fd = openat(pipefs_fd, name, O_RDWR);
 
 		/* If we opened a gss-specific pipe, let's try opening
 		 * the new upcall pipe again. If we succeed, close
 		 * gss-specific pipe(s).
 		 */
 		if (clp->krb5_fd != -1) {
-			clp->gssd_fd = open(gname, O_RDWR);
+			clp->gssd_fd = openat(pipefs_fd, gname, O_RDWR);
 			if (clp->gssd_fd != -1) {
-				if (clp->krb5_fd != -1)
-					close(clp->krb5_fd);
+				close(clp->krb5_fd);
 				clp->krb5_fd = -1;
 			}
 		}
@@ -452,9 +451,9 @@ process_clnt_dir_files(struct clnt_info * clp)
 		return 0;
 
 	if (clp->prog == 0) {
-		char info_file_name[strlen(clp->dirname) + 6];
+		char info_file_name[strlen(clp->relpath) + strlen("/info") + 1];
 
-		sprintf(info_file_name, "%s/info", clp->dirname);
+		sprintf(info_file_name, "%s/info", clp->relpath);
 		read_service_info(info_file_name, &clp->servicename,
 				  &clp->servername, &clp->prog, &clp->vers,
 				  &clp->protocol, (struct sockaddr *) &clp->addr);
@@ -464,24 +463,28 @@ process_clnt_dir_files(struct clnt_info * clp)
 }
 
 static void
-process_clnt_dir(struct topdir *tdi, char *dir)
+process_clnt_dir(struct topdir *tdi, const char *name)
 {
 	struct clnt_info *clp;
 
-	if (!(clp = insert_new_clnt(tdi)))
+	clp = insert_new_clnt(tdi);
+	if (!clp)
 		goto out;
 
-	/* An extra for the '/', and an extra for the null */
-	if (!(clp->dirname = calloc(strlen(dir) + strlen(tdi->dirname) + 2, 1)))
+	clp->relpath = malloc(strlen(tdi->name) + strlen("/") + strlen(name) + 1);
+	if (!clp->relpath)
 		goto out;
 
-	sprintf(clp->dirname, "%s/%s", tdi->dirname, dir);
-	if ((clp->dir_fd = open(clp->dirname, O_RDONLY)) == -1) {
+	sprintf(clp->relpath, "%s/%s", tdi->name, name);
+	clp->name = clp->relpath + strlen(tdi->name) + 1;
+
+	if ((clp->dir_fd = open(clp->relpath, O_RDONLY)) == -1) {
 		if (errno != ENOENT)
 			printerr(0, "ERROR: can't open %s: %s\n",
-				 clp->dirname, strerror(errno));
+				 clp->relpath, strerror(errno));
 		goto out;
 	}
+
 	fcntl(clp->dir_fd, F_SETSIG, DNOTIFY_SIGNAL);
 	fcntl(clp->dir_fd, F_NOTIFY, DN_CREATE | DN_DELETE | DN_MULTISHOT);
 
@@ -509,22 +512,19 @@ update_old_clients(struct topdir *tdi, struct dirent **namelist, int size)
 	void *saveprev;
 	int i;
 	bool stillhere;
-	char fname[PATH_MAX];
 
 	TAILQ_FOREACH(clp, &tdi->clnt_list, list) {
 		stillhere = false;
 
 		for (i = 0; i < size; i++) {
-			snprintf(fname, sizeof(fname), "%s/%s",
-				 tdi->dirname, namelist[i]->d_name);
-			if (strcmp(clp->dirname, fname) == 0) {
+			if (!strcmp(clp->name, namelist[i]->d_name)) {
 				stillhere = true;
 				break;
 			}
 		}
 
 		if (!stillhere) {
-			printerr(2, "destroying client %s\n", clp->dirname);
+			printerr(2, "destroying client %s\n", clp->relpath);
 			saveprev = clp->list.tqe_prev;
 			TAILQ_REMOVE(&tdi->clnt_list, clp, list);
 			destroy_client(clp);
@@ -538,16 +538,13 @@ update_old_clients(struct topdir *tdi, struct dirent **namelist, int size)
 
 /* Search for a client by directory name, return 1 if found, 0 otherwise */
 static bool
-find_client(struct topdir *tdi, const char *dirname)
+find_client(struct topdir *tdi, const char *name)
 {
 	struct clnt_info *clp;
-	char fname[PATH_MAX];
 
-	TAILQ_FOREACH(clp, &tdi->clnt_list, list) {
-		snprintf(fname, sizeof(fname), "%s/%s", tdi->dirname, dirname);
-		if (!strcmp(clp->dirname, fname))
+	TAILQ_FOREACH(clp, &tdi->clnt_list, list)
+		if (!strcmp(clp->name, name))
 			return true;
-	}
 
 	return false;
 }
@@ -627,7 +624,7 @@ gssd_update_clients(void)
 		if (d->d_name[0] == '.')
 			continue;
 
-		gssd_add_topdir(dirfd(pipefs_dir), d->d_name);
+		gssd_add_topdir(pipefs_fd, d->d_name);
 	}
 
 	if (TAILQ_EMPTY(&topdir_list)) {
@@ -802,7 +799,8 @@ main(int argc, char *argv[])
 		exit(EXIT_FAILURE);
 	}
 
-	if (fchdir(dirfd(pipefs_dir))) {
+	pipefs_fd = dirfd(pipefs_dir);
+	if (fchdir(pipefs_fd)) {
 		printerr(1, "ERROR: fchdir(%s) failed: %s\n", pipefs_path, strerror(errno));
 		exit(EXIT_FAILURE);
 	}
diff --git a/utils/gssd/gssd.h b/utils/gssd/gssd.h
index 8a882d3..e602d18 100644
--- a/utils/gssd/gssd.h
+++ b/utils/gssd/gssd.h
@@ -64,8 +64,9 @@ extern char			*preferred_realm;
 
 struct clnt_info {
 	TAILQ_ENTRY(clnt_info)	list;
-	char			*dirname;
 	int			dir_fd;
+	char			*name;
+	char			*relpath;
 	char			*servicename;
 	char			*servername;
 	int			prog;
diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 8957b27..c16f111 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -527,7 +527,7 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
 		return;
 	}
 
-	printerr(1, "handling krb5 upcall (%s)\n", clp->dirname);
+	printerr(1, "handling krb5 upcall (%s)\n", clp->relpath);
 
 	token.length = 0;
 	token.value = NULL;
@@ -716,7 +716,7 @@ handle_gssd_upcall(struct clnt_info *clp)
 	char			*service = NULL;
 	char			*enctypes = NULL;
 
-	printerr(1, "handling gssd upcall (%s)\n", clp->dirname);
+	printerr(1, "handling gssd upcall (%s)\n", clp->relpath);
 
 	lbuflen = read(clp->gssd_fd, lbuf, sizeof(lbuf));
 	if (lbuflen <= 0 || lbuf[lbuflen-1] != '\n') {


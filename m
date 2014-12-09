Return-Path: linux-nfs-owner@vger.kernel.org
Received: from vader.hardeman.nu ([95.142.160.32]:51286 "EHLO hardeman.nu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750826AbaLIFmA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Dec 2014 00:42:00 -0500
Subject: [PATCH 14/19] nfs-utils: gssd - simplify client scanning
From: David =?utf-8?b?SMOkcmRlbWFu?= <david@hardeman.nu>
To: linux-nfs@vger.kernel.org
Cc: SteveD@redhat.com
Date: Tue, 09 Dec 2014 06:41:50 +0100
Message-ID: <20141209054150.24756.2636.stgit@zeus.muc.hardeman.nu>
In-Reply-To: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
References: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Simplify the code responsible for the client dir scanning. This
is also in preparation for the inotify patches.

Signed-off-by: David Härdeman <david@hardeman.nu>
---
 utils/gssd/gssd.c |  171 +++++++++++++++++++++++++----------------------------
 1 file changed, 80 insertions(+), 91 deletions(-)

diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index 9e48840..91e3e05 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -240,7 +240,7 @@ get_servername(const char *name, const struct sockaddr *sa, const char *addr)
 
 /* XXX buffer problems: */
 static int
-read_service_info(char *info_file_name, char **servicename, char **servername,
+read_service_info(int fd, char **servicename, char **servername,
 		  int *prog, int *vers, char **protocol,
 		  struct sockaddr *addr) {
 #define INFOBUFLEN 256
@@ -254,20 +254,13 @@ read_service_info(char *info_file_name, char **servicename, char **servername,
 	char		protoname[16];
 	char		port[128];
 	char		*p;
-	int		fd = -1;
 	int		numfields;
 
 	*servicename = *servername = *protocol = NULL;
 
-	if ((fd = open(info_file_name, O_RDONLY)) == -1) {
-		printerr(0, "ERROR: can't open %s: %s\n", info_file_name,
-			 strerror(errno));
-		goto fail;
-	}
 	if ((nbytes = read(fd, buf, INFOBUFLEN)) == -1)
 		goto fail;
-	close(fd);
-	fd = -1;
+
 	buf[nbytes] = '\0';
 
 	numfields = sscanf(buf,"RPC server: %127s\n"
@@ -313,7 +306,6 @@ read_service_info(char *info_file_name, char **servicename, char **servername,
 	return 0;
 fail:
 	printerr(0, "ERROR: failed to read service info\n");
-	if (fd != -1) close(fd);
 	free(*servername);
 	free(*servicename);
 	free(*protocol);
@@ -322,7 +314,7 @@ fail:
 }
 
 static void
-destroy_client(struct clnt_info *clp)
+gssd_destroy_client(struct clnt_info *clp)
 {
 	if (clp->krb5_fd >= 0) {
 		close(clp->krb5_fd);
@@ -344,26 +336,6 @@ destroy_client(struct clnt_info *clp)
 	free(clp);
 }
 
-static struct clnt_info *
-insert_new_clnt(struct topdir *tdi)
-{
-	struct clnt_info *clp;
-
-	clp = calloc(1, sizeof(struct clnt_info));
-	if (!clp) {
-		printerr(0, "ERROR: can't malloc clnt_info: %s\n",
-			 strerror(errno));
-		return NULL;
-	}
-
-	clp->krb5_fd = -1;
-	clp->gssd_fd = -1;
-	clp->dir_fd = -1;
-
-	TAILQ_INSERT_HEAD(&tdi->clnt_list, clp, list);
-	return clp;
-}
-
 static void gssd_scan(void);
 
 static void
@@ -400,33 +372,86 @@ gssd_clnt_krb5_cb(int UNUSED(fd), short which, void *data)
 	handle_krb5_upcall(clp);
 }
 
+static struct clnt_info *
+gssd_get_clnt(struct topdir *tdi, const char *name)
+{
+	struct clnt_info *clp;
+
+	TAILQ_FOREACH(clp, &tdi->clnt_list, list)
+		if (!strcmp(clp->name, name))
+			return clp;
+
+	clp = calloc(1, sizeof(struct clnt_info));
+	if (!clp) {
+		printerr(0, "ERROR: can't malloc clnt_info: %s\n",
+			 strerror(errno));
+		return NULL;
+	}
+
+	if (asprintf(&clp->relpath, "%s/%s", tdi->name, name) < 0) {
+		clp->relpath = NULL;
+		goto out;
+	}
+
+	clp->name = clp->relpath + strlen(tdi->name) + 1;
+	clp->krb5_fd = -1;
+	clp->gssd_fd = -1;
+	clp->dir_fd = -1;
+
+	if ((clp->dir_fd = open(clp->relpath, O_RDONLY)) == -1) {
+		if (errno != ENOENT)
+			printerr(0, "ERROR: can't open %s: %s\n",
+				 clp->relpath, strerror(errno));
+		goto out;
+	}
+
+	fcntl(clp->dir_fd, F_SETSIG, DNOTIFY_SIGNAL);
+	fcntl(clp->dir_fd, F_NOTIFY, DN_CREATE | DN_DELETE | DN_MULTISHOT);
+
+	TAILQ_INSERT_HEAD(&tdi->clnt_list, clp, list);
+	return clp;
+
+out:
+	free(clp->relpath);
+	free(clp);
+	return NULL;
+}
+
 static int
-process_clnt_dir_files(struct clnt_info * clp)
+gssd_scan_clnt(struct topdir *tdi, const char *name)
 {
-	char name[strlen(clp->relpath) + strlen("/krb5") + 1];
-	char gname[strlen(clp->relpath) + strlen("/gssd") + 1];
+	struct clnt_info *clp;
+	int clntfd;
 	bool gssd_was_closed;
 	bool krb5_was_closed;
 
+	clp = gssd_get_clnt(tdi, name);
+	if (!clp)
+		return -1;
+
 	gssd_was_closed = clp->gssd_fd < 0 ? true : false;
 	krb5_was_closed = clp->krb5_fd < 0 ? true : false;
 
-	sprintf(gname, "%s/gssd", clp->relpath);
-	sprintf(name, "%s/krb5", clp->relpath);
+	clntfd = openat(pipefs_fd, clp->relpath, O_RDONLY);
+	if (clntfd < 0) {
+		printerr(0, "ERROR: can't openat %s: %s\n",
+			 clp->relpath, strerror(errno));
+		return -1;
+	}
 
 	if (clp->gssd_fd == -1)
-		clp->gssd_fd = openat(pipefs_fd, gname, O_RDWR);
+		clp->gssd_fd = openat(clntfd, "gssd", O_RDWR);
 
 	if (clp->gssd_fd == -1) {
 		if (clp->krb5_fd == -1)
-			clp->krb5_fd = openat(pipefs_fd, name, O_RDWR);
+			clp->krb5_fd = openat(clntfd, "krb5", O_RDWR);
 
 		/* If we opened a gss-specific pipe, let's try opening
 		 * the new upcall pipe again. If we succeed, close
 		 * gss-specific pipe(s).
 		 */
 		if (clp->krb5_fd != -1) {
-			clp->gssd_fd = openat(pipefs_fd, gname, O_RDWR);
+			clp->gssd_fd = openat(clntfd, "gssd", O_RDWR);
 			if (clp->gssd_fd != -1) {
 				close(clp->krb5_fd);
 				clp->krb5_fd = -1;
@@ -448,58 +473,29 @@ process_clnt_dir_files(struct clnt_info * clp)
 
 	if ((clp->krb5_fd == -1) && (clp->gssd_fd == -1))
 		/* not fatal, files might appear later */
-		return 0;
+		goto out;
 
 	if (clp->prog == 0) {
-		char info_file_name[strlen(clp->relpath) + strlen("/info") + 1];
+		int infofd;
 
-		sprintf(info_file_name, "%s/info", clp->relpath);
-		read_service_info(info_file_name, &clp->servicename,
-				  &clp->servername, &clp->prog, &clp->vers,
-				  &clp->protocol, (struct sockaddr *) &clp->addr);
+		infofd = openat(clntfd, "info", O_RDONLY);
+		if (infofd < 0) {
+			printerr(0, "ERROR: can't open %s/info: %s\n",
+				 clp->relpath, strerror(errno));
+		} else {
+			read_service_info(infofd, &clp->servicename,
+					  &clp->servername, &clp->prog, &clp->vers,
+					  &clp->protocol, (struct sockaddr *) &clp->addr);
+			close(infofd);
+		}
 	}
 
+out:
+	close(clntfd);
 	clp->scanned = true;
 	return 0;
 }
 
-static void
-process_clnt_dir(struct topdir *tdi, const char *name)
-{
-	struct clnt_info *clp;
-
-	clp = insert_new_clnt(tdi);
-	if (!clp)
-		goto out;
-
-	clp->relpath = malloc(strlen(tdi->name) + strlen("/") + strlen(name) + 1);
-	if (!clp->relpath)
-		goto out;
-
-	sprintf(clp->relpath, "%s/%s", tdi->name, name);
-	clp->name = clp->relpath + strlen(tdi->name) + 1;
-
-	if ((clp->dir_fd = open(clp->relpath, O_RDONLY)) == -1) {
-		if (errno != ENOENT)
-			printerr(0, "ERROR: can't open %s: %s\n",
-				 clp->relpath, strerror(errno));
-		goto out;
-	}
-
-	fcntl(clp->dir_fd, F_SETSIG, DNOTIFY_SIGNAL);
-	fcntl(clp->dir_fd, F_NOTIFY, DN_CREATE | DN_DELETE | DN_MULTISHOT);
-
-	if (process_clnt_dir_files(clp))
-		goto out;
-
-	return;
-
-out:
-	if (clp) {
-		TAILQ_REMOVE(&tdi->clnt_list, clp, list);
-		destroy_client(clp);
-	}
-}
 
 static struct topdir *
 gssd_get_topdir(const char *name)
@@ -572,14 +568,7 @@ gssd_scan_topdir(const char *name)
 		if (strncmp(d->d_name, "clnt", strlen("clnt")))
 			continue;
 
-		TAILQ_FOREACH(clp, &tdi->clnt_list, list)
-			if (!strcmp(clp->name, d->d_name))
-				break;
-
-		if (clp)
-			process_clnt_dir_files(clp);
-		else
-			process_clnt_dir(tdi, d->d_name);
+		gssd_scan_clnt(tdi, d->d_name);
 	}
 
 	closedir(dir);
@@ -593,7 +582,7 @@ gssd_scan_topdir(const char *name)
 		printerr(2, "destroying client %s\n", clp->relpath);
 		saveprev = clp->list.tqe_prev;
 		TAILQ_REMOVE(&tdi->clnt_list, clp, list);
-		destroy_client(clp);
+		gssd_destroy_client(clp);
 		clp = saveprev;
 	}
 }


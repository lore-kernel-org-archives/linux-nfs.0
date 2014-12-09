Return-Path: linux-nfs-owner@vger.kernel.org
Received: from vader.hardeman.nu ([95.142.160.32]:51276 "EHLO hardeman.nu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756831AbaLIFlk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Dec 2014 00:41:40 -0500
Subject: [PATCH 10/19] nfs-utils: gssd - make the client lists per-topdir
From: David =?utf-8?b?SMOkcmRlbWFu?= <david@hardeman.nu>
To: linux-nfs@vger.kernel.org
Cc: SteveD@redhat.com
Date: Tue, 09 Dec 2014 06:41:30 +0100
Message-ID: <20141209054130.24756.84458.stgit@zeus.muc.hardeman.nu>
In-Reply-To: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
References: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This makes it easier to keep track of which client belongs
to which topdir.

Signed-off-by: David Härdeman <david@hardeman.nu>
---
 utils/gssd/gssd.c |  138 +++++++++++++++++++++++++----------------------------
 utils/gssd/gssd.h |    1 
 2 files changed, 66 insertions(+), 73 deletions(-)

diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index 2187562..d0eae16 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -81,30 +81,33 @@ unsigned int  context_timeout = 0;
 unsigned int  rpc_timeout = 5;
 char *preferred_realm = NULL;
 
-TAILQ_HEAD(clnt_list_head, clnt_info) clnt_list;
+TAILQ_HEAD(topdir_list_head, topdir) topdir_list;
 
-TAILQ_HEAD(topdirs_list_head, topdirs_info) topdirs_list;
-
-struct topdirs_info {
-	TAILQ_ENTRY(topdirs_info)	list;
-	int				fd;
-	char				dirname[];
+struct topdir {
+	TAILQ_ENTRY(topdir) list;
+	TAILQ_HEAD(clnt_list_head, clnt_info) clnt_list;
+	int fd;
+	char dirname[];
 };
 
 /*
+ * topdir_list:
+ *	linked list of struct topdir with basic data about a topdir.
+ *
  * clnt_list:
- *      linked list of struct clnt_info with basic data about a clntXXX dir.
+ *      linked list of struct clnt_info with basic data about a clntXXX dir,
+ *      one per topdir.
  *
  * Directory structure: created by the kernel
- *      {rpc_pipefs}/{dir}/clntXX         : one per rpc_clnt struct in the kernel
- *      {rpc_pipefs}/{dir}/clntXX/krb5    : read uid for which kernel wants
+ *      {rpc_pipefs}/{topdir}/clntXX      : one per rpc_clnt struct in the kernel
+ *      {rpc_pipefs}/{topdir}/clntXX/krb5 : read uid for which kernel wants
  *					    a context, write the resulting context
- *      {rpc_pipefs}/{dir}/clntXX/info    : stores info such as server name
- *      {rpc_pipefs}/{dir}/clntXX/gssd    : pipe for all gss mechanisms using
+ *      {rpc_pipefs}/{topdir}/clntXX/info : stores info such as server name
+ *      {rpc_pipefs}/{topdir}/clntXX/gssd : pipe for all gss mechanisms using
  *					    a text-based string of parameters
  *
  * Algorithm:
- *      Poll all {rpc_pipefs}/{dir}/clntXX/YYYY files.  When data is ready,
+ *      Poll all {rpc_pipefs}/{topdir}/clntXX/YYYY files.  When data is ready,
  *      read and process; performs rpcsec_gss context initialization protocol to
  *      get a cred for that user.  Writes result to corresponding krb5 file
  *      in a form the kernel code will understand.
@@ -331,7 +334,6 @@ destroy_client(struct clnt_info *clp)
 		close(clp->dir_fd);
 
 	free(clp->dirname);
-	free(clp->pdir);
 	free(clp->servicename);
 	free(clp->servername);
 	free(clp->protocol);
@@ -339,22 +341,22 @@ destroy_client(struct clnt_info *clp)
 }
 
 static struct clnt_info *
-insert_new_clnt(void)
+insert_new_clnt(struct topdir *tdi)
 {
-	struct clnt_info	*clp = NULL;
+	struct clnt_info *clp;
 
-	if (!(clp = (struct clnt_info *)calloc(1,sizeof(struct clnt_info)))) {
+	clp = calloc(1, sizeof(struct clnt_info));
+	if (!clp) {
 		printerr(0, "ERROR: can't malloc clnt_info: %s\n",
 			 strerror(errno));
-		goto out;
+		return NULL;
 	}
 
 	clp->krb5_fd = -1;
 	clp->gssd_fd = -1;
 	clp->dir_fd = -1;
 
-	TAILQ_INSERT_HEAD(&clnt_list, clp, list);
-out:
+	TAILQ_INSERT_HEAD(&tdi->clnt_list, clp, list);
 	return clp;
 }
 
@@ -459,21 +461,18 @@ process_clnt_dir_files(struct clnt_info * clp)
 }
 
 static void
-process_clnt_dir(char *dir, char *pdir)
+process_clnt_dir(struct topdir *tdi, char *dir)
 {
-	struct clnt_info *	clp;
-
-	if (!(clp = insert_new_clnt()))
-		goto out;
+	struct clnt_info *clp;
 
-	if (!(clp->pdir = strdup(pdir)))
+	if (!(clp = insert_new_clnt(tdi)))
 		goto out;
 
 	/* An extra for the '/', and an extra for the null */
-	if (!(clp->dirname = calloc(strlen(dir) + strlen(pdir) + 2, 1)))
+	if (!(clp->dirname = calloc(strlen(dir) + strlen(tdi->dirname) + 2, 1)))
 		goto out;
 
-	sprintf(clp->dirname, "%s/%s", pdir, dir);
+	sprintf(clp->dirname, "%s/%s", tdi->dirname, dir);
 	if ((clp->dir_fd = open(clp->dirname, O_RDONLY)) == -1) {
 		if (errno != ENOENT)
 			printerr(0, "ERROR: can't open %s: %s\n",
@@ -490,7 +489,7 @@ process_clnt_dir(char *dir, char *pdir)
 
 out:
 	if (clp) {
-		TAILQ_REMOVE(&clnt_list, clp, list);
+		TAILQ_REMOVE(&tdi->clnt_list, clp, list);
 		destroy_client(clp);
 	}
 }
@@ -501,79 +500,74 @@ out:
  * directories, since the DNOTIFY could have been in there.
  */
 static void
-update_old_clients(struct dirent **namelist, int size, char *pdir)
+update_old_clients(struct topdir *tdi, struct dirent **namelist, int size)
 {
 	struct clnt_info *clp;
 	void *saveprev;
-	int i, stillhere;
+	int i;
+	bool stillhere;
 	char fname[PATH_MAX];
 
-	for (clp = clnt_list.tqh_first; clp != NULL; clp = clp->list.tqe_next) {
-		/* only compare entries in the global list that are from the
-		 * same pipefs parent directory as "pdir"
-		 */
-		if (strcmp(clp->pdir, pdir) != 0) continue;
+	TAILQ_FOREACH(clp, &tdi->clnt_list, list) {
+		stillhere = false;
 
-		stillhere = 0;
-		for (i=0; i < size; i++) {
+		for (i = 0; i < size; i++) {
 			snprintf(fname, sizeof(fname), "%s/%s",
-				 pdir, namelist[i]->d_name);
+				 tdi->dirname, namelist[i]->d_name);
 			if (strcmp(clp->dirname, fname) == 0) {
-				stillhere = 1;
+				stillhere = true;
 				break;
 			}
 		}
+
 		if (!stillhere) {
 			printerr(2, "destroying client %s\n", clp->dirname);
 			saveprev = clp->list.tqe_prev;
-			TAILQ_REMOVE(&clnt_list, clp, list);
+			TAILQ_REMOVE(&tdi->clnt_list, clp, list);
 			destroy_client(clp);
 			clp = saveprev;
 		}
 	}
-	for (clp = clnt_list.tqh_first; clp != NULL; clp = clp->list.tqe_next)
+
+	TAILQ_FOREACH(clp, &tdi->clnt_list, list)
 		process_clnt_dir_files(clp);
 }
 
 /* Search for a client by directory name, return 1 if found, 0 otherwise */
-static int
-find_client(char *dirname, char *pdir)
+static bool
+find_client(struct topdir *tdi, const char *dirname)
 {
-	struct clnt_info	*clp;
+	struct clnt_info *clp;
 	char fname[PATH_MAX];
 
-	for (clp = clnt_list.tqh_first; clp != NULL; clp = clp->list.tqe_next) {
-		snprintf(fname, sizeof(fname), "%s/%s", pdir, dirname);
-		if (strcmp(clp->dirname, fname) == 0)
-			return 1;
+	TAILQ_FOREACH(clp, &tdi->clnt_list, list) {
+		snprintf(fname, sizeof(fname), "%s/%s", tdi->dirname, dirname);
+		if (!strcmp(clp->dirname, fname))
+			return true;
 	}
-	return 0;
+
+	return false;
 }
 
 static int
-process_pipedir(char *pipe_name)
+process_pipedir(struct topdir *tdi)
 {
 	struct dirent **namelist;
 	int i, j;
 
-	if (chdir(pipe_name) < 0) {
-		printerr(0, "ERROR: can't chdir to %s: %s\n",
-			 pipe_name, strerror(errno));
-		return -1;
-	}
-
-	j = scandir(pipe_name, &namelist, NULL, alphasort);
+	j = scandir(tdi->dirname, &namelist, NULL, alphasort);
 	if (j < 0) {
 		printerr(0, "ERROR: can't scandir %s: %s\n",
-			 pipe_name, strerror(errno));
+			 tdi->dirname, strerror(errno));
 		return -1;
 	}
 
-	update_old_clients(namelist, j, pipe_name);
-	for (i=0; i < j; i++) {
+	update_old_clients(tdi, namelist, j);
+
+	for (i = 0; i < j; i++) {
 		if (!strncmp(namelist[i]->d_name, "clnt", 4)
-		    && !find_client(namelist[i]->d_name, pipe_name))
-			process_clnt_dir(namelist[i]->d_name, pipe_name);
+		    && !find_client(tdi, namelist[i]->d_name))
+			process_clnt_dir(tdi, namelist[i]->d_name);
 		free(namelist[i]);
 	}
 
@@ -587,10 +581,10 @@ static void
 gssd_update_clients(void)
 {
 	int retval;
-	struct topdirs_info *tdi;
+	struct topdir *tdi;
 
-	TAILQ_FOREACH(tdi, &topdirs_list, list) {
-		retval = process_pipedir(tdi->dirname);
+	TAILQ_FOREACH(tdi, &topdir_list, list) {
+		retval = process_pipedir(tdi);
 		if (retval)
 			printerr(1, "WARNING: error processing %s\n",
 				 tdi->dirname);
@@ -607,15 +601,16 @@ gssd_update_clients_cb(int UNUSED(ifd), short UNUSED(which), void *UNUSED(data))
 static int
 topdirs_add_entry(int pfd, const char *name)
 {
-	struct topdirs_info *tdi;
+	struct topdir *tdi;
 
 	tdi = malloc(sizeof(*tdi) + strlen(pipefs_dir) + strlen(name) + 2);
 	if (!tdi) {
-		printerr(0, "ERROR: Couldn't allocate struct topdirs_info\n");
+		printerr(0, "ERROR: Couldn't allocate struct topdir\n");
 		return -1;
 	}
 
 	sprintf(tdi->dirname, "%s/%s", pipefs_dir, name);
+	TAILQ_INIT(&tdi->clnt_list);
 
 	tdi->fd = openat(pfd, name, O_RDONLY);
 	if (tdi->fd < 0) {
@@ -628,7 +623,7 @@ topdirs_add_entry(int pfd, const char *name)
 	fcntl(tdi->fd, F_SETSIG, DNOTIFY_SIGNAL);
 	fcntl(tdi->fd, F_NOTIFY, DN_CREATE|DN_DELETE|DN_MODIFY|DN_MULTISHOT);
 
-	TAILQ_INSERT_HEAD(&topdirs_list, tdi, list);
+	TAILQ_INSERT_HEAD(&topdir_list, tdi, list);
 	return 0;
 }
 
@@ -638,7 +633,7 @@ topdirs_init_list(void)
 	DIR *pipedir;
 	struct dirent *dent;
 
-	TAILQ_INIT(&topdirs_list);
+	TAILQ_INIT(&topdir_list);
 
 	pipedir = opendir(".");
 	if (!pipedir) {
@@ -658,7 +653,7 @@ topdirs_init_list(void)
 			exit(EXIT_FAILURE);
 	}
 
-	if (TAILQ_EMPTY(&topdirs_list)) {
+	if (TAILQ_EMPTY(&topdir_list)) {
 		printerr(0, "ERROR: the rpc_pipefs directory is empty!\n");
 		exit(EXIT_FAILURE);
 	}
@@ -835,7 +830,6 @@ main(int argc, char *argv[])
 	signal_add(&sigdnotify_ev, NULL);
 
 	topdirs_init_list();
-	TAILQ_INIT(&clnt_list);
 	gssd_update_clients();
 	daemon_ready();
 
diff --git a/utils/gssd/gssd.h b/utils/gssd/gssd.h
index cea2b92..8a882d3 100644
--- a/utils/gssd/gssd.h
+++ b/utils/gssd/gssd.h
@@ -65,7 +65,6 @@ extern char			*preferred_realm;
 struct clnt_info {
 	TAILQ_ENTRY(clnt_info)	list;
 	char			*dirname;
-	char			*pdir;
 	int			dir_fd;
 	char			*servicename;
 	char			*servername;


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from vader.hardeman.nu ([95.142.160.32]:51266 "EHLO hardeman.nu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753576AbaLIFlP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Dec 2014 00:41:15 -0500
Subject: [PATCH 05/19] nfs-utils: gssd - simplify topdirs path
From: David =?utf-8?b?SMOkcmRlbWFu?= <david@hardeman.nu>
To: linux-nfs@vger.kernel.org
Cc: SteveD@redhat.com
Date: Tue, 09 Dec 2014 06:41:05 +0100
Message-ID: <20141209054105.24756.4022.stgit@zeus.muc.hardeman.nu>
In-Reply-To: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
References: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

By chdir():ing to the root of the rpc_pipefs dir and making paths
relative from there (gssd already keeps a number of files open
in rpc_pipefs so chdir doesn't suddenly make it impossible to
umount rpc_pipefs because of this patch).

Signed-off-by: David Härdeman <david@hardeman.nu>
---
 utils/gssd/gssd.c |   93 +++++++++++++++++++++--------------------------------
 utils/gssd/gssd.h |    6 ++-
 2 files changed, 40 insertions(+), 59 deletions(-)

diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index 60e753c..716a387 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -125,28 +125,26 @@ scan_poll_results(int ret)
 }
 
 static int
-topdirs_add_entry(struct dirent *dent)
+topdirs_add_entry(int pfd, const char *name)
 {
 	struct topdirs_info *tdi;
 
-	tdi = calloc(sizeof(struct topdirs_info), 1);
-	if (tdi == NULL) {
+	tdi = malloc(sizeof(*tdi) + strlen(pipefs_dir) + strlen(name) + 2);
+	if (!tdi) {
 		printerr(0, "ERROR: Couldn't allocate struct topdirs_info\n");
 		return -1;
 	}
-	tdi->dirname = malloc(PATH_MAX);
-	if (tdi->dirname == NULL) {
-		printerr(0, "ERROR: Couldn't allocate directory name\n");
-		free(tdi);
-		return -1;
-	}
-	snprintf(tdi->dirname, PATH_MAX, "%s/%s", pipefs_dir, dent->d_name);
-	tdi->fd = open(tdi->dirname, O_RDONLY);
-	if (tdi->fd == -1) {
-		printerr(0, "ERROR: failed to open %s\n", tdi->dirname);
+
+	sprintf(tdi->dirname, "%s/%s", pipefs_dir, name);
+
+	tdi->fd = openat(pfd, name, O_RDONLY);
+	if (tdi->fd < 0) {
+		printerr(0, "ERROR: failed to open %s: %s\n",
+			 tdi->dirname, strerror(errno));
 		free(tdi);
 		return -1;
 	}
+
 	fcntl(tdi->fd, F_SETSIG, DNOTIFY_SIGNAL);
 	fcntl(tdi->fd, F_NOTIFY, DN_CREATE|DN_DELETE|DN_MODIFY|DN_MULTISHOT);
 
@@ -155,53 +153,37 @@ topdirs_add_entry(struct dirent *dent)
 }
 
 static void
-topdirs_free_list(void)
-{
-	struct topdirs_info *tdi;
-
-	TAILQ_FOREACH(tdi, &topdirs_list, list) {
-		free(tdi->dirname);
-		if (tdi->fd != -1)
-			close(tdi->fd);
-		TAILQ_REMOVE(&topdirs_list, tdi, list);
-		free(tdi);
-	}
-}
-
-static int
 topdirs_init_list(void)
 {
-	DIR		*pipedir;
-	struct dirent	*dent;
-	int		ret;
+	DIR *pipedir;
+	struct dirent *dent;
 
 	TAILQ_INIT(&topdirs_list);
 
-	pipedir = opendir(pipefs_dir);
-	if (pipedir == NULL) {
-		printerr(0, "ERROR: could not open rpc_pipefs directory '%s': "
-			 "%s\n", pipefs_dir, strerror(errno));
-		return -1;
+	pipedir = opendir(".");
+	if (!pipedir) {
+		printerr(0, "ERROR: could not open rpc_pipefs directory: '%s'\n",
+			 strerror(errno));
+		exit(EXIT_FAILURE);
 	}
-	for (dent = readdir(pipedir); dent != NULL; dent = readdir(pipedir)) {
-		if (dent->d_type != DT_DIR ||
-		    strcmp(dent->d_name, ".") == 0  ||
-		    strcmp(dent->d_name, "..") == 0) {
+
+	while ((dent = readdir(pipedir))) {
+		if (dent->d_type != DT_DIR)
 			continue;
-		}
-		ret = topdirs_add_entry(dent);
-		if (ret)
-			goto out_err;
+
+		if (dent->d_name[0] == '.')
+			continue;
+
+		if (topdirs_add_entry(dirfd(pipedir), dent->d_name))
+			exit(EXIT_FAILURE);
 	}
+
 	if (TAILQ_EMPTY(&topdirs_list)) {
-		printerr(0, "ERROR: rpc_pipefs directory '%s' is empty!\n", pipefs_dir);
-		return -1;
+		printerr(0, "ERROR: the rpc_pipefs directory is empty!\n");
+		exit(EXIT_FAILURE);
 	}
+
 	closedir(pipedir);
-	return 0;
-out_err:
-	topdirs_free_list();
-	return -1;
 }
 
 #ifdef HAVE_PPOLL
@@ -257,10 +239,7 @@ gssd_run(void)
 	sigaddset(&set, DNOTIFY_SIGNAL);
 	sigprocmask(SIG_UNBLOCK, &set, NULL);
 
-	if (topdirs_init_list() != 0) {
-		/* Error msg is already printed */
-		exit(1);
-	}
+	topdirs_init_list();
 	init_client_list();
 
 	printerr(1, "beginning poll\n");
@@ -276,9 +255,6 @@ gssd_run(void)
 		}
 		gssd_poll(pollarray, pollsize);
 	}
-	topdirs_free_list();
-
-	return;
 }
 
 static void
@@ -441,6 +417,11 @@ main(int argc, char *argv[])
 
 	daemon_init(fg);
 
+	if (chdir(pipefs_dir)) {
+		printerr(1, "ERROR: chdir(%s) failed: %s\n", pipefs_dir, strerror(errno));
+		exit(EXIT_FAILURE);
+	}
+
 	signal(SIGINT, sig_die);
 	signal(SIGTERM, sig_die);
 	signal(SIGHUP, sig_hup);
diff --git a/utils/gssd/gssd.h b/utils/gssd/gssd.h
index 3320d5e..91be83b 100644
--- a/utils/gssd/gssd.h
+++ b/utils/gssd/gssd.h
@@ -89,9 +89,9 @@ struct clnt_info {
 TAILQ_HEAD(topdirs_list_head, topdirs_info) topdirs_list;
 
 struct topdirs_info {
-	TAILQ_ENTRY(topdirs_info)   list;
-	char			*dirname;
-	int			fd;
+	TAILQ_ENTRY(topdirs_info)	list;
+	int				fd;
+	char				dirname[];
 };
 
 void init_client_list(void);


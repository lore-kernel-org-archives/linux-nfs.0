Return-Path: linux-nfs-owner@vger.kernel.org
Received: from vader.hardeman.nu ([95.142.160.32]:51271 "EHLO hardeman.nu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753576AbaLIFlZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Dec 2014 00:41:25 -0500
Subject: [PATCH 07/19] nfs-utils: gssd - simplify client dir scanning code
From: David =?utf-8?b?SMOkcmRlbWFu?= <david@hardeman.nu>
To: linux-nfs@vger.kernel.org
Cc: SteveD@redhat.com
Date: Tue, 09 Dec 2014 06:41:15 +0100
Message-ID: <20141209054115.24756.94417.stgit@zeus.muc.hardeman.nu>
In-Reply-To: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
References: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Simplify the client directory scanning and merge it into one
function that can be called both when a client initially
appears and later when it needs to be updated.

Signed-off-by: David Härdeman <david@hardeman.nu>
---
 utils/gssd/gssd.c |   85 ++++++++++++++++++++++-------------------------------
 1 file changed, 36 insertions(+), 49 deletions(-)

diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index 21abaed..7fa27c8 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -374,11 +374,29 @@ out:
 }
 
 static int
+get_poll_index(int *ind)
+{
+	unsigned int i;
+
+	*ind = -1;
+	for (i=0; i<pollsize; i++) {
+		if (pollarray[i].events == 0) {
+			*ind = i;
+			break;
+		}
+	}
+	if (*ind == -1) {
+		printerr(0, "ERROR: No pollarray slots open\n");
+		return -1;
+	}
+	return 0;
+}
+
+static int
 process_clnt_dir_files(struct clnt_info * clp)
 {
 	char	name[PATH_MAX];
 	char	gname[PATH_MAX];
-	char	info_file_name[PATH_MAX];
 
 	if (clp->gssd_close_me) {
 		printerr(2, "Closing 'gssd' pipe for %s\n", clp->dirname);
@@ -424,39 +442,18 @@ process_clnt_dir_files(struct clnt_info * clp)
 	}
 
 	if ((clp->krb5_fd == -1) && (clp->gssd_fd == -1))
-		return -1;
-	snprintf(info_file_name, sizeof(info_file_name), "%s/info",
-			clp->dirname);
-	if (clp->prog == 0)
+		/* not fatal, files might appear later */
+		return 0;
+
+	if (clp->prog == 0) {
+		char info_file_name[strlen(clp->dirname) + 6];
+
+		sprintf(info_file_name, "%s/info", clp->dirname);
 		read_service_info(info_file_name, &clp->servicename,
 				  &clp->servername, &clp->prog, &clp->vers,
 				  &clp->protocol, (struct sockaddr *) &clp->addr);
-	return 0;
-}
-
-static int
-get_poll_index(int *ind)
-{
-	unsigned int i;
-
-	*ind = -1;
-	for (i=0; i<pollsize; i++) {
-		if (pollarray[i].events == 0) {
-			*ind = i;
-			break;
-		}
 	}
-	if (*ind == -1) {
-		printerr(0, "ERROR: No pollarray slots open\n");
-		return -1;
-	}
-	return 0;
-}
-
 
-static int
-insert_clnt_poll(struct clnt_info *clp)
-{
 	if ((clp->gssd_fd != -1) && (clp->gssd_poll_index == -1)) {
 		if (get_poll_index(&clp->gssd_poll_index)) {
 			printerr(0, "ERROR: Too many gssd clients\n");
@@ -484,43 +481,35 @@ process_clnt_dir(char *dir, char *pdir)
 	struct clnt_info *	clp;
 
 	if (!(clp = insert_new_clnt()))
-		goto fail_destroy_client;
+		goto out;
 
 	if (!(clp->pdir = strdup(pdir)))
-		goto fail_destroy_client;
+		goto out;
 
 	/* An extra for the '/', and an extra for the null */
-	if (!(clp->dirname = calloc(strlen(dir) + strlen(pdir) + 2, 1))) {
-		goto fail_destroy_client;
-	}
+	if (!(clp->dirname = calloc(strlen(dir) + strlen(pdir) + 2, 1)))
+		goto out;
+
 	sprintf(clp->dirname, "%s/%s", pdir, dir);
 	if ((clp->dir_fd = open(clp->dirname, O_RDONLY)) == -1) {
 		if (errno != ENOENT)
 			printerr(0, "ERROR: can't open %s: %s\n",
 				 clp->dirname, strerror(errno));
-		goto fail_destroy_client;
+		goto out;
 	}
 	fcntl(clp->dir_fd, F_SETSIG, DNOTIFY_SIGNAL);
 	fcntl(clp->dir_fd, F_NOTIFY, DN_CREATE | DN_DELETE | DN_MULTISHOT);
 
 	if (process_clnt_dir_files(clp))
-		goto fail_keep_client;
-
-	if (insert_clnt_poll(clp))
-		goto fail_destroy_client;
+		goto out;
 
 	return;
 
-fail_destroy_client:
+out:
 	if (clp) {
 		TAILQ_REMOVE(&clnt_list, clp, list);
 		destroy_client(clp);
 	}
-fail_keep_client:
-	/* We couldn't find some subdirectories, but we keep the client
-	 * around in case we get a notification on the directory when the
-	 * subdirectories are created. */
-	return;
 }
 
 /*
@@ -559,10 +548,8 @@ update_old_clients(struct dirent **namelist, int size, char *pdir)
 			clp = saveprev;
 		}
 	}
-	for (clp = clnt_list.tqh_first; clp != NULL; clp = clp->list.tqe_next) {
-		if (!process_clnt_dir_files(clp))
-			insert_clnt_poll(clp);
-	}
+	for (clp = clnt_list.tqh_first; clp != NULL; clp = clp->list.tqe_next)
+		process_clnt_dir_files(clp);
 }
 
 /* Search for a client by directory name, return 1 if found, 0 otherwise */


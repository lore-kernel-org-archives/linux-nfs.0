From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 3/7] gssd: add support for callback authentication
Date: Wed, 29 Apr 2009 17:56:26 -0400
Message-ID: <20090429215626.25811.13927.stgit@jazz.citi.umich.edu>
References: <20090429214300.25811.81332.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:47712 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759051AbZD2V40 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Apr 2009 17:56:26 -0400
In-Reply-To: <20090429214300.25811.81332.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Olga Kornievskaia <aglo@citi.umich.edu>

Add support for handling upcalls on the new "nfsd4_cb" directory pipes.
Only new kernels (2.6.29) have support for this new pipe directory.
(The need for this new pipe directory will go away with NFSv4.1 where
the callback can be done on the same connection as the fore-channel.)

Signed-off-by: Olga Kornievskaia <aglo@citi.umich.edu>
Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 utils/gssd/gssd.c           |    5 +++
 utils/gssd/gssd.h           |    2 +
 utils/gssd/gssd_main_loop.c |   18 ++++++++++-
 utils/gssd/gssd_proc.c      |   73 +++++++++++++++++++++++++++++--------------
 4 files changed, 74 insertions(+), 24 deletions(-)

diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index f6949db..7a23362 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -57,6 +57,7 @@
 
 char pipefs_dir[PATH_MAX] = GSSD_PIPEFS_DIR;
 char pipefs_nfsdir[PATH_MAX] = GSSD_PIPEFS_DIR;
+char pipefs_nfscbdir[PATH_MAX] = GSSD_PIPEFS_DIR;
 char keytabfile[PATH_MAX] = GSSD_DEFAULT_KEYTAB_FILE;
 char ccachedir[PATH_MAX] = GSSD_DEFAULT_CRED_DIR;
 char *ccachesearch[GSSD_MAX_CCACHE_SEARCH + 1];
@@ -163,6 +164,10 @@ main(int argc, char *argv[])
 		 pipefs_dir, GSSD_SERVICE_NAME);
 	if (pipefs_nfsdir[sizeof(pipefs_nfsdir)-1] != '\0')
 		errx(1, "pipefs_nfsdir path name too long");
+	snprintf(pipefs_nfscbdir, sizeof(pipefs_nfscbdir), "%s/%s",
+		 pipefs_dir, GSSD_NFSCB_NAME);
+	if (pipefs_nfscbdir[sizeof(pipefs_nfscbdir)-1] != '\0')
+		errx(1, "pipefs_nfscbdir path name too long");
 
 	if ((progname = strrchr(argv[0], '/')))
 		progname++;
diff --git a/utils/gssd/gssd.h b/utils/gssd/gssd.h
index 3c52f46..ef2ac54 100644
--- a/utils/gssd/gssd.h
+++ b/utils/gssd/gssd.h
@@ -49,6 +49,7 @@
 #define GSSD_DEFAULT_MACHINE_CRED_SUFFIX	"machine"
 #define GSSD_DEFAULT_KEYTAB_FILE		"/etc/krb5.keytab"
 #define GSSD_SERVICE_NAME			"nfs"
+#define GSSD_NFSCB_NAME				"nfsd4_cb"
 #define GSSD_SERVICE_NAME_LEN			3
 #define GSSD_MAX_CCACHE_SEARCH			16
 
@@ -61,6 +62,7 @@ enum {AUTHTYPE_KRB5, AUTHTYPE_SPKM3, AUTHTYPE_LIPKEY};
 
 extern char			pipefs_dir[PATH_MAX];
 extern char			pipefs_nfsdir[PATH_MAX];
+extern char			pipefs_nfscbdir[PATH_MAX];
 extern char			keytabfile[PATH_MAX];
 extern char			*ccachesearch[];
 extern int			use_memcache;
diff --git a/utils/gssd/gssd_main_loop.c b/utils/gssd/gssd_main_loop.c
index 397fd14..1c1ff4f 100644
--- a/utils/gssd/gssd_main_loop.c
+++ b/utils/gssd/gssd_main_loop.c
@@ -103,7 +103,7 @@ gssd_run()
 {
 	int			ret;
 	struct sigaction	dn_act;
-	int			fd;
+	int			fd, fd_cb;
 	sigset_t		set;
 
 	/* Taken from linux/Documentation/dnotify.txt: */
@@ -125,6 +125,20 @@ gssd_run()
 	fcntl(fd, F_SETSIG, DNOTIFY_SIGNAL);
 	fcntl(fd, F_NOTIFY, DN_CREATE|DN_DELETE|DN_MODIFY|DN_MULTISHOT);
 
+	/* Attempt to open new callback pipe.  If the open fails,
+	 * don't try to process it. */
+	if ((fd_cb = open(pipefs_nfscbdir, O_RDONLY)) == -1) {
+		/* could be an older kernel or a newer one doing NFS 4.1 */
+		if (errno != ENOENT)
+			printerr(0, "WARNING: failed to open %s: %s\n",
+				 pipefs_nfscbdir, strerror(errno));
+		memset(pipefs_nfscbdir, '\0', sizeof(pipefs_nfscbdir));
+	} else {
+		fcntl(fd_cb, F_SETSIG, DNOTIFY_SIGNAL);
+		fcntl(fd_cb, F_NOTIFY,
+			DN_CREATE|DN_DELETE|DN_MODIFY|DN_MULTISHOT);
+	}
+
 	init_client_list();
 
 	printerr(1, "beginning poll\n");
@@ -151,5 +165,7 @@ gssd_run()
 		}
 	}
 	close(fd);
+	if (fd_cb != -1)
+		close(fd_cb);
 	return;
 }
diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 0fc0c42..969d113 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -232,11 +232,19 @@ read_service_info(char *info_file_name, char **servicename, char **servername,
 		sscanf(p, "port: %127s\n", cb_port);
 
 	/* check service, program, and version */
-	if(memcmp(service, "nfs", 3)) return -1;
+	if (memcmp(service, "nfs", 3) != 0)
+		return -1;
 	*prog = atoi(program + 1); /* skip open paren */
 	*vers = atoi(version);
-	if((*prog != 100003) || ((*vers != 2) && (*vers != 3) && (*vers != 4)))
-		goto fail;
+
+	if (strlen(service) == 3 ) {
+		if ((*prog != 100003) || ((*vers != 2) && (*vers != 3) &&
+		    (*vers != 4)))
+			goto fail;
+	} else if (memcmp(service, "nfs4_cb", 7) == 0) {
+		if (*vers != 1)
+			goto fail;
+	}
 
 	if (cb_port[0] != '\0') {
 		port = atoi(cb_port);
@@ -315,19 +323,18 @@ out:
 static int
 process_clnt_dir_files(struct clnt_info * clp)
 {
-	char	kname[32];
-	char	sname[32];
-	char	info_file_name[32];
+	char	name[PATH_MAX];
+	char	info_file_name[PATH_MAX];
 
 	if (clp->krb5_fd == -1) {
-		snprintf(kname, sizeof(kname), "%s/krb5", clp->dirname);
-		clp->krb5_fd = open(kname, O_RDWR);
+		snprintf(name, sizeof(name), "%s/krb5", clp->dirname);
+		clp->krb5_fd = open(name, O_RDWR);
 	}
 	if (clp->spkm3_fd == -1) {
-		snprintf(sname, sizeof(sname), "%s/spkm3", clp->dirname);
-		clp->spkm3_fd = open(sname, O_RDWR);
+		snprintf(name, sizeof(name), "%s/spkm3", clp->dirname);
+		clp->spkm3_fd = open(name, O_RDWR);
 	}
-	if((clp->krb5_fd == -1) && (clp->spkm3_fd == -1))
+	if ((clp->krb5_fd == -1) && (clp->spkm3_fd == -1))
 		return -1;
 	snprintf(info_file_name, sizeof(info_file_name), "%s/info",
 			clp->dirname);
@@ -384,17 +391,18 @@ insert_clnt_poll(struct clnt_info *clp)
 }
 
 static void
-process_clnt_dir(char *dir)
+process_clnt_dir(char *dir, char *pdir)
 {
 	struct clnt_info *	clp;
 
 	if (!(clp = insert_new_clnt()))
 		goto fail_destroy_client;
 
-	if (!(clp->dirname = calloc(strlen(dir) + 1, 1))) {
+	/* An extra for the '/', and an extra for the null */
+	if (!(clp->dirname = calloc(strlen(dir) + strlen(pdir) + 2, 1))) {
 		goto fail_destroy_client;
 	}
-	memcpy(clp->dirname, dir, strlen(dir));
+	sprintf(clp->dirname, "%s/%s", pdir, dir);
 	if ((clp->dir_fd = open(clp->dirname, O_RDONLY)) == -1) {
 		printerr(0, "ERROR: can't open %s: %s\n",
 			 clp->dirname, strerror(errno));
@@ -438,16 +446,24 @@ init_client_list(void)
  * directories, since the DNOTIFY could have been in there.
  */
 static void
-update_old_clients(struct dirent **namelist, int size)
+update_old_clients(struct dirent **namelist, int size, char *pdir)
 {
 	struct clnt_info *clp;
 	void *saveprev;
 	int i, stillhere;
+	char fname[PATH_MAX];
 
 	for (clp = clnt_list.tqh_first; clp != NULL; clp = clp->list.tqe_next) {
+		/* only compare entries in the global list that are from the
+		 * same pipefs parent directory as "pdir"
+		 */
+		if (strncmp(clp->dirname, pdir, strlen(pdir)) != 0) continue;
+
 		stillhere = 0;
 		for (i=0; i < size; i++) {
-			if (!strcmp(clp->dirname, namelist[i]->d_name)) {
+			snprintf(fname, sizeof(fname), "%s/%s",
+				 pdir, namelist[i]->d_name);
+			if (strcmp(clp->dirname, fname) == 0) {
 				stillhere = 1;
 				break;
 			}
@@ -468,13 +484,16 @@ update_old_clients(struct dirent **namelist, int size)
 
 /* Search for a client by directory name, return 1 if found, 0 otherwise */
 static int
-find_client(char *dirname)
+find_client(char *dirname, char *pdir)
 {
 	struct clnt_info	*clp;
+	char fname[PATH_MAX];
 
-	for (clp = clnt_list.tqh_first; clp != NULL; clp = clp->list.tqe_next)
-		if (!strcmp(clp->dirname, dirname))
+	for (clp = clnt_list.tqh_first; clp != NULL; clp = clp->list.tqe_next) {
+		snprintf(fname, sizeof(fname), "%s/%s", pdir, dirname);
+		if (strcmp(clp->dirname, fname) == 0)
 			return 1;
+	}
 	return 0;
 }
 
@@ -497,12 +516,12 @@ process_pipedir(char *pipe_name)
 		return -1;
 	}
 
-	update_old_clients(namelist, j);
+	update_old_clients(namelist, j, pipe_name);
 	for (i=0; i < j; i++) {
 		if (i < FD_ALLOC_BLOCK
 				&& !strncmp(namelist[i]->d_name, "clnt", 4)
-				&& !find_client(namelist[i]->d_name))
-			process_clnt_dir(namelist[i]->d_name);
+				&& !find_client(namelist[i]->d_name, pipe_name))
+			process_clnt_dir(namelist[i]->d_name, pipe_name);
 		free(namelist[i]);
 	}
 
@@ -510,7 +529,6 @@ process_pipedir(char *pipe_name)
 
 	return 0;
 }
-
 /* Used to read (and re-read) list of clients, set up poll array. */
 int
 update_client_list(void)
@@ -521,6 +539,15 @@ update_client_list(void)
 	if (retval)
 		printerr(0, "ERROR: processing %s\n", pipefs_nfsdir);
 
+	/* If we successfully processed nfsdir and callback directory exists
+	 * process any events in the callback directory
+	 */
+	if (retval == 0 && pipefs_nfscbdir[0] != '\0') {
+		retval = process_pipedir(pipefs_nfscbdir);
+		if (retval)
+			printerr(0, "ERROR: processing %s\n", pipefs_nfscbdir);
+	}
+
 	return retval;
 }
 


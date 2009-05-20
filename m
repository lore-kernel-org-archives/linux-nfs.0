From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [round2 PATCH 3/7] gssd: add upcall support for callback
	authentication
Date: Wed, 20 May 2009 11:20:51 -0400
Message-ID: <20090520152051.2986.87384.stgit@jazz.citi.umich.edu>
References: <20090520151651.2986.29621.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:36502 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756614AbZETPUu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 May 2009 11:20:50 -0400
In-Reply-To: <20090520151651.2986.29621.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Change the processing so that all subdirectories within the rpc_pipefs
directory are treated equally.  Any "clnt" directories that show up
within any of them are processed.  (As suggested by Bruce Fields.)

Note that the callback authentication will create a new "nfs4d_cb"
subdirectory.  Only new kernels (2.6.29) will create this new directory.
(The need for this directory will go away with NFSv4.1 where the
callback can be done on the same connection as the fore-channel.)

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 utils/gssd/gssd.c           |    6 ---
 utils/gssd/gssd.h           |    9 ++++
 utils/gssd/gssd_main_loop.c |   88 ++++++++++++++++++++++++++++++++++++++-----
 utils/gssd/gssd_proc.c      |   89 +++++++++++++++++++++++++++----------------
 4 files changed, 143 insertions(+), 49 deletions(-)

diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index f6949db..a8a3fd9 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -56,7 +56,6 @@
 #include "krb5_util.h"
 
 char pipefs_dir[PATH_MAX] = GSSD_PIPEFS_DIR;
-char pipefs_nfsdir[PATH_MAX] = GSSD_PIPEFS_DIR;
 char keytabfile[PATH_MAX] = GSSD_DEFAULT_KEYTAB_FILE;
 char ccachedir[PATH_MAX] = GSSD_DEFAULT_CRED_DIR;
 char *ccachesearch[GSSD_MAX_CCACHE_SEARCH + 1];
@@ -159,11 +158,6 @@ main(int argc, char *argv[])
 	if (preferred_realm == NULL)
 		gssd_k5_get_default_realm(&preferred_realm);
 
-	snprintf(pipefs_nfsdir, sizeof(pipefs_nfsdir), "%s/%s",
-		 pipefs_dir, GSSD_SERVICE_NAME);
-	if (pipefs_nfsdir[sizeof(pipefs_nfsdir)-1] != '\0')
-		errx(1, "pipefs_nfsdir path name too long");
-
 	if ((progname = strrchr(argv[0], '/')))
 		progname++;
 	else
diff --git a/utils/gssd/gssd.h b/utils/gssd/gssd.h
index 3c52f46..3c53a88 100644
--- a/utils/gssd/gssd.h
+++ b/utils/gssd/gssd.h
@@ -60,7 +60,6 @@ enum {AUTHTYPE_KRB5, AUTHTYPE_SPKM3, AUTHTYPE_LIPKEY};
 
 
 extern char			pipefs_dir[PATH_MAX];
-extern char			pipefs_nfsdir[PATH_MAX];
 extern char			keytabfile[PATH_MAX];
 extern char			*ccachesearch[];
 extern int			use_memcache;
@@ -86,6 +85,14 @@ struct clnt_info {
 	struct sockaddr_storage addr;
 };
 
+TAILQ_HEAD(topdirs_list_head, topdirs_info) topdirs_list;
+
+struct topdirs_info {
+	TAILQ_ENTRY(topdirs_info)   list;
+	char			*dirname;
+	int			fd;
+};
+
 void init_client_list(void);
 int update_client_list(void);
 void handle_krb5_upcall(struct clnt_info *clp);
diff --git a/utils/gssd/gssd_main_loop.c b/utils/gssd/gssd_main_loop.c
index 397fd14..b5117c5 100644
--- a/utils/gssd/gssd_main_loop.c
+++ b/utils/gssd/gssd_main_loop.c
@@ -49,6 +49,7 @@
 #include <fcntl.h>
 #include <signal.h>
 #include <unistd.h>
+#include <dirent.h>
 
 #include "gssd.h"
 #include "err_util.h"
@@ -98,12 +99,85 @@ scan_poll_results(int ret)
 	}
 };
 
+static int
+topdirs_add_entry(struct dirent *dent)
+{
+	struct topdirs_info *tdi;
+
+	tdi = calloc(sizeof(struct topdirs_info), 1);
+	if (tdi == NULL) {
+		printerr(0, "ERROR: Couldn't allocate struct topdirs_info\n");
+		return -1;
+	}
+	tdi->dirname = malloc(PATH_MAX);
+	if (tdi->dirname == NULL) {
+		printerr(0, "ERROR: Couldn't allocate directory name\n");
+		free(tdi);
+		return -1;
+	}
+	snprintf(tdi->dirname, PATH_MAX, "%s/%s", pipefs_dir, dent->d_name);
+	tdi->fd = open(tdi->dirname, O_RDONLY);
+	if (tdi->fd != -1) {
+		fcntl(tdi->fd, F_SETSIG, DNOTIFY_SIGNAL);
+		fcntl(tdi->fd, F_NOTIFY,
+		      DN_CREATE|DN_DELETE|DN_MODIFY|DN_MULTISHOT);
+	}
+
+	TAILQ_INSERT_HEAD(&topdirs_list, tdi, list);
+	return 0;
+}
+
+static void
+topdirs_free_list(void)
+{
+	struct topdirs_info *tdi;
+
+	TAILQ_FOREACH(tdi, &topdirs_list, list) {
+		free(tdi->dirname);
+		if (tdi->fd != -1)
+			close(tdi->fd);
+		TAILQ_REMOVE(&topdirs_list, tdi, list);
+		free(tdi);
+	}
+}
+
+static int
+topdirs_init_list(void)
+{
+	DIR		*pipedir;
+	struct dirent	*dent;
+	int		ret;
+
+	TAILQ_INIT(&topdirs_list);
+
+	pipedir = opendir(pipefs_dir);
+	if (pipedir == NULL) {
+		printerr(0, "ERROR: could not open rpc_pipefs directory '%s': "
+			 "%s\n", pipefs_dir, strerror(errno));
+		return -1;
+	}
+	for (dent = readdir(pipedir); dent != NULL; dent = readdir(pipedir)) {
+		if (dent->d_type != DT_DIR ||
+		    strcmp(dent->d_name, ".") == 0  ||
+		    strcmp(dent->d_name, "..") == 0) {
+			continue;
+		}
+		ret = topdirs_add_entry(dent);
+		if (ret)
+			goto out_err;
+	}
+	closedir(pipedir);
+	return 0;
+out_err:
+	topdirs_free_list();
+	return -1;
+}
+
 void
 gssd_run()
 {
 	int			ret;
 	struct sigaction	dn_act;
-	int			fd;
 	sigset_t		set;
 
 	/* Taken from linux/Documentation/dnotify.txt: */
@@ -117,13 +191,8 @@ gssd_run()
 	sigaddset(&set, DNOTIFY_SIGNAL);
 	sigprocmask(SIG_UNBLOCK, &set, NULL);
 
-	if ((fd = open(pipefs_nfsdir, O_RDONLY)) == -1) {
-		printerr(0, "ERROR: failed to open %s: %s\n",
-			 pipefs_nfsdir, strerror(errno));
-		exit(1);
-	}
-	fcntl(fd, F_SETSIG, DNOTIFY_SIGNAL);
-	fcntl(fd, F_NOTIFY, DN_CREATE|DN_DELETE|DN_MODIFY|DN_MULTISHOT);
+	if (topdirs_init_list() != 0)
+		return;
 
 	init_client_list();
 
@@ -150,6 +219,7 @@ gssd_run()
 			scan_poll_results(ret);
 		}
 	}
-	close(fd);
+	topdirs_free_list();
+
 	return;
 }
diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 0fc0c42..d56865c 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -83,20 +83,20 @@
  *      linked list of struct clnt_info which associates a clntXXX directory
  *	with an index into pollarray[], and other basic data about that client.
  *
- * Directory structure: created by the kernel nfs client
- *      {pipefs_nfsdir}/clntXX             : one per rpc_clnt struct in the kernel
- *      {pipefs_nfsdir}/clntXX/krb5        : read uid for which kernel wants
+ * Directory structure: created by the kernel
+ *      {rpc_pipefs}/{dir}/clntXX         : one per rpc_clnt struct in the kernel
+ *      {rpc_pipefs}/{dir}/clntXX/krb5    : read uid for which kernel wants
  *					    a context, write the resulting context
- *      {pipefs_nfsdir}/clntXX/info        : stores info such as server name
+ *      {rpc_pipefs}/{dir}/clntXX/info    : stores info such as server name
  *
  * Algorithm:
- *      Poll all {pipefs_nfsdir}/clntXX/krb5 files.  When ready, data read
- *      is a uid; performs rpcsec_gss context initialization protocol to
+ *      Poll all {rpc_pipefs}/{dir}/clntXX/krb5 files.  When data is ready,
+ *      read and process; performs rpcsec_gss context initialization protocol to
  *      get a cred for that user.  Writes result to corresponding krb5 file
  *      in a form the kernel code will understand.
  *      In addition, we make sure we are notified whenever anything is
- *      created or destroyed in {pipefs_nfsdir} or in an of the clntXX directories,
- *      and rescan the whole {pipefs_nfsdir} when this happens.
+ *      created or destroyed in {rpc_pipefs} or in any of the clntXX directories,
+ *      and rescan the whole {rpc_pipefs} when this happens.
  */
 
 struct pollfd * pollarray;
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
 
@@ -516,11 +535,15 @@ int
 update_client_list(void)
 {
 	int retval = -1;
+	struct topdirs_info *tdi;
 
-	retval = process_pipedir(pipefs_nfsdir);
-	if (retval)
-		printerr(0, "ERROR: processing %s\n", pipefs_nfsdir);
+	TAILQ_FOREACH(tdi, &topdirs_list, list) {
+		retval = process_pipedir(tdi->dirname);
+		if (retval)
+			printerr(1, "WARNING: error processing %s\n",
+				 tdi->dirname);
 
+	}
 	return retval;
 }
 


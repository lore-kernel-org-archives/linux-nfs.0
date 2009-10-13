From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/26] statd: Use the new nsm_ file.c calls in sm_notify
Date: Tue, 13 Oct 2009 10:55:26 -0400
Message-ID: <20091013145526.2424.89310.stgit@matisse.1015granger.net>
References: <20091013142257.2424.76946.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: chris.mason@oracle.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:26071 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760092AbZJMO4P (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Oct 2009 10:56:15 -0400
Received: from rgminet13.oracle.com (rcsinet13.oracle.com [148.87.113.125])
	by acsinet11.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n9DEttUw025633
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2009 14:55:56 GMT
Received: from acsmt353.oracle.com (acsmt353.oracle.com [141.146.40.153])
	by rgminet13.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n9DEaKxW012723
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2009 14:56:09 GMT
In-Reply-To: <20091013142257.2424.76946.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace open-coded accesses to on-disk NSM information in sm_notify.c
with calls to the new API.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/sm-notify.c |  267 ++++++++---------------------------------------
 1 files changed, 46 insertions(+), 221 deletions(-)

diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index 1983ef6..157cd34 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -29,25 +29,9 @@
 #include <grp.h>
 
 #include "xlog.h"
+#include "nsm.h"
 #include "nfsrpc.h"
 
-#ifndef BASEDIR
-# ifdef NFS_STATEDIR
-#  define BASEDIR		NFS_STATEDIR
-# else
-#  define BASEDIR		"/var/lib/nfs"
-# endif
-#endif
-
-#define DEFAULT_SM_STATE_PATH	BASEDIR "/state"
-#define	DEFAULT_SM_DIR_PATH	BASEDIR "/sm"
-#define	DEFAULT_SM_BAK_PATH	DEFAULT_SM_DIR_PATH ".bak"
-
-char *_SM_BASE_PATH = BASEDIR;
-char *_SM_STATE_PATH = DEFAULT_SM_STATE_PATH;
-char *_SM_DIR_PATH = DEFAULT_SM_DIR_PATH;
-char *_SM_BAK_PATH = DEFAULT_SM_BAK_PATH;
-
 #define NSM_PROG	100024
 #define NSM_PROGRAM	100024
 #define NSM_VERSION	1
@@ -59,7 +43,6 @@ char *_SM_BAK_PATH = DEFAULT_SM_BAK_PATH;
 struct nsm_host {
 	struct nsm_host *	next;
 	char *			name;
-	char *			path;
 	struct sockaddr_storage	addr;
 	socklen_t		addrlen;
 	struct addrinfo		*ai;
@@ -78,17 +61,12 @@ static unsigned int	opt_max_retry = 15 * 60;
 static char *		opt_srcaddr = 0;
 static uint16_t		opt_srcport = 0;
 
-static unsigned int	nsm_get_state(int);
 static void		notify(void);
 static int		notify_host(int, struct nsm_host *);
 static void		recv_reply(int);
-static void		backup_hosts(const char *, const char *);
-static void		get_hosts(const char *);
 static void		insert_host(struct nsm_host *);
 static struct nsm_host *find_host(uint32_t);
 static int		record_pid(void);
-static void		drop_privs(void);
-static void		set_kernel_nsm_state(int state);
 
 static struct nsm_host *	hosts = NULL;
 
@@ -112,10 +90,44 @@ static struct addrinfo *smn_lookup(const char *name)
 	return ai;
 }
 
+static unsigned int
+smn_get_host(const char *hostname,
+		__attribute__((unused)) const struct sockaddr *sap,
+		__attribute__((unused)) const struct mon *mon,
+		const time_t timestamp)
+{
+	struct nsm_host	*host;
+
+	host = calloc(1, sizeof(*host));
+	if (host == NULL)
+		goto out_nomem;
+
+	host->name = strdup(hostname);
+	if (host->name == NULL) {
+		free(host);
+		goto out_nomem;
+	}
+
+	xlog(D_GENERAL, "Adding host %s to notify list", hostname);
+
+	host->last_used = timestamp;
+	host->timeout = NSM_TIMEOUT;
+	host->retries = 100; /* force address retry */
+
+	insert_host(host);
+	return 1;
+
+out_nomem:
+	xlog_warn("Unable to allocate memory");
+	return 0;
+}
+
 static void smn_forget_host(struct nsm_host *host)
 {
-	unlink(host->path);
-	free(host->path);
+	xlog(D_CALL, "Removing %s from notify list", host->name);
+
+	nsm_delete_notified_host(host->name);
+
 	free(host->name);
 	if (host->ai)
 		freeaddrinfo(host->ai);
@@ -157,20 +169,8 @@ main(int argc, char **argv)
 			opt_srcaddr = optarg;
 			break;
 		case 'P':
-			_SM_BASE_PATH = strdup(optarg);
-			_SM_STATE_PATH = malloc(strlen(optarg)+1+sizeof("state"));
-			_SM_DIR_PATH = malloc(strlen(optarg)+1+sizeof("sm"));
-			_SM_BAK_PATH = malloc(strlen(optarg)+1+sizeof("sm.bak"));
-			if (_SM_BASE_PATH == NULL ||
-			    _SM_STATE_PATH == NULL ||
-			    _SM_DIR_PATH == NULL ||
-			    _SM_BAK_PATH == NULL) {
-				fprintf(stderr, "unable to allocate memory");
+			if (!nsm_setup_pathnames(argv[0], optarg))
 				exit(1);
-			}
-			strcat(strcpy(_SM_STATE_PATH, _SM_BASE_PATH), "/state");
-			strcat(strcpy(_SM_DIR_PATH, _SM_BASE_PATH), "/sm");
-			strcat(strcpy(_SM_BAK_PATH, _SM_BASE_PATH), "/sm.bak");
 			break;
 
 		default:
@@ -196,7 +196,7 @@ usage:		fprintf(stderr,
 	xlog_open(progname);
 	xlog(L_NOTICE, "Version " VERSION " starting");
 
-	if (strcmp(_SM_BASE_PATH, BASEDIR) == 0) {
+	if (nsm_is_default_parentdir()) {
 		if (record_pid() == 0 && force == 0 && opt_update_state == 1) {
 			/* already run, don't try again */
 			xlog(L_NOTICE, "Already notifying clients; Exiting!");
@@ -212,18 +212,16 @@ usage:		fprintf(stderr,
 		exit(1);
 	}
 
-	backup_hosts(_SM_DIR_PATH, _SM_BAK_PATH);
-	get_hosts(_SM_BAK_PATH);
-
-	/* If there are not hosts to notify, just exit */
-	if (!hosts) {
+	(void)nsm_retire_monitored_hosts();
+	if (!nsm_load_notify_list(smn_get_host)) {
 		xlog(D_GENERAL, "No hosts to notify; exiting");
 		return 0;
 	}
 
-	/* Get and update the NSM state. This will call sync() */
 	nsm_state = nsm_get_state(opt_update_state);
-	set_kernel_nsm_state(nsm_state);
+	if (nsm_state == 0)
+		exit(1);
+	nsm_update_kernel_state(nsm_state);
 
 	if (!opt_debug) {
 		xlog(L_NOTICE, "Backgrounding to notify hosts...\n");
@@ -317,7 +315,8 @@ notify(void)
 	if (opt_max_retry)
 		failtime = time(NULL) + opt_max_retry;
 
-	drop_privs();
+	if (!nsm_drop_privileges(-1))
+		exit(1);
 
 	while (hosts) {
 		struct pollfd	pfd;
@@ -556,82 +555,6 @@ fail:	/* Re-insert the host */
 }
 
 /*
- * Back up all hosts from the sm directory to sm.bak
- */
-static void
-backup_hosts(const char *dirname, const char *bakname)
-{
-	struct dirent	*de;
-	DIR		*dir;
-
-	if (!(dir = opendir(dirname))) {
-		xlog_warn("Failed to open %s: %m", dirname);
-		return;
-	}
-
-	while ((de = readdir(dir)) != NULL) {
-		char	src[1024], dst[1024];
-
-		if (de->d_name[0] == '.')
-			continue;
-
-		snprintf(src, sizeof(src), "%s/%s", dirname, de->d_name);
-		snprintf(dst, sizeof(dst), "%s/%s", bakname, de->d_name);
-		if (rename(src, dst) < 0)
-			xlog_warn("Failed to rename %s -> %s: %m", src, dst);
-	}
-	closedir(dir);
-}
-
-/*
- * Get all entries from sm.bak and convert them to host entries
- */
-static void
-get_hosts(const char *dirname)
-{
-	struct nsm_host	*host;
-	struct dirent	*de;
-	DIR		*dir;
-
-	if (!(dir = opendir(dirname))) {
-		xlog_warn("Failed to open %s: %m", dirname);
-		return;
-	}
-
-	host = NULL;
-	while ((de = readdir(dir)) != NULL) {
-		struct stat	stb;
-		char		path[1024];
-
-		if (de->d_name[0] == '.')
-			continue;
-		if (host == NULL)
-			host = calloc(1, sizeof(*host));
-		if (host == NULL) {
-			xlog_warn("Unable to allocate memory");
-			return;
-		}
-
-		snprintf(path, sizeof(path), "%s/%s", dirname, de->d_name);
-		if (stat(path, &stb) < 0)
-			continue;
-
-		host->last_used = stb.st_mtime;
-		host->timeout = NSM_TIMEOUT;
-		host->path = strdup(path);
-		host->name = strdup(de->d_name);
-		host->retries = 100; /* force address retry */
-
-		insert_host(host);
-		host = NULL;
-	}
-	closedir(dir);
-
-	if (host)
-		free(host);
-}
-
-/*
  * Insert host into sorted list
  */
 static void
@@ -678,60 +601,6 @@ find_host(uint32_t xid)
 	return NULL;
 }
 
-
-/*
- * Retrieve the current NSM state
- */
-static unsigned int
-nsm_get_state(int update)
-{
-	char		newfile[PATH_MAX];
-	int		fd, state;
-
-	if ((fd = open(_SM_STATE_PATH, O_RDONLY)) < 0) {
-		xlog_warn("%s: %m", _SM_STATE_PATH);
-		xlog_warn("Creating %s, set initial state 1",
-			_SM_STATE_PATH);
-		state = 1;
-		update = 1;
-	} else {
-		if (read(fd, &state, sizeof(state)) != sizeof(state)) {
-			xlog_warn("%s: bad file size, setting state = 1",
-				_SM_STATE_PATH);
-			state = 1;
-			update = 1;
-		} else {
-			if (!(state & 1))
-				state += 1;
-		}
-		close(fd);
-	}
-
-	if (update) {
-		state += 2;
-		snprintf(newfile, sizeof(newfile),
-				"%s.new", _SM_STATE_PATH);
-		if ((fd = open(newfile, O_CREAT|O_WRONLY, 0644)) < 0) {
-			xlog(L_ERROR, "Cannot create %s: %m", newfile);
-			exit(1);
-		}
-		if (write(fd, &state, sizeof(state)) != sizeof(state)) {
-			xlog(L_ERROR,
-				"Failed to write state to %s", newfile);
-			exit(1);
-		}
-		close(fd);
-		if (rename(newfile, _SM_STATE_PATH) < 0) {
-			xlog(L_ERROR,
-				"Cannot create %s: %m", _SM_STATE_PATH);
-			exit(1);
-		}
-		sync();
-	}
-
-	return state;
-}
-
 /*
  * Record pid in /var/run/sm-notify.pid
  * This file should remain until a reboot, even if the
@@ -754,47 +623,3 @@ static int record_pid(void)
 	close(fd);
 	return 1;
 }
-
-/* Drop privileges to match owner of state-directory
- * (in case a reply triggers some unknown bug).
- */
-static void drop_privs(void)
-{
-	struct stat st;
-
-	if (stat(_SM_DIR_PATH, &st) == -1 &&
-	    stat(_SM_BASE_PATH, &st) == -1) {
-		st.st_uid = 0;
-		st.st_gid = 0;
-	}
-
-	if (st.st_uid == 0) {
-		xlog_warn("Running as 'root'.  "
-			"chown %s to choose different user", _SM_DIR_PATH);
-		return;
-	}
-
-	setgroups(0, NULL);
-	if (setgid(st.st_gid) == -1
-	    || setuid(st.st_uid) == -1) {
-		xlog(L_ERROR, "Fail to drop privileges");
-		exit(1);
-	}
-}
-
-static void set_kernel_nsm_state(int state)
-{
-	int fd;
-	const char *file = "/proc/sys/fs/nfs/nsm_local_state";
-
-	fd = open(file ,O_WRONLY);
-	if (fd >= 0) {
-		char buf[20];
-		snprintf(buf, sizeof(buf), "%d", state);
-		if (write(fd, buf, strlen(buf)) != strlen(buf)) {
-			xlog_warn("Writing to '%s' failed: errno %d (%m)",
-				file, errno);
-		}
-		close(fd);
-	}
-}


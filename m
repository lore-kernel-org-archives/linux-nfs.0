Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58224 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751046AbdBAPTa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 1 Feb 2017 10:19:30 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: neilb@suse.com, linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH v2 2/2] mountd/exportfs: implement the -s/--state-directory-path option
Date: Wed,  1 Feb 2017 10:19:29 -0500
Message-Id: <1485962369-25852-3-git-send-email-smayhew@redhat.com>
In-Reply-To: <1485962369-25852-1-git-send-email-smayhew@redhat.com>
References: <1485962369-25852-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 support/export/xtab.c     | 82 +++++++++++++++++++++++++++++++++++++++++++++--
 support/include/nfslib.h  | 17 ++++++++++
 support/nfs/cacheio.c     |  4 ++-
 support/nfs/rmtab.c       |  4 ++-
 utils/exportfs/exportfs.c | 13 ++++++++
 utils/mountd/auth.c       |  8 +++--
 utils/mountd/mountd.c     | 31 +++++++++++-------
 utils/mountd/mountd.man   |  2 +-
 utils/mountd/rmtab.c      | 26 ++++++++-------
 9 files changed, 156 insertions(+), 31 deletions(-)

diff --git a/support/export/xtab.c b/support/export/xtab.c
index 22cf539..a5bfa6e 100644
--- a/support/export/xtab.c
+++ b/support/export/xtab.c
@@ -14,12 +14,20 @@
 #include <unistd.h>
 #include <stdlib.h>
 #include <string.h>
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <errno.h>
+#include <libgen.h>
 
 #include "nfslib.h"
 #include "exportfs.h"
 #include "xio.h"
 #include "xlog.h"
 #include "v4root.h"
+#include "misc.h"
+
+static char state_base_dirname[PATH_MAX] = NFS_STATEDIR;
+extern struct state_paths etab;
 
 int v4root_needed;
 static void cond_rename(char *newfile, char *oldfile);
@@ -65,7 +73,7 @@ xtab_read(char *xtab, char *lockfn, int is_export)
 int
 xtab_export_read(void)
 {
-	return xtab_read(_PATH_ETAB, _PATH_ETABLCK, 1);
+	return xtab_read(etab.statefn, etab.lockfn, 1);
 }
 
 /*
@@ -112,7 +120,7 @@ xtab_write(char *xtab, char *xtabtmp, char *lockfn, int is_export)
 int
 xtab_export_write()
 {
-	return xtab_write(_PATH_ETAB, _PATH_ETABTMP, _PATH_ETABLCK, 1);
+	return xtab_write(etab.statefn, etab.tmpfn, etab.lockfn, 1);
 }
 
 /*
@@ -158,3 +166,73 @@ static void cond_rename(char *newfile, char *oldfile)
 	rename(newfile, oldfile);
 	return;
 }
+
+/*
+ * Returns a dynamically allocated, '\0'-terminated buffer
+ * containing an appropriate pathname, or NULL if an error
+ * occurs.  Caller must free the returned result with free(3).
+ */
+static char *
+state_make_pathname(const char *tabname)
+{
+	return generic_make_pathname(state_base_dirname, tabname);
+}
+
+/**
+ * state_setup_basedir - set up basedir
+ * @progname: C string containing name of program, for error messages
+ * @parentdir: C string containing pathname to on-disk state, or NULL
+ *
+ * This runs before logging is set up, so error messages are directed
+ * to stderr.
+ *
+ * Returns true and sets up our basedir, if @parentdir was valid
+ * and usable; otherwise false is returned.
+ */
+_Bool
+state_setup_basedir(const char *progname, const char *parentdir)
+{
+	return generic_setup_basedir(progname, parentdir, state_base_dirname);
+}
+
+int
+setup_state_path_names(const char *progname, const char *statefn,
+		      const char *tmpfn, const char *lockfn,
+		      struct state_paths *paths)
+{
+	paths->statefn = state_make_pathname(statefn);
+	if (!paths->statefn) {
+		fprintf(stderr, "%s: state_make_pathname(%s) failed\n",
+			progname, statefn);
+		goto out_err;
+	}
+	paths->tmpfn = state_make_pathname(tmpfn);
+	if (!paths->tmpfn) {
+		fprintf(stderr, "%s: state_make_pathname(%s) failed\n",
+			progname, tmpfn);
+		goto out_free_statefn;
+	}
+	paths->lockfn = state_make_pathname(lockfn);
+	if (!paths->lockfn) {
+		fprintf(stderr, "%s: state_make_pathname(%s) failed\n",
+			progname, lockfn);
+		goto out_free_tmpfn;
+	}
+	return 1;
+
+out_free_tmpfn:
+	free(paths->tmpfn);
+out_free_statefn:
+	free(paths->statefn);
+out_err:
+	return 0;
+
+}
+
+void
+free_state_path_names(struct state_paths *paths)
+{
+	free(paths->statefn);
+	free(paths->tmpfn);
+	free(paths->lockfn);
+}
diff --git a/support/include/nfslib.h b/support/include/nfslib.h
index 1498977..adcbe43 100644
--- a/support/include/nfslib.h
+++ b/support/include/nfslib.h
@@ -58,6 +58,19 @@
 #define	_PATH_PROC_EXPORTS_ALT	"/proc/fs/nfsd/exports"
 #endif
 
+#define ETAB		"etab"
+#define ETABTMP		"etab.tmp"
+#define ETABLCK 	".etab.lock"
+#define RMTAB		"rmtab"
+#define RMTABTMP	"rmtab.tmp"
+#define RMTABLCK	".rmtab.lock"
+
+struct state_paths {
+	char *statefn;
+	char *tmpfn;
+	char *lockfn;
+};
+
 /* Maximum number of security flavors on an export: */
 #define SECFLAVOR_COUNT 8
 
@@ -120,6 +133,10 @@ void			fputrmtabent(FILE *fp, struct rmtabent *xep, long *pos);
 void			fendrmtabent(FILE *fp);
 void			frewindrmtabent(FILE *fp);
 
+_Bool state_setup_basedir(const char *, const char *);
+int setup_state_path_names(const char *, const char *, const char *, const char *, struct state_paths *);
+void free_state_path_names(struct state_paths *);
+
 /* mydaemon */
 void daemon_init(bool fg);
 void daemon_ready(void);
diff --git a/support/nfs/cacheio.c b/support/nfs/cacheio.c
index e5e2579..885a4bb 100644
--- a/support/nfs/cacheio.c
+++ b/support/nfs/cacheio.c
@@ -27,6 +27,8 @@
 #include <time.h>
 #include <errno.h>
 
+extern struct state_paths etab;
+
 void qword_add(char **bpp, int *lp, char *str)
 {
 	char *bp = *bpp;
@@ -228,7 +230,7 @@ cache_flush(int force)
 	};
 	now = time(0);
 	if (force ||
-	    stat(_PATH_ETAB, &stb) != 0 ||
+	    stat(etab.statefn, &stb) != 0 ||
 	    stb.st_mtime > now)
 		stb.st_mtime = time(0);
 	
diff --git a/support/nfs/rmtab.c b/support/nfs/rmtab.c
index 59dfbdf..2ecb2cc 100644
--- a/support/nfs/rmtab.c
+++ b/support/nfs/rmtab.c
@@ -33,12 +33,14 @@
 
 static FILE	*rmfp = NULL;
 
+extern struct state_paths rmtab;
+
 int
 setrmtabent(char *type)
 {
 	if (rmfp)
 		fclose(rmfp);
-	rmfp = fsetrmtabent(_PATH_RMTAB, type);
+	rmfp = fsetrmtabent(rmtab.statefn, type);
 	return (rmfp != NULL);
 }
 
diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index 61dddfb..02d5b6d 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -52,6 +52,8 @@ static const char *lockfile = EXP_LOCKFILE;
 static int _lockfd = -1;
 char *conf_path = NFS_CONFFILE;
 
+struct state_paths etab;
+
 /*
  * If we aren't careful, changes made by exportfs can be lost
  * when multiple exports process run at once:
@@ -95,6 +97,7 @@ main(int argc, char **argv)
 	int	f_ignore = 0;
 	int	i, c;
 	int	force_flush = 0;
+	char	*s;
 
 	if ((progname = strrchr(argv[0], '/')) != NULL)
 		progname++;
@@ -108,6 +111,11 @@ main(int argc, char **argv)
 	conf_init();
 	xlog_from_conffile("exportfs");
 
+	/* NOTE: following uses "mountd" section of nfs.conf !!!! */
+	s = conf_get_str("mountd", "state-directory-path");
+	if (s && !state_setup_basedir(argv[0], s))
+		exit(1);
+
 	while ((c = getopt(argc, argv, "ad:fhio:ruvs")) != EOF) {
 		switch(c) {
 		case 'a':
@@ -159,13 +167,17 @@ main(int argc, char **argv)
 		xlog(L_ERROR, "-r and -u are incompatible");
 		return 1;
 	}
+	if (!setup_state_path_names(progname, ETAB, ETABTMP, ETABLCK, &etab))
+		return 1;
 	if (optind == argc && ! f_all) {
 		if (force_flush) {
 			cache_flush(1);
+			free_state_path_names(&etab);
 			return 0;
 		} else {
 			xtab_export_read();
 			dump(f_verbose, f_export_format);
+			free_state_path_names(&etab);
 			return 0;
 		}
 	}
@@ -206,6 +218,7 @@ main(int argc, char **argv)
 	}
 	xtab_export_write();
 	cache_flush(force_flush);
+	free_state_path_names(&etab);
 
 	return export_errno;
 }
diff --git a/utils/mountd/auth.c b/utils/mountd/auth.c
index d065830..8299256 100644
--- a/utils/mountd/auth.c
+++ b/utils/mountd/auth.c
@@ -41,6 +41,8 @@ static nfs_client my_client;
 
 extern int use_ipaddr;
 
+extern struct state_paths etab;
+
 void
 auth_init(void)
 {
@@ -84,10 +86,10 @@ auth_reload()
 	static unsigned int	counter;
 	int			fd;
 
-	if ((fd = open(_PATH_ETAB, O_RDONLY)) < 0) {
-		xlog(L_FATAL, "couldn't open %s", _PATH_ETAB);
+	if ((fd = open(etab.statefn, O_RDONLY)) < 0) {
+		xlog(L_FATAL, "couldn't open %s", etab.statefn);
 	} else if (fstat(fd, &stb) < 0) {
-		xlog(L_FATAL, "couldn't stat %s", _PATH_ETAB);
+		xlog(L_FATAL, "couldn't stat %s", etab.statefn);
 		close(fd);
 	} else if (last_fd != -1 && stb.st_ino == last_inode) {
 		/* We opened the etab file before, and its inode
diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index 61699e6..bbadfaf 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -29,6 +29,7 @@
 #include "mountd.h"
 #include "rpcmisc.h"
 #include "pseudoflavors.h"
+#include "nfslib.h"
 
 extern void my_svc_run(void);
 
@@ -40,6 +41,9 @@ int reverse_resolve = 0;
 int manage_gids;
 int use_ipaddr = -1;
 
+struct state_paths etab;
+struct state_paths rmtab;
+
 char *conf_path = NFS_CONFFILE;
 
 /* PRC: a high-availability callout program can be specified with -H
@@ -110,8 +114,8 @@ unregister_services (void)
 static void
 cleanup_lockfiles (void)
 {
-	unlink(_PATH_ETABLCK);
-	unlink(_PATH_RMTABLCK);
+	unlink(etab.lockfn);
+	unlink(rmtab.lockfn);
 }
 
 /* Wait for all worker child processes to exit and reap them */
@@ -181,6 +185,8 @@ fork_workers(void)
 	wait_for_workers();
 	unregister_services();
 	cleanup_lockfiles();
+	free_state_path_names(&etab);
+	free_state_path_names(&rmtab);
 	xlog(L_NOTICE, "mountd: no more workers, exiting\n");
 	exit(0);
 }
@@ -198,6 +204,8 @@ killer (int sig)
 		wait_for_workers();
 	}
 	cleanup_lockfiles();
+	free_state_path_names(&etab);
+	free_state_path_names(&rmtab);
 	xlog (L_NOTICE, "Caught signal %d, un-registering and exiting.", sig);
 	exit(0);
 }
@@ -656,7 +664,6 @@ get_exportlist(void)
 int
 main(int argc, char **argv)
 {
-	char    *state_dir = NFS_STATEDIR;
 	char	*progname;
 	char	*s;
 	unsigned int listeners = 0;
@@ -684,8 +691,8 @@ main(int argc, char **argv)
 	ha_callout_prog = conf_get_str("mountd", "ha-callout");
 
 	s = conf_get_str("mountd", "state-directory-path");
-	if (s)
-		state_dir = s;
+	if (s && !state_setup_basedir(argv[0], s))
+		exit(1);
 
 	/* NOTE: following uses "nfsd" section of nfs.conf !!!! */
 	if (conf_get_bool("nfsd", "udp", NFSCTL_UDPISSET(_rpcprotobits)))
@@ -758,7 +765,8 @@ main(int argc, char **argv)
 			reverse_resolve = 1;
 			break;
 		case 's':
-			state_dir = xstrdup(optarg);
+			if (!state_setup_basedir(argv[0], optarg))
+				exit(1);
 			break;
 		case 't':
 			num_threads = atoi (optarg);
@@ -790,11 +798,10 @@ main(int argc, char **argv)
 		fprintf(stderr, "%s: No protocol versions specified!\n", progname); 
 		usage(progname, 1);
 	}
-	if (chdir(state_dir)) {
-		fprintf(stderr, "%s: chdir(%s) failed: %s\n",
-			progname, state_dir, strerror(errno));
-		exit(1);
-	}
+	if (!setup_state_path_names(progname, ETAB, ETABTMP, ETABLCK, &etab))
+		return 1;
+	if (!setup_state_path_names(progname, RMTAB, RMTABTMP, RMTABLCK, &rmtab))
+		return 1;
 
 	if (getrlimit (RLIMIT_NOFILE, &rlim) != 0)
 		fprintf(stderr, "%s: getrlimit (RLIMIT_NOFILE) failed: %s\n",
@@ -888,6 +895,8 @@ main(int argc, char **argv)
 
 	xlog(L_ERROR, "RPC service loop terminated unexpectedly. Exiting...\n");
 	unregister_services();
+	free_state_path_names(&etab);
+	free_state_path_names(&rmtab);
 	exit(1);
 }
 
diff --git a/utils/mountd/mountd.man b/utils/mountd/mountd.man
index 9f0a51f..9978afc 100644
--- a/utils/mountd/mountd.man
+++ b/utils/mountd/mountd.man
@@ -144,7 +144,7 @@ Instead, mount the nfsd filesystem on
 .IR /proc/fs/nfsd .
 .TP
 .BI "\-s," "" " \-\-state\-directory\-path "  directory
-Specify a directory in which to place statd state information.
+Specify a directory in which to place state information (etab and rmtab).
 If this option is not specified the default of
 .I /var/lib/nfs
 is used.
diff --git a/utils/mountd/rmtab.c b/utils/mountd/rmtab.c
index 527377f..3ae0dbb 100644
--- a/utils/mountd/rmtab.c
+++ b/utils/mountd/rmtab.c
@@ -28,6 +28,8 @@
 
 extern int reverse_resolve;
 
+extern struct state_paths rmtab;
+
 /* If new path is a link do not destroy it but place the
  * file where the link points.
  */
@@ -59,7 +61,7 @@ mountlist_add(char *host, const char *path)
 	int		lockid;
 	long		pos;
 
-	if ((lockid = xflock(_PATH_RMTABLCK, "a")) < 0)
+	if ((lockid = xflock(rmtab.lockfn, "a")) < 0)
 		return;
 	setrmtabent("r+");
 	while ((rep = getrmtabent(1, &pos)) != NULL) {
@@ -99,13 +101,13 @@ mountlist_del(char *hname, const char *path)
 	int		lockid;
 	int		match;
 
-	if ((lockid = xflock(_PATH_RMTABLCK, "w")) < 0)
+	if ((lockid = xflock(rmtab.lockfn, "w")) < 0)
 		return;
 	if (!setrmtabent("r")) {
 		xfunlock(lockid);
 		return;
 	}
-	if (!(fp = fsetrmtabent(_PATH_RMTABTMP, "w"))) {
+	if (!(fp = fsetrmtabent(rmtab.tmpfn, "w"))) {
 		endrmtabent();
 		xfunlock(lockid);
 		return;
@@ -121,9 +123,9 @@ mountlist_del(char *hname, const char *path)
 		if (!match || rep->r_count)
 			fputrmtabent(fp, rep, NULL);
 	}
-	if (slink_safe_rename(_PATH_RMTABTMP, _PATH_RMTAB) < 0) {
+	if (slink_safe_rename(rmtab.tmpfn, rmtab.statefn) < 0) {
 		xlog(L_ERROR, "couldn't rename %s to %s",
-				_PATH_RMTABTMP, _PATH_RMTAB);
+				rmtab.tmpfn, rmtab.statefn);
 	}
 	endrmtabent();	/* close & unlink */
 	fendrmtabent(fp);
@@ -138,7 +140,7 @@ mountlist_del_all(const struct sockaddr *sap)
 	FILE		*fp;
 	int		lockid;
 
-	if ((lockid = xflock(_PATH_RMTABLCK, "w")) < 0)
+	if ((lockid = xflock(rmtab.lockfn, "w")) < 0)
 		return;
 	hostname = host_canonname(sap);
 	if (hostname == NULL) {
@@ -151,7 +153,7 @@ mountlist_del_all(const struct sockaddr *sap)
 	if (!setrmtabent("r"))
 		goto out_free;
 
-	if (!(fp = fsetrmtabent(_PATH_RMTABTMP, "w")))
+	if (!(fp = fsetrmtabent(rmtab.tmpfn, "w")))
 		goto out_close;
 
 	while ((rep = getrmtabent(1, NULL)) != NULL) {
@@ -160,9 +162,9 @@ mountlist_del_all(const struct sockaddr *sap)
 			continue;
 		fputrmtabent(fp, rep, NULL);
 	}
-	if (slink_safe_rename(_PATH_RMTABTMP, _PATH_RMTAB) < 0) {
+	if (slink_safe_rename(rmtab.tmpfn, rmtab.statefn) < 0) {
 		xlog(L_ERROR, "couldn't rename %s to %s",
-				_PATH_RMTABTMP, _PATH_RMTAB);
+				rmtab.tmpfn, rmtab.statefn);
 	}
 	fendrmtabent(fp);
 out_close:
@@ -195,11 +197,11 @@ mountlist_list(void)
 	struct stat		stb;
 	int			lockid;
 
-	if ((lockid = xflock(_PATH_RMTABLCK, "r")) < 0)
+	if ((lockid = xflock(rmtab.lockfn, "r")) < 0)
 		return NULL;
-	if (stat(_PATH_RMTAB, &stb) < 0) {
+	if (stat(rmtab.statefn, &stb) < 0) {
 		xlog(L_ERROR, "can't stat %s: %s",
-				_PATH_RMTAB, strerror(errno));
+				rmtab.statefn, strerror(errno));
 		xfunlock(lockid);
 		return NULL;
 	}
-- 
2.7.4

